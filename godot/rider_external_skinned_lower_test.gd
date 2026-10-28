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
    var fitted_head := rig.get_node_or_null("ExternalHeroHeadgear") as BoneAttachment3D
    if fitted_head == null or absf(float(lower.get("face_sign")) - float(fitted_head.get("face_sign"))) > 0.001:
        _fail("boot forward axis must match the actual imported Head/eyes")
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
        var material := garment.material_override as ShaderMaterial
        if material == null or material.shader == null:
            _fail(property_name + " lacks the real skinned lower-body PBR shader")
            return
        var shader_code := material.shader.code
        for required in ["cobalt", "magenta", "EMISSION", "ROUGHNESS", "boot_mode"]:
            if not shader_code.contains(required):
                _fail(property_name + " missing cohesive hover-suit material: " + required)
                return
        var mode := float(material.get_shader_parameter("boot_mode"))
        if absf(mode - (1.0 if property_name == "boots" else 0.0)) > 0.001:
            _fail(property_name + " uses wrong trouser/boot shader mode")
            return
        if absf(float(material.get_shader_parameter("face_sign")) - float(lower.get("face_sign"))) > 0.001:
            _fail("boot and trouser shader orientation diverged from the imported face")
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
                    # Imported glTF Skin bindings are frequently name-based;
                    # get_bind_bone() may legitimately return -1 for these.
                    # Resolve names before reading the Skeleton3D by index.
                    var bound_name := source.skin.get_bind_name(index).to_lower()
                    var bound_id := source.skin.get_bind_bone(index)
                    if bound_name.is_empty() and bound_id >= 0 and bound_id < rig.get_bone_count():
                        bound_name = rig.get_bone_name(bound_id).to_lower()
                    if weight > 0.05 and ("thigh" in bound_name or "calf" in bound_name or "foot" in bound_name or "shin" in bound_name):
                        leg_influences += 1
                if absf(total - 1.0) > 0.04:
                    _fail(property_name + " weights no longer normalized")
                    return
            count += verts.size()
        if count < 120 or leg_influences < 30:
            _fail(property_name + " is not substantial animated leg geometry")
            return
        combined += count
    # Verify genuine geometric width and boot volume on both legs, not only
    # material colors. The same profile must mirror without lateral drift.
    var sample_bounds := AABB(Vector3(-0.6, 0.0, -0.4), Vector3(1.2, 3.0, 0.8))
    var right_knee: Vector3 = lower.call("_sculpt_offset",
        Vector3(0.28, 0.915, 0.0), Vector3.RIGHT, sample_bounds, false)
    var left_knee: Vector3 = lower.call("_sculpt_offset",
        Vector3(-0.28, 0.915, 0.0), Vector3.LEFT, sample_bounds, false)
    var right_boot: Vector3 = lower.call("_sculpt_offset",
        Vector3(0.28, 0.255, 0.0), Vector3.RIGHT, sample_bounds, true)
    var right_waist: Vector3 = lower.call("_sculpt_offset",
        Vector3(0.28, 1.2, 0.0), Vector3.RIGHT, sample_bounds, false)
    if right_knee.x < 0.07 or right_boot.x < 0.075 or right_knee.x < right_waist.x + 0.04:
        _fail("athletic knee and boot must be sculpted wider than the original narrow legs")
        return
    # Full skinned boot geometry must have an actual toe, instep, heel,
    # sole and front shin plate, not merely the previous glowing cuff.
    var front_normal := Vector3(0.0, 0.0, float(lower.get("face_sign")))
    var back_normal := -front_normal
    var toe_front: Vector3 = lower.call("_sculpt_offset",
        Vector3(0.28, 0.264, 0.0), front_normal, sample_bounds, true)
    var toe_back: Vector3 = lower.call("_sculpt_offset",
        Vector3(0.28, 0.264, 0.0), back_normal, sample_bounds, true)
    var instep_front: Vector3 = lower.call("_sculpt_offset",
        Vector3(0.28, 0.396, 0.0), front_normal, sample_bounds, true)
    var shin_front: Vector3 = lower.call("_sculpt_offset",
        Vector3(0.28, 0.675, 0.0), front_normal, sample_bounds, true)
    var shin_back: Vector3 = lower.call("_sculpt_offset",
        Vector3(0.28, 0.675, 0.0), back_normal, sample_bounds, true)
    var heel_back: Vector3 = lower.call("_sculpt_offset",
        Vector3(0.28, 0.210, 0.0), back_normal, sample_bounds, true)
    var sole_front: Vector3 = lower.call("_sculpt_offset",
        Vector3(0.28, 0.135, 0.0), front_normal, sample_bounds, true)
    if toe_front.dot(front_normal) < toe_back.dot(front_normal) + 0.13 or \
            instep_front.dot(front_normal) < 0.10 or \
            shin_front.dot(front_normal) < shin_back.dot(front_normal) + 0.10 or \
            heel_back.dot(back_normal) < 0.07 or sole_front.y >= -0.008:
        _fail("true weighted boots lack front toe/instep, rear heel, shin relief or sole")
        return
    # The boot collar must be an actual 3D, bilateral four-weight mesh
    # deformation, not a painted stripe or an unskinned attachment.
    var right_cuff: Vector3 = lower.call("_sculpt_offset",
        Vector3(0.28, 0.465, 0.0), Vector3.RIGHT, sample_bounds, true)
    var below_cuff: Vector3 = lower.call("_sculpt_offset",
        Vector3(0.28, 0.375, 0.0), Vector3.RIGHT, sample_bounds, true)
    var left_cuff: Vector3 = lower.call("_sculpt_offset",
        Vector3(-0.28, 0.465, 0.0), Vector3.LEFT, sample_bounds, true)
    if right_cuff.x < below_cuff.x + 0.04 or absf(right_cuff.x + left_cuff.x) > 0.001:
        _fail("weighted ankle collar lacks raised symmetrical 3D volume")
        return
    var boot_shader := ((lower.get("boots") as MeshInstance3D).material_override as ShaderMaterial).shader.code
    if not boot_shader.contains("ankle_cuff") or not boot_shader.contains("boot_mode * 0.58") or \
            not boot_shader.contains("shin_plate") or not boot_shader.contains("forefoot") or \
            not boot_shader.contains("heel_counter") or not boot_shader.contains("sole_edge"):
        _fail("boot collar shading does not follow its actual skinned geometry")
        return
    if absf(right_knee.x + left_knee.x) > 0.001:
        _fail("lower garment silhouette must be left/right symmetric")
        return
    for garment_name in ["trousers", "boots"]:
        var material := (lower.get(garment_name) as MeshInstance3D).material_override as ShaderMaterial
        var source_bounds := source.mesh.get_aabb()
        if absf(float(material.get_shader_parameter("rest_height")) - source_bounds.size.y) > 0.001 or \
                absf(float(material.get_shader_parameter("rest_width")) - source_bounds.size.x) > 0.001:
            _fail("large color panels must fit actual imported CC0 body bounds")
            return
    # A source triangle straddling BOTH garment limits must be clipped into
    # continuous weighted triangles, never dropped because one corner lies
    # outside. This catches the former jagged waist/ankle/boot seam defect.
    var sample: Array[Dictionary] = [
        {"position": Vector3(-0.4, 0.0, 0.0), "normal": Vector3.FORWARD,
            "bones": PackedInt32Array([0, 0, 0, 0]),
            "weights": PackedFloat32Array([1.0, 0.0, 0.0, 0.0])},
        {"position": Vector3(0.4, 1.0, 0.0), "normal": Vector3.FORWARD,
            "bones": PackedInt32Array([1, 1, 1, 1]),
            "weights": PackedFloat32Array([1.0, 0.0, 0.0, 0.0])},
        {"position": Vector3(0.0, 2.0, 0.0), "normal": Vector3.FORWARD,
            "bones": PackedInt32Array([2, 2, 2, 2]),
            "weights": PackedFloat32Array([1.0, 0.0, 0.0, 0.0])}
    ]
    var clipped: Array[Dictionary] = lower.call("_clip_to_height", sample, 0.5, true)
    clipped = lower.call("_clip_to_height", clipped, 1.5, false)
    if clipped.size() < 3:
        _fail("straddling original weighted triangle was discarded at the lower seams")
        return
    var bottom_edges := 0
    var top_edges := 0
    var mixed_bones := 0
    for corner in clipped:
        var point: Vector3 = corner["position"]
        if point.y < 0.4999 or point.y > 1.5001:
            _fail("clipped garment vertex escaped its two seam planes")
            return
        if absf(point.y - 0.5) < 0.0001:
            bottom_edges += 1
        if absf(point.y - 1.5) < 0.0001:
            top_edges += 1
        var ids: PackedInt32Array = corner["bones"]
        var influences: PackedFloat32Array = corner["weights"]
        if ids.size() != 4 or influences.size() != 4:
            _fail("seam vertex lost original four-influence skin format")
            return
        var total_weight := 0.0
        var active := 0
        for slot in range(4):
            if ids[slot] < 0 or ids[slot] > 2:
                _fail("seam interpolation invented a bone")
                return
            total_weight += influences[slot]
            if influences[slot] > 0.1:
                active += 1
        if absf(total_weight - 1.0) > 0.0001:
            _fail("seam interpolation did not normalize four bone weights")
            return
        if active >= 2:
            mixed_bones += 1
    if bottom_edges == 0 or top_edges == 0 or mixed_bones < 2:
        _fail("missing interpolated upper/lower seam or blended original bone influences")
        return
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
