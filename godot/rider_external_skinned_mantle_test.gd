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
    if float(mantle.get("mantle_span")) < source.mesh.get_aabb().size.y * 0.24 or \
            float(mantle.get("mantle_span")) > source.mesh.get_aabb().size.y * 0.30:
        _fail("short skinned flight fins must reveal the lower suit and hoverboard")
        return
    # Integrated wing redesign must occupy a readable chase silhouette
    # without widening beyond the rider/board composition.
    var wing_reach := float(mantle.get("wing_reach"))
    var source_width := source.mesh.get_aabb().size.x
    if wing_reach < source_width * 0.50 or wing_reach > source_width * 0.76:
        _fail("swept wings must be broad but not detached from the rider")
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
        var wing_shader := mesh.material_override as ShaderMaterial
        if wing_shader == null or wing_shader.shader == null:
            _fail("integrated wing has no one-pass sculpted material")
            return
        for zone in ["leading", "trailing", "central_spar", "silhouette_rim"]:
            if not wing_shader.shader.code.contains(zone):
                _fail("integrated wing missing material region: " + zone)
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
        var root_min := INF
        var root_max := -INF
        var hem_min := INF
        var hem_max := -INF
        var root_depth := 0.0
        var hem_depth := 0.0
        var mid_min := INF
        var mid_max := -INF
        var closest_hem_to_center := INF
        var root_samples := 0
        var hem_samples := 0
        var airfoil_min_z := INF
        var airfoil_max_z := -INF
        var lowest_y := INF
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
            lowest_y = minf(lowest_y, vertices[i].y)
            if uv[i].x > 0.48 and uv[i].x < 0.52 and uv[i].y > 0.48 and uv[i].y < 0.52:
                airfoil_min_z = minf(airfoil_min_z, vertices[i].z)
                airfoil_max_z = maxf(airfoil_max_z, vertices[i].z)
            if uv[i].y < 0.05:
                root_min = minf(root_min, vertices[i].x)
                root_max = maxf(root_max, vertices[i].x)
                root_depth += vertices[i].z
                root_samples += 1
            if uv[i].y > 0.47 and uv[i].y < 0.53:
                mid_min = minf(mid_min, vertices[i].x)
                mid_max = maxf(mid_max, vertices[i].x)
            if uv[i].y > 0.95:
                hem_min = minf(hem_min, vertices[i].x)
                hem_max = maxf(hem_max, vertices[i].x)
                hem_depth += vertices[i].z
                closest_hem_to_center = minf(closest_hem_to_center, absf(vertices[i].x - source.mesh.get_aabb().get_center().x))
                hem_samples += 1
            if uv[i].y > 0.9:
                low_count += 1
        if root_samples < 10 or hem_samples < 10:
            _fail("mantle must have sampled shoulder and wing-tip rows")
            return
        if mid_max - mid_min < source_width * 0.30:
            _fail("swept wing must add a broad, visible sculpted midspan")
            return
        if mid_max - mid_min < (root_max - root_min) * 3.0:
            _fail("sculpted fin must have substantial mid-chord width")
            return
        if hem_max - hem_min > (mid_max - mid_min) * 0.60:
            _fail("fin tip must taper rather than become a skirt-like hem")
            return
        if lowest_y < source.mesh.get_aabb().position.y + source.mesh.get_aabb().size.y * 0.44:
            _fail("short fins must not conceal the original skinned legs or board")
            return
        if airfoil_max_z - airfoil_min_z < source.mesh.get_aabb().size.x * 0.025:
            _fail("flight fins need real front/back airfoil volume, not flat double-sided cloth")
            return
        if closest_hem_to_center < source.mesh.get_aabb().size.x * 0.12:
            _fail("split-wing tips must leave a visible center channel for boots and board")
            return
        var headgear := rig.get_node_or_null("ExternalHeroHeadgear") as BoneAttachment3D
        if headgear == null:
            _fail("original Head attachment missing")
            return
        var back_sign := -1.0 if float(headgear.get("face_sign")) > 0.0 else 1.0
        if back_sign * (hem_depth / float(hem_samples) - root_depth / float(root_samples)) < 0.32:
            _fail("wing hems must sweep behind the original skinned torso")
            return
        if low_count < 50:
            _fail("missing tapered, sealed flight-fin tip geometry")
            return
    # The sculpted shoulder bridge is also a true weighted source-body
    # surface, not a rigid armor primitive hovering over the torso.
    var yoke := mantle.get("shoulder_yoke") as MeshInstance3D
    if yoke == null or yoke.mesh == null or yoke.skin != source.skin:
        _fail("weighted shoulder yoke missing original imported Skin")
        return
    if yoke.skeleton != source.skeleton or yoke.get_parent() != source.get_parent():
        _fail("shoulder yoke must follow the same original Skeleton3D")
        return
    var yoke_arrays: Array = yoke.mesh.surface_get_arrays(0)
    var yoke_points: PackedVector3Array = yoke_arrays[Mesh.ARRAY_VERTEX]
    var yoke_weights: PackedFloat32Array = yoke_arrays[Mesh.ARRAY_WEIGHTS]
    var yoke_bones: PackedInt32Array = yoke_arrays[Mesh.ARRAY_BONES]
    if yoke_points.size() < 120 or yoke_weights.size() != yoke_points.size() * 4 or yoke_bones.size() != yoke_points.size() * 4:
        _fail("shoulder bridge must contain substantial four-weight sculpted geometry")
        return
    for i in range(yoke_points.size()):
        var total := 0.0
        for j in range(4):
            var index := yoke_bones[i * 4 + j]
            if index < 0 or index >= source.skin.get_bind_count():
                _fail("shoulder yoke contains invalid source Skin index")
                return
            total += yoke_weights[i * 4 + j]
        if absf(total - 1.0) > 0.04:
            _fail("shoulder yoke has unnormalized source weights")
            return
    if not (yoke.material_override is ShaderMaterial) or yoke.get_child_count() > 0:
        _fail("shoulder bridge must remain a PBR cosmetic surface only")
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
    rider.set("lean", 0.65)
    pose.call("_process", 0.35)
    var motion_mat := (panels[0] as MeshInstance3D).material_override as ShaderMaterial
    if motion_mat == null:
        _fail("split-wing mantle needs its own animated PBR material")
        return
    if absf(float(motion_mat.get_shader_parameter("steer_amount")) - 0.65) > 0.01:
        _fail("mantle wind must follow actual steering without changing controls")
        return
    if float(motion_mat.get_shader_parameter("boost_amount")) < 0.99:
        _fail("mantle wind must react to real turbo state")
        return
    if float(motion_mat.get_shader_parameter("jump_amount")) < 0.10:
        _fail("mantle wind must react to real jump height")
        return
    if rig.get_bone_pose_rotation(thigh).angle_to(before) < 0.03:
        _fail("mantle lower joint must move during jump/boost")
        return
    rider.set("lean", 0.0)
    rider.set("boosting", false)
    rider.position.y = 0.0
    pose.call("_process", 0.40)
    if absf(float(motion_mat.get_shader_parameter("steer_amount"))) > 0.01 or float(motion_mat.get_shader_parameter("boost_amount")) > 0.01:
        _fail("split-wing wind must return to neutral when steering/turbo end")
        return
    if rider.get_node_or_null("LegacyRider") == null:
        _fail("legacy fallback and existing hoverboard must remain")
        return
    print("EXTERNAL SKINNED MANTLE TEST PASSED: %d four-weight vertices, swept wing reach %.3f, closed airfoils and weighted shoulder yoke" % [int(mantle.get("generated_vertices")), wing_reach])
    quit(0)
