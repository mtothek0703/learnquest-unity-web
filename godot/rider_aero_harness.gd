extends Node3D
## Skyway V36: original sculpted back-mounted aero harness.
## Curved vertex-shaded armor, rotating reactor and twin animated thrusters.
## All geometry is generated once, with no third-party assets or paid services.
var clock: float = 0.0
var reactor: Node3D
var thrusters: Array[Node3D] = []
var reactor_light: StandardMaterial3D
var exhaust_light: StandardMaterial3D

func _ready() -> void:
    _build_harness()

func _process(delta: float) -> void:
    clock += delta
    var rider := get_parent().get_parent() as Node3D
    var lean := float(rider.get("lean")) if rider != null else 0.0
    var turbo := bool(rider.get("boosting")) if rider != null else false
    var pace := 9.0 if turbo else 2.8
    if is_instance_valid(reactor):
        reactor.rotation.z += delta * (5.2 if turbo else 1.2)
        var pulse := 1.0 + (0.09 if turbo else 0.025) * sin(clock * pace)
        reactor.scale = Vector3.ONE * pulse
    for i in range(thrusters.size()):
        var side := -1.0 if i == 0 else 1.0
        var thruster := thrusters[i]
        thruster.rotation.z = lerpf(thruster.rotation.z, -lean * 0.17 + side * (0.11 if turbo else 0.025), minf(1.0, delta * 7.0))
        thruster.rotation.x = lerpf(thruster.rotation.x, -0.19 if turbo else -0.03, minf(1.0, delta * 7.0))
    if reactor_light != null:
        reactor_light.emission_energy_multiplier = 1.5 + (0.9 if turbo else 0.18) * (0.5 + 0.5 * sin(clock * pace))
    if exhaust_light != null:
        exhaust_light.emission_energy_multiplier = 1.6 + (1.2 if turbo else 0.20) * (0.5 + 0.5 * sin(clock * pace))

func _fabric() -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = Color.WHITE
    m.vertex_color_use_as_albedo = true
    m.metallic = 0.46
    m.roughness = 0.34
    m.cull_mode = BaseMaterial3D.CULL_DISABLED
    return m

func _light(tint: Color) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = tint
    m.emission_enabled = true
    m.emission = tint * 0.75
    m.emission_energy_multiplier = 1.6
    m.cull_mode = BaseMaterial3D.CULL_DISABLED
    return m

func _build_harness() -> void:
    var armor := _fabric()
    reactor_light = _light(Color(0.17, 0.96, 1.0))
    exhaust_light = _light(Color(0.83, 0.32, 1.0))
    var shell := MeshInstance3D.new()
    shell.name = "CurvedAeroBackplate"
    shell.mesh = _backplate_mesh()
    shell.material_override = armor
    add_child(shell)
    var ribs := MeshInstance3D.new()
    ribs.name = "LuminousArmorRibs"
    ribs.mesh = _rib_mesh()
    ribs.material_override = reactor_light
    add_child(ribs)
    reactor = Node3D.new()
    reactor.name = "RotatingEnergyReactor"
    reactor.position = Vector3(0.0, 1.68, 1.045)
    add_child(reactor)
    var ring := MeshInstance3D.new()
    ring.name = "SculptedReactorRing"
    ring.mesh = _ring_mesh()
    ring.material_override = reactor_light
    reactor.add_child(ring)
    var hub := MeshInstance3D.new()
    hub.name = "ReactorHub"
    var hub_mesh := SphereMesh.new()
    hub_mesh.radius = 0.10
    hub_mesh.height = 0.10
    hub_mesh.radial_segments = 16
    hub_mesh.rings = 8
    hub.mesh = hub_mesh
    hub.material_override = exhaust_light
    hub.position.z = 0.015
    reactor.add_child(hub)
    thrusters.clear()
    for i in range(2):
        var side := -1.0 if i == 0 else 1.0
        var thruster := Node3D.new()
        thruster.name = "LeftAeroThruster" if i == 0 else "RightAeroThruster"
        thruster.position = Vector3(side * 0.42, 1.58, 0.90)
        add_child(thruster)
        var pod := MeshInstance3D.new()
        pod.name = "SculptedThrusterHousing"
        pod.mesh = _pod_mesh()
        pod.material_override = armor
        thruster.add_child(pod)
        var plume := MeshInstance3D.new()
        plume.name = "NeonExhaustPlume"
        plume.mesh = _plume_mesh()
        plume.material_override = exhaust_light
        thruster.add_child(plume)
        thrusters.append(thruster)

func _backplate_point(u: float, v: float) -> Vector3:
    var x := u * 2.0 - 1.0
    var width := 0.31 + 0.15 * sin(v * PI)
    var roundness := maxf(0.0, 1.0 - x * x)
    return Vector3(x * width, 1.16 + v * 0.98, 0.78 + 0.19 * roundness + 0.035 * sin(v * PI))

func _vertex(tool: SurfaceTool, point: Vector3, tint: Color) -> void:
    tool.set_color(tint)
    tool.add_vertex(point)

