extends SceneTree
## V117: shield, jump, attack and turbo must read as different 3D silhouettes.
func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("POWERUP VFX TEST FAILED: " + message)
    quit(1)

func _validate(mesh: ArrayMesh, minimum_vertices: int, label: String) -> AABB:
    if mesh == null or mesh.get_surface_count() != 1:
        _fail("missing single-batch VFX mesh: " + label)
        return AABB()
    var arrays: Array = mesh.surface_get_arrays(0)
    var points: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
    var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
    var colors: PackedColorArray = arrays[Mesh.ARRAY_COLOR]
    if points.size() < minimum_vertices or normals.size() != points.size() or colors.size() != points.size():
        _fail("insufficient shaded VFX geometry: " + label)
        return AABB()
    return mesh.get_aabb()

func _check() -> void:
    var factory = preload("res://ability_effects.gd")
    var shield: ArrayMesh = factory.shield_mesh()
    var jump: ArrayMesh = factory.jump_mesh()
    var attack: ArrayMesh = factory.attack_mesh()
    var a := _validate(shield, 8000, "shield")
    var b := _validate(jump, 2300, "mega jump")
    var c := _validate(attack, 10900, "super attack")
    if a.size.y < 2.5 or b.size.y < 2.2 or c.size.x < 3.8:
        _fail("shield cage, rising jump helix and radial attack must differ in shape")
        return
    if b.size.y < a.size.y * 0.70 or c.size.y > b.size.y:
        _fail("mega jump must rise, attack must spread")
        return
    var shield_colors: PackedColorArray = shield.surface_get_arrays(0)[Mesh.ARRAY_COLOR]
    var vivid := 0
    for tint in shield_colors:
        if tint.g > 0.90 and tint.a > 0.8:
            vivid += 1
    if vivid < 500:
        _fail("luminous shield cage rails are missing")
        return
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    root.add_child(rider)
    await process_frame
    var wake := rider.get_node_or_null("LegacyRider/Floating hoverboard/Cinematic ion wake") as Node3D
    if wake == null:
        _fail("fourth turbo effect: existing ion wake missing")
        return
    var ribbons: Array = wake.get("wake_roots")
    if ribbons.size() != 2:
        _fail("turbo requires both existing ion trails")
        return
    var before: float = ribbons[0].scale.z
    rider.set("boosting", true)
    var legacy := rider.get_node_or_null("LegacyRider") as Node3D
    legacy.set("boosting", true)
    wake.call("_process", 0.25)
    if ribbons[0].scale.z <= before + 0.1:
        _fail("turbo ion wake must visibly extend during boost")
        return
    if rider.get_node_or_null("ImportedRider/OriginalBodySkinRig/OriginalBodySkeleton13") == null:
        _fail("original 13-bone skinned rider missing")
        return
    if wake.find_children("*", "CollisionObject3D", true, false).size() > 0:
        _fail("power-up visuals must not change physics")
        return
    print("POWERUP VFX TEST PASSED: shield lattice, jump windshear, attack crests and turbo wake remain distinct and collision-free")
    quit(0)
