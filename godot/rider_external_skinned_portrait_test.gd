extends SceneTree
## Regression: the entire sculpted face must use the imported GPU Skin,
## not just sit rigidly on a Head attachment. No extra face draw call.
func _initialize() -> void:
    call_deferred("_check")

func _fail(reason: String) -> void:
    push_error("TRUE SKINNED PORTRAIT TEST FAILED: " + reason)
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
    var rig := adapter.get("skeleton") as Skeleton3D
    if rig == null or rig.get_bone_count() != 65:
        _fail("original 65-bone rig changed")
        return
    var conversion := hero.get_node_or_null("ExternalTrueSkinnedPortrait") as Node
    if conversion == null:
        _fail("continuous face skin adapter missing")
        return
    var face := conversion.get("face") as MeshInstance3D
    var old := conversion.get("original") as MeshInstance3D
    var source := hero.find_child("SuperHero_Male", true, false) as MeshInstance3D
    if face == null or old == null or source == null or face.mesh == null:
        _fail("continuous portrait replacement incomplete")
        return
    if not face.visible or old.visible or face.skin != source.skin or face.skeleton != source.skeleton:
        _fail("duplicate face or missing original GPU skin")
        return
    if face.get_node_or_null(face.skeleton) != rig:
        _fail("portrait skeleton path does not resolve to imported rig")
        return
    if face.material_override != old.material_override:
        _fail("original painted skin material / face palette lost")
        return
    if face.mesh.get_surface_count() != 1:
        _fail("face must remain a single draw-call surface")
        return
    var arrays: Array = face.mesh.surface_get_arrays(0)
    var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
    var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
    var colors: PackedColorArray = arrays[Mesh.ARRAY_COLOR]
    var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
    var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
    if vertices.size() < 1000 or normals.size() != vertices.size() or colors.size() != vertices.size():
        _fail("continuous 360-degree face lost sculpted geometry / normals / vertex paint")
        return
    if weights.size() != vertices.size() * 4 or bones.size() != vertices.size() * 4:
        _fail("portrait must have exactly four GPU weights per vertex")
        return
    var head_bind := -1
    var neck_bind := -1
    for i in range(source.skin.get_bind_count()):
        if String(source.skin.get_bind_name(i)) == "Head":
            head_bind = i
        if String(source.skin.get_bind_name(i)) == "neck_01":
            neck_bind = i
    if head_bind < 0 or neck_bind < 0:
        _fail("original named Head/Neck binds missing")
        return
    var has_neck := false
    for i in range(vertices.size()):
        var total := 0.0
        for j in range(4):
            var index := i * 4 + j
            if bones[index] < 0 or bones[index] >= source.skin.get_bind_count():
                _fail("invalid original Skin bind")
                return
            total += weights[index]
            if bones[index] == neck_bind and weights[index] > 0.10:
                has_neck = true
        if absf(total - 1.0) > 0.002 or not vertices[i].is_finite() or not normals[i].is_finite():
            _fail("unnormalized or invalid portrait vertex")
            return
    if not has_neck or float(conversion.get("upper_head_weight")) < 0.95 or float(conversion.get("lower_head_weight")) > 0.75:
        _fail("chin must blend to original Neck while crown remains Head-driven")
        return
    var headwear := rig.get_node_or_null("ExternalHeroHeadgear") as BoneAttachment3D
    if headwear == null or headwear.find_child("EyeWhite*", false, false) == null:
        _fail("existing Head-attached animated eyes must remain")
        return
    var head_id := rig.find_bone("Head")
    var before := rig.get_bone_pose_rotation(head_id)
    rider.set("lean", 0.8)
    rider.set("boosting", true)
    adapter.call("_process", 0.3)
    if rig.get_bone_pose_rotation(head_id).angle_to(before) < 0.03:
        _fail("original Head joint must still animate")
        return
    if not hero.find_children("*", "CollisionObject3D", true, false).is_empty():
        _fail("portrait must not add collision/touch objects")
        return
    print("TRUE SKINNED PORTRAIT TEST PASSED: 65 original bones, %d face vertices, four-weight chin and Head skin" % vertices.size())
    quit(0)
