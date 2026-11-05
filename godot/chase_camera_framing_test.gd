extends SceneTree
## V145: the actual playable chase camera must keep all three lanes visible
## while making the 3D racer appreciably larger in both landscape ratios.
## No touch, quiz, boss or collision code is changed by this camera-only sprint.
const SIZES := [Vector2i(1280, 720), Vector2i(1170, 540)]

func _initialize() -> void:
    call_deferred("_run")

func _fail(reason: String) -> void:
    push_error("CHASE FRAMING TEST FAILED: " + reason)
    quit(1)

func _run() -> void:
    var viewport := SubViewport.new()
    viewport.size = SIZES[0]
    viewport.own_world_3d = true
    root.add_child(viewport)
    var game := preload("res://main.tscn").instantiate() as Node3D
    viewport.add_child(game)
    await process_frame
    game.set_process(false)
    var camera := game.get_node_or_null("Dynamic chase camera") as Camera3D
    var rider := game.get("rider") as Node3D
    if camera == null or rider == null:
        _fail("playable camera or actual rider missing")
        return
    game.set("phase", "race")
    game.set("started", true)
    game.set("quiz_active", false)
    for size in SIZES:
        viewport.size = size
        await process_frame
        for lane in [-1, 0, 1]:
            rider.position = Vector3(float(lane) * 3.1, 0.0, 0.2)
            game.set("turbo_left", 0.0)
            game.call("_update_camera", 100.0)
            var expected_distance := 7.75 if lane == 0 else 8.15
            var expected_fov := 60.0 if lane == 0 else 61.0
            if absf(camera.position.z - expected_distance) > 0.01 or absf(camera.fov - expected_fov) > 0.01:
                _fail("new normal-race camera is not active")
                return
            var focus: Vector3 = game.get("camera_focus")
            var expected_focus_y := 1.5 if lane == 0 else 1.25
            if absf(focus.y - expected_focus_y) > 0.01:
                _fail("edge-lane hoverboard clearance focus is missing")
                return
            var center := camera.unproject_position(rider.global_position + Vector3(0.0, 2.0, 0.0))
            if center.x < float(size.x) * 0.16 or center.x > float(size.x) * 0.84:
                _fail("rider lane %d falls outside landscape safe area %s" % [lane, str(size)])
                return
            # Project both ends of the rider into the real viewport, not just its center.
            # This catches off-screen clipping that a camera-distance assertion misses.
            var head_screen := camera.unproject_position(rider.global_position + Vector3(0.0, 3.5, 0.0))
            var deck_screen := camera.unproject_position(rider.global_position + Vector3(0.0, 0.0, 0.0))
            if head_screen.y < 0.0 or deck_screen.y > float(size.y):
                _fail("rider/board vertical framing clipped in lane %d at %s" % [lane, str(size)])
                return
            if camera.is_position_behind(rider.global_position):
                _fail("rider is behind chase camera")
                return
            # Synthetic vertical positions test projected clearance during the
            # rise, apex, descent and landing. This is a camera geometry
            # regression, not a substitute for real animated jump screenshots.
            for jump_height: float in [0.45, 1.25, 0.65, 0.0]:
                rider.position.y = jump_height
                game.call("_update_camera", 100.0)
                for local_point: Vector3 in [Vector3(0.0, 3.5, 0.0), Vector3(-0.8, 0.0, 0.0), Vector3(0.8, 0.0, 0.0)]:
                    var world_point: Vector3 = rider.global_position + local_point
                    if camera.is_position_behind(world_point):
                        _fail("jump rider/board behind camera in lane %d at %s" % [lane, str(size)])
                        return
                    var screen_point := camera.unproject_position(world_point)
                    if screen_point.x < 0.0 or screen_point.x > float(size.x) or screen_point.y < 0.0 or screen_point.y > float(size.y):
                        _fail("jump height %.2f clips rider/board in lane %d at %s" % [jump_height, lane, str(size)])
                        return
            rider.position.y = 0.0
            game.call("_update_camera", 100.0)
            game.set("turbo_left", 4.0)
            game.call("_update_camera", 100.0)
            if absf(camera.position.z - 9.1) > 0.01 or absf(camera.fov - 71.0) > 0.01:
                _fail("Turbo does not widen the chase view")
                return
            # Turbo changes both camera distance and FOV: verify the actual
            # projected rider/board remains on screen in every lane and ratio.
            for point in [
                rider.global_position + Vector3(0.0, 3.5, 0.0),
                rider.global_position + Vector3(0.0, 0.0, 0.0),
                rider.global_position + Vector3(-0.8, 0.0, 0.0),
                rider.global_position + Vector3(0.8, 0.0, 0.0)
            ]:
                if camera.is_position_behind(point):
                    _fail("Turbo rider/board behind camera in lane %d at %s" % [lane, str(size)])
                    return
                var projected := camera.unproject_position(point)
                if projected.x < 0.0 or projected.x > float(size.x) or projected.y < 0.0 or projected.y > float(size.y):
                    _fail("Turbo rider/board clipped in lane %d at %s" % [lane, str(size)])
                    return
    game.set("phase", "menu")
    game.call("_update_camera", 100.0)
    if camera.position.z >= -6.0 or absf(camera.fov - 58.0) > 0.01:
        _fail("front-facing menu presentation changed")
        return
    print("CHASE FRAMING TEST PASSED: 3 lanes, 2 landscape ratios, Turbo projection and menu")
    quit(0)
