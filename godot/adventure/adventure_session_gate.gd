extends RefCounted
## Isolated adventure transition gate. No Runner nodes or touch gestures are changed.
## Integration must explicitly opt in after the three-question training gate.
const RACE := "race"
const TRANSITION := "transition"
const ON_FOOT := "on_foot"
const RESULTS := "results"

var enabled := false
var state := RACE
var completed_questions := 0
var entered_adventure := false
var return_pending := false

func reset() -> void:
    state = RACE
    completed_questions = 0
    entered_adventure = false
    return_pending = false

func record_question() -> void:
    completed_questions = mini(3, completed_questions + 1)

func can_dismount(runner_phase: String, world_index: int, quiz_active: bool) -> bool:
    return enabled and state == RACE and runner_phase == RACE and world_index == 0 and not quiz_active and completed_questions == 3 and not entered_adventure

func request_dismount(runner_phase: String, world_index: int, quiz_active: bool) -> bool:
    if not can_dismount(runner_phase, world_index, quiz_active):
        return false
    state = TRANSITION
    return true

func confirm_on_foot() -> bool:
    if state != TRANSITION or entered_adventure:
        return false
    state = ON_FOOT
    entered_adventure = true
    return true

func request_remount() -> bool:
    if state != ON_FOOT:
        return false
    state = TRANSITION
    return_pending = true
    return true

func confirm_race_resume() -> bool:
    if state != TRANSITION or not return_pending:
        return false
    state = RACE
    return_pending = false
    return true
