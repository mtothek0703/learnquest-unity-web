extends SceneTree
## V124 action silhouette gate: real OpenGL V123/V124 frames in neutral,
## both carving directions and boost+jump. This is visual QA evidence,
## NOT an automatic claim that V124 looks better or passes iPhone FPS.
## All geometry and game controls remain untouched.
const SIZES := [Vector2i(1280, 720), Vector2i(1170, 540)]
const VIEWS := ["front", "chase"]
const POSES := ["neutral", "carve_left", "carve_right", "boost_jump"]

func _initialize() -> void:
    call_deferred("_capture")

func _fail(reason: String) -> void:
    push_error("EXTERNAL ACTION SILHOUETTE QA FAILED: " + reason)
    quit(1)

func _capture() -> void:
    var folder := OS.get_environment("LEARNQUEST_ACTION_OUTPUT")
    if folder.is_empty():
        folder = "/tmp/learnquest-action-qa"
    if DirAccess.make_dir_recursive_absolute(folder) != OK:
        _fail("action frame directory unavailable")
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
    camera.fov = 43.0
    stage.add_child(camera)
    camera.current = true
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    rider.set("prefer_cc0_rigged_hero", true)
    stage.add_child(rider)
    await process_frame
    var old := rider.get_node_or_null("ImportedRider") as Node3D
    var hero := rider.get_node_or_null("ExternalRiggedHero") as Node3D
    var adapter := rider.get_node_or_null("ExternalHeroPose") as Node
    if old == null or hero == null or adapter == null:
        _fail("V123 fallback, V124 imported hero or pose adapter missing")
        return
    var rig := adapter.get("skeleton") as Skeleton3D
    var meshes: Array = adapter.get("skinned_meshes")
    if rig == null or rig.get_bone_count() < 50 or meshes.is_empty():
        _fail("real imported 65-bone skinned hero unavailable")
        return
    if rig.get_node_or_null("ExternalHeroHeadgear") == null:
        _fail("real Head-bone accessories missing")
        return
    for mesh_item in meshes:
        var body := mesh_item as MeshInstance3D
        if body == null or body.skin == null or body.skin.get_bind_count() < 50:
            _fail("action poses must retain original GPU skin")
            return
    if hero.find_children("*", "CollisionObject3D", true, false).size() > 0:
        _fail("visual action comparison may not add collision bodies")
        return
    # Freeze the autonomous pose update: each capture receives the SAME
    # explicit pose parameters, rather than a different animation frame.
    rider.set_process(false)
    adapter.set_process(false)
    var head_id := rig.find_bone("Head")
    if head_id < 0:
        _fail("original Head joint missing")
        return
    var neutral_head := Quaternion.IDENTITY
    var count := 0
    for pose_name in POSES:
        rider.position.y = 0.0
        rider.set("lean", 0.0)
        rider.set("boosting", false)
        match pose_name:
            "carve_left":
                rider.set("lean", -0.90)
            "carve_right":
                rider.set("lean", 0.90)
            "boost_jump":
                rider.set("lean", 0.45)
                rider.set("boosting", true)
                rider.position.y = 0.88
        rider.call("_process", 0.30)
        adapter.call("_process", 0.35)
        if pose_name == "neutral":
            neutral_head = rig.get_bone_pose_rotation(head_id)
        elif rig.get_bone_pose_rotation(head_id).angle_to(neutral_head) < 0.035:
            _fail("action pose did not move the imported Head bone: " + pose_name)
            return
        for size in SIZES:
            viewport.size = size
            for view in VIEWS:
                camera.position = Vector3(0.0, 2.05, -7.4) if view == "front" else Vector3(0.0, 2.6, 7.8)
                camera.look_at(Vector3(0.0, 1.7, 0.0), Vector3.UP)
                for variant in ["before", "after"]:
                    old.visible = variant == "before"
                    hero.visible = variant == "after"
                    for frame in range(4):
                        await process_frame
                    await RenderingServer.frame_post_draw
                    var picture := viewport.get_texture().get_image()
                    if picture.is_empty() or picture.get_width() != size.x or picture.get_height() != size.y:
                        _fail("invalid landscape framebuffer for " + pose_name)
                        return
                    var filename := "%s/%dx%d_%s_%s_%s.png" % [
                        folder, size.x, size.y, pose_name, view, variant]
                    if picture.save_png(filename) != OK:
                        _fail("could not save actual action render " + filename)
                        return
                    count += 1
    if count != 32:
        _fail("expected 32 actual action frames, got %d" % count)
        return
    print("EXTERNAL ACTION SILHOUETTE QA PASSED: 32 real V123/V124 neutral/carve/boost-jump landscape frames; manual visual and iPhone review still required")
    quit(0)
