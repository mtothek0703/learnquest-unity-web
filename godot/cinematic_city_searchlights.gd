extends Node3D
## V89: original, lightweight cinematic Neon City searchlight towers.
## Three moving roadside towers project animated translucent 3D light shafts
## high above the road. No collision, input hooks, external assets or textures.
## Wide 16:9 chase framing keeps the rider and driving lanes unobstructed.

const SHAFT_STEPS := 14
const SHAFT_SIDES := 18
const TOWER_COUNT := 3
const TOWER_SPACING := 46.0

var running := false
var travel_speed := 14.0
var clock := 0.0
var towers: Array[Node3D] = []
var search_pivots: Array[Node3D] = []
var tower_lights: Array[OmniLight3D] = []

func _ready() -> void:
    var metal := StandardMaterial3D.new()
    metal.albedo_color = Color("#202b51")
    metal.metallic = 0.64
    metal.roughness = 0.29

    var trim := StandardMaterial3D.new()
    trim.albedo_color = Color("#8ff7ff")
    trim.emission_enabled = true
    trim.emission = Color("#37b9fa")
    trim.emission_energy_multiplier = 1.6

    var shaft_material := StandardMaterial3D.new()
    shaft_material.albedo_color = Color.WHITE
    shaft_material.vertex_color_use_as_albedo = true
    shaft_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    shaft_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    shaft_material.cull_mode = BaseMaterial3D.CULL_DISABLED
    shaft_material.emission_enabled = true
    shaft_material.emission = Color("#399be0")
    shaft_material.emission_energy_multiplier = 0.65

    for index in range(TOWER_COUNT):
        var tower := Node3D.new()
        tower.name = "Neon searchlight tower %d" % index
        tower.position = Vector3(-11.5 if index % 2 == 0 else 11.5, 0.0, -27.0 - float(index) * TOWER_SPACING)
        add_child(tower)
        towers.append(tower)

        var shaft := MeshInstance3D.new()
        shaft.name = "Faceted metallic tower"
        var column := CylinderMesh.new()
        column.top_radius = 0.42
        column.bottom_radius = 1.0
        column.height = 7.4
        column.radial_segments = 12
        shaft.mesh = column
        shaft.material_override = metal
        shaft.position.y = 3.7
        tower.add_child(shaft)

        for band in range(3):
            var ring := MeshInstance3D.new()
            ring.name = "Glowing structural collar %d" % band
            var torus := TorusMesh.new()
            torus.inner_radius = 0.54 - float(band) * 0.045
            torus.outer_radius = 0.64 - float(band) * 0.045
            torus.rings = 20
            torus.ring_segments = 6
            ring.mesh = torus
            ring.material_override = trim
            ring.position.y = 2.0 + float(band) * 2.5
            tower.add_child(ring)

        var pivot := Node3D.new()
        pivot.name = "Sweeping twin holographic spotlights"
        pivot.position.y = 7.65
        tower.add_child(pivot)
        search_pivots.append(pivot)

        var lamp := MeshInstance3D.new()
        lamp.name = "Sculpted rotating beacon"
        var beacon := SphereMesh.new()
        beacon.radius = 0.66
        beacon.height = 1.02
        beacon.radial_segments = 16
        beacon.rings = 8
        lamp.mesh = beacon
        lamp.material_override = trim
        pivot.add_child(lamp)

        for side in [-1.0, 1.0]:
            var cone := MeshInstance3D.new()
            cone.name = "Left volumetric light shaft" if side < 0.0 else "Right volumetric light shaft"
            cone.mesh = _build_shaft(side)
            cone.material_override = shaft_material
            pivot.add_child(cone)

            var emitter := MeshInstance3D.new()
            emitter.name = "Left spotlight emitter" if side < 0.0 else "Right spotlight emitter"
            var lens := SphereMesh.new()
            lens.radius = 0.26
            lens.height = 0.4
            lens.radial_segments = 12
            lens.rings = 6
            emitter.mesh = lens
            emitter.material_override = trim
            emitter.position = Vector3(side * 0.48, 0.08, -0.28)
            pivot.add_child(emitter)

        var light := OmniLight3D.new()
        light.name = "Animated cinematic beacon light"
        light.light_color = Color("#79ecff") if index % 2 == 0 else Color("#ff89db")
        light.light_energy = 1.05
        light.omni_range = 5.5
        light.shadow_enabled = false
        pivot.add_child(light)
        tower_lights.append(light)

func _shaft_point(t: float, angle: float, side: float) -> Vector3:
    var radius := 0.16 + 1.55 * t
    var bend := 1.3 * t + 1.7 * t * t
    return Vector3(
        side * bend + cos(angle) * radius,
        0.08 + 9.2 * t,
        -0.35 - 2.8 * t + sin(angle) * radius
    )

func _shaft_vertex(tool: SurfaceTool, t: float, angle: float, side: float) -> void:
    var opacity := 0.06 + 0.30 * sin(PI * t) * (1.0 - 0.35 * t)
    var color := Color("#69e9ff").lerp(Color("#ff80dc"), t * 0.62)
    tool.set_color(Color(color.r, color.g, color.b, opacity))
    tool.add_vertex(_shaft_point(t, angle, side))

func _build_shaft(side: float) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for step in range(SHAFT_STEPS):
        var t0 := float(step) / float(SHAFT_STEPS)
        var t1 := float(step + 1) / float(SHAFT_STEPS)
        for segment in range(SHAFT_SIDES):
            var a0 := TAU * float(segment) / float(SHAFT_SIDES)
            var a1 := TAU * float(segment + 1) / float(SHAFT_SIDES)
            _shaft_vertex(tool, t0, a0, side)
            _shaft_vertex(tool, t1, a0, side)
            _shaft_vertex(tool, t1, a1, side)
            _shaft_vertex(tool, t0, a0, side)
            _shaft_vertex(tool, t1, a1, side)
            _shaft_vertex(tool, t0, a1, side)
    tool.generate_normals()
    return tool.commit()

func _process(delta: float) -> void:
    # Pause every animation during quiz, menus and results.
    if not running:
        return
    clock += delta
    for index in range(towers.size()):
        var tower := towers[index]
        tower.position.z += travel_speed * delta
        if tower.position.z > 16.0:
            tower.position.z -= TOWER_COUNT * TOWER_SPACING
        var pivot := search_pivots[index]
        pivot.rotation.y = sin(clock * 0.66 + float(index) * 1.7) * 0.65
        pivot.rotation.z = sin(clock * 0.38 + float(index)) * 0.09
        tower_lights[index].light_energy = 1.05 + 0.32 * sin(clock * 2.1 + float(index))
