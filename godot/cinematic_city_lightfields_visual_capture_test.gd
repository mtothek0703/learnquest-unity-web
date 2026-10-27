extends SceneTree
## V119: real OpenGL before/after pairs at 16:9 and 19.5:9.
## Disable only the new lightfields, so the baseline is identical scene/camera.
const SIZES := [Vector2i(1280, 720), Vector2i(1170, 540)]
const VIEWS := ["chase", "oblique"]

func _initialize() -> void:
    call_deferred("_capture")

func _fail(message: String) -> void:
    push_error("CITY LIGHTFIELDS VISUAL QA FAILED: " + message)
    quit(1)

func _capture() -> void:
    var output := OS.get_environment("LEARNQUEST_LIGHTFIELDS_OUTPUT")
    if output.is_empty():
        output = "/tmp/learnquest-lightfields-qa"
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
    environment.background_color = Color("#111a37")
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color("#829ac9")
    environment.ambient_light_energy = 0.85
    world_env.environment = environment
    stage.add_child(world_env)
    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-40, -25, 0)
    sun.light_energy = 1.3
    stage.add_child(sun)
    var camera := Camera3D.new()
    camera.fov = 75.0
    camera.far = 220.0
    stage.add_child(camera)
    camera.current = true
    var city := preload("res://neon_environment.gd").new() as Node3D
    stage.add_child(city)
    await process_frame
    var lightfields := city.get_node_or_null("Cinematic atmospheric lightfields") as Node3D
    if lightfields == null:
        _fail("cannot compare a missing lightfields")
        return
    var count := 0
    for size in SIZES:
        viewport.size = size
        for view in VIEWS:
            if view == "chase":
                camera.position = Vector3(0.0, 8.0, 15.0)
                camera.look_at(Vector3(0.0, 9.0, -42.0), Vector3.UP)
            else:
                camera.position = Vector3(6.0, 12.0, 18.0)
                camera.look_at(Vector3(0.0, 10.0, -45.0), Vector3.UP)
            var baseline: Image
            for state in ["before", "after"]:
                lightfields.visible = state == "after"
                for frame in range(5):
                    await process_frame
                await RenderingServer.frame_post_draw
                var shot := viewport.get_texture().get_image()
                if shot.is_empty() or shot.get_width() != size.x or shot.get_height() != size.y:
                    _fail("invalid rendered landscape image")
                    return
                if shot.save_png("%s/%dx%d_%s_%s.png" % [output, size.x, size.y, view, state]) != OK:
                    _fail("could not save rendered comparison")
                    return
                if state == "before":
                    baseline = shot
                else:
                    var different := 0
                    for y in range(16):
                        for x in range(32):
                            var px := int(float(size.x - 1) * float(x) / 31.0)
                            var py := int(float(size.y - 1) * float(y) / 15.0)
                            var a := baseline.get_pixel(px, py)
                            var b := shot.get_pixel(px, py)
                            if absf(a.r - b.r) + absf(a.g - b.g) + absf(a.b - b.b) > 0.16:
                                different += 1
                    if different < 6:
                        _fail("new lighting does not visibly change the %s %s view" % [str(size), view])
                        return
                count += 1
    if count != 8:
        _fail("expected eight actual rendered before/after images")
        return
    print("CITY LIGHTFIELDS VISUAL QA PASSED: eight actual 16:9 / 19.5:9 before-after Neon City frames")
    quit(0)
