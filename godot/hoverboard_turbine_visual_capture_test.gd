extends SceneTree
## V124: real 16:9 and 19.5:9 before/after frames of the sculpted board
## propulsion upgrade. Before hides only the new turbines and halos; every
## original hoverboard, rider, gameplay and touch node remains identical.
const SIZES := [Vector2i(1280, 720), Vector2i(1170, 540)]
const VIEWS := ["front", "chase"]
const PARTS := ["PortSculptedTurbine", "StarboardSculptedTurbine",
    "PortExhaustHalo", "StarboardExhaustHalo"]

func _initialize() -> void:
    call_deferred("_capture")

func _fail(message: String) -> void:
    push_error("TURBINE VISUAL QA FAILED: " + message)
    quit(1)

func _capture() -> void:
    var folder := OS.get_environment("LEARNQUEST_TURBINE_OUTPUT")
    if folder.is_empty():
        folder = "/tmp/learnquest-turbine-qa"
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
    var key_light := DirectionalLight3D.new()
    key_light.rotation_degrees = Vector3(-35.0, -35.0, 0.0)
    key_light.light_energy = 1.6
    stage.add_child(key_light)
    var rim := DirectionalLight3D.new()
    rim.rotation_degrees = Vector3(-18.0, 145.0, 0.0)
    rim.light_color = Color(0.33, 0.84, 1.0)
    rim.light_energy = 0.85
    stage.add_child(rim)
    var camera := Camera3D.new()
    camera.fov = 42.0
    stage.add_child(camera)
    camera.current = true
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    stage.add_child(rider)
    await process_frame
    var board := rider.get_node_or_null("LegacyRider/Floating hoverboard/SculptedHoverboardChassis") as Node3D
    if board == null or not bool(board.get("built")):
        _fail("original hoverboard and sculpted upgrade must exist")
        return
    var new_parts: Array[MeshInstance3D] = []
    for part_name in PARTS:
        var part := board.get_node_or_null(part_name) as MeshInstance3D
        if part == null or part.mesh == null:
            _fail("missing propulsion mesh: " + part_name)
            return
        new_parts.append(part)
    # A/B the actual silhouette cleanup in the same scene and camera.
    # "legacy_before" restores only the six superseded original meshes;
    # "clean_after" shows the new closed turbines and articulated fins alone.
    var old_parts: Array[Node3D] = []
    var original_board := board.get_parent() as Node3D
    for old_name in ["LegacyPortTurbine", "LegacyStarboardTurbine",
            "LegacyPortVerticalFin", "LegacyStarboardVerticalFin"]:
        var old_part := original_board.get_node_or_null(old_name) as Node3D
        if old_part == null or old_part.visible:
            _fail("original duplicate must exist but be retired: " + old_name)
            return
        old_parts.append(old_part)
    var count := 0
    for size in SIZES:
        viewport.size = size
        for view in VIEWS:
            camera.position = Vector3(0.0, 1.65, -5.6) if view == "front" else Vector3(0.0, 1.95, 5.6)
            camera.look_at(Vector3(0.0, 0.8, 0.0), Vector3.UP)
            for variant in ["before", "after"]:
                for part in new_parts:
                    part.visible = variant == "after"
                for frame in range(5):
                    await process_frame
                await RenderingServer.frame_post_draw
                var image := viewport.get_texture().get_image()
                if image.is_empty() or image.get_width() != size.x or image.get_height() != size.y:
                    _fail("invalid landscape framebuffer")
                    return
                if image.save_png("%s/%dx%d_%s_%s.png" % [folder, size.x, size.y, view, variant]) != OK:
                    _fail("could not save rendered comparison frame")
                    return
                count += 1
            # Compare the original redundant primitive geometry with the
            # actual cleaner silhouette, while retaining all new turbine parts.
            for part in new_parts:
                part.visible = true
            for variant in ["legacy_before", "clean_after"]:
                for old_part in old_parts:
                    old_part.visible = variant == "legacy_before"
                for frame in range(5):
                    await process_frame
                await RenderingServer.frame_post_draw
                var cleanup_image := viewport.get_texture().get_image()
                if cleanup_image.is_empty() or cleanup_image.get_width() != size.x or cleanup_image.get_height() != size.y:
                    _fail("invalid hoverboard cleanup landscape framebuffer")
                    return
                if cleanup_image.save_png("%s/%dx%d_%s_%s.png" % [folder, size.x, size.y, view, variant]) != OK:
                    _fail("could not save hoverboard cleanup comparison")
                    return
                count += 1
    for part in new_parts:
        part.visible = true
    for old_part in old_parts:
        old_part.visible = false
    if count != 16:
        _fail("expected sixteen real landscape turbine and cleanup images")
        return
    print("TURBINE VISUAL QA PASSED: 16 actual landscape turbine/legacy-cleanup frames; visual approval remains manual")
    quit(0)
