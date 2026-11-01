extends SceneTree
## V120: actual OpenGL before/after images, identical camera/scene in landscape.
const SIZES := [Vector2i(1280, 720), Vector2i(1170, 540)]
const VIEWS := ["chase", "oblique"]

func _initialize() -> void:
    call_deferred("_capture")

func _fail(message: String) -> void:
    push_error("CANYON GEODES VISUAL QA FAILED: " + message)
    quit(1)

func _capture() -> void:
    var output := OS.get_environment("LEARNQUEST_CANYON_OUTPUT")
    if output.is_empty():
        output = "/tmp/learnquest-canyon-qa"
    if DirAccess.make_dir_recursive_absolute(output) != OK:
        _fail("cannot create output directory")
        return
    var viewport := SubViewport.new()
    viewport.size = SIZES[0]
    viewport.own_world_3d = true
    viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    root.add_child(viewport)
    var stage := Node3D.new()
    viewport.add_child(stage)
    var world_env := WorldEnvironment.new()
    var environment := Environment.new()
    environment.background_mode = Environment.BG_COLOR
    environment.background_color = Color("#312044")
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color("#ffc1d8")
    environment.ambient_light_energy = 0.85
    world_env.environment = environment
    stage.add_child(world_env)
    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-38, -28, 0)
    sun.light_energy = 1.4
    stage.add_child(sun)
    var camera := Camera3D.new()
    camera.fov = 75.0
    camera.far = 220.0
    stage.add_child(camera)
    camera.current = true
    var canyon := preload("res://crystal_canyon.gd").new() as Node3D
    stage.add_child(canyon)
    await process_frame
    var reefs := canyon.get_node_or_null("Cinematic floating geode reefs") as Node3D
    if reefs == null:
        _fail("cannot render missing geode islands")
        return
    var bridges := canyon.get_node_or_null("Cinematic canyon sky bridges") as Node3D
    if bridges == null:
        _fail("cannot render missing canyon sky bridges")
        return
    var count := 0
    for size in SIZES:
        viewport.size = size
        for view in VIEWS:
            if view == "chase":
                camera.position = Vector3(0.0, 8.0, 16.0)
                camera.look_at(Vector3(0.0, 7.0, -42.0), Vector3.UP)
            else:
                camera.position = Vector3(5.0, 12.0, 18.0)
                camera.look_at(Vector3(0.0, 8.0, -44.0), Vector3.UP)
            var baseline: Image
            for state in ["before", "after"]:
                reefs.visible = state == "after"
                for frame in range(5):
                    await process_frame
                await RenderingServer.frame_post_draw
                var shot := viewport.get_texture().get_image()
                if shot.is_empty() or shot.get_width() != size.x or shot.get_height() != size.y:
                    _fail("invalid landscape render")
                    return
                if shot.save_png("%s/%dx%d_%s_%s.png" % [output, size.x, size.y, view, state]) != OK:
                    _fail("could not save render")
                    return
                if state == "before":
                    baseline = shot
                else:
                    var changed := 0
                    for y in range(54):
                        for x in range(96):
                            var px := int(float(size.x - 1) * float(x) / 95.0)
                            var py := int(float(size.y - 1) * float(y) / 53.0)
                            var a := baseline.get_pixel(px, py)
                            var b := shot.get_pixel(px, py)
                            if absf(a.r - b.r) + absf(a.g - b.g) + absf(a.b - b.b) > 0.18:
                                changed += 1
                    if changed < 42:
                        _fail("new 3D canyon geometry is not sufficiently visible in %s %s (%d pixels)" % [str(size), view, changed])
                        return
                count += 1
            # Isolate the new sky-bridge silhouettes: same existing canyon,
            # same geodes and identical camera for each before/after frame.
            reefs.visible = true
            var bridge_baseline: Image
            for state in ["bridge_before", "bridge_after"]:
                bridges.visible = state == "bridge_after"
                for frame in range(5):
                    await process_frame
                await RenderingServer.frame_post_draw
                var bridge_shot := viewport.get_texture().get_image()
                if bridge_shot.is_empty() or bridge_shot.get_width() != size.x or bridge_shot.get_height() != size.y:
                    _fail("invalid sky-bridge landscape render")
                    return
                if bridge_shot.save_png("%s/%dx%d_%s_%s.png" % [output, size.x, size.y, view, state]) != OK:
                    _fail("could not save sky-bridge render")
                    return
                if state == "bridge_before":
                    bridge_baseline = bridge_shot
                else:
                    var bridge_changed := 0
                    for y in range(108):
                        for x in range(192):
                            var px := int(float(size.x - 1) * float(x) / 191.0)
                            var py := int(float(size.y - 1) * float(y) / 107.0)
                            var a := bridge_baseline.get_pixel(px, py)
                            var b := bridge_shot.get_pixel(px, py)
                            if absf(a.r - b.r) + absf(a.g - b.g) + absf(a.b - b.b) > 0.18:
                                bridge_changed += 1
                    if bridge_changed < 90:
                        _fail("new sculpted sky bridges are not sufficiently visible in %s %s (%d samples)" % [str(size), view, bridge_changed])
                        return
                count += 1
    if count != 16:
        _fail("expected sixteen real before-after images")
        return
    print("CANYON GEODES VISUAL QA PASSED: sixteen 16:9 and 19.5:9 real before-after frames including isolated sky bridges")
    quit(0)
