extends Node3D
## V118 / Sprint 3: substantial, entirely original Neon City architecture.
## Twelve moving, tapered multi-tier buildings, three district identities,
## instanced luminous facades and roof crowns. All outside the playable lanes.
## Geometry is generated once; no external assets, shadows or new collisions.

const BUILDING_COUNT := 12
const SPACING := 13.0
const LOOP_LENGTH := BUILDING_COUNT * SPACING

var running := false
var travel_speed := 14.0
var towers: Array[Node3D] = []
var window_batches: Array[MultiMeshInstance3D] = []
var roof_crowns: Array[MeshInstance3D] = []
var sky_terraces: Array[MeshInstance3D] = []
var terrace_supports: Array[MultiMeshInstance3D] = []
var district_styles: Array[int] = []
var elapsed := 0.0

func _facade_material() -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = Color.WHITE
    material.vertex_color_use_as_albedo = true
    material.metallic = 0.42
    material.roughness = 0.38
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    return material

func _glow_material() -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = Color.WHITE
    material.vertex_color_use_as_albedo = true
    material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    material.emission_enabled = true
    material.emission = Color("#62b8fa")
    material.emission_energy_multiplier = 1.15
    return material

func _profile(t: float, style: int) -> float:
    var u := clampf(t, 0.0, 1.0)
    match style:
        0:
            return 2.50 - 0.75 * u + 0.18 * sin(PI * u)
        1:
            return 2.55 - 0.62 * u + (0.20 if u < 0.58 else -0.18)
        _:
            return 2.35 - 0.55 * u + 0.15 * sin(TAU * u * 2.0)

func _corner(corner: int, t: float, height: float, style: int) -> Vector3:
    var radius := _profile(t, style)
    var x := -1.0 if corner == 0 or corner == 3 else 1.0
    var z := -1.0 if corner < 2 else 1.0
    return Vector3(x * radius, t * height, z * radius)

func _emit(tool: SurfaceTool, point: Vector3, tint: Color) -> void:
    tool.set_color(tint)
    tool.add_vertex(point)

func _shell_mesh(height: float, style: int) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    var base: Color = [Color("#1b3654"), Color("#352e64"), Color("#263a61")][style]
    var top: Color = [Color("#6584b3"), Color("#9a649b"), Color("#58a3a8")][style]
    for ring in range(16):
        var t0 := float(ring) / 16.0
        var t1 := float(ring + 1) / 16.0
        for face in range(4):
            var a := _corner(face, t0, height, style)
            var b := _corner((face + 1) % 4, t0, height, style)
            var c := _corner(face, t1, height, style)
            var d := _corner((face + 1) % 4, t1, height, style)
            var low: Color = base.lerp(top, t0 * 0.70 + float(face % 2) * 0.08)
            var high: Color = base.lerp(top, t1 * 0.70 + float(face % 2) * 0.08)
            _emit(tool, a, low)
            _emit(tool, c, high)
            _emit(tool, b, low)
            _emit(tool, b, low)
            _emit(tool, c, high)
            _emit(tool, d, high)
    var roof := _profile(1.0, style)
    var crown_color: Color = top.lightened(0.10)
    for triangle in [[0, 1, 2], [0, 2, 3]]:
        for index in triangle:
            _emit(tool, _corner(index, 1.0, height, style), crown_color)
    tool.generate_normals()
    return tool.commit()

func _batch(mesh: Mesh, transforms: Array[Transform3D], colors: Array[Color], label: String, parent: Node3D, material: StandardMaterial3D) -> MultiMeshInstance3D:
    var multimesh := MultiMesh.new()
    multimesh.transform_format = MultiMesh.TRANSFORM_3D
    multimesh.use_colors = true
    multimesh.mesh = mesh
    multimesh.instance_count = transforms.size()
    for i in range(transforms.size()):
        multimesh.set_instance_transform(i, transforms[i])
        multimesh.set_instance_color(i, colors[i])
    var instance := MultiMeshInstance3D.new()
    instance.name = label
    instance.multimesh = multimesh
    instance.material_override = material
    parent.add_child(instance)
    return instance

