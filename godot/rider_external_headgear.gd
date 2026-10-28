extends BoneAttachment3D
## V124 WIP: lightweight authored-in-code curved headgear for the actual CC0
## skinned 65-bone avatar. This attachment follows the imported Head bone;
## it does not replace the weighted face, skeleton, or bind matrices.
## All geometry is generated locally, with no paid or third-party textures.

var head_bounds: AABB
var face_sign: float = -1.0
var generated_meshes: Array[MeshInstance3D] = []
var visual_scale: float = 1.0

func set_visual_scale(factor: float) -> void:
    # BoneAttachment3D follows the imported Head and may overwrite its own
    # transform. Scale the actual visual meshes around the sampled head center
    # instead, preserving the original 65-bone Skin and stable Head binding.
    if factor < 1.0 or factor > 2.35 or absf(visual_scale - 1.0) > 0.001:
        return
    var center := head_bounds.get_center()
    for part in generated_meshes:
        if part.mesh is ArrayMesh:
            # Procedural surfaces store their points in Head-local coordinates.
            part.position = center * (1.0 - factor)
            part.scale = Vector3.ONE * factor
        else:
            # Eye ellipsoids store their center in the node transform.
            part.position = center + (part.position - center) * factor
            part.scale *= factor
    visual_scale = factor

func install(rig: Skeleton3D, body_meshes: Array[MeshInstance3D]) -> bool:
    if rig == null:
        return false
    var head_id := rig.find_bone("Head")
    if head_id < 0:
        return false
    var head_rest := rig.get_bone_global_rest(head_id)
    var inverse_rest := head_rest.affine_inverse()
    var lower := Vector3(INF, INF, INF)
    var upper := Vector3(-INF, -INF, -INF)
    var count := 0
    # glTF often stores named Skin binds with get_bind_bone() == -1.
    # Resolve imported bind names against the real Skeleton3D once per mesh.
    var eye_position := Vector3.ZERO
    var has_eyes := false
    for body in body_meshes:
        if body == null or body.mesh == null or body.skin == null:
            continue
        if String(body.name).to_lower().contains("eyes"):
            eye_position = inverse_rest * rig.to_local(body.to_global(body.get_aabb().get_center()))
            has_eyes = true
        var head_bind_ids: Dictionary = {}
        for bind_index in range(body.skin.get_bind_count()):
            if _bind_targets_head(body.skin, bind_index, head_id, rig):
                head_bind_ids[bind_index] = true
        for surface in range(body.mesh.get_surface_count()):
            var arrays: Array = body.mesh.surface_get_arrays(surface)
            var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
            var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
            var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
            if weights.size() < vertices.size() * 4 or bones.size() < vertices.size() * 4:
                continue
            for vertex_id in range(vertices.size()):
                var head_weight := 0.0
                for influence in range(4):
                    var skin_index := bones[vertex_id * 4 + influence]
                    if skin_index >= 0 and skin_index < body.skin.get_bind_count():
                        if head_bind_ids.has(skin_index):
                            head_weight += weights[vertex_id * 4 + influence]
                if head_weight < 0.45:
                    continue
                var point := inverse_rest * rig.to_local(body.to_global(vertices[vertex_id]))
                lower = lower.min(point)
                upper = upper.max(point)
                count += 1
    var span := upper - lower
    if count < 35 or span.x < 0.08 or span.y < 0.08 or span.z < 0.08 or span.length() > 4.0:
        # Some glTF exporters bind head vertices through a neck/face joint,
        # not directly through Head. Recover from the uppermost 18% of the
        # actual weighted body geometry; never invent a fixed-size head.
        var fallback := _bounds_from_upper_body(rig, body_meshes, inverse_rest)
        if fallback.size.x < 0.08 or fallback.size.y < 0.08 or fallback.size.z < 0.08:
            push_warning("CC0 head bounds invalid: direct=%d span=%s fallback=%s" % [count, span, fallback.size])
            return false
        lower = fallback.position
        upper = fallback.end
        span = fallback.size
    head_bounds = AABB(lower, span)
    face_sign = 1.0 if has_eyes and eye_position.z > head_bounds.get_center().z else -1.0
    bone_name = "Head"
    rig.add_child(self)
    name = "ExternalHeroHeadgear"
    _build_headwear()
    return generated_meshes.size() >= 9

func _bind_targets_head(skin: Skin, bind_index: int, head_id: int, rig: Skeleton3D) -> bool:
    if bind_index < 0 or bind_index >= skin.get_bind_count():
        return false
    var bound_bone := skin.get_bind_bone(bind_index)
    if bound_bone >= 0:
        return bound_bone == head_id
    var bound_name := String(skin.get_bind_name(bind_index))
    return not bound_name.is_empty() and rig.find_bone(bound_name) == head_id

