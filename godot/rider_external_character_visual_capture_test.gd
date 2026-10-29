extends SceneTree
## Render REAL V123 vs V124 16:9 / 19.5:9 frames; not a fake image.
const SIZES := [Vector2i(1280, 720), Vector2i(1170, 540)]
const VIEWS := ["front", "chase", "front_detail", "chase_detail"]
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
            camera.look_at(Vector3(0.0, 1.8 if view.ends_with("detail") else 1.7, 0.0), Vector3.UP)
            for variant in ["before", "after"]:
                old.visible = variant == "before"
                hero.visible = variant == "after"
                for frame in range(5):
                    await process_frame
                await RenderingServer.frame_post_draw
                var image := viewport.get_texture().get_image()
                if image.is_empty() or image.get_width() != size.x or image.get_height() != size.y:
                    _fail("invalid landscape framebuffer")
                    return
                var filename := "%s/%dx%d_%s_%s.png" % [folder, size.x, size.y, view, variant]
                if image.save_png(filename) != OK:
                    _fail("could not save actual rendered PNG")
                    return
                count += 1
    if count != 16:
        _fail("expected sixteen actual wide/detail landscape before/after images")
        return
    print("QUATERNIUS VISUAL QA PASSED: 16 real V123/V124 wide/detail landscape PNGs (manual quality review still required)")
    quit(0)