func _build_facade_windows(tower: Node3D, height: float, style: int, side: float, material: StandardMaterial3D) -> void:
    var pane := BoxMesh.new()
    pane.size = Vector3(0.70, 0.92, 0.07)
    var transforms: Array[Transform3D] = []
    var colors: Array[Color] = []
    var row := 0
    var y := 2.0
    while y < height - 1.6:
        var radius := _profile(y / height, style)
        for column in range(3):
            var offset := float(column - 1) * 1.12
            # Inner facade faces the track; front facade adds depth in chase.
            transforms.append(Transform3D(Basis(Vector3.UP, PI * 0.5), Vector3(-side * (radius + 0.10), y, offset)))
            transforms.append(Transform3D(Basis(), Vector3(offset, y, radius + 0.10)))
            var warm := (row + column + style) % 5 == 0
            var tint := Color("#ffbb83") if warm else (Color("#6ef8f2") if style != 1 else Color("#f3a1fa"))
            colors.append(tint)
            colors.append(tint.darkened(0.16))
        row += 1
        y += 2.0
    var windows := _batch(pane, transforms, colors, "Instanced luminous windows", tower, material)
    window_batches.append(windows)

func _build_vertical_ribs(tower: Node3D, height: float, style: int, material: StandardMaterial3D) -> void:
    var rib := BoxMesh.new()
    rib.size = Vector3(0.13, 1.0, 0.13)
    var transforms: Array[Transform3D] = []
    var colors: Array[Color] = []
    for corner in range(4):
        var radius := _profile(0.45, style)
        var x := -radius if corner == 0 or corner == 3 else radius
        var z := -radius if corner < 2 else radius
        transforms.append(Transform3D(Basis().scaled(Vector3(1.0, height * 0.88, 1.0)), Vector3(x, height * 0.51, z)))
        colors.append(Color("#6bffed") if style != 1 else Color("#ff7dcb"))
    _batch(rib, transforms, colors, "Four instanced vertical neon ribs", tower, material)

func _build_roof(tower: Node3D, height: float, style: int, material: StandardMaterial3D) -> void:
    var crown := MeshInstance3D.new()
    crown.name = "Luminous roof observation crown"
    var torus := TorusMesh.new()
    torus.inner_radius = _profile(1.0, style) * 0.77
    torus.outer_radius = _profile(1.0, style) * 0.89
    torus.rings = 24
    torus.ring_segments = 6
    crown.mesh = torus
    crown.material_override = material
    crown.position.y = height + 0.20
    tower.add_child(crown)
    roof_crowns.append(crown)
    var spire := MeshInstance3D.new()
    spire.name = "Tapered rooftop beacon"
    var cone := CylinderMesh.new()
    cone.top_radius = 0.12
    cone.bottom_radius = 0.64
    cone.height = 2.1 + float(style) * 0.4
    cone.radial_segments = 10
    spire.mesh = cone
    spire.material_override = _facade_material()
    spire.position.y = height + 1.15
    tower.add_child(spire)


# V141: two continuous, volumetric cantilevered terraces on every building.
# A single vertex-colored mesh per tower makes their stepped silhouettes
# legible in the landscape chase view without extra textures or collision.
func _terrace_quad(tool: SurfaceTool, a: Vector3, b: Vector3,
        c: Vector3, d: Vector3, tint: Color) -> void:
    for point in [a, b, c, a, c, d]:
        _emit(tool, point, tint)

