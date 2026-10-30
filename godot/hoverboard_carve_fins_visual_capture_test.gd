extends SceneTree
## Reproducible before/after OpenGL captures of the articulated board vanes.
## Camera, character pose and hoverboard are frozen between A/B frames.
## 2 landscape ratios x 2 views x 3 action states x 2 variants = 24 PNGs.
const SIZES := [Vector2i(1280, 720), Vector2i(1170, 540)]
const VIEWS := ["chase", "three_quarter"]
const STATES := ["neutral", "right_carve", "left_carve"]

func _initialize() -> void:
    call_deferred("_capture")

func _fail(reason: String) -> void:
    push_error("CARVE FIN VISUAL QA FAILED: " + reason)
    quit(1)

func _capture() -> void:
    var folder := OS.get_environment("LEARNQUEST_CARVE_FIN_OUTPUT")
    if folder.is_empty():
        folder = "/tmp/learnquest-carve-fin-qa"
    if DirAccess.make_dir_recursive_absolute(folder) != OK:
        _fail("output directory unavailable")
        return
    var viewport := SubViewport.new()
    viewport.size = SIZES[0]
    viewport.own_world_3d = true
    viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    root.add_child(viewport)
    var stage := Node3D.new()
    viewport.add_child(stage)
    var world_env := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color(0.035, 0.055, 0.12)
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.56, 0.66, 0.92)
    env.ambient_light_energy = 0.85
    world_env.environment = env
    stage.add_child(world_env)
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
    camera.fov = 42.0
    stage.add_child(camera)
    camera.current = true
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    stage.add_child(rider)
    await process_frame
    var vanes := rider.get_node_or_null(
        "LegacyRider/Floating hoverboard/SculptedHoverboardChassis/ArticulatedCarveFins") as Node3D
    if vanes == null or not bool(vanes.get("ready_to_animate")):
        _fail("procedural carve fins are missing")
        return
    # Disable all rider subtree process callbacks so pose/hover cannot drift
    # between the before and after images of each action state.
    rider.process_mode = Node.PROCESS_MODE_DISABLED
    var hinges: Array = vanes.get("fins")
    var count := 0
    for size in SIZES:
        viewport.size = size
        for view in VIEWS:
            camera.position = Vector3(0.0, 1.95, 5.6) if view == "chase" else Vector3(3.8, 1.95, 4.0)
            camera.look_at(Vector3(0.0, 0.8, 0.0), Vector3.UP)
            for state in STATES:
                for hinge in hinges:
                    (hinge as Node3D).rotation.z = 0.0
                var lean := 0.9 if state == "right_carve" else (-0.9 if state == "left_carve" else 0.0)
                vanes.call("update_state", lean, state != "neutral", 1.0)
                var baseline: Image
                for variant in ["before", "after"]:
                    vanes.visible = variant == "after"
                    for frame in range(3):
                        await process_frame
                    await RenderingServer.frame_post_draw
                    var image := viewport.get_texture().get_image()
                    if image.is_empty() or image.get_width() != size.x or image.get_height() != size.y:
                        _fail("landscape framebuffer is empty or has wrong dimensions")
                        return
                    var path := "%s/%dx%d_%s_%s_%s.png" % [
                        folder, size.x, size.y, view, state, variant]
                    if image.save_png(path) != OK:
                        _fail("cannot write comparison frame")
                        return
                    if variant == "before":
                        baseline = image.duplicate() as Image
                    elif view == "chase":
                        # A green renderer test alone previously accepted fins
                        # that changed ZERO chase-view pixels. Compare actual
                        # rendered A/B pixels, not just mesh visibility flags.
                        var changed_samples := 0
                        for py in range(0, size.y, 3):
                            for px in range(0, size.x, 3):
                                var old_pixel: Color = baseline.get_pixel(px, py)
                                var new_pixel: Color = image.get_pixel(px, py)
                                var difference := maxf(absf(old_pixel.r - new_pixel.r),
                                    maxf(absf(old_pixel.g - new_pixel.g),
                                        absf(old_pixel.b - new_pixel.b)))
                                if difference > 0.10:
                                    changed_samples += 1
                        print("CARVE FIN CHASE A/B: %s %s = %d/9 sampled changed pixels" % [
                            str(size), state, changed_samples])
                        if changed_samples < 18:
                            _fail("carve fins are still visually occluded in chase camera: "
                                + str(size) + " " + state)
                            return
                    count += 1
    vanes.visible = true
    if count != 24:
        _fail("expected 24 pose-locked before/after board frames")
        return
    print("CARVE FIN VISUAL QA PASSED: 24 real landscape A/B frames, artistic approval pending")
    quit(0)
