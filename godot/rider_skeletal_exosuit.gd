extends Node3D
## Skyway V94: an actual five-bone Skeleton3D drives a sculpted exosuit.
## This rig animates original armor, not the imported glTF body. It is purely
## visual: no collision objects, changes to rider physics or touch controls.
const ROWS := 18
const COLS := 18
var skeleton: Skeleton3D
var spine_core: MeshInstance3D
var glow_material: StandardMaterial3D
var elapsed: float = 0.0

func _ready() -> void:
    _build_skeleton()
    _build_exosuit()

func _build_skeleton() -> void:
    skeleton = Skeleton3D.new()
    skeleton.name = "FiveBoneExosuitSkeleton"
    add_child(skeleton)
    skeleton.position = Vector3(0.0, 1.34, 0.0)
    for bone_name in ["SpineRoot", "UpperSpine", "LeftShoulder", "RightShoulder", "NeckCollar"]:
        skeleton.add_bone(bone_name)
    skeleton.set_bone_parent(1, 0)
    skeleton.set_bone_parent(2, 1)
    skeleton.set_bone_parent(3, 1)
    skeleton.set_bone_parent(4, 1)
    skeleton.set_bone_rest(0, Transform3D(Basis.IDENTITY, Vector3.ZERO))
    skeleton.set_bone_rest(1, Transform3D(Basis.IDENTITY, Vector3(0.0, 0.56, 0.0)))
    skeleton.set_bone_rest(2, Transform3D(Basis.IDENTITY, Vector3(-0.47, 0.18, 0.04)))
    skeleton.set_bone_rest(3, Transform3D(Basis.IDENTITY, Vector3(0.47, 0.18, 0.04)))
    skeleton.set_bone_rest(4, Transform3D(Basis.IDENTITY, Vector3(0.0, 0.37, -0.01)))

func _attachment(name: String, bone: String) -> BoneAttachment3D:
    var attachment := BoneAttachment3D.new()
    attachment.name = name
    attachment.bone_name = bone
    skeleton.add_child(attachment)
    return attachment

func _shaded_metal() -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color.WHITE
    mat.vertex_color_use_as_albedo = true
    mat.metallic = 0.64
    mat.roughness = 0.27
    mat.cull_mode = BaseMaterial3D.CULL_DISABLED
    return mat

func _neon() -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color("#78f6ff")
    mat.emission_enabled = true
    mat.emission = Color("#48caff")
    mat.emission_energy_multiplier = 1.8
    mat.cull_mode = BaseMaterial3D.CULL_DISABLED
    return mat

func _add_mesh(parent: Node3D, name: String, mesh: Mesh, mat: Material) -> MeshInstance3D:
    var instance := MeshInstance3D.new()
    instance.name = name
    instance.mesh = mesh
    instance.material_override = mat
    parent.add_child(instance)
    return instance

func _back_point(u: float, v: float, offset: float = 0.0) -> Vector3:
    var across := 2.0 * u - 1.0
    return Vector3(
        across * (0.44 + 0.10 * v),
        -0.46 + 0.88 * v,
        0.42 + 0.17 * (1.0 - across * across) + 0.035 * sin(v * PI) + offset
    )

func _blade_point(u: float, v: float, side: float, offset: float = 0.0) -> Vector3:
    # Wide swept fins sit beside the back, never over the rider's head.
    return Vector3(
        side * (0.03 + 1.03 * u),
        0.04 + 0.33 * u + (v - 0.5) * (0.19 + 0.21 * sin(u * PI)),
        0.37 + 0.20 * sin(u * PI) - 0.24 * v + offset
    )

func _colored_vertex(tool: SurfaceTool, point: Vector3, tint: Color) -> void:
    tool.set_color(tint)
    tool.add_vertex(point)

func _quad(tool: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, low: Color, high: Color) -> void:
    _colored_vertex(tool, a, low)
    _colored_vertex(tool, b, low)
    _colored_vertex(tool, c, high)
    _colored_vertex(tool, a, low)
    _colored_vertex(tool, c, high)
    _colored_vertex(tool, d, high)

func _back_armor_mesh() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for row in range(ROWS):
        var v0 := float(row) / float(ROWS)
        var v1 := float(row + 1) / float(ROWS)
        for col in range(COLS):
            var u0 := float(col) / float(COLS)
            var u1 := float(col + 1) / float(COLS)
            var dark := Color("#192d50").lerp(Color("#67529b"), v0 * 0.58)
            var bright := Color("#365f8a").lerp(Color("#a67fd5"), v1 * 0.65)
            _quad(tool, _back_point(u0, v0), _back_point(u1, v0),
                _back_point(u1, v1), _back_point(u0, v1), dark, bright)
    tool.generate_normals()
    return tool.commit()

func _blade_mesh(side: float) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for row in range(ROWS):
        var u0 := float(row) / float(ROWS)
        var u1 := float(row + 1) / float(ROWS)
        for col in range(COLS):
            var v0 := float(col) / float(COLS)
            var v1 := float(col + 1) / float(COLS)
            var base := Color("#294d78").lerp(Color("#7758aa"), u0)
            var edge := Color("#51c0c7").lerp(Color("#d78ddc"), u1)
            _quad(tool, _blade_point(u0, v0, side), _blade_point(u1, v0, side),
                _blade_point(u1, v1, side), _blade_point(u0, v1, side), base, edge)
    tool.generate_normals()
    return tool.commit()

