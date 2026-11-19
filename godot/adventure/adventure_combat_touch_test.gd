extends SceneTree
const Touch = preload("res://adventure/adventure_combat_touch.gd")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var layer := Control.new()
    layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.add_child(layer)
    var touch := Touch.new()
    touch.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    layer.add_child(touch)
    await process_frame
    var attacks := [0]
    var guards: Array[bool] = []
    touch.attack_requested.connect(func(): attacks[0] += 1)
    touch.guard_changed.connect(func(active: bool): guards.append(active))
    assert(touch.attack_button.disabled and touch.guard_button.disabled)
    touch._on_attack()
    touch._on_guard_down()
    assert(attacks[0] == 0 and guards.is_empty(), "Disabled controls must be inert")
    touch.set_combat_enabled(true)
    assert(not touch.attack_button.disabled and not touch.guard_button.disabled)
    touch._on_attack()
    touch._on_guard_down()
    touch._on_guard_down()
    assert(attacks[0] == 1 and guards == [true], "Attack and guard-down once")
    touch.hide()
    assert(guards == [true, false] and not touch.guard_held, "Hiding releases guard")
    touch.show()
    touch._on_guard_down()
    touch.set_combat_enabled(false)
    assert(guards == [true, false, true, false], "Disabling releases guard")
    touch.queue_free()
    await process_frame
    print("ADVENTURE COMBAT TOUCH TEST PASSED")
    quit(0)
