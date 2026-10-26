extends Node3D
## V106: one continuous 360-degree flight-jacket surface joins waist, chest,
## shoulders and raised collar. Unlike V38's rigid front panels, the garment
## is GPU-skinned to the ORIGINAL 13-bone rider, including arm/neck blending.
## Procedural authored geometry only; no gameplay, input or collision nodes.
const ROWS := 28
const SIDES := 40
var skeleton: Skeleton3D
var jacket: MeshInstance3D
var collar_edge: MeshInstance3D
var center_seam: MeshInstance3D

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
    fabric.metallic = 0.22
    fabric.roughness = 0.49
    fabric.cull_mode = BaseMaterial3D.CULL_DISABLED
    var luminous := StandardMaterial3D.new()
    luminous.albedo_color = Color.WHITE
    luminous.vertex_color_use_as_albedo = true
    luminous.emission_enabled = true
    luminous.emission = Color("#50e4ff")
    luminous.emission_energy_multiplier = 1.25
    luminous.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    luminous.cull_mode = BaseMaterial3D.CULL_DISABLED
    jacket = _attach("UnifiedSkinnedJacket", _mesh(0), fabric, skin)
    collar_edge = _attach("SkinnedCollarEdge", _mesh(1), luminous, skin)
    center_seam = _attach("SkinnedCenterSeam", _mesh(2), luminous, skin)
    if jacket == null or collar_edge == null or center_seam == null:
        return
    # Retire V38's unskinned front panels, chest plates, zipper and collar
    # only after the replacement meshes have a valid original-body skin.
    # The older V100 BACK shell, animated reactor and sleeves stay intact.
    var old := model.get_node_or_null("AnimatedTailoredFlightJacket") as Node3D
    if old != null:
        var breathing := old.get_node_or_null("AnimatedBreathingJacket") as Node3D
        if breathing != null:
            for name in ["TailoredLeftChest", "TailoredRightChest",
                    "LayeredLeftChestArmor", "LayeredRightChestArmor",
                    "LuminousCenterZipper", "LuminousWaistPiping",
                    "LuminousLeftChestEdge", "LuminousRightChestEdge"]:
                var part := breathing.get_node_or_null(name) as MeshInstance3D
                if part != null:
                    part.visible = false
        var old_collar := old.get_node_or_null("RaisedFlightCollar") as MeshInstance3D
        if old_collar != null:
            old_collar.visible = false

func _attach(name: String, surface: ArrayMesh, material: Material, skin: Skin) -> MeshInstance3D:
    if surface == null or surface.get_surface_count() == 0:
        return null
    var part := MeshInstance3D.new()
    part.name = name
    part.mesh = surface
    part.material_override = material
    part.skin = skin
    add_child(part)
    part.skeleton = part.get_path_to(skeleton)
    return part

func _point(t: float, u: float, kind: int) -> Vector3:
    if kind == 1:
        t = 0.956 + 0.033 * t
    elif kind == 2:
        t = 0.12 + 0.69 * t
        u = 0.5 + (u - 0.5) * 0.019
    var angle := TAU * u
    var front := maxf(0.0, -cos(angle))
    var shoulders := smoothstep(0.08, 0.71, t)
    var collar := smoothstep(0.80, 1.0, t)
    var width := 0.36 + 0.20 * shoulders - 0.13 * collar
    var depth := 0.55 + 0.13 * shoulders - 0.22 * collar
    # The collar rises behind the head but forms a lowered V at the face.
    # Rounded shoulders meet the skinned sleeves without rigid box joints.
    var point := Vector3(
        sin(angle) * width,
        1.11 + 1.28 * t - 0.19 * front * collar,
        cos(angle) * depth - 0.018 * front * (1.0 - absf(sin(angle)))
    )
    if kind == 1:
        point.x += sin(angle) * 0.024
        point.z += cos(angle) * 0.024
    elif kind == 2:
        point.z -= 0.024
    return point

func _influences(point: Vector3) -> Dictionary:
    var ids := PackedInt32Array([0, 1, 2, 3])
    var weights := PackedFloat32Array([0.0, 0.0, 0.0, 0.0])
    var chest := smoothstep(1.32, 2.03, point.y)
    var neck := smoothstep(2.08, 2.40, point.y)
    if point.y > 1.83 and absf(point.x) > 0.41 and point.y < 2.23:
        var arm := 5 if point.x < 0.0 else 7
        var blend := 0.42 * smoothstep(0.41, 0.57, absf(point.x))
        ids = PackedInt32Array([1, 2, 3, arm])
        weights = PackedFloat32Array([0.10 * (1.0 - chest), 0.88 - blend,
            0.02 + 0.10 * neck, blend])
    elif point.y > 2.09:
        ids = PackedInt32Array([1, 2, 3, 4])
        weights = PackedFloat32Array([0.02, 0.80 * (1.0 - neck),
            0.18 + 0.67 * neck, 0.13 * neck])
    else:
        weights = PackedFloat32Array([
            0.11 * (1.0 - chest), 0.77 * (1.0 - chest),
            0.90 * chest, 0.10 * chest
        ])
    var total := weights[0] + weights[1] + weights[2] + weights[3]
    for i in range(4):
        weights[i] /= maxf(total, 0.00001)
    return {"bones": ids, "weights": weights}

func _emit(tool: SurfaceTool, t: float, u: float, kind: int) -> void:
    var point := _point(t, u, kind)
    var influence := _influences(point)
    tool.set_bones(influence["bones"])
    tool.set_weights(influence["weights"])
    var angle := TAU * u
    var shade := Color("#15213d").lerp(Color("#55509b"), 0.22 + 0.58 * t)
    shade = shade.lerp(Color("#428aaf"), 0.18 * (1.0 - absf(sin(angle))))
    # Fabric shading across shoulder curvature, distinct from neon piping.
    shade = shade.lightened(0.10 * pow(maxf(0.0, cos(angle - 0.65)), 3.0))
    if kind != 0:
        shade = Color("#5df3ff").lerp(Color("#d3a2ff"), 0.18 + 0.48 * t)
    tool.set_color(shade)
    tool.add_vertex(point)

func _mesh(kind: int) -> ArrayMesh:
    var rows := ROWS if kind == 0 else (2 if kind == 1 else 24)
    var sides := SIDES if kind != 2 else 2
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for row in range(rows):
        var t0 := float(row) / float(rows)
        var t1 := float(row + 1) / float(rows)
        for side in range(sides):
            var u0 := float(side) / float(sides)
            var u1 := float(side + 1) / float(sides)
            _emit(tool, t0, u0, kind)
            _emit(tool, t1, u0, kind)
            _emit(tool, t1, u1, kind)
            _emit(tool, t0, u0, kind)
            _emit(tool, t1, u1, kind)
            _emit(tool, t0, u1, kind)
    tool.generate_normals()
    return tool.commit()
