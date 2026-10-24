extends Node3D
## Skyway V35: original layered, volumetric hair sculpture. The scalp,
## six swept gradient locks and two wind-driven temple curls are generated
## once as meshes, not rebuilt each frame. No third-party textures/assets.
var clock: float = 0.0
var temple_pivots: Array[Node3D] = []
var glow_material: StandardMaterial3D

func _ready() -> void:
    _build_hair()

func _process(delta: float) -> void:
    clock += delta
    var rider := get_parent().get_parent() as Node3D
    var lean: float = float(rider.get("lean")) if rider != null else 0.0
    var turbo: bool = bool(rider.get("boosting")) if rider != null else false
    var pace := 8.5 if turbo else 3.2
    for i in range(temple_pivots.size()):
        var pivot := temple_pivots[i]
        var side := -1.0 if i == 0 else 1.0
        var wind := -0.20 if turbo else 0.025
        pivot.rotation.x = lerpf(pivot.rotation.x, wind + sin(clock * pace + float(i)) * 0.06, minf(1.0, delta * 6.0))
        pivot.rotation.z = lerpf(pivot.rotation.z, -lean * 0.20 + side * sin(clock * 2.6) * 0.045, minf(1.0, delta * 6.0))
    if glow_material != null:
        glow_material.emission_energy_multiplier = 1.15 + (0.45 if turbo else 0.10) * (0.5 + 0.5 * sin(clock * pace))

func _hair_material() -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = Color.WHITE
    material.vertex_color_use_as_albedo = true
    material.metallic = 0.14
    material.roughness = 0.46
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    return material

func _build_hair() -> void:
    var hair := _hair_material()
    var scalp := MeshInstance3D.new()
    scalp.name = "VolumetricScalp"
    scalp.mesh = _scalp_mesh()
    scalp.material_override = hair
    add_child(scalp)
    glow_material = StandardMaterial3D.new()
    glow_material.albedo_color = Color(0.30, 0.83, 1.0)
    glow_material.emission_enabled = true
    glow_material.emission = Color(0.09, 0.45, 0.68)
    glow_material.emission_energy_multiplier = 1.25
    glow_material.cull_mode = BaseMaterial3D.CULL_DISABLED
    for layer in range(6):
        var lock := MeshInstance3D.new()
        lock.name = "SweptLayer%d" % layer
        lock.mesh = _layer_mesh(layer, false)
        lock.material_override = hair
        add_child(lock)
        var sheen := MeshInstance3D.new()
        sheen.name = "LuminousHairSheen%d" % layer
        sheen.mesh = _layer_mesh(layer, true)
        sheen.material_override = glow_material
        add_child(sheen)
    temple_pivots.clear()
    for i in range(2):
        var side := -1.0 if i == 0 else 1.0
        var pivot := Node3D.new()
        pivot.name = "LeftTempleCurl" if i == 0 else "RightTempleCurl"
        pivot.position = Vector3(side * 0.49, 2.74, -0.09)
        add_child(pivot)
        var curl := MeshInstance3D.new()
        curl.name = "SculptedCurl"
        curl.mesh = _temple_mesh(side)
        curl.material_override = hair
        pivot.add_child(curl)
        temple_pivots.append(pivot)

func _scalp_point(t: float, angle: float) -> Vector3:
    # Upper half-ellipsoid hugs the forehead without hiding the eyes.
    var latitude := t * PI * 0.5
    var spread := sin(latitude)
    return Vector3(
        0.485 * spread * cos(angle),
        2.69 + 0.43 * cos(latitude),
        0.055 + 0.48 * spread * sin(angle)
    )

func _scalp_vertex(tool: SurfaceTool, t: float, angle: float) -> void:
    var sheen := 0.80 + 0.20 * maxf(0.0, sin(angle))
    var shade := Color(0.12, 0.07, 0.27).lerp(Color(0.45, 0.16, 0.57), t * 0.58)
    tool.set_color(shade * sheen)
    tool.add_vertex(_scalp_point(t, angle))

func _scalp_mesh() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    const ROWS := 14
    const SIDES := 32
    for row in range(ROWS):
        var t0 := float(row) / float(ROWS)
        var t1 := float(row + 1) / float(ROWS)
        for side in range(SIDES):
            var a0 := TAU * float(side) / float(SIDES)
            var a1 := TAU * float(side + 1) / float(SIDES)
            _scalp_vertex(tool, t0, a0)
            _scalp_vertex(tool, t1, a0)
            _scalp_vertex(tool, t1, a1)
            _scalp_vertex(tool, t0, a0)
            _scalp_vertex(tool, t1, a1)
            _scalp_vertex(tool, t0, a1)
    tool.generate_normals()
    return tool.commit()

