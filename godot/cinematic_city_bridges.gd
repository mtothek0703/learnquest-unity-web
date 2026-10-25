extends Node3D
## Three richly layered, animated skybridges framing the 16:9 landscape race.
## Custom shaded mesh rails use no external assets and few mobile draw calls.

var running := false
var travel_speed := 14.0
var clock := 0.0
var bridges: Array[Node3D] = []
var sign_pivots: Array[Node3D] = []

func _ready() -> void:
    for index in range(3):
        var bridge := Node3D.new()
        bridge.name = "Cinematic Skybridge %d" % index
        bridge.position.z = -34.0 - float(index) * 47.0
        add_child(bridge)
        bridges.append(bridge)
        _build_bridge(bridge, index)

func _arch_point(t: float, angle: float, elevation: float, z_offset: float, radius: float) -> Vector3:
    var x := lerpf(-7.4, 7.4, t)
    var crest := elevation * sin(PI * t)
    var slope := elevation * PI * cos(PI * t) / 14.8
    var normal := Vector3(-slope, 1.0, 0.0).normalized()
    return Vector3(x, 4.5 + crest, z_offset) + normal * cos(angle) * radius + Vector3(0.0, 0.0, sin(angle) * radius)

func _rail_mesh(elevation: float, z_offset: float, thickness: float) -> ArrayMesh:
    var builder := SurfaceTool.new()
    builder.begin(Mesh.PRIMITIVE_TRIANGLES)
    for segment in range(40):
        var t0 := float(segment) / 40.0
        var t1 := float(segment + 1) / 40.0
        for side in range(8):
            var a0 := TAU * float(side) / 8.0
            var a1 := TAU * float(side + 1) / 8.0
            var c0 := Color("#64fff5").lerp(Color("#ff81bc"), absf(t0 - 0.5) * 1.4)
            var c1 := Color("#64fff5").lerp(Color("#ff81bc"), absf(t1 - 0.5) * 1.4)
            builder.set_color(c0)
            builder.add_vertex(_arch_point(t0, a0, elevation, z_offset, thickness))
            builder.set_color(c1)
            builder.add_vertex(_arch_point(t1, a0, elevation, z_offset, thickness))
            builder.set_color(c0)
            builder.add_vertex(_arch_point(t0, a1, elevation, z_offset, thickness))
            builder.set_color(c0)
            builder.add_vertex(_arch_point(t0, a1, elevation, z_offset, thickness))
            builder.set_color(c1)
            builder.add_vertex(_arch_point(t1, a0, elevation, z_offset, thickness))
            builder.set_color(c1)
            builder.add_vertex(_arch_point(t1, a1, elevation, z_offset, thickness))
    builder.generate_normals()
    return builder.commit()

func _neon_material() -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = Color.WHITE
    m.vertex_color_use_as_albedo = true
    m.cull_mode = BaseMaterial3D.CULL_DISABLED
    m.metallic = 0.30
    m.roughness = 0.35
    m.emission_enabled = true
    m.emission = Color("#32dff5")
    m.emission_energy_multiplier = 1.7
    return m

func _build_bridge(bridge: Node3D, index: int) -> void:
    var metal := StandardMaterial3D.new()
    metal.albedo_color = Color("#273a67")
    metal.metallic = 0.58
    metal.roughness = 0.32
    var cyan := _neon_material()
    for layer in range(3):
        var beam := MeshInstance3D.new()
        beam.name = "Sculpted Luminous Arch %d" % layer
        beam.mesh = _rail_mesh(3.0 + float(layer) * 0.48, -float(layer) * 0.48, 0.24 if layer == 0 else 0.11)
        beam.material_override = cyan
        bridge.add_child(beam)
    for side in [-1.0, 1.0]:
        var pylon := MeshInstance3D.new()
        pylon.name = "Sculpted Bridge Pylon %s" % ("L" if side < 0 else "R")
        var cone := CylinderMesh.new()
        cone.top_radius = 0.38
        cone.bottom_radius = 0.85
        cone.height = 4.45
        cone.radial_segments = 14
        pylon.mesh = cone
        pylon.position = Vector3(side * 7.37, 2.2, 0)
        pylon.material_override = metal
        bridge.add_child(pylon)
        var beacon := MeshInstance3D.new()
        beacon.name = "Luminous Pylon Beacon"
        var beacon_mesh := SphereMesh.new()
        beacon_mesh.radius = 0.43
        beacon_mesh.height = 0.86
        beacon.mesh = beacon_mesh
        beacon.material_override = cyan
        beacon.position = Vector3(side * 7.37, 4.6, 0)
        bridge.add_child(beacon)

    var sign := Node3D.new()
    sign.name = "Floating Holographic Road Sign"
    sign.position = Vector3(0, 7.25 + float(index % 2) * 0.32, -0.95)
    bridge.add_child(sign)
    sign_pivots.append(sign)
    var holo := MeshInstance3D.new()
    holo.name = "Translucent Hologram"
    var panel_mesh := QuadMesh.new()
    panel_mesh.size = Vector2(4.8, 1.15)
    holo.mesh = panel_mesh
    var glass := StandardMaterial3D.new()
    glass.albedo_color = Color(0.11, 0.65, 0.96, 0.35)
    glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    glass.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    glass.cull_mode = BaseMaterial3D.CULL_DISABLED
    glass.emission_enabled = true
    glass.emission = Color("#194ca7")
    glass.emission_energy_multiplier = 0.7
    holo.material_override = glass
    sign.add_child(holo)
    for stripe in range(3):
        var line := MeshInstance3D.new()
        line.name = "Animated Holographic Stripe %d" % stripe
        var line_mesh := BoxMesh.new()
        line_mesh.size = Vector3(3.6 - float(stripe) * 0.75, 0.065, 0.06)
        line.mesh = line_mesh
        line.material_override = cyan
        line.position = Vector3(0, 0.30 - float(stripe) * 0.24, 0.07)
        sign.add_child(line)

func _process(delta: float) -> void:
    clock += delta
    for i in range(bridges.size()):
        var bridge := bridges[i]
        if running:
            bridge.position.z += travel_speed * delta
            if bridge.position.z > 14.0:
                bridge.position.z -= 141.0
        var sign := sign_pivots[i]
        sign.position.y = 7.25 + float(i % 2) * 0.32 + sin(clock * 1.6 + float(i)) * 0.16
        sign.rotation.y = sin(clock * 0.7 + float(i)) * 0.10