func _bounds_from_upper_body(rig: Skeleton3D, meshes: Array[MeshInstance3D], inverse_rest: Transform3D) -> AABB:
    var bottom := INF
    var top := -INF
    var body_center_x := 0.0
    var count := 0
    for body in meshes:
        for surface in range(body.mesh.get_surface_count()):
            var vertices: PackedVector3Array = body.mesh.surface_get_arrays(surface)[Mesh.ARRAY_VERTEX]
            for vertex in vertices:
                var point := rig.to_local(body.to_global(vertex))
                bottom = minf(bottom, point.y)
                top = maxf(top, point.y)
                body_center_x += point.x
                count += 1
    if count < 100 or top - bottom < 0.5:
        return AABB()
    body_center_x /= float(count)
    var cutoff := bottom + (top - bottom) * 0.80
    var max_offset := (top - bottom) * 0.20
    var lower := Vector3(INF, INF, INF)
    var upper := Vector3(-INF, -INF, -INF)
    var selected := 0
    for body in meshes:
        for surface in range(body.mesh.get_surface_count()):
            var vertices: PackedVector3Array = body.mesh.surface_get_arrays(surface)[Mesh.ARRAY_VERTEX]
            for vertex in vertices:
                var point := rig.to_local(body.to_global(vertex))
                if point.y < cutoff or absf(point.x - body_center_x) > max_offset:
                    continue
                var local := inverse_rest * point
                lower = lower.min(local)
                upper = upper.max(local)
                selected += 1
    if selected < 30:
        return AABB()
    return AABB(lower, upper - lower)

func _material(color: Color, metallic: float = 0.0, roughness: float = 0.5, transparent: bool = false) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.metallic = metallic
    mat.roughness = roughness
    mat.cull_mode = BaseMaterial3D.CULL_DISABLED
    if transparent:
        mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    return mat

func _mesh(name_text: String, surface: ArrayMesh, mat: Material) -> void:
    if surface == null:
        return
    var instance := MeshInstance3D.new()
    instance.name = name_text
    instance.mesh = surface
    instance.material_override = mat
    add_child(instance)
    generated_meshes.append(instance)

