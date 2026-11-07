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
    # Right-side walking actions must stay anchored inside compact landscape widths.
    var action_count := 0
    for layer in area.get_children():
        if not layer is CanvasLayer:
            continue
        for ui_root in layer.get_children():
            for control in ui_root.get_children():
                if control is Button and control.text in ["SPRUNG", "ANGRIFF", "ABWEHR", "INTERAKTION"]:
                    action_count += 1
                    if control.anchor_left != 1.0 or control.anchor_right != 1.0 or control.offset_right > -10.0:
                        _fail("walking action button must be right-edge anchored with safe inset: " + control.text)
                        return
    if action_count != 4:
        _fail("four independent walking action buttons required")
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
    # Falling in the translated arena must respawn locally, not at world origin.
    player.global_position = area.to_global(Vector3(0.0, -14.0, 0.0))
    await physics_frame
    if player.global_position.distance_to(area.to_global(Vector3(0.0, 1.5, 0.0))) > 1.0:
        _fail("fall respawn must preserve translated arena origin")
        return
    # A3: telegraphed strike hits in range, guard blocks, leaving range dodges.
    var robot := area.get("robot") as Node3D
    if robot == null:
        _fail("training robot missing")
        return
    # A4: switching Safari tabs must freeze a pending robot strike and release touch.
    area.set("robot_warning", 0.75)
    player.velocity = Vector3(3.0, -2.0, 0.0)
    var focus_position := player.global_position
    area.set("mobile_axis", Vector2(1.0, 0.0))
    area.call("_notification", Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
    if not bool(area.get("adventure_focus_paused")) or (area.get("mobile_axis") as Vector2) != Vector2.ZERO:
        _fail("focus loss must pause adventure and clear walking touch movement")
        return
    # Background input must not collect items, attack, guard or return to the runner.
    var paused_crystals := int(area.get("crystals_collected"))
    var paused_hits := int(area.get("robot_hits"))
    var paused_guard := float(area.get("robot_guard"))
    if bool(area.call("interact")) or bool(area.call("attack_robot")):
        _fail("backgrounded adventure must reject mission and combat actions")
        return
    area.call("guard_robot")
    area.call("_request_return")
    var paused_key := InputEventKey.new()
    paused_key.keycode = KEY_E
    paused_key.pressed = true
    area.call("_unhandled_key_input", paused_key)
    if int(area.get("crystals_collected")) != paused_crystals or int(area.get("robot_hits")) != paused_hits or absf(float(area.get("robot_guard")) - paused_guard) > 0.001 or str(game.get("phase")) != "adventure":
        _fail("background input mutated mission, combat or runner state")
        return
    area.call("_physics_process", 0.5)
    for focus_step in range(3):
        await physics_frame
    if player.is_physics_processing() or player.global_position.distance_to(focus_position) > 0.001:
        _fail("backgrounded walking hero must not continue gravity or movement")
        return
    if absf(float(area.get("robot_warning")) - 0.75) > 0.001:
        _fail("background tab must not consume robot warning or cause a hidden hit")
        return
    area.call("_notification", Node.NOTIFICATION_APPLICATION_FOCUS_IN)
    if bool(area.get("adventure_focus_paused")) or not player.is_physics_processing():
        _fail("focus regain must resume arena and walking physics")
        return
    area.set("robot_warning", 0.0)
    player.global_position = robot.global_position + Vector3(1.0, 0.0, 0.0)
    area.set("robot_warning", 0.01)
    area.call("_update_robot_visual")
    var warning_material := area.get("robot_material") as StandardMaterial3D
    if warning_material == null or warning_material.albedo_color != Color("#ff6655"):
        _fail("robot warning must be visible on the 3D mesh, not just HUD text")
        return
    await physics_frame
    if warning_material.albedo_color != Color("#54c7ed"):
        _fail("robot warning tint must reset after the attack resolves")
        return
    if int(area.get("robot_energy")) != 2 or not bool(area.get("robot_last_hit")):
        _fail("unguarded robot strike must cost one local energy")
        return
    if str(area.get("robot_feedback")) != "TREFFER ERHALTEN":
        _fail("robot hit feedback missing")
        return
    area.call("guard_robot")
    var hero_material := area.get("hero_material") as StandardMaterial3D
    if hero_material == null or hero_material.albedo_color != Color("#65f5c7"):
        _fail("active guard must have a visible in-world hero cue")
        return
    area.set("robot_warning", 0.01)
    await physics_frame
    if int(area.get("robot_energy")) != 2 or bool(area.get("robot_last_hit")):
        _fail("guard window must block robot strike")
        return
    if str(area.get("robot_feedback")) != "ABGEWEHRT":
        _fail("robot guard feedback missing")
        return
    # Repeated guard input cannot extend the active window or bypass cooldown.
    var guard_remaining := float(area.get("robot_guard"))
    area.call("guard_robot")
    if absf(float(area.get("robot_guard")) - guard_remaining) > 0.001:
        _fail("guard spam must not refresh the protection window")
        return
    area.set("robot_guard", 0.0)
    area.call("_update_hero_guard_visual")
    if hero_material.albedo_color != Color("#d7e9ff"):
        _fail("expired guard must restore the original hero appearance")
        return
    player.global_position = robot.global_position + Vector3(6.0, 0.0, 0.0)
    area.set("robot_warning", 0.01)
    await physics_frame
    if int(area.get("robot_energy")) != 2 or bool(area.get("robot_last_hit")):
        _fail("leaving robot range must dodge telegraphed strike")
        return
    if str(area.get("robot_feedback")) != "AUSGEWICHEN":
        _fail("robot dodge feedback missing")
        return
    # Exhausting local robot energy must use a real checkpoint respawn, not
    # teleport while retaining momentum or stale mobile movement.
    player.global_position = robot.global_position + Vector3(1.0, 0.0, 0.0)
    player.velocity = Vector3(7.0, -9.0, 4.0)
    area.set("mobile_axis", Vector2(1.0, 0.0))
    area.set("robot_energy", 1)
    area.set("robot_guard", 0.0)
    area.call("_resolve_robot_strike")
    if player.global_position.distance_to(area.to_global(Vector3(0.0, 1.5, 0.0))) > 0.01 or player.velocity != Vector3.ZERO or (area.get("mobile_axis") as Vector2) != Vector2.ZERO or int(area.get("robot_energy")) != 3:
        _fail("robot checkpoint must clear velocity, mobile input and restore energy")
        return
    # A retry must restore the arena checkpoint, not just counters and robot.
    player.global_position = area.to_global(Vector3(5.0, 2.0, -5.0))
    player.velocity = Vector3(4.0, -3.0, 2.0)
    area.set("mobile_axis", Vector2(1.0, 0.0))
    area.call("reset_mission")
    if player.global_position.distance_to(area.to_global(Vector3(0.0, 1.5, 0.0))) > 0.01 or player.velocity != Vector3.ZERO or (area.get("mobile_axis") as Vector2) != Vector2.ZERO:
        _fail("mission retry must restore local checkpoint and clear walking momentum/input")
        return
    if hero_material.albedo_color != Color("#d7e9ff"):
        _fail("mission retry must clear the guard visual")
        return
    if str(area.get("robot_feedback")) != "":
        _fail("robot feedback must clear on retry")
        return
    # A3: robot only accepts nearby attacks; two hits stun it; reset restores it.
    if bool(area.call("attack_robot")):
        _fail("remote robot attack must be rejected")
        return
    player.global_position = robot.global_position + Vector3(1.0, 0.0, 0.0)
    if not bool(area.call("attack_robot")):
        _fail("nearby robot must accept first attack")
        return
    if bool(area.call("attack_robot")) or int(area.get("robot_hits")) != 1:
        _fail("attack spam must not bypass the 0.65s cooldown")
        return
    area.set("player_attack_cooldown", 0.0)
    if not bool(area.call("attack_robot")):
        _fail("nearby robot must accept second attack after cooldown")
        return
    if not bool(area.get("robot_stunned")) or robot.visible:
        _fail("robot must be stunned and hidden after two hits")
        return
    if bool(area.call("attack_robot")):
        _fail("stunned robot cannot be attacked repeatedly")
        return
    area.call("reset_mission")
    if bool(area.get("robot_stunned")) or not robot.visible or int(area.get("robot_hits")) != 0 or float(area.get("player_attack_cooldown")) != 0.0:
        _fail("retry must reset robot encounter")
        return
    var preserved_distance := float(game.get("distance"))
    # Locked exit must be red until mission and robot are both complete.
    var portal_material := area.get("portal_material") as StandardMaterial3D
    if portal_material == null or portal_material.albedo_color != Color("#ff6655", 0.35):
        _fail("locked portal must show a red 3D material")
        return
    # Portal cannot return until all five interactions have happened.
    var locked_key := InputEventKey.new()
    locked_key.keycode = KEY_E
    locked_key.pressed = true
    area.call("_unhandled_key_input", locked_key)
    if int(game.get("xp")) != initial_xp:
        _fail("locked portal must not award mission XP")
        return
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
    if portal_material.albedo_color != Color("#ff6655", 0.35):
        _fail("robot must still gate green exit after collecting mission targets")
        return
    area.call("_request_return")
    if str(game.get("phase")) != "adventure":
        _fail("completed mission must not allow remote remount away from exit portal")
        return
    player.global_position = area.global_position + Vector3(0.0, 1.0, 6.0)
    area.call("_request_return")
    if str(game.get("phase")) != "adventure":
        _fail("completed collection mission must still require robot defeat")
        return
    player.global_position = robot.global_position + Vector3(1.0, 0.0, 0.0)
    if not bool(area.call("attack_robot")):
        _fail("first robot hit required for exit portal")
        return
    area.set("player_attack_cooldown", 0.0)
    if not bool(area.call("attack_robot")):
        _fail("robot defeat required for exit portal")
        return
    if portal_material.albedo_color != Color("#35f0ba", 0.35):
        _fail("completed mission and robot defeat must turn exit portal green")
        return
    player.global_position = area.global_position + Vector3(0.0, 1.0, 6.0)
    # Both desktop E and the mobile INTERAKTION button must be contextual.
    # Check the mobile path here; keyboard E remains checked while locked below.
    var mobile_interact: Button = null
    for layer in area.get_children():
        if layer is CanvasLayer:
            for ui_root in layer.get_children():
                for control in ui_root.get_children():
                    if control is Button and control.text == "INTERAKTION":
                        mobile_interact = control
    if mobile_interact == null:
        _fail("mobile interaction button missing")
        return
    mobile_interact.pressed.emit()
    if str(game.get("phase")) != "race" or game.get("adventure_area") != null:
        _fail("on-foot signal did not return to active race")
        return
    if not (game.get("rider") as Node3D).visible or not canvas.visible:
        _fail("runner rider and touch UI not restored")
        return
    if not (game.get("chase_camera") as Camera3D).current:
        _fail("return did not restore race chase camera")
        return
    if int(game.get("xp")) != initial_xp + 75 or int(game.get("power")) != initial_power or \
            int(game.get("lives")) != initial_lives or absf(float(game.get("distance")) - preserved_distance) > 0.001:
        _fail("transition changed stored race rewards or progress")
        return
    if not bool(game.get("adventure_reward_claimed")):
        _fail("completed mission must mark reward as claimed")
        return
    if bool(game.call("_exit_adventure")) or int(game.get("xp")) != initial_xp + 75:
        _fail("duplicate exit must not grant extra XP")
        return
    if bool(game.call("_enter_adventure")):
        _fail("same race can farm adventure repeatedly")
        return
    game.call("_reset_run")
    if bool(game.get("adventure_used")) or bool(game.get("adventure_reward_claimed")):
        _fail("new race failed to reset adventure visit and reward gates")
        return
    print("ADVENTURE BRIDGE TEST PASSED: default-off, three questions, 100m entry, 3D collision/walking, five proximity interactions, gated portal return, one-time mission XP and preserved power/lives/distance")
    quit(0)
