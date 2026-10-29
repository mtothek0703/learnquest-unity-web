extends SceneTree
## V124 draft: eight real phone-landscape before/after images of paired 3D
## boost wakes. This proves pixels changed, not that visual quality is approved.
const SIZES := [Vector2i(1280, 720), Vector2i(1170, 540)]
const VIEWS := ["front", "chase"]

func _initialize() -> void:
    call_deferred("_capture")

func _fail(reason: String) -> void:
    push_error("BOOST WAKE VISUAL QA FAILED: " + reason)
    quit(1)

func _capture() -> void:
    var folder := OS.get_environment("LEARNQUEST_WAKE_OUTPUT")
    if folder.is_empty():
        folder = "/tmp/learnquest-wake-qa"
    if DirAccess.make_dir_recursive_absolute(folder) != OK:
        _fail("wake QA directory unavailable")
        return
    var viewport := SubViewport.new()
    viewport.size = SIZES[0]
    viewport.own_world_3d = true
    viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    root.add_child(viewport)
    var stage := Node3D.new()
    viewport.add_child(stage)
    var env_node := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color(0.035, 0.055, 0.12)
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.56, 0.66, 0.92)
    env.ambient_light_energy = 0.85
    env_node.environment = env
    stage.add_child(env_node)
    var light := DirectionalLight3D.new()
    light.rotation_degrees = Vector3(-35.0, -35.0, 0.0)
    light.light_energy = 1.6
    stage.add_child(light)
    var camera := Camera3D.new()
    camera.fov = 43.0
    stage.add_child(camera)
    camera.current = true
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    rider.set("prefer_cc0_rigged_hero", true)
    stage.add_child(rider)
    await process_frame
    var legacy := rider.get_node_or_null("LegacyRider") as Node3D
    var board := rider.get_node_or_null("LegacyRider/Floating hoverboard/SculptedHoverboardChassis") as Node3D
    var wake: Node3D = null
    if board != null:
        wake = board.get_node_or_null("BoostWake") as Node3D
    if legacy == null or board == null or wake == null:
        _fail("original animated board or its 3D wake missing")
        return
    var parts: Array = wake.get("wake_meshes")
    if parts.size() != 2:
        _fail("both wakes required for before/after rendering")
        return
    rider.set_process(false)
    legacy.set_process(false)
    board.set_process(false)
    wake.set_process(false)
    legacy.set("boosting", true)
    legacy.set("lean", 0.25)
    wake.call("_process", 0.60)
    var count := 0
    var changed_chase := 0
    for size in SIZES:
        viewport.size = size
        for view in VIEWS:
            camera.position = Vector3(0.0, 1.65, -5.6) if view == "front" else Vector3(0.0, 1.95, 5.6)
            camera.look_at(Vector3(0.0, 0.8, 0.0), Vector3.UP)
            var previous: Image
            for variant in ["before", "after"]:
                for part in parts:
                    (part as MeshInstance3D).visible = variant == "after"
                for frame in range(5):
                    await process_frame
                await RenderingServer.frame_post_draw
                var frame_image := viewport.get_texture().get_image()
                if frame_image.is_empty() or frame_image.get_width() != size.x or frame_image.get_height() != size.y:
                    _fail("invalid landscape framebuffer")
                    return
                if frame_image.save_png("%s/%dx%d_%s_%s.png" % [folder, size.x, size.y, view, variant]) != OK:
                    _fail("could not save real boost-wake image")
                    return
                if variant == "before":
                    previous = frame_image
                elif view == "chase":
                    for y in range(0, size.y, 6):
                        for x in range(0, size.x, 6):
                            var after_color := frame_image.get_pixel(x, y)
                            var before_color := previous.get_pixel(x, y)
                            var channel_delta := maxf(absf(after_color.r - before_color.r),
                                maxf(absf(after_color.g - before_color.g),
                                    absf(after_color.b - before_color.b)))
                            if channel_delta > 0.08:
                                changed_chase += 1
                count += 1
    if count != 8 or changed_chase < 35:
        _fail("eight images required and visible 3D boost wake must alter chase pixels")
        return
    print("BOOST WAKE VISUAL QA PASSED: 8 real phone-landscape frames, visible chase difference; manual approval pending")
    quit(0)
