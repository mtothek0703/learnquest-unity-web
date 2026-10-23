extends SceneTree
## Automated game-level smoke test used by GitHub Actions.
## Runs without a GPU: verifies that the actual level, character, pickups, quiz
## and input actions initialize and can be exercised without script errors.

func _initialize() -> void:
    call_deferred("_run_checks")

func _fail(message: String) -> void:
    push_error("LEARNQUEST TEST FAILED: " + message)
    quit(1)

func _run_checks() -> void:
    var scene := load("res://main.tscn") as PackedScene
    if scene == null:
        _fail("Unable to load main.tscn")
        return
    var game := scene.instantiate() as Node3D
    if game == null:
        _fail("Main scene is not a Node3D")
        return
    root.add_child(game)
    await process_frame
    if game.get_node_or_null("LearnQuest Skyway world") == null:
        _fail("Skyway 3D environment is missing")
        return
    if game.get("rider") == null:
        _fail("Animated hoverboard character is missing")
        return
    var rider := game.get("rider") as Node3D
    if rider == null or rider.get_node_or_null("LegacyRider/Floating hoverboard") == null:
        _fail("Rider scene must preserve the animated hoverboard")
        return
    var fallback := rider.get_node_or_null("LegacyRider/Animated racer rig") as Node3D
    if fallback == null:
        _fail("Legacy rider fallback must exist")
        return
    var installed_model := rider.get_node_or_null("ImportedRider")
    if installed_model == null:
        _fail("Bundled 3D rider model was not imported")
        return
    if fallback.visible:
        _fail("Fallback body must be hidden while imported 3D rider is active")
        return
    # Exercise the new replacement contract without requiring any paid model.
    var placeholder := Node3D.new()
    rider.call("set_character_model", placeholder)
    if rider.get_node_or_null("ImportedRider") == null or fallback.visible:
        _fail("Imported visual does not replace the legacy character correctly")
        return
    rider.call("restore_fallback")
    if not fallback.visible:
        _fail("Restoring the legacy character failed")
        return
    # Regression: jumping moves the RiderCharacter root, not its LegacyRider child.
    rider.position.y = 1.4
    await process_frame
    await process_frame
    var legacy := rider.get_node("LegacyRider")
    if float(legacy.get("jump_pose")) <= 0.0:
        _fail("Hoverboard rider does not animate during a real jump")
        return
    rider.position.y = 0.0
    await process_frame
    if float(legacy.get("landing_pulse")) <= 0.0:
        _fail("Hoverboard landing shockwave did not trigger")
        return
    var items := game.get("run_items") as Node3D
    if items == null or items.get_child_count() < 10:
        _fail("Obstacles and pickups were not created")
        return
    # Simulate portrait and desktop viewport widths without a real phone.
    var controls := game.get("controls_grid") as GridContainer
    if controls == null or controls.get_child_count() != 4:
        _fail("Hoverboard touch controls are missing")
        return
    game.call("_apply_mobile_layout", 390.0)
    if controls.columns != 2 or controls.offset_top > -130.0:
        _fail("Phone portrait controls must use two rows")
        return
    for panel in [game.get("splash"), game.get("quiz_box"), game.get("end_panel")]:
        if (panel as PanelContainer).custom_minimum_size.x > 366.0:
            _fail("Phone portrait overlay exceeds the available width")
            return
    game.call("_apply_mobile_layout", 960.0)
    if controls.columns != 4:
        _fail("Desktop controls must return to one row")
        return
    game.call("_start_game")
    var hud := game.get("hud") as Label
    if hud == null or not hud.text.contains("SKYWAY V21") or not hud.text.contains("KOMBO x0"):
        _fail("Race HUD must show the current version and starting combo")
        return
    if not bool(game.get("started")):
        _fail("The race did not start")
        return
    game.call("_shift", 1)
    if int(game.get("lane")) != 1:
        _fail("Player cannot steer to the right")
        return
    game.call("_shift", -1)
    if int(game.get("lane")) != 0:
        _fail("Player cannot steer to the center")
        return
    game.call("_jump")
    if float(game.get("jump_left")) <= 0.0:
        _fail("Jump did not trigger")
        return
    # Energy rings must rotate and pulse without replacing the existing meshes.
    var energy_gate: MeshInstance3D = null
    for item in items.get_children():
        if bool(item.get_meta("energy")):
            energy_gate = item.get_node_or_null("Energy gate") as MeshInstance3D
            break
    if energy_gate == null:
        _fail("Collectible energy gate is missing")
        return
    var previous_angle := energy_gate.rotation.z
    game.set("distance", 14.0)
    game.call("_update_run_items", 0.016)
    if energy_gate.rotation.z <= previous_angle or absf(energy_gate.scale.x - 1.0) < 0.001:
        _fail("Collectible energy gate rotation or pulse is not animated")
        return
    var camera := game.get("chase_camera") as Camera3D
    if camera == null:
        _fail("Chase camera missing")
        return
    game.call("_update_camera", 0.2)
    if camera.fov < 63.0:
        _fail("Camera field of view is invalid")
        return
    game.call("_ask")
    if not bool(game.get("quiz_active")):
        _fail("Vocabulary challenge did not open")
        return
    if game.get("quiz_box") == null:
        _fail("Vocabulary overlay is missing")
        return
    # A child should not receive the same word twice in a row.
    var previous_word: int = int(game.get("correct_index"))
    for attempt in range(20):
        game.call("_ask")
        var current_word: int = int(game.get("correct_index"))
        if current_word == previous_word:
            _fail("Vocabulary challenge repeated the previous word")
            return
        var choices: Array = game.get("options")
        if choices.size() != 3 or not choices.has(current_word):
            _fail("Vocabulary answers are missing the correct translation")
            return
        if choices[0] == choices[1] or choices[0] == choices[2] or choices[1] == choices[2]:
            _fail("Vocabulary challenge contains duplicate answer options")
            return
        previous_word = current_word
    # Cover both the youngest and oldest available grade bands.
    for school_grade in [1, 10]:
        game.set("grade", school_grade)
        game.call("_ask")
        if (game.get("question_label") as Label).text.is_empty():
            _fail("Vocabulary question missing for grade %d" % school_grade)
            return
    # Correct vocabulary answers must update the visible streak counter.
    game.set("grade", 5)
    game.call("_ask")
    var correct_option: int = (game.get("options") as Array).find(int(game.get("correct_index")))
    if correct_option < 0:
        _fail("Correct vocabulary option cannot be selected")
        return
    game.call("_answer", correct_option)
    if int(game.get("combo")) != 1 or not hud.text.contains("KOMBO x1"):
        _fail("Correct vocabulary answer does not update the HUD combo")
        return
    print("LEARNQUEST SMOKE TEST PASSED: scene, 3D world, rider, steering, jump, pickups, vocabulary, combo HUD")
    quit(0)
