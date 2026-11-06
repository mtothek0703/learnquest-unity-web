extends SceneTree

# Execute: godot --headless --path godot --script res://adventure/runner_entry_gate_test.gd
func _initialize() -> void:
    var world_script: Script = load("res://world.gd")
    assert(world_script != null)
    var world: Node = world_script.new()
    assert(world != null)
    # Never add to the scene tree: this tests the pure entry guard only.
    world.set("phase", "race")
    world.set("started", true)
    world.set("quiz_active", false)
    world.set("world_choice", 0)
    assert(not world.call("can_enter_neon_adventure"), "Feature-off must deny entry")
    world.set("phase", "training")
    assert(not world.call("can_enter_neon_adventure"), "Training must deny entry")
    world.set("phase", "results")
    assert(not world.call("can_enter_neon_adventure"), "Results must deny entry")
    world.free()
    print("ADVENTURE RUNNER ENTRY GATE TEST PASSED")
    quit(0)