func _build_headwear() -> void:
    var c := head_bounds.get_center()
    var s := head_bounds.size
    var radius_x := s.x * 0.56
    var radius_z := s.z * 0.57
    var crown_y := head_bounds.position.y + s.y * 0.85
    var cap_height := s.y * 0.21
    var cap := SurfaceTool.new()
    cap.begin(Mesh.PRIMITIVE_TRIANGLES)
    for row in range(10):
        var a0 := float(row) / 10.0 * PI * 0.5
        var a1 := float(row + 1) / 10.0 * PI * 0.5
        for column in range(32):
            var t0 := float(column) / 32.0 * TAU
            var t1 := float(column + 1) / 32.0 * TAU
            _quad(cap, _cap_point(c, radius_x, radius_z, crown_y, cap_height, a0, t0),
                _cap_point(c, radius_x, radius_z, crown_y, cap_height, a1, t0),
                _cap_point(c, radius_x, radius_z, crown_y, cap_height, a1, t1),
                _cap_point(c, radius_x, radius_z, crown_y, cap_height, a0, t1))
    cap.generate_normals()
    _mesh("CurvedFlightHelmetShell", cap.commit(), _material(Color(0.18, 0.095, 0.42), 0.35, 0.34))

    var visor := SurfaceTool.new()
    visor.begin(Mesh.PRIMITIVE_TRIANGLES)
    for row in range(5):
        var v0 := float(row) / 5.0
        var v1 := float(row + 1) / 5.0
        for column in range(24):
            var u0 := -0.93 + float(column) / 24.0 * 1.86
            var u1 := -0.93 + float(column + 1) / 24.0 * 1.86
            _quad(visor, _visor_point(c, s, u0, v0),
                _visor_point(c, s, u0, v1),
                _visor_point(c, s, u1, v1),
                _visor_point(c, s, u1, v0))
    visor.generate_normals()
    _mesh("TranslucentFaceShield", visor.commit(), _material(Color(0.10, 0.67, 0.92, 0.24), 0.35, 0.16, true))

    var edge_mat := _material(Color(0.07, 0.80, 0.96), 0.30, 0.25)
    edge_mat.emission_enabled = true
    edge_mat.emission = Color(0.02, 0.32, 0.55)
    edge_mat.emission_energy_multiplier = 1.2
    for edge in [0.0, 1.0]:
        var points: Array[Vector3] = []
        for segment in range(25):
            points.append(_visor_point(c, s, -0.93 + float(segment) / 24.0 * 1.86, edge))
        _mesh("VisorLightEdge%d" % int(edge), _tube(points, s.x * 0.018, 6), edge_mat)

    var hair_mat := _material(Color(0.48, 0.24, 0.76), 0.08, 0.48)
    var highlight := _material(Color(0.78, 0.43, 0.96), 0.12, 0.37)
    for strand in range(7):
        var across := (float(strand) - 3.0) / 3.0
        var start := Vector3(c.x + across * radius_x * 0.46, crown_y + cap_height * 0.94,
            c.z - face_sign * radius_z * 0.18)
        var end := Vector3(c.x + across * radius_x * 0.85,
            crown_y - s.y * (0.025 + 0.035 * absf(across)),
            c.z + face_sign * radius_z * 1.05)
        var mid := Vector3(c.x + across * radius_x * 0.72,
            crown_y + cap_height * 0.52, c.z + face_sign * radius_z * 0.66)
        var points: Array[Vector3] = []
        for segment in range(13):
            var t := float(segment) / 12.0
            points.append(start * (1.0 - t) * (1.0 - t) + mid * (2.0 * t * (1.0 - t)) + end * (t * t))
        _mesh("SweptHairLock%d" % strand, _tube(points, s.x * (0.047 if strand % 2 == 0 else 0.038), 7),
            highlight if strand % 3 == 0 else hair_mat)
    for side in [-1.0, 1.0]:
        var arc: Array[Vector3] = []
        for segment in range(11):
            var t := float(segment) / 10.0
            arc.append(Vector3(c.x + side * radius_x * (0.88 + 0.08 * sin(t * PI)),
                crown_y + cap_height * (0.20 - t * 0.9),
                c.z + face_sign * radius_z * (0.05 + 0.25 * t)))
        _mesh("SideHairSweep%s" % ("L" if side < 0.0 else "R"),
            _tube(arc, s.x * 0.065, 7), hair_mat)
    # A 360-degree character needs a readable REAR silhouette as well.
    # The old V124 trial had a nearly bald head in chase camera, even though
    # the front showed swept bangs. Curved back-hair geometry remains cosmetic
    # and follows the real Head bone through this BoneAttachment3D.
    # Dark underlayer gives the bright sculpted locks readable depth in chase view.
    var underhair := _material(Color(0.19, 0.085, 0.35), 0.05, 0.68)
    _mesh("SculptedBackHairCurtain", _back_hair_surface(c, s, crown_y, cap_height, radius_x, radius_z),
        underhair)
    # The previous free-floating nine rear arcs formed a hollow cage around
    # the head in the actual chase capture. Lay sculpted tapered locks over
    # the SAME continuous closed rear hair volume instead: each follows the
    # underlayer's shoulder flare and taper, rather than making giant loops.
    # No extra rig, physics, textures, collisions or new draw passes.
    for strand in range(9):
        var u := (float(strand) + 0.5) / 9.0
        var flow: Array[Vector3] = []
        for segment in range(17):
            var t := float(segment) / 16.0
            var point := _back_hair_point(c, s, crown_y, cap_height,
                radius_x, radius_z, t, u)
            point.x += sin(t * PI * 1.5 + float(strand) * 0.35) * \
                radius_x * 0.07 * sin(PI * t)
            point.z -= face_sign * s.z * (0.17 + 0.018 * sin(PI * t))
            point.y += s.y * 0.025 * (1.0 - t)
            flow.append(point)
        _mesh("WindSweptBackLock%d" % strand,
            _tapered_hair_lock(flow, s.x * (0.060 if strand % 2 == 0 else 0.052), 9),
            highlight if strand % 3 == 0 else hair_mat)
    # One coherent, tapered hairline frames the face while the back curtain
    # gains a real inner/outer volume. These follow the imported Head joint.
    var fringe_mat := _material(Color(0.64, 0.33, 0.85), 0.06, 0.44)
    # The previous six thick round tubes looked like beads above the forehead
    # in real 16:9 captures. Sculpt broad, flattened 3D swept bangs instead:
    # curved from the helmet crown to the upper forehead with a tapered tip.
    for strand in range(6):
        var across := (float(strand) - 2.5) / 2.5
        var root := Vector3(c.x + across * radius_x * 0.69,
            crown_y + cap_height * 0.25, c.z + face_sign * radius_z * 0.38)
        var tip := Vector3(c.x + across * radius_x * 0.88 + radius_x * 0.06,
            head_bounds.position.y + s.y * (0.72 + 0.025 * absf(across)),
            c.z + face_sign * radius_z * (0.94 - 0.09 * absf(across)))
        var control := Vector3(c.x + across * radius_x * 0.94,
            crown_y + cap_height * 0.57, c.z + face_sign * radius_z * 0.91)
        _mesh("SculptedTaperedFringe%d" % strand,
            _sculpted_fringe_ribbon(root, control, tip, s.x * 0.20, s.z * 0.035),
            fringe_mat if strand % 2 == 0 else hair_mat)
    _build_expression(c, s)

