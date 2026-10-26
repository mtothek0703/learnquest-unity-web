extends Node3D
## Skyway V96: the rider's flexible torso panels are actual GPU-skinned
## geometry, not rigid bone attachments. They bend from waist to shoulder
## on the existing five-bone rig without modifying the imported character,
## gameplay collisions, camera, HUD or proven phone gestures.
const SPAN_STEPS := 20
const HEIGHT_STEPS := 12
var skeleton: Skeleton3D

func _ready() -> void:
    skeleton = get_parent().get_node_or_null("FiveBoneExosuitSkeleton") as Skeleton3D
    if skeleton == null or skeleton.get_bone_count() != 5:
        push_error("V96 flexible torso requires the five-bone exosuit")
        return
    var shared_skin: Skin = skeleton.create_skin_from_rest_transforms()
    for side in [-1.0, 1.0]:
        var label := "Left" if side < 0.0 else "Right"
        _install(label + "SkinnedTorsoShell", side, 0.0, 1.0, 0.0, 1.0, _armor_material(), shared_skin, false)
        # Neon ribs follow the SAME weighted deformation as the shaded armor.
        _install(label + "SkinnedInnerRib", side, 0.12, 0.20, 0.06, 0.96, _neon_material(), shared_skin, true)
        _install(label + "SkinnedOuterRib", side, 0.84, 0.92, 0.06, 0.96, _neon_material(), shared_skin, true)
        _install(label + "SkinnedWaistBand", side, 0.05, 0.95, 0.14, 0.19, _neon_material(), shared_skin, true)
        _install(label + "SkinnedShoulderBand", side, 0.08, 0.94, 0.84, 0.89, _neon_material(), shared_skin, true)

func _armor_material() -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color.WHITE
    mat.vertex_color_use_as_albedo = true
    mat.metallic = 0.55
    mat.roughness = 0.34
    mat.cull_mode = BaseMaterial3D.CULL_DISABLED
    return mat

func _neon_material() -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color.WHITE
    mat.vertex_color_use_as_albedo = true
    mat.emission_enabled = true
    mat.emission = Color("#46dfff")
    mat.emission_energy_multiplier = 2.0
    mat.roughness = 0.36
    mat.cull_mode = BaseMaterial3D.CULL_DISABLED
    return mat

func _torso_point(u: float, v: float, side: float, depth: float) -> Vector3:
    # Local coordinates of the Skeleton3D at the rider's waist.
    # The central reactor remains exposed; raised curved ribs catch chase light.
    return Vector3(
        side * (0.17 + 0.55 * u + 0.06 * sin(PI * v) * u),
        -0.36 + 1.18 * v,
        0.64 + 0.17 * sin(PI * v) + 0.09 * u * u + depth
    )

func _vertex(tool: SurfaceTool, u: float, v: float, side: float, glow: bool) -> void:
    # Root/upper-spine/shoulder/neck influences, all normalized to one.
    # Lower rows flex at the waist, upper outer rows follow the shoulders.
    var waist_weight := 0.62 * (1.0 - v)
    var shoulder_weight := 0.42 * v * u * u
    var neck_weight := 0.16 * v * v * (1.0 - u)
    var chest_weight := 1.0 - waist_weight - shoulder_weight - neck_weight
    tool.set_bones(PackedInt32Array([0, 1, 2 if side < 0.0 else 3, 4]))
    tool.set_weights(PackedFloat32Array([waist_weight, chest_weight, shoulder_weight, neck_weight]))
    var color := Color("#182c55").lerp(Color("#7e5ed4"), 0.32 * u + 0.60 * v)
    if glow:
        color = Color("#54f4ff").lerp(Color("#ff80df"), 0.36 * u + 0.54 * v)
    tool.set_color(color)
    tool.add_vertex(_torso_point(u, v, side, 0.022 if glow else 0.0))

func _panel_mesh(side: float, u_start: float, u_end: float, v_start: float, v_end: float, glow: bool) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    var width_steps := SPAN_STEPS if u_end - u_start > 0.4 else 3
    var height_steps := HEIGHT_STEPS if v_end - v_start > 0.4 else 2
    for row in range(width_steps):
        var u0 := lerpf(u_start, u_end, float(row) / float(width_steps))
        var u1 := lerpf(u_start, u_end, float(row + 1) / float(width_steps))
        for column in range(height_steps):
            var v0 := lerpf(v_start, v_end, float(column) / float(height_steps))
            var v1 := lerpf(v_start, v_end, float(column + 1) / float(height_steps))
            _vertex(tool, u0, v0, side, glow)
            _vertex(tool, u1, v0, side, glow)
            _vertex(tool, u1, v1, side, glow)
            _vertex(tool, u0, v0, side, glow)
            _vertex(tool, u1, v1, side, glow)
            _vertex(tool, u0, v1, side, glow)
    tool.generate_normals()
    return tool.commit()

func _install(label: String, side: float, u_start: float, u_end: float, v_start: float, v_end: float, material: StandardMaterial3D, shared_skin: Skin, glow: bool) -> void:
    var instance := MeshInstance3D.new()
    instance.name = label
    instance.mesh = _panel_mesh(side, u_start, u_end, v_start, v_end, glow)
    instance.material_override = material
    skeleton.add_child(instance)
    instance.skeleton = NodePath("..")
    instance.skin = shared_skin
