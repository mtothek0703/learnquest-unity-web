extends SceneTree
## Render REAL V123 vs V124 16:9 / 19.5:9 frames; not a fake image.
const SIZES := [Vector2i(1280, 720), Vector2i(1170, 540)]
const VIEWS := ["front", "chase", "front_detail", "chase_detail",
    "left_profile", "right_profile"]
func _initialize() -> void:
    call_deferred("_capture")
func _fail(message: String) -> void:
    push_error("QUATERNIUS VISUAL QA FAILED: " + message)
    quit(1)
func _capture() -> void:
    var folder := OS.get_environment("LEARNQUEST_QUATERNIUS_OUTPUT")
    if folder.is_empty():
        folder = "/tmp/learnquest-quaternius-qa"
    if DirAccess.make_dir_recursive_absolute(folder) != OK:
        _fail("output directory unavailable")
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
    light.rotation_degrees = Vector3(-35.0, -35.0, 0.0)
    light.light_energy = 1.6
    stage.add_child(light)
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
    if old == null or hero == null:
        _fail("both comparable rider models must be available")
        return
    var pose := rider.get_node_or_null("ExternalHeroPose") as Node
    var rig: Skeleton3D = null
    if pose != null:
        rig = pose.get("skeleton") as Skeleton3D
    if rig == null or rig.get_node_or_null("ExternalHeroHeadgear") == null:
        _fail("real Head-bone helmet/hair must appear in V124 comparison frames")
        return
    var mantle_meshes := hero.find_children("*WeightedFlightMantle", "MeshInstance3D", true, false)
    var core_meshes := hero.find_children("*SkinnedThrusterCore", "MeshInstance3D", true, false)
    if mantle_meshes.size() != 2 or core_meshes.size() != 2:
        _fail("expected two actual GPU-skinned mantle tails and two shoulder thruster cores")
        return
    # Lock both actual characters at the SAME rest/hover pose before the
    # paired capture. Previously the V123 animation kept running while the
    # V124 image was taken, so position/pose drift polluted A/B differences.
    rider.set("lean", 0.0)
    rider.set("boosting", false)
    for frame in range(6):
        await process_frame
    var locked_old := old.global_transform
    var locked_hero := hero.global_transform
    var bone_locks: Dictionary = {}
    for skeleton_node in rider.find_children("*", "Skeleton3D", true, false):
        var skeleton := skeleton_node as Skeleton3D
        var poses: Array[Transform3D] = []
        for bone_id in range(skeleton.get_bone_count()):
            poses.append(skeleton.get_bone_pose(bone_id))
        bone_locks[skeleton] = poses
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
    for frame in range(4):
        await process_frame
    var board := rider.get_node_or_null("LegacyRider/Floating hoverboard") as Node3D
    if board == null:
        _fail("CC0 board comparison needs the original animated board")
        return
    # Diagnostic A/B: isolate the real imported source torso from the
    # true weighted jacket. A previous deeper V cut looked unchanged in
    # front and revealed a broad purple band in chase; do not guess which
    # original-Skin layer creates the horizontal collar.
    var source_body := hero.find_child("SuperHero_Male", true, false) as MeshInstance3D
    var fitted_jacket := hero.find_child("TrueSkinnedTailoredJacket", true, false) as MeshInstance3D
    if source_body == null or fitted_jacket == null or \
            source_body.skin == null or fitted_jacket.skin != source_body.skin:
        _fail("collar isolation requires original CC0 Skin and fitted jacket")
        return
    var jacket_shader := fitted_jacket.material_override as ShaderMaterial
    if jacket_shader == null or jacket_shader.shader == null or \
            not jacket_shader.shader.code.contains("qa_upper_jacket_mode"):
        _fail("upper-jacket diagnostic requires the original four-weight jacket shader")
        return
    # Diagnostic-only layer switches; preserve every mesh's original state.
    var harness_mesh := hero.find_child("FourWeightSculptedFlightHarness", true, false) as MeshInstance3D
    var sleeve_meshes := hero.find_children("*WeightedFlightSleeve", "MeshInstance3D", true, false)
    if harness_mesh == null or harness_mesh.skin != source_body.skin or sleeve_meshes.size() != 2:
        _fail("layer isolation needs the four-weight harness and both sleeves")
        return
    var harness_was_visible := harness_mesh.visible
    var sleeves_were_visible: Array[bool] = []
    for sleeve in sleeve_meshes:
        var part := sleeve as MeshInstance3D
        if part == null or part.skin != source_body.skin:
            _fail("layer isolation sleeve must share the original imported Skin")
            return
        sleeves_were_visible.append(part.visible)
    var count := 0
    for size in SIZES:
        viewport.size = size
        for view in VIEWS:
            # Retain the identical wide V123/V124 comparisons and add a
            # closer full-figure framing. The original wide shots hide the
            # face, boot seams and shoulder clipping at mobile screen size.
            camera.fov = 43.0
            match view:
                "front":
                    camera.position = Vector3(0.0, 2.05, -7.4)
                "chase":
                    camera.position = Vector3(0.0, 2.6, 7.8)
                "front_detail":
                    camera.position = Vector3(0.0, 2.0, -5.2)
                "chase_detail":
                    camera.position = Vector3(0.0, 2.25, 5.4)
                "left_profile":
                    camera.position = Vector3(-5.6, 2.15, 0.0)
                "right_profile":
                    camera.position = Vector3(5.6, 2.15, 0.0)
            camera.look_at(Vector3(0.0, 1.8 if view.ends_with("detail") else 1.7, 0.0), Vector3.UP)
            # Preserve the original paired frames; two extra isolation states
            # reveal whether broad weighted tails or glowing shoulder cores
            # are responsible for the toy-like rear silhouette.
            var compact_board_frame: Image
            for variant in ["before", "after", "after_no_mantle", "after_with_thrusters",
                    "after_no_source", "after_no_jacket", "after_upper_jacket_only",
                    "after_without_upper_jacket", "after_no_jacket_no_harness",
                    "after_no_jacket_no_harness_no_sleeves", "after_original_board"]:
                old.visible = variant == "before"
                hero.visible = variant != "before"
                source_body.visible = variant != "after_no_source"
                fitted_jacket.visible = not variant in ["after_no_jacket",
                    "after_no_jacket_no_harness", "after_no_jacket_no_harness_no_sleeves"]
                harness_mesh.visible = harness_was_visible and not variant in [
                    "after_no_jacket_no_harness", "after_no_jacket_no_harness_no_sleeves"]
                for sleeve_index in range(sleeve_meshes.size()):
                    (sleeve_meshes[sleeve_index] as MeshInstance3D).visible = \
                        sleeves_were_visible[sleeve_index] and \
                        variant != "after_no_jacket_no_harness_no_sleeves"
                # Both modes use the SAME original Skin, pose and camera. Only
                # fragment visibility changes; this is not a game costume edit.
                var isolation_mode := 0
                if variant == "after_upper_jacket_only":
                    isolation_mode = 1
                elif variant == "after_without_upper_jacket":
                    isolation_mode = 2
                jacket_shader.set_shader_parameter("qa_upper_jacket_mode", isolation_mode)
                board.scale = Vector3.ONE if variant in ["before", "after_original_board"] else Vector3(0.80, 1.0, 0.90)
                for mesh in mantle_meshes:
                    mesh.visible = variant != "after_no_mantle"
                for mesh in core_meshes:
                    mesh.visible = variant == "after_with_thrusters"
                old.global_transform = locked_old
                hero.global_transform = locked_hero
                for skeleton_node in bone_locks.keys():
                    var skeleton := skeleton_node as Skeleton3D
                    var poses: Array = bone_locks[skeleton]
                    for bone_id in range(poses.size()):
                        skeleton.set_bone_pose(bone_id, poses[bone_id])
                for frame in range(5):
                    await process_frame
                await RenderingServer.frame_post_draw
                if old.global_transform.origin.distance_to(locked_old.origin) > 0.003 or \
                        hero.global_transform.origin.distance_to(locked_hero.origin) > 0.003:
                    _fail("V123/V124 pose drift invalidates identical-camera visual comparison")
                    return
                var image := viewport.get_texture().get_image()
                if image.is_empty() or image.get_width() != size.x or image.get_height() != size.y:
                    _fail("invalid landscape framebuffer")
                    return
                var filename := "%s/%dx%d_%s_%s.png" % [folder, size.x, size.y, view, variant]
                if image.save_png(filename) != OK:
                    _fail("could not save actual rendered PNG")
                    return
                if variant == "after":
                    compact_board_frame = image
                elif variant == "after_original_board" and view in ["front", "chase"]:
                    var changed := 0
                    for y in range(108):
                        for x in range(192):
                            var px := int(float(size.x - 1) * float(x) / 191.0)
                            var py := int(float(size.y - 1) * float(y) / 107.0)
                            var compact := compact_board_frame.get_pixel(px, py)
                            var original := image.get_pixel(px, py)
                            if absf(compact.r - original.r) + absf(compact.g - original.g) + absf(compact.b - original.b) > 0.16:
                                changed += 1
                    if changed < 70:
                        _fail("CC0 board footprint not visually distinct in %s %s: %d changed samples" % [size, view, changed])
                        return
                    print("CC0 compact-board real landscape changed samples %s %s: %d" % [size, view, changed])
                count += 1
    source_body.visible = true
    fitted_jacket.visible = true
    harness_mesh.visible = harness_was_visible
    for sleeve_index in range(sleeve_meshes.size()):
        (sleeve_meshes[sleeve_index] as MeshInstance3D).visible = sleeves_were_visible[sleeve_index]
    jacket_shader.set_shader_parameter("qa_upper_jacket_mode", 0)
    if count != 132:
        _fail("expected 132 actual paired, upper-jacket, harness and sleeve-isolated landscape images")
        return
    print("QUATERNIUS VISUAL QA PASSED: 132 pose-locked V123/V124, source/jacket/harness/sleeve-isolated, compact-board and costume PNGs (manual quality review still required)")
    quit(0)
