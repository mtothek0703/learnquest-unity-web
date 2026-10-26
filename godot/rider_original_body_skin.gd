extends Node3D
## Skyway V97 — bind the ACTUAL imported glTF body mesh to a 13-bone
## Skeleton3D. Unlike the V94–V96 costume-only skins, the original mesh
## itself now receives four GPU skin weights per vertex. All geometry and
## original material surfaces are preserved; no external assets or collisions.
const BONE_NAMES := [
    "Hips", "Spine", "Chest", "Neck", "Head",
    "LeftUpperArm", "LeftForearm", "RightUpperArm", "RightForearm",
    "LeftThigh", "LeftShin", "RightThigh", "RightShin"
]
var skeleton: Skeleton3D
var skinned_meshes: Array[MeshInstance3D] = []
var clock: float = 0.0
# V101: phase-aware body motion; visual-only, no gameplay state changes.
var previous_height: float = 0.0
var landing_recoil: float = 0.0
var boost_pose_weight: float = 0.0

func bind_original(model: Node3D) -> void:
    # Process after the rider updates input, before head/costume followers.
    process_priority = 10
    # Capture only original imported geometry, BEFORE any costume nodes exist.
    var original_meshes: Array[MeshInstance3D] = []
    # Godot may import a one-node glTF with MeshInstance3D as scene root.
    if model is MeshInstance3D and (model as MeshInstance3D).mesh != null:
        original_meshes.append(model as MeshInstance3D)
    for node in model.find_children("*", "MeshInstance3D", true, false):
        var mesh_node := node as MeshInstance3D
        if mesh_node != null and mesh_node.mesh != null:
            original_meshes.append(mesh_node)
    if original_meshes.is_empty():
        # The gameplay tests and hero gallery also inject optional placeholder
        # Node3D models. They have no imported body and must remain supported.
        return
    _make_skeleton()
    var shared_skin := skeleton.create_skin_from_rest_transforms()
    for source in original_meshes:
        var original := source.mesh
        var weighted := ArrayMesh.new()
        for surface_index in range(original.get_surface_count()):
            var arrays: Array = original.surface_get_arrays(surface_index)
            var positions: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
            if positions.is_empty():
                continue
            var bone_indices := PackedInt32Array()
            var weights := PackedFloat32Array()
            for point in positions:
                var influences: Dictionary = _influences(point)
                var ids: PackedInt32Array = influences["bones"]
                var values: PackedFloat32Array = influences["weights"]
                bone_indices.append_array(ids)
                weights.append_array(values)
            arrays[Mesh.ARRAY_BONES] = bone_indices
            arrays[Mesh.ARRAY_WEIGHTS] = weights
            weighted.add_surface_from_arrays(original.surface_get_primitive_type(surface_index), arrays)
            weighted.surface_set_material(weighted.get_surface_count() - 1, original.surface_get_material(surface_index))
        if weighted.get_surface_count() == 0:
            continue
        source.mesh = weighted
        source.skin = shared_skin
        source.skeleton = source.get_path_to(skeleton)
        skinned_meshes.append(source)

func _make_skeleton() -> void:
    skeleton = Skeleton3D.new()
    skeleton.name = "OriginalBodySkeleton13"
    add_child(skeleton)
    for bone_name in BONE_NAMES:
        skeleton.add_bone(bone_name)
    # Anatomical rest hierarchy, expressed in original glTF coordinates.
    var parents := [-1, 0, 1, 2, 3, 2, 5, 2, 7, 0, 9, 0, 11]
    var offsets := [
        Vector3(0.0, 0.93, 0.0),
        Vector3(0.0, 0.48, 0.0),
        Vector3(0.0, 0.54, 0.0),
        Vector3(0.0, 0.35, 0.0),
        Vector3(0.0, 0.37, 0.0),
        Vector3(-0.53, 0.02, 0.0),
        Vector3(-0.33, -0.45, 0.0),
        Vector3(0.53, 0.02, 0.0),
        Vector3(0.33, -0.45, 0.0),
        Vector3(-0.34, -0.19, 0.0),
        Vector3(0.0, -0.43, 0.0),
        Vector3(0.34, -0.19, 0.0),
        Vector3(0.0, -0.43, 0.0)
    ]
    for i in range(BONE_NAMES.size()):
        if parents[i] >= 0:
            skeleton.set_bone_parent(i, parents[i])
        skeleton.set_bone_rest(i, Transform3D(Basis.IDENTITY, offsets[i]))

func _influences(p: Vector3) -> Dictionary:
    # Four weights for every vertex. Smooth transitions at waist, shoulder,
    # elbow, knee and neck avoid rigid seams on the original curved geometry.
    var ids := PackedInt32Array([0, 1, 2, 3])
    var values := PackedFloat32Array([0.0, 0.0, 0.0, 0.0])
    var x := absf(p.x)
    if p.y >= 2.40:
        var head := smoothstep(2.40, 2.72, p.y)
        ids = PackedInt32Array([4, 3, 2, 1])
        values = PackedFloat32Array([0.12 + 0.88 * head, 0.68 * (1.0 - head), 0.20 * (1.0 - head), 0.0])
    elif p.y > 1.27 and x > 0.43:
        var side := 5 if p.x < 0.0 else 7
        var arm := smoothstep(0.43, 0.72, x)
        var elbow := smoothstep(0.64, 0.97, x) * (1.0 - smoothstep(1.42, 2.12, p.y))
        ids = PackedInt32Array([side, side + 1, 2, 1])
        values = PackedFloat32Array([arm * (1.0 - elbow), arm * elbow, (1.0 - arm) * 0.85, (1.0 - arm) * 0.15])
    elif p.y < 1.14 and x > 0.15:
        var thigh := 9 if p.x < 0.0 else 11
        var leg := smoothstep(0.15, 0.32, x)
        var knee := 1.0 - smoothstep(0.27, 0.72, p.y)
        ids = PackedInt32Array([thigh, thigh + 1, 0, 1])
        values = PackedFloat32Array([leg * (1.0 - knee), leg * knee, (1.0 - leg) * 0.96, (1.0 - leg) * 0.04])
    else:
        var chest := smoothstep(1.28, 2.12, p.y)
        var hips := 1.0 - smoothstep(0.80, 1.45, p.y)
        ids = PackedInt32Array([0, 1, 2, 3])
        values = PackedFloat32Array([hips * (1.0 - chest), (1.0 - hips) * (1.0 - chest), chest * 0.94, chest * 0.06 + hips * chest])
    var total := values[0] + values[1] + values[2] + values[3]
    if total < 0.0001:
        values = PackedFloat32Array([1.0, 0.0, 0.0, 0.0])
    else:
        for i in range(4):
            values[i] /= total
    return {"bones": ids, "weights": values}

