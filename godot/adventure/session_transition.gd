extends RefCounted
## Feature-off by default. A race owner must explicitly opt in.
## Pure session coordinator: does not mutate world.gd or runner input.
signal mode_changed(previous_mode: String, next_mode: String)

const RACE := "race"
const ON_FOOT := "on_foot"
const TRANSITION := "transition"

var enabled := false
var mode := RACE
var pending_target := ""
var session_id := -1
var completed_session_ids: Dictionary = {}

func begin_session(new_session_id: int) -> void:
    session_id = new_session_id
    pending_target = ""
    mode = RACE

func request_dismount(race_active: bool, quiz_active: bool, neon_city: bool) -> bool:
    if not enabled or mode != RACE or pending_target != "":
        return false
    if not race_active or quiz_active or not neon_city or session_id < 0:
        return false
    return _begin_transition(ON_FOOT)

func request_mount(exit_unlocked: bool) -> bool:
    if not enabled or mode != ON_FOOT or pending_target != "":
        return false
    if not exit_unlocked or completed_session_ids.has(session_id):
        return false
    return _begin_transition(RACE)

func complete_transition() -> bool:
    if mode != TRANSITION or pending_target == "":
        return false
    var target := pending_target
    pending_target = ""
    var old_mode := mode
    mode = target
    if target == RACE:
        completed_session_ids[session_id] = true
    mode_changed.emit(old_mode, mode)
    return true

func cancel_transition() -> bool:
    if mode != TRANSITION:
        return false
    var previous := ON_FOOT if pending_target == RACE else RACE
    pending_target = ""
    mode = previous
    return true

func reset() -> void:
    pending_target = ""
    mode = RACE
    session_id = -1
    completed_session_ids.clear()

func _begin_transition(target: String) -> bool:
    pending_target = target
    var old_mode := mode
    mode = TRANSITION
    mode_changed.emit(old_mode, mode)
    return true
