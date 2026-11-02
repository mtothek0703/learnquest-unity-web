extends SceneTree
## Isolated original Godot OpenGL before/after landscape renders for V143.
const SIZES := [Vector2i(1280, 720), Vector2i(1170, 540)]
const VIEWS := ["chase", "oblique"]

func _initialize() -> void:
    call_deferred("_capture")

func _fail(message: String) -> void:
    push_error("GLACIER ICEFALLS VISUAL QA FAILED: " + message)
    quit(1)

func _capture() -> void:
    var output := OS.get_environment("LEARNQUEST_ICEFALLS_OUTPUT")
    if output.is_empty():
        output = "/tmp/learnquest-icefalls-qa"
    if DirAccess.make_dir_recursive_absolute(output) != OK:
        _fail("cannot create render directory")
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
    environment.background_color = Color("#101d42")
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color("#a6d9f7")
    environment.ambient_light_energy = 0.92
    world_env.environment = environment
    stage.add_child(world_env)
    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-42, -25, 0)
    sun.light_energy = 1.45
    stage.add_child(sun)
    var camera := Camera3D.new()
    camera.fov = 75.0
    camera.far = 220.0
    stage.add_child(camera)
    camera.current = true
    var glacier := preload("res://aurora_glacier.gd").new() as Node3D
    stage.add_child(glacier)
    await process_frame
    var falls := glacier.get_node_or_null("Cinematic sculpted glacier icefalls") as Node3D
    if falls == null:
        _fail("no new icefalls to compare")
        return
    var count := 0
    for size in SIZES:
        viewport.size = size
        for view in VIEWS:
            if view == "chase":
                camera.position = Vector3(0.0, 5.5, 14.0)
                camera.look_at(Vector3(0.0, 6.0, -35.0), Vector3.UP)
            else:
                camera.position = Vector3(4.0, 8.0, 16.0)
                camera.look_at(Vector3(0.0, 7.0, -38.0), Vector3.UP)
            var baseline: Image
            for state in ["before", "after"]:
                falls.visible = state == "after"
                for frame in range(5):
                    await process_frame
                await RenderingServer.frame_post_draw
                var shot := viewport.get_texture().get_image()
                if shot.is_empty() or shot.get_width() != size.x or shot.get_height() != size.y:
                    _fail("invalid real landscape image")
                    return
                if shot.save_png("%s/%dx%d_%s_%s.png" % [output, size.x, size.y, view, state]) != OK:
                    _fail("cannot save landscape image")
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
                    if changed < 120:
                        _fail("sculpted icefalls not visibly distinct in %s %s (%d samples)" % [str(size), view, changed])
                        return
                count += 1
    # Isolate the NEW sculpted flow from the existing V143 ice walls.
    # Whole-icefall before/after alone cannot prove V154 adds visible value.
    var channels: Array = falls.get("flow_channels")
    var canopies: Array = falls.get("overhead_flows")
    var stream_images := 0
    for size in SIZES:
        viewport.size = size
        for view in VIEWS:
            if view == "chase":
                camera.position = Vector3(0.0, 5.5, 14.0)
                camera.look_at(Vector3(0.0, 6.0, -35.0), Vector3.UP)
            else:
                camera.position = Vector3(4.0, 8.0, 16.0)
                camera.look_at(Vector3(0.0, 7.0, -38.0), Vector3.UP)
            falls.visible = true
            var without_streams: Image
            for state in ["streams_off", "streams_on"]:
                var show_streams: bool = state == "streams_on"
                for channel in channels:
                    (channel as MeshInstance3D).visible = show_streams
                for canopy in canopies:
                    (canopy as MeshInstance3D).visible = show_streams
                for frame in range(5):
                    await process_frame
                await RenderingServer.frame_post_draw
                var shot := viewport.get_texture().get_image()
                if shot.is_empty() or shot.get_width() != size.x or shot.get_height() != size.y:
                    _fail("invalid streaming glacier landscape capture")
                    return
                if shot.save_png("%s/%dx%d_%s_%s.png" % [output, size.x, size.y, view, state]) != OK:
                    _fail("cannot save streaming glacier QA image")
                    return
                if not show_streams:
                    without_streams = shot
                else:
                    var changed := 0
                    for y in range(108):
                        for x in range(192):
                            var px := int(float(size.x - 1) * float(x) / 191.0)
                            var py := int(float(size.y - 1) * float(y) / 107.0)
                            var a := without_streams.get_pixel(px, py)
                            var b := shot.get_pixel(px, py)
                            if absf(a.r - b.r) + absf(a.g - b.g) + absf(a.b - b.b) > 0.16:
                                changed += 1
                    if changed < 8:
                        _fail("new raised flowing streams are not visibly distinct in %s %s (%d samples)" % [str(size), view, changed])
                        return
                stream_images += 1
    if stream_images != 8:
        _fail("expected eight isolated flowing-stream landscape images")
        return
    if count != 8:
        _fail("expected eight real landscape comparison images")
        return
    print("GLACIER ICEFALLS VISUAL QA PASSED: eight icefall and eight isolated streaming-channel 16:9/wide landscape images")
    quit(0)