func _sky_terrace_mesh(height: float, style: int) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    var edge_tints: Array[Color] = [
        Color("#60dce7"), Color("#ec89cb"), Color("#a2ebcf")
    ]
    var rim_tint: Color = edge_tints[style]
    for level in range(2):
        var y := height * (0.42 if level == 0 else 0.70)
        var outer_radius := 4.70 if level == 0 else 4.00
        var inner_radius := _profile(y / height, style) - 0.10
        var underside := y - (0.48 if level == 0 else 0.32)
        for segment in range(32):
            var a0 := TAU * float(segment) / 32.0
            var a1 := TAU * float(segment + 1) / 32.0
            var i0 := Vector3(cos(a0) * inner_radius, y, sin(a0) * inner_radius)
            var i1 := Vector3(cos(a1) * inner_radius, y, sin(a1) * inner_radius)
            var o0 := Vector3(cos(a0) * outer_radius, y, sin(a0) * outer_radius)
            var o1 := Vector3(cos(a1) * outer_radius, y, sin(a1) * outer_radius)
            var ib0 := Vector3(i0.x, underside, i0.z)
            var ib1 := Vector3(i1.x, underside, i1.z)
            var ob0 := Vector3(o0.x, underside, o0.z)
            var ob1 := Vector3(o1.x, underside, o1.z)
            _terrace_quad(tool, i0, o0, o1, i1, rim_tint.darkened(0.48))
            _terrace_quad(tool, ib1, ob1, ob0, ib0, rim_tint.darkened(0.73))
            _terrace_quad(tool, o0, ob0, ob1, o1, rim_tint)
            _terrace_quad(tool, ib1, ib0, i0, i1, rim_tint.darkened(0.62))
    tool.generate_normals()
    return tool.commit()

func _build_sky_terraces(tower: Node3D, height: float, style: int,
        facade: StandardMaterial3D, glow: StandardMaterial3D) -> void:
    var deck := MeshInstance3D.new()
    deck.name = "Twin sculpted cantilevered sky terraces"
    deck.mesh = _sky_terrace_mesh(height, style)
    deck.material_override = facade
    tower.add_child(deck)
    sky_terraces.append(deck)
    # Eight repeated illuminated supports, batched into ONE multimesh.
    # The supports sit outside the facade, never inside a racing lane.
    var fin := BoxMesh.new()
    fin.size = Vector3(0.18, 1.0, 0.50)
    var transforms: Array[Transform3D] = []
    var colors: Array[Color] = []
    for index in range(8):
        var angle := TAU * float(index) / 8.0
        var radius := 2.85
        var y := height * 0.56
        var basis := Basis(Vector3.UP, angle).scaled(
            Vector3(1.0, height * 0.24, 1.0))
        transforms.append(Transform3D(basis,
            Vector3(cos(angle) * radius, y, sin(angle) * radius)))
        colors.append(Color("#6ef8f2") if style != 1 else Color("#ff96d4"))
    terrace_supports.append(_batch(fin, transforms, colors,
        "Eight instanced sky terrace supports", tower, glow))

func _ready() -> void:
    var facade := _facade_material()
    var glow := _glow_material()
    # Pull the moving foreground facades into the phone chase composition;
    # even the wider lower terrace remains outside the playable road.
    for index in range(BUILDING_COUNT):
        var side := -1.0 if index % 2 == 0 else 1.0
        var style := index % 3
        var height := 15.0 + float((index * 5) % 14)
        var tower := Node3D.new()
        tower.name = "Architectural district tower %02d" % index
        tower.position = Vector3(side * (12.2 + float(index % 3) * 1.4), 0.0, -8.0 - float(index) * SPACING)
        add_child(tower)
        towers.append(tower)
        district_styles.append(style)
        var shell := MeshInstance3D.new()
        shell.name = "Sculpted facade shell"
        shell.mesh = _shell_mesh(height, style)
        shell.material_override = facade
        tower.add_child(shell)
        _build_facade_windows(tower, height, style, side, glow)
        _build_vertical_ribs(tower, height, style, glow)
        _build_roof(tower, height, style, glow)
        _build_sky_terraces(tower, height, style, facade, glow)

func _process(delta: float) -> void:
    if not running:
        return
    elapsed += delta
    for tower in towers:
        tower.position.z += travel_speed * delta
        if tower.position.z > 20.0:
            tower.position.z -= LOOP_LENGTH
