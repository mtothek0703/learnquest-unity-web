extends Node3D
## Skyway V95: actual smooth GPU skinning across the V94 five-bone rig.
## Six curved, weighted surfaces are visual only. They neither replace the
## imported rider nor touch the proven phone gestures, physics or collisions.
const SPAN_STEPS := 20
const HEIGHT_STEPS := 12
var skeleton: Skeleton3D

func _ready() -> void:
    skeleton = get_parent().get_node_or_null("FiveBoneExosuitSkeleton") as Skeleton3D
    if skeleton == null or skeleton.get_bone_count() != 5:
        push_error("V95 weighted wing membranes require the five-bone exosuit")
        return
    # Bind poses are the inverse GLOBAL REST transforms, not bone-local rests.
    var shared_skin: Skin = skeleton.create_skin_from_rest_transforms()
    for side in [-1.0, 1.0]:
        var label := "Left" if side < 0.0 else "Right"
        _install(label + "WeightedAeroMembrane", side, 0.0, 1.0, HEIGHT_STEPS, 0.0, _fabric(), shared_skin, false)
        _install(label + "WeightedUpperSeam", side, 0.91, 0.99, 1, 0.028, _luminous_trim(), shared_skin, true)
        _install(label + "WeightedLowerSeam", side, 0.01, 0.09, 1, 0.028, _luminous_trim(), shared_skin, true)

func _fabric() -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(1.0, 1.0, 1.0, 0.83)
    mat.vertex_color_use_as_albedo = true
    mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    mat.metallic = 0.28
    mat.roughness = 0.39
    mat.cull_mode = BaseMaterial3D.CULL_DISABLED
    return mat

func _luminous_trim() -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(1.0, 1.0, 1.0, 0.90)
    mat.vertex_color_use_as_albedo = true
    mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    mat.emission_enabled = true
    mat.emission = Color("#4dd9ff")
    mat.emission_energy_multiplier = 1.75
    mat.cull_mode = BaseMaterial3D.CULL_DISABLED
    return mat

func _wing_point(u: float, v: float, side: float, depth: float) -> Vector3:
    # In Skeleton3D rest coordinates. Open center leaves the chase-camera
    # character readable; both wings live behind and outside the rider.
    return Vector3(
        side * (0.32 + 1.48 * u),
        0.16 + 0.55 * v + 0.17 * u + 0.10 * sin(u * PI) * sin(v * PI),
        0.66 + 0.17 * sin(u * PI) + 0.09 * u + 0.03 * sin(v * PI) + depth
    )

func _weighted_vertex(tool: SurfaceTool, point: Vector3, u: float, v: float, side: float, is_trim: bool) -> void:
    # Four influences per vertex: lower spine, upper spine, its own shoulder,
    # and a zero-weight collar slot. Normalized weights create a genuinely
    # deforming mesh rather than a rigid BoneAttachment3D imitation.
    var shoulder := clampf(0.10 + 0.84 * u * u, 0.10, 0.94)
    var lower := (1.0 - shoulder) * (0.38 - 0.30 * v)
    var upper := 1.0 - shoulder - lower
    var shoulder_bone := 2 if side < 0.0 else 3
    tool.set_bones(PackedInt32Array([0, 1, shoulder_bone, 4]))
    tool.set_weights(PackedFloat32Array([lower, upper, shoulder, 0.0]))
    var tint := Color("#285c92").lerp(Color("#c97af0"), 0.18 + 0.74 * u)
    if is_trim:
        tint = Color("#65e9ff").lerp(Color("#ffa4f4"), 0.25 + 0.65 * u)
        tint.a = 0.96
    else:
        tint.a = 0.64 + 0.16 * v
    tool.set_color(tint)
    tool.add_vertex(point)

func _mesh(side: float, v_start: float, v_end: float, vertical_steps: int, depth: float, is_trim: bool) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for row in range(SPAN_STEPS):
        var u0 := float(row) / float(SPAN_STEPS)
        var u1 := float(row + 1) / float(SPAN_STEPS)
        for col in range(vertical_steps):
            var v0 := lerpf(v_start, v_end, float(col) / float(vertical_steps))
            var v1 := lerpf(v_start, v_end, float(col + 1) / float(vertical_steps))
            var a := _wing_point(u0, v0, side, depth)
            var b := _wing_point(u1, v0, side, depth)
            var c := _wing_point(u1, v1, side, depth)
            var d := _wing_point(u0, v1, side, depth)
            _weighted_vertex(tool, a, u0, v0, side, is_trim)
            _weighted_vertex(tool, b, u1, v0, side, is_trim)
            _weighted_vertex(tool, c, u1, v1, side, is_trim)
            _weighted_vertex(tool, a, u0, v0, side, is_trim)
            _weighted_vertex(tool, c, u1, v1, side, is_trim)
            _weighted_vertex(tool, d, u0, v1, side, is_trim)
    tool.generate_normals()
    return tool.commit()

func _install(label: String, side: float, v_start: float, v_end: float, steps: int, depth: float, mat: StandardMaterial3D, shared_skin: Skin, is_trim: bool) -> void:
    var instance := MeshInstance3D.new()
    instance.name = label
    instance.mesh = _mesh(side, v_start, v_end, steps, depth, is_trim)
    instance.material_override = mat
    skeleton.add_child(instance)
    instance.skeleton = NodePath("..")
    instance.skin = shared_skin
