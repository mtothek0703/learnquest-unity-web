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
    # The on-foot HUD must provide actual mission guidance on touch screens,
    # not a desktop-only hover tooltip.
    area.call("_update_objective_guidance")
    var guidance_label := area.get("mission_label") as Label
    if guidance_label == null or not guidance_label.text.contains("INTERAKTION: Kristall"):
        _fail("walking mission needs a visible mobile objective hint")
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
    # A4: check real HUD anchor/offset rectangles at compact 390px landscape
    # height; right-side buttons must not intercept each other's touch zones.
    var action_rects: Array[Rect2] = []
    for layer in area.get_children():
        if not layer is CanvasLayer:
            continue
        for ui_root in layer.get_children():
            for control in ui_root.get_children():
                if control is Button and control.text in ["SPRUNG", "ANGRIFF", "ABWEHR", "INTERAKTION"]:
                    var top: float = control.anchor_top * 390.0 + control.offset_top
                    var bottom: float = control.anchor_bottom * 390.0 + control.offset_bottom
                    var left: float = control.offset_left
                    var right: float = control.offset_right
                    var rect := Rect2(Vector2(left, top), Vector2(right - left, maxf(bottom - top, control.custom_minimum_size.y)))
                    if rect.position.y < 0.0 or rect.end.y > 390.0:
                        _fail("walking action button outside compact landscape height: " + control.text)
                        return
                    for previous in action_rects:
                        if rect.intersects(previous):
                            _fail("walking action touch zones overlap at 390px height: " + control.text)
                            return
                    action_rects.append(rect)
    if action_rects.size() != 4:
        _fail("compact landscape touch zone check missed an action")
        return
    for step in range(35):
        await physics_frame
    if not player.is_on_floor():
        _fail("walking hero never landed on real 3D collision floor")
        return
    # Guidance must direct players toward a distant objective without a popup.
    area.call("_update_objective_guidance")
    var objective_label := area.get("mission_label") as Label
    if objective_label == null or not objective_label.text.contains(" m"):
        _fail("distant adventure objectives must display an approximate distance")
        return
    # A4: an obstacle behind the walking hero must pull the third-person
    # camera forward, without modifying the runner chase camera.
    var camera_wall := StaticBody3D.new()
    var camera_collision := CollisionShape3D.new()
    var camera_box := BoxShape3D.new()
    camera_box.size = Vector3(6.0, 8.0, 0.5)
    camera_collision.shape = camera_box
    camera_wall.add_child(camera_collision)
    area.add_child(camera_wall)
    camera_wall.global_position = player.global_position + Vector3(0.0, 2.0, 4.0)
    await physics_frame
    area.call("_update_follow_camera")
    if walk_camera.global_position.z >= player.global_position.z + 6.0:
        _fail("walking camera clipped through an obstacle behind the hero")
        return
    camera_wall.queue_free()
    await physics_frame
    area.call("_update_follow_camera")
    if walk_camera.global_position.z <= player.global_position.z + 7.5:
        _fail("walking camera failed to recover its normal distance")
        return
    # A4: a slightly early mobile jump should survive an airborne frame,
    # but not remain queued indefinitely or across a checkpoint reset.
    player.global_position += Vector3.UP * 3.0
    # Force a collision refresh after teleport: is_on_floor() otherwise
    # still reports the prior grounded tick and consumes the jump buffer.
    player.velocity = Vector3.ZERO
    player.move_and_slide()
    player.set("coyote_remaining", 0.0)
    if player.is_on_floor():
        _fail("jump-buffer fixture must begin airborne")
        return
    player.mobile_jump()
    player.call("_physics_process", 0.016)
    if float(player.get("jump_buffer_remaining")) <= 0.0:
        _fail("on-foot early jump must be buffered briefly")
        return
    player.respawn()
    if float(player.get("jump_buffer_remaining")) != 0.0:
        _fail("checkpoint must clear buffered mobile jump")
        return
    # A4: walking off a ledge grants a brief jump grace period, not a double jump.
    player.global_position += Vector3.UP * 3.0
    player.set("coyote_remaining", 0.08)
    player.mobile_jump()
    player.call("_physics_process", 0.016)
    if player.velocity.y <= 0.0 or float(player.get("coyote_remaining")) != 0.0:
        _fail("ledge grace jump must fire once and consume its allowance")
        return
    player.mobile_jump()
    player.call("_physics_process", 0.016)
    if player.velocity.y >= 6.5:
        _fail("ledge grace must not permit an airborne double jump")
        return
    player.respawn()
    if float(player.get("coyote_remaining")) != 0.0:
        _fail("checkpoint must clear ledge grace")
        return
    var start_x := player.global_position.x
    area.set("mobile_axis", Vector2(1.0, 0.0))
    for step in range(12):
        await physics_frame
    area.set("mobile_axis", Vector2.ZERO)
    if player.global_position.x <= start_x + 0.3:
        _fail("mobile walking control did not move CharacterBody3D")
        return
    # Direction changes must turn only the walking appearance, not collision.
    var walking_visual := player.get_node_or_null("WalkingVisual") as Node3D
    if walking_visual == null or walking_visual.rotation.y > -0.6:
        _fail("on-foot hero visual must face its mobile movement direction")
        return
    if absf(player.rotation.y) > 0.001:
        _fail("on-foot visual turning must not rotate the collision body")
        return
    # A4: on-foot sprint has a separate mobile hold control and must not
    # change the runner's gesture routing or survive a checkpoint reset.
    var sprint_button: Button = null
    for sprint_layer in area.get_children():
        if sprint_layer is CanvasLayer:
            for sprint_root in sprint_layer.get_children():
                for sprint_control in sprint_root.get_children():
                    if sprint_control is Button and sprint_control.text == "SPRINT":
                        sprint_button = sprint_control
    if sprint_button == null:
        _fail("on-foot mobile sprint button missing")
        return
    sprint_button.button_down.emit()
    if not bool(player.get("mobile_sprint_held")):
        _fail("walking sprint must activate while mobile button is held")
        return
    area.set("mobile_axis", Vector2(1.0, 0.0))
    await physics_frame
    if player.velocity.x < 7.0:
        _fail("walking sprint must increase actual CharacterBody speed")
        return
    sprint_button.button_up.emit()
    area.set("mobile_axis", Vector2.ZERO)
    if bool(player.get("mobile_sprint_held")):
        _fail("walking sprint must stop on touch release")
        return
    player.respawn()
    if absf(walking_visual.rotation.y) > 0.001 or absf(player.rotation.y) > 0.001:
        _fail("checkpoint respawn must reset facing without rotating the collision body")
        return
    if bool(player.get("mobile_sprint_held")):
        _fail("checkpoint respawn must clear held sprint")
        return
    # Falling in the translated arena must respawn locally, not at world origin.
    player.global_position = area.to_global(Vector3(0.0, -14.0, 0.0))
    await physics_frame
    if player.global_position.distance_to(area.to_global(Vector3(0.0, 1.5, 0.0))) > 1.0:
        _fail("fall respawn must preserve translated arena origin")
        return
    # Falling must not replay gravity or movement in the respawn physics tick.
    player.global_position = area.to_global(Vector3(0.0, -14.0, 0.0))
    player.velocity = Vector3(4.0, -8.0, 2.0)
    player.call("_physics_process", 0.016)
    if player.velocity != Vector3.ZERO or player.global_position.distance_to(area.to_global(Vector3(0.0, 1.5, 0.0))) > 0.001:
        _fail("fall respawn must not apply gravity or stale movement in the same tick")
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
    player.set_mobile_sprint(true)
    area.call("_notification", Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
    if bool(player.get("mobile_sprint_held")):
        _fail("focus loss must release a held mobile sprint without waiting for button_up")
        return
    if not bool(area.get("adventure_focus_paused")) or (area.get("mobile_axis") as Vector2) != Vector2.ZERO:
        _fail("focus loss must pause adventure and clear walking touch movement")
        return
    # Touch events may arrive after Safari has already lost focus. Neither
    # movement nor a queued jump may be replayed when the player returns.
    var walking_jump: Button = null
    var walking_right: Button = null
    for touch_layer in area.get_children():
        if touch_layer is CanvasLayer:
            for touch_root in touch_layer.get_children():
                for touch_control in touch_root.get_children():
                    if touch_control is Button and touch_control.text == "SPRUNG":
                        walking_jump = touch_control
                    elif touch_control is Button and touch_control.text == "RECHTS":
                        walking_right = touch_control
    if walking_jump == null or walking_right == null:
        _fail("walking jump or direction button missing")
        return
    walking_right.button_down.emit()
    walking_jump.pressed.emit()
    if (area.get("mobile_axis") as Vector2) != Vector2.ZERO or bool(player.get("jump_requested")):
        _fail("backgrounded touch must not queue movement or jump for focus regain")
        return
    # The CharacterBody also receives keyboard events independently of the HUD.
    # Delayed SPACE and direct mobile calls must not queue a jump on focus regain.
    var late_space := InputEventKey.new()
    late_space.keycode = KEY_SPACE
    late_space.pressed = true
    player.call("_notification", Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
    var paused_velocity := player.velocity
    var paused_position := player.global_position
    player.call("_physics_process", 0.25)
    if player.velocity != paused_velocity or player.global_position.distance_to(paused_position) > 0.001:
        _fail("backgrounded walking CharacterBody must ignore even direct physics ticks")
        return
    player.call("_unhandled_key_input", late_space)
    player.call("mobile_jump")
    player.call("set_mobile_move", Vector2(1.0, 0.0))
    if bool(player.get("jump_requested")) or (player.get("move_axis") as Vector2) != Vector2.ZERO:
        _fail("backgrounded CharacterBody must reject late keyboard/mobile inputs")
        return
    player.call("_notification", Node.NOTIFICATION_APPLICATION_FOCUS_IN)
    if bool(player.get("jump_requested")) or (player.get("move_axis") as Vector2) != Vector2.ZERO:
        _fail("focus regain must not replay walking input")
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
    var warning_mesh := area.get("robot_visual") as MeshInstance3D
    if warning_mesh == null or not is_equal_approx(warning_mesh.scale.x, 1.14):
        _fail("robot attack warning must pulse the actual 3D mesh")
        return
    await physics_frame
    if warning_mesh == null or not is_equal_approx(warning_mesh.scale.x, 1.0):
        _fail("robot mesh must return to normal size after its warning")
        return
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
    # A4: retry must be reachable by the actual mobile HUD button, not only
    # through a test-only reset_mission() call.
    var retry_button: Button = null
    for retry_layer in area.get_children():
        if retry_layer is CanvasLayer:
            for retry_root in retry_layer.get_children():
                for retry_control in retry_root.get_children():
                    if retry_control is Button and retry_control.text == "NEUSTART":
                        retry_button = retry_control
    if retry_button == null:
        _fail("walking HUD must expose a mission retry button")
        return
    player.global_position = area.to_global(Vector3(3.0, 2.0, -2.0))
    player.velocity = Vector3(3.0, 0.0, 2.0)
    area.set("robot_energy", 1)
    area.set("mobile_axis", Vector2(1.0, 0.0))
    retry_button.pressed.emit()
    if player.global_position.distance_to(area.to_global(Vector3(0.0, 1.5, 0.0))) > 0.01 or player.velocity != Vector3.ZERO or int(area.get("robot_energy")) != 3 or (area.get("mobile_axis") as Vector2) != Vector2.ZERO:
        _fail("HUD retry must restore checkpoint, energy and movement state")
        return
    if str(game.get("phase")) != "adventure" or int(game.get("xp")) != initial_xp:
        _fail("HUD retry must not restart race or grant XP")
        return
    # Desktop R must perform the same local retry as the mobile button.
    player.global_position = area.to_global(Vector3(4.0, 2.0, -3.0))
    player.velocity = Vector3(2.0, -1.0, 2.0)
    area.set("robot_energy", 1)
    var retry_key := InputEventKey.new()
    retry_key.keycode = KEY_R
    retry_key.pressed = true
    area.call("_unhandled_key_input", retry_key)
    if player.global_position.distance_to(area.to_global(Vector3(0.0, 1.5, 0.0))) > 0.01 or player.velocity != Vector3.ZERO or int(area.get("robot_energy")) != 3:
        _fail("desktop R retry must restore checkpoint, momentum and energy")
        return
    if str(game.get("phase")) != "adventure" or int(game.get("xp")) != initial_xp:
        _fail("desktop R retry must not restart runner or award XP")
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
    # Nearby objectives must be chosen by distance, not creation order.
    var first_target := targets[0] as Node3D
    var second_target := targets[1] as Node3D
    var first_position := first_target.position
    var second_position := second_target.position
    first_target.position = Vector3(0.0, 0.9, 0.0)
    second_target.position = Vector3(0.8, 0.9, 0.0)
    player.global_position = area.to_global(Vector3(0.8, 0.9, 0.0))
    if not bool(area.call("interact")) or second_target.visible or not first_target.visible:
        _fail("nearby interaction must choose the closest visible objective")
        return
    area.call("reset_mission")
    first_target.position = first_position
    second_target.position = second_position
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
    area.call("_update_objective_guidance")
    if not (area.get("mission_label") as Label).text.contains("Roboter in ") or not (area.get("mission_label") as Label).text.contains("ANGRIFF / ABWEHR"):
        _fail("completed collection mission must show robot distance and combat controls")
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
    area.call("_update_objective_guidance")
    if not (area.get("mission_label") as Label).text.contains("Ausgangsportal in ") or not (area.get("mission_label") as Label).text.contains("AUFSTEIGEN"):
        _fail("completed Neon mission must guide mobile players to the exit with distance")
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
