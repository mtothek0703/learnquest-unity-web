extends Node
## V124 visual-readability pass: broad, genuinely GPU-skinned shoulder thrusters.
## All surfaces share the imported CC0 Skin and Skeleton3D. No collision shapes,
## touch changes, gameplay rewards, physics, external assets or historic edits.
var nacelles: Array[MeshInstance3D] = []
var cores: Array[MeshInstance3D] = []
var generated_vertices: int = 0
var rear_sign: float = 1.0
var shoulder_span: float = 0.0

func install(source_meshes: Array[MeshInstance3D], rig: Skeleton3D, face_sign: float) -> bool:
    if rig == null:
        return false
    for body in source_meshes:
        if body == null or body.mesh == null or body.skin == null:
            continue
        if not String(body.name).contains("SuperHero"):
            continue
        var spine := _bind(body.skin, rig, "spine_02")
        if spine < 0:
            spine = _bind(body.skin, rig, "spine_01")
        var pelvis := _bind(body.skin, rig, "pelvis")
        var left_arm := _bind(body.skin, rig, "upperarm_l")
        var right_arm := _bind(body.skin, rig, "upperarm_r")
        if spine < 0 or pelvis < 0 or left_arm < 0 or right_arm < 0:
            continue
        var bounds := body.mesh.get_aabb()
        if bounds.size.y < 0.5 or bounds.size.x < 0.2:
            continue
        rear_sign = -1.0 if face_sign > 0.0 else 1.0
        var back := _torso_back(body.mesh, bounds)
        for side in [-1, 1]:
            var arm := left_arm if side < 0 else right_arm
            var shell := _build_pod(bounds, back, float(side), spine, pelvis, arm, false)
            var core := _build_pod(bounds, back, float(side), spine, pelvis, arm, true)
            if shell == null or core == null:
                return false
            var label := "Left" if side < 0 else "Right"
            nacelles.append(_attach(body, shell, label + "SkinnedShoulderNacelle", false))
            cores.append(_attach(body, core, label + "SkinnedThrusterCore", true))
            generated_vertices += shell.surface_get_arrays(0)[Mesh.ARRAY_VERTEX].size()
            generated_vertices += core.surface_get_arrays(0)[Mesh.ARRAY_VERTEX].size()
        shoulder_span = bounds.size.x * 1.32
        return nacelles.size() == 2 and cores.size() == 2
    return false

func _bind(skin: Skin, rig: Skeleton3D, bone_name_text: String) -> int:
    for i in range(skin.get_bind_count()):
        var name_text := String(skin.get_bind_name(i))
        var id := skin.get_bind_bone(i)
        if name_text == bone_name_text or (name_text.is_empty() and id >= 0 and id < rig.get_bone_count()
                and rig.get_bone_name(id) == bone_name_text):
            return i
    return -1

func _torso_back(mesh: Mesh, bounds: AABB) -> float:
    var extreme := -INF if rear_sign > 0.0 else INF
    var found := false
    for surface in range(mesh.get_surface_count()):
        var vertices: PackedVector3Array = mesh.surface_get_arrays(surface)[Mesh.ARRAY_VERTEX]
        for vertex in vertices:
            var y := (vertex.y - bounds.position.y) / bounds.size.y
            if y < 0.50 or y > 0.73:
                continue
            if absf(vertex.x - bounds.get_center().x) > bounds.size.x * 0.14:
                continue
            extreme = maxf(extreme, vertex.z) if rear_sign > 0.0 else minf(extreme, vertex.z)
            found = true
    if found:
        return extreme
    return bounds.end.z if rear_sign > 0.0 else bounds.position.z

func _build_pod(bounds: AABB, back: float, side: float, spine: int,
        pelvis: int, arm: int, core: bool) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    const ROWS = 18
    const SEGMENTS = 16
    for row in range(ROWS):
        var t0 := float(row) / float(ROWS)
        var t1 := float(row + 1) / float(ROWS)
        for segment in range(SEGMENTS):
            var a0 := TAU * float(segment) / float(SEGMENTS)
            var a1 := TAU * float(segment + 1) / float(SEGMENTS)
            _vertex(tool, bounds, back, side, spine, pelvis, arm, core, t0, a0)
            _vertex(tool, bounds, back, side, spine, pelvis, arm, core, t1, a0)
            _vertex(tool, bounds, back, side, spine, pelvis, arm, core, t1, a1)
            _vertex(tool, bounds, back, side, spine, pelvis, arm, core, t0, a0)
            _vertex(tool, bounds, back, side, spine, pelvis, arm, core, t1, a1)
            _vertex(tool, bounds, back, side, spine, pelvis, arm, core, t0, a1)
    tool.generate_normals()
    return tool.commit()

func _vertex(tool: SurfaceTool, bounds: AABB, back: float, side: float,
        spine: int, pelvis: int, arm: int, core: bool, t: float, angle: float) -> void:
    var width := bounds.size.x
    var height := bounds.size.y
    var shoulder_x := bounds.get_center().x + side * width * 0.48
    var upper_y := bounds.position.y + height * 0.745
    var taper := 0.73 + 0.27 * sin(PI * t)
    var radius_x := width * (0.135 if core else 0.185) * taper
    var radius_z := width * (0.105 if core else 0.150) * taper
    var y := upper_y - height * (0.205 if core else 0.245) * t
    var x := shoulder_x + cos(angle) * radius_x
    var z := back + rear_sign * (width * (0.22 if core else 0.16) +
        sin(angle) * radius_z + height * 0.042 * t)
    # The shoulder joint controls the outside of the nacelle, while the
    # spine/pelvis stabilise its inside and base. Four source-Skin slots,
    # with normalized weights, avoid rigid objects sliding during steering.
    var arm_weight := (0.36 + 0.24 * maxf(0.0, side * cos(angle))) * (1.0 - 0.40 * t)
    var pelvis_weight := 0.13 + 0.22 * t
    var spine_weight := 1.0 - arm_weight - pelvis_weight
    tool.set_bones(PackedInt32Array([spine, pelvis, arm, spine]))
    tool.set_weights(PackedFloat32Array([spine_weight, pelvis_weight, arm_weight, 0.0]))
    tool.set_uv(Vector2(float(angle) / TAU, t))
    tool.add_vertex(Vector3(x, y, z))

func _attach(body: MeshInstance3D, mesh: ArrayMesh, label: String, core: bool) -> MeshInstance3D:
    var instance := MeshInstance3D.new()
    instance.name = label
    instance.mesh = mesh
    instance.skin = body.skin
    instance.skeleton = body.skeleton
    instance.transform = body.transform
    var material := StandardMaterial3D.new()
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    material.metallic = 0.38 if core else 0.24
    material.roughness = 0.28 if core else 0.44
    material.albedo_color = Color(0.12, 0.88, 1.0) if core else Color(0.67, 0.27, 0.93)
    material.emission_enabled = true
    material.emission = Color(0.08, 0.74, 1.0) if core else Color(0.33, 0.08, 0.49)
    material.emission_energy_multiplier = 2.2 if core else 0.75
    instance.material_override = material
    body.get_parent().add_child(instance)
    return instance
