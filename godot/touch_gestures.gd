extends RefCounted
## Touch-only gesture interpreter. No mouse emulation or UI controls are consumed.
## A gesture must begin in the playable 3D area; the caller blocks UI origins.
const TAP_SLOP := 24.0
const SWIPE_UP := 72.0
const DOUBLE_TAP_MS := 340
const TWO_FINGER_MS := 420

var fingers: Dictionary = {}
var primary_id := -1
var start_lane := 0
var last_tap_ms := -10000
var last_tap_position := Vector2(-10000.0, -10000.0)
var multi_active := false
var multi_start_ms := 0
var multi_tap_allowed := false
var multi_deltas: Array[Vector2] = []

func reset() -> void:
    fingers.clear()
    primary_id = -1
    multi_active = false
    multi_tap_allowed = false
    multi_deltas.clear()
    last_tap_ms = -10000

func handle(event: InputEvent, enabled: bool, blocked_start: bool, now_ms: int, lane_now: int, viewport_width: float) -> Dictionary:
    if not enabled:
        reset()
        return {}
    var touch := event as InputEventScreenTouch
    if touch != null:
        if touch.pressed:
            if blocked_start or fingers.has(touch.index) or fingers.size() >= 2:
                return {}
            fingers[touch.index] = {"start": touch.position, "time": now_ms}
            if fingers.size() == 1:
                primary_id = touch.index
                start_lane = lane_now
            else:
                multi_active = true
                multi_start_ms = now_ms
                multi_tap_allowed = now_ms - int(fingers[primary_id]["time"]) <= 180
                multi_deltas.clear()
                last_tap_ms = -10000
            return {"captured": true}
        if not fingers.has(touch.index):
            return {}
        var origin: Vector2 = fingers[touch.index]["start"]
        var duration: int = now_ms - int(fingers[touch.index]["time"])
        var delta: Vector2 = touch.position - origin
        fingers.erase(touch.index)
        if multi_active:
            multi_deltas.append(delta)
            if not fingers.is_empty():
                return {"captured": true}
            var result := {"captured": true}
            if multi_deltas.size() == 2:
                var a: Vector2 = multi_deltas[0]
                var b: Vector2 = multi_deltas[1]
                if a.y < -SWIPE_UP and b.y < -SWIPE_UP and absf(a.x) < absf(a.y) and absf(b.x) < absf(b.y):
                    result["action"] = "attack"
                elif multi_tap_allowed and now_ms - multi_start_ms <= TWO_FINGER_MS and a.length() <= TAP_SLOP and b.length() <= TAP_SLOP:
                    result["action"] = "shield"
            multi_active = false
            primary_id = -1
            multi_deltas.clear()
            return result
        primary_id = -1
        var single := {"captured": true}
        if delta.y < -SWIPE_UP and absf(delta.y) > absf(delta.x) * 1.2:
            single["action"] = "jump"
        elif absf(delta.x) > absf(delta.y) * 1.2:
            var target := _steer_target(delta.x, viewport_width)
            if target != lane_now:
                single["lane"] = target
        elif delta.length() <= TAP_SLOP and duration <= 260:
            if now_ms - last_tap_ms <= DOUBLE_TAP_MS and touch.position.distance_to(last_tap_position) <= 76.0:
                single["action"] = "turbo"
                last_tap_ms = -10000
            else:
                last_tap_ms = now_ms
                last_tap_position = touch.position
        return single
    var drag := event as InputEventScreenDrag
    if drag == null or not fingers.has(drag.index):
        return {}
    if multi_active or drag.index != primary_id:
        return {"captured": true}
    var delta: Vector2 = drag.position - fingers[drag.index]["start"]
    var result := {"captured": true}
    if absf(delta.x) > absf(delta.y) * 1.2:
        var target := _steer_target(delta.x, viewport_width)
        if target != lane_now:
            result["lane"] = target
    return result

func _steer_target(horizontal: float, viewport_width: float) -> int:
    var step := clampf(viewport_width * 0.10, 32.0, 64.0)
    if absf(horizontal) < step * 0.65:
        return start_lane
    return clampi(start_lane + clampi(roundi(horizontal / step), -2, 2), -1, 1)
