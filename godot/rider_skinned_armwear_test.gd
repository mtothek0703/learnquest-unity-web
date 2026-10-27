extends SceneTree
## V107: original 13-bone GPU-skinned sleeves replace rigid overlapping arms.
func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("SKINNED ARMWEAR TEST FAILED: " + message)
    quit(1)

func _deformed_point(mesh: MeshInstance3D, index: int, skeleton: Skeleton3D) -> Vector3:
    var arrays: Array = mesh.mesh.surface_get_arrays(0)
    var points: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
    var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
    var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
    var point := Vector3.ZERO
    for slot in range(4):
        var offset := index * 4 + slot
        var bone := bones[offset]
        var pose := skeleton.get_bone_global_pose(bone) * mesh.skin.get_bind_pose(bone)
        point += (pose * points[index]) * weights[offset]
    return point

func _check() -> void:
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    root.add_child(rider)
    await process_frame
    var model := rider.get_node_or_null("ImportedRider") as Node3D
    if model == null:
        _fail("imported rider missing")
        return
    var rig := model.get_node_or_null("OriginalBodySkinRig") as Node3D
    var garment := model.get_node_or_null("OrganicSkinnedArmwear") as Node3D
    var suit := model.get_node_or_null("SculptedSkinnedFlightSuit") as Node3D
    if rig == null or garment == null or suit == null:
        _fail("original skeleton, new armwear and old fallback suit required")
        return
    var skeleton := rig.get_node_or_null("OriginalBodySkeleton13") as Skeleton3D
    if skeleton == null or skeleton.get_bone_count() != 13:
        _fail("armwear must use original 13-bone skeleton")
        return
    var sleeves: Array = garment.get("sleeves")
    var seams: Array = garment.get("seams")
    var cuffs: Array = garment.get("cuffs")
    if sleeves.size() != 2 or seams.size() != 2 or cuffs.size() != 2:
        _fail("two sculpted sleeves, luminous seams and cuffs required")
        return
    var min_x := INF
    var max_x := -INF
    var min_y := INF
    var max_y := -INF
    var shoulder_count := 0
    var forearm_count := 0
    var vertices_total := 0
    for mesh in sleeves + seams + cuffs:
        var part := mesh as MeshInstance3D
        if part == null or part.mesh == null or part.skin == null:
            _fail("each armwear layer needs real skinned geometry")
            return
        if part.skin.get_bind_count() != 13 or part.get_node_or_null(part.skeleton) != skeleton:
            _fail("armwear detached from original 13-bone GPU skin")
            return
        var arrays: Array = part.mesh.surface_get_arrays(0)
        var points: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
        var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
        var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
        var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
        var colors: PackedColorArray = arrays[Mesh.ARRAY_COLOR]
        if points.size() < 100 or bones.size() != points.size() * 4 or weights.size() != bones.size() or normals.size() != points.size() or colors.size() != points.size():
            _fail("armwear needs shaded triangles and four normalized weights per vertex")
            return
        vertices_total += points.size()
        for i in range(points.size()):
            var p := points[i]
            min_x = minf(min_x, p.x)
            max_x = maxf(max_x, p.x)
            min_y = minf(min_y, p.y)
            max_y = maxf(max_y, p.y)
            var total := 0.0
            for slot in range(4):
                var offset := i * 4 + slot
                if bones[offset] < 0 or bones[offset] >= 13 or weights[offset] < 0.0:
                    _fail("invalid armwear skin influence")
                    return
                total += weights[offset]
                if (bones[offset] == 5 or bones[offset] == 7) and weights[offset] > 0.20:
                    shoulder_count += 1
                if (bones[offset] == 6 or bones[offset] == 8) and weights[offset] > 0.25:
                    forearm_count += 1
            if absf(total - 1.0) > 0.002:
                _fail("unnormalized armwear GPU skin")
                return
    if vertices_total < 9000 or min_x > -0.92 or max_x < 0.92 or min_y > 1.34 or max_y < 2.02:
        _fail("new sleeves must form full organic bilateral shoulder-to-wrist volumes")
        return
    if shoulder_count < 400 or forearm_count < 400:
        _fail("both shoulder and forearm bones must deform the sleeve")
        return
    var fabric := (sleeves[0] as MeshInstance3D).material_override as StandardMaterial3D
    var light := (seams[0] as MeshInstance3D).material_override as StandardMaterial3D
    if fabric == null or not fabric.vertex_color_use_as_albedo or fabric.shading_mode == BaseMaterial3D.SHADING_MODE_UNSHADED or light == null or not light.emission_enabled:
        _fail("physically shaded fabric and emissive tailored seams required")
        return
    var old_shells: Array = suit.get("suit_parts")
    var old_piping: Array = suit.get("piping_parts")
    for index in [1, 2]:
        if (old_shells[index] as MeshInstance3D).visible or (old_piping[index] as MeshInstance3D).visible:
            _fail("old overlapping GPU-skinned sleeves still visible")
            return
    for index in range(2):
        var arm := model.get_node_or_null("BalanceArm%d" % index) as Node3D
        if arm == null or arm.get_node_or_null("SculptedRiderGauntlet") == null or arm.get_node_or_null("AnimatedElbowKinematics") == null:
            _fail("existing articulated gauntlets and elbow mechanics must remain")
            return
        var guard := arm.get_node_or_null("SculptedShoulderGuard") as MeshInstance3D
        var trim := arm.get_node_or_null("ShoulderNeonTrim") as MeshInstance3D
        if guard == null or trim == null or guard.visible or trim.visible:
            _fail("old rigid shoulder shells must not occlude new skinned armwear")
            return
        for child in arm.get_children():
            if child is MeshInstance3D and child.mesh is CapsuleMesh and child.visible:
                _fail("legacy rigid arm capsule still visible")
                return
    if garment.find_children("*", "CollisionObject3D", true, false).size() != 0:
        _fail("armwear must not alter gameplay collisions or touch")
        return
    var left := sleeves[0] as MeshInstance3D
    var sample := 1800
    var before := _deformed_point(left, sample, skeleton)
    rider.set("lean", 0.95)
    rider.set("boosting", true)
    rider.position.y = 0.90
    rig.call("_process", 0.28)
    var after := _deformed_point(left, sample, skeleton)
    if before.distance_to(after) < 0.025:
        _fail("armwear must visibly deform under real skeleton poses")
        return
    print("SKINNED ARMWEAR TEST PASSED: bilateral organic sleeve volumes, shoulder/elbow weights, emissive seams, cuffs, retired duplicates, original rig")
    quit(0)
