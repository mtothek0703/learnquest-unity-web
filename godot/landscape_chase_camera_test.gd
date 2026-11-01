extends SceneTree
## V145 candidate: mobile landscape chase composition without gameplay changes.
func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("LANDSCAPE CHASE CAMERA TEST FAILED: " + message)
    quit(1)

func _check() -> void:
    var game := preload("res://main.tscn").instantiate() as Node3D
    if game == null:
        _fail("main scene missing")
        return
    root.add_child(game)
    await process_frame
    game.set_process(false)
    var rider := game.get("rider") as Node3D
    var camera := game.get("chase_camera") as Camera3D
    if rider == null or camera == null:
        _fail("actual rider or chase camera missing")
        return
    var desktop: Dictionary = game.call("_race_camera_targets", false, Vector2(1920, 1080))
    if not is_equal_approx(float(desktop["fov"]), 64.0) or not is_equal_approx((desktop["position"] as Vector3).z, 9.0):
        _fail("desktop camera must remain exactly V144")
        return
    for screen in [Vector2(1280, 720), Vector2(1170, 540), Vector2(852, 393)]:
        var normal: Dictionary = game.call("_race_camera_targets", false, screen)
        var turbo: Dictionary = game.call("_race_camera_targets", true, screen)
        var compact := screen.y < 620.0
        var normal_fov := 63.0 if compact else 58.0
        var turbo_fov := 73.0 if compact else 70.0
        var normal_z := 8.5 if compact else 7.55
        var turbo_z := 9.7 if compact else 8.65
        if not is_equal_approx(float(normal["fov"]), normal_fov) or not is_equal_approx(float(turbo["fov"]), turbo_fov):
            _fail("phone landscape FOV regression at " + str(screen))
            return
        if not is_equal_approx((normal["position"] as Vector3).z, normal_z) or not is_equal_approx((turbo["position"] as Vector3).z, turbo_z):
            _fail("phone landscape camera distance regression")
            return
        if float(normal["fov"]) >= float(desktop["fov"]):
            _fail("phone rider must be visibly larger than old desktop framing")
            return
    game.set("phase", "race")
    game.set("started", true)
    game.set("quiz_active", false)
    for lane_x in [-3.1, 0.0, 3.1]:
        rider.position.x = lane_x
        for boosted in [false, true]:
            game.set("turbo_left", 1.0 if boosted else 0.0)
            game.call("_update_camera", 100.0)
            var expected: Dictionary = game.call("_race_camera_targets", boosted, root.get_visible_rect().size)
            if camera.position.distance_to(expected["position"]) > 0.01 or absf(camera.fov - float(expected["fov"])) > 0.01:
                _fail("actual camera does not use landscape targets")
                return
            var subject := camera.unproject_position(rider.global_position + Vector3(0.0, 2.1, 0.0))
            var bounds: Vector2 = root.get_visible_rect().size
            if camera.is_position_behind(rider.global_position + Vector3(0.0, 2.1, 0.0)) or subject.x < bounds.x * 0.08 or subject.x > bounds.x * 0.92 or subject.y < bounds.y * 0.06 or subject.y > bounds.y * 0.85:
                _fail("rider leaves safe screen area for lane %s, boost %s: %s" % [lane_x, boosted, subject])
                return
    if int(game.get_script().get_script_constant_map().get("TASKS_PER_ROUND", 0)) != 3:
        _fail("three mandatory vocabulary tasks changed")
        return
    print("LANDSCAPE CHASE CAMERA TEST PASSED: three phone ratios, desktop unchanged, lane/turbo framing and vocabulary rules")
    quit(0)
