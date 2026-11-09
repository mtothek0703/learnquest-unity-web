extends SceneTree
# Run: godot --headless --path godot --script res://adventure/adventure_touch_focus_test.gd
const Touch = preload("res://adventure/adventure_touch.gd")

class FakeWalker:
    extends Node
    var last_direction := Vector2(99, 99)
    func set_touch_move(direction: Vector2) -> void:
        last_direction = direction

func _initialize() -> void:
    var root := Node.new()
    root.name = "Root"
    get_root().add_child(root)
    var walker := FakeWalker.new()
    walker.name = "Walker"
    root.add_child(walker)
    var pad := Touch.new()
    pad.name = "Pad"
    pad.walker_path = NodePath("../Walker")
    root.add_child(pad)
    pad.active_pointer = 3
    pad._set_direction(Vector2(0.7, 0.2))
    assert(walker.last_direction.length() > 0.1)
    pad._notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
    assert(pad.active_pointer == -1)
    assert(pad.current_vector == Vector2.ZERO)
    assert(walker.last_direction == Vector2.ZERO)
    pad.active_pointer = 4
    pad._set_direction(Vector2.LEFT)
    pad.cancel_touch()
    assert(pad.active_pointer == -1 and walker.last_direction == Vector2.ZERO)
    print("ADVENTURE TOUCH FOCUS TEST PASSED")
    quit()
