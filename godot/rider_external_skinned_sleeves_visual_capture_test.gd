extends SceneTree
## Experimental CC0 sleeves: pose-locked OpenGL frames distinguish original
## imported body, weighted sleeves, and individually isolated costume families
## in both phone ratios. Every family is composited over the same source body.
## A successful render is not a V123 aesthetic or physical-device sign-off.
const SIZES := [Vector2i(1280, 720), Vector2i(1170, 540)]
const VIEWS := ["front", "chase"]
const COSTUME_GROUPS := ["suit_sleeves", "shoulder_thrusters", "pauldrons", "head_hair", "other_costume"]

func _initialize() -> void:
    call_deferred("_capture")

func _fail(reason: String) -> void:
    push_error("SKINNED SLEEVE VISUAL QA FAILED: " + reason)
    quit(1)

# Classify by the actual scene-tree owner, not material color or arbitrary
# mesh names. A pink silhouette can then be traced to its generator without
# modifying a single gameplay mesh, skin weight or collision shape.
func _costume_group(mesh: MeshInstance3D, original: MeshInstance3D) -> String:
    if mesh == original:
        return "source"
    var path := String(mesh.get_path())
    if path.contains("ExternalSkinnedShoulderThrusters"):
        return "shoulder_thrusters"
    if path.contains("ExternalSkinnedFlightPauldrons"):
        return "pauldrons"
    if path.contains("ExternalSkinnedFlightSuit") or path.contains("ExternalSkinnedFlightSleeves"):
        return "suit_sleeves"
    if path.contains("ExternalHeroHeadgear") or path.contains("ExternalSkinnedBackHair") or path.contains("ExternalTrueSkinnedPortrait"):
        return "head_hair"
    return "other_costume"

func _capture() -> void:
    var folder := OS.get_environment("LEARNQUEST_SLEEVES_OUTPUT")
    if folder.is_empty():
        folder = "/tmp/learnquest-sleeves-qa"
    if DirAccess.make_dir_recursive_absolute(folder) != OK:
        _fail("cannot create sleeve screenshot folder")
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
    var adapter := rider.get_node_or_null("ExternalHeroPose") as Node
    if hero == null or adapter == null:
        _fail("original imported CC0 hero missing")
        return
    var rig := adapter.get("skeleton") as Skeleton3D
    var controller := hero.get_node_or_null("ExternalSkinnedFlightSleeves") as Node
    if rig == null or rig.get_bone_count() != 65 or controller == null:
        _fail("original 65-bone Skin and weighted sleeves required")
        return
    var sleeves: Array = controller.get("sleeves")
    var original := hero.find_child("SuperHero_Male", true, false) as MeshInstance3D
    if sleeves.size() != 2 or original == null or original.skin == null:
        _fail("both original-Skin sleeves and imported source mesh required")
        return
    rider.set("lean", 0.65)
    rider.set("boosting", true)
    adapter.call("_process", 0.28)
    for frame in range(6):
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
    # Lock shader TIME as well as the skeleton. Previous cross-run
    # comparisons drifted even when the sleeve geometry was unchanged.
    Engine.time_scale = 0.0
    for frame in range(4):
        await process_frame
    var locked_hero := hero.global_transform
    var locked_bones: Array[Transform3D] = []
    for bone in range(rig.get_bone_count()):
        locked_bones.append(rig.get_bone_pose(bone))
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
            for layer in ["skin_layers", "complete_rider", "source_isolation", "costume_groups"]:
                var variants := ["without_sleeves", "with_sleeves"]
                if layer == "source_isolation":
                    variants = ["source_only", "costume_only"]
                elif layer == "costume_groups":
                    variants = COSTUME_GROUPS
                for variant in variants:
                    for item in visibility.keys():
                        var mesh := item as MeshInstance3D
                        var enabled := bool(visibility[item])
                        if layer == "skin_layers":
                            for keyword in ["Pauldron", "Mantle", "Thruster", "Harness", "Armor"]:
                                if String(mesh.name).contains(keyword):
                                    enabled = false
                                    break
                            enabled = enabled and mesh.skin != null
                        if layer == "source_isolation":
                            # Imported body versus every generated attachment.
                            enabled = mesh == original if variant == "source_only" else \
                                (mesh != original and bool(visibility[item]))
                        elif layer == "costume_groups":
                            # Always keep the identical imported CC0 body as
                            # a reference. Add exactly ONE costume family.
                            # Unlike raw costume-only renders, each pair can
                            # be compared pixel-for-pixel to source_only.
                            enabled = mesh == original or (bool(visibility[item]) and \
                                _costume_group(mesh, original) == variant)
                        elif variant == "without_sleeves" and sleeves.has(mesh):
                            enabled = false
                        mesh.visible = enabled
                    for frame in range(5):
                        hero.global_transform = locked_hero
                        for bone in range(locked_bones.size()):
                            rig.set_bone_pose(bone, locked_bones[bone])
                        await process_frame
                    await RenderingServer.frame_post_draw
                    if hero.global_transform.origin.distance_to(locked_hero.origin) > 0.003:
                        _fail("hero drift invalidates paired sleeve comparison")
                        return
                    var image := viewport.get_texture().get_image()
                    if image.is_empty() or image.get_width() != size.x or image.get_height() != size.y:
                        _fail("invalid smartphone landscape framebuffer")
                        return
                    if image.save_png("%s/%dx%d_%s_%s_%s.png" % [
                            folder, size.x, size.y, view, layer, variant]) != OK:
                        _fail("could not save actual skinned sleeve frame")
                        return
                    count += 1
    for item in visibility.keys():
        (item as MeshInstance3D).visible = bool(visibility[item])
    Engine.time_scale = 1.0
    if count != 44:
        _fail("expected forty-four 16:9/19.5:9 sleeve, source and isolated costume-family frames")
        return
    print("SKINNED SLEEVE VISUAL QA PASSED: 44 pose-locked, shader-time-frozen front/chase frames, including five independent costume-family overlays; manual visual gate remains open")
    quit(0)
