extends SceneTree
## V145 candidate: real gameplay world/camera before-after at phone landscape sizes.
## Run with Mesa/OpenGL display, not --headless. Screenshots are not iPhone FPS proof.
const SIZES := [Vector2i(1280, 720), Vector2i(1170, 540)]
const POSES := ["center", "right_lane", "turbo"]

func _initialize() -> void:
    call_deferred("_capture")

func _fail(message: String) -> void:
    push_error("LANDSCAPE CHASE VISUAL QA FAILED: " + message)
    quit(1)

func _capture() -> void:
    var output := OS.get_environment("LEARNQUEST_CHASE_OUTPUT")
    if output.is_empty():
        output = "/tmp/learnquest-chase-qa"
    if DirAccess.make_dir_recursive_absolute(output) != OK:
        _fail("cannot create QA directory")
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
    game.set("phase", "race")
    game.set("started", true)
    game.set("quiz_active", false)
    for name in ["splash", "quiz_box", "end_panel", "hero_gallery"]:
        var panel = game.get(name)
        if panel != null:
            panel.visible = false
    var rider := game.get("rider") as Node3D
    var camera := game.get("chase_camera") as Camera3D
    if rider == null or camera == null:
        _fail("actual game rider or camera missing")
        return
    var count := 0
    for size in SIZES:
        viewport.size = size
        # Render the REAL touch-landscape HUD rather than a desktop fallback.
        # The mission progress bar must remain below the three-line panel.
        game.call("_apply_mobile_layout", float(size.x), 1, float(size.y))
        game.call("_refresh_hud")
        await process_frame
        var hud_panel := game.get("hud_panel") as PanelContainer
        var progress := game.get("progress_bar") as ProgressBar
        var hud := game.get("hud") as Label
        if hud_panel == null or progress == null or hud == null:
            _fail("real landscape HUD/progress nodes missing")
            return
        if hud.text.split("\n").size() != 3:
            _fail("short phone landscape race HUD is not three lines")
            return
        if hud_panel.get_global_rect().end.y + 4.0 > progress.get_global_rect().position.y:
            _fail("real landscape HUD overlaps mission progress at %s: panel=%s progress=%s" % [size, hud_panel.get_global_rect(), progress.get_global_rect()])
            return
        for pose in POSES:
            rider.position.x = 3.1 if pose == "right_lane" else 0.0
            var boost: bool = pose == "turbo"
            game.set("turbo_left", 1.0 if boost else 0.0)
            var original: Image
            for variant in ["before", "after"]:
                if variant == "before":
                    camera.position = Vector3(rider.position.x * 0.36, 4.3, 10.1 if boost else 9.0)
                    camera.look_at(Vector3(rider.position.x * 0.42, 1.5, 0.5), Vector3.UP)
                    camera.fov = 74.0 if boost else 64.0
                else:
                    var target: Dictionary = game.call("_race_camera_targets", boost, Vector2(size))
                    camera.position = target["position"]
                    camera.look_at(target["focus"], Vector3.UP)
                    camera.fov = target["fov"]
                for frame in range(5):
                    await process_frame
                await RenderingServer.frame_post_draw
                var shot := viewport.get_texture().get_image()
                if shot.is_empty() or shot.get_width() != size.x or shot.get_height() != size.y:
                    _fail("invalid actual gameplay landscape screenshot")
                    return
                var filename := "%s/%dx%d_%s_%s.png" % [output, size.x, size.y, pose, variant]
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
                            var a := original.get_pixel(px, py)
                            var b := shot.get_pixel(px, py)
                            if absf(a.r - b.r) + absf(a.g - b.g) + absf(a.b - b.b) > 0.18:
                                changed += 1
                    if changed < 150:
                        _fail("framing change not visible in %s %s: %d changed samples" % [size, pose, changed])
                        return
                count += 1
    if count != 12:
        _fail("expected 12 original gameplay before-after landscape screenshots")
        return
    print("LANDSCAPE CHASE VISUAL QA PASSED: 12 original gameplay frames, two phone ratios, three poses")
    quit(0)
