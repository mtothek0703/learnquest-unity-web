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
            if absf(camera.position.z - 7.15) > 0.01 or absf(camera.fov - 58.0) > 0.01:
                _fail("new normal-race camera is not active")
                return
            var center := camera.unproject_position(rider.global_position + Vector3(0.0, 2.0, 0.0))
            if center.x < float(size.x) * 0.16 or center.x > float(size.x) * 0.84:
                _fail("rider lane %d falls outside landscape safe area %s" % [lane, str(size)])
                return
            if camera.is_position_behind(rider.global_position):
                _fail("rider is behind chase camera")
                return
            game.set("turbo_left", 4.0)
            game.call("_update_camera", 100.0)
            if absf(camera.position.z - 8.7) > 0.01 or absf(camera.fov - 70.0) > 0.01:
                _fail("Turbo does not widen the chase view")
                return
    game.set("phase", "menu")
    game.call("_update_camera", 100.0)
    if camera.position.z >= -6.0 or absf(camera.fov - 58.0) > 0.01:
        _fail("front-facing menu presentation changed")
        return
    print("CHASE FRAMING TEST PASSED: 3 lanes, 2 landscape ratios, Turbo and menu")
    quit(0)