func _sculpted_fringe_ribbon(root: Vector3, control: Vector3, tip: Vector3,
        width: float, thickness: float) -> ArrayMesh:
    # A closed, curved, tapered volumetric hair ribbon. Broad faces catch light
    # like sculpted hair, rather than six circular pipe cross-sections.
    var surface := SurfaceTool.new()
    surface.begin(Mesh.PRIMITIVE_TRIANGLES)
    var segments := 22
    var strips := 5
    for segment in range(segments):
        var t0 := float(segment) / float(segments)
        var t1 := float(segment + 1) / float(segments)
        for strip in range(strips):
            var u0 := float(strip) / float(strips)
            var u1 := float(strip + 1) / float(strips)
            for outer in [true, false]:
                var a := _fringe_ribbon_point(root, control, tip, width, thickness, t0, u0, outer)
                var b := _fringe_ribbon_point(root, control, tip, width, thickness, t1, u0, outer)
                var d := _fringe_ribbon_point(root, control, tip, width, thickness, t0, u1, outer)
                var e := _fringe_ribbon_point(root, control, tip, width, thickness, t1, u1, outer)
                if outer:
                    _quad(surface, a, b, e, d)
                else:
                    _quad(surface, d, e, b, a)
        for u in [0.0, 1.0]:
            _quad(surface,
                _fringe_ribbon_point(root, control, tip, width, thickness, t0, u, true),
                _fringe_ribbon_point(root, control, tip, width, thickness, t1, u, true),
                _fringe_ribbon_point(root, control, tip, width, thickness, t1, u, false),
                _fringe_ribbon_point(root, control, tip, width, thickness, t0, u, false))
    for t in [0.0, 1.0]:
        for strip in range(strips):
            var u0 := float(strip) / float(strips)
            var u1 := float(strip + 1) / float(strips)
            _quad(surface,
                _fringe_ribbon_point(root, control, tip, width, thickness, t, u0, true),
                _fringe_ribbon_point(root, control, tip, width, thickness, t, u1, true),
                _fringe_ribbon_point(root, control, tip, width, thickness, t, u1, false),
                _fringe_ribbon_point(root, control, tip, width, thickness, t, u0, false))
    surface.generate_normals()
    return surface.commit()

func _fringe_ribbon_point(root: Vector3, control: Vector3, tip: Vector3,
        width: float, thickness: float, t: float, u: float, outer: bool) -> Vector3:
    var center := root * pow(1.0 - t, 2.0) + control * (2.0 * t * (1.0 - t)) + tip * t * t
    var taper := maxf(0.07, sin(PI * (0.08 + 0.84 * t)))
    var across := (u - 0.5) * width * taper
    return center + Vector3(across, 0.012 * width * sin(PI * u) * sin(PI * t),
        face_sign * thickness * (0.60 if outer else -0.40))

func _tapered_hair_lock(points: Array[Vector3], radius: float, sides: int) -> ArrayMesh:
    # Sculpted, CLOSED hair ribbons replace the nine round pipe-like rear
    # strands that made the chase silhouette resemble a wire cage.
    # Each lock has broad curved faces, tapered ends and real thickness;
    # it remains a cosmetic part of the imported Head BoneAttachment3D.
    var surface := SurfaceTool.new()
    surface.begin(Mesh.PRIMITIVE_TRIANGLES)
    var strips := maxi(4, sides - 3)
    for segment in range(points.size() - 1):
        var t0 := float(segment) / float(points.size() - 1)
        var t1 := float(segment + 1) / float(points.size() - 1)
        for strip in range(strips):
            var u0 := float(strip) / float(strips)
            var u1 := float(strip + 1) / float(strips)
            for outer in [true, false]:
                var a := _back_lock_point(points, radius, t0, u0, outer)
                var b := _back_lock_point(points, radius, t1, u0, outer)
                var c := _back_lock_point(points, radius, t1, u1, outer)
                var d := _back_lock_point(points, radius, t0, u1, outer)
                if outer:
                    _quad(surface, a, b, c, d)
                else:
                    _quad(surface, d, c, b, a)
        for u in [0.0, 1.0]:
            _quad(surface,
                _back_lock_point(points, radius, t0, u, true),
                _back_lock_point(points, radius, t1, u, true),
                _back_lock_point(points, radius, t1, u, false),
                _back_lock_point(points, radius, t0, u, false))
    for t in [0.0, 1.0]:
        for strip in range(strips):
            var u0 := float(strip) / float(strips)
            var u1 := float(strip + 1) / float(strips)
            _quad(surface,
                _back_lock_point(points, radius, t, u0, true),
                _back_lock_point(points, radius, t, u1, true),
                _back_lock_point(points, radius, t, u1, false),
                _back_lock_point(points, radius, t, u0, false))
    surface.generate_normals()
    return surface.commit()

