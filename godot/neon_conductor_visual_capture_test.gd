extends SceneTree
## V125: eight actual OpenGL landscape images compare the Neon City race
## with and without the new modeled boss. No phone FPS claims are made.
const SIZES := [Vector2i(1280, 720), Vector2i(1170, 540)]
const VIEWS := ["chase", "oblique"]

func _initialize() -> void:
    call_deferred("_capture")

func _fail(message: String) -> void:
    push_error("NEON CONDUCTOR VISUAL QA FAILED: " + message)
    quit(1)

func _capture() -> void:
    var output := OS.get_environment("LEARNQUEST_CONDUCTOR_OUTPUT")
    if output.is_empty():
        output = "/tmp/learnquest-conductor-qa"
    if DirAccess.make_dir_recursive_absolute(output) != OK:
        _fail("cannot create screenshot directory")
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
    env.background_color = Color("#0c1637")
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color("#9bb9e6")
    env.ambient_light_energy = 0.92
    world_env.environment = env
    stage.add_child(world_env)
    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-42, -28, 0)
    sun.light_energy = 1.45
    stage.add_child(sun)
    var camera := Camera3D.new()
    camera.fov = 69.0
    camera.far = 220.0
    stage.add_child(camera)
    camera.current = true
    var city := preload("res://neon_environment.gd").new() as Node3D
    stage.add_child(city)
    var boss := preload("res://neon_conductor.gd").new() as Node3D
    boss.position = Vector3(0.0, 0.7, -10.0)
    boss.scale = Vector3.ONE * 1.6
    stage.add_child(boss)
    await process_frame
    var captures := 0
    for size in SIZES:
        viewport.size = size
        for view in VIEWS:
            if view == "chase":
                camera.position = Vector3(0.0, 5.2, 10.5)
                camera.look_at(Vector3(0.0, 3.5, -10.0), Vector3.UP)
            else:
                camera.position = Vector3(5.0, 7.0, 10.5)
                camera.look_at(Vector3(0.0, 3.5, -10.0), Vector3.UP)
            var baseline: Image
            for state in ["before", "after"]:
                boss.visible = state == "after"
                for frame in range(5):
                    await process_frame
                await RenderingServer.frame_post_draw
                var shot := viewport.get_texture().get_image()
                if shot.is_empty() or shot.get_width() != size.x or shot.get_height() != size.y:
                    _fail("invalid landscape screenshot")
                    return
                if shot.save_png("%s/%dx%d_%s_%s.png" % [output, size.x, size.y, view, state]) != OK:
                    _fail("cannot save landscape screenshot")
                    return
                if state == "before":
                    baseline = shot
                else:
                    var changed := 0
                    for y in range(108):
                        for x in range(192):
                            var px := int(float(size.x - 1) * float(x) / 191.0)
                            var py := int(float(size.y - 1) * float(y) / 107.0)
                            var a := baseline.get_pixel(px, py)
                            var b := shot.get_pixel(px, py)
                            if absf(a.r - b.r) + absf(a.g - b.g) + absf(a.b - b.b) > 0.18:
                                changed += 1
                    if changed < 100:
                        _fail("modeled boss is not visibly distinct in %s %s (%d samples)" % [str(size), view, changed])
                        return
                captures += 1
    if captures != 8:
        _fail("expected eight actual before-after boss screenshots")
        return
    print("NEON CONDUCTOR VISUAL QA PASSED: eight 16:9 / 19.5:9 before-after Neon City frames")
    quit(0)
