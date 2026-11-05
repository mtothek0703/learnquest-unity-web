extends SceneTree
## V145: compare the ACTUAL race scene with the V144 chase camera at
## identical world/pose and 1280x720 + 1170x540. Run under Xvfb/OpenGL,
## not headless. Images are visual evidence, NOT physical iPhone FPS proof.
const SIZES := [Vector2i(1280, 720), Vector2i(1170, 540)]
const LANES := [-1, 0, 1]

func _initialize() -> void:
    call_deferred("_capture")

func _fail(reason: String) -> void:
    push_error("CHASE CAMERA VISUAL QA FAILED: " + reason)
    quit(1)

func _capture() -> void:
    var output := OS.get_environment("LEARNQUEST_CHASE_OUTPUT")
    if output.is_empty():
        output = "/tmp/learnquest-chase-qa"
    if DirAccess.make_dir_recursive_absolute(output) != OK:
        _fail("cannot create output folder")
        return
    var viewport := SubViewport.new()
    viewport.size = SIZES[0]
    viewport.own_world_3d = true
    viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    root.add_child(viewport)
    var game := preload("res://main.tscn").instantiate() as Node3D
    viewport.add_child(game)
    await process_frame
    game.set_process(false)
    var camera := game.get_node_or_null("Dynamic chase camera") as Camera3D
    var rider := game.get("rider") as Node3D
    if camera == null or rider == null:
        _fail("actual world camera/rider missing")
        return
    game.set("phase", "race")
    game.set("started", true)
    game.set("quiz_active", false)
    game.set("turbo_left", 0.0)
    var gallery := game.get("hero_gallery") as Node3D
    if gallery != null:
        gallery.visible = false
    for child in game.get_children():
        if child is CanvasLayer:
            child.visible = false
    var captures := 0
    for size in SIZES:
        viewport.size = size
        for lane in LANES:
            rider.position = Vector3(float(lane) * 3.1, 0.0, 0.2)
            var before: Image
            var old_height := 0.0
            for state in ["before", "after"]:
                if state == "before":
                    camera.position = Vector3(rider.position.x * 0.36, 4.3, 9.0)
                    camera.look_at(Vector3(rider.position.x * 0.42, 1.5, 0.5), Vector3.UP)
                    camera.fov = 64.0
                else:
                    game.call("_update_camera", 100.0)
                for frame in range(5):
                    await process_frame
                await RenderingServer.frame_post_draw
                var shot := viewport.get_texture().get_image()
                if shot.is_empty() or shot.get_width() != size.x or shot.get_height() != size.y:
                    _fail("invalid actual landscape frame")
                    return
                if shot.save_png("%s/%dx%d_lane%d_%s.png" % [output, size.x, size.y, lane, state]) != OK:
                    _fail("could not save actual frame")
                    return
                var top := camera.unproject_position(rider.global_position + Vector3(0.0, 3.5, 0.0))
                var bottom := camera.unproject_position(rider.global_position + Vector3(0.0, 0.5, 0.0))
                var height := absf(top.y - bottom.y)
                if state == "before":
                    before = shot
                    old_height = height
                else:
                    if height < old_height * 1.15:
                        _fail("rider is not at least 15 percent larger on screen")
                        return
                    var changed := 0
                    for y in range(108):
                        for x in range(192):
                            var px := int(float(size.x - 1) * float(x) / 191.0)
                            var py := int(float(size.y - 1) * float(y) / 107.0)
                            var a := before.get_pixel(px, py)
                            var b := shot.get_pixel(px, py)
                            if absf(a.r - b.r) + absf(a.g - b.g) + absf(a.b - b.b) > 0.18:
                                changed += 1
                    if changed < 180:
                        _fail("new race framing not visible in %s lane %d: %d samples" % [str(size), lane, changed])
                        return
                captures += 1
    if captures != 12:
        _fail("expected twelve real before/after images")
        return
    print("CHASE CAMERA VISUAL QA PASSED: twelve actual 16:9/19.5:9 race frames across all three lanes")
    quit(0)