func _process(delta: float) -> void:
    if skeleton == null or skinned_meshes.is_empty():
        return
    var rider := get_parent().get_parent() as Node3D
    if rider == null:
        return
    # The existing gameplay controller owns the real jump and steering.
    # Read its state; never write to the rider, touch interpreter or collider.
    var step := maxf(delta, 0.0001)
    clock += delta
    var steering := clampf(float(rider.get("lean")), -1.0, 1.0)
    var boost := bool(rider.get("boosting"))
    var height := maxf(rider.position.y, 0.0)
    var jump := clampf(height / 1.25, 0.0, 1.0)
    var vertical_speed := clampf((height - previous_height) / step, -6.0, 6.0)
    var ascending := clampf(vertical_speed / 3.0, 0.0, 1.0) if height > 0.08 else 0.0
    var descending := clampf(-vertical_speed / 3.0, 0.0, 1.0) if height > 0.08 else 0.0
    if previous_height > 0.12 and height <= 0.08:
        landing_recoil = 1.0
    else:
        landing_recoil = move_toward(landing_recoil, 0.0, delta * 5.0)
    previous_height = height
    boost_pose_weight = move_toward(boost_pose_weight, 1.0 if boost else 0.0, delta * 7.0)
    var speed := 12.0 if boost else 5.0
    var rhythm := sin(clock * speed)
    var blend := minf(1.0, delta * 9.0)
    # Board-sport silhouette: the hips counterbalance the chest; the head
    # looks through the turn while shoulders follow with a softer twist.
    # All 13 original bones still drive the GPU-skinned body and suit.
    _rotate(0, Quaternion(Vector3.FORWARD, -steering * 0.14) *
        Quaternion(Vector3.RIGHT, -landing_recoil * 0.11 - boost_pose_weight * 0.045), blend)
    _rotate(1, Quaternion(Vector3.FORWARD, -steering * 0.16) *
        Quaternion(Vector3.RIGHT, jump * 0.12 - landing_recoil * 0.08), blend)
    _rotate(2, Quaternion(Vector3.UP, -steering * 0.23 + rhythm * 0.018) *
        Quaternion(Vector3.FORWARD, -steering * 0.08) *
        Quaternion(Vector3.RIGHT, boost_pose_weight * 0.19 + jump * 0.17 - landing_recoil * 0.10), blend)
    _rotate(3, Quaternion(Vector3.UP, steering * 0.14) *
        Quaternion(Vector3.RIGHT, -landing_recoil * 0.04), blend)
    var gaze := -steering * 0.26 + sin(clock * 1.1) * 0.035
    var nod := boost_pose_weight * 0.16 - 0.025 - jump * 0.19 + descending * 0.06
    var tilt := -steering * 0.14 + sin(clock * 1.8) * 0.018
    _rotate(4, Quaternion(Vector3.UP, gaze) *
        Quaternion(Vector3.RIGHT, nod) * Quaternion(Vector3.FORWARD, tilt), blend)
    # Asymmetric arms and legs provide a clear airborne silhouette. Ascent
    # spreads the arms, descent pulls them in; landing compresses both knees.
    for side in [-1.0, 1.0]:
        var arm := 5 if side < 0.0 else 7
        var thigh := 9 if side < 0.0 else 11
        var balance: float = steering * float(side)
        var arm_spread: float = float(side) * (0.13 + jump * 0.29 + ascending * 0.13 - descending * 0.06)
        _rotate(arm, Quaternion(Vector3.FORWARD, arm_spread - steering * 0.10) *
            Quaternion(Vector3.RIGHT, boost_pose_weight * 0.24 +
                rhythm * (0.038 + boost_pose_weight * 0.025) * side -
                landing_recoil * 0.09), blend)
        _rotate(arm + 1, Quaternion(Vector3.RIGHT,
            -0.10 - jump * 0.39 - boost_pose_weight * 0.22 -
            descending * 0.12 - absf(balance) * 0.07), blend)
        _rotate(thigh, Quaternion(Vector3.RIGHT,
            jump * (0.30 + 0.05 * side) + rhythm * 0.032 * side +
            landing_recoil * 0.18) *
            Quaternion(Vector3.FORWARD, balance * 0.10), blend)
        _rotate(thigh + 1, Quaternion(Vector3.RIGHT,
            -jump * (0.53 + 0.08 * side) -
            boost_pose_weight * 0.11 - landing_recoil * 0.32), blend)

func _rotate(index: int, target: Quaternion, blend: float) -> void:
    skeleton.set_bone_pose_rotation(index, skeleton.get_bone_pose_rotation(index).slerp(target, blend))
