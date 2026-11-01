extends SceneTree
## Eight real OpenGL phone-landscape images of the Neon boss lane telegraph.
## This isolates raised chevrons from the existing flat warning beam.
const SIZES := [Vector2i(1280, 720), Vector2i(1170, 540)]
const VIEWS := ["chase", "oblique"]

func _initialize() -> void:
    call_deferred("_capture")

func _fail(reason: String) -> void:
    push_error("NEON WARNING VISUAL QA FAILED: " + reason)
    quit(1)

func _capture() -> void:
    var output := OS.get_environment("LEARNQUEST_WARNING_OUTPUT")
    if output.is_empty():
        output = "/tmp/learnquest-warning-qa"
    if DirAccess.make_dir_recursive_absolute(output) != OK:
        _fail("cannot create output folder")
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
    var warning := MeshInstance3D.new()
    var beam := BoxMesh.new()
    beam.size = Vector3(1.75, 0.13, 34.0)
    warning.mesh = beam
    warning.position = Vector3(0.0, 0.10, -13.0)
    var beam_mat := StandardMaterial3D.new()
    beam_mat.albedo_color = Color("#ff4dce")
    beam_mat.emission_enabled = true
    beam_mat.emission = Color("#ff4dce")
    beam_mat.emission_energy_multiplier = 1.8
    warning.material_override = beam_mat
    stage.add_child(warning)
    # Use the EXACT runtime mesh builder from the playable boss, not a mock.
    var geometry_source := preload("res://world.gd").new() as Node3D
    geometry_source.set("neon_beam", warning)
    geometry_source.call("_create_neon_warning_chevrons")
    var arrows := warning.get_node_or_null("RaisedBossLaneChevrons") as MeshInstance3D
    if arrows == null or arrows.mesh == null:
        _fail("runtime warning chevrons missing")
        return
    var captures := 0
    await process_frame
    for size in SIZES:
        viewport.size = size
        for view in VIEWS:
            if view == "chase":
                camera.position = Vector3(0.0, 5.2, 10.5)
                camera.look_at(Vector3(0.0, 0.6, -11.0), Vector3.UP)
            else:
                camera.position = Vector3(5.0, 7.0, 10.5)
                camera.look_at(Vector3(0.0, 0.6, -11.0), Vector3.UP)
            var baseline: Image
            for state in ["plain", "raised"]:
                arrows.visible = state == "raised"
                for frame in range(5):
                    await process_frame
                await RenderingServer.frame_post_draw
                var shot := viewport.get_texture().get_image()
                if shot.is_empty() or shot.get_width() != size.x or shot.get_height() != size.y:
                    _fail("invalid phone landscape frame")
                    return
                if shot.save_png("%s/%dx%d_%s_%s.png" % [
                        output, size.x, size.y, view, state]) != OK:
                    _fail("cannot write visual QA image")
                    return
                if state == "plain":
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
                    print("NEON WARNING VISUAL A/B: %s %s = %d changed samples" % [
                        str(size), view, changed])
                    if changed < 8:
                        _fail("raised arrows are not sufficiently visible in the phone chase view")
                        return
                captures += 1
    if captures != 8:
        _fail("expected eight real before/after landscape images")
        return
    print("NEON WARNING VISUAL QA PASSED: eight actual landscape frames")
    quit(0)
