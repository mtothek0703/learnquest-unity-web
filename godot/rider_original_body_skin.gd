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
var retired_head_surfaces: int = 0
var retired_hand_surfaces: int = 0
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

# V108: the glTF still contains a rigid-looking original head, dark helmet cap
# and bright face strip. Those THREE surfaces occlude the newer 360-degree
# skinned head even though its skinning tests pass. Retire only these surfaces
# AFTER the replacement head has been created successfully. Keep every other
# original glTF body surface and its real 13-bone GPU skin.
func retire_legacy_head_surfaces() -> void:
    if skeleton == null or skeleton.get_bone_count() != 13:
        return
    if retired_head_surfaces > 0:
        return
    for source in skinned_meshes:
        var old := source.mesh as ArrayMesh
        if old == null:
            continue
        var kept := ArrayMesh.new()
        var removed := 0
        for surface_index in range(old.get_surface_count()):
            var arrays: Array = old.surface_get_arrays(surface_index)
            if _is_original_head_surface(arrays):
                removed += 1
                continue
            kept.add_surface_from_arrays(old.surface_get_primitive_type(surface_index), arrays)
            kept.surface_set_material(kept.get_surface_count() - 1,
                old.surface_get_material(surface_index))
        # Never erase a standalone body mesh or leave an empty render object.
        if removed > 0 and kept.get_surface_count() > 0:
            source.mesh = kept
            retired_head_surfaces += removed

func _is_original_head_surface(arrays: Array) -> bool:
    var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
    var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
    if vertices.is_empty():
        return false
    var lowest := INF
    var highest := -INF
    # glTF primitives may share a POSITION accessor with the entire body.
    # Only referenced vertices count; scanning the whole array would
    # incorrectly classify every primitive as a head surface.
    if indices.is_empty():
        for point in vertices:
            lowest = minf(lowest, point.y)
            highest = maxf(highest, point.y)
    else:
        for index in indices:
            if index < 0 or index >= vertices.size():
                return false
            lowest = minf(lowest, vertices[index].y)
            highest = maxf(highest, vertices[index].y)
    # Current bundled CC0/procedural glTF: Skin head (1.90–2.92),
    # Navy crown (2.42–3.00), Cyan visor strip (2.24–2.66).
    # Torso, arms, pants and boots all end at y <= 2.17.
    return lowest > 1.85 and highest > 2.55

# V115: two original pale hand surfaces occlude the newly GPU-skinned
# gloves. The bundled glTF has a shared POSITION accessor; classify by
# referenced triangle vertices, not by all accessor vertices. Preserve every
# imported torso, arm, leg, boot and head surface and the existing skin.
func retire_legacy_hand_surfaces() -> void:
    if skeleton == null or skeleton.get_bone_count() != 13 or retired_hand_surfaces > 0:
        return
    for source in skinned_meshes:
        var old := source.mesh as ArrayMesh
        if old == null:
            continue
        var kept := ArrayMesh.new()
        var removed := 0
        for surface_index in range(old.get_surface_count()):
            var arrays: Array = old.surface_get_arrays(surface_index)
            if _is_original_hand_surface(arrays):
                removed += 1
                continue
            kept.add_surface_from_arrays(old.surface_get_primitive_type(surface_index), arrays)
            kept.surface_set_material(kept.get_surface_count() - 1,
                old.surface_get_material(surface_index))
        if removed > 0 and kept.get_surface_count() > 0:
            source.mesh = kept
            retired_hand_surfaces += removed

func _is_original_hand_surface(arrays: Array) -> bool:
    var points: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
    var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
    if points.is_empty():
        return false
    var minimum := Vector3(INF, INF, INF)
    var maximum := Vector3(-INF, -INF, -INF)
    if indices.is_empty():
        for point in points:
            minimum = minimum.min(point)
            maximum = maximum.max(point)
    else:
        for index in indices:
            if index < 0 or index >= points.size():
                return false
            minimum = minimum.min(points[index])
            maximum = maximum.max(points[index])
    # Only bundled original glTF skin hands: left/right x +/-0.52..0.86,
    # y 0.91..1.37, z -0.32..0.04. Exclude jacket arms, pants and boots.
    var on_side := (maximum.x < -0.49 and minimum.x > -0.95) or (
        minimum.x > 0.49 and maximum.x < 0.95)
    return on_side and minimum.y < 1.05 and maximum.y > 1.30 and (
        maximum.y < 1.55 and minimum.z < -0.25 and maximum.z < 0.12)

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
        # Critical V108 visual fix: a new Skeleton3D starts with IDENTITY
        # pose translations, NOT its authored bone-rest translations.
        # Without this, global poses stay at (0,0,0), inverse bind matrices
        # shift the GPU-skinned head/jacket/hair below the board, and only
        # the old rigid decorative face remains visible. Initialize each
        # local pose to the same rest offset before animating rotations.
        skeleton.set_bone_pose_position(i, offsets[i])

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
        # A long headless test tick must not leave a one-frame landing pose.
        landing_recoil = maxf(0.0, 1.0 - delta * 5.0)
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
    _rotate(2, Quaternion(Vector3.UP, -steering * 0.23) *
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
