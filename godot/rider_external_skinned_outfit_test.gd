extends SceneTree
## V124: prove new sculpted jacket is a genuine GPU-skinned surface using
## the imported CC0 Skin and bone weights, not a rigid decorative duplicate.
func _initialize() -> void:
    call_deferred("_check")
func _fail(reason: String) -> void:
    push_error("EXTERNAL SKINNED OUTFIT TEST FAILED: " + reason)
    quit(1)
func _check() -> void:
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    rider.set("prefer_cc0_rigged_hero", true)
    root.add_child(rider)
    await process_frame
    var adapter := rider.get_node_or_null("ExternalHeroPose") as Node
    var hero := rider.get_node_or_null("ExternalRiggedHero") as Node3D
    if adapter == null or hero == null:
        _fail("real imported character missing")
        return
    var outfit := hero.get_node_or_null("ExternalSkinnedFlightSuit") as Node
    if outfit == null:
        _fail("jacket extraction controller missing")
        return
    var garment := outfit.get("garment") as MeshInstance3D
    if garment == null or garment.mesh == null or garment.skin == null:
        _fail("weighted jacket geometry was not generated")
        return
    var source := hero.find_child("SuperHero_Male", true, false) as MeshInstance3D
    if source == null or garment.skin != source.skin:
        _fail("jacket must reuse the actual original imported Skin resource")
        return
    if garment.skeleton != source.skeleton or garment.get_parent() != source.get_parent():
        _fail("jacket must deform under the exact same original Skeleton3D")
        return
    var material := garment.material_override as ShaderMaterial
    if material == null or material.shader == null:
        _fail("mobile PBR jacket shader not attached to the real skinned garment")
        return
    var shader_code := material.shader.code
    for required in ["electric_pink", "cobalt", "weave", "EMISSION", "ROUGHNESS"]:
        if not shader_code.contains(required):
            _fail("missing coherent mobile flight-jacket material feature: " + required)
            return
    # New full-torso sculpt must create a genuinely differentiated silhouette,
    # not just recolor the original narrow body or attach rigid shoulder boxes.
    var imported_bounds := source.mesh.get_aabb()
    if absf(float(material.get_shader_parameter("rest_height")) - imported_bounds.size.y) > 0.001 or \
            absf(float(material.get_shader_parameter("rest_width")) - imported_bounds.size.x) > 0.001:
        _fail("jacket color panels must be fitted to the actual CC0 rest bounds")
        return
    var test_bounds := AABB(Vector3(-0.7, 0.0, -0.35), Vector3(1.4, 3.0, 0.7))
    var forward := Vector3(0.0, 0.0, 1.0)
    var chest: Vector3 = outfit.call("_tailored_offset", Vector3(0.10, 1.905, 0.3), forward, test_bounds)
    var waist: Vector3 = outfit.call("_tailored_offset", Vector3(0.10, 1.395, 0.3), forward, test_bounds)
    var shoulder: Vector3 = outfit.call("_tailored_offset", Vector3(0.30, 2.205, 0.3), forward, test_bounds)
    var opposite: Vector3 = outfit.call("_tailored_offset", Vector3(-0.30, 2.205, 0.3), forward, test_bounds)
    if chest.z < waist.z + 0.025 or shoulder.z < waist.z + 0.025:
        _fail("new skinned torso must have sculpted chest/shoulder volume and a tapered waist")
        return
    if shoulder.x < 0.01 or opposite.x > -0.01 or absf(shoulder.x + opposite.x) > 0.002:
        _fail("weighted shoulder expansion must be balanced on both sides")
        return
    # Verify the new V-shaped ridge and collar are actual geometric relief
    # on the original weighted jacket, not a painted texture or rigid prop.
    var ridge: Vector3 = outfit.call("_tailored_offset", Vector3(0.25, 1.905, 0.3),
        forward, test_bounds)
    var ridge_off: Vector3 = outfit.call("_tailored_offset", Vector3(0.42, 1.905, 0.3),
        forward, test_bounds)
    var collar: Vector3 = outfit.call("_tailored_offset", Vector3(0.08, 2.295, 0.3),
        forward, test_bounds)
    var collar_above: Vector3 = outfit.call("_tailored_offset", Vector3(0.08, 2.34, 0.3),
        forward, test_bounds)
    # Compare the same centerline rather than outer shoulder volume, which
    # intentionally rises higher than the collar in the original CC0 shape.
    if ridge.z < ridge_off.z + 0.025 or collar.z < collar_above.z + 0.009:
        _fail("V-yoke and raised collar must have real 3D geometry on the skinned torso")
        return
    var mirrored_ridge: Vector3 = outfit.call("_tailored_offset", Vector3(-0.25, 1.905, 0.3),
        forward, test_bounds)
    if absf(ridge.z - mirrored_ridge.z) > 0.001 or absf(ridge.x + mirrored_ridge.x) > 0.001:
        _fail("skinned jacket V-yoke must remain bilaterally symmetrical")
        return
    # Anatomical shoulder and pectoral relief must exist as actual weighted
    # geometry, not merely new shader colors.
    var pectoral_center: Vector3 = outfit.call("_tailored_offset",
        Vector3(0.238, 1.965, 0.3), forward, test_bounds)
    var pectoral_outer: Vector3 = outfit.call("_tailored_offset",
        Vector3(0.58, 1.965, 0.3), forward, test_bounds)
    var deltoid_top: Vector3 = outfit.call("_tailored_offset",
        Vector3(0.49, 2.145, 0.3), forward, test_bounds)
    var deltoid_lower: Vector3 = outfit.call("_tailored_offset",
        Vector3(0.49, 1.72, 0.3), forward, test_bounds)
    if pectoral_center.z < pectoral_outer.z + 0.04:
        _fail("real skinned jacket must have sculpted pectoral volume")
        return
    if deltoid_top.x < deltoid_lower.x + 0.035:
        _fail("real skinned jacket must have an anatomical shoulder cap")
        return
    if not (garment.material_override as ShaderMaterial).shader.code.contains("pectoral_panel"):
        _fail("chest color panels must follow the sculpted torso")
        return
    if garment.mesh.get_aabb().size.x < imported_bounds.size.x * 0.28:
        _fail("tailored jacket silhouette collapsed")
        return
    var vertex_count := 0
    for surface in range(garment.mesh.get_surface_count()):
        var arrays: Array = garment.mesh.surface_get_arrays(surface)
        var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
        var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
        var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
        if weights.size() < vertices.size() * 4 or bones.size() < vertices.size() * 4:
            _fail("jacket surface has no actual GPU skinning weights")
            return
        for i in range(vertices.size()):
            var total := 0.0
            for j in range(4):
                var index := bones[i * 4 + j]
                if index < 0 or index >= garment.skin.get_bind_count():
                    _fail("jacket bone index outside original Skin")
                    return
                total += weights[i * 4 + j]
            if absf(total - 1.0) > 0.04:
                _fail("jacket weights must stay normalized")
                return
        vertex_count += vertices.size()
    if vertex_count < 300:
        _fail("not enough real sculpted garment geometry")
        return
    if garment.find_children("*", "CollisionObject3D", true, false).size() > 0:
        _fail("visual jacket must not modify game collisions")
        return
    print("EXTERNAL SKINNED OUTFIT TEST PASSED: %d jacket vertices reuse original 65-bone Skin" % vertex_count)
    quit(0)
