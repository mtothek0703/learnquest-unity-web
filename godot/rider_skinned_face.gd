extends Node3D
## V105: complete 360-degree head and neck with sculpted facial relief.
## Shared original 13-bone GPU skin; eye expressions, hair and helmet remain.
## Procedural original geometry: no third-party assets, physics or input nodes.
const ROWS := 36
const COLUMNS := 48
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
    # The old glTF contains three opaque head/crown/visor surfaces in front
    # of this skinned head. Retire them only after the replacement has a valid
    # mesh, skin and the original skeleton, preserving the rest of the body.
    if facial_surface.mesh != null and facial_surface.skin != null and \
            facial_surface.skin.get_bind_count() == 13:
        rig.call("retire_legacy_head_surfaces")
    # Old nose and cheek spheres pierced the continuous facial surface.
    # Retire them only when the real skin has been successfully attached.
    var expressions := model.get_node_or_null("ExpressiveFace") as Node3D
    if expressions != null:
        for name in ["SculptedNose", "Cheek0", "Cheek1"]:
            var old := expressions.get_node_or_null(name) as MeshInstance3D
            if old != null:
                old.visible = false


func _point(t: float, u: float) -> Vector3:
    # Rounded head, back, temples, chin and neck in ONE deforming surface.
    var y := lerpf(1.98, 3.08, t)
    var angle := TAU * u
    # V109: superelliptic cranial dome keeps volume above the temples.
    # The old sin(t*PI)^0.55 profile collapsed into a pointed egg-shaped
    # crown in actual V108 16:9 renders. This remains one closed GPU skin.
    var dome_height := (y - 2.53) / 0.55
    var profile := sqrt(maxf(0.0, 1.0 - pow(absf(dome_height), 4.0)))
    var neck := 1.0 - smoothstep(0.0, 0.14, t)
    var width := 0.47 * profile + 0.20 * neck
    var depth := 0.46 * profile + 0.17 * neck
    var x := sin(angle) * width
    var front := pow(maxf(0.0, -cos(angle)), 4.0)
    var z := 0.025 + cos(angle) * depth
    var nose := exp(-pow(x / 0.105, 2.0) - pow((y - 2.35) / 0.145, 2.0))
    var cheeks := exp(-pow((x + 0.275) / 0.13, 2.0) - pow((y - 2.33) / 0.17, 2.0))
    cheeks += exp(-pow((x - 0.275) / 0.13, 2.0) - pow((y - 2.33) / 0.17, 2.0))
    var sockets := exp(-pow((x + 0.17) / 0.13, 2.0) - pow((y - 2.49) / 0.115, 2.0))
    sockets += exp(-pow((x - 0.17) / 0.13, 2.0) - pow((y - 2.49) / 0.115, 2.0))
    var chin := exp(-pow(x / 0.23, 2.0) - pow((y - 2.17) / 0.105, 2.0))
    var lips := exp(-pow(x / 0.20, 2.0) - pow((y - 2.21) / 0.034, 2.0))
    z -= front * (0.085 * nose + 0.035 * cheeks + 0.125 * chin)
    z += front * (0.095 * sockets + 0.018 * lips)
    return Vector3(x, y, z)

func _emit(tool: SurfaceTool, t: float, u: float) -> void:
    var point := _point(t, u)
    var head_weight := 0.57 + 0.43 * smoothstep(2.08, 2.48, point.y)
    tool.set_bones(PackedInt32Array([4, 3, 2, 1]))
    tool.set_weights(PackedFloat32Array([head_weight, 1.0 - head_weight, 0.0, 0.0]))
    var front := pow(maxf(0.0, -cos(TAU * u)), 4.0)
    var blush := exp(-pow((point.x + 0.29) / 0.13, 2.0) - pow((point.y - 2.32) / 0.14, 2.0))
    blush += exp(-pow((point.x - 0.29) / 0.13, 2.0) - pow((point.y - 2.32) / 0.14, 2.0))
    var skin := Color("#eeb38f").lerp(Color("#f5c7a4"), 0.38 * smoothstep(2.08, 2.94, point.y))
    skin = skin.lerp(Color("#db8094"), clampf(front * blush * 0.37, 0.0, 0.37))
    skin = skin.darkened(0.12 * absf(sin(TAU * u)) + 0.07 * (1.0 - front))
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
            # Outward winding for the complete 360-degree cranial volume.
            _emit(tool, t0, u0)
            _emit(tool, t1, u1)
            _emit(tool, t1, u0)
            _emit(tool, t0, u0)
            _emit(tool, t0, u1)
            _emit(tool, t1, u1)
    tool.generate_normals()
    return tool.commit()