func _backplate_mesh() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    const ROWS := 14
    const COLUMNS := 18
    for row in range(ROWS):
        var v0 := float(row) / float(ROWS)
        var v1 := float(row + 1) / float(ROWS)
        for col in range(COLUMNS):
            var u0 := float(col) / float(COLUMNS)
            var u1 := float(col + 1) / float(COLUMNS)
            var tint0 := Color(0.09, 0.13, 0.35).lerp(Color(0.48, 0.24, 0.77), v0 * 0.8)
            var tint1 := Color(0.09, 0.13, 0.35).lerp(Color(0.48, 0.24, 0.77), v1 * 0.8)
            _vertex(tool, _backplate_point(u0, v0), tint0)
            _vertex(tool, _backplate_point(u0, v1), tint1)
            _vertex(tool, _backplate_point(u1, v1), tint1)
            _vertex(tool, _backplate_point(u0, v0), tint0)
            _vertex(tool, _backplate_point(u1, v1), tint1)
            _vertex(tool, _backplate_point(u1, v0), tint0)
    tool.generate_normals()
    return tool.commit()

func _rib_mesh() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    const STEPS := 24
    for edge in [0.04, 0.92]:
        for step in range(STEPS):
            var v0 := 0.08 + 0.84 * float(step) / float(STEPS)
            var v1 := 0.08 + 0.84 * float(step + 1) / float(STEPS)
            _quad(tool, _backplate_point(edge, v0) + Vector3(0, 0, 0.018), _backplate_point(edge + 0.035, v0) + Vector3(0, 0, 0.018), _backplate_point(edge, v1) + Vector3(0, 0, 0.018), _backplate_point(edge + 0.035, v1) + Vector3(0, 0, 0.018))
    tool.generate_normals()
    return tool.commit()

func _quad(tool: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3) -> void:
    tool.add_vertex(a)
    tool.add_vertex(c)
    tool.add_vertex(d)
    tool.add_vertex(a)
    tool.add_vertex(d)
    tool.add_vertex(b)

func _ring_mesh() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    const SEGMENTS := 48
    for i in range(SEGMENTS):
        var a0 := TAU * float(i) / float(SEGMENTS)
        var a1 := TAU * float(i + 1) / float(SEGMENTS)
        # A five-pointed energy rotor, not a plain primitive torus.
        var r0 := 0.205 + 0.035 * pow(absf(cos(a0 * 2.5)), 10.0)
        var r1 := 0.205 + 0.035 * pow(absf(cos(a1 * 2.5)), 10.0)
        _quad(tool,
            Vector3(cos(a0) * (r0 - 0.046), sin(a0) * (r0 - 0.046), 0.0),
            Vector3(cos(a0) * r0, sin(a0) * r0, 0.0),
            Vector3(cos(a1) * (r1 - 0.046), sin(a1) * (r1 - 0.046), 0.0),
            Vector3(cos(a1) * r1, sin(a1) * r1, 0.0))
    tool.generate_normals()
    return tool.commit()

func _pod_mesh() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    const ROWS := 14
    const SIDES := 16
    for row in range(ROWS):
        var t0 := float(row) / float(ROWS)
        var t1 := float(row + 1) / float(ROWS)
        for side in range(SIDES):
            var a0 := TAU * float(side) / float(SIDES)
            var a1 := TAU * float(side + 1) / float(SIDES)
            var tint0 := Color(0.11, 0.17, 0.38).lerp(Color(0.52, 0.25, 0.73), t0 * 0.8)
            var tint1 := Color(0.11, 0.17, 0.38).lerp(Color(0.52, 0.25, 0.73), t1 * 0.8)
            _vertex(tool, _pod_point(t0, a0), tint0)
            _vertex(tool, _pod_point(t1, a0), tint1)
            _vertex(tool, _pod_point(t1, a1), tint1)
            _vertex(tool, _pod_point(t0, a0), tint0)
            _vertex(tool, _pod_point(t1, a1), tint1)
            _vertex(tool, _pod_point(t0, a1), tint0)
    tool.generate_normals()
    return tool.commit()

func _pod_point(t: float, angle: float) -> Vector3:
    var radius := 0.07 + 0.075 * sin(t * PI)
    return Vector3(cos(angle) * radius, 0.31 - t * 0.61, 0.10 + sin(angle) * radius * 1.18)

func _plume_mesh() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    const ROWS := 14
    const SIDES := 12
    for row in range(ROWS):
        var t0 := float(row) / float(ROWS)
        var t1 := float(row + 1) / float(ROWS)
        for side in range(SIDES):
            var a0 := TAU * float(side) / float(SIDES)
            var a1 := TAU * float(side + 1) / float(SIDES)
            _quad(tool, _plume_point(t0, a0), _plume_point(t0, a1), _plume_point(t1, a0), _plume_point(t1, a1))
    tool.generate_normals()
    return tool.commit()

func _plume_point(t: float, angle: float) -> Vector3:
    var radius := 0.09 * (1.0 - t * 0.75)
    return Vector3(cos(angle) * radius, -0.20 - 0.43 * t, 0.10 + sin(angle) * radius)
