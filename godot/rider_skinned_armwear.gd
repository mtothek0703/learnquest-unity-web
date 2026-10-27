extends Node3D
## V107/V111: organic two-joint flight-jacket sleeves on the ORIGINAL 13-bone
## rider skeleton. Sculpted shoulder-to-cuff volume, elbow folds, reflective
## wrist rings and rear-facing luminous seams replace layered rigid capsules.
## Visual-only original procedural geometry; no touch, physics or assets.
const ROWS := 28
const SIDES := 24
var skeleton: Skeleton3D
var sleeves: Array[MeshInstance3D] = []
var seams: Array[MeshInstance3D] = []
var cuffs: Array[MeshInstance3D] = []

func _ready() -> void:
    var model := get_parent() as Node3D
    var rig := model.get_node_or_null("OriginalBodySkinRig") as Node3D
    if rig == null:
        return
    skeleton = rig.get_node_or_null("OriginalBodySkeleton13") as Skeleton3D
    if skeleton == null or skeleton.get_bone_count() != 13:
        return
    var skin := skeleton.create_skin_from_rest_transforms()
    var fabric := StandardMaterial3D.new()
    fabric.albedo_color = Color.WHITE
    fabric.vertex_color_use_as_albedo = true
    fabric.metallic = 0.20
    fabric.roughness = 0.48
    fabric.cull_mode = BaseMaterial3D.CULL_DISABLED
    var light := StandardMaterial3D.new()
    light.albedo_color = Color.WHITE
    light.vertex_color_use_as_albedo = true
    light.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    light.emission_enabled = true
    light.emission = Color("#5ce9ff")
    light.emission_energy_multiplier = 1.45
    light.cull_mode = BaseMaterial3D.CULL_DISABLED
    var metal := StandardMaterial3D.new()
    metal.albedo_color = Color.WHITE
    metal.vertex_color_use_as_albedo = true
    metal.metallic = 0.67
    metal.roughness = 0.28
    metal.cull_mode = BaseMaterial3D.CULL_DISABLED
    for side in [-1.0, 1.0]:
        var prefix := "Left" if side < 0.0 else "Right"
        sleeves.append(_attach(prefix + "OrganicSkinnedSleeve", _mesh(side, 0), fabric, skin))
        seams.append(_attach(prefix + "SkinnedSleeveLight", _mesh(side, 1), light, skin))
        cuffs.append(_attach(prefix + "SkinnedWristCuff", _mesh(side, 2), metal, skin))
    if sleeves.size() != 2 or seams.size() != 2 or cuffs.size() != 2:
        return
    for part in sleeves + seams + cuffs:
        if part == null or part.skin == null:
            return
    # Hide duplicates only after every replacement is skinned successfully.
    # Keep the articulated gauntlets, fingers and elbow mechanisms functional.
    var suit := model.get_node_or_null("SculptedSkinnedFlightSuit") as Node3D
    if suit != null:
        var shells: Array = suit.get("suit_parts")
        var piping: Array = suit.get("piping_parts")
        if shells.size() == 5 and piping.size() == 5:
            for index in [1, 2]:
                (shells[index] as MeshInstance3D).visible = false
                (piping[index] as MeshInstance3D).visible = false
    for index in range(2):
        var arm := model.get_node_or_null("BalanceArm%d" % index) as Node3D
        if arm == null:
            continue
        for child in arm.get_children():
            if child is MeshInstance3D and (child.name == "SculptedShoulderGuard" or
                    child.name == "ShoulderNeonTrim" or child.mesh is CapsuleMesh):
                child.visible = false

func _attach(name: String, mesh: ArrayMesh, material: Material, skin: Skin) -> MeshInstance3D:
    if mesh == null or mesh.get_surface_count() != 1:
        return null
    var part := MeshInstance3D.new()
    part.name = name
    part.mesh = mesh
    part.skin = skin
    part.material_override = material
    add_child(part)
    part.skeleton = part.get_path_to(skeleton)
    return part

