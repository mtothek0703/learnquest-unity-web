extends SceneTree
# Run with Godot 4.4.1: godot --headless --path godot --script res://adventure/adventure_completion_regression_test.gd
const Mission = preload("res://adventure/adventure_mission.gd")
func _initialize() -> void:
    var mission = Mission.new()
    assert(not mission.is_complete())
    for i in range(3):
        assert(mission.collect_crystal("crystal_%d" % i))
    assert(not mission.is_complete(), "Crystals alone must not finish mission")
    assert(not mission.can_open_portal())
    assert(mission.activate_switch("left"))
    assert(not mission.is_complete(), "One switch is insufficient")
    assert(mission.activate_switch("platform"))
    assert(mission.is_complete(), "All three crystals and both switches finish mission")
    assert(mission.can_open_portal())
    assert(not mission.activate_switch("platform"), "Repeated switch must not count")
    mission.reset_mission()
    assert(not mission.is_complete(), "Retry must reset mission completion")
    assert(not mission.can_open_portal())
    print("ADVENTURE COMPLETION REGRESSION TEST PASSED")
    quit(0)
