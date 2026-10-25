extends RefCounted
## Native touch gesture interpreter: never consumes mouse events or UI controls.
## Only fingers that began on the 3D playfield may control the rider.
const TAP_SLOP := 24.0
const SWIPE_UP := 72.0
const DOUBLE_TAP_MS := 340
const TWO_FINGER_MS := 420
# A late second finger is a new touch, not a deliberate simultaneous gesture.
const TWO_FINGER_START_MS := 350
const MAX_ATTACK_MS := 900
# Fingers starting almost together can be a pinch/accidental touch, not a
# deliberate two-finger upward attack. Keep shield taps available.
const MIN_ATTACK_START_SPACING := 40.0

var fingers: Dictionary = {}
var blocked_fingers: Dictionary = {}
var primary_id := -1
var start_lane := 0
var last_target_lane := 0 # Stable lane while the finger hovers near a boundary.
var last_tap_ms := -10000
var last_tap_position := Vector2(-10000.0, -10000.0)
var multi_active := false
var multi_start_ms := 0
var multi_tap_allowed := false
# A shield tap must stay a tap for its entire path, not just at release.
var multi_moved := false
var multi_deltas: Array[Vector2] = []
# Track both live positions so a deliberate attack can fire before release.
var multi_positions: Dictionary = {}
# Preserve both origins and final positions until the entire gesture ends.
# This also protects the release-only fallback when browsers skip drag frames.
var multi_origins: Dictionary = {}
var multi_attack_fired := false
# Lock out an attack after sideways-first two-finger scrolling or pinching.
var multi_attack_blocked := false
var cancelled := false
var single_mode := "" # undecided -> steer OR jump, never both
var moved_outside_tap := false

func _clear_active() -> void:
    fingers.clear()
    primary_id = -1
    multi_active = false
    multi_tap_allowed = false
    multi_moved = false
    multi_deltas.clear()
    multi_positions.clear()
    multi_origins.clear()
    multi_attack_fired = false
    multi_attack_blocked = false
    single_mode = ""
    moved_outside_tap = false
    last_target_lane = 0

func reset() -> void:
    _clear_active()
    blocked_fingers.clear()
    cancelled = false
    last_tap_ms = -10000

# A viewport relayout changes touch coordinates while fingers may still be
# physically down. Quarantine every old pointer until it is released; unlike
# reset(), this also prevents a new finger from starting a stray gesture.
func invalidate_layout() -> void:
    for index in fingers.keys():
        blocked_fingers[index] = true
    _clear_active()
    cancelled = not blocked_fingers.is_empty()
    last_tap_ms = -10000

