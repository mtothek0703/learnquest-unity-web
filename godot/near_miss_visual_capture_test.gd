extends SceneTree
## Actual OpenGL before/after images of the new board-level near-miss pulse.
## Both frames use the same rider, camera, world and UI in phone landscape.
## These are render checks, not real iPhone FPS or touch-playthrough evidence.
const SIZES := [Vector2i(1280, 720), Vector2i(1170, 540)]

func _initialize() -> void:
    call_deferred("_capture")

func _fail(reason: String) -> void:
    push_error("NEAR MISS VISUAL QA FAILED: " + reason)
    quit(1)

func _capture() -> void:
    var output := OS.get_environment("LEARNQUEST_NEAR_MISS_OUTPUT")
    if output.is_empty():
        output = "/tmp/learnquest-near-miss-qa"
    if DirAccess.make_dir_recursive_absolute(output) != OK:
        _fail("cannot create screenshot folder")
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
    var zone := game.get("skyway_zone") as Node3D
    if zone != null:
        zone.process_mode = Node.PROCESS_MODE_DISABLED
    game.set("phase", "race")
    game.set("started", true)
    game.set("quiz_active", false)
    for name in ["splash", "quiz_box", "end_panel", "hero_gallery", "info_label"]:
        var control = game.get(name)
        if control != null:
            control.visible = false
    var rider := game.get("rider") as Node3D
    var camera := game.get("chase_camera") as Camera3D
    var ring := game.get("near_miss_ring") as MeshInstance3D
    if rider == null or camera == null or ring == null:
        _fail("real game chase camera, rider or near-miss VFX missing")
        return
    rider.process_mode = Node.PROCESS_MODE_DISABLED
    for size in SIZES:
        viewport.size = size
        game.set("xp", 0)
        game.set("turbo_left", 0.0)
        game.set("shield_left", 0.0)
        game.set("hit_cooldown", 0.0)
        game.call("_apply_mobile_layout", float(size.x), 1, float(size.y))
        game.call("_refresh_hud")
        var targets: Dictionary = game.call("_race_camera_targets", false, Vector2(size))
        camera.position = targets["position"]
        camera.look_at(targets["focus"], Vector3.UP)
        camera.fov = targets["fov"]
        game.set("near_miss_streak", 0)
        game.set("near_miss_last_side", 0)
        game.set("near_miss_last_rider_lane", 99)
        game.set("near_miss_mastery", false)
        ring.visible = false
        var baseline: Image
        for variant in ["before", "after"]:
            if variant == "after":
                for maneuver in [Vector2(-3.1, 0.0), Vector2(0.0, -3.1), Vector2(-3.1, 0.0)]:
                    rider.position.x = maneuver.y
                    game.call("_register_near_miss", maneuver.x)
                # Restore the exact baseline rider position for the A/B render.
                rider.position.x = 0.0
                if not bool(game.get("near_miss_mastery")) or not ring.visible:
                    _fail("three alternating hazards did not reveal the 3D board pulse")
                    return
                # Hold HUD and game world identical: count real VFX pixels,
                # not the XP or Turbo numbers earned by the challenge.
                game.set("xp", 0)
                game.set("turbo_left", 0.0)
                game.call("_refresh_hud")
            for frame in range(5):
                await process_frame
            await RenderingServer.frame_post_draw
            var shot := viewport.get_texture().get_image()
            if shot.is_empty() or shot.get_size() != size:
                _fail("invalid real landscape framebuffer")
                return
            if shot.save_png("%s/%dx%d_%s.png" % [output, size.x, size.y, variant]) != OK:
                _fail("could not save near-miss 3D frame")
                return
            if variant == "before":
                baseline = shot
            else:
                var changed := 0
                # Sample central gameplay area only, excluding top HUD.
                for sy in range(30, 103):
                    for sx in range(32, 160):
                        var px := int(float(size.x - 1) * float(sx) / 191.0)
                        var py := int(float(size.y - 1) * float(sy) / 107.0)
                        var a := baseline.get_pixel(px, py)
                        var b := shot.get_pixel(px, py)
                        if absf(a.r - b.r) + absf(a.g - b.g) + absf(a.b - b.b) > 0.16:
                            changed += 1
                if changed < 24:
                    _fail("3D near-miss pulse is invisible/occluded in %s: %d changed samples" % [size, changed])
                    return
                print("Near-miss 3D board pulse at %s: %d changed gameplay samples" % [size, changed])
    print("NEAR MISS VISUAL QA PASSED: four real 1280x720/1170x540 same-camera before/after game frames")
    quit(0)
