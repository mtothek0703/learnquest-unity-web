extends Node3D
## V84: six jointed, translucent energy sails expand the hero silhouette.
## All meshes are generated once; only transforms and emission animate.
## Entirely original Godot geometry, no external assets or collision shapes.
const ROWS := 18
const COLUMNS := 6
const FEATHERS_PER_SIDE := 3

var elapsed: float = 0.0
# V112: idle chase view must not be obscured by six translucent sails.
# Keep every original sail and animation, deploying them for boost/jumps.
var deployment: float = 0.0
var sail_roots: Array[Node3D] = []
var feathers: Array[Node3D] = []
var light_materials: Array[StandardMaterial3D] = []

func _ready() -> void:
    _build_sails()
    for sail in sail_roots:
        sail.visible = false
        sail.scale = Vector3.ONE * 0.12

func _process(delta: float) -> void:
    elapsed += delta
    var rider := get_parent().get_parent() as Node3D
    var lean := float(rider.get("lean")) if rider != null else 0.0
    var turbo := bool(rider.get("boosting")) if rider != null else false
    var airborne := rider != null and rider.position.y > 0.18
    var active := turbo or airborne
    deployment = move_toward(deployment, 1.0 if active else 0.0, delta * (3.4 if active else 2.6))
    var eased := smoothstep(0.0, 1.0, deployment)
    for i in range(sail_roots.size()):
        var side := -1.0 if i == 0 else 1.0
        var root := sail_roots[i]
        # Fully fold the duplicate idle wings; expand smoothly only during
        # an actual power-up or jump. This also avoids idle alpha overdraw.
        root.visible = deployment > 0.015
        root.scale = Vector3.ONE * lerpf(0.12, 1.0, eased)
        # Counter-steer the two wings and spread them during Turbo.
        var spread := 0.12 if turbo else -0.025
        root.rotation.z = lerpf(root.rotation.z, side * spread - lean * 0.08, minf(1.0, delta * 7.0))
        root.rotation.y = lerpf(root.rotation.y, side * (0.13 if turbo else -0.04) - lean * 0.09, minf(1.0, delta * 6.0))
        for layer in range(FEATHERS_PER_SIDE):
            var feather := feathers[i * FEATHERS_PER_SIDE + layer]
            var wave := sin(elapsed * (9.0 if turbo else 3.4) - float(layer) * 0.85 + float(i))
            feather.rotation.x = lerpf(feather.rotation.x, (0.16 if turbo else -0.08) + wave * 0.055, minf(1.0, delta * 7.0))
            feather.rotation.z = lerpf(feather.rotation.z, side * (0.10 if turbo else 0.01) + side * wave * 0.035, minf(1.0, delta * 7.0))
            feather.scale.x = lerpf(feather.scale.x, 1.20 if turbo else 0.90, minf(1.0, delta * 6.0))
        light_materials[i].emission_energy_multiplier = 1.65 + (1.20 if turbo else 0.28) * (0.5 + 0.5 * sin(elapsed * (11.0 if turbo else 3.5) + float(i)))

func _membrane_material() -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = Color.WHITE
    material.vertex_color_use_as_albedo = true
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    material.metallic = 0.20
    material.roughness = 0.35
    return material

func _edge_material() -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = Color.WHITE
    material.vertex_color_use_as_albedo = true
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    material.emission_enabled = true
    material.emission = Color(0.19, 0.83, 1.0)
    material.emission_energy_multiplier = 1.65
    return material

func _build_sails() -> void:
    sail_roots.clear()
    feathers.clear()
    light_materials.clear()
    var fabric := _membrane_material()
    for i in range(2):
        var side := -1.0 if i == 0 else 1.0
        var root := Node3D.new()
        root.name = "LeftSailPivot" if i == 0 else "RightSailPivot"
        # Behind the sculpted shoulder armor, outside the rider's centerline.
        root.position = Vector3(side * 0.62, 1.97, 1.12)
        add_child(root)
        sail_roots.append(root)
        var edge_material := _edge_material()
        light_materials.append(edge_material)
        for layer in range(FEATHERS_PER_SIDE):
            var feather := Node3D.new()
            feather.name = "Feather%d" % layer
            feather.position = Vector3(side * 0.035, -float(layer) * 0.19, float(layer) * 0.11)
            root.add_child(feather)
            feathers.append(feather)
            var panel := MeshInstance3D.new()
            panel.name = "CurvedEnergyMembrane"
            panel.mesh = _sail_mesh(side, layer, 0)
            panel.material_override = fabric
            feather.add_child(panel)
            var edge := MeshInstance3D.new()
            edge.name = "LuminousFeatherEdge"
            edge.mesh = _sail_mesh(side, layer, 1)
            edge.material_override = edge_material
            feather.add_child(edge)
            var vein := MeshInstance3D.new()
            vein.name = "LuminousCenterSpine"
            vein.mesh = _sail_mesh(side, layer, 2)
            vein.material_override = edge_material
            feather.add_child(vein)

func _sail_point(t: float, across: float, side: float, layer: int) -> Vector3:
    var span := 1.08 + float(layer) * 0.16
    var chord := (0.50 - float(layer) * 0.05) * (1.0 - t * 0.54)
    return Vector3(
        side * (0.04 + span * t),
        (0.38 - float(layer) * 0.11) * t + sin(t * PI) * 0.11 + (across - 0.5) * 0.16,
        0.11 + 0.43 * t * t + sin(t * PI) * 0.12 + (across - 0.5) * chord
    )

func _vertex(tool: SurfaceTool, point: Vector3, t: float, strip: int) -> void:
    var tint := Color(0.09, 0.32, 0.66, 0.70).lerp(Color(0.90, 0.28, 0.87, 0.28), t)
    if strip != 0:
        tint = Color(0.36, 0.98, 1.0, 0.90 - t * 0.42)
    tool.set_color(tint)
    tool.add_vertex(point)

func _sail_mesh(side: float, layer: int, strip: int) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    var columns := COLUMNS if strip == 0 else 1
    for row in range(ROWS):
        var t0 := float(row) / float(ROWS)
        var t1 := float(row + 1) / float(ROWS)
        for col in range(columns):
            var u0 := float(col) / float(columns)
            var u1 := float(col + 1) / float(columns)
            if strip == 1:
                u0 = 0.945
                u1 = 0.985
            elif strip == 2:
                u0 = 0.49
                u1 = 0.515
            var offset := Vector3(0.0, 0.0, 0.018 if strip != 0 else 0.0)
            var a := _sail_point(t0, u0, side, layer) + offset
            var b := _sail_point(t1, u0, side, layer) + offset
            var c := _sail_point(t1, u1, side, layer) + offset
            var d := _sail_point(t0, u1, side, layer) + offset
            _vertex(tool, a, t0, strip)
            _vertex(tool, b, t1, strip)
            _vertex(tool, c, t1, strip)
            _vertex(tool, a, t0, strip)
            _vertex(tool, c, t1, strip)
            _vertex(tool, d, t0, strip)
    tool.generate_normals()
    return tool.commit()
