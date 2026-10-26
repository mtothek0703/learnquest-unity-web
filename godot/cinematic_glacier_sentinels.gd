extends Node3D
## Skyway V86: four monumental, animated crystal sentinels for Aurora Glacier.
## Original faceted meshes, shaded orbiting halos and soft lights; no assets.
## The ornaments never enter playable lanes and contain no collision bodies.

var running := false
var travel_speed := 14.0
var clock := 0.0
var monuments: Array[Node3D] = []
var cores: Array[Node3D] = []
var halo_pivots: Array[Node3D] = []
var shard_pivots: Array[Node3D] = []
var glow_lights: Array[OmniLight3D] = []

func _surface_material(transparent: bool = false) -> StandardMaterial3D:
    var result := StandardMaterial3D.new()
    result.albedo_color = Color.WHITE
    result.vertex_color_use_as_albedo = true
    result.metallic = 0.25
    result.roughness = 0.24
    result.cull_mode = BaseMaterial3D.CULL_DISABLED
    if transparent:
        result.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
        result.emission_enabled = true
        result.emission = Color("#51eaff")
        result.emission_energy_multiplier = 0.75
    return result

func _crystal_point(level: int, segment: int) -> Vector3:
    var heights := [-2.3, -1.45, -0.15, 1.65, 3.6]
    var widths := [0.18, 0.75, 1.13, 0.79, 0.055]
    var angle := TAU * float(segment) / 10.0 + float(level) * 0.13
    var radius: float = widths[level] * (1.0 + 0.08 * sin(angle * 3.0 + float(level)))
    return Vector3(cos(angle) * radius, heights[level], sin(angle) * radius)

func _crystal_mesh() -> ArrayMesh:
    var surface := SurfaceTool.new()
    surface.begin(Mesh.PRIMITIVE_TRIANGLES)
    for level in range(4):
        for segment in range(10):
            var a := _crystal_point(level, segment)
            var b := _crystal_point(level, segment + 1)
            var c := _crystal_point(level + 1, segment + 1)
            var d := _crystal_point(level + 1, segment)
            var tint := Color("#235aa8").lerp(Color("#a4faff"), float(level) / 4.0)
            tint = tint.lerp(Color("#ec86ff"), float(segment % 4) * 0.11)
            for vertex in [a, b, c, a, c, d]:
                surface.set_color(tint)
                surface.add_vertex(vertex)
    surface.generate_normals()
    return surface.commit()

func _halo_point(step: int, radial: int, radius: float, phase: float) -> Vector3:
    var angle := TAU * float(step) / 48.0
    var cross := TAU * float(radial) / 8.0
    var r := radius + cos(cross) * 0.14
    return Vector3(
        cos(angle) * r,
        sin(angle) * r + sin(angle * 3.0 + phase) * 0.31,
        sin(cross) * 0.14 + cos(angle * 2.0 + phase) * 0.23
    )

func _halo_mesh(radius: float, phase: float) -> ArrayMesh:
    var surface := SurfaceTool.new()
    surface.begin(Mesh.PRIMITIVE_TRIANGLES)
    for step in range(48):
        var tint := Color(0.25, 0.97, 1.0, 0.87).lerp(Color(0.98, 0.48, 0.96, 0.75), (sin(float(step) * 0.17 + phase) + 1.0) * 0.5)
        for radial in range(8):
            var a := _halo_point(step, radial, radius, phase)
            var b := _halo_point(step + 1, radial, radius, phase)
            var c := _halo_point(step + 1, radial + 1, radius, phase)
            var d := _halo_point(step, radial + 1, radius, phase)
            for vertex in [a, b, c, a, c, d]:
                surface.set_color(tint)
                surface.add_vertex(vertex)
    surface.generate_normals()
    return surface.commit()

func _part(parent: Node3D, title: String, mesh: Mesh, material: Material) -> MeshInstance3D:
    var result := MeshInstance3D.new()
    result.name = title
    result.mesh = mesh
    result.material_override = material
    parent.add_child(result)
    return result

func _ready() -> void:
    var crystal_mesh := _crystal_mesh()
    var outer_mesh := _halo_mesh(3.25, 0.0)
    var inner_mesh := _halo_mesh(2.45, 1.4)
    var ice := _surface_material()
    var aurora := _surface_material(true)
    for index in range(4):
        var side := -1.0 if index % 2 == 0 else 1.0
        var monument := Node3D.new()
        monument.name = "Crystal sentinel %d" % index
        monument.position = Vector3(side * 11.8, 0.0, -31.0 - float(index) * 38.0)
        add_child(monument)
        monuments.append(monument)

        var pedestal := _part(monument, "Faceted glacier pedestal", crystal_mesh, ice)
        pedestal.position = Vector3(0.0, 2.5, 0.0)
        pedestal.scale = Vector3(1.25, 1.45, 1.25)

        var core := Node3D.new()
        core.name = "Floating crystal core"
        core.position = Vector3(0.0, 7.1, 0.0)
        monument.add_child(core)
        cores.append(core)
        var gem := _part(core, "Shaded faceted aurora gem", crystal_mesh, ice)
        gem.scale = Vector3(0.88, 0.92, 0.88)

        for halo_index in range(2):
            var pivot := Node3D.new()
            pivot.name = "Outer rotating aurora halo" if halo_index == 0 else "Inner rotating aurora halo"
            pivot.position = Vector3(0.0, 7.0, 0.0)
            pivot.rotation.y = 0.14 if halo_index == 0 else -0.23
            monument.add_child(pivot)
            halo_pivots.append(pivot)
            _part(pivot, "Curved translucent energy ring", outer_mesh if halo_index == 0 else inner_mesh, aurora)

        var orbit := Node3D.new()
        orbit.name = "Orbiting crystal shards"
        orbit.position = Vector3(0.0, 7.0, 0.0)
        monument.add_child(orbit)
        shard_pivots.append(orbit)
        for shard_index in range(5):
            var shard := _part(orbit, "Satellite shard %d" % shard_index, crystal_mesh, ice)
            var angle := TAU * float(shard_index) / 5.0
            shard.position = Vector3(cos(angle) * 3.8, sin(angle) * 3.6, 0.2)
            shard.scale = Vector3(0.19, 0.23, 0.19)
            shard.rotation.z = angle

        if index < 2:
            var glow := OmniLight3D.new()
            glow.name = "Soft aurora sentinel light"
            glow.light_color = Color("#73eaff") if index == 0 else Color("#ff8ded")
            glow.light_energy = 0.75
            glow.omni_range = 9.0
            glow.shadow_enabled = false
            glow.position = Vector3(0.0, 7.0, 0.0)
            monument.add_child(glow)
            glow_lights.append(glow)

func _process(delta: float) -> void:
    clock += delta
    for index in range(monuments.size()):
        var monument := monuments[index]
        if running:
            monument.position.z += travel_speed * delta
            if monument.position.z > 22.0:
                monument.position.z -= 190.0
        var core := cores[index]
        core.position.y = 7.1 + sin(clock * 1.25 + float(index)) * 0.42
        core.rotation.y += delta * (0.38 if index % 2 == 0 else -0.38)
        for halo_index in range(2):
            var pivot := halo_pivots[index * 2 + halo_index]
            pivot.rotation.z += delta * (0.29 if halo_index == 0 else -0.39)
            pivot.rotation.y = sin(clock * 0.52 + float(index) + float(halo_index)) * 0.23
        shard_pivots[index].rotation.z += delta * 0.32
    for index in range(glow_lights.size()):
        glow_lights[index].light_energy = 0.72 + 0.21 * sin(clock * 2.2 + float(index))
