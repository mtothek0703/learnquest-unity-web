extends Node3D
## V114: organic, 360-degree trouser and boot transition on the ORIGINAL
## 13-bone rider GPU skin. No external assets, collisions or input changes.
const LEG_ROWS := 32
const RADIAL := 24
const YOKE_ROWS := 12
var skeleton: Skeleton3D
var legs: Array[MeshInstance3D] = []
var seams: Array[MeshInstance3D] = []
var hip_yoke: MeshInstance3D

func _ready() -> void:
    var model := get_parent() as Node3D
    var rig := model.get_node_or_null("OriginalBodySkinRig") as Node3D
    if rig == null:
        return
    skeleton = rig.get_node_or_null("OriginalBodySkeleton13") as Skeleton3D
    if skeleton == null or skeleton.get_bone_count() != 13:
        return
    var skin := skeleton.create_skin_from_rest_transforms()
    var cloth := StandardMaterial3D.new()
    cloth.albedo_color = Color.WHITE
    cloth.vertex_color_use_as_albedo = true
    cloth.metallic = 0.20
    cloth.roughness = 0.54
    cloth.cull_mode = BaseMaterial3D.CULL_DISABLED
    var light := StandardMaterial3D.new()
    light.albedo_color = Color.WHITE
    light.vertex_color_use_as_albedo = true
    light.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    light.emission_enabled = true
    light.emission = Color("#5bdfff")
    light.emission_energy_multiplier = 1.25
    light.cull_mode = BaseMaterial3D.CULL_DISABLED
    hip_yoke = _attach("UnifiedSkinnedHipYoke", _build_hip(), cloth, skin)
    for side in [-1.0, 1.0]:
        var prefix := "Left" if side < 0.0 else "Right"
        legs.append(_attach(prefix + "ContinuousSkinnedTrouser", _build_leg(side, false), cloth, skin))
        seams.append(_attach(prefix + "WeightedTrouserSeam", _build_leg(side, true), light, skin))
    if hip_yoke == null or legs.size() != 2 or seams.size() != 2:
        return
    for part in legs + seams:
        if part == null or part.skin == null or part.get_node_or_null(part.skeleton) != skeleton:
            return
    # Retire duplicates only after the replacement meshes are bound.
    # Preserve imported glTF limbs, articulated knees, neon knee rings,
    # the existing boot geometry, its animation and all game physics.
    var suit := model.get_node_or_null("SculptedSkinnedFlightSuit") as Node3D
    if suit != null:
        var shells: Array = suit.get("suit_parts")
        var piping: Array = suit.get("piping_parts")
        if shells.size() == 5 and piping.size() == 5:
            for index in [3, 4]:
                (shells[index] as MeshInstance3D).visible = false
                (piping[index] as MeshInstance3D).visible = false
    for index in range(2):
        var pivot := model.get_node_or_null("BalanceLeg%d" % index) as Node3D
        if pivot == null:
            continue
        var old := pivot.get_node_or_null("SculptedRiderLeg") as Node3D
        if old != null:
            for mesh in old.find_children("*", "MeshInstance3D", true, false):
                (mesh as MeshInstance3D).visible = false

func _attach(part_name: String, geometry: ArrayMesh, material: Material, skin: Skin) -> MeshInstance3D:
    if geometry == null or geometry.get_surface_count() != 1:
        return null
    var part := MeshInstance3D.new()
    part.name = part_name
    part.mesh = geometry
    part.skin = skin
    part.material_override = material
    add_child(part)
    part.skeleton = part.get_path_to(skeleton)
    return part

func _leg_point(side: float, t: float, u: float, seam: bool = false) -> Vector3:
    # The boot collar is at y ~0.48 in imported-rider coordinates.
    # A soft calf taper and shallow knee folds form one continuous surface.
    var angle := TAU * u
    var knee := exp(-pow((t - 0.61) / 0.13, 2.0))
    var radius := lerpf(0.267, 0.155, t) + 0.018 * sin(PI * t)
    radius += 0.011 * knee * cos(3.0 * angle + t * 10.0)
    radius += 0.010 if seam else 0.0
    var center := Vector3(side * (0.34 + 0.015 * sin(PI * t)),
        lerpf(1.16, 0.45, t), 0.03 + 0.027 * sin(PI * t))
    var forward := sin(angle)
    var knee_shape := 0.028 * knee * maxf(0.0, -forward)
    return center + Vector3(cos(angle) * radius,
        0.010 * knee * sin(angle * 2.0),
        forward * radius * 0.91 - knee_shape)