func _neon_spine_mesh() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for segment in range(32):
        var v0 := float(segment) / 32.0
        var v1 := float(segment + 1) / 32.0
        var a := _back_point(0.46, v0, 0.018)
        var b := _back_point(0.54, v0, 0.018)
        var c := _back_point(0.54, v1, 0.018)
        var d := _back_point(0.46, v1, 0.018)
        tool.add_vertex(a)
        tool.add_vertex(b)
        tool.add_vertex(c)
        tool.add_vertex(a)
        tool.add_vertex(c)
        tool.add_vertex(d)
    tool.generate_normals()
    return tool.commit()

func _blade_trim_mesh(side: float) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for segment in range(24):
        var u0 := float(segment) / 24.0
        var u1 := float(segment + 1) / 24.0
        var a := _blade_point(u0, 0.04, side, 0.022)
        var b := _blade_point(u1, 0.04, side, 0.022)
        var c := _blade_point(u1, 0.12, side, 0.022)
        var d := _blade_point(u0, 0.12, side, 0.022)
        tool.add_vertex(a)
        tool.add_vertex(b)
        tool.add_vertex(c)
        tool.add_vertex(a)
        tool.add_vertex(c)
        tool.add_vertex(d)
    tool.generate_normals()
    return tool.commit()

func _build_exosuit() -> void:
    var metal := _shaded_metal()
    glow_material = _neon()
    var upper := _attachment("UpperSpineArmor", "UpperSpine")
    _add_mesh(upper, "SculptedArticulatedBackplate", _back_armor_mesh(), metal)
    _add_mesh(upper, "LuminousSpineChannel", _neon_spine_mesh(), glow_material)
    spine_core = MeshInstance3D.new()
    spine_core.name = "PulsingSpineReactor"
    var reactor_mesh := SphereMesh.new()
    reactor_mesh.radius = 0.16
    reactor_mesh.height = 0.30
    reactor_mesh.radial_segments = 20
    reactor_mesh.rings = 10
    spine_core.mesh = reactor_mesh
    spine_core.material_override = glow_material
    spine_core.position = Vector3(0.0, 0.12, 0.70)
    upper.add_child(spine_core)
    for side in [-1.0, 1.0]:
        var attachment := _attachment("LeftSkeletalShoulder" if side < 0.0 else "RightSkeletalShoulder",
            "LeftShoulder" if side < 0.0 else "RightShoulder")
        _add_mesh(attachment, "SweptMetalAeroBlade", _blade_mesh(side), metal)
        _add_mesh(attachment, "CurvedNeonBladeSeam", _blade_trim_mesh(side), glow_material)
    var collar := _attachment("AnimatedNeckCollar", "NeckCollar")
    var collar_mesh := TorusMesh.new()
    collar_mesh.inner_radius = 0.29
    collar_mesh.outer_radius = 0.35
    collar_mesh.rings = 24
    collar_mesh.ring_segments = 10
    var collar_ring := _add_mesh(collar, "LuminousArticulatedCollar", collar_mesh, glow_material)
    collar_ring.position = Vector3(0.0, -0.03, 0.0)

func _process(delta: float) -> void:
    if skeleton == null:
        return
    var rider := get_parent().get_parent() as Node3D
    if rider == null:
        return
    elapsed += delta
    var steering := clampf(float(rider.get("lean")), -1.0, 1.0)
    var turbo := bool(rider.get("boosting"))
    var airborne := clampf(rider.position.y / 1.25, 0.0, 1.0)
    var blend := minf(1.0, delta * 7.0)
    var root_target := Quaternion(Vector3.FORWARD, -steering * 0.12)
    var chest_target := Quaternion(Vector3.UP, -steering * 0.19) * Quaternion(Vector3.RIGHT, (0.16 if turbo else 0.0) + airborne * 0.20)
    skeleton.set_bone_pose_rotation(0, skeleton.get_bone_pose_rotation(0).slerp(root_target, blend))
    skeleton.set_bone_pose_rotation(1, skeleton.get_bone_pose_rotation(1).slerp(chest_target, blend))
    for bone_index in [2, 3]:
        var side := -1.0 if bone_index == 2 else 1.0
        var wing_angle := side * (0.10 + (0.48 if turbo else 0.0) + airborne * 0.22) - steering * 0.12
        var wing_target := Quaternion(Vector3.FORWARD, wing_angle) * Quaternion(Vector3.UP, -steering * 0.10)
        skeleton.set_bone_pose_rotation(bone_index,
            skeleton.get_bone_pose_rotation(bone_index).slerp(wing_target, blend))
    var collar_target := Quaternion(Vector3.RIGHT, (-0.12 if turbo else 0.0) - airborne * 0.10)
    skeleton.set_bone_pose_rotation(4, skeleton.get_bone_pose_rotation(4).slerp(collar_target, blend))
    if spine_core != null:
        var pulse := 1.0 + (0.20 if turbo else 0.055) * (0.5 + 0.5 * sin(elapsed * (13.0 if turbo else 4.0)))
        spine_core.scale = Vector3.ONE * pulse
    if glow_material != null:
        glow_material.emission_energy_multiplier = 2.7 if turbo else 1.8
