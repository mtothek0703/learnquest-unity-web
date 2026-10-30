extends SceneTree
## Isolated, real OpenGL original-vs.-sculpted source-body comparison.
## Unlike V123/V124 comparisons, both frames use the SAME imported CC0
## character, board, original 65-bone pose, camera and light. This is
## geometry evidence, not an aesthetic approval or iPhone FPS measurement.
const SIZES := [Vector2i(1280, 720), Vector2i(1170, 540)]
const VIEWS := ["front", "chase"]

func _initialize() -> void:
    call_deferred("_capture")

func _fail(reason: String) -> void:
    push_error("CONTINUOUS BODY VISUAL QA FAILED: " + reason)
    quit(1)

func _capture() -> void:
    var folder := OS.get_environment("LEARNQUEST_BODY_SCULPT_OUTPUT")
    if folder.is_empty():
        folder = "/tmp/learnquest-body-sculpt-qa"
    if DirAccess.make_dir_recursive_absolute(folder) != OK:
        _fail("cannot create original-body screenshot folder")
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
    var light := DirectionalLight3D.new()
    light.rotation_degrees = Vector3(-35, -35, 0)
    light.light_energy = 1.6
    stage.add_child(light)
    var rim := DirectionalLight3D.new()
    rim.rotation_degrees = Vector3(-18, 145, 0)
    rim.light_color = Color(0.33, 0.84, 1.0)
    rim.light_energy = 0.85
    stage.add_child(rim)
    var camera := Camera3D.new()
    camera.fov = 43.0
    stage.add_child(camera)
    camera.current = true
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    rider.set("prefer_cc0_rigged_hero", true)
    stage.add_child(rider)
    await process_frame
    var hero := rider.get_node_or_null("ExternalRiggedHero") as Node3D
    var pose := rider.get_node_or_null("ExternalHeroPose") as Node
    if hero == null or pose == null:
        _fail("original 65-bone rider missing")
        return
    var rig := pose.get("skeleton") as Skeleton3D
    var body := hero.find_child("SuperHero_Male", true, false) as MeshInstance3D
    var sculpt := hero.get_node_or_null("ExternalContinuousBodySculpt") as Node
    if rig == null or rig.get_bone_count() != 65 or body == null or sculpt == null:
        _fail("true original-Skin source sculpt missing")
        return
    var before := sculpt.get("source_mesh") as Mesh
    var after := sculpt.get("sculpted_mesh") as Mesh
    if before == null or after == null or body.skin == null:
        _fail("both original weighted meshes required")
        return
    # Freeze the exact same action pose and the whole rider tree; no live
    # frame-dependent board bob, hair motion or rig update may contaminate
    # the two geometry-only screenshots.
    rider.set("lean", 0.45)
    pose.call("_process", 0.28)
    for i in range(6):
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
    rider.process_mode = Node.PROCESS_MODE_DISABLED
    for i in range(4):
        await process_frame
    var locked_hero := hero.global_transform
    var locked_bones: Array[Transform3D] = []
    for i in range(rig.get_bone_count()):
        locked_bones.append(rig.get_bone_pose(i))
    var visibility: Dictionary = {}
    for node in hero.find_children("*", "MeshInstance3D", true, false):
        var mesh := node as MeshInstance3D
        visibility[mesh] = mesh.visible
    var count := 0
    for size in SIZES:
        viewport.size = size
        for view in VIEWS:
            camera.position = Vector3(0, 2.0, -5.2) if view == "front" else Vector3(0, 2.25, 5.4)
            camera.look_at(Vector3(0, 1.8, 0), Vector3.UP)
            for mode in ["source_only", "complete_rider"]:
                for item in visibility.keys():
                    var mesh := item as MeshInstance3D
                    mesh.visible = bool(visibility[item]) if mode == "complete_rider" else mesh == body
                for variant in ["original", "sculpted"]:
                    body.mesh = before if variant == "original" else after
                    for frame in range(5):
                        hero.global_transform = locked_hero
                        for bone in range(locked_bones.size()):
                            rig.set_bone_pose(bone, locked_bones[bone])
                        await process_frame
                    await RenderingServer.frame_post_draw
                    if hero.global_transform.origin.distance_to(locked_hero.origin) > 0.003:
                        _fail("hero drift invalidates paired source-body comparison")
                        return
                    var image := viewport.get_texture().get_image()
                    if image.is_empty() or image.get_width() != size.x or image.get_height() != size.y:
                        _fail("invalid OpenGL smartphone landscape frame")
                        return
                    var filename := "%s/%dx%d_%s_%s_%s.png" % [
                        folder, size.x, size.y, view, mode, variant]
                    if image.save_png(filename) != OK:
                        _fail("could not save original body comparison frame")
                        return
                    count += 1
    body.mesh = after
    for item in visibility.keys():
        (item as MeshInstance3D).visible = bool(visibility[item])
    if count != 16:
        _fail("expected sixteen actual original/sculpted landscape frames")
        return
    print("CONTINUOUS BODY VISUAL QA PASSED: 16 real pose-locked source-only/full-rider landscape PNGs; visual approval pending")
    quit(0)
