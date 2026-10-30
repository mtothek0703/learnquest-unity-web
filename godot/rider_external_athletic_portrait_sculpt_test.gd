extends SceneTree
## V124: real anatomical profile QA for the sculpted, four-weight skinned
## 360-degree face. Geometric checks do not replace manual mobile visual QA.

func _initialize() -> void:
    call_deferred("_check")

func _fail(reason: String) -> void:
    push_error("ATHLETIC PORTRAIT SCULPT TEST FAILED: " + reason)
    quit(1)

func _check() -> void:
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    rider.set("prefer_cc0_rigged_hero", true)
    root.add_child(rider)
    await process_frame
    var adapter := rider.get_node_or_null("ExternalHeroPose") as Node
    var hero := rider.get_node_or_null("ExternalRiggedHero") as Node3D
    if adapter == null or hero == null:
        _fail("real imported skinned hero missing")
        return
    var rig := adapter.get("skeleton") as Skeleton3D
    if rig == null or rig.get_bone_count() != 65:
        _fail("original 65-bone Skeleton3D must be preserved")
        return
    var head := rig.get_node_or_null("ExternalHeroHeadgear") as BoneAttachment3D
    var conversion := hero.get_node_or_null("ExternalTrueSkinnedPortrait") as Node
    var source := hero.find_child("SuperHero_Male", true, false) as MeshInstance3D
    if head == null or conversion == null or source == null:
        _fail("sculpted Head and true original-Skin conversion missing")
        return
    var face := conversion.get("face") as MeshInstance3D
    var rigid := conversion.get("original") as MeshInstance3D
    if face == null or rigid == null or face.mesh == null or face.skin != source.skin:
        _fail("facial sculpt must remain genuinely GPU-skinned")
        return
    if rigid.visible or not face.visible or face.skeleton != source.skeleton:
        _fail("duplicate rigid face or lost original skeleton")
        return
    var bounds: AABB = head.get("head_bounds")
    var c := bounds.get_center()
    var s := bounds.size
    var forward := float(head.get("face_sign"))
    var front_u := 0.25 if forward > 0.0 else 0.75
    var back_u := 0.75 if forward > 0.0 else 0.25
    var nose: Vector3 = head.call("_face_point", c, s, front_u, 0.59)
    var nose_y := c.y + cos(0.59 * PI) * s.y * 0.48
    var cheek: Vector3 = head.call("_face_front_point", c, s, c.x + s.x * 0.285, nose_y)
    var outer: Vector3 = head.call("_face_front_point", c, s, c.x + s.x * 0.42, nose_y)
    if forward * (nose.z - cheek.z) < s.z * 0.045:
        _fail("nose bridge and tip have no modeled forward profile")
        return
    if forward * (cheek.z - outer.z) < s.z * 0.015:
        _fail("cheekbone relief must remain distinct from jaw/temple edge")
        return
    var jaw_left: Vector3 = head.call("_face_point", c, s, 0.0, 0.78)
    var jaw_right: Vector3 = head.call("_face_point", c, s, 0.5, 0.78)
    var temple: Vector3 = head.call("_face_point", c, s, 0.0, 0.49)
    if absf(jaw_left.x - c.x) < s.x * 0.25 or             absf(jaw_left.x - c.x) > absf(temple.x - c.x) * 0.91:
        _fail("athletic jaw must be tapered but not pinched")
        return
    if absf(jaw_left.x + jaw_right.x - 2.0 * c.x) > 0.0005:
        _fail("sculpted head must remain bilaterally symmetric")
        return
    var forehead: Vector3 = head.call("_face_point", c, s, front_u, 0.35)
    var rear: Vector3 = head.call("_face_point", c, s, back_u, 0.50)
    if forward * (forehead.z - rear.z) < s.z * 0.65:
        _fail("360-degree head lost real front-to-back cranial volume")
        return
    for u in [0.0, 0.13, 0.25, 0.37, 0.5, 0.75, 0.91]:
        for v in [0.12, 0.35, 0.48, 0.59, 0.78, 0.91]:
            var point: Vector3 = head.call("_face_point", c, s, u, v)
            var normal: Vector3 = head.call("_face_normal", c, s, u, v)
            if not point.is_finite() or not normal.is_finite() or absf(normal.length() - 1.0) > 0.03:
                _fail("non-finite anatomical point or non-unit smooth normal")
                return
    var arrays: Array = face.mesh.surface_get_arrays(0)
    var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
    var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
    if verts.size() < 5000 or weights.size() != verts.size() * 4:
        _fail("sculpted facial anatomy lost continuous original four-weight geometry")
        return
    if head.find_child("EyeWhite*", false, false) == null or             head.get_node_or_null("CurvedSmile") == null:
        _fail("existing animated eye and mouth landmarks lost")
        return
    if not hero.find_children("*", "CollisionObject3D", true, false).is_empty():
        _fail("visual face resculpt must not change touch or collision physics")
        return
    print("ATHLETIC PORTRAIT SCULPT TEST PASSED: organic cheek/nose/jaw relief, smooth normals, 65-bone original Skin, 360-degree surface")
    quit(0)