func _point(t: float, u: float, side: float, kind: int) -> Vector3:
    if kind == 2:
        t = 0.91 + 0.075 * t
    elif kind == 1:
        # Narrow seam runs down the outer/back of each arm, above the fabric.
        u = 0.245 + (u - 0.5) * 0.035
    var angle := TAU * u
    var shoulder := 1.0 - smoothstep(0.04, 0.34, t)
    var elbow := exp(-pow((t - 0.55) / 0.17, 2.0))
    # Close the upper ring into a smooth shoulder dome: the first PR render
    # revealed an open, oversized cup with the pink body still visible inside.
    var shoulder_cap := smoothstep(0.0, 0.19, t)
    var radius := (lerpf(0.300, 0.145, t) + 0.018 * shoulder) * shoulder_cap + 0.012
    # Subtle tailoring: shoulder fullness, tapered elbow and three soft folds.
    radius += (0.009 * sin(t * TAU * 3.0) + 0.006 * cos(angle * 3.0)) * elbow
    radius += 0.010 if kind == 2 else (0.012 if kind == 1 else 0.0)
    # V111: the V110 real landscape frames exposed bright shoulder holes
    # and sleeves ending away from the gauntlets. Previously the "circular"
    # section lay in the X/Z plane: every vertex of each ring had nearly
    # identical Y, so the shoulder had no upper volume. Construct the ring
    # perpendicular to the actual sloping shoulder-to-wrist centerline.
    # The shoulder overlaps the continuous jacket, while the wrist terminates
    # at the existing articulated hand rather than beyond it.
    var start := Vector3(side * 0.61, 2.29, -0.33)
    var finish := Vector3(side * 0.73, 1.33, -0.06)
    var center := start.lerp(finish, t)
    center.x += side * 0.018 * sin(t * PI)
    center.z += 0.024 * sin(t * PI)
    var tangent := Vector3(
        side * (0.12 + 0.018 * PI * cos(t * PI)),
        -0.96,
        0.27 + 0.024 * PI * cos(t * PI)
    ).normalized()
    var radial_x := (Vector3.RIGHT - tangent * tangent.x).normalized()
    var radial_z := tangent.cross(radial_x).normalized()
    return center + radius * (
        radial_x * cos(angle) + radial_z * sin(angle) * 1.08
    )

func _influences(t: float, side: float) -> Dictionary:
    var arm := 5 if side < 0.0 else 7
    var elbow := smoothstep(0.30, 0.79, t)
    var shoulder := 1.0 - smoothstep(0.04, 0.30, t)
    var weights := PackedFloat32Array([
        0.68 * (1.0 - elbow) + 0.04,
        0.89 * elbow,
        0.29 * shoulder,
        0.025 * shoulder
    ])
    var total := weights[0] + weights[1] + weights[2] + weights[3]
    for index in range(4):
        weights[index] /= maxf(total, 0.00001)
    return {"bones": PackedInt32Array([arm, arm + 1, 2, 1]), "weights": weights}

func _emit(tool: SurfaceTool, t: float, u: float, side: float, kind: int) -> void:
    var point := _point(t, u, side, kind)
    var influence := _influences(0.91 + 0.075 * t if kind == 2 else t, side)
    tool.set_bones(influence["bones"])
    tool.set_weights(influence["weights"])
    var angle := TAU * u
    var color := Color("#1d294a").lerp(Color("#6157a1"), 0.23 + 0.36 * t)
    color = color.lerp(Color("#4c99b5"), 0.19 * pow(maxf(0.0, sin(angle)), 3.0))
    color = color.lightened(0.08 * pow(maxf(0.0, cos(angle - 0.55)), 4.0))
    if kind == 1:
        color = Color("#5cf0ff").lerp(Color("#ca9bff"), 0.23 + 0.47 * t)
    elif kind == 2:
        color = Color("#455778").lerp(Color("#8bd6e2"), 0.38 + 0.26 * t)
    tool.set_color(color)
    tool.add_vertex(point)

func _mesh(side: float, kind: int) -> ArrayMesh:
    var rows := 3 if kind == 2 else ROWS
    var columns := 2 if kind == 1 else SIDES
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for row in range(rows):
        var t0 := float(row) / float(rows)
        var t1 := float(row + 1) / float(rows)
        for column in range(columns):
            var u0 := float(column) / float(columns)
            var u1 := float(column + 1) / float(columns)
            _emit(tool, t0, u0, side, kind)
            _emit(tool, t1, u0, side, kind)
            _emit(tool, t1, u1, side, kind)
            _emit(tool, t0, u0, side, kind)
            _emit(tool, t1, u1, side, kind)
            _emit(tool, t0, u1, side, kind)
    tool.generate_normals()
    return tool.commit()
