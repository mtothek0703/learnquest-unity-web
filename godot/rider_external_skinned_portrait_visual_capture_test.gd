extends SceneTree
## Real OpenGL portrait before/after QA. Same camera, rig and material:
## the only intended difference is rigid Head face versus original-Skin face.
## A successful capture is NOT an aesthetic or iPhone-FPS sign-off.
const SIZES := [Vector2i(1280, 720), Vector2i(1170, 540)]
const VIEWS := ["front_close", "left_profile", "right_profile"]

func _initialize() -> void:
    call_deferred("_capture")

func _fail(reason: String) -> void:
    push_error("TRUE SKINNED PORTRAIT VISUAL QA FAILED: " + reason)
    quit(1)

func _capture() -> void:
    var folder := OS.get_environment("LEARNQUEST_PORTRAIT_OUTPUT")
    if folder.is_empty():
        folder = "/tmp/learnquest-skinned-portrait-qa"
    if DirAccess.make_dir_recursive_absolute(folder) != OK:
        _fail("cannot create screenshot directory")
        return
    var viewport := SubViewport.new()
    viewport.size = SIZES[0]
    viewport.own_world_3d = true
    viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    root.add_child(viewport)
    var stage := Node3D.new()
    viewport.add_child(stage)
    var env_node := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color(0.035, 0.055, 0.12)
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.56, 0.66, 0.92)
    env.ambient_light_energy = 0.85
    env_node.environment = env
    stage.add_child(env_node)
    var key := DirectionalLight3D.new()
    key.rotation_degrees = Vector3(-35.0, -35.0, 0.0)
    key.light_energy = 1.6
    stage.add_child(key)
    var rim := DirectionalLight3D.new()
    rim.rotation_degrees = Vector3(-18.0, 145.0, 0.0)
    rim.light_color = Color(0.33, 0.84, 1.0)
    rim.light_energy = 0.85
    stage.add_child(rim)
    var camera := Camera3D.new()
    camera.fov = 38.0
    stage.add_child(camera)
    camera.current = true
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    rider.set("prefer_cc0_rigged_hero", true)
    stage.add_child(rider)
    await process_frame
    var hero := rider.get_node_or_null("ExternalRiggedHero") as Node3D
    var adapter := rider.get_node_or_null("ExternalHeroPose") as Node
    if hero == null or adapter == null:
        _fail("imported skinned character missing")
        return
    var conversion := hero.get_node_or_null("ExternalTrueSkinnedPortrait") as Node
    if conversion == null:
        _fail("face conversion missing")
        return
    var skinned := conversion.get("face") as MeshInstance3D
    var rigid := conversion.get("original") as MeshInstance3D
    if skinned == null or rigid == null:
        _fail("both face variants required for matching images")
        return
    rider.set("lean", 0.75)
    rider.set("boosting", true)
    adapter.call("_process", 0.28)
    # Lock the exact same hero/board pose for BOTH face variants. The first
    # capture revealed that live rider updates shifted the entire avatar
    # between images, producing meaningless 6-18% whole-frame differences.
    for frame in range(8):
        await process_frame
    rider.set_process(false)
    rider.set_physics_process(false)
    for node in rider.find_children("*", "Node", true, false):
        node.set_process(false)
        node.set_physics_process(false)
        if node is AnimationPlayer:
            (node as AnimationPlayer).pause()
        elif node is AnimationTree:
            (node as AnimationTree).active = false
    # Disable inherited/internal processing as well, then allow pending
    # skeleton/attachment transforms to settle BEFORE taking the snapshot.
    rider.process_mode = Node.PROCESS_MODE_DISABLED
    for settle_frame in range(4):
        await process_frame
    var rig := adapter.get("skeleton") as Skeleton3D
    var head_id := rig.find_bone("Head")
    var locked_head := rig.get_bone_pose_rotation(head_id)
    var locked_hero := hero.global_transform
    var count := 0
    for size in SIZES:
        viewport.size = size
        for view in VIEWS:
            match view:
                "front_close":
                    camera.position = Vector3(0.0, 2.35, -3.8)
                "left_profile":
                    camera.position = Vector3(-3.8, 2.35, 0.0)
                "right_profile":
                    camera.position = Vector3(3.8, 2.35, 0.0)
            camera.look_at(Vector3(0.0, 2.15, 0.0), Vector3.UP)
            for variant in ["rigid", "skinned"]:
                rigid.visible = variant == "rigid"
                skinned.visible = variant == "skinned"
                for frame in range(5):
                    await process_frame
                await RenderingServer.frame_post_draw
                var hero_now := hero.global_transform
                if rig.get_bone_pose_rotation(head_id).angle_to(locked_head) > 0.003 or \
                        hero_now.origin.distance_to(locked_hero.origin) > 0.003 or \
                        hero_now.basis.x.distance_to(locked_hero.basis.x) > 0.003 or \
                        hero_now.basis.y.distance_to(locked_hero.basis.y) > 0.003 or \
                        hero_now.basis.z.distance_to(locked_hero.basis.z) > 0.003:
                    _fail("rig/hero pose drifted between rigid and skinned comparison frames")
                    return
                var img := viewport.get_texture().get_image()
                if img.is_empty() or img.get_width() != size.x or img.get_height() != size.y:
                    _fail("invalid OpenGL portrait framebuffer")
                    return
                if img.save_png("%s/%dx%d_%s_%s.png" % [folder, size.x, size.y, view, variant]) != OK:
                    _fail("portrait screenshot could not be saved")
                    return
                count += 1
    rigid.visible = false
    skinned.visible = true
    if count != 12:
        _fail("expected twelve actual landscape face comparisons")
        return
    print("TRUE SKINNED PORTRAIT VISUAL QA PASSED: 12 actual landscape rigid/skinned front/profile frames")
    quit(0)