func handle(event: InputEvent, enabled: bool, blocked_start: bool, now_ms: int, lane_now: int, viewport_width: float, viewport_height: float = 0.0) -> Dictionary:
    if not enabled:
        reset()
        return {}
    var jump_swipe := _jump_swipe_threshold(viewport_height)
    var touch := event as InputEventScreenTouch
    if touch != null:
        # iOS/Android may cancel a pointer when the app loses focus, the OS
        # takes over a gesture or a browser interrupts a touch sequence.
        # Cancellation is NOT a release: never award Turbo, Shield or a jump.
        # Keep other fingers quarantined until lifted so a half-cancelled
        # two-finger gesture cannot become a new power-up.
        if touch.canceled:
            var was_playfield := fingers.has(touch.index)
            var was_blocked := blocked_fingers.has(touch.index)
            if not was_playfield and not was_blocked:
                return {}
            fingers.erase(touch.index)
            multi_positions.erase(touch.index)
            blocked_fingers.erase(touch.index)
            last_tap_ms = -10000
            if fingers.is_empty():
                _clear_active()
                cancelled = not blocked_fingers.is_empty()
            else:
                cancelled = true
                multi_tap_allowed = false
            return {"captured": true} if was_playfield else {}
        if touch.pressed:
            if fingers.has(touch.index) or blocked_fingers.has(touch.index):
                return {}
            # A UI touch, or a third finger, cancels the entire in-flight
            # gesture. Never let a remaining finger turn into a jump/ability.
            if blocked_start or not blocked_fingers.is_empty() or fingers.size() >= 2 or multi_active:
                blocked_fingers[touch.index] = true
                last_tap_ms = -10000
                if not fingers.is_empty():
                    cancelled = true
                return {}
            fingers[touch.index] = {"start": touch.position, "time": now_ms}
            multi_positions[touch.index] = touch.position
            multi_origins[touch.index] = touch.position
            if fingers.size() == 1:
                primary_id = touch.index
                start_lane = lane_now
                last_target_lane = lane_now
                single_mode = ""
                moved_outside_tap = false
            else:
                multi_active = true
                multi_start_ms = now_ms
                multi_tap_allowed = now_ms - int(fingers[primary_id]["time"]) <= 180 and not moved_outside_tap
                # A second finger after steering/scrolling is not a power-up.
                if single_mode != "" or moved_outside_tap or now_ms - int(fingers[primary_id]["time"]) > TWO_FINGER_START_MS:
                    cancelled = true
                multi_moved = false
                multi_attack_blocked = _attack_fingers_too_close()
                multi_deltas.clear()
                last_tap_ms = -10000
            return {"captured": true}
        if blocked_fingers.has(touch.index):
            blocked_fingers.erase(touch.index)
            if blocked_fingers.is_empty() and fingers.is_empty():
                cancelled = false
            return {}
        if not fingers.has(touch.index):
            return {}
        var origin: Vector2 = fingers[touch.index]["start"]
        var duration: int = now_ms - int(fingers[touch.index]["time"])
        var delta: Vector2 = touch.position - origin
        fingers.erase(touch.index)
        # Keep the final location for a pinch check after both releases.
        multi_positions[touch.index] = touch.position
        if cancelled:
            if fingers.is_empty():
                _clear_active()
                if blocked_fingers.is_empty():
                    cancelled = false
            return {"captured": true}
        if multi_active:
            # A two-finger attack already fired on drag must never fire twice.
            if multi_attack_fired:
                if fingers.is_empty():
                    _clear_active()
                return {"captured": true}
            multi_deltas.append(delta)
            if delta.length() > TAP_SLOP:
                multi_moved = true
            if not fingers.is_empty():
                return {"captured": true}
            var result := {"captured": true}
            if multi_deltas.size() == 2:
                if _pinch_changed_span():
                    multi_attack_blocked = true
                var a: Vector2 = multi_deltas[0]
                var b: Vector2 = multi_deltas[1]
                if not multi_attack_blocked and now_ms - multi_start_ms <= MAX_ATTACK_MS and a.y < -SWIPE_UP and b.y < -SWIPE_UP and absf(a.x) < absf(a.y) and absf(b.x) < absf(b.y):
                    result["action"] = "attack"
                elif multi_tap_allowed and not multi_moved and now_ms - multi_start_ms <= TWO_FINGER_MS and a.length() <= TAP_SLOP and b.length() <= TAP_SLOP:
                    result["action"] = "shield"
            _clear_active()
            return result
        var single := {"captured": true}
        if single_mode == "steer":
            var target := _steer_target(delta.x, viewport_width)
            if target != lane_now:
                single["lane"] = target
        elif single_mode == "jump":
            pass # Already fired on drag; do not jump twice on release.
        elif single_mode == "ignore":
            pass # Downward-first scroll stays inert even if released far above origin.
        elif delta.length() <= TAP_SLOP and duration <= 260 and not moved_outside_tap:
            # Check taps BEFORE direction: real fingers drift by a few pixels.
            if now_ms - last_tap_ms <= DOUBLE_TAP_MS and touch.position.distance_to(last_tap_position) <= 76.0:
                single["action"] = "turbo"
                last_tap_ms = -10000
            else:
                last_tap_ms = now_ms
                last_tap_position = touch.position
        elif delta.y < -jump_swipe and absf(delta.y) > absf(delta.x) * 1.2:
            single["action"] = "jump" # Fallback if no drag event was delivered.
            last_tap_ms = -10000
        elif absf(delta.x) > absf(delta.y) * 1.2:
            var target := _steer_target(delta.x, viewport_width)
            if target != lane_now:
                single["lane"] = target
            last_tap_ms = -10000
        else:
            last_tap_ms = -10000
        _clear_active()
        return single
    var drag := event as InputEventScreenDrag
    if drag == null or not fingers.has(drag.index):
        return {}
    multi_positions[drag.index] = drag.position
    if multi_active or cancelled or drag.index != primary_id:
        # Track both fingers separately. A Super Attack fires as soon as BOTH
        # move deliberately upward; the player need not lift their fingers.
        # Never treat one moving finger or a UI-cancelled gesture as an attack.
        if multi_active and not cancelled:
            var travel: Vector2 = drag.position - fingers[drag.index]["start"]
            if travel.length() > TAP_SLOP:
                multi_moved = true
            # Lock the first deliberate scroll direction for the full touch.
            # Reversing a two-finger downward scroll must not spend attack
            # energy when both fingers eventually pass the upward threshold.
            if travel.y >= 48.0 and travel.y > absf(travel.x) * 1.2:
                multi_attack_blocked = true
            # Never turn an earlier horizontal scroll into a vertical attack.
            if absf(travel.x) >= 48.0 and absf(travel.x) > absf(travel.y) * 1.15:
                multi_attack_blocked = true
            # Pinching with both fingers must not spend attack energy, even
            # when the gesture also travels upward. Wait for both fingers to
            # move so a normal staggered upward swipe is not misclassified.
            if fingers.size() == 2 and _both_fingers_moved() and _pinch_changed_span():
                multi_attack_blocked = true
            if not multi_attack_fired and not multi_attack_blocked and fingers.size() == 2 and now_ms - multi_start_ms <= MAX_ATTACK_MS:
                var ids: Array = fingers.keys()
                var a: Vector2 = multi_positions[ids[0]] - fingers[ids[0]]["start"]
                var b: Vector2 = multi_positions[ids[1]] - fingers[ids[1]]["start"]
                if a.y < -SWIPE_UP and b.y < -SWIPE_UP and absf(a.x) < absf(a.y) and absf(b.x) < absf(b.y):
                    multi_attack_fired = true
                    multi_tap_allowed = false
                    last_tap_ms = -10000
                    return {"captured": true, "action": "attack"}
        return {"captured": true}
    var delta: Vector2 = drag.position - fingers[drag.index]["start"]
    var result := {"captured": true}
    if delta.length() > TAP_SLOP:
        moved_outside_tap = true
        last_tap_ms = -10000
    if single_mode == "":
        # A deliberate downward scroll locks this touch out of game actions.
        # Without this, scrolling down and then reversing past the origin
        # could unexpectedly jump, especially on short landscape screens.
        if delta.y >= maxf(36.0, jump_swipe * 0.65) and delta.y > absf(delta.x) * 1.2:
            single_mode = "ignore"
        elif delta.y < -jump_swipe and absf(delta.y) > absf(delta.x) * 1.2:
            single_mode = "jump"
            result["action"] = "jump" # Fire immediately, without finger lift.
        elif absf(delta.x) > absf(delta.y) * 1.2 and absf(delta.x) >= _steer_step(viewport_width) * 0.65:
            single_mode = "steer"
    if single_mode == "steer":
        var target := _steer_target(delta.x, viewport_width)
        if target != lane_now:
            result["lane"] = target
    return result

