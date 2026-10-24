extends RefCounted
## Native touch gesture interpreter: never consumes mouse events or UI controls.
## Only fingers that began on the 3D playfield may control the rider.
const TAP_SLOP := 24.0
const SWIPE_UP := 72.0
const DOUBLE_TAP_MS := 340
const TWO_FINGER_MS := 420
const MAX_ATTACK_MS := 900

var fingers: Dictionary = {}
var blocked_fingers: Dictionary = {}
var primary_id := -1
var start_lane := 0
var last_tap_ms := -10000
var last_tap_position := Vector2(-10000.0, -10000.0)
var multi_active := false
var multi_start_ms := 0
var multi_tap_allowed := false
var multi_deltas: Array[Vector2] = []
var cancelled := false
var single_mode := "" # undecided -> steer OR jump, never both
var moved_outside_tap := false

func _clear_active() -> void:
    fingers.clear()
    primary_id = -1
    multi_active = false
    multi_tap_allowed = false
    multi_deltas.clear()
    single_mode = ""
    moved_outside_tap = false

func reset() -> void:
    _clear_active()
    blocked_fingers.clear()
    cancelled = false
    last_tap_ms = -10000

func handle(event: InputEvent, enabled: bool, blocked_start: bool, now_ms: int, lane_now: int, viewport_width: float) -> Dictionary:
    if not enabled:
        reset()
        return {}
    var touch := event as InputEventScreenTouch
    if touch != null:
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
            if fingers.size() == 1:
                primary_id = touch.index
                start_lane = lane_now
                single_mode = ""
                moved_outside_tap = false
            else:
                multi_active = true
                multi_start_ms = now_ms
                multi_tap_allowed = now_ms - int(fingers[primary_id]["time"]) <= 180 and not moved_outside_tap
                # A second finger after steering/scrolling is not a power-up.
                if single_mode != "" or moved_outside_tap:
                    cancelled = true
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
        if cancelled:
            if fingers.is_empty():
                _clear_active()
                if blocked_fingers.is_empty():
                    cancelled = false
            return {"captured": true}
        if multi_active:
            multi_deltas.append(delta)
            if not fingers.is_empty():
                return {"captured": true}
            var result := {"captured": true}
            if multi_deltas.size() == 2:
                var a: Vector2 = multi_deltas[0]
                var b: Vector2 = multi_deltas[1]
                if now_ms - multi_start_ms <= MAX_ATTACK_MS and a.y < -SWIPE_UP and b.y < -SWIPE_UP and absf(a.x) < absf(a.y) and absf(b.x) < absf(b.y):
                    result["action"] = "attack"
                elif multi_tap_allowed and now_ms - multi_start_ms <= TWO_FINGER_MS and a.length() <= TAP_SLOP and b.length() <= TAP_SLOP:
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
        elif delta.length() <= TAP_SLOP and duration <= 260 and not moved_outside_tap:
            # Check taps BEFORE direction: real fingers drift by a few pixels.
            if now_ms - last_tap_ms <= DOUBLE_TAP_MS and touch.position.distance_to(last_tap_position) <= 76.0:
                single["action"] = "turbo"
                last_tap_ms = -10000
            else:
                last_tap_ms = now_ms
                last_tap_position = touch.position
        elif delta.y < -SWIPE_UP and absf(delta.y) > absf(delta.x) * 1.2:
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
    if multi_active or cancelled or drag.index != primary_id:
        return {"captured": true}
    var delta: Vector2 = drag.position - fingers[drag.index]["start"]
    var result := {"captured": true}
    if delta.length() > TAP_SLOP:
        moved_outside_tap = true
        last_tap_ms = -10000
    if single_mode == "":
        if delta.y < -SWIPE_UP and absf(delta.y) > absf(delta.x) * 1.2:
            single_mode = "jump"
            result["action"] = "jump" # Fire immediately, without finger lift.
        elif absf(delta.x) > absf(delta.y) * 1.2 and absf(delta.x) >= _steer_step(viewport_width) * 0.65:
            single_mode = "steer"
    if single_mode == "steer":
        var target := _steer_target(delta.x, viewport_width)
        if target != lane_now:
            result["lane"] = target
    return result

func _steer_step(viewport_width: float) -> float:
    return clampf(viewport_width * 0.10, 32.0, 64.0)

func _steer_target(horizontal: float, viewport_width: float) -> int:
    var step := _steer_step(viewport_width)
    if absf(horizontal) < step * 0.65:
        return start_lane
    return clampi(start_lane + clampi(roundi(horizontal / step), -2, 2), -1, 1)