func _hip_point(t: float, u: float) -> Vector3:
    var angle := TAU * u
    var width := lerpf(0.495, 0.455, t)
    var depth := lerpf(0.355, 0.385, t)
    var curve := 0.022 * sin(PI * t)
    return Vector3(cos(angle) * (width + curve), 1.01 + 0.34 * t,
        0.045 + sin(angle) * (depth + curve))

func _leg_weights(side: float, t: float) -> Dictionary:
    var thigh := 9 if side < 0.0 else 11
    var knee := smoothstep(0.31, 0.79, t)
    var hip := 1.0 - smoothstep(0.02, 0.31, t)
    var weights := PackedFloat32Array([
        0.84 * (1.0 - knee) + 0.07,
        0.91 * knee,
        0.32 * hip,
        0.04 * hip
    ])
    _normalize(weights)
    return {"bones": PackedInt32Array([thigh, thigh + 1, 0, 1]), "weights": weights}

func _hip_weights(t: float, u: float) -> Dictionary:
    var left := maxf(0.0, -cos(TAU * u))
    var right := maxf(0.0, cos(TAU * u))
    var weights := PackedFloat32Array([
        0.68,
        0.17 + 0.17 * t,
        0.22 * left * (1.0 - t),
        0.22 * right * (1.0 - t)
    ])
    _normalize(weights)
    return {"bones": PackedInt32Array([0, 1, 9, 11]), "weights": weights}

func _normalize(weights: PackedFloat32Array) -> void:
    var total := 0.0
    for value in weights:
        total += value
    for i in range(weights.size()):
        weights[i] /= maxf(total, 0.00001)

func _emit_leg(tool: SurfaceTool, side: float, t: float, u: float, seam: bool) -> void:
    var influence := _leg_weights(side, t)
    tool.set_bones(influence["bones"])
    tool.set_weights(influence["weights"])
    var shade := Color("#20274c").lerp(Color("#58539a"), 0.27 + 0.27 * (1.0 - t))
    shade = shade.lerp(Color("#4083a1"), 0.18 * maxf(0.0, -sin(TAU * u)))
    shade = shade.lightened(0.075 * pow(maxf(0.0, cos(TAU * u - 0.45)), 4.0))
    if seam:
        shade = Color("#6beaff").lerp(Color("#b5a0ff"), t * 0.55)
    tool.set_color(shade)
    tool.add_vertex(_leg_point(side, t, u, seam))

func _emit_hip(tool: SurfaceTool, t: float, u: float) -> void:
    var influence := _hip_weights(t, u)
    tool.set_bones(influence["bones"])
    tool.set_weights(influence["weights"])
    var shade := Color("#222b50").lerp(Color("#6357a1"), 0.25 + 0.25 * t)
    shade = shade.lerp(Color("#44839d"), 0.14 * maxf(0.0, -sin(TAU * u)))
    tool.set_color(shade)
    tool.add_vertex(_hip_point(t, u))

func _build_leg(side: float, seam: bool) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    var columns := 2 if seam else RADIAL
    for row in range(LEG_ROWS):
        var t0 := float(row) / float(LEG_ROWS)
        var t1 := float(row + 1) / float(LEG_ROWS)
        for column in range(columns):
            var u0 := float(column) / float(columns)
            var u1 := float(column + 1) / float(columns)
            if seam:
                var outer := 0.50 if side < 0.0 else 0.0
                u0 = outer + (u0 - 0.5) * 0.015
                u1 = outer + (u1 - 0.5) * 0.015
            _emit_leg(tool, side, t0, u0, seam)
            _emit_leg(tool, side, t1, u0, seam)
            _emit_leg(tool, side, t1, u1, seam)
            _emit_leg(tool, side, t0, u0, seam)
            _emit_leg(tool, side, t1, u1, seam)
            _emit_leg(tool, side, t0, u1, seam)
    tool.generate_normals()
    return tool.commit()

func _build_hip() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for row in range(YOKE_ROWS):
        var t0 := float(row) / float(YOKE_ROWS)
        var t1 := float(row + 1) / float(YOKE_ROWS)
        for column in range(RADIAL):
            var u0 := float(column) / float(RADIAL)
            var u1 := float(column + 1) / float(RADIAL)
            _emit_hip(tool, t0, u0)
            _emit_hip(tool, t1, u0)
            _emit_hip(tool, t1, u1)
            _emit_hip(tool, t0, u0)
            _emit_hip(tool, t1, u1)
            _emit_hip(tool, t0, u1)
    tool.generate_normals()
    return tool.commit()