func _layer_point(t: float, u: float, layer: int) -> Vector3:
    # Six overlapping, asymmetrically swept sculpted hair plates; each has
    # a curved back profile, pointed tip and subtly raised central ridge.
    var side := float(layer) - 2.5
    var across := u * 2.0 - 1.0
    var width := (0.21 - 0.14 * t) * pow(1.0 - t, 0.55)
    return Vector3(
        side * 0.15 + across * width * 0.5 + 0.035 * sin(t * PI) - side * 0.009 * t,
        2.97 - 0.47 * t + 0.035 * sin(t * PI),
        0.38 + 0.31 * t + 0.055 * sin(t * PI) + 0.035 * (1.0 - across * across)
    )

func _layer_vertex(tool: SurfaceTool, t: float, u: float, layer: int, accent: bool) -> void:
    var shade := Color(0.17, 0.09, 0.33).lerp(Color(0.72, 0.28, 0.72), t * 0.76)
    var glint := 0.78 + 0.22 * (1.0 - absf(u * 2.0 - 1.0))
    tool.set_color(Color.WHITE if accent else shade * glint)
    var point := _layer_point(t, u, layer)
    if accent:
        point.z += 0.012
    tool.add_vertex(point)

func _layer_mesh(layer: int, accent: bool) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    const ROWS := 14
    const COLUMNS := 6
    for row in range(ROWS):
        var t0 := lerpf(0.18, 0.88, float(row) / float(ROWS)) if accent else float(row) / float(ROWS)
        var t1 := lerpf(0.18, 0.88, float(row + 1) / float(ROWS)) if accent else float(row + 1) / float(ROWS)
        for column in range(COLUMNS):
            var u0 := lerpf(0.47, 0.53, float(column) / float(COLUMNS)) if accent else float(column) / float(COLUMNS)
            var u1 := lerpf(0.47, 0.53, float(column + 1) / float(COLUMNS)) if accent else float(column + 1) / float(COLUMNS)
            _layer_vertex(tool, t0, u0, layer, accent)
            _layer_vertex(tool, t1, u0, layer, accent)
            _layer_vertex(tool, t1, u1, layer, accent)
            _layer_vertex(tool, t0, u0, layer, accent)
            _layer_vertex(tool, t1, u1, layer, accent)
            _layer_vertex(tool, t0, u1, layer, accent)
    tool.generate_normals()
    return tool.commit()

func _curl_center(t: float, side: float) -> Vector3:
    return Vector3(side * (0.09 * t + 0.045 * sin(t * PI)), -0.61 * t, 0.15 * t + 0.08 * sin(t * PI))

func _curl_point(t: float, angle: float, side: float) -> Vector3:
    var tangent := (_curl_center(minf(1.0, t + 0.003), side) - _curl_center(maxf(0.0, t - 0.003), side)).normalized()
    var across := tangent.cross(Vector3.FORWARD).normalized()
    var depth := tangent.cross(across).normalized()
    var radius := 0.105 * pow(1.0 - t, 0.7) + 0.009
    return _curl_center(t, side) + (across * cos(angle) + depth * sin(angle)) * radius

func _curl_vertex(tool: SurfaceTool, t: float, angle: float, side: float) -> void:
    var shade := Color(0.14, 0.08, 0.32).lerp(Color(0.64, 0.24, 0.66), t * 0.75)
    tool.set_color(shade * (0.83 + 0.17 * cos(angle)))
    tool.add_vertex(_curl_point(t, angle, side))

func _temple_mesh(side: float) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    const SECTIONS := 18
    const SIDES := 10
    for section in range(SECTIONS):
        var t0 := float(section) / float(SECTIONS)
        var t1 := float(section + 1) / float(SECTIONS)
        for i in range(SIDES):
            var a0 := TAU * float(i) / float(SIDES)
            var a1 := TAU * float(i + 1) / float(SIDES)
            _curl_vertex(tool, t0, a0, side)
            _curl_vertex(tool, t1, a0, side)
            _curl_vertex(tool, t1, a1, side)
            _curl_vertex(tool, t0, a0, side)
            _curl_vertex(tool, t1, a1, side)
            _curl_vertex(tool, t0, a1, side)
    tool.generate_normals()
    return tool.commit()
