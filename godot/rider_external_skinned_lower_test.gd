extends SceneTree
## Regression: imported CC0 lower garments must deform with original 65-bone
## skin, not use rigid capsules or change the existing hoverboard controls.
func _initialize() -> void:
    call_deferred("_check")

func _fail(reason: String) -> void:
    push_error("EXTERNAL SKINNED LOWER TEST FAILED: " + reason)
    quit(1)

func _check() -> void:
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    rider.set("prefer_cc0_rigged_hero", true)
    root.add_child(rider)
    await process_frame
    var adapter := rider.get_node_or_null("ExternalHeroPose") as Node
    var hero := rider.get_node_or_null("ExternalRiggedHero") as Node3D
    if adapter == null or hero == null:
        _fail("opt-in real humanoid not available")
        return
    var lower := hero.get_node_or_null("ExternalSkinnedLowerSuit") as Node
    var source := hero.find_child("SuperHero_Male", true, false) as MeshInstance3D
    if lower == null or source == null:
        _fail("source body or lower suit missing")
        return
    var rig := adapter.get("skeleton") as Skeleton3D
    if rig == null or rig.get_bone_count() < 60:
        _fail("real 65-bone rig missing")
        return
    var combined := 0
    for property_name in ["trousers", "boots"]:
        var garment := lower.get(property_name) as MeshInstance3D
        if garment == null or garment.mesh == null or garment.skin != source.skin:
            _fail(property_name + " does not share original imported Skin")
            return
        if garment.skeleton != source.skeleton or garment.get_parent() != source.get_parent():
            _fail(property_name + " does not use the original Skeleton3D")
            return
        if garment.get_child_count() > 0 or garment.get_node_or_null("CollisionShape3D") != null:
            _fail(property_name + " must be cosmetic only")
            return
        var count := 0
        var leg_influences := 0
        for surface in range(garment.mesh.get_surface_count()):
            var arrays: Array = garment.mesh.surface_get_arrays(surface)
            var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
            var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
            var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
            if bones.size() != verts.size() * 4 or weights.size() != verts.size() * 4:
                _fail(property_name + " is not four-weight skinned")
                return
            for i in range(verts.size()):
                var total := 0.0
                for j in range(4):
                    var index := bones[i * 4 + j]
                    if index < 0 or index >= source.skin.get_bind_count():
                        _fail("out-of-range imported bone bind")
                        return
                    var weight := weights[i * 4 + j]
                    total += weight
                    var name := rig.get_bone_name(source.skin.get_bind_bone(index)).to_lower()
                    if weight > 0.05 and ("thigh" in name or "calf" in name or "foot" in name):
                        leg_influences += 1
                if absf(total - 1.0) > 0.04:
                    _fail(property_name + " weights no longer normalized")
                    return
            count += verts.size()
        if count < 120 or leg_influences < 30:
            _fail(property_name + " is not substantial animated leg geometry")
            return
        combined += count
    var calf := rig.find_bone("calf_l")
    if calf < 0:
        _fail("imported calf bone missing")
        return
    var before := rig.get_bone_pose_rotation(calf)
    rider.set("lean", 0.75)
    rider.set("boosting", true)
    adapter.call("_process", 0.3)
    if rig.get_bone_pose_rotation(calf).angle_to(before) < 0.02:
        _fail("lower-body imported bone did not animate")
        return
    print("EXTERNAL SKINNED LOWER TEST PASSED: %d weighted trouser/boot vertices on original 65-bone Skin" % combined)
    quit(0)
