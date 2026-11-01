extends SceneTree
## V144: actual Godot OpenGL landscape before/after for the orbital cranes.
const SIZES := [Vector2i(1280, 720), Vector2i(1170, 540)]
const VIEWS := ["chase", "oblique"]

func _initialize() -> void:
    call_deferred("_capture")

func _fail(message: String) -> void:
    push_error("HARBOR SKYCRANES VISUAL QA FAILED: " + message)
    quit(1)

func _capture() -> void:
    var output := OS.get_environment("LEARNQUEST_SKYCRANES_OUTPUT")
    if output.is_empty():
        output = "/tmp/learnquest-skycranes-qa"
    if DirAccess.make_dir_recursive_absolute(output) != OK:
        _fail("cannot create landscape output")
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
    environment.background_color = Color("#101b38")
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color("#b6ecff")
    environment.ambient_light_energy = 0.92
    environment_node.environment = environment
    stage.add_child(environment_node)
    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-42, -28, 0)
    sun.light_energy = 1.5
    stage.add_child(sun)
    var camera := Camera3D.new()
    camera.fov = 75.0
    camera.far = 220.0
    stage.add_child(camera)
    camera.current = true
    var harbor := preload("res://star_harbor.gd").new() as Node3D
    stage.add_child(harbor)
    await process_frame
    var cranes := harbor.get_node_or_null("Cinematic Star Harbor orbital cargo cranes") as Node3D
    if cranes == null:
        _fail("cranes not integrated into actual Harbor")
        return
    var captures := 0
    for size in SIZES:
        viewport.size = size
        for view in VIEWS:
            if view == "chase":
                camera.position = Vector3(0.0, 7.5, 14.0)
                camera.look_at(Vector3(0.0, 7.5, -32.0), Vector3.UP)
            else:
                camera.position = Vector3(5.0, 11.0, 15.0)
                camera.look_at(Vector3(0.0, 8.0, -34.0), Vector3.UP)
            var baseline: Image
            for state in ["before", "after"]:
                cranes.visible = state == "after"
                for frame in range(5):
                    await process_frame
                await RenderingServer.frame_post_draw
                var shot := viewport.get_texture().get_image()
                if shot.is_empty() or shot.get_width() != size.x or shot.get_height() != size.y:
                    _fail("invalid original landscape image")
                    return
                if shot.save_png("%s/%dx%d_%s_%s.png" % [output, size.x, size.y, view, state]) != OK:
                    _fail("cannot save actual landscape image")
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
                    if changed < 65:
                        _fail("new 3D cranes too subtle in %s %s (%d changed samples)" % [str(size), view, changed])
                        return
                captures += 1
    if captures != 8:
        _fail("expected eight real before-after landscape frames")
        return
    print("HARBOR SKYCRANES VISUAL QA PASSED: eight actual 16:9 and 19.5:9 comparison frames")
    quit(0)
