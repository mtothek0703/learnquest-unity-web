extends SceneTree
## V124: regression for headwear generated from actual weighted Head vertices.
## Ensures it remains an accessory to the original imported 65-bone skin,
## follows real Head pose and does not create collisions or rigid face copies.

func _initialize() -> void:
    call_deferred("_check")

func _fail(reason: String) -> void:
    push_error("EXTERNAL HEADGEAR TEST FAILED: " + reason)
    quit(1)

func _check() -> void:
    if not ResourceLoader.exists("res://models/quaternius_hero.glb"):
        _fail("pinned CC0 source GLB not imported")
        return
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    rider.set("prefer_cc0_rigged_hero", true)
    root.add_child(rider)
    await process_frame
    var adapter := rider.get_node_or_null("ExternalHeroPose") as Node
    if adapter == null:
        _fail("external 65-bone character adapter missing")
        return
    var rig := adapter.get("skeleton") as Skeleton3D
    if rig == null or rig.get_bone_count() < 50:
        _fail("original skinned humanoid rig missing")
        return
    var headwear := rig.get_node_or_null("ExternalHeroHeadgear") as BoneAttachment3D
    if headwear == null or headwear.bone_name != "Head":
        _fail("headwear must be attached to original Head bone")
        return
    # Balanced 360-degree silhouette: the Head-bone portrait remains readable
    # at mobile landscape size without overpowering the real skinned torso.
    var scale_factor := float(headwear.get("visual_scale"))
    if scale_factor < 2.04 or scale_factor > 2.16:
        _fail("integrated hero portrait scale must balance the skinned torso")
        return
    var region := headwear.get("head_bounds") as AABB
    var rear_center := region.get_center()
    var rear_size := region.size
    var rear_point: Vector3 = headwear.call("_back_hair_point",
        rear_center, rear_size, region.position.y + rear_size.y * 0.85,
        rear_size.y * 0.21, rear_size.x * 0.56, rear_size.z * 0.57, 1.0, 0.5)
    if rear_point.y < rear_center.y - rear_size.y * 0.95:
        _fail("larger head rear hair hangs too far into the shoulder/board silhouette")
        return
    var meshes: Array = headwear.get("generated_meshes")
    if meshes.size() < 10:
        _fail("expected curved cap, face shield, visor edges and multiple hair locks")
        return
    for expected in ["CurvedFlightHelmetShell", "TranslucentFaceShield", "SculptedContinuousFace",
            "SculptedBackHairCurtain", "WindSweptBackLock0", "WindSweptBackLock8",
            "EyeWhite*", "Iris*", "Pupil*", "CurvedSmile"]:
        if headwear.find_child(expected, false, false) == null:
            _fail("missing expressive helmet/face feature: " + expected)
            return
    # Integrated crown/temple silhouette: replace seven separate round tubes
    # with broad, closed, shell-following volumes. The darker helmet and
    # lightly tinted visor must not overpower the mobile-scale face.
    var crown_locks := headwear.find_children("SweptHairLock*", "MeshInstance3D", false, false)
    var temple_locks := headwear.find_children("SideHairSweep*", "MeshInstance3D", false, false)
    if crown_locks.size() != 3 or temple_locks.size() != 2:
        _fail("integrated head must have three crown volumes and two temple sweeps")
        return
    for lock_node in crown_locks + temple_locks:
        var sculpted_lock := lock_node as MeshInstance3D
        if sculpted_lock.mesh == null or sculpted_lock.mesh.get_surface_count() != 1:
            _fail("crown/temple volume is not a closed renderable mesh")
            return
        var lock_arrays: Array = sculpted_lock.mesh.surface_get_arrays(0)
        var lock_points: PackedVector3Array = lock_arrays[Mesh.ARRAY_VERTEX]
        var lock_normals: PackedVector3Array = lock_arrays[Mesh.ARRAY_NORMAL]
        if lock_points.size() < 800 or lock_normals.size() != lock_points.size():
            _fail("crown/temple locks must use substantial sculpted geometry and normals")
            return
    var helmet := headwear.get_node_or_null("CurvedFlightHelmetShell") as MeshInstance3D
    var visor := headwear.get_node_or_null("TranslucentFaceShield") as MeshInstance3D
    var helmet_mat := helmet.material_override as StandardMaterial3D if helmet != null else null
    var visor_mat := visor.material_override as StandardMaterial3D if visor != null else null
    if helmet_mat == null or helmet_mat.albedo_color.get_luminance() > 0.18:
        _fail("helmet crown must remain dark enough to frame the expressive face")
        return
    if visor_mat == null or visor_mat.transparency != BaseMaterial3D.TRANSPARENCY_ALPHA or \
            visor_mat.albedo_color.a > 0.17:
        _fail("visor must be translucent enough for the face to read at mobile size")
        return
    var back_hair := headwear.get_node_or_null("SculptedBackHairCurtain") as MeshInstance3D
    if back_hair == null or back_hair.mesh == null or back_hair.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX].size() < 1000:
        _fail("chase camera must have substantial curved back-hair geometry")
        return
    # Nine substantial closed ribbons must replace round pipe-like rear locks.
    # Their broad faces should be much wider than their thickness at midspan.
    var rear_locks := headwear.find_children("WindSweptBackLock*", "MeshInstance3D", false, false)
    if rear_locks.size() != 9:
        _fail("nine Head-attached rear sculpted locks must remain")
        return
    for item in rear_locks:
        var lock := item as MeshInstance3D
        if lock.mesh == null or lock.mesh.get_surface_count() != 1:
            _fail("rear hair ribbon has no renderable closed mesh")
            return
        var arrays: Array = lock.mesh.surface_get_arrays(0)
        var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
        var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
        if vertices.size() < 950 or normals.size() != vertices.size():
            _fail("rear locks must have closed sculpted ribbon geometry and normals")
            return
    # New rear-lock volumes must have distinct, three-dimensional S-curves
    # instead of nine parallel vertical stripes on a flat back-hair sheet.
    var hair_origin := Vector3.ZERO
    var curl_a: Vector3 = headwear.call("_rear_lock_curve",
        hair_origin, rear_size, 0, 0.50)
    var curl_b: Vector3 = headwear.call("_rear_lock_curve",
        hair_origin, rear_size, 4, 0.50)
    if absf(curl_a.x - curl_b.x) < rear_size.x * 0.06 and \
            absf(curl_a.z - curl_b.z) < rear_size.z * 0.04:
        _fail("rear hairstyle still has identical parallel flat locks")
        return
    var root_curve: Vector3 = headwear.call("_rear_lock_curve",
        hair_origin, rear_size, 2, 0.0)
    if absf(root_curve.x) > rear_size.x * 0.01:
        _fail("sculpted rear hair roots must stay attached to the continuous shell")
        return
    var sample_flow: Array[Vector3] = [
        Vector3(0.0, 1.0, 0.0), Vector3(0.0, 0.5, 0.02), Vector3(0.0, 0.0, 0.05)]
    var sample_left: Vector3 = headwear.call("_back_lock_point",
        sample_flow, 0.20, 0.5, 0.0, true)
    var sample_right: Vector3 = headwear.call("_back_lock_point",
        sample_flow, 0.20, 0.5, 1.0, true)
    var sample_inner: Vector3 = headwear.call("_back_lock_point",
        sample_flow, 0.20, 0.5, 0.5, false)
    var sample_outer: Vector3 = headwear.call("_back_lock_point",
        sample_flow, 0.20, 0.5, 0.5, true)
    if absf(sample_right.x - sample_left.x) < absf(sample_outer.z - sample_inner.z) * 3.0:
        _fail("rear hair must form broad ribbons, not cylindrical pipes")
        return
    # A genuine closed 3D rear volume plus six shaped face-framing locks,
    # rather than more floating rigid panels, must survive the mobile rig fit.
    var sculpted_fringe := headwear.find_children("SculptedTaperedFringe*", "MeshInstance3D", false, false)
    if sculpted_fringe.size() != 6:
        _fail("the cohesive forehead hairstyle must contain six tapered locks")
        return
    for item in sculpted_fringe:
        var lock := item as MeshInstance3D
        if lock.mesh == null or lock.mesh.get_surface_count() != 1:
            _fail("a face-framing lock has no modeled surface")
            return
        var arrays: Array = lock.mesh.surface_get_arrays(0)
        var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
        var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
        if vertices.size() < 1000 or normals.size() != vertices.size():
            _fail("fringe must be a closed, sculpted 3D ribbon with real normals")
            return
        var fitted_bounds := headwear.get("head_bounds") as AABB
        var lowest_fringe := lock.mesh.get_aabb().position.y
        if lowest_fringe > fitted_bounds.position.y + fitted_bounds.size.y * 0.745:
            _fail("swept bangs must reach the forehead instead of floating above it")
            return
        if lowest_fringe < fitted_bounds.position.y + fitted_bounds.size.y * 0.605:
            _fail("swept bangs must not obscure the animated eyes")
            return
        if lock.mesh.get_aabb().size.y < headwear.get("head_bounds").size.y * 0.15:
            _fail("fringe has lost its curved crown-to-forehead sweep")
            return
    # Regress the actual sculpt profile: a wide, thin, enclosed hair lock
    # must replace the former round pipe at the crown.
    var sample_root := Vector3(0.0, 1.0, 0.0)
    var sample_control := Vector3(0.0, 1.08, 0.25)
    var sample_tip := Vector3(0.0, 0.72, 0.45)
    var left: Vector3 = headwear.call("_fringe_ribbon_point",
        sample_root, sample_control, sample_tip, 0.20, 0.025, 0.5, 0.0, true)
    var right: Vector3 = headwear.call("_fringe_ribbon_point",
        sample_root, sample_control, sample_tip, 0.20, 0.025, 0.5, 1.0, true)
    var rear: Vector3 = headwear.call("_fringe_ribbon_point",
        sample_root, sample_control, sample_tip, 0.20, 0.025, 0.5, 0.5, false)
    var front: Vector3 = headwear.call("_fringe_ribbon_point",
        sample_root, sample_control, sample_tip, 0.20, 0.025, 0.5, 0.5, true)
    if absf(right.x - left.x) < absf(front.z - rear.z) * 3.0:
        _fail("forehead locks must be broad curved ribbons, not round hair rollers")
        return
    # Mobile-scale expression proportions are actual Head-attached geometry.
    # The face must have a rounded jaw, legible eyes and a broad smile, not
    # the previous narrow chin / tiny stare. Source Skin stays unchanged.
    var mobile_face_region := headwear.get("head_bounds") as AABB
    var mobile_face_center := mobile_face_region.get_center()
    var mobile_face_size := mobile_face_region.size
    var jaw_edge: Vector3 = headwear.call("_face_point",
        mobile_face_center, mobile_face_size, 0.0, 0.78)
    if absf(jaw_edge.x - mobile_face_center.x) < mobile_face_size.x * 0.25:
        _fail("face jaw remains too narrow for readable stylized expression")
        return
    # The front portrait must use shallow, CLOSED sculpted iris/pupil lenses,
    # not detached spherical beads. They keep their original gaze/blink nodes
    # and sit close to the same real Head-attached almond-eye surface.
    var iris_count := 0
    var pupil_count := 0
    for feature in headwear.find_children("*", "MeshInstance3D", false, false):
        var lens := feature as MeshInstance3D
        var feature_name := String(lens.name)
        if feature_name.begins_with("IrisCatchlight"):
            continue
        if not feature_name.begins_with("Iris") and not feature_name.begins_with("Pupil"):
            continue
        if feature_name.begins_with("Iris"):
            iris_count += 1
        else:
            pupil_count += 1
        if not lens.mesh is ArrayMesh or lens.mesh.get_surface_count() != 1:
            _fail("iris and pupils must use closed sculpted lenses, not spheres")
            return
        if not lens.has_meta("local_eye_geometry"):
            _fail("sculpted eye lens must keep fitted center and radius on portrait scaling")
            return
        var lens_arrays: Array = lens.mesh.surface_get_arrays(0)
        var lens_vertices: PackedVector3Array = lens_arrays[Mesh.ARRAY_VERTEX]
        var lens_normals: PackedVector3Array = lens_arrays[Mesh.ARRAY_NORMAL]
        if lens_vertices.size() < 1000 or lens_normals.size() != lens_vertices.size():
            _fail("convex eye lenses require substantial modeled surface and normals")
            return
        var lens_bounds := lens.mesh.get_aabb()
        if lens_bounds.size.z >= lens_bounds.size.x * 0.5:
            _fail("iris/pupil lens has become a protruding sphere")
            return
    if iris_count != 2 or pupil_count != 2:
        _fail("both eyes must retain separate iris and pupil animation nodes")
        return
    var white_left := headwear.find_child("EyeWhite*", false, false) as MeshInstance3D
    var iris_left := headwear.find_child("Iris*", false, false) as MeshInstance3D
    var pupil_left := headwear.find_child("Pupil*", false, false) as MeshInstance3D
    if white_left == null or iris_left == null or pupil_left == null:
        _fail("recessed eye geometry missing")
        return
    var forward := float(headwear.get("face_sign"))
    var white_front := forward * white_left.position.z + white_left.scale.z * 0.72
    var iris_front := forward * iris_left.position.z + iris_left.scale.z * 0.20
    var pupil_front := forward * pupil_left.position.z + pupil_left.scale.z * 0.20
    if iris_front < white_front or pupil_front <= iris_front or \
            pupil_front - white_front > white_left.scale.z * 0.75:
        _fail("iris/pupil must be layered on the almond eye without floating beads")
        return
    var eye_white := headwear.find_child("EyeWhite*", false, false) as MeshInstance3D
    var smile_mesh := headwear.get_node_or_null("CurvedSmile") as MeshInstance3D
    if eye_white == null:
        _fail("both modeled eyes must remain visible")
        return
    var eye_width_ratio := eye_white.scale.x / (mobile_face_size.x * float(headwear.get("visual_scale")))
    if eye_width_ratio < 0.098 or eye_width_ratio > 0.114:
        _fail("athletic portrait eyes must be readable without oversized cartoon proportions")
        return
    var iris_width_ratio := iris_left.scale.x / eye_white.scale.x
    var pupil_width_ratio := pupil_left.scale.x / iris_left.scale.x
    if iris_width_ratio < 0.37 or iris_width_ratio > 0.45 or \
            pupil_width_ratio < 0.54 or pupil_width_ratio > 0.69:
        _fail("smaller eye, iris and pupil proportions must remain coordinated")
        return
    if smile_mesh == null or smile_mesh.mesh.get_aabb().size.x < mobile_face_size.x * 0.42 or \
            smile_mesh.mesh.get_aabb().size.x > mobile_face_size.x * 0.53:
        _fail("sculpted smile must span the wider rounded jaw")
        return
    var rear_arrays: Array = back_hair.mesh.surface_get_arrays(0)
    var rear_vertices: PackedVector3Array = rear_arrays[Mesh.ARRAY_VERTEX]
    if rear_vertices.size() < 4000:
        _fail("rear hair must have two modeled shell layers and closed edges")
        return
    if back_hair.mesh.get_aabb().size.z < headwear.get("head_bounds").size.z * 0.22:
        _fail("rear hair collapsed into a paper-thin plane")
        return
    var head_region := headwear.get("head_bounds") as AABB
    if float(headwear.get("visual_scale")) < 1.85:
        _fail("expressive face/head must remain readable at mobile landscape chase distance")
        return
    var hair_region := back_hair.mesh.get_aabb()
    if hair_region.size.x < head_region.size.x * 1.2 or hair_region.size.y < head_region.size.y * 0.9:
        _fail("rear hair is too narrow or short to read in smartphone chase view")
        return
    # Real render QA found the first volume was an opaque rectangular slab
    # hiding the nine existing hair locks. Enforce a tapered width profile,
    # dark underlayer and exposed bright lock geometry in chase view.
    var center := head_region.get_center()
    var rx := head_region.size.x * 0.56
    var rz := head_region.size.z * 0.57
    var crown := head_region.position.y + head_region.size.y * 0.85
    var cap_height := head_region.size.y * 0.21
    var root_edge: Vector3 = headwear.call("_back_hair_point", center, head_region.size,
        crown, cap_height, rx, rz, 0.0, 1.0)
    var shoulder_edge: Vector3 = headwear.call("_back_hair_point", center, head_region.size,
        crown, cap_height, rx, rz, 0.5, 1.0)
    var tip_edge: Vector3 = headwear.call("_back_hair_point", center, head_region.size,
        crown, cap_height, rx, rz, 1.0, 1.0)
    if absf(shoulder_edge.x - center.x) < absf(root_edge.x - center.x) * 1.20 or \
            absf(shoulder_edge.x - center.x) < absf(tip_edge.x - center.x) * 1.35:
        _fail("rear hair must have a sculpted shoulder flare and tapered tips")
        return
    var visible_lock := headwear.get_node_or_null("WindSweptBackLock4") as MeshInstance3D
    # The previous bright violet noodle hair distracted from the 65-bone
    # adventurer silhouette. Require layered, matte chestnut locks, a darker
    # continuous undercoat and a shortened, side-swept neck-length profile.
    var underhair := back_hair.material_override as StandardMaterial3D
    var bright_hair: StandardMaterial3D = null
    if visible_lock != null:
        bright_hair = visible_lock.material_override as StandardMaterial3D
    if underhair == null or bright_hair == null or \
            bright_hair.albedo_color.get_luminance() <= underhair.albedo_color.get_luminance() * 1.5:
        _fail("sculpted back locks must visibly contrast against the dark underhair")
        return
    if bright_hair.albedo_color.r < bright_hair.albedo_color.b * 1.4 or \
            bright_hair.roughness < 0.70 or underhair.roughness < 0.80:
        _fail("rear hairstyle must use natural matte layered chestnut, not glossy purple rods")
        return
    var neck_tip: Vector3 = headwear.call("_back_hair_point", center, head_region.size,
        crown, cap_height, rx, rz, 1.0, 0.5)
    if neck_tip.y < head_region.position.y - head_region.size.y * 0.30 or \
            neck_tip.x < center.x + head_region.size.x * 0.04:
        _fail("rear hair must form a shorter asymmetric swept cut above the shoulders")
        return
    var lock_depth := (visible_lock.mesh.get_aabb().get_center().z - center.z) * -float(headwear.get("face_sign"))
    if lock_depth < head_region.size.z * 0.55:
        _fail("back hair locks are buried under the sculpted volume")
        return
    # A real chase render exposed nine straight, vertically stacked rods.
    # Require actual wide, tapered 3D strands fanning out at shoulder level.
    var left_fan := headwear.get_node_or_null("WindSweptBackLock0") as MeshInstance3D
    var right_fan := headwear.get_node_or_null("WindSweptBackLock8") as MeshInstance3D
    if left_fan == null or right_fan == null:
        _fail("missing bilateral swept rear-hair silhouette")
        return
    var left_aabb := left_fan.mesh.get_aabb()
    var right_aabb := right_fan.mesh.get_aabb()
    if left_aabb.size.x < head_region.size.x * 0.25 or right_aabb.size.x < head_region.size.x * 0.25:
        _fail("rear hair still forms vertical rods rather than shoulder-swept locks")
        return
    if right_aabb.get_center().x - left_aabb.get_center().x < head_region.size.x * 0.90:
        _fail("rear hair does not fan out bilaterally in chase camera")
        return
    # The old rear locks floated far beyond the closed hair shell and formed
    # a hollow cage in real chase images. All nine must now hug the sculpted
    # volume while keeping a broad, readable shoulder-level silhouette.
    var attached_locks := headwear.find_children("WindSweptBackLock*", "MeshInstance3D", false, false)
    if attached_locks.size() != 9:
        _fail("expected nine surface-following sculpted rear locks")
        return
    for item in attached_locks:
        var lock := item as MeshInstance3D
        var lock_box := lock.mesh.get_aabb()
        if lock_box.position.x < hair_region.position.x - head_region.size.x * 0.20 or \
                lock_box.end.x > hair_region.end.x + head_region.size.x * 0.20:
            _fail("rear lock forms an outboard hair cage instead of following the closed volume")
            return
        if lock_box.size.y < head_region.size.y * 0.65:
            _fail("surface-following rear locks must retain crown-to-shoulder length")
            return
    for strand in [left_fan, right_fan]:
        var strand_arrays: Array = strand.mesh.surface_get_arrays(0)
        var strand_vertices: PackedVector3Array = strand_arrays[Mesh.ARRAY_VERTEX]
        var strand_normals: PackedVector3Array = strand_arrays[Mesh.ARRAY_NORMAL]
        if strand_vertices.size() < 800 or strand_normals.size() != strand_vertices.size():
            _fail("rear strands must be modeled tapered volumes with normals")
            return
    # V124 facial reconstruction: test the actual two eyes by mesh identity,
    # not float-to-string suffixes (Godot may format -1 as -1 or -1.0).
    var eyes := headwear.find_children("EyeWhite*", "MeshInstance3D", false, false)
    if eyes.size() != 2:
        _fail("expected two face-conforming eyes, found %d" % eyes.size())
        return
    for node in eyes:
        var eye := node as MeshInstance3D
        # The eye must be a genuine smooth, closed almond volume, not the
        # old spherical primitive or a flat quad. No new collision or draw
        # surfaces are introduced; blinking still scales the same eye node.
        if not (eye.mesh is ArrayMesh) or eye.mesh.get_surface_count() != 1:
            _fail("eye white must use a single sculpted almond mesh")
            return
        if not eye.has_meta("local_eye_geometry"):
            _fail("sculpted eye must retain its projected center when head scales")
            return
        var eye_arrays: Array = eye.mesh.surface_get_arrays(0)
        var eye_vertices: PackedVector3Array = eye_arrays[Mesh.ARRAY_VERTEX]
        var eye_normals: PackedVector3Array = eye_arrays[Mesh.ARRAY_NORMAL]
        var eye_indices: PackedInt32Array = eye_arrays[Mesh.ARRAY_INDEX]
        if eye_vertices.size() < 300 or eye_normals.size() != eye_vertices.size() or eye_indices.size() < 2000:
            _fail("almond eye must be a smoothly shaded, fully modeled 3D lens")
            return
        var corner_width := 0.0
        var middle_width := 0.0
        var middle_depth := 0.0
        for point in eye_vertices:
            if absf(point.x) > 0.98:
                corner_width = maxf(corner_width, absf(point.y))
            if absf(point.x) < 0.09:
                middle_width = maxf(middle_width, absf(point.y))
                middle_depth = maxf(middle_depth, absf(point.z))
        if corner_width > 0.15 or middle_width < 0.80 or middle_depth < 0.60:
            _fail("eye must taper to almond corners while retaining true 3D depth")
            return
        # Undo the visual-only stylization transform before checking the
        # original face/eye projection in imported Head-local coordinates.
        var factor := float(headwear.get("visual_scale"))
        var local_eye := head_region.get_center() + (eye.position - head_region.get_center()) / factor
        var face_point: Vector3 = headwear.call("_face_front_point",
            head_region.get_center(), head_region.size, local_eye.x, local_eye.y)
        var offset := (local_eye.z - face_point.z) * float(headwear.get("face_sign"))
        if offset < head_region.size.z * 0.005 or offset > head_region.size.z * 0.07:
            _fail("eye must embed in continuous face surface, not float above it")
            return
    # Compare actual eye-part dimensions, independent of Godot's float
    # suffix formatting. The earlier portrait had oversized cyan irises and
    # tiny pupils; the revised face should read as friendly at chase scale.
    var iris_parts: Array[MeshInstance3D] = []
    for node in headwear.find_children("Iris*", "MeshInstance3D", false, false):
        var part := node as MeshInstance3D
        if not String(part.name).contains("Catchlight"):
            iris_parts.append(part)
    var pupils := headwear.find_children("Pupil*", "MeshInstance3D", false, false)
    if iris_parts.size() != 2 or pupils.size() != 2:
        _fail("facial proportions require two iris/pupil pairs")
        return
    for iris in iris_parts:
        var ratio_ok := false
        for pupil_node in pupils:
            var pupil := pupil_node as MeshInstance3D
            if signf(pupil.position.x - head_region.get_center().x) != \
                    signf(iris.position.x - head_region.get_center().x):
                continue
            var pupil_ratio := pupil.scale.x / maxf(iris.scale.x, 0.00001)
            ratio_ok = pupil_ratio > 0.52 and pupil_ratio < 0.72
        if not ratio_ok:
            _fail("eyes must have readable dark pupils inside restrained cyan irises")
            return
    for landmark in ["UpperLid", "LowerLid", "CurvedBrow", "CheekAccent"]:
        var features := headwear.find_children(landmark + "*", "MeshInstance3D", false, false)
        if features.size() != 2:
            _fail("expected bilateral face-conforming " + landmark)
            return
        for node in features:
            var feature := node as MeshInstance3D
            if feature.mesh == null or feature.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX].size() < 100:
                _fail("missing substantial face-conforming " + landmark)
                return
    for landmark in ["SculptedNoseBridge", "LowerLipContour"]:
        if headwear.find_child(landmark, false, false) == null:
            _fail("sculpted nose/lip anatomy must not be a flat decal")
            return
    # V124 cohesive face redesign: color and anatomy must live on the SAME
    # curved Head-attached surface, not on extra floating rigid face panels.
    var sculpted_face := headwear.get_node_or_null("SculptedContinuousFace") as MeshInstance3D
    if sculpted_face == null or sculpted_face.mesh == null:
        _fail("continuous sculpted face missing")
        return
    var face_mat := sculpted_face.material_override as StandardMaterial3D
    if face_mat == null or not face_mat.vertex_color_use_as_albedo:
        _fail("facial gradients must be baked into the continuous mesh vertex colors")
        return
    var face_arrays: Array = sculpted_face.mesh.surface_get_arrays(0)
    var face_vertices: PackedVector3Array = face_arrays[Mesh.ARRAY_VERTEX]
    var face_colors: PackedColorArray = face_arrays[Mesh.ARRAY_COLOR]
    var face_normals: PackedVector3Array = face_arrays[Mesh.ARRAY_NORMAL]
    if face_vertices.size() < 5000 or face_colors.size() != face_vertices.size() or \
            face_normals.size() != face_vertices.size():
        _fail("face must have continuous high-resolution painted geometry with normals")
        return
    var min_light := 1.0
    var max_light := 0.0
    for color in face_colors:
        min_light = minf(min_light, color.get_luminance())
        max_light = maxf(max_light, color.get_luminance())
    if max_light - min_light < 0.035:
        _fail("face color is flat; cheek/brow/jaw shading has been lost")
        return
    var face_center := head_region.get_center()
    var face_size := head_region.size
    var face_u := 0.25 if float(headwear.get("face_sign")) > 0.0 else 0.75
    var nose_point: Vector3 = headwear.call("_face_point", face_center, face_size, face_u, 0.52)
    var side_point: Vector3 = headwear.call("_face_point", face_center, face_size,
        face_u - 0.12, 0.52)
    var protrusion := (nose_point.z - side_point.z) * float(headwear.get("face_sign"))
    if protrusion < face_size.z * 0.08:
        _fail("sculpted nose/cheek relief must remain visible in front view")
        return
    # Portrait silhouette gate: the continuous head surface must have
    # wider cheek/jaw anatomy and a less elongated profile, with facial
    # landmarks still generated by the same inverse projection.
    var cheek_side: Vector3 = headwear.call("_face_point", face_center, face_size, 0.0, 0.50)
    var brow_top: Vector3 = headwear.call("_face_point", face_center, face_size, 0.25, 0.02)
    if cheek_side.x - face_center.x < face_size.x * 0.49:
        _fail("new portrait face is still too narrow in the chase/menu silhouette")
        return
    if brow_top.y - face_center.y > face_size.y * 0.50:
        _fail("portrait facial shell is still vertically elongated")
        return
    var chin_edge: Vector3 = headwear.call("_face_point", face_center, face_size, 0.0, 0.78)
    if chin_edge.x - face_center.x >= (cheek_side.x - face_center.x) * 0.57:
        _fail("athletic portrait needs a genuinely tapered jaw, not a round face mask")
        return
    var portrait_smile := headwear.get_node_or_null("CurvedSmile") as MeshInstance3D
    if portrait_smile == null or portrait_smile.mesh.get_aabb().size.x < face_size.x * 0.42 or \
            portrait_smile.mesh.get_aabb().size.x > face_size.x * 0.53:
        _fail("restrained smile must remain actual curved facial geometry")
        return
    var highlights := headwear.find_children("IrisCatchlight*", "MeshInstance3D", false, false)
    if highlights.size() != 4:
        _fail("both expressive irises need two modeled highlights each")
        return
    for highlight in highlights:
        var glint := highlight as MeshInstance3D
        if glint.mesh == null or glint.mesh.get_surface_count() == 0:
            _fail("iris highlight has no renderable geometry")
            return
    var vertices := 0
    for item in meshes:
        var part := item as MeshInstance3D
        if part == null or part.mesh == null or part.mesh.get_surface_count() == 0:
            _fail("headwear contains an invalid 3D surface")
            return
        vertices += part.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX].size()
    if vertices < 1800:
        _fail("headwear must be curved modeled geometry, not primitive boxes")
        return
    var bounds := headwear.get("head_bounds") as AABB
    if bounds.size.x < 0.08 or bounds.size.y < 0.08:
        _fail("head dimensions must come from actual imported weighted head vertices")
        return
    if headwear.find_children("*", "CollisionObject3D", true, false).size() > 0:
        _fail("cosmetic headwear must never alter gameplay collisions")
        return
    var head_id := rig.find_bone("Head")
    # Regression for the real glTF failure mode: named Skin binds have
    # get_bind_bone() == -1, but must still resolve to imported Head.
    var named_skin := Skin.new()
    named_skin.add_named_bind("Head", Transform3D.IDENTITY)
    named_skin.add_named_bind("pelvis", Transform3D.IDENTITY)
    if not bool(headwear.call("_bind_targets_head", named_skin, 0, head_id, rig)):
        _fail("named glTF Head bind was not resolved to the original skeleton")
        return
    if bool(headwear.call("_bind_targets_head", named_skin, 1, head_id, rig)):
        _fail("non-head named bind incorrectly selected as Head")
        return
    var initial := rig.get_bone_pose_rotation(head_id)
    rider.set("lean", 0.85)
    rider.set("boosting", true)
    adapter.call("_process", 0.40)
    await process_frame
    var moved := rig.get_bone_pose_rotation(head_id)
    if moved.angle_to(initial) < 0.08:
        _fail("headwear's imported Head bone did not animate")
        return
    var original_meshes: Array = adapter.get("skinned_meshes")
    var original_vertices := 0
    for item in original_meshes:
        var original := item as MeshInstance3D
        if original == null or original.skin == null or original.skin.get_bind_count() < 50:
            _fail("headwear must not remove or replace real GPU skin")
            return
        for surface in range(original.mesh.get_surface_count()):
            original_vertices += original.mesh.surface_get_arrays(surface)[Mesh.ARRAY_VERTEX].size()
    if original_vertices < 8000:
        _fail("original skinned body mesh unexpectedly changed")
        return
    print("EXTERNAL HEADGEAR TEST PASSED: %d curved accessory vertices, %d original skinned body vertices, real Head bone pose" % [vertices, original_vertices])
    quit(0)