func _back_lock_point(points: Array[Vector3], radius: float, t: float,
        u: float, outer: bool) -> Vector3:
    var scaled := clampf(t, 0.0, 1.0) * float(points.size() - 1)
    var index := mini(int(floor(scaled)), points.size() - 2)
    var alpha := scaled - float(index)
    var center := points[index].lerp(points[index + 1], alpha)
    var taper := maxf(0.09, sin(PI * (0.09 + 0.82 * t)))
    var broad := (u - 0.5) * radius * 2.65 * taper
    var groove := sin(u * PI) * sin(t * PI) * radius * 0.14
    var depth := radius * 0.30 * taper
    return center + Vector3(broad, groove,
        -face_sign * depth * (0.75 if outer else -0.50))

func _back_hair_surface(c: Vector3, s: Vector3, crown_y: float, cap_height: float,
        radius_x: float, radius_z: float) -> ArrayMesh:
    # Closed, double-sided sculpted hair volume, not a single flat card.
    # The inner shell avoids a paper-thin silhouette in chase/side views.
    var surface := SurfaceTool.new()
    surface.begin(Mesh.PRIMITIVE_TRIANGLES)
    var rows := 14
    var columns := 24
    for row in range(rows):
        var t0 := float(row) / float(rows)
        var t1 := float(row + 1) / float(rows)
        for column in range(columns):
            var u0 := float(column) / float(columns)
            var u1 := float(column + 1) / float(columns)
            for outer in [true, false]:
                var a := _back_hair_volume_point(c, s, crown_y, cap_height, radius_x, radius_z, t0, u0, outer)
                var b := _back_hair_volume_point(c, s, crown_y, cap_height, radius_x, radius_z, t1, u0, outer)
                var d := _back_hair_volume_point(c, s, crown_y, cap_height, radius_x, radius_z, t0, u1, outer)
                var e := _back_hair_volume_point(c, s, crown_y, cap_height, radius_x, radius_z, t1, u1, outer)
                if outer:
                    _quad(surface, a, b, e, d)
                else:
                    _quad(surface, d, e, b, a)
        for u in [0.0, 1.0]:
            _quad(surface,
                _back_hair_volume_point(c, s, crown_y, cap_height, radius_x, radius_z, t0, u, true),
                _back_hair_volume_point(c, s, crown_y, cap_height, radius_x, radius_z, t1, u, true),
                _back_hair_volume_point(c, s, crown_y, cap_height, radius_x, radius_z, t1, u, false),
                _back_hair_volume_point(c, s, crown_y, cap_height, radius_x, radius_z, t0, u, false))
    for t in [0.0, 1.0]:
        for column in range(columns):
            var u0 := float(column) / float(columns)
            var u1 := float(column + 1) / float(columns)
            _quad(surface,
                _back_hair_volume_point(c, s, crown_y, cap_height, radius_x, radius_z, t, u0, true),
                _back_hair_volume_point(c, s, crown_y, cap_height, radius_x, radius_z, t, u1, true),
                _back_hair_volume_point(c, s, crown_y, cap_height, radius_x, radius_z, t, u1, false),
                _back_hair_volume_point(c, s, crown_y, cap_height, radius_x, radius_z, t, u0, false))
    surface.generate_normals()
    return surface.commit()

func _back_hair_volume_point(c: Vector3, s: Vector3, crown_y: float, cap_height: float,
        radius_x: float, radius_z: float, t: float, u: float, outer: bool) -> Vector3:
    var point := _back_hair_point(c, s, crown_y, cap_height, radius_x, radius_z, t, u)
    var thickness := s.z * (0.14 + 0.045 * sin(PI * t))
    point.z += -face_sign * thickness * (0.65 if outer else -0.35)
    point.x += (u - 0.5) * s.x * (0.09 if outer else -0.025)
    return point

func _back_hair_point(c: Vector3, s: Vector3, crown_y: float, cap_height: float,
        radius_x: float, radius_z: float, t: float, u: float) -> Vector3:
    # Sculpted silhouette: broad at shoulder, tapered toward the ends and
    # split into softly scalloped locks. Avoid a rectangular purple hair slab.
    var angle := (u - 0.5) * PI
    var edge := sin(angle)
    var width_profile := 1.12 + 0.55 * sin(PI * t) - 0.24 * t
    var strand_wave := 0.07 * sin(7.0 * angle + 2.5 * t) * sin(PI * t)
    var hem := 0.13 * pow(t, 5.0) * (0.5 + 0.5 * cos(7.0 * angle))
    return Vector3(
        c.x + (edge * width_profile + strand_wave) * radius_x,
        crown_y + cap_height * 0.20 - s.y * (0.20 + 1.23 * t - hem),
        c.z - face_sign * cos(angle) * radius_z *
            (0.97 + 0.23 * t + 0.07 * sin(5.0 * angle) * sin(PI * t)))

