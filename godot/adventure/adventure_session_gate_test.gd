extends SceneTree
const Gate = preload("res://adventure/adventure_session_gate.gd")

func _initialize() -> void:
    var gate = Gate.new()
    assert(not gate.request_dismount("race", 0, false), "Feature off must preserve Runner")
    gate.enabled = true
    assert(not gate.request_dismount("race", 0, false), "Three questions required")
    for i in range(2):
        gate.record_question()
    assert(not gate.request_dismount("race", 0, false), "Two questions insufficient")
    gate.record_question()
    assert(not gate.request_dismount("race", 1, false), "Only Neon City")
    assert(not gate.request_dismount("race", 0, true), "No interruption of active quiz")
    assert(not gate.request_dismount("training", 0, false), "Race required")
    assert(gate.request_dismount("race", 0, false), "Qualified dismount")
    assert(not gate.request_dismount("race", 0, false), "No duplicate dismount")
    assert(gate.confirm_on_foot(), "Enter on-foot")
    assert(not gate.confirm_on_foot(), "No duplicate entry")
    assert(gate.request_remount(), "Remount")
    assert(gate.confirm_race_resume(), "Resume same race")
    assert(not gate.request_dismount("race", 0, false), "Adventure only once per round")
    gate.reset()
    assert(not gate.request_dismount("race", 0, false), "Retry must requalify")
    print("ADVENTURE SESSION GATE TEST PASSED")
    quit(0)
