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
# Three raised, sculpted streaming channels per icefall. Shared meshes/shader;
# purely scenic, no touch input, collisions, lights or gameplay state changes.
var flow_channels: Array[MeshInstance3D] = []

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


# Sculpt a narrow three-dimensional meltwater ridge along the existing
# fluted ice surface. The central crest projects forward from the ice wall;
# the two edges blend back into it. No flat billboard or physics geometry.
func _flow_point(t: float, lane: int, across: float) -> Vector3:
    var u := 0.24 + float(lane) * 0.26
    var taper := 0.82 + 0.18 * sin(PI * t) + 0.05 * sin(u * 14.0 + t * 6.0)
    var x := (u - 0.5) * 5.0 * taper + 0.26 * sin(t * 6.0 + u * 11.0)
    x += across * (0.18 + 0.045 * sin(t * 12.0 + float(lane)))
    var crown := 12.4 + 0.88 * sin(u * 8.0) + 0.34 * cos(u * 19.0)
    var y := lerpf(0.45 + 0.18 * sin(u * 14.0), crown, t)
    var ice_z := 0.45 * sin(u * 9.0 + t * 4.0) + 0.24 * sin(u * 23.0 - t * 7.0)
    var crest := 0.14 * (1.0 - absf(across))
    return Vector3(x, y, ice_z + 0.10 + crest)

func _flow_mesh(lane: int) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for row in range(32):
        var t0 := float(row) / 32.0
        var t1 := float(row + 1) / 32.0
        for half in range(2):
            var a := -1.0 + float(half)
            var b := a + 1.0
            var points := [
                Vector2(a, t0), Vector2(b, t0), Vector2(b, t1),
                Vector2(a, t0), Vector2(b, t1), Vector2(a, t1)]
            for uv in points:
                tool.set_uv(Vector2((uv.x + 1.0) * 0.5, uv.y))
                tool.add_vertex(_flow_point(uv.y, lane, uv.x))
    tool.generate_normals()
    return tool.commit()

func _flow_material() -> ShaderMaterial:
    # Animated emission moves through actual raised 3D channels. The shader
    # is unshaded/opaque to avoid costly mobile transparency and extra lights.
    var shader := Shader.new()
    shader.code = """
shader_type spatial;
render_mode unshaded, cull_disabled;
void fragment() {
    float streak = pow(max(0.0, sin(UV.y * 38.0 - TIME * 4.5)), 3.0);
    float edge = 1.0 - abs(UV.x * 2.0 - 1.0);
    float intensity = 0.28 + 0.50 * streak + 0.22 * edge;
    ALBEDO = vec3(0.10, 0.42, 0.65) * intensity;
    EMISSION = vec3(0.20, 0.86, 1.0) * intensity * 1.7;
}
"""
    var material := ShaderMaterial.new()
    material.shader = shader
    return material

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

    var flow_material := _flow_material()
    var flow_meshes := [_flow_mesh(0), _flow_mesh(1), _flow_mesh(2)]
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
        for lane in range(3):
            var channel := MeshInstance3D.new()
            channel.name = "Raised animated glacial flow %d" % lane
            channel.mesh = flow_meshes[lane]
            channel.material_override = flow_material
            fall.add_child(channel)
            flow_channels.append(channel)

func _process(delta: float) -> void:
    if not running:
        return
    for fall in icefalls:
        fall.position.z += travel_speed * delta
        if fall.position.z > 23.0:
            fall.position.z -= LOOP_LENGTH
