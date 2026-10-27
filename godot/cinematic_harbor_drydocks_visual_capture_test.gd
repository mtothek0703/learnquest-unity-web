extends SceneTree
## V122: actual before/after Star Harbor 3D dock frames, two landscape ratios.
const SIZES := [Vector2i(1280, 720), Vector2i(1170, 540)]
const VIEWS := ["chase", "oblique"]

func _initialize() -> void:
    call_deferred("_capture")

func _fail(message: String) -> void:
    push_error("HARBOR DRYDOCKS VISUAL QA FAILED: " + message)
    quit(1)

func _capture() -> void:
    var output := OS.get_environment("LEARNQUEST_HARBOR_OUTPUT")
    if output.is_empty():
        output = "/tmp/learnquest-harbor-qa"
    if DirAccess.make_dir_recursive_absolute(output) != OK:
        _fail("cannot create harbor screenshot directory")
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
    env.background_color = Color("#101b38")
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color("#b6ecff")
    env.ambient_light_energy = 0.90
    env_node.environment = env
    stage.add_child(env_node)
    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-38, -25, 0)
    sun.light_energy = 1.5
    stage.add_child(sun)
    var camera := Camera3D.new()
    camera.fov = 75.0
    camera.far = 230.0
    stage.add_child(camera)
    camera.current = true
    var harbor := preload("res://star_harbor.gd").new() as Node3D
    stage.add_child(harbor)
    await process_frame
    var docks := harbor.get_node_or_null("Cinematic Star Harbor loading drydocks") as Node3D
    if docks == null:
        _fail("drydock scenery missing from actual harbor")
        return
    var count := 0
    for size in SIZES:
        viewport.size = size
        for view in VIEWS:
            if view == "chase":
                camera.position = Vector3(0.0, 8.0, 16.0)
                camera.look_at(Vector3(0.0, 5.5, -42.0), Vector3.UP)
            else:
                camera.position = Vector3(5.0, 12.0, 17.0)
                camera.look_at(Vector3(0.0, 7.0, -44.0), Vector3.UP)
            var baseline: Image
            for state in ["before", "after"]:
                docks.visible = state == "after"
                for frame in range(5):
                    await process_frame
                await RenderingServer.frame_post_draw
                var image := viewport.get_texture().get_image()
                if image.is_empty() or image.get_width() != size.x or image.get_height() != size.y:
                    _fail("invalid landscape harbor render")
                    return
                if image.save_png("%s/%dx%d_%s_%s.png" % [output, size.x, size.y, view, state]) != OK:
                    _fail("cannot save harbor screenshot")
                    return
                if state == "before":
                    baseline = image
                else:
                    var changed := 0
                    for y in range(108):
                        for x in range(192):
                            var px := int(float(size.x - 1) * float(x) / 191.0)
                            var py := int(float(size.y - 1) * float(y) / 107.0)
                            var a := baseline.get_pixel(px, py)
                            var b := image.get_pixel(px, py)
                            if absf(a.r - b.r) + absf(a.g - b.g) + absf(a.b - b.b) > 0.18:
                                changed += 1
                    if changed < 65:
                        _fail("3D drydocks are not clearly visible in %s %s (%d changed samples)" % [str(size), view, changed])
                        return
                count += 1
    if count != 8:
        _fail("expected eight actual before-after harbor frames")
        return
    print("HARBOR DRYDOCKS VISUAL QA PASSED: eight real landscape before-after images")
    quit(0)
