extends SceneTree
## Reproducible real Godot in-game visual frames of the walking Neon City.
## No synthetic illustration and no claim of device/FPS approval.
const SIZES := [Vector2i(1280, 720), Vector2i(1170, 540)]

func _initialize() -> void:
    call_deferred("_capture")

func _fail(reason: String) -> void:
    push_error("ADVENTURE VISUAL CAPTURE FAILED: " + reason)
    quit(1)

func _capture() -> void:
    var folder := OS.get_environment("LEARNQUEST_ADVENTURE_VISUAL_OUTPUT")
    if folder.is_empty():
        folder = "/tmp/learnquest-adventure-visual"
    if DirAccess.make_dir_recursive_absolute(folder) != OK:
        _fail("cannot create output directory")
        return
    var packed := load("res://adventure/neon_walk_testbed.tscn") as PackedScene
    if packed == null:
        _fail("walking testbed scene missing")
        return
    var viewport := SubViewport.new()
    viewport.size = SIZES[0]
    viewport.own_world_3d = true
    viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    root.add_child(viewport)
    var area := packed.instantiate() as Node3D
    viewport.add_child(area)
    await process_frame
    var player := area.get("player") as CharacterBody3D
    var camera := area.get("follow_camera") as Camera3D
    if player == null or camera == null:
        _fail("real walking player or camera missing")
        return
    var visual := player.get_node_or_null("WalkingVisual") as Node3D
    if visual == null or visual.find_children("*", "Skeleton3D", true, false).is_empty():
        _fail("actual rigged Blender hero missing from game")
        return
    # Keep gameplay paused for reproducible frames, but preserve the real
    # camera, imported skin, lighting, platforms, HUD and city geometry.
    area.process_mode = Node.PROCESS_MODE_DISABLED
    player.position = Vector3(0, 1.05, 0)
    # Match the current playable third-person framing rather than an old
    # fixed QA camera that made the hero look artificially distant.
    # The hero remains at the same reproducible test position for all poses.
    camera.global_position = player.global_position + Vector3(0, 2.9, 5.2)
    camera.look_at(player.global_position + Vector3.UP * 0.75)
    camera.current = true
    var animators := visual.find_children("*", "AnimationPlayer", true, false)
    if animators.is_empty():
        _fail("imported character has no animation player")
        return
    var animator := animators[0] as AnimationPlayer
    var clip := ""
    for name in animator.get_animation_list():
        if name != "RESET":
            clip = name
            break
    if clip.is_empty():
        _fail("imported character has no pose animation")
        return
    animator.play(clip)
    var count := 0
    for size in SIZES:
        viewport.size = size
        for pose in ["idle", "walk", "jump"]:
            # Timeline samples are deterministic QA snapshots, not a claim
            # of seamless transition blending or real touch performance.
            var sample := 0.2 if pose == "idle" else (2.8 if pose == "walk" else 6.2)
            animator.seek(sample, true)
            for frame in range(8):
                await process_frame
            await RenderingServer.frame_post_draw
            var shot := viewport.get_texture().get_image()
            if shot.is_empty() or shot.get_width() != size.x or shot.get_height() != size.y:
                _fail("invalid actual game screenshot: " + pose + " " + str(size))
                return
            var path := "%s/%dx%d_%s_neon_walk.png" % [folder, size.x, size.y, pose]
            if shot.save_png(path) != OK:
                _fail("failed to save " + path)
                return
            count += 1
    if count != 6:
        _fail("expected six actual game frames")
        return
    print("ADVENTURE VISUAL CAPTURE PASSED: six in-game frames, visual approval still required")
    quit(0)
