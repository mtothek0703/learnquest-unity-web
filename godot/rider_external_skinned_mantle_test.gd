extends SceneTree
## V124 regression: a real imported 65-bone skin drives two broad, split,
## curved flight-mantle panels in the chase view; no rigid/collision fallback.
func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("EXTERNAL SKINNED MANTLE TEST FAILED: " + message)
    quit(1)

func _check() -> void:
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    rider.set("prefer_cc0_rigged_hero", true)
    root.add_child(rider)
    await process_frame
    var hero := rider.get_node_or_null("ExternalRiggedHero") as Node3D
    var pose := rider.get_node_or_null("ExternalHeroPose") as Node
    if hero == null or pose == null:
        _fail("opt-in CC0 character not installed")
        return
    var rig := pose.get("skeleton") as Skeleton3D
    var mantle := hero.get_node_or_null("ExternalSkinnedFlightMantle") as Node
    var source := hero.find_child("SuperHero_Male", true, false) as MeshInstance3D
    if rig == null or rig.get_bone_count() < 60 or mantle == null or source == null:
        _fail("real skeleton, source mesh or split mantle missing")
        return
    var panels: Array = mantle.get("panels")
    if panels.size() != 2 or int(mantle.get("generated_vertices")) < 2000:
        _fail("two substantial curved mesh panels required")
        return
    if float(mantle.get("mantle_span")) < source.mesh.get_aabb().size.y * 0.45:
        _fail("flight mantle does not reach lower silhouette")
        return
    var active_leg_binds := 0
    for panel in panels:
        var mesh := panel as MeshInstance3D
        if mesh == null or mesh.mesh == null or mesh.skin != source.skin:
            _fail("panel does not use the original imported Skin")
            return
        if mesh.skeleton != source.skeleton or mesh.get_parent() != source.get_parent():
            _fail("panel must share source Skeleton3D path and local transform")
            return
        if mesh.get_child_count() != 0 or not (mesh.material_override is ShaderMaterial):
            _fail("panel should be shader-driven cosmetic geometry only")
            return
        var arrays: Array = mesh.mesh.surface_get_arrays(0)
        var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
        var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
        var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
        var uv: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
        if vertices.size() < 1000 or bones.size() != vertices.size() * 4 or weights.size() != vertices.size() * 4 or uv.size() != vertices.size():
            _fail("panel lacks four-weight skinning or UV wind surface")
            return
        var low_count := 0
        for i in range(vertices.size()):
            var total := 0.0
            for j in range(4):
                var index := bones[i * 4 + j]
                var weight := weights[i * 4 + j]
                if index < 0 or index >= source.skin.get_bind_count() or weight < -0.001:
                    _fail("invalid skin bind or negative weight")
                    return
                total += weight
                if j >= 2 and weight > 0.05:
                    active_leg_binds += 1
            if absf(total - 1.0) > 0.001:
                _fail("GPU skin weights not normalized")
                return
            if uv[i].y > 0.9:
                low_count += 1
        if low_count < 50:
            _fail("missing broad trailing hem geometry")
            return
    if active_leg_binds < 100:
        _fail("trailing mantle must actually deform with leg bones")
        return
    if hero.find_children("*", "CollisionObject3D", true, false).size() != 0:
        _fail("new mantle must never modify game collisions")
        return
    var pelvis := rig.find_bone("pelvis")
    var thigh := rig.find_bone("thigh_l")
    if pelvis < 0 or thigh < 0:
        _fail("original pelvis/thigh joints missing")
        return
    var before := rig.get_bone_pose_rotation(thigh)
    rider.set("boosting", true)
    rider.position.y = 0.85
    pose.call("_process", 0.35)
    if rig.get_bone_pose_rotation(thigh).angle_to(before) < 0.03:
        _fail("mantle lower joint must move during jump/boost")
        return
    if rider.get_node_or_null("LegacyRider") == null:
        _fail("legacy fallback and existing hoverboard must remain")
        return
    print("EXTERNAL SKINNED MANTLE TEST PASSED: %d genuine weighted textile vertices on two 65-bone flight panels" % int(mantle.get("generated_vertices")))
    quit(0)
