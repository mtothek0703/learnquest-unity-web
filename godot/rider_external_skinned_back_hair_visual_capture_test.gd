extends SceneTree
## Real OpenGL comparison: the SAME V124 character, with rigid Head shell
## versus genuine four-bone skinned rear hair. Two landscape ratios, neutral
## and hard carve+boost, front and chase. Not a manual clipping/FPS approval.
const SIZES := [Vector2i(1280, 720), Vector2i(1170, 540)]
const VIEWS := ["front", "chase"]
const POSES := ["neutral", "carve_boost"]

func _initialize() -> void:
    call_deferred("_capture")

func _fail(reason: String) -> void:
    push_error("SKINNED BACK HAIR VISUAL QA FAILED: " + reason)
    quit(1)

func _capture() -> void:
    var folder := OS.get_environment("LEARNQUEST_SKINNED_HAIR_OUTPUT")
    if folder.is_empty():
        folder = "/tmp/learnquest-skinned-hair-qa"
    if DirAccess.make_dir_recursive_absolute(folder) != OK:
        _fail("hair QA output directory unavailable")
        return
    var viewport := SubViewport.new()
    viewport.size = SIZES[0]
    viewport.own_world_3d = true
    viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    root.add_child(viewport)
    var stage := Node3D.new()
    viewport.add_child(stage)
    var environment := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color(0.035, 0.055, 0.12)
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.56, 0.66, 0.92)
    env.ambient_light_energy = 0.85
    environment.environment = env
    stage.add_child(environment)
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
    var hero := rider.get_node_or_null("ExternalRiggedHero") as Node3D
    var adapter := rider.get_node_or_null("ExternalHeroPose") as Node
    if hero == null or adapter == null:
        _fail("genuine CC0 hero missing")
        return
    var rig := adapter.get("skeleton") as Skeleton3D
    var headwear := rig.get_node_or_null("ExternalHeroHeadgear") as BoneAttachment3D
    var original := headwear.get_node_or_null("SculptedBackHairCurtain") as MeshInstance3D
    var skinned := hero.find_child("TrueSkinnedBackHairCurtain", true, false) as MeshInstance3D
    if original == null or skinned == null or skinned.skin == null:
        _fail("rigid and weighted hair must both exist for direct comparison")
        return
    var wind_controller := hero.get_node_or_null("ExternalSkinnedBackHair") as Node
    var lock_controller: Node
    if wind_controller != null:
        lock_controller = wind_controller.get("weighted_locks") as Node
    if lock_controller == null:
        _fail("all five weighted hair locks required for real rigid-vs-skinned visual QA")
        return
    var weighted_locks: Array = lock_controller.get("locks")
    var rigid_locks: Array = lock_controller.get("originals")
    if weighted_locks.size() != 5 or rigid_locks.size() != 5:
        _fail("incomplete five-lock weighted hair visual comparison")
        return
    rider.set_process(false)
    adapter.set_process(false)
    var count := 0
    var changed_chase := 0
    var bleached_hair := 0
    var sampled_hair := 0
    for pose_name in POSES:
        rider.set("lean", 0.0)
        rider.set("boosting", false)
        rider.position.y = 0.0
        if pose_name == "carve_boost":
            rider.set("lean", 0.90)
            rider.set("boosting", true)
            rider.position.y = 0.65
        adapter.call("_process", 0.35)
        for size in SIZES:
            viewport.size = size
            for view in VIEWS:
                camera.position = Vector3(0.0, 2.0, -5.2) if view == "front" else Vector3(0.0, 2.25, 5.4)
                camera.look_at(Vector3(0.0, 1.8, 0.0), Vector3.UP)
                var before: Image
                for variant in ["rigid", "skinned"]:
                    original.visible = variant == "rigid"
                    skinned.visible = variant == "skinned"
                    for i in range(5):
                        (rigid_locks[i] as MeshInstance3D).visible = variant == "rigid"
                        (weighted_locks[i] as MeshInstance3D).visible = variant == "skinned"
                    for frame in range(5):
                        await process_frame
                    await RenderingServer.frame_post_draw
                    var picture := viewport.get_texture().get_image()
                    if picture.is_empty() or picture.get_width() != size.x or picture.get_height() != size.y:
                        _fail("invalid landscape framebuffer")
                        return
                    var filename := "%s/%dx%d_%s_%s_%s.png" % [
                        folder, size.x, size.y, pose_name, view, variant]
                    if picture.save_png(filename) != OK:
                        _fail("could not save actual hair image")
                        return
                    if variant == "rigid":
                        before = picture
                    elif view == "chase" and pose_name == "carve_boost":
                        for y in range(0, size.y, 6):
                            for x in range(0, size.x, 6):
                                var a := picture.get_pixel(x, y)
                                var b := before.get_pixel(x, y)
                                var diff := maxf(absf(a.r - b.r),
                                    maxf(absf(a.g - b.g), absf(a.b - b.b)))
                                if diff > 0.08:
                                    changed_chase += 1
                        # Real chase images caught a shader regression that
                        # painted the old dark underhair nearly white. Compare
                        # the same upper-center hair region in both frames.
                        for y in range(int(size.y * 0.04), int(size.y * 0.15), 4):
                            for x in range(int(size.x * 0.44), int(size.x * 0.56), 4):
                                var current := picture.get_pixel(x, y)
                                var previous := before.get_pixel(x, y)
                                sampled_hair += 1
                                if current.get_luminance() - previous.get_luminance() > 0.35:
                                    bleached_hair += 1
                    count += 1
    # Hold the same original 65-bone action pose, camera and lighting, then
    # change ONLY the weighted curtain's GPU wind parameters. These two
    # extra frames prove secondary motion is visible, not just a uniform set.
    original.visible = false
    skinned.visible = true
    for i in range(5):
        (rigid_locks[i] as MeshInstance3D).visible = false
        (weighted_locks[i] as MeshInstance3D).visible = true
    var wind := hero.get_node_or_null("ExternalSkinnedBackHair") as Node
    if wind == null or wind.get("wind_material") == null:
        _fail("original GPU-skinned wind material unavailable")
        return
    viewport.size = SIZES[0]
    camera.position = Vector3(0.0, 2.25, 5.4)
    camera.look_at(Vector3(0.0, 1.8, 0.0), Vector3.UP)
    var still: Image
    var changed_wind := 0
    for state in ["still", "wind"]:
        if state == "still":
            wind.call("set_motion", 0.0, 0.0, 0.0, 2.0)
        else:
            wind.call("set_motion", 0.95, 1.0, 0.6, 2.0)
        for frame in range(5):
            await process_frame
        await RenderingServer.frame_post_draw
        var shot := viewport.get_texture().get_image()
        if shot.is_empty() or shot.get_width() != 1280 or shot.get_height() != 720:
            _fail("invalid GPU hair wind landscape framebuffer")
            return
        if shot.save_png("%s/1280x720_carve_chase_hair_%s.png" % [folder, state]) != OK:
            _fail("cannot save weighted hair wind comparison")
            return
        if state == "still":
            still = shot
        else:
            # Restrict the motion proof to the upper-center head/hair ROI.
            # Animated board jets below the waist must not count as hair wind.
            for y in range(0, int(720 * 0.22), 4):
                for x in range(int(1280 * 0.38), int(1280 * 0.62), 4):
                    var a := shot.get_pixel(x, y)
                    var b := still.get_pixel(x, y)
                    if maxf(absf(a.r - b.r), maxf(absf(a.g - b.g), absf(a.b - b.b))) > 0.08:
                        changed_wind += 1
        count += 1
    wind.call("set_motion", 0.0, 0.0, 0.0, 0.0)
    if count != 18 or changed_chase < 12 or changed_wind < 8 or \
            bleached_hair > int(sampled_hair * 0.20):
        _fail("expected 18 frames, visible wind and no white hair regression: %d %d %d/%d" % [changed_chase, changed_wind, bleached_hair, sampled_hair])
        return
    print("SKINNED BACK HAIR VISUAL QA PASSED: 18 real landscape images, including all five four-weight locks and isolated weighted-hair wind; manual clipping and iPhone FPS still required")
    quit(0)
