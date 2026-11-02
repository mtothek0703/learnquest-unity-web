extends SceneTree
## V124 geometry regression: original imported CC0 source mesh is sculpted
## in-place at runtime, not replaced by rigid primitive torso attachments.
func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("CONTINUOUS BODY RESCULPT TEST FAILED: " + message)
    quit(1)

func _check() -> void:
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    rider.set("prefer_cc0_rigged_hero", true)
    root.add_child(rider)
    await process_frame
    var hero := rider.get_node_or_null("ExternalRiggedHero") as Node3D
    var pose := rider.get_node_or_null("ExternalHeroPose") as Node
    if hero == null or pose == null:
        _fail("real imported rider or pose missing")
        return
    var rig := pose.get("skeleton") as Skeleton3D
    var body := hero.find_child("SuperHero_Male", true, false) as MeshInstance3D
    var sculpt := hero.get_node_or_null("ExternalContinuousBodySculpt") as Node
    if rig == null or rig.get_bone_count() != 65 or body == null or sculpt == null:
        _fail("65 original bones or integrated source-body sculpt missing")
        return
    var before := sculpt.get("source_mesh") as Mesh
    var after := body.mesh
    if before == null or after == null or before == after or body.skin == null:
        _fail("source body must be a separate, genuinely GPU-skinned mesh copy")
        return
    if before.get_surface_count() != after.get_surface_count():
        _fail("original source draw-call count changed")
        return
    var changed := 0
    var checked := 0
    for surface in range(before.get_surface_count()):
        var old: Array = before.surface_get_arrays(surface)
        var new: Array = after.surface_get_arrays(surface)
        var original: PackedVector3Array = old[Mesh.ARRAY_VERTEX]
        var reshaped: PackedVector3Array = new[Mesh.ARRAY_VERTEX]
        var normals: PackedVector3Array = new[Mesh.ARRAY_NORMAL]
        if original.size() != reshaped.size() or normals.size() != original.size():
            _fail("sculpt lost original source topology or smooth normals")
            return
        if old[Mesh.ARRAY_BONES] != new[Mesh.ARRAY_BONES] or \
                old[Mesh.ARRAY_WEIGHTS] != new[Mesh.ARRAY_WEIGHTS] or \
                old[Mesh.ARRAY_INDEX] != new[Mesh.ARRAY_INDEX]:
            _fail("sculpt changed original four-weight Skin or triangle indices")
            return
        for i in range(original.size()):
            var delta := reshaped[i] - original[i]
            if delta.y > 0.000001 or delta.y < -before.get_aabb().size.y * 0.033 or \
                    not reshaped[i].is_finite() or \
                    not normals[i].is_finite() or absf(normals[i].length() - 1.0) > 0.002:
                _fail("invalid rest vertex, vertical foot-contact drift or lighting normal")
                return
            if delta.length() > before.get_aabb().size.x * 0.115:
                _fail("sculpt exceeds safe original-skeleton deformation envelope")
                return
            if delta.length_squared() > 0.00000001:
                changed += 1
            checked += 1
    if checked < 1000 or changed < 200 or \
            changed != int(sculpt.get("sculpted_vertices")) or \
            checked != int(sculpt.get("source_vertices")):
        _fail("source mesh not significantly reshaped / reported counts invalid")
        return
    var bounds := before.get_aabb()
    var center := bounds.get_center()
    var x := bounds.size.x * 0.13
    var chest := Vector3(center.x + x, bounds.position.y + bounds.size.y * 0.665, center.z + bounds.size.z * 0.18)
    var waist := Vector3(center.x + x, bounds.position.y + bounds.size.y * 0.465, center.z + bounds.size.z * 0.18)
    var shoulder := Vector3(center.x + x, bounds.position.y + bounds.size.y * 0.738, center.z + bounds.size.z * 0.18)
    var head := Vector3(center.x + x, bounds.position.y + bounds.size.y * 0.92, center.z)
    var foot := Vector3(center.x + x, bounds.position.y + bounds.size.y * 0.10, center.z)
    var chest_after: Vector3 = sculpt.call("_reshape", chest, bounds)
    var waist_after: Vector3 = sculpt.call("_reshape", waist, bounds)
    # The new athletic source chest must be materially closer to the CC0
    # imported rest mesh in both axes, not merely recolored or covered up.
    # Former 15%/12% pectoral inflation exceeds these conservative bounds.
    if chest_after.x - chest.x > bounds.size.x * 0.012 or \
            chest_after.z - chest.z > bounds.size.z * 0.015:
        _fail("original source chest still has inflated toy-like pectoral volume")
        return
    if chest_after.x <= chest.x + 0.007 or waist_after.x >= waist.x - 0.008:
        _fail("sculpt must create athletic chest-to-waist taper on original triangles")
        return
    # Regression for the full torso redesign, not only a tiny collar change:
    # the original four-weight source skin must narrow through the waist AND
    # lower ribs while retaining the existing broader athletic chest.
    var lower_rib := Vector3(center.x + x,
        bounds.position.y + bounds.size.y * 0.560, chest.z)
    var rib_after: Vector3 = sculpt.call("_reshape", lower_rib, bounds)
    if waist.x - waist_after.x < bounds.size.x * 0.014 or \
            lower_rib.x - rib_after.x < bounds.size.x * 0.007:
        _fail("source-skinned torso lacks a continuous chest-to-waist taper")
        return
    # The old extra 24% shoulder expansion inflated the CC0 body's upper
    # trapezius into a horizontal bar, visible even in source-only captures.
    # Protect the slimmer real shoulder contour, not just a material change.
    var shoulder_after: Vector3 = sculpt.call("_reshape", shoulder, bounds)
    var shoulder_gain := shoulder_after.x - shoulder.x
    var chest_gain := chest_after.x - chest.x
    if shoulder_gain < 0.005 or shoulder_gain >= chest_gain * 0.90:
        _fail("original weighted shoulder contour is still overinflated or collapsed")
        return
    if shoulder_after.z - shoulder.z >= chest_after.z - chest.z:
        _fail("original shoulder depth still balloons beyond the sculpted chest")
        return
    # Isolated source-only frames showed the OUTER original deltoid, not
    # the overlaid graphite armor, still forming a wide shoulder shelf.
    # Verify actual rest-space vertex contraction, bilateral symmetry,
    # armpit falloff and unchanged hands on the original 65-bone mesh.
    var outer_right := Vector3(center.x + bounds.size.x * 0.275,
        bounds.position.y + bounds.size.y * 0.738,
        center.z + bounds.size.z * 0.18)
    var outer_left := Vector3(center.x - bounds.size.x * 0.275,
        outer_right.y, outer_right.z)
    var tapered_right: Vector3 = sculpt.call("_reshape", outer_right, bounds)
    var tapered_left: Vector3 = sculpt.call("_reshape", outer_left, bounds)
    if outer_right.x - tapered_right.x < bounds.size.x * 0.026 or \
            outer_right.z - tapered_right.z < bounds.size.z * 0.006:
        _fail("original outer deltoid must narrow in both real geometry axes")
        return
    if absf(tapered_right.x + tapered_left.x - 2.0 * center.x) > 0.00001 or \
            absf(tapered_right.z - tapered_left.z) > 0.00001:
        _fail("source-skinned deltoid tailoring must be bilaterally symmetric")
        return
    var armpit := Vector3(outer_right.x,
        bounds.position.y + bounds.size.y * 0.60, outer_right.z)
    # The previous narrow mask missed the outer source-shoulder vertices.
    # Require a meaningful inward movement near the visible shoulder edge.
    var shoulder_edge := Vector3(center.x + bounds.size.x * 0.39,
        outer_right.y, outer_right.z)
    var shoulder_edge_after: Vector3 = sculpt.call("_reshape", shoulder_edge, bounds)
    if shoulder_edge.x - shoulder_edge_after.x < bounds.size.x * 0.055:
        _fail("outer source shoulder shelf remains too wide in rest geometry")
        return
    var hand_tip := Vector3(center.x + bounds.size.x * 0.45,
        bounds.position.y + bounds.size.y * 0.50, outer_right.z)
    if (sculpt.call("_reshape", armpit, bounds) as Vector3).distance_to(armpit) > \
            bounds.size.x * 0.0001 or \
            (sculpt.call("_reshape", hand_tip, bounds) as Vector3).distance_to(hand_tip) > 0.00001:
        _fail("shoulder taper must fade before armpit and outer hand")
        return
    # Check the original 65-bone neck band rather than a hidden collar prop.
    # The source neckline now tucks in bilaterally at the real shoulder-to-head
    # transition, but leaves chest, hands, head and hoverboard contact intact.
    var neck_right := Vector3(center.x + bounds.size.x * 0.18,
        bounds.position.y + bounds.size.y * 0.815, center.z + bounds.size.z * 0.18)
    var neck_left := Vector3(center.x - bounds.size.x * 0.18,
        neck_right.y, neck_right.z)
    var neck_right_after: Vector3 = sculpt.call("_reshape", neck_right, bounds)
    var neck_left_after: Vector3 = sculpt.call("_reshape", neck_left, bounds)
    if neck_right.x - neck_right_after.x < bounds.size.x * 0.016 or \
            neck_right.z - neck_right_after.z < bounds.size.z * 0.005:
        _fail("real original-skin neckline still forms a wide shoulder shelf")
        return
    if absf(neck_right_after.x + neck_left_after.x - 2.0 * center.x) > 0.00001 or \
            absf(neck_right_after.z - neck_left_after.z) > 0.00001:
        _fail("original neck sculpt must remain symmetric")
        return
    var face_base := Vector3(neck_right.x,
        bounds.position.y + bounds.size.y * 0.93, neck_right.z)
    if (sculpt.call("_reshape", face_base, bounds) as Vector3).distance_to(face_base) > 0.0001:
        _fail("neck tailoring must not deform the head/face")
        return
    # A true sloped shoulder must descend away from the neck in the original
    # rest-space triangles, not be simulated with a painted collar highlight.
    var slope_edge := Vector3(center.x + bounds.size.x * 0.34,
        bounds.position.y + bounds.size.y * 0.738, center.z + bounds.size.z * 0.18)
    var slope_center := Vector3(center.x + bounds.size.x * 0.10,
        slope_edge.y, slope_edge.z)
    var sloped: Vector3 = sculpt.call("_reshape", slope_edge, bounds)
    var centered: Vector3 = sculpt.call("_reshape", slope_center, bounds)
    if slope_edge.y - sloped.y < bounds.size.y * 0.020 or \
            absf(slope_center.y - centered.y) > bounds.size.y * 0.001:
        _fail("real 65-bone shoulder must slope downward without moving the neck")
        return
    # Bilateral side-profile correction must actually recede the imported
    # front pectoral surface while preserving the rear and face/hand/feet.
    var front_chest := Vector3(center.x + bounds.size.x * 0.09,
        bounds.position.y + bounds.size.y * 0.645,
        center.z - bounds.size.z * 0.40)
    var back_chest := Vector3(front_chest.x, front_chest.y,
        center.z + bounds.size.z * 0.40)
    var mirror_front := Vector3(2.0 * center.x - front_chest.x,
        front_chest.y, front_chest.z)
    var recessed_front: Vector3 = sculpt.call("_reshape", front_chest, bounds)
    var sculpted_back: Vector3 = sculpt.call("_reshape", back_chest, bounds)
    var recessed_mirror: Vector3 = sculpt.call("_reshape", mirror_front, bounds)
    if recessed_front.z - front_chest.z < bounds.size.z * 0.050 or \
            absf(sculpted_back.z - back_chest.z) > bounds.size.z * 0.040:
        _fail("source-skinned pectoral profile must recede in front without flattening the back")
        return
    if absf(recessed_front.x + recessed_mirror.x - 2.0 * center.x) > 0.00001 or \
            absf(recessed_front.z - recessed_mirror.z) > 0.00001:
        _fail("source-skinned front pectoral sculpt must remain symmetric")
        return
    # The new athletic thigh is narrower in BOTH axes than the source body,
    # not merely recolored, and remains on the original 65-bone skin.
    var thigh := Vector3(center.x + x, bounds.position.y + bounds.size.y * 0.310, center.z + bounds.size.z * 0.18)
    var thigh_after: Vector3 = sculpt.call("_reshape", thigh, bounds)
    if thigh_after.x >= thigh.x or thigh_after.z >= thigh.z:
        _fail("original weighted thigh still has the inflated toy-like profile")
        return
    if (sculpt.call("_reshape", head, bounds) as Vector3).distance_to(head) > 0.0001 or \
            (sculpt.call("_reshape", foot, bounds) as Vector3).distance_to(foot) > 0.0001:
        _fail("face and board-contact feet must retain imported rest geometry")
        return
    if rider.get_node_or_null("LegacyRider/Floating hoverboard") == null or \
            not hero.find_children("*", "CollisionObject3D", true, false).is_empty():
        _fail("sculpt altered board, collision or touch controller")
        return
    print("CONTINUOUS BODY RESCULPT TEST PASSED: %d original weighted vertices, %d resculpted, 65 bones" % [checked, changed])
    quit(0)
