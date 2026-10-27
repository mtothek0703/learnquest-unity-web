extends SceneTree
## Sprint 1: reproducible, actually RENDERED landscape contact-sheet source.
## Run with a real OpenGL display (xvfb/Mesa in CI), NEVER --headless.
## PNGs are QA evidence, not proof of iPhone FPS or clipping-free geometry.
const SIZES := [Vector2i(1280, 720), Vector2i(1170, 540)]
const VIEWS := ["front", "profile", "chase"]
const POSES := ["idle", "steer_boost", "jump"]

func _initialize() -> void:
    call_deferred("_capture")

func _fail(reason: String) -> void:
    push_error("VISUAL CAPTURE TEST FAILED: " + reason)
    quit(1)

func _camera_position(view: String) -> Vector3:
    match view:
        "front":
            return Vector3(0.0, 2.05, -7.4)
        "profile":
            return Vector3(7.4, 2.05, -0.5)
        _:
            return Vector3(0.0, 2.6, 7.8)

func _apply_pose(rider: Node3D, pose: String) -> void:
    rider.set("lean", 0.0)
    rider.set("boosting", false)
    rider.position.y = 0.0
    if pose == "steer_boost":
        rider.set("lean", 0.95)
        rider.set("boosting", true)
    elif pose == "jump":
        rider.set("lean", -0.65)
        rider.position.y = 0.95
    var model := rider.get_node_or_null("ImportedRider") as Node3D
    if model == null:
        return
    var rig := model.get_node_or_null("OriginalBodySkinRig") as Node3D
    if rig != null:
        rig.call("_process", 0.35)
    var head := model.get_node_or_null("AnimatedHeadKinematics") as Node3D
    if head != null:
        head.call("_process", 0.35)

func _has_visible_subject(image: Image) -> bool:
    if image == null or image.is_empty():
        return false
    var backdrop := image.get_pixel(4, 4)
    var different := 0
    var shades := {}
    # A blank/transparent viewport must never be accepted as visual evidence.
    for row in range(16):
        for col in range(24):
            var x := int(float(image.get_width()) * (0.12 + 0.76 * float(col) / 23.0))
            var y := int(float(image.get_height()) * (0.12 + 0.76 * float(row) / 15.0))
            var pixel := image.get_pixel(x, y)
            if absf(pixel.r - backdrop.r) + absf(pixel.g - backdrop.g) + absf(pixel.b - backdrop.b) > 0.10:
                different += 1
            var key := Vector3i(int(pixel.r * 16.0), int(pixel.g * 16.0), int(pixel.b * 16.0))
            shades[key] = true
    return different >= 18 and shades.size() >= 9

func _capture() -> void:
    var output := OS.get_environment("LEARNQUEST_VISUAL_OUTPUT")
    if output.is_empty():
        output = "/tmp/learnquest-visual-qa"
    if DirAccess.make_dir_recursive_absolute(output) != OK:
        _fail("cannot create screenshot directory: " + output)
        return
    var viewport := SubViewport.new()
    viewport.name = "DeterministicLandscapeCharacterViewport"
    viewport.size = SIZES[0]
    viewport.own_world_3d = true
    viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    root.add_child(viewport)
    var stage := Node3D.new()
    viewport.add_child(stage)
    var world_environment := WorldEnvironment.new()
    var environment := Environment.new()
    environment.background_mode = Environment.BG_COLOR
    environment.background_color = Color(0.035, 0.055, 0.12)
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color(0.56, 0.66, 0.92)
    environment.ambient_light_energy = 0.85
    world_environment.environment = environment
    stage.add_child(world_environment)
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
    camera.near = 0.05
    camera.far = 80.0
    stage.add_child(camera)
    camera.current = true
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    stage.add_child(rider)
    await process_frame
    if rider.get_node_or_null("ImportedRider/OriginalBodySkinRig/OriginalBodySkeleton13") == null:
        _fail("the actual original-body skeleton did not initialize")
        return
    var count := 0
    for size in SIZES:
        viewport.size = size
        for view in VIEWS:
            camera.position = _camera_position(view)
            camera.look_at(Vector3(0.0, 1.7, 0.0), Vector3.UP)
            for pose in POSES:
                _apply_pose(rider, pose)
                for frame in range(4):
                    await process_frame
                await RenderingServer.frame_post_draw
                var image := viewport.get_texture().get_image()
                if image.get_width() != size.x or image.get_height() != size.y:
                    _fail("rendered image has wrong landscape dimensions")
                    return
                if not _has_visible_subject(image):
                    _fail("blank or uninformative rendered image: %s %s %s" % [str(size), view, pose])
                    return
                var filename := "%s/%dx%d_%s_%s.png" % [output, size.x, size.y, view, pose]
                if image.save_png(filename) != OK:
                    _fail("cannot save screenshot: " + filename)
                    return
                count += 1
    if count != 18:
        _fail("expected 18 actual rendered perspective/pose images")
        return
    # Diagnostic close-ups reveal whether a helmet, old glTF or a skin
    # transform hides the new head. These are NOT player-facing screenshots.
    viewport.size = SIZES[0]
    camera.position = Vector3(0.0, 2.5, -3.1)
    camera.look_at(Vector3(0.0, 2.5, 0.0), Vector3.UP)
    _apply_pose(rider, "idle")
    var model := rider.get_node_or_null("ImportedRider") as Node3D
    var helmet := model.get_node_or_null("AnimatedHeadKinematics") as Node3D
    if helmet != null:
        helmet.visible = false
    for frame in range(4):
        await process_frame
    await RenderingServer.frame_post_draw
    var without_helmet := viewport.get_texture().get_image()
    if not _has_visible_subject(without_helmet) or without_helmet.save_png(output + "/diagnostic_front_without_helmet.png") != OK:
        _fail("cannot capture helmet-free face diagnostic")
        return
    if model is MeshInstance3D:
        (model as MeshInstance3D).mesh = null
    for child in model.get_children():
        if child is Node3D and String(child.name) not in ["OriginalBodySkinRig", "SculptedSkinnedFace", "ExpressiveFace"]:
            child.visible = false
    for frame in range(4):
        await process_frame
    await RenderingServer.frame_post_draw
    var face_only := viewport.get_texture().get_image()
    if face_only.save_png(output + "/diagnostic_front_face_only.png") != OK:
        _fail("cannot save skinned-face-only diagnostic")
        return
    if not _has_visible_subject(face_only):
        _fail("skinned face is invisible even with old mesh and helmet removed")
        return
    print("VISUAL CAPTURE TEST PASSED: 20 nonblank rendered PNGs, including 18 landscape gameplay views and 2 head-occlusion diagnostics")
    quit(0)
