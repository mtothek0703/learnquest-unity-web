extends Node3D
## V120: original, collision-free floating geode reefs for Crystal Canyon.
## Faceted 360-degree rock islands, luminous crystal spires and drifting shards.
## Reused meshes and materials, no external assets or gameplay/input changes.

const REEF_COUNT := 10
const REEF_SPACING := 15.0
const LOOP_LENGTH := REEF_COUNT * REEF_SPACING

var running := false
var travel_speed := 14.0
var elapsed := 0.0
var reefs: Array[Node3D] = []
var floating_shards: Array[Node3D] = []
var rock_islands: Array[MeshInstance3D] = []
var crystal_spires: Array[MeshInstance3D] = []
var halos: Array[MeshInstance3D] = []

func _material(color: Color, glowing: bool = false) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.vertex_color_use_as_albedo = not glowing
    mat.roughness = 0.52
    mat.metallic = 0.15
    mat.cull_mode = BaseMaterial3D.CULL_DISABLED
    if glowing:
        mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
        mat.emission_enabled = true
        mat.emission = color
        mat.emission_energy_multiplier = 1.8
    return mat

func _tri(tool: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, tint: Color) -> void:
    tool.set_color(tint)
    tool.add_vertex(a)
    tool.add_vertex(b)
    tool.add_vertex(c)

func _island_mesh() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for side in range(18):
        var a0 := TAU * float(side) / 18.0
        var a1 := TAU * float(side + 1) / 18.0
        var r0 := 3.4 + 0.32 * sin(float(side) * 2.7)
        var r1 := 3.4 + 0.32 * sin(float(side + 1) * 2.7)
        var p0 := Vector3(cos(a0) * r0, -0.15, sin(a0) * r0)
        var p1 := Vector3(cos(a1) * r1, -0.15, sin(a1) * r1)
        var center := Vector3(0, 0.48, 0)
        var tip := Vector3(0.22, -2.65, -0.14)
        _tri(tool, center, p1, p0, Color("#a178a9") if side % 3 == 0 else Color("#655b94"))
        _tri(tool, p0, p1, tip, Color("#3b3b73") if side % 2 == 0 else Color("#535181"))
    tool.generate_normals()
    return tool.commit()

func _crystal_point(t: float, angle: float, variant: int) -> Vector3:
    var taper := maxf(0.03, 1.0 - pow(t, 1.25))
    var facet := 1.0 + 0.16 * sin(angle * 5.0 + float(variant))
    var radius := (1.6 + float(variant) * 0.17) * taper * facet
    return Vector3(cos(angle) * radius + sin(t * 3.0 + float(variant)) * t * 0.45,
        t * (8.0 + float(variant) * 1.2), sin(angle) * radius)

func _crystal_mesh(variant: int) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for layer in range(10):
        var t0 := float(layer) / 10.0
        var t1 := float(layer + 1) / 10.0
        for side in range(9):
            var a0 := TAU * float(side) / 9.0
            var a1 := TAU * float(side + 1) / 9.0
            var p00 := _crystal_point(t0, a0, variant)
            var p01 := _crystal_point(t0, a1, variant)
            var p10 := _crystal_point(t1, a0, variant)
            var p11 := _crystal_point(t1, a1, variant)
            var tint := Color("#4e9db2").lerp(Color("#b4fff3"), t0) if variant % 2 == 0 else Color("#975aa9").lerp(Color("#ffd1f1"), t0)
            if side % 3 == 0:
                tint = tint.lightened(0.17)
            _tri(tool, p00, p10, p11, tint)
            _tri(tool, p00, p11, p01, tint)
    tool.generate_normals()
    return tool.commit()

func _mesh(parent: Node3D, title: String, shape: Mesh, pos: Vector3, mat: Material) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.name = title
    node.mesh = shape
    node.material_override = mat
    node.position = pos
    parent.add_child(node)
    return node

func _ready() -> void:
    var island := _island_mesh()
    var crystals := [_crystal_mesh(0), _crystal_mesh(1), _crystal_mesh(2)]
    var rock_mat := _material(Color.WHITE)
    var crystal_mat := _material(Color.WHITE)
    var cyan := _material(Color("#5cf8e9"), true)
    var magenta := _material(Color("#ff83e6"), true)
    var halo_mesh := TorusMesh.new()
    halo_mesh.inner_radius = 3.12
    halo_mesh.outer_radius = 3.22
    halo_mesh.rings = 36
    halo_mesh.ring_segments = 8
    for index in range(REEF_COUNT):
        var side := -1.0 if index % 2 == 0 else 1.0
        var reef := Node3D.new()
        reef.name = "Floating canyon geode reef %02d" % index
        reef.position = Vector3(side * (15.0 + float(index % 3) * 1.4), 5.7, -18.0 - float(index) * REEF_SPACING)
        add_child(reef)
        reefs.append(reef)
        var platform := _mesh(reef, "Faceted floating island", island, Vector3.ZERO, rock_mat)
        rock_islands.append(platform)
        var spire := _mesh(reef, "Sculpted luminous geode spire", crystals[index % 3], Vector3(0, 0.45, 0), crystal_mat)
        spire.rotation.y = float(index) * 0.53
        crystal_spires.append(spire)
        var halo := _mesh(reef, "Suspended neon geode halo", halo_mesh, Vector3(0, 0.32, 0), cyan if index % 2 == 0 else magenta)
        halos.append(halo)
        for shard_index in range(2):
            var pivot := Node3D.new()
            pivot.name = "Drifting faceted shard %d" % shard_index
            pivot.position = Vector3(float(shard_index * 2 - 1) * 2.25, 8.2 + float(shard_index) * 2.4, 0.8)
            reef.add_child(pivot)
            var shard := _mesh(pivot, "Original 3D shard", crystals[(index + shard_index + 1) % 3], Vector3.ZERO, crystal_mat)
            shard.scale = Vector3(0.28, 0.36, 0.28)
            shard.rotation.z = PI if shard_index == 0 else -0.28
            floating_shards.append(pivot)

func _process(delta: float) -> void:
    if not running:
        return
    elapsed += delta
    for index in range(reefs.size()):
        var reef := reefs[index]
        reef.position.z += travel_speed * delta
        if reef.position.z > 20.0:
            reef.position.z -= LOOP_LENGTH
        halos[index].rotation.y += delta * (0.12 + float(index % 3) * 0.04)
    for index in range(floating_shards.size()):
        var shard := floating_shards[index]
        shard.rotation.y += delta * (0.18 + float(index % 3) * 0.07)
        shard.position.y = 8.2 + float(index % 2) * 2.4 + sin(elapsed * 0.8 + float(index)) * 0.24
