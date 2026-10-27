extends Node3D
## V115: shaded, rounded gloves that bridge the existing V111 sleeve cuffs
## to animated fingers using the SAME original 13-bone GPU skin. Procedural,
## visual-only; no touch, collider, third-party asset or gameplay changes.
const ROWS := 22
const SIDES := 24
var skeleton: Skeleton3D
var palms: Array[MeshInstance3D] = []
var knuckle_seams: Array[MeshInstance3D] = []

func _ready() -> void:
    var model := get_parent() as Node3D
    var rig := model.get_node_or_null("OriginalBodySkinRig") as Node3D
    var sleeves := model.get_node_or_null("OrganicSkinnedArmwear") as Node3D
    if rig == null or sleeves == null:
        return
    skeleton = rig.get_node_or_null("OriginalBodySkeleton13") as Skeleton3D
    if skeleton == null or skeleton.get_bone_count() != 13:
        return
    var skin := skeleton.create_skin_from_rest_transforms()
    var fabric := StandardMaterial3D.new()
    fabric.albedo_color = Color.WHITE
    fabric.vertex_color_use_as_albedo = true
    fabric.metallic = 0.23
    fabric.roughness = 0.48
    fabric.cull_mode = BaseMaterial3D.CULL_DISABLED
    var light := StandardMaterial3D.new()
    light.albedo_color = Color.WHITE
    light.vertex_color_use_as_albedo = true
    light.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    light.emission_enabled = true
    light.emission = Color("#5ce5ff")
    light.emission_energy_multiplier = 1.10
    light.cull_mode = BaseMaterial3D.CULL_DISABLED
    for side in [-1.0, 1.0]:
        var prefix := "Left" if side < 0.0 else "Right"
        palms.append(_attach(prefix + "SkinnedGlovePalm", _build(side, false), fabric, skin))
        knuckle_seams.append(_attach(prefix + "GloveKnuckleStitch", _build(side, true), light, skin))
    if palms.size() != 2 or knuckle_seams.size() != 2:
        return
    for part in palms + knuckle_seams:
        if part == null or part.skin == null or part.get_node_or_null(part.skeleton) != skeleton:
            return
    # Only remove overlapping rigid visual shells once BOTH gloves are skinned.
    # Retain articulated fingers, thumbs, holographic displays and arm pivots.
    for index in range(2):
        var arm := model.get_node_or_null("BalanceArm%d" % index) as Node3D
        if arm == null:
            continue
        for child in arm.get_children():
            if child is MeshInstance3D and child.mesh is SphereMesh:
                (child as MeshInstance3D).visible = false
        var gauntlet := arm.get_node_or_null("SculptedRiderGauntlet") as Node3D
        if gauntlet != null:
            for name in ["SculptedForearmShell", "LuminousGauntletSeams", "LayeredKnuckleGuard"]:
                var old := gauntlet.get_node_or_null(name) as MeshInstance3D
                if old != null:
                    old.visible = false

func _attach(part_name: String, mesh: ArrayMesh, material: Material, skin: Skin) -> MeshInstance3D:
    if mesh == null or mesh.get_surface_count() != 1:
        return null
    var part := MeshInstance3D.new()
    part.name = part_name
    part.mesh = mesh
    part.material_override = material
    part.skin = skin
    add_child(part)
    part.skeleton = part.get_path_to(skeleton)
    return part

func _point(side: float, t: float, u: float, stitch: bool = false) -> Vector3:
    var angle := TAU * u
    var cuff := 1.0 - smoothstep(0.02, 0.25, t)
    var knuckles := exp(-pow((t - 0.79) / 0.15, 2.0))
    var radius := lerpf(0.161, 0.119, t) + 0.010 * cuff
    radius += 0.011 * knuckles * cos(4.0 * angle + 0.3)
    radius += 0.008 if stitch else 0.0
    var center := Vector3(side * (0.71 + 0.010 * t),
        lerpf(1.46, 1.24, t), -0.060 - 0.015 * sin(PI * t))
    return center + Vector3(radius * cos(angle),
        0.006 * sin(PI * t) * cos(2.0 * angle),
        radius * sin(angle) * 0.91)

func _influences(side: float, t: float) -> Dictionary:
    var arm := 5 if side < 0.0 else 7
    var forearm := arm + 1
    var weights := PackedFloat32Array([
        0.81 + 0.14 * t,
        0.17 * (1.0 - t),
        0.015 * (1.0 - t),
        0.005 * (1.0 - t)
    ])
    var total := 0.0
    for weight in weights:
        total += weight
    for i in range(4):
        weights[i] /= maxf(total, 0.00001)
    return {"bones": PackedInt32Array([forearm, arm, 2, 1]), "weights": weights}

func _emit(tool: SurfaceTool, side: float, t: float, u: float, stitch: bool) -> void:
    var influence := _influences(side, t)
    tool.set_bones(influence["bones"])
    tool.set_weights(influence["weights"])
    var shade := Color("#1b2748").lerp(Color("#4c5187"), 0.22 + 0.34 * t)
    shade = shade.lerp(Color("#3c8ca4"), 0.17 * maxf(0.0, -sin(TAU * u)))
    shade = shade.lightened(0.08 * pow(maxf(0.0, cos(TAU * u - 0.3)), 4.0))
    if stitch:
        shade = Color("#66e5fa").lerp(Color("#b2a1f5"), 0.22 + 0.40 * t)
    tool.set_color(shade)
    tool.add_vertex(_point(side, t, u, stitch))

func _build(side: float, stitch: bool) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    var rows := 12 if stitch else ROWS
    var columns := 2 if stitch else SIDES
    for row in range(rows):
        var t0 := float(row) / float(rows)
        var t1 := float(row + 1) / float(rows)
        if stitch:
            t0 = 0.72 + 0.14 * t0
            t1 = 0.72 + 0.14 * t1
        for col in range(columns):
            var u0 := float(col) / float(columns)
            var u1 := float(col + 1) / float(columns)
            if stitch:
                u0 = 0.73 + (u0 - 0.5) * 0.055
                u1 = 0.73 + (u1 - 0.5) * 0.055
            _emit(tool, side, t0, u0, stitch)
            _emit(tool, side, t1, u0, stitch)
            _emit(tool, side, t1, u1, stitch)
            _emit(tool, side, t0, u0, stitch)
            _emit(tool, side, t1, u1, stitch)
            _emit(tool, side, t0, u1, stitch)
    tool.generate_normals()
    return tool.commit()
