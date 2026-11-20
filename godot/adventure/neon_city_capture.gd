extends SceneTree
## Real rendered Neon City QA capture. Run with a display (e.g. xvfb-run),
## never --headless: headless rendering cannot prove visual quality.
## Usage: godot --path godot --script res://adventure/neon_city_capture.gd
## Output: /tmp/learnquest-neon-qa/1280x720.png and 1170x540.png
const OUTPUT := "/tmp/learnquest-neon-qa"

func _initialize() -> void:
    call_deferred("_capture")

func _fail(reason: String) -> void:
    push_error("NEON CITY RENDER QA FAILED: " + reason)
    quit(1)

func _capture() -> void:
    if DisplayServer.get_name() == "headless":
        _fail("A real display/renderer is required; do not use --headless")
        return
    var game := load("res://main.tscn").instantiate() as Node3D
    if game == null:
        _fail("Could not instantiate the real game scene")
        return
    root.add_child(game)
    await process_frame
    game.call("_toggle_adventure_opt_in")
    game.call("_begin_training")
    for i in range(3):
        if str(game.get("phase")) != "training" or not bool(game.get("quiz_active")):
            _fail("Three-question gate was not available")
            return
        var choices: Array = game.get("options")
        game.call("_answer", choices.find(int(game.get("correct_index"))))
    if str(game.get("phase")) != "race":
        _fail("Race did not start")
        return
    game.set("distance", 150.0)
    if not bool(game.call("_enter_adventure")):
        _fail("Real Neon City on-foot level did not start")
        return
    var arena := game.get("adventure_area") as Node3D
    if arena == null or arena.get_node_or_null("NeonCitySkyline") == null:
        _fail("Neon City skyline is missing from the rendered level")
        return
    var camera := arena.get("follow_camera") as Camera3D
    if camera == null:
        _fail("Adventure camera is missing")
        return
    DirAccess.make_dir_recursive_absolute(OUTPUT)
    for resolution in [Vector2i(1280, 720), Vector2i(1170, 540)]:
        root.size = resolution
        camera.current = true
        await process_frame
        await process_frame
        await RenderingServer.frame_post_draw
        var frame := root.get_texture().get_image()
        if frame == null or frame.is_empty():
            _fail("Renderer produced no image")
            return
        if frame.get_width() != resolution.x or frame.get_height() != resolution.y:
            _fail("Wrong captured resolution: " + str(frame.get_size()))
            return
        var target := OUTPUT + "/" + str(resolution.x) + "x" + str(resolution.y) + ".png"
        var error := frame.save_png(target)
        if error != OK:
            _fail("Could not write PNG: " + str(error))
            return
        print("NEON CITY RENDER CAPTURE: " + target)
    print("NEON CITY REAL RENDER CAPTURE COMPLETE; VISUAL REVIEW STILL REQUIRED")
    quit(0)
