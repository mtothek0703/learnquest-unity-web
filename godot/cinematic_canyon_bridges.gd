extends Node3D
## Original collision-free Crystal Canyon sky bridges for smartphone landscape.
## Four continuous sculpted arches and instanced crystal pendants; one shared
## rock mesh and one MultiMesh per bridge. No external assets or runtime fetch.

const BRIDGE_COUNT := 4
const SPACING := 39.0
const LOOP_LENGTH := BRIDGE_COUNT * SPACING
const HALF_SPAN := 11.0

var running := false
var travel_speed := 14.0
var bridges: Array[Node3D] = []
var rock_spans: Array[MeshInstance3D] = []
var pendant_batches: Array[MultiMeshInstance3D] = []

func _height_at(x: float) -> float:
    var u := clampf(absf(x) / HALF_SPAN, 0.0, 1.0)
    return 7.4 + 4.7 * (1.0 - pow(u, 1.7))

func _quad(tool: SurfaceTool, a: Vector3, b: Vector3,
        c: Vector3, d: Vector3, tint: Color) -> void:
    tool.set_color(tint)
    for point in [a, b, c, a, c, d]:
        tool.add_vertex(point)

func _rock_mesh() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for index in range(32):
        var x0 := lerpf(-HALF_SPAN, HALF_SPAN, float(index) / 32.0)
        var x1 := lerpf(-HALF_SPAN, HALF_SPAN, float(index + 1) / 32.0)
        var h0 := _height_at(x0)
        var h1 := _height_at(x1)
        # The full front, back, underside and upper deck are genuinely 3D.
        # Faceted strata remain legible against the luminous geode reefs.
        var shade := Color("#744d79").lerp(Color("#c98c9d"), 0.35 + 0.35 * sin(float(index) * 1.7))
        var front := shade.lightened(0.10)
        var back := shade.darkened(0.18)
        var a := Vector3(x0, h0, -1.45)
        var b := Vector3(x1, h1, -1.45)
        var c := Vector3(x0, h0 + 1.45, -1.45)
        var d := Vector3(x1, h1 + 1.45, -1.45)
        var e := Vector3(x0, h0, 1.45)
        var f := Vector3(x1, h1, 1.45)
        var g := Vector3(x0, h0 + 1.45, 1.45)
        var h := Vector3(x1, h1 + 1.45, 1.45)
        _quad(tool, a, b, d, c, front)
        _quad(tool, f, e, g, h, back)
        _quad(tool, c, d, h, g, shade.lightened(0.23))
        _quad(tool, e, f, b, a, shade.darkened(0.25))
    tool.generate_normals()
    return tool.commit()

func _ready() -> void:
    var stone := StandardMaterial3D.new()
    stone.vertex_color_use_as_albedo = true
    stone.roughness = 0.77
    stone.metallic = 0.04
    stone.cull_mode = BaseMaterial3D.CULL_DISABLED
    var shared_span := _rock_mesh()
    var pendant := CylinderMesh.new()
    pendant.top_radius = 0.38
    pendant.bottom_radius = 0.0
    pendant.height = 1.55
    pendant.radial_segments = 7
    for index in range(BRIDGE_COUNT):
        var root_bridge := Node3D.new()
        root_bridge.name = "Sculpted canyon sky bridge %d" % index
        root_bridge.position.z = -17.0 - float(index) * SPACING
        add_child(root_bridge)
        bridges.append(root_bridge)
        var rock := MeshInstance3D.new()
        rock.name = "Continuous faceted suspended arch"
        rock.mesh = shared_span
        rock.material_override = stone
        root_bridge.add_child(rock)
        rock_spans.append(rock)
        var crystal_material := StandardMaterial3D.new()
        crystal_material.albedo_color = Color("#70fff0") if index % 2 == 0 else Color("#ff9bdc")
        crystal_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
        crystal_material.emission_enabled = true
        crystal_material.emission = crystal_material.albedo_color
        crystal_material.emission_energy_multiplier = 1.8
        var batch := MultiMesh.new()
        batch.transform_format = MultiMesh.TRANSFORM_3D
        batch.mesh = pendant
        batch.instance_count = 7
        for shard in range(7):
            var x := float(shard - 3) * 2.45
            # Every tip stays well above the rider and even the mega-jump.
            var y := _height_at(x) - 0.77
            var size := 0.68 + 0.13 * float((shard + index) % 3)
            batch.set_instance_transform(shard, Transform3D(
                Basis().scaled(Vector3(size, size, size)),
                Vector3(x, y, 0.0)))
        var glints := MultiMeshInstance3D.new()
        glints.name = "Seven instanced hanging crystal keystones"
        glints.multimesh = batch
        glints.material_override = crystal_material
        root_bridge.add_child(glints)
        pendant_batches.append(glints)

func _process(delta: float) -> void:
    if not running:
        return
    for bridge in bridges:
        bridge.position.z += travel_speed * delta
        if bridge.position.z > 20.0:
            bridge.position.z -= LOOP_LENGTH