## Short landscape screens should not require a quarter-screen thumb sweep.
## Keep the longer original threshold on portrait screens to avoid false jumps.
func _jump_swipe_threshold(viewport_height: float) -> float:
    if viewport_height <= 0.0:
        return SWIPE_UP # Compatibility with callers that only pass width.
    return clampf(viewport_height * 0.16, 48.0, SWIPE_UP)

func _steer_step(viewport_width: float) -> float:
    return clampf(viewport_width * 0.10, 32.0, 64.0)

func _steer_target(horizontal: float, viewport_width: float) -> int:
    var step := _steer_step(viewport_width)
    var target := start_lane
    if absf(horizontal) >= step * 0.65:
        target = clampi(start_lane + clampi(roundi(horizontal / step), -2, 2), -1, 1)
    if target == last_target_lane:
        return target
    # Finger jitter near a lane boundary must not oscillate the rider
    # between lanes. The margin is relative to viewport width, so narrow
    # phones and tablets have the same proportional steering feel.
    var previous_relative := last_target_lane - start_lane
    var next_relative := target - start_lane
    var boundary := 0.0
    if next_relative > previous_relative:
        boundary = (float(previous_relative) + 0.5) * step
        if previous_relative == 0:
            boundary = 0.65 * step
        elif previous_relative == -1:
            boundary = -0.65 * step
        if horizontal < boundary + 0.18 * step:
            return last_target_lane
    else:
        boundary = (float(previous_relative) - 0.5) * step
        if previous_relative == 0:
            boundary = -0.65 * step
        elif previous_relative == 1:
            boundary = 0.65 * step
        if horizontal > boundary - 0.18 * step:
            return last_target_lane
    last_target_lane = target
    return target

# A close two-finger start is ambiguous on small phone screens: a tiny pinch
# can move both fingers upward without a measurable span change. Do not spend
# Super Attack energy until the player starts a fresh, spaced gesture.
func _attack_fingers_too_close() -> bool:
    if multi_origins.size() != 2:
        return false
    var ids: Array = multi_origins.keys()
    var first: Vector2 = multi_origins[ids[0]]
    var second: Vector2 = multi_origins[ids[1]]
    return first.distance_to(second) < MIN_ATTACK_START_SPACING

# Compare changes along the original two-finger separation axis. This
# avoids mistaking a slight difference in upward swipe timing for a pinch.
func _pinch_changed_span() -> bool:
    if multi_origins.size() != 2 or multi_positions.size() != 2:
        return false
    var ids: Array = multi_origins.keys()
    var original: Vector2 = multi_origins[ids[1]] - multi_origins[ids[0]]
    if original.length() < MIN_ATTACK_START_SPACING:
        return false
    var current: Vector2 = multi_positions[ids[1]] - multi_positions[ids[0]]
    var span_change := absf((current - original).dot(original.normalized()))
    return span_change > maxf(36.0, original.length() * 0.30)

func _both_fingers_moved() -> bool:
    if multi_origins.size() != 2 or multi_positions.size() != 2:
        return false
    for id in multi_origins:
        if multi_positions[id].distance_to(multi_origins[id]) <= TAP_SLOP:
            return false
    return true
