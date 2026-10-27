extends Node3D
## Original, lightweight articulated aerofoil costume for the glTF rider.
## Two curved two-layer winglets, luminous edge piping and animated wind response.
## Geometry is generated once at startup: no paid assets or runtime mesh rebuilds.
var wings: Array[Node3D] = []
var lights: Array[StandardMaterial3D] = []
var clock: float = 0.0
# V113: keep the original curved aerofoils but stow them at cruising speed.
# Boost and jump unfold both winglets; only visual transforms change.
var deployment: float = 0.0

func _ready() -> void:
    _build_wings()
    for wing in wings:
        wing.visible = false
        wing.scale = Vector3.ONE * 0.12

func _process(delta: float) -> void:
    clock += delta
    var rider := get_parent().get_parent() as Node3D
    var lean := float(rider.get("lean")) if rider != null else 0.0
    var turbo := bool(rider.get("boosting")) if rider != null else false
    var airborne := rider != null and rider.position.y > 0.18
    var active := turbo or airborne
    deployment = move_toward(deployment, 1.0 if active else 0.0, delta * (3.5 if active else 2.6))
    var opened := smoothstep(0.0, 1.0, deployment)
    for i in range(wings.size()):
        var side := -1.0 if i == 0 else 1.0
        var wing := wings[i]
        wing.visible = deployment > 0.015
        wing.scale = Vector3.ONE * lerpf(0.12, 1.0, opened)
        var spread := 0.27 if turbo else 0.07
        wing.rotation.z = lerpf(wing.rotation.z, side * spread - lean * 0.12 + sin(clock * 2.8 + float(i)) * 0.025, minf(1.0, delta * 7.0))
        wing.rotation.x = lerpf(wing.rotation.x, (-0.18 if turbo else -0.03) + sin(clock * 3.7 + float(i)) * 0.025, minf(1.0, delta * 6.0))
        lights[i].emission_energy_multiplier = 1.7 + (0.65 if turbo else 0.20) * (0.5 + 0.5 * sin(clock * (10.0 if turbo else 3.0) + float(i)))

func _fabric() -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = Color.WHITE
    material.vertex_color_use_as_albedo = true
    material.metallic = 0.37
    material.roughness = 0.34
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    return material

func _neon() -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = Color(0.13, 0.92, 1.0)
    material.emission_enabled = true
    material.emission = Color(0.06, 0.62, 0.93)
    material.emission_energy_multiplier = 1.7
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    return material

func _build_wings() -> void:
    wings.clear()
    lights.clear()
    var shell := _fabric()
    for i in range(2):
        var side := -1.0 if i == 0 else 1.0
        var pivot := Node3D.new()
        pivot.name = "LeftWing" if i == 0 else "RightWing"
        # Wing roots are outside the coat and behind the shoulders.
        pivot.position = Vector3(side * 0.54, 2.02, 0.60)
        add_child(pivot)
        var light := _neon()
        for layer in range(2):
            var panel := MeshInstance3D.new()
            panel.name = "SculptedUpperFin" if layer == 0 else "SculptedLowerFin"
            panel.mesh = _panel_mesh(side, layer, false, false)
            panel.material_override = shell
            pivot.add_child(panel)
            var edge := MeshInstance3D.new()
            edge.name = "UpperNeonEdge" if layer == 0 else "LowerNeonEdge"
            edge.mesh = _panel_mesh(side, layer, true, false)
            edge.material_override = light
            pivot.add_child(edge)
            var vein := MeshInstance3D.new()
            vein.name = "UpperNeonVein" if layer == 0 else "LowerNeonVein"
            vein.mesh = _panel_mesh(side, layer, false, true)
            vein.material_override = light
            pivot.add_child(vein)
        # Small metal shoulder hinge; the large fins use original curved meshes.
        var hinge := MeshInstance3D.new()
        hinge.name = "ShoulderHinge"
        var hinge_mesh := SphereMesh.new()
        hinge_mesh.radius = 0.13
        hinge_mesh.height = 0.20
        hinge.mesh = hinge_mesh
        hinge.position = Vector3(0.0, 0.0, 0.11)
        var metal := StandardMaterial3D.new()
        metal.albedo_color = Color(0.12, 0.14, 0.34)
        metal.metallic = 0.72
        metal.roughness = 0.26
        hinge.material_override = metal
        pivot.add_child(hinge)
        wings.append(pivot)
        lights.append(light)

func _fin_point(u: float, v: float, side: float, layer: int) -> Vector3:
    var span := 0.87 if layer == 0 else 0.66
    var chord := (0.32 if layer == 0 else 0.25) * (1.0 - 0.52 * u)
    var base_y := 0.09 if layer == 0 else -0.18
    var rise := 0.27 if layer == 0 else 0.10
    var base_z := 0.10 if layer == 0 else 0.24
    return Vector3(
        side * (0.035 + span * u),
        base_y + rise * u + sin(u * PI) * 0.075 + (v - 0.5) * 0.08,
        base_z + 0.20 * u * u + (v - 0.5) * chord + sin(u * PI) * 0.045
    )

func _vertex(tool: SurfaceTool, point: Vector3, u: float, layer: int) -> void:
    var root_color := Color(0.13, 0.15, 0.39) if layer == 0 else Color(0.26, 0.13, 0.50)
    var tip_color := Color(0.67, 0.23, 0.82) if layer == 0 else Color(0.86, 0.25, 0.61)
    tool.set_color(root_color.lerp(tip_color, u * 0.85))
    tool.add_vertex(point)

func _panel_mesh(side: float, layer: int, edge: bool, vein: bool) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    const ROWS := 18
    const COLUMNS := 7
    for row in range(ROWS):
        var u0 := float(row) / float(ROWS)
        var u1 := float(row + 1) / float(ROWS)
        for col in range(COLUMNS):
            var v0 := float(col) / float(COLUMNS)
            var v1 := float(col + 1) / float(COLUMNS)
            if edge:
                v0 = 0.018 + v0 * 0.045
                v1 = 0.018 + v1 * 0.045
            elif vein:
                v0 = 0.49 + v0 * 0.030
                v1 = 0.49 + v1 * 0.030
            var offset := Vector3(0.0, 0.0, 0.014 if edge or vein else 0.0)
            var a := _fin_point(u0, v0, side, layer) + offset
            var b := _fin_point(u1, v0, side, layer) + offset
            var c := _fin_point(u0, v1, side, layer) + offset
            var d := _fin_point(u1, v1, side, layer) + offset
            _vertex(tool, a, u0, layer)
            _vertex(tool, b, u1, layer)
            _vertex(tool, d, u1, layer)
            _vertex(tool, a, u0, layer)
            _vertex(tool, d, u1, layer)
            _vertex(tool, c, u0, layer)
    tool.generate_normals()
    return tool.commit()
