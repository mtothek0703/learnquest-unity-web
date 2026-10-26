extends Node3D
## Sprint 1 / V100: visible, smoothly weighted flight-suit silhouette.
## Five original curved meshes (back shell, both sleeves, both leg guards)
## and six luminous piping strips are bound to the SAME original-body
## Skeleton3D. No boxes, imported licenses, collisions or input changes.
## Modest ring counts keep the extra geometry suitable for WebGL/mobile.
const RINGS := 15
const SIDES := 20
var skeleton: Skeleton3D
var suit_parts: Array[MeshInstance3D] = []
var piping_parts: Array[MeshInstance3D] = []

func _ready() -> void:
    var model := get_parent() as Node3D
    var rig := model.get_node_or_null("OriginalBodySkinRig") as Node3D
    if rig == null:
        return
    skeleton = rig.get_node_or_null("OriginalBodySkeleton13") as Skeleton3D
    if skeleton == null or skeleton.get_bone_count() != 13:
        return
    var shared_skin := skeleton.create_skin_from_rest_transforms()
    var armor := StandardMaterial3D.new()
    armor.albedo_color = Color.WHITE
    armor.vertex_color_use_as_albedo = true
    armor.metallic = 0.56
    armor.roughness = 0.31
    armor.cull_mode = BaseMaterial3D.CULL_DISABLED
    var piping := StandardMaterial3D.new()
    piping.albedo_color = Color.WHITE
    piping.vertex_color_use_as_albedo = true
    piping.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    piping.emission_enabled = true
    piping.emission = Color("#54dfff")
    piping.emission_energy_multiplier = 1.65
    piping.cull_mode = BaseMaterial3D.CULL_DISABLED
    for part in range(5):
        var side := -1.0 if part == 1 or part == 3 else 1.0
        var shell := MeshInstance3D.new()
        shell.name = ["SculptedBackJacket", "SkinnedLeftSleeve", "SkinnedRightSleeve",
            "SkinnedLeftLegGuard", "SkinnedRightLegGuard"][part]
        shell.mesh = _build_surface(part, side, false)
        shell.material_override = armor
        shell.skin = shared_skin
        add_child(shell)
        shell.skeleton = shell.get_path_to(skeleton)
        suit_parts.append(shell)
        var neon := MeshInstance3D.new()
        neon.name = "WeightedNeonSeams%d" % part
        neon.mesh = _build_surface(part, side, true)
        neon.material_override = piping
        neon.skin = shared_skin
        add_child(neon)
        neon.skeleton = neon.get_path_to(skeleton)
        piping_parts.append(neon)

func _point(part: int, side: float, t: float, u: float, piping: bool) -> Vector3:
    var outward := 0.022 if piping else 0.0
    if part == 0:
        # V100: the old jacket/backplate sat IN FRONT of V99's new GPU skin.
        # A shaped outer shell now clears the imported body and jacket,
        # while a central concave channel leaves the reactor unobstructed.
        # The high shoulders taper into a defined waist in chase view.
        var y := 1.05 + 1.18 * t
        var across := 2.0 * u - 1.0
        var shoulder := smoothstep(0.42, 0.92, t)
        var width := 0.37 + 0.14 * sin(PI * t * 0.88) + 0.035 * shoulder
        var contour := 1.0 - across * across
        var central_channel := 0.055 * exp(-pow(across / 0.20, 2.0))
        var depth := 0.80 + 0.13 * contour + 0.04 * sin(PI * t)
        return Vector3(across * width, y,
            depth - central_channel + 0.02 * absf(across) + outward)
    if part <= 2:
        # Elliptical, tapered sleeves bend from shoulder toward wrist.
        var angle := u * TAU
        var shoulder := 0.56 + 0.38 * t
        var radius := (0.185 - 0.045 * t) + outward
        return Vector3(side * shoulder + cos(angle) * radius,
            1.95 - 0.82 * t,
            0.09 + 0.08 * t + sin(angle) * (radius * 1.10))
    var angle := u * TAU
    var radius := (0.235 - 0.063 * t) + outward
    return Vector3(side * (0.34 + 0.018 * t) + cos(angle) * radius,
        0.88 - 0.77 * t,
        0.105 + sin(angle) * radius)

func _influences(part: int, side: float, t: float) -> Dictionary:
    var bones: PackedInt32Array
    var weights: PackedFloat32Array
    if part == 0:
        var upper := smoothstep(0.16, 0.90, t)
        bones = PackedInt32Array([0, 1, 2, 3])
        weights = PackedFloat32Array([
            0.20 * (1.0 - upper),
            0.80 * (1.0 - upper),
            0.92 * upper,
            0.08 * upper
        ])
    elif part <= 2:
        var arm := 5 if side < 0.0 else 7
        var elbow := smoothstep(0.30, 0.80, t)
        bones = PackedInt32Array([arm, arm + 1, 2, 1])
        weights = PackedFloat32Array([
            0.94 * (1.0 - elbow),
            0.94 * elbow,
            0.06, 0.0
        ])
    else:
        var thigh := 9 if side < 0.0 else 11
        var knee := smoothstep(0.30, 0.79, t)
        bones = PackedInt32Array([thigh, thigh + 1, 0, 1])
        weights = PackedFloat32Array([
            0.94 * (1.0 - knee),
            0.94 * knee,
            0.06, 0.0
        ])
    return {"bones": bones, "weights": weights}

func _emit(tool: SurfaceTool, part: int, side: float,
        t: float, u: float, piping: bool) -> void:
    var influences := _influences(part, side, t)
    tool.set_bones(influences["bones"])
    tool.set_weights(influences["weights"])
    var base := Color("#172341").lerp(Color("#664eae"), t * 0.57)
    if part == 0:
        base = base.lerp(Color("#3b92ae"), 0.22 + 0.15 * sin(PI * t))
    elif part >= 3:
        base = base.lerp(Color("#356080"), 0.33)
    if piping:
        base = Color("#60f5ff").lerp(Color("#d68aff"), 0.20 + 0.55 * t)
    tool.set_color(base)
    tool.add_vertex(_point(part, side, t, u, piping))

func _build_surface(part: int, side: float, piping: bool) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    # Back has two separate, curved luminous seams; each limb has one.
    var strips := 2 if piping and part == 0 else 1
    var columns := 2 if piping else SIDES
    for strip in range(strips):
        for row in range(RINGS):
            var t0 := float(row) / float(RINGS)
            var t1 := float(row + 1) / float(RINGS)
            for col in range(columns):
                var u0 := float(col) / float(columns)
                var u1 := float(col + 1) / float(columns)
                if piping:
                    if part == 0:
                        var center := 0.27 if strip == 0 else 0.73
                        u0 = center + (u0 - 0.5) * 0.026
                        u1 = center + (u1 - 0.5) * 0.026
                    else:
                        u0 = 0.25 + (u0 - 0.5) * 0.035
                        u1 = 0.25 + (u1 - 0.5) * 0.035
                _emit(tool, part, side, t0, u0, piping)
                _emit(tool, part, side, t1, u0, piping)
                _emit(tool, part, side, t1, u1, piping)
                _emit(tool, part, side, t0, u0, piping)
                _emit(tool, part, side, t1, u1, piping)
                _emit(tool, part, side, t0, u1, piping)
    tool.generate_normals()
    return tool.commit()
