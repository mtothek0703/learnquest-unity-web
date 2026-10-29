extends SceneTree
## V124: all six truly skinned rear-hair surfaces must share one coherent,
## dark mobile PBR finish. This is a material/rig regression, NOT a claim of
## commercial character quality or an iPhone clipping/FPS sign-off.
func _initialize() -> void:
    call_deferred("_check")

func _fail(reason: String) -> void:
    push_error("WEIGHTED HAIR FINISH TEST FAILED: " + reason)
    quit(1)

func _check() -> void:
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    rider.set("prefer_cc0_rigged_hero", true)
    root.add_child(rider)
    await process_frame
    var hero := rider.get_node_or_null("ExternalRiggedHero") as Node3D
    var pose := rider.get_node_or_null("ExternalHeroPose") as Node
    if hero == null or pose == null:
        _fail("original CC0 hero and pose adapter missing")
        return
    var rig := pose.get("skeleton") as Skeleton3D
    if rig == null or rig.get_bone_count() != 65:
        _fail("the 65 imported joints must remain")
        return
    var controller := hero.get_node_or_null("ExternalSkinnedBackHair") as Node
    if controller == null:
        _fail("skinned curtain missing")
        return
    var curtain := controller.get("curtain") as MeshInstance3D
    var weighted := controller.get("weighted_locks") as Node
    if curtain == null or weighted == null:
        _fail("skinned curtain and five skinned locks required")
        return
    var locks: Array = weighted.get("locks")
    if locks.size() != 5:
        _fail("five weighted rear locks required")
        return
    var source := hero.find_child("SuperHero_Male", true, false) as MeshInstance3D
    if source == null or source.skin == null:
        _fail("original imported skin unavailable")
        return
    var materials: Array[ShaderMaterial] = []
    for item in [curtain] + locks:
        var part := item as MeshInstance3D
        if part == null or part.mesh == null or part.skin != source.skin or \
                part.skeleton != source.skeleton or not part.visible:
            _fail("every visible hair volume must use original GPU Skin")
            return
        var mat := part.material_override as ShaderMaterial
        if mat == null or mat.shader == null:
            _fail("every weighted hair volume needs the shared shader")
            return
        if not materials.is_empty() and mat.shader != materials[0].shader:
            _fail("all six hair volumes must use identical shader source")
            return
        var dye: Color = mat.get_shader_parameter("hair_base_tint")
        if dye.r > 0.38 or dye.g > 0.30 or dye.b > 0.32 or \
                dye.r <= 0.0 or dye.g <= 0.0 or dye.b <= 0.0:
            _fail("original dark hair tint missing or bleached")
            return
        var arrays: Array = part.mesh.surface_get_arrays(0)
        var uv: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
        var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
        if uv.size() != vertices.size() or vertices.size() < 500:
            _fail("each skinned hair volume needs real fiber UVs and geometry")
            return
        materials.append(mat)
    var code := materials[0].shader.code
    for required in ["hair_dye = COLOR", "hair_base_tint.rgb",
        "float broad =", "float fibers =", "float directional =",
        "ALBEDO = min(base, original_dye * 1.28)",
        "ROUGHNESS = clamp(", "METALLIC =", "SPECULAR =",
        "smoothstep(0.14, 0.98, UV.y)"]:
        if not code.contains(required):
            _fail("shared root-to-tip fiber PBR shader lost " + required)
            return
    if code.contains("EMISSION =") or code.contains("render_mode unshaded"):
        _fail("hair should use restrained light-reactive PBR, not self-lit strips")
        return
    controller.call("set_motion", 0.75, 1.0, 0.5, 2.0)
    for material in materials:
        if absf(float(material.get_shader_parameter("steer_amount")) - 0.75) > 0.001 or \
                absf(float(material.get_shader_parameter("boost_amount")) - 1.0) > 0.001:
            _fail("all six materials must respond to original action pose")
            return
    if hero.find_children("*", "CollisionObject3D", true, false).size() != 0:
        _fail("material redesign must not add collisions")
        return
    print("WEIGHTED HAIR FINISH TEST PASSED: six genuine 65-bone skinned volumes, dark layered PBR fiber finish, shared shader and wind")
    quit(0)
