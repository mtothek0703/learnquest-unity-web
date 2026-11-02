extends SceneTree
## DRAFT CC0: show the real 65-bone rider in neutral, left and right touch
## carves from identical front/chase AND both side-profile cameras in both
## smartphone landscape ratios. Side profiles expose sleeve/hand/torso
## intersections that frontal images conceal; all original frames remain.
## These images are diagnostic, not iPhone FPS or aesthetic acceptance.
const SIZES := [Vector2i(1280, 720), Vector2i(1170, 540)]
const VIEWS := ["front", "chase", "left_profile", "right_profile"]
const POSES := ["neutral", "left_carve", "right_carve"]

func _initialize() -> void:
    call_deferred("_capture")

func _fail(message: String) -> void:
    Engine.time_scale = 1.0
    push_error("BILATERAL POSE VISUAL QA FAILED: " + message)
    quit(1)

func _capture() -> void:
    var folder := OS.get_environment("LEARNQUEST_BILATERAL_POSE_OUTPUT")
    if folder.is_empty():
        folder = "/tmp/learnquest-bilateral-pose-qa"
    if DirAccess.make_dir_recursive_absolute(folder) != OK:
        _fail("cannot create landscape pose QA folder")
        return
    var viewport := SubViewport.new()
    viewport.size = SIZES[0]
    viewport.own_world_3d = true
    viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    root.add_child(viewport)
    var stage := Node3D.new()
    viewport.add_child(stage)
    var environment_node := WorldEnvironment.new()
    var environment := Environment.new()
    environment.background_mode = Environment.BG_COLOR
    environment.background_color = Color(0.035, 0.055, 0.12)
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color(0.56, 0.66, 0.92)
    environment.ambient_light_energy = 0.85
    environment_node.environment = environment
    stage.add_child(environment_node)
    var key := DirectionalLight3D.new()
    key.rotation_degrees = Vector3(-35.0, -35.0, 0.0)
    key.light_energy = 1.6
    stage.add_child(key)
    var rim := DirectionalLight3D.new()
    rim.rotation_degrees = Vector3(-18.0, 145.0, 0.0)
    rim.light_color = Color(0.33, 0.84, 1.0)
    rim.light_energy = 0.85
    stage.add_child(rim)
    var camera := Camera3D.new()
    camera.fov = 43.0
    stage.add_child(camera)
    camera.current = true
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    rider.set("prefer_cc0_rigged_hero", true)
    stage.add_child(rider)
    await process_frame
    var hero := rider.get_node_or_null("ExternalRiggedHero") as Node3D
    var adapter := rider.get_node_or_null("ExternalHeroPose") as Node
    if hero == null or adapter == null:
        _fail("original CC0 rigged rider missing")
        return
    var rig := adapter.get("skeleton") as Skeleton3D
    if rig == null or rig.get_bone_count() != 65:
        _fail("original 65-bone GPU skin missing")
        return
    # Stop game/physics/asset animation so only explicitly requested poses
    # differ. Freeze shader TIME to avoid misattributing mantle motion.
    rider.set_process(false)
    rider.set_physics_process(false)
    for node in rider.find_children("*", "Node", true, false):
        node.set_process(false)
        node.set_physics_process(false)
        if node is AnimationPlayer:
            (node as AnimationPlayer).pause()
        elif node is AnimationTree:
            (node as AnimationTree).active = false
    rider.process_mode = Node.PROCESS_MODE_DISABLED
    Engine.time_scale = 0.0
    var count := 0
    for size in SIZES:
        viewport.size = size
        for view in VIEWS:
            match view:
                "front":
                    camera.position = Vector3(0.0, 2.0, -5.2)
                "chase":
                    camera.position = Vector3(0.0, 2.25, 5.4)
                "left_profile":
                    camera.position = Vector3(-5.6, 2.15, 0.0)
                "right_profile":
                    camera.position = Vector3(5.6, 2.15, 0.0)
            camera.look_at(Vector3(0.0, 1.8, 0.0), Vector3.UP)
            var left_carve_frame: Image
            for pose_name in POSES:
                # Reestablish neutral before each turn, rather than carrying
                # the previous turn's inertial shoulder offset into the next.
                rider.set("lean", 0.0)
                rider.set("boosting", false)
                adapter.call("_process", 0.8)
                var steer := 0.0
                if pose_name == "left_carve":
                    steer = -0.9
                elif pose_name == "right_carve":
                    steer = 0.9
                rider.set("lean", steer)
                adapter.call("_process", 0.8)
                for frame in range(6):
                    await process_frame
                await RenderingServer.frame_post_draw
                var frame_image := viewport.get_texture().get_image()
                if frame_image.is_empty() or frame_image.get_width() != size.x or frame_image.get_height() != size.y:
                    _fail("invalid 16:9/19.5:9 render framebuffer")
                    return
                var filename := "%s/%dx%d_%s_%s.png" % [folder, size.x, size.y, view, pose_name]
                if frame_image.save_png(filename) != OK:
                    _fail("could not save original-skin pose image")
                    return
                # A real pixel-level gate on the two side cameras: a mirrored
                # touch carve must visibly move the actual GPU-skinned rider,
                # not just update bone angles offscreen. Shader TIME, game
                # animation and camera are locked across these two frames.
                if pose_name == "left_carve":
                    left_carve_frame = frame_image
                elif pose_name == "right_carve" and view.ends_with("_profile"):
                    if left_carve_frame == null:
                        _fail("side-profile comparison lost left-carve baseline")
                        return
                    var changed_samples := 0
                    for sample_y in range(90):
                        for sample_x in range(160):
                            var px := int(float(size.x - 1) * float(sample_x) / 159.0)
                            var py := int(float(size.y - 1) * float(sample_y) / 89.0)
                            var left_pixel := left_carve_frame.get_pixel(px, py)
                            var right_pixel := frame_image.get_pixel(px, py)
                            var channel_delta := maxf(absf(left_pixel.r - right_pixel.r),
                                maxf(absf(left_pixel.g - right_pixel.g),
                                    absf(left_pixel.b - right_pixel.b)))
                            if channel_delta > 0.12:
                                changed_samples += 1
                    print("BILATERAL PROFILE PIXEL QA %s %s: %d/14400 changed samples" %
                        [str(size), view, changed_samples])
                    if changed_samples < 8:
                        _fail("left/right 65-bone surf poses are not visibly different in %s %s" %
                            [str(size), view])
                        return
                count += 1
    Engine.time_scale = 1.0
    if count != 24:
        _fail("expected 24 real bilateral front/chase/side-profile landscape pose frames")
        return
    print("BILATERAL POSE VISUAL QA PASSED: 24 original-65-bone neutral/left/right front/chase/left/right-profile frames at both phone landscape ratios; side-profile pixel gates passed; clipping sign-off still pending")
    quit(0)
