extends SceneTree
## V119: atmospheric light wells must be rendered, efficient and noninteractive.
func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("CITY LIGHTFIELDS TEST FAILED: " + message)
    quit(1)

func _check() -> void:
    var city := preload("res://neon_environment.gd").new() as Node3D
    root.add_child(city)
    await process_frame
    var lightfields := city.get_node_or_null("Cinematic atmospheric lightfields") as Node3D
    if lightfields == null:
        _fail("Neon City lightfields not integrated")
        return
    var wells: Array = lightfields.get("wells")
    var shafts: Array = lightfields.get("shafts")
    var pools: Array = lightfields.get("pools")
    var lamps: Array = lightfields.get("lamps")
    if wells.size() != 4 or shafts.size() != 4 or pools.size() != 4 or lamps.size() != 4:
        _fail("expected exactly four atmospheric lighting zones")
        return
    var tinted := {}
    for index in range(4):
        var well := wells[index] as Node3D
        if absf(well.position.x) < 8.0:
            _fail("decorative lighting enters playable lanes")
            return
        for mesh_instance in [shafts[index], pools[index]]:
            var instance := mesh_instance as MeshInstance3D
            if instance == null or not instance.mesh is ArrayMesh:
                _fail("missing original gradient mesh")
                return
            var mesh := instance.mesh as ArrayMesh
            if mesh.get_surface_count() != 1:
                _fail("each light volume must be one draw batch")
                return
            var arrays: Array = mesh.surface_get_arrays(0)
            var points: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
            var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
            var colors: PackedColorArray = arrays[Mesh.ARRAY_COLOR]
            if points.size() < 900 or normals.size() != points.size() or colors.size() != points.size():
                _fail("missing volumetric gradient geometry")
                return
            var min_alpha := 1.0
            var max_alpha := 0.0
            for tint in colors:
                min_alpha = minf(min_alpha, tint.a)
                max_alpha = maxf(max_alpha, tint.a)
            if min_alpha > 0.05 or max_alpha < 0.25:
                _fail("lightfield must have transparent edges and a luminous center")
                return
            var material := instance.material_override as StandardMaterial3D
            if material == null or material.transparency != BaseMaterial3D.TRANSPARENCY_ALPHA:
                _fail("lightfield gradient requires actual alpha blending")
                return
        if well.get_node_or_null("Suspended luminous lens") == null:
            _fail("readable suspended emitter is missing")
            return
        var lamp := lamps[index] as OmniLight3D
        if lamp == null or lamp.shadow_enabled or lamp.omni_range > 9.5 or lamp.light_energy > 1.4:
            _fail("mobile lighting budget or shadow rule violated")
            return
        tinted[str(lamp.light_color)] = true
        var shaft_material := (shafts[index] as MeshInstance3D).material_override as StandardMaterial3D
        if shaft_material == null or not shaft_material.emission_enabled or shaft_material.emission.distance_to(lamp.light_color) > 0.02:
            _fail("shaft glow must match its cyan or magenta district lamp")
            return
    if tinted.size() != 2:
        _fail("cyan and magenta accents must remain distinct")
        return
    if lightfields.find_children("*", "CollisionObject3D", true, false).size() > 0:
        _fail("lightfields must not add physics")
        return
    if city.get_node_or_null("Cinematic facade districts") == null:
        _fail("V118 architecture must remain")
        return
    var before: float = wells[0].position.z
    lightfields.set("running", true)
    lightfields.set("travel_speed", 12.0)
    lightfields.call("_process", 0.25)
    if not is_equal_approx(wells[0].position.z, before + 3.0):
        _fail("lighting must move with the scenery")
        return
    lightfields.set("running", false)
    var paused: float = wells[0].position.z
    lightfields.call("_process", 0.5)
    if not is_equal_approx(wells[0].position.z, paused):
        _fail("lighting must pause during vocabulary")
        return
    print("CITY LIGHTFIELDS TEST PASSED: four shadow-free gradient light wells, two colors, zero collisions, paused scrolling")
    quit(0)
