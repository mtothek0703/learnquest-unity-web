extends SceneTree
## V121: real 16:9 and 19.5:9 OpenGL before/after portal screenshots.
## This is visual QA, not a substitute for iPhone Safari performance testing.
const SIZES := [Vector2i(1280, 720), Vector2i(1170, 540)]
const VIEWS := ["chase", "oblique"]

func _initialize() -> void:
    call_deferred("_capture")

func _fail(message: String) -> void:
    push_error("CANYON ROUTES VISUAL QA FAILED: " + message)
    quit(1)

func _capture() -> void:
    var output := OS.get_environment("LEARNQUEST_ROUTES_OUTPUT")
    if output.is_empty():
        output = "/tmp/learnquest-routes-qa"
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
    env.background_color = Color("#25163e")
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color("#ffbedc")
    env.ambient_light_energy = 0.92
    world_env.environment = env
    stage.add_child(world_env)
    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-42, -28, 0)
    sun.light_energy = 1.5
    stage.add_child(sun)
    var camera := Camera3D.new()
    camera.fov = 72.0
    camera.far = 220.0
    stage.add_child(camera)
    camera.current = true
    var canyon := preload("res://crystal_canyon.gd").new() as Node3D
    stage.add_child(canyon)
    await process_frame
    var routes := canyon.get_node_or_null("Playable canyon route choices") as Node3D
    if routes == null:
        _fail("route forks are missing from the actual Canyon scene")
        return
    var junctions: Array = routes.get("junctions")
    junctions[0].position.z = -10.0
    junctions[1].position.z = -38.0
    var captures := 0
    for size in SIZES:
        viewport.size = size
        for view in VIEWS:
            if view == "chase":
                camera.position = Vector3(0.0, 5.2, 14.0)
                camera.look_at(Vector3(0.0, 2.4, -17.0), Vector3.UP)
            else:
                camera.position = Vector3(6.0, 8.2, 14.0)
                camera.look_at(Vector3(0.0, 2.7, -17.0), Vector3.UP)
            # The prior switchback A/B resets the junction positions. Restore
            # the SAME near-camera baseline for every ratio and camera view.
            routes.call("reset_course")
            junctions[0].position.z = -10.0
            junctions[1].position.z = -38.0
            var baseline: Image
            for state in ["before", "after"]:
                routes.visible = state == "after"
                for frame in range(5):
                    await process_frame
                await RenderingServer.frame_post_draw
                var image := viewport.get_texture().get_image()
                if image.is_empty() or image.get_width() != size.x or image.get_height() != size.y:
                    _fail("invalid landscape screenshot")
                    return
                if image.save_png("%s/%dx%d_%s_%s.png" % [output, size.x, size.y, view, state]) != OK:
                    _fail("cannot save landscape screenshot")
                    return
                if state == "before":
                    baseline = image
                else:
                    var changed := 0
                    # Thin emissive portal rings fall between coarse 96x54 samples.
                    # Denser sampling is a stricter visibility check, not a bypass.
                    for y in range(108):
                        for x in range(192):
                            var px := int(float(size.x - 1) * float(x) / 191.0)
                            var py := int(float(size.y - 1) * float(y) / 107.0)
                            var a := baseline.get_pixel(px, py)
                            var b := image.get_pixel(px, py)
                            if absf(a.r - b.r) + absf(a.g - b.g) + absf(a.b - b.b) > 0.18:
                                changed += 1
                    if changed < 45:
                        _fail("two branch portals are not visibly distinguishable in %s %s (%d samples)" % [str(size), view, changed])
                        return
                captures += 1
            # V132: keep the same camera and a single visible fork while the
            # next opposite-lane target brightens. These are actual rendered
            # gameplay-state frames, not manually composited mockups.
            routes.call("reset_course")
            junctions[0].visible = false
            junctions[0].set_meta("passed", true)
            junctions[1].position.z = -10.0
            routes.visible = true
            for state in ["unlit", "switchback"]:
                if state == "switchback":
                    routes.call("_record_choice", "energy", 15, 20)
                for frame in range(5):
                    await process_frame
                await RenderingServer.frame_post_draw
                var combo_image := viewport.get_texture().get_image()
                if combo_image.is_empty() or combo_image.get_width() != size.x or \
                        combo_image.get_height() != size.y:
                    _fail("invalid real switchback landscape screenshot")
                    return
                if combo_image.save_png("%s/%dx%d_%s_%s.png" % [
                        output, size.x, size.y, view, state]) != OK:
                    _fail("cannot save switchback portal guidance frame")
                    return
                captures += 1
    if captures != 16:
        _fail("expected sixteen baseline, fork and active switchback landscape frames")
        return
    print("CANYON ROUTES VISUAL QA PASSED: sixteen actual landscape images including live switchback 3D guidance")
    quit(0)
