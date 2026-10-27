extends Node3D
## V119: mobile-conscious, shadow-free colored lightfields for Neon City.
## Four original procedural light wells with volumetric-looking gradient shafts,
## soft ground pools and short-range real OmniLight3D illumination.
## No imported assets, particles, collisions or changes to gameplay/input.

const WELL_COUNT := 4
const WELL_SPACING := 26.0
const LOOP_LENGTH := WELL_COUNT * WELL_SPACING

var running := false
var travel_speed := 14.0
var elapsed := 0.0
var wells: Array[Node3D] = []
var shafts: Array[MeshInstance3D] = []
var pools: Array[MeshInstance3D] = []
var lamps: Array[OmniLight3D] = []

func _glow_material(tint: Color) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = Color.WHITE
    material.vertex_color_use_as_albedo = true
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    material.emission_enabled = true
    material.emission = tint
    material.emission_energy_multiplier = 1.45
    return material

func _vertex(tool: SurfaceTool, point: Vector3, tint: Color) -> void:
    tool.set_color(tint)
    tool.add_vertex(point)

func _shaft_mesh(tint: Color) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for ring in range(12):
        var t0 := float(ring) / 12.0
        var t1 := float(ring + 1) / 12.0
        for side in range(16):
            var a0 := TAU * float(side) / 16.0
            var a1 := TAU * float(side + 1) / 16.0
            var r0 := lerpf(3.35, 0.48, t0)
            var r1 := lerpf(3.35, 0.48, t1)
            var p00 := Vector3(cos(a0) * r0, 0.35 + t0 * 15.0, sin(a0) * r0)
            var p01 := Vector3(cos(a1) * r0, 0.35 + t0 * 15.0, sin(a1) * r0)
            var p10 := Vector3(cos(a0) * r1, 0.35 + t1 * 15.0, sin(a0) * r1)
            var p11 := Vector3(cos(a1) * r1, 0.35 + t1 * 15.0, sin(a1) * r1)
            var low := Color(tint.r, tint.g, tint.b, 0.72 * pow(sin(PI * t0), 1.3))
            var high := Color(tint.r, tint.g, tint.b, 0.72 * pow(sin(PI * t1), 1.3))
            _vertex(tool, p00, low)
            _vertex(tool, p10, high)
            _vertex(tool, p01, low)
            _vertex(tool, p01, low)
            _vertex(tool, p10, high)
            _vertex(tool, p11, high)
    tool.generate_normals()
    return tool.commit()

func _pool_mesh(tint: Color) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for ring in range(7):
        var t0 := float(ring) / 7.0
        var t1 := float(ring + 1) / 7.0
        for side in range(24):
            var a0 := TAU * float(side) / 24.0
            var a1 := TAU * float(side + 1) / 24.0
            var r0 := 3.75 * t0
            var r1 := 3.75 * t1
            var p00 := Vector3(cos(a0) * r0, 0.06, sin(a0) * r0)
            var p01 := Vector3(cos(a1) * r0, 0.06, sin(a1) * r0)
            var p10 := Vector3(cos(a0) * r1, 0.06, sin(a0) * r1)
            var p11 := Vector3(cos(a1) * r1, 0.06, sin(a1) * r1)
            var low := Color(tint.r, tint.g, tint.b, 0.76 * pow(1.0 - t0, 1.8))
            var high := Color(tint.r, tint.g, tint.b, 0.76 * pow(1.0 - t1, 1.8))
            _vertex(tool, p00, low)
            _vertex(tool, p01, low)
            _vertex(tool, p10, high)
            _vertex(tool, p01, low)
            _vertex(tool, p11, high)
            _vertex(tool, p10, high)
    tool.generate_normals()
    return tool.commit()

func _ready() -> void:
    for index in range(WELL_COUNT):
        var side := -1.0 if index % 2 == 0 else 1.0
        var tint := Color("#5ff4ef") if index % 2 == 0 else Color("#ff85d3")
        var glow := _glow_material(tint)
        var well := Node3D.new()
        well.name = "Atmospheric light well %d" % index
        well.position = Vector3(side * 9.9, 0.0, -14.0 - float(index) * WELL_SPACING)
        add_child(well)
        wells.append(well)
        var shaft := MeshInstance3D.new()
        shaft.name = "Soft tapered light shaft"
        shaft.mesh = _shaft_mesh(tint)
        shaft.material_override = glow
        well.add_child(shaft)
        shafts.append(shaft)
        var pool := MeshInstance3D.new()
        pool.name = "Radial ground light pool"
        pool.mesh = _pool_mesh(tint)
        pool.material_override = glow
        well.add_child(pool)
        pools.append(pool)
        # A visible suspended emitter makes the new shaft readable in chase view.
        var lens := MeshInstance3D.new()
        lens.name = "Suspended luminous lens"
        var orb := SphereMesh.new()
        orb.radius = 0.56
        orb.height = 1.12
        orb.radial_segments = 16
        orb.rings = 8
        lens.mesh = orb
        var lens_material := StandardMaterial3D.new()
        lens_material.albedo_color = tint
        lens_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
        lens_material.emission_enabled = true
        lens_material.emission = tint
        lens_material.emission_energy_multiplier = 1.65
        lens.material_override = lens_material
        lens.position.y = 15.3
        well.add_child(lens)
        var lamp := OmniLight3D.new()
        lamp.name = "Shadow-free district accent lamp"
        lamp.position.y = 3.7
        lamp.light_color = tint
        lamp.light_energy = 1.25
        lamp.omni_range = 9.0
        lamp.shadow_enabled = false
        well.add_child(lamp)
        lamps.append(lamp)

func _process(delta: float) -> void:
    if not running:
        return
    elapsed += delta
    for index in range(wells.size()):
        var well := wells[index]
        well.position.z += travel_speed * delta
        if well.position.z > 19.0:
            well.position.z -= LOOP_LENGTH
        lamps[index].light_energy = 1.25 + 0.13 * sin(elapsed * 1.2 + float(index))
