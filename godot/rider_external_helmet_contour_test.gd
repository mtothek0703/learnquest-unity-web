extends SceneTree
## V124 regression: one closed integrated helmet shell, not detached ear boxes.
func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("INTEGRATED HELMET TEST FAILED: " + message)
    quit(1)

func _check() -> void:
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    rider.set("prefer_cc0_rigged_hero", true)
    root.add_child(rider)
    await process_frame
    var pose := rider.get_node_or_null("ExternalHeroPose") as Node
    if pose == null:
        _fail("original rig adapter missing")
        return
    var rig := pose.get("skeleton") as Skeleton3D
    var headwear := rig.get_node_or_null("ExternalHeroHeadgear") as BoneAttachment3D if rig != null else null
    if rig == null or rig.get_bone_count() < 50 or headwear == null or headwear.bone_name != "Head":
        _fail("integrated helmet must follow original 65-bone Head")
        return
    var helmet := headwear.get_node_or_null("CurvedFlightHelmetShell") as MeshInstance3D
    if helmet == null or helmet.mesh == null or helmet.mesh.get_surface_count() != 1:
        _fail("temple guards must share the existing crown mesh and draw call")
        return
    var a: Array = helmet.mesh.surface_get_arrays(0)
    var vertices: PackedVector3Array = a[Mesh.ARRAY_VERTEX]
    var normals: PackedVector3Array = a[Mesh.ARRAY_NORMAL]
    if vertices.size() < 7500 or normals.size() != vertices.size():
        _fail("continuous helmet lacks substantial bilateral sculpted geometry/normals")
        return
    var bounds := headwear.get("head_bounds") as AABB
    var c := bounds.get_center()
    var s := bounds.size
    var left := 0
    var right := 0
    var front_limit := 0
    var nonfinite := 0
    for i in range(vertices.size()):
        var v := vertices[i]
        var n := normals[i]
        if not v.is_finite() or not n.is_finite() or absf(n.length() - 1.0) > 0.015:
            nonfinite += 1
        if v.y < c.y - s.y * 0.18 and absf(v.x - c.x) > s.x * 0.43:
            if v.x < c.x:
                left += 1
            else:
                right += 1
            if float(headwear.get("face_sign")) * (v.z - c.z) > s.z * 0.38:
                front_limit += 1
    # Profile QA: cheek guards must taper toward the jaw instead of forming
    # the broad rectangular side slabs seen in the first real render.
    var contour := preload("res://rider_external_helmet_contour.gd").new()
    var face_sign := float(headwear.get("face_sign"))
    var upper: Vector3 = contour.call("_point", c, s, face_sign, 1.0, 0.0, 1.0, true)
    var lower: Vector3 = contour.call("_point", c, s, face_sign, 1.0, 1.0, 1.0, true)
    if upper.x - lower.x < s.x * 0.08 or face_sign * (upper.z - lower.z) < s.z * 0.30:
        _fail("sculpted cheek contour must taper in width and depth toward the jaw")
        return
    # Explicitly guard against the old bulky rectangular side guards. These
    # are sampled from the same actual closed mesh generator, not a mock.
    var mid: Vector3 = contour.call("_point", c, s, face_sign, 1.0, 0.5, 0.5, true)
    var mirrored: Vector3 = contour.call("_point", c, s, face_sign, -1.0, 1.0, 1.0, true)
    if upper.x - c.x < s.x * 0.55 or lower.x - c.x > s.x * 0.43 or \
            not (upper.x > mid.x and mid.x > lower.x):
        _fail("integrated helmet must narrow continuously from crown to jaw")
        return
    if absf((lower.x - c.x) + (mirrored.x - c.x)) > 0.00001 or \
            absf(lower.z - mirrored.z) > 0.00001:
        _fail("athletic cheek contour must be bilaterally symmetric")
        return
    if nonfinite != 0 or left < 50 or right < 50:
        _fail("both anatomically tapered cheek guards must have finite, closed geometry")
        return
    if front_limit > 0:
        _fail("helmet sidewalls must not cover the expressive eye/face plane")
        return
    if headwear.find_children("TempleGuard*", "MeshInstance3D", false, false).size() != 0:
        _fail("side guards must not add independent rigid accessories/draw calls")
        return
    if rider.get_node_or_null("ExternalRiggedHero").find_children("*", "CollisionObject3D", true, false).size() != 0:
        _fail("new head silhouette must not modify collisions")
        return
    var source := rider.get_node_or_null("ExternalRiggedHero").find_child("SuperHero_Male", true, false) as MeshInstance3D
    if source == null or source.skin == null or source.skin.get_bind_count() < 50:
        _fail("real imported 65-bone four-weight skin was replaced")
        return
    print("INTEGRATED HELMET TEST PASSED: one sculpted 360-degree crown/temple shell, bilateral closed cheek contour, original Head and Skin")
    quit(0)