func _build_expression(c: Vector3, s: Vector3) -> void:
    # The facial features must follow the ACTUAL sculpted head surface.
    # The previous fixed front plane left eyes/brows/smile visibly floating
    # in the front render; calculate each landmark from the same face mesh.
    # Paint warm cheeks, cool eye sockets and a readable jaw directly on the
    # continuous sculpted head. Vertex colors avoid extra draw calls/textures.
    var face_material := _material(Color.WHITE, 0.0, 0.71)
    face_material.vertex_color_use_as_albedo = true
    _mesh("SculptedContinuousFace", _face_surface(c, s), face_material)
    var white := _material(Color(0.96, 0.98, 1.0), 0.0, 0.25)
    var iris := _material(Color(0.10, 0.70, 0.91), 0.04, 0.24)
    var pupil := _material(Color(0.025, 0.038, 0.11), 0.0, 0.22)
    var eye_glint := _material(Color(0.96, 0.98, 1.0), 0.0, 0.16)
    eye_glint.emission_enabled = true
    eye_glint.emission = Color(0.30, 0.52, 0.70)
    eye_glint.emission_energy_multiplier = 0.45
    var ink := _material(Color(0.14, 0.075, 0.22), 0.0, 0.76)
    var lid_mat := _material(Color(0.30, 0.14, 0.28), 0.0, 0.66)
    var blush := _material(Color(0.77, 0.36, 0.43), 0.0, 0.79)
    var eye_y := head_bounds.position.y + s.y * 0.57
    for side in [-1.0, 1.0]:
        var eye_x: float = c.x + side * s.x * 0.22
        var base := _face_front_point(c, s, eye_x, eye_y)
        _ellipsoid("EyeWhite%s" % str(side),
            base + Vector3(0.0, 0.0, face_sign * s.z * 0.024),
            Vector3(s.x * 0.112, s.y * 0.086, s.z * 0.049), white)
        _ellipsoid("Iris%s" % str(side),
            base + Vector3(0.0, 0.0, face_sign * s.z * 0.073),
            Vector3(s.x * 0.057, s.y * 0.061, s.z * 0.023), iris)
        _ellipsoid("Pupil%s" % str(side),
            base + Vector3(0.0, 0.0, face_sign * s.z * 0.094),
            Vector3(s.x * 0.026, s.y * 0.035, s.z * 0.014), pupil)
        # Two small highlights are embedded in each iris, not floating props.
        # They remain visible in the 1280x720 and 1170x540 front cameras.
        _ellipsoid("IrisCatchlight%s_Main" % str(side),
            base + Vector3(-s.x * 0.012, s.y * 0.016, face_sign * s.z * 0.109),
            Vector3(s.x * 0.012, s.y * 0.016, s.z * 0.007), eye_glint)
        _ellipsoid("IrisCatchlight%s_Small" % str(side),
            base + Vector3(s.x * 0.015, -s.y * 0.013, face_sign * s.z * 0.108),
            Vector3(s.x * 0.006, s.y * 0.008, s.z * 0.005), eye_glint)
        var upper_lid: Array[Vector3] = []
        var lower_lid: Array[Vector3] = []
        var brow: Array[Vector3] = []
        var cheek: Array[Vector3] = []
        for i in range(17):
            var t := float(i) / 16.0
            var x := eye_x + (t - 0.5) * s.x * 0.245
            var arc := sin(t * PI)
            var upper_y := eye_y + s.y * (0.012 + 0.092 * arc)
            var lower_y := eye_y - s.y * (0.016 + 0.078 * arc)
            upper_lid.append(_face_front_point(c, s, x, upper_y) +
                Vector3(0.0, 0.0, face_sign * s.z * 0.069))
            lower_lid.append(_face_front_point(c, s, x, lower_y) +
                Vector3(0.0, 0.0, face_sign * s.z * 0.058))
            var brow_y := eye_y + s.y * (0.165 + 0.025 * arc)
            brow.append(_face_front_point(c, s, x, brow_y) +
                Vector3(0.0, 0.0, face_sign * s.z * 0.027))
            var cheek_y := eye_y - s.y * (0.170 + 0.015 * arc)
            cheek.append(_face_front_point(c, s, x, cheek_y) +
                Vector3(0.0, 0.0, face_sign * s.z * 0.020))
        _mesh("UpperLid%s" % str(side), _tube(upper_lid, s.x * 0.013, 6), lid_mat)
        _mesh("LowerLid%s" % str(side), _tube(lower_lid, s.x * 0.009, 6), lid_mat)
        _mesh("CurvedBrow%s" % str(side), _tube(brow, s.x * 0.020, 6), ink)
        _mesh("CheekAccent%s" % str(side), _tube(cheek, s.x * 0.017, 6), blush)
    var nose_bridge: Array[Vector3] = []
    for i in range(13):
        var t := float(i) / 12.0
        var y := head_bounds.position.y + s.y * (0.53 - 0.16 * t)
        nose_bridge.append(_face_front_point(c, s, c.x, y) +
            Vector3(0.0, 0.0, face_sign * s.z * 0.016))
    _mesh("SculptedNoseBridge", _tube(nose_bridge, s.x * 0.017, 7),
        _material(Color(0.91, 0.61, 0.50), 0.0, 0.74))
    var smile: Array[Vector3] = []
    var lower_lip: Array[Vector3] = []
    for i in range(21):
        var t := float(i) / 20.0
        var x := c.x + (t - 0.5) * s.x * 0.39
        var y := head_bounds.position.y + s.y * (0.29 + 0.055 * pow(2.0 * t - 1.0, 2.0))
        smile.append(_face_front_point(c, s, x, y) +
            Vector3(0.0, 0.0, face_sign * s.z * 0.026))
        lower_lip.append(_face_front_point(c, s, x, y - s.y * 0.032 * sin(t * PI)) +
            Vector3(0.0, 0.0, face_sign * s.z * 0.023))
    _mesh("CurvedSmile", _tube(smile, s.x * 0.014, 6), ink)
    _mesh("LowerLipContour", _tube(lower_lip, s.x * 0.012, 6), blush)

