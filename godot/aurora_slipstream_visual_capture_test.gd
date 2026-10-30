extends SceneTree
## Aurora Glacier 3D slipstream visual QA. Eight real Mesa/OpenGL landscape
## screenshots compare the same frozen world with/without the wind tunnel.
const SIZES := [Vector2i(1280, 720), Vector2i(1170, 540)]
const VIEWS := ["chase", "oblique"]

func _initialize() -> void:
    call_deferred("_capture")

func _fail(message: String) -> void:
    push_error("AURORA SLIPSTREAM VISUAL QA FAILED: " + message)
    quit(1)

func _capture() -> void:
    var output := OS.get_environment("LEARNQUEST_SLIPSTREAM_OUTPUT")
    if output.is_empty():
        output = "/tmp/learnquest-slipstream-qa"
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
    var env_node := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color("#092c4a")
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color("#c5f0ff")
    env.ambient_light_energy = 0.95
    env_node.environment = env
    stage.add_child(env_node)
    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-42, -22, 0)
    sun.light_energy = 1.4
    stage.add_child(sun)
    var camera := Camera3D.new()
    camera.fov = 64.0
    camera.far = 220.0
    stage.add_child(camera)
    camera.current = true
    var glacier := preload("res://aurora_glacier.gd").new() as Node3D
    stage.add_child(glacier)
    await process_frame
    var course := glacier.get_node_or_null("Playable Aurora slipstream course") as Node3D
    if course == null:
        _fail("actual Glacier world has no wind tunnel")
        return
    var stations: Array = course.get("stations")
    stations[0].position = Vector3(0.0, 0.0, -9.0)
    glacier.set_process(false)
    course.set_process(false)
    var captures := 0
    for size in SIZES:
        viewport.size = size
        for view in VIEWS:
            if view == "chase":
                camera.position = Vector3(0.0, 4.8, 10.0)
                camera.look_at(Vector3(0.0, 2.4, -9.0), Vector3.UP)
            else:
                camera.position = Vector3(4.0, 6.0, 10.0)
                camera.look_at(Vector3(0.0, 2.4, -9.0), Vector3.UP)
            var baseline: Image
            for state in ["before", "after"]:
                course.visible = state == "after"
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
                    if changed < 80:
                        _fail("3D wind tunnel is too small in %s %s (%d samples)" % [str(size), view, changed])
                        return
                captures += 1
    if captures != 8:
        _fail("expected eight real before-after landscape screenshots")
        return
    print("AURORA SLIPSTREAM VISUAL QA PASSED: eight frozen 16:9 / 19.5:9 Glacier frames")
    quit(0)
