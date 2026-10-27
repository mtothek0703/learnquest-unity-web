extends SceneTree
## V117: actual rendered, reproducible 16:9 screenshots of all four powers.
## Requires xvfb/Mesa OpenGL. Not a real-phone FPS certification.
const OUTPUT_SIZE := Vector2i(1280, 720)
const POWERS := ["shield", "mega_jump", "attack", "turbo"]
const VIEWS := ["front", "chase"]

func _initialize() -> void:
    call_deferred("_capture")

func _fail(message: String) -> void:
    push_error("POWERUP VISUAL QA FAILED: " + message)
    quit(1)

func _capture() -> void:
    var output := OS.get_environment("LEARNQUEST_POWERUP_OUTPUT")
    if output.is_empty():
        output = "/tmp/learnquest-powerup-qa"
    if DirAccess.make_dir_recursive_absolute(output) != OK:
        _fail("cannot create output directory")
        return
    var viewport := SubViewport.new()
    viewport.size = OUTPUT_SIZE
    viewport.own_world_3d = true
    viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    root.add_child(viewport)
    var stage := Node3D.new()
    viewport.add_child(stage)
    var environment := WorldEnvironment.new()
    var resource := Environment.new()
    resource.background_mode = Environment.BG_COLOR
    resource.background_color = Color("#090f29")
    resource.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    resource.ambient_light_color = Color("#9bb4e0")
    resource.ambient_light_energy = 0.95
    environment.environment = resource
    stage.add_child(environment)
    var light := DirectionalLight3D.new()
    light.rotation_degrees = Vector3(-40, -25, 0)
    light.light_energy = 1.6
    stage.add_child(light)
    var camera := Camera3D.new()
    camera.fov = 48.0
    camera.near = 0.05
    stage.add_child(camera)
    camera.current = true
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    stage.add_child(rider)
    await process_frame
    var factory = preload("res://ability_effects.gd")
    var effects := {}
    for power in ["shield", "mega_jump", "attack"]:
        var effect := MeshInstance3D.new()
        effect.name = power
        match power:
            "shield":
                effect.mesh = factory.shield_mesh()
                effect.position.y = 1.35
                effect.material_override = factory.effect_material(Color("#28bdf7"), 0.36)
            "mega_jump":
                effect.mesh = factory.jump_mesh()
                effect.position.y = 0.20
                effect.material_override = factory.effect_material(Color("#ffcd53"), 0.88)
            "attack":
                effect.mesh = factory.attack_mesh()
                effect.position.y = 1.30
                effect.material_override = factory.effect_material(Color("#f347b7"), 0.88)
                effect.scale = Vector3.ONE * 1.45
        rider.add_child(effect)
        effect.visible = false
        effects[power] = effect
    var legacy := rider.get_node("LegacyRider") as Node3D
    var wake := rider.get_node("LegacyRider/Floating hoverboard/Cinematic ion wake") as Node3D
    var count := 0
    for view in VIEWS:
        camera.position = Vector3(0, 2.2, -7.0) if view == "front" else Vector3(0, 2.6, 7.8)
        camera.look_at(Vector3(0, 1.5, 0), Vector3.UP)
        for power in POWERS:
            for item in effects.values():
                (item as MeshInstance3D).visible = false
            rider.set("boosting", power == "turbo")
            legacy.set("boosting", power == "turbo")
            if effects.has(power):
                (effects[power] as MeshInstance3D).visible = true
            wake.call("_process", 0.55)
            for frame in range(5):
                await process_frame
            await RenderingServer.frame_post_draw
            var picture := viewport.get_texture().get_image()
            if picture.get_width() != OUTPUT_SIZE.x or picture.get_height() != OUTPUT_SIZE.y:
                _fail("incorrect landscape frame size")
                return
            var filename := "%s/%s_%s.png" % [output, view, power]
            if picture.save_png(filename) != OK:
                _fail("cannot save " + filename)
                return
            count += 1
    if count != 8:
        _fail("expected eight distinct power-up views")
        return
    print("POWERUP VISUAL QA PASSED: eight rendered 1280x720 front/chase images for all four powers")
    quit(0)