func _face_front_point(c: Vector3, s: Vector3, x: float, y: float) -> Vector3:
    # Invert the face's latitude/longitude parameterization so eyes, lids,
    # cheeks and mouth sit on the same curved, jaw-tapered mesh.
    var latitude := acos(clampf((y - c.y) / maxf(s.y * 0.54, 0.001), -0.98, 0.98))
    var v := latitude / PI
    var jaw := 0.75 + 0.25 * smoothstep(0.12, 0.67, 1.0 - v)
    var radius := maxf(0.001, sin(latitude) * s.x * 0.49 * jaw)
    var angle := acos(clampf((x - c.x) / radius, -0.985, 0.985))
    if face_sign < 0.0:
        angle = TAU - angle
    return _face_point(c, s, angle / TAU, v)

func _face_surface(c: Vector3, s: Vector3) -> ArrayMesh:
    # One continuous, vertex-painted face: cheek warmth, brow shadows and
    # chin shading share the SAME curved mesh, without decals or extra passes.
    var surface := SurfaceTool.new()
    surface.begin(Mesh.PRIMITIVE_TRIANGLES)
    for row in range(24):
        var v0 := float(row) / 24.0
        var v1 := float(row + 1) / 24.0
        for column in range(40):
            var u0 := float(column) / 40.0
            var u1 := float(column + 1) / 40.0
            for uv in [Vector2(u0, v0), Vector2(u0, v1), Vector2(u1, v1),
                    Vector2(u0, v0), Vector2(u1, v1), Vector2(u1, v0)]:
                surface.set_color(_face_color(c, s, uv.x, uv.y))
                surface.add_vertex(_face_point(c, s, uv.x, uv.y))
    surface.generate_normals()
    return surface.commit()

func _face_color(c: Vector3, s: Vector3, u: float, v: float) -> Color:
    var longitude := u * TAU
    var frontness := maxf(0.0, face_sign * sin(longitude))
    var lateral := absf(cos(longitude) * sin(v * PI))
    var cheek := exp(-pow((lateral - 0.48) / 0.22, 2.0)) * exp(-pow((v - 0.58) / 0.14, 2.0))
    var eye_shadow := exp(-pow((lateral - 0.42) / 0.24, 2.0)) * exp(-pow((v - 0.40) / 0.085, 2.0))
    var chin_shadow := smoothstep(0.72, 0.94, v)
    var skin := Color(0.91, 0.64, 0.53)
    skin = skin.lerp(Color(0.98, 0.75, 0.60), 0.22 * frontness)
    skin = skin.lerp(Color(0.88, 0.37, 0.45), cheek * frontness * 0.34)
    skin = skin.lerp(Color(0.45, 0.29, 0.42), eye_shadow * frontness * 0.21)
    skin = skin.lerp(Color(0.48, 0.30, 0.40), chin_shadow * 0.20)
    return skin

