extends Node3D
## V143 candidate: six original, shaded volumetric glacier icefalls.
## No external assets, collision bodies, lights or additional touch controls.
## A shared sculpted ice mesh plus six instanced icicle batches keeps WebGL light.
const ICEFALL_COUNT := 6
const SPACING := 27.0
const LOOP_LENGTH := ICEFALL_COUNT * SPACING

var running := false
var travel_speed := 14.0
var icefalls: Array[Node3D] = []
var ice_walls: Array[MeshInstance3D] = []
var icicle_batches: Array[MultiMeshInstance3D] = []

func _point(row: int, column: int, rear: bool) -> Vector3:
    var t := float(row) / 18.0
    var u := float(column) / 12.0
    # Irregular fluted ice crown and tapered feet avoid a rectangular wall.
    var taper := 0.82 + 0.18 * sin(PI * t) + 0.05 * sin(u * 14.0 + t * 6.0)
    var x := (u - 0.5) * 5.0 * taper + 0.26 * sin(t * 6.0 + u * 11.0)
    var crown := 12.4 + 0.88 * sin(u * 8.0) + 0.34 * cos(u * 19.0)
    var y := lerpf(0.45 + 0.18 * sin(u * 14.0), crown, t)
    # A deeply folded surface with actual front/back volume, not a billboard.
    var z := 0.45 * sin(u * 9.0 + t * 4.0) + 0.24 * sin(u * 23.0 - t * 7.0)
    if rear:
        z += 0.95
    return Vector3(x, y, z)

func _quad(tool: SurfaceTool, a: Vector3, b: Vector3,
        c: Vector3, d: Vector3, tint: Color) -> void:
    tool.set_color(tint)
    for vertex in [a, b, c, a, c, d]:
        tool.add_vertex(vertex)

func _ice_mesh() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for row in range(18):
        var t := float(row) / 18.0
        var tint := Color("#2463a8").lerp(Color("#d8faff"), t * 0.85)
        for column in range(12):
            var variation := 0.11 * sin(float(column) * 1.7 + t * 13.0)
            var face_tint := tint.lightened(maxf(0.0, variation))
            _quad(tool, _point(row, column, false),
                _point(row, column + 1, false),
                _point(row + 1, column + 1, false),
                _point(row + 1, column, false), face_tint)
            _quad(tool, _point(row, column + 1, true),
                _point(row, column, true),
                _point(row + 1, column, true),
                _point(row + 1, column + 1, true), tint.darkened(0.32))
        for edge in [0, 12]:
            _quad(tool, _point(row, edge, true),
                _point(row, edge, false),
                _point(row + 1, edge, false),
                _point(row + 1, edge, true), tint.darkened(0.15))
    for column in range(12):
        _quad(tool, _point(0, column, true), _point(0, column + 1, true),
            _point(0, column + 1, false), _point(0, column, false),
            Color("#285c94"))
        _quad(tool, _point(18, column, false), _point(18, column + 1, false),
            _point(18, column + 1, true), _point(18, column, true),
            Color("#d8faff"))
    tool.generate_normals()
    return tool.commit()

func _ready() -> void:
    var shared_ice := _ice_mesh()
    var ice_material := StandardMaterial3D.new()
    ice_material.vertex_color_use_as_albedo = true
    ice_material.roughness = 0.42
    ice_material.metallic = 0.12
    ice_material.cull_mode = BaseMaterial3D.CULL_DISABLED

    var icicle_mesh := CylinderMesh.new()
    icicle_mesh.top_radius = 0.30
    icicle_mesh.bottom_radius = 0.0
    icicle_mesh.height = 2.25
    icicle_mesh.radial_segments = 7
    var glow := StandardMaterial3D.new()
    glow.albedo_color = Color("#a5faff")
    glow.emission_enabled = true
    glow.emission = Color("#52dfff")
    glow.emission_energy_multiplier = 1.15
    glow.roughness = 0.32

    for index in range(ICEFALL_COUNT):
        var side := -1.0 if index % 2 == 0 else 1.0
        var fall := Node3D.new()
        fall.name = "Volumetric icefall %d" % index
        fall.position = Vector3(side * (10.4 + float(index % 3) * 0.65),
            0.0, -14.0 - float(index) * SPACING)
        add_child(fall)
        icefalls.append(fall)

        var wall := MeshInstance3D.new()
        wall.name = "Continuous folded ice cascade"
        wall.mesh = shared_ice
        wall.material_override = ice_material
        wall.rotation.y = side * 0.14
        fall.add_child(wall)
        ice_walls.append(wall)

        var batch := MultiMesh.new()
        batch.transform_format = MultiMesh.TRANSFORM_3D
        batch.mesh = icicle_mesh
        batch.instance_count = 12
        for shard in range(12):
            var x := float(shard % 4 - 2) * 1.13 + 0.5
            var y := 3.0 + float(shard / 4) * 3.4
            var size := 0.62 + 0.13 * float((index + shard) % 4)
            batch.set_instance_transform(shard, Transform3D(
                Basis().scaled(Vector3(size, size, size)),
                Vector3(x, y, 1.05)))
        var icicles := MultiMeshInstance3D.new()
        icicles.name = "Twelve batched luminous icicles"
        icicles.multimesh = batch
        icicles.material_override = glow
        fall.add_child(icicles)
        icicle_batches.append(icicles)

func _process(delta: float) -> void:
    if not running:
        return
    for fall in icefalls:
        fall.position.z += travel_speed * delta
        if fall.position.z > 23.0:
            fall.position.z -= LOOP_LENGTH
