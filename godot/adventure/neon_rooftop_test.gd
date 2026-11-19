extends SceneTree
## Run: godot --headless --path godot --script res://adventure/neon_rooftop_test.gd
func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var packed: PackedScene = load("res://adventure/neon_rooftop.tscn")
    assert(packed != null, "A1 rooftop scene missing")
    var arena := packed.instantiate()
    root.add_child(arena)
    await process_frame
    await physics_frame
    var player := arena.get_node_or_null("OnFootPlayer") as CharacterBody3D
    assert(player != null, "Missing CharacterBody3D")
    assert(player.get_node_or_null("CollisionShape3D") != null, "Missing player collision")
    assert(arena.get_node_or_null("OnFootCamera") is Camera3D, "Missing third-person camera")
    assert(arena.get_child_count() >= 6, "Missing collidable level geometry")
    arena.move_touch = Vector2.RIGHT
    for i in range(12):
        await physics_frame
    assert(player.position.x > 0.05, "Walking did not move the player")
    arena.move_touch = Vector2.ZERO
    arena.jump_requested = true
    for i in range(3):
        await physics_frame
    assert(player.velocity.y > 0.0, "Jump did not activate")
    arena._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
    assert(arena.move_touch == Vector2.ZERO, "Focus loss did not clear joystick")
    print("NEON ROOFTOP A1 TEST PASSED")
    quit(0)
