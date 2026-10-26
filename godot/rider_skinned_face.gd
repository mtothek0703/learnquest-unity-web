extends Node3D
## V102: one continuous, anatomically contoured facial surface, GPU-skinned to
## the SAME 13-bone original-body rig. Replaces floating nose/cheek spheres,
## not the eyes, expressions, hair or the original imported body.
## Procedural original geometry: no third-party assets, physics or input nodes.
const ROWS := 24
const COLUMNS := 32
var skeleton: Skeleton3D
var facial_surface: MeshInstance3D

func _ready() -> void:
    var model := get_parent() as Node3D
    var rig := model.get_node_or_null("OriginalBodySkinRig") as Node3D
    if rig == null:
        return
    skeleton = rig.get_node_or_null("OriginalBodySkeleton13") as Skeleton3D
    if skeleton == null or skeleton.get_bone_count() != 13:
        return
    var skin := skeleton.create_skin_from_rest_transforms()
    facial_surface = MeshInstance3D.new()
    facial_surface.name = "ContinuousSkinnedFace"
    facial_surface.mesh = _face_mesh()
    facial_surface.skin = skin
    var material := StandardMaterial3D.new()
    material.albedo_color = Color.WHITE
    material.vertex_color_use_as_albedo = true
    material.metallic = 0.0
    material.roughness = 0.58
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    facial_surface.material_override = material
    add_child(facial_surface)
    facial_surface.skeleton = facial_surface.get_path_to(skeleton)
    # Old nose and cheek spheres pierced the continuous facial surface.
    # Retire them only when the real skin has been successfully attached.
    var expressions := model.get_node_or_null("ExpressiveFace") as Node3D
    if expressions != null:
        for name in ["SculptedNose", "Cheek0", "Cheek1"]:
            var old := expressions.get_node_or_null(name) as MeshInstance3D
            if old != null:
                old.visible = false

func _point(t: float, u: float) -> Vector3:
    # Sculpted jaw tapers into cheekbones and forehead, not a flat mask.
    var y := lerpf(2.12, 2.80, t)
    var width := 0.34 + 0.12 * smoothstep(0.08, 0.60, t)
    var x := (2.0 * u - 1.0) * width
    var front := -0.19 - 0.225 * sqrt(maxf(0.0, 1.0 - pow(x / 0.53, 2.0)))
    var nose := exp(-pow(x / 0.105, 2.0) - pow((y - 2.35) / 0.145, 2.0))
    var cheek_l := exp(-pow((x + 0.275) / 0.13, 2.0) - pow((y - 2.33) / 0.17, 2.0))
    var cheek_r := exp(-pow((x - 0.275) / 0.13, 2.0) - pow((y - 2.33) / 0.17, 2.0))
    # Eye sockets recede so the existing blinkable eyes remain in FRONT.
    var socket_l := exp(-pow((x + 0.17) / 0.13, 2.0) - pow((y - 2.49) / 0.115, 2.0))
    var socket_r := exp(-pow((x - 0.17) / 0.13, 2.0) - pow((y - 2.49) / 0.115, 2.0))
    var chin := exp(-pow(x / 0.23, 2.0) - pow((y - 2.16) / 0.075, 2.0))
    var lip_recess := exp(-pow(x / 0.20, 2.0) - pow((y - 2.21) / 0.034, 2.0))
    var z := front - 0.085 * nose - 0.032 * (cheek_l + cheek_r)
    z += 0.074 * (socket_l + socket_r) - 0.018 * chin + 0.018 * lip_recess
    return Vector3(x, y, z)

func _emit(tool: SurfaceTool, t: float, u: float) -> void:
    var point := _point(t, u)
    var jaw_blend := smoothstep(2.15, 2.45, point.y)
    var head_weight := 0.70 + 0.30 * jaw_blend
    tool.set_bones(PackedInt32Array([4, 3, 2, 1]))
    tool.set_weights(PackedFloat32Array([head_weight, 1.0 - head_weight, 0.0, 0.0]))
    var blush_l := exp(-pow((point.x + 0.29) / 0.13, 2.0) - pow((point.y - 2.32) / 0.14, 2.0))
    var blush_r := exp(-pow((point.x - 0.29) / 0.13, 2.0) - pow((point.y - 2.32) / 0.14, 2.0))
    var skin := Color("#eeb38f").lerp(Color("#f5c7a4"), 0.40 * t)
    skin = skin.lerp(Color("#db8094"), clampf((blush_l + blush_r) * 0.37, 0.0, 0.37))
    skin = skin.darkened(0.13 * absf(2.0 * u - 1.0))
    tool.set_color(skin)
    tool.add_vertex(point)

func _face_mesh() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for row in range(ROWS):
        var t0 := float(row) / float(ROWS)
        var t1 := float(row + 1) / float(ROWS)
        for column in range(COLUMNS):
            var u0 := float(column) / float(COLUMNS)
            var u1 := float(column + 1) / float(COLUMNS)
            _emit(tool, t0, u0)
            _emit(tool, t1, u0)
            _emit(tool, t1, u1)
            _emit(tool, t0, u0)
            _emit(tool, t1, u1)
            _emit(tool, t0, u1)
    tool.generate_normals()
    return tool.commit()
