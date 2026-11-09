extends SceneTree
## Render the REAL imported Blender bonus portal inside the existing Neon City
## runner scene in two smartphone landscape aspect ratios. Non-production QA.

const SIZES := [Vector2i(1280, 720), Vector2i(1170, 540)]

func _initialize() -> void:
    call_deferred("_capture")

func _fail(reason: String) -> void:
    push_error("BLENDER RACE VISUAL QA FAILED: " + reason)
    quit(1)

func _capture() -> void:
    var folder := OS.get_environment("LEARNQUEST_BLENDER_RACE_OUTPUT")
    if folder.is_empty():
        folder = "/tmp/learnquest-blender-race-qa"
    if DirAccess.make_dir_recursive_absolute(folder) != OK:
        _fail("cannot create screenshot output folder")
        return

    var viewport := SubViewport.new()
    viewport.size = SIZES[0]
    viewport.own_world_3d = true
    viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    root.add_child(viewport)
    var game_scene := load("res://main.tscn") as PackedScene
    if game_scene == null:
        _fail("main game scene could not load")
        return
    var world := game_scene.instantiate() as Node3D
    viewport.add_child(world)
    await process_frame
    world.call("_reset_run")
    var portal := world.get_node_or_null("Blender Bonus Portal") as Node3D
    var imported := portal.get_node_or_null("Actual Blender 3D Portal") if portal != null else null
    var chase_camera := world.get("chase_camera") as Camera3D
    var rider := world.get("rider") as Node3D
    if portal == null or imported == null or chase_camera == null or rider == null:
        _fail("actual Blender mesh, player or chase camera is missing")
        return

    # Freeze game simulation while the real game mesh, lighting, road and
    # surrounding Neon City remain visible to the 3D renderer.
    world.process_mode = Node.PROCESS_MODE_DISABLED
    var gallery := world.get("hero_gallery") as Node3D
    if gallery != null:
        gallery.visible = false
    # Compare a center-lane view (player partially obscures the Blender ring,
    # now signposted by the elevated beacon) and a clear adjacent-lane view.
    portal.position = Vector3(0.0, 0.0, -7.5)
    var beacon := portal.get_node_or_null("Center lane portal beacon above rider") as MeshInstance3D
    if beacon == null:
        _fail("center-lane Blender bonus portal beacon was not created")
        return
    chase_camera.position = Vector3(0.0, 3.9, 9.0)
    chase_camera.fov = 59.0
    chase_camera.look_at(Vector3(0.0, 1.7, -13.0), Vector3.UP)
    chase_camera.current = true

    var count := 0
    for size in SIZES:
        viewport.size = size
        for view in ["center", "adjacent"]:
            rider.position.x = 0.0 if view == "center" else -3.1
            var baseline: Image
            for state in ["without", "with"]:
                portal.visible = state == "with"
                for frame in range(6):
                    await process_frame
                await RenderingServer.frame_post_draw
                var shot := viewport.get_texture().get_image()
                if shot.is_empty() or shot.get_width() != size.x or shot.get_height() != size.y:
                    _fail("invalid in-game screenshot for " + str(size) + " " + view)
                    return
                var filename := "%s/%dx%d_%s_%s_blender_portal.png" % [
                    folder, size.x, size.y, view, state
                ]
                if shot.save_png(filename) != OK:
                    _fail("could not save in-game screenshot")
                    return
                if state == "without":
                    baseline = shot
                else:
                    var different := 0
                    for y in range(36):
                        for x in range(64):
                            var px := int(float(size.x - 1) * float(x) / 63.0)
                            var py := int(float(size.y - 1) * float(y) / 35.0)
                            var a := baseline.get_pixel(px, py)
                            var b := shot.get_pixel(px, py)
                            if absf(a.r - b.r) + absf(a.g - b.g) + absf(a.b - b.b) > 0.14:
                                different += 1
                    var minimum := 4 if view == "center" else 8
                    if different < minimum:
                        _fail("Blender portal is not signposted visibly at " + str(size) + " " + view)
                        return
                count += 1
    if count != 8:
        _fail("expected eight in-game center/adjacent before-after frames")
        return
    print("BLENDER RACE VISUAL QA PASSED: 8 actual phone frames, visible center beacon and Blender portal")
    quit(0)
