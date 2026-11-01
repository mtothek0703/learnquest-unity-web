extends SceneTree
## Original 3D gameplay frames before/after earning the lane-weave pulse.
## Render via xvfb/OpenGL, not --headless. Not a real iPhone FPS test.
const SIZES := [Vector2i(1280, 720), Vector2i(1170, 540)]

func _initialize() -> void:
    call_deferred("_capture")

func _fail(message: String) -> void:
    push_error("ENERGY WEAVE VISUAL QA FAILED: " + message)
    quit(1)

func _capture() -> void:
    var output := OS.get_environment("LEARNQUEST_WEAVE_OUTPUT")
    if output.is_empty():
        output = "/tmp/learnquest-weave-qa"
    if DirAccess.make_dir_recursive_absolute(output) != OK:
        _fail("cannot create QA output")
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
    # Hold every animated child at the SAME pose for a real VFX-only A/B.
    # Otherwise moving hair/traffic can falsely satisfy pixel-difference QA.
    var world_zone := game.get("skyway_zone") as Node3D
    if world_zone != null:
        world_zone.process_mode = Node.PROCESS_MODE_DISABLED
    game.set("phase", "race")
    game.set("started", true)
    game.set("quiz_active", false)
    for name in ["splash", "quiz_box", "end_panel", "hero_gallery", "info_label"]:
        var panel = game.get(name)
        if panel != null:
            panel.visible = false
    var rider := game.get("rider") as Node3D
    var camera := game.get("chase_camera") as Camera3D
    var ring := game.get("energy_weave_ring") as MeshInstance3D
    if rider == null or camera == null or ring == null:
        _fail("real game chase camera, rider or pulse missing")
        return
    rider.process_mode = Node.PROCESS_MODE_DISABLED
    for size in SIZES:
        viewport.size = size
        game.set("xp", 0)
        game.set("turbo_left", 0.0)
        game.call("_apply_mobile_layout", float(size.x), 1, float(size.y))
        game.call("_refresh_hud")
        var targets: Dictionary = game.call("_race_camera_targets", false, Vector2(size))
        camera.position = targets["position"]
        camera.look_at(targets["focus"], Vector3.UP)
        camera.fov = targets["fov"]
        game.set("energy_weave_streak", 0)
        game.set("energy_weave_last_lane", 99)
        game.set("energy_weave_mastery", false)
        ring.visible = false
        var original: Image
        for variant in ["before", "after"]:
            if variant == "after":
                for lane_x in [-3.1, 3.1, -3.1]:
                    game.call("_register_energy_weave", lane_x)
                if not bool(game.get("energy_weave_mastery")) or not ring.visible:
                    _fail("real three-lane action did not reveal 3D pulse")
                    return
            for frame in range(5):
                await process_frame
            await RenderingServer.frame_post_draw
            var shot := viewport.get_texture().get_image()
            if shot.is_empty() or shot.get_width() != size.x or shot.get_height() != size.y:
                _fail("invalid actual phone landscape frame")
                return
            var filename := "%s/%dx%d_%s.png" % [output, size.x, size.y, variant]
            if shot.save_png(filename) != OK:
                _fail("cannot save " + filename)
                return
            if variant == "before":
                original = shot
            else:
                var changed := 0
                for y in range(108):
                    for x in range(192):
                        var px := int(float(size.x - 1) * float(x) / 191.0)
                        var py := int(float(size.y - 1) * float(y) / 107.0)
                        var old := original.get_pixel(px, py)
                        var now := shot.get_pixel(px, py)
                        if absf(old.r - now.r) + absf(old.g - now.g) + absf(old.b - now.b) > 0.16:
                            changed += 1
                if changed < 32:
                    _fail("earned 3D pulse not visible at %s: only %d changed samples" % [size, changed])
                    return
                print("Energy Weave actual landscape changed samples %s: %d" % [size, changed])
    # New V150: isolate an actual energy gate in the next valid lane, and
    # prove that its 3D waypoint changes REAL chase frames (not only a flag).
    var items := game.get("run_items") as Node3D
    var target_gate: Node3D
    for item in items.get_children():
        item.visible = false
        item.set_meta("collected", true)
        if target_gate == null and bool(item.get_meta("energy")):
            target_gate = item as Node3D
    if target_gate == null:
        _fail("no real energy gate for slalom waypoint capture")
        return
    target_gate.position = Vector3(3.1, 0.0, -7.0)
    target_gate.set_meta("collected", false)
    target_gate.visible = true
    var beacon := target_gate.get_node_or_null("Next slalom lane beacon") as Node3D
    if beacon == null:
        _fail("missing 3D slalom waypoint")
        return
    ring.visible = false
    game.set("energy_weave_mastery", false)
    game.set("energy_weave_last_lane", -1)
    for size in SIZES:
        viewport.size = size
        game.call("_apply_mobile_layout", float(size.x), 1, float(size.y))
        var targets: Dictionary = game.call("_race_camera_targets", false, Vector2(size))
        camera.position = targets["position"]
        camera.look_at(targets["focus"], Vector3.UP)
        camera.fov = targets["fov"]
        var baseline: Image
        for variant in ["unmarked", "marked"]:
            game.set("energy_weave_streak", 0 if variant == "unmarked" else 1)
            game.call("_update_energy_weave_guides")
            if beacon.visible != (variant == "marked"):
                _fail("slalom beacon did not obey alternate-lane progress")
                return
            for frame in range(5):
                await process_frame
            await RenderingServer.frame_post_draw
            var shot := viewport.get_texture().get_image()
            if shot.is_empty() or shot.get_size() != size:
                _fail("invalid beacon landscape render")
                return
            if shot.save_png("%s/%dx%d_beacon_%s.png" % [output, size.x, size.y, variant]) != OK:
                _fail("could not save beacon frame")
                return
            if variant == "unmarked":
                baseline = shot
            else:
                var changed := 0
                for y in range(108):
                    for x in range(192):
                        var px := int(float(size.x - 1) * float(x) / 191.0)
                        var py := int(float(size.y - 1) * float(y) / 107.0)
                        var before := baseline.get_pixel(px, py)
                        var after := shot.get_pixel(px, py)
                        if absf(before.r - after.r) + absf(before.g - after.g) + absf(before.b - after.b) > 0.16:
                            changed += 1
                if changed < 16:
                    _fail("3D slalom beacon too small/occluded at %s: %d changed samples" % [size, changed])
                    return
                print("Slalom beacon actual landscape changed samples %s: %d" % [size, changed])
    print("ENERGY WEAVE VISUAL QA PASSED: 8 real game chase frames at 1280x720 and 1170x540, including 3D lane beacons")
    quit(0)