func _face_point(c: Vector3, s: Vector3, u: float, v: float) -> Vector3:
    var latitude := v * PI
    var longitude := u * TAU
    var silhouette := sin(latitude)
    var jaw := 0.75 + 0.25 * smoothstep(0.12, 0.67, 1.0 - v)
    var x := cos(longitude) * silhouette * s.x * 0.49 * jaw
    var z := sin(longitude) * silhouette * s.z * 0.52
    # Sculpt the actual facial surface as a coherent 3D shape. The face-front
    # inverse projection uses the SAME x/jaw mapping, keeping eyes/lids seated.
    var frontness := maxf(0.0, face_sign * sin(longitude))
    var nose := exp(-pow(x / maxf(0.01, s.x * 0.12), 2.0)) * exp(-pow((v - 0.52) / 0.13, 2.0))
    var cheek := exp(-pow((absf(x) - s.x * 0.27) / maxf(0.01, s.x * 0.16), 2.0)) * exp(-pow((v - 0.56) / 0.18, 2.0))
    var eye_socket := exp(-pow((absf(x) - s.x * 0.22) / maxf(0.01, s.x * 0.13), 2.0)) * exp(-pow((v - 0.43) / 0.11, 2.0))
    var brow := exp(-pow((v - 0.34) / 0.075, 2.0)) * exp(-pow((absf(x) - s.x * 0.19) / maxf(0.01, s.x * 0.25), 2.0))
    var lips := exp(-pow((v - 0.70) / 0.055, 2.0)) * exp(-pow(x / maxf(0.01, s.x * 0.24), 2.0))
    var chin := exp(-pow((v - 0.79) / 0.10, 2.0)) * exp(-pow(x / maxf(0.01, s.x * 0.27), 2.0))
    z += face_sign * frontness * s.z * (nose * 0.24 + cheek * 0.09 -
        eye_socket * 0.06 + brow * 0.055 + lips * 0.045 + chin * 0.065)
    return Vector3(c.x + x, c.y + cos(latitude) * s.y * 0.54, c.z + z)

func _ellipsoid(name_text: String, center: Vector3, radii: Vector3, mat: Material) -> void:
    var shape := SphereMesh.new()
    shape.radius = 1.0
    shape.height = 2.0
    shape.radial_segments = 16
    shape.rings = 8
    var part := MeshInstance3D.new()
    part.name = name_text
    part.mesh = shape
    part.material_override = mat
    part.position = center
    part.scale = radii
    add_child(part)
    generated_meshes.append(part)

func _cap_point(c: Vector3, rx: float, rz: float, base: float, height: float, elevation: float, azimuth: float) -> Vector3:
    return Vector3(c.x + rx * sin(elevation) * cos(azimuth),
        base + height * cos(elevation),
        c.z + rz * sin(elevation) * sin(azimuth))

func _visor_point(c: Vector3, s: Vector3, angle: float, v: float) -> Vector3:
    return Vector3(c.x + sin(angle) * s.x * 0.51,
        head_bounds.position.y + s.y * (0.77 + (1.0 - v) * 0.12),
        c.z + face_sign * (cos(angle) * s.z * 0.57 + s.z * 0.04))

func _quad(surface: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3) -> void:
    surface.add_vertex(a)
    surface.add_vertex(b)
    surface.add_vertex(c)
    surface.add_vertex(a)
    surface.add_vertex(c)
    surface.add_vertex(d)

func _tube(points: Array[Vector3], radius: float, sides: int) -> ArrayMesh:
    var surface := SurfaceTool.new()
    surface.begin(Mesh.PRIMITIVE_TRIANGLES)
    for segment in range(points.size() - 1):
        var tangent := (points[segment + 1] - points[segment]).normalized()
        var reference := Vector3.UP if absf(tangent.dot(Vector3.UP)) < 0.9 else Vector3.FORWARD
        var normal := tangent.cross(reference).normalized()
        var binormal := tangent.cross(normal).normalized()
        for side in range(sides):
            var angle0 := TAU * float(side) / float(sides)
            var angle1 := TAU * float(side + 1) / float(sides)
            var taper0 := 1.0 - 0.45 * float(segment) / float(points.size() - 1)
            var taper1 := 1.0 - 0.45 * float(segment + 1) / float(points.size() - 1)
            var offset0 := (normal * cos(angle0) + binormal * sin(angle0)) * radius
            var offset1 := (normal * cos(angle1) + binormal * sin(angle1)) * radius
            _quad(surface, points[segment] + offset0 * taper0,
                points[segment + 1] + offset0 * taper1,
                points[segment + 1] + offset1 * taper1,
                points[segment] + offset1 * taper0)
    surface.generate_normals()
    return surface.commit()
