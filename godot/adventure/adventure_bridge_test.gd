extends SceneTree
## A1/A2 bridge integration – actual gameplay scene, mandatory questions and
## opt-in same-session runner -> walking -> runner return; headless Godot QA.
func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("ADVENTURE BRIDGE TEST FAILED: " + message)
    quit(1)

func _check() -> void:
    var game := preload("res://main.tscn").instantiate() as Node3D
    root.add_child(game)
    await process_frame
    if bool(game.get("adventure_opt_in")) or bool(game.get("adventure_used")):
        _fail("existing runner must boot with adventure disabled")
        return
    if bool(game.call("_enter_adventure")):
        _fail("menu must not bypass the three-question gate")
        return
    game.call("_toggle_adventure_opt_in")
    if not bool(game.get("adventure_opt_in")):
        _fail("menu toggle did not opt in")
        return
    game.call("_begin_training")
    if bool(game.call("_enter_adventure")):
        _fail("training must never enter an arena")
        return
    for i in range(3):
        if str(game.get("phase")) != "training" or not bool(game.get("quiz_active")):
            _fail("all three vocabulary questions must precede the race")
            return
        var answers: Array = game.get("options")
        game.call("_answer", answers.find(int(game.get("correct_index"))))
    if str(game.get("phase")) != "race" or not bool(game.get("started")):
        _fail("three answers did not unlock race")
        return
    if bool(game.call("_enter_adventure")):
        _fail("arena entry must require 100m of real race progress")
        return
    var initial_xp := int(game.get("xp"))
    var initial_power := int(game.get("power"))
    var initial_lives := int(game.get("lives"))
    game.set("distance", 150.0)
    if not bool(game.call("_enter_adventure")):
        _fail("enabled Neon race did not enter on-foot mode")
        return
    var area := game.get("adventure_area") as Node3D
    if area == null or str(game.get("phase")) != "adventure" or not bool(game.get("adventure_used")):
        _fail("on-foot mode is not active after entry")
        return
    if area.global_position.z < 650.0 or not area.has_signal("return_requested"):
        _fail("walkable scene not isolated or return signal missing")
        return
    if (game.get("rider") as Node3D).visible:
        _fail("hoverboard rider remains visible in foot mode")
        return
    var canvas := game.get("runner_ui_layer") as CanvasLayer
    if canvas == null or canvas.visible:
        _fail("race HUD and touch buttons overlap walking UI")
        return
    await process_frame
    var player := area.get("player") as CharacterBody3D
    var walk_camera := area.get("follow_camera") as Camera3D
    if player == null or walk_camera == null or not walk_camera.current:
        _fail("separate foot player or third-person camera not active")
        return
    for step in range(35):
        await physics_frame
    if not player.is_on_floor():
        _fail("walking hero never landed on real 3D collision floor")
        return
    var start_x := player.global_position.x
    area.set("mobile_axis", Vector2(1.0, 0.0))
    for step in range(12):
        await physics_frame
    area.set("mobile_axis", Vector2.ZERO)
    if player.global_position.x <= start_x + 0.3:
        _fail("mobile walking control did not move CharacterBody3D")
        return
    var preserved_distance := float(game.get("distance"))
    # Portal cannot return until all five interactions have happened.
    area.call("_request_return")
    if str(game.get("phase")) != "adventure":
        _fail("portal returned before mission completion")
        return
    var targets: Array = area.get("mission_targets")
    for target in targets:
        player.global_position = target.global_position + Vector3.UP * 0.4
        if not bool(area.call("interact")):
            _fail("nearby mission target was not interactable")
            return
    if not bool(area.get("mission_complete")) or int(area.get("crystals_collected")) != 3 or int(area.get("switches_activated")) != 2:
        _fail("all three crystals and two switches must unlock portal")
        return
    area.call("_request_return")
    if str(game.get("phase")) != "race" or game.get("adventure_area") != null:
        _fail("on-foot signal did not return to active race")
        return
    if not (game.get("rider") as Node3D).visible or not canvas.visible:
        _fail("runner rider and touch UI not restored")
        return
    if not (game.get("chase_camera") as Camera3D).current:
        _fail("return did not restore race chase camera")
        return
    if int(game.get("xp")) != initial_xp or int(game.get("power")) != initial_power or \
            int(game.get("lives")) != initial_lives or absf(float(game.get("distance")) - preserved_distance) > 0.001:
        _fail("transition changed stored race rewards or progress")
        return
    if bool(game.call("_enter_adventure")):
        _fail("same race can farm adventure repeatedly")
        return
    game.call("_reset_run")
    if bool(game.get("adventure_used")):
        _fail("new race failed to reset one-time adventure gate")
        return
    print("ADVENTURE BRIDGE TEST PASSED: default-off, three questions, 100m entry, 3D collision/walking, five proximity interactions, gated portal return, score preserved and one-visit gate")
    quit(0)
