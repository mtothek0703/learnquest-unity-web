extends Node3D
## Skyway V45: original, reusable sculpted ice architecture and animated aurora.
## All meshes are generated locally in Godot; no external assets or licenses.
var running := false
var travel_speed := 14.0
var elapsed := 0.0
var moving_parts: Array[Node3D] = []
var aurora_ribbons: Array[MeshInstance3D] = []
var jump_gates: Array[Node3D] = []
var completed_gates := 0
var missed_gates := 0

func _ready() -> void:
    _build_glacier()

func _material(tint: Color, emissive: bool = false, vertex_colors: bool = true, translucent: bool = false) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = tint
    material.vertex_color_use_as_albedo = vertex_colors
    material.roughness = 0.34
    material.metallic = 0.18
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    if emissive:
        material.emission_enabled = true
        material.emission = tint
        material.emission_energy_multiplier = 1.65
    if translucent:
        material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
        material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    return material

func _quad(tool: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, tint: Color) -> void:
    tool.set_color(tint)
    tool.add_vertex(a)
    tool.add_vertex(b)
    tool.add_vertex(c)
    tool.add_vertex(a)
    tool.add_vertex(c)
    tool.add_vertex(d)

func _ridge_point(layer: int, angle: float) -> Vector3:
    var t := float(layer) / 10.0
    var radius := (1.0 - t) * (2.6 + 0.30 * sin(angle * 5.0 + t * 8.0)) + 0.08
    return Vector3(cos(angle) * radius + sin(t * 5.0) * 0.38, t * 11.0, sin(angle) * radius + cos(t * 7.0) * 0.26)

func _ridge_mesh() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for layer in range(10):
        var tint := Color("#244f87").lerp(Color("#e0fcff"), float(layer) / 10.0)
        for segment in range(14):
            var a := TAU * float(segment) / 14.0
            var b := TAU * float(segment + 1) / 14.0
            _quad(tool, _ridge_point(layer, a), _ridge_point(layer, b), _ridge_point(layer + 1, b), _ridge_point(layer + 1, a), tint)
    tool.generate_normals()
    return tool.commit()

func _arch_point(step: int, radial_step: int) -> Vector3:
    var t := PI * float(step) / 32.0
    var r := TAU * float(radial_step) / 12.0
    var thickness := 0.55 + 0.11 * sin(t * 9.0)
    return Vector3(cos(t) * (6.45 + cos(r) * thickness), 0.4 + sin(t) * (8.0 + cos(r) * thickness), sin(r) * thickness)

func _arch_mesh() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for step in range(32):
        var tint := Color("#3b7db4").lerp(Color("#c6f9ff"), sin(PI * float(step) / 32.0))
        for radial in range(12):
            _quad(tool, _arch_point(step, radial), _arch_point(step, radial + 1), _arch_point(step + 1, radial + 1), _arch_point(step + 1, radial), tint)
    tool.generate_normals()
    return tool.commit()

func _gate_point(step: int, radial_step: int) -> Vector3:
    var t := TAU * float(step) / 48.0
    var r := TAU * float(radial_step) / 10.0
    var radius := 1.75 + cos(r) * 0.17
    return Vector3(cos(t) * radius, sin(t) * radius, sin(r) * 0.17)

func _gate_mesh() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for step in range(48):
        var tint := Color("#49f9d3").lerp(Color("#fc9fff"), (sin(TAU * float(step) / 48.0) + 1.0) * 0.5)
        for radial in range(10):
            _quad(tool, _gate_point(step, radial), _gate_point(step, radial + 1), _gate_point(step + 1, radial + 1), _gate_point(step + 1, radial), tint)
    tool.generate_normals()
    return tool.commit()

func _ribbon_point(step: int, width_step: int, offset: float) -> Vector3:
    var t := float(step) / 52.0
    var w := float(width_step) / 5.0
    var x := sin(t * 8.0 + offset) * 7.0 + (w - 0.5) * 3.0
    var y := 14.0 + sin(t * 13.0 + offset) * 2.5 + w * 5.5
    return Vector3(x, y, -22.0 - t * 145.0)

func _ribbon_mesh(offset: float) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for step in range(52):
        for width_step in range(5):
            var fraction := float(width_step) / 5.0
            var tint := Color(0.12, 0.98, 0.81, 0.24).lerp(Color(0.98, 0.32, 0.91, 0.10), fraction)
            _quad(tool, _ribbon_point(step, width_step, offset), _ribbon_point(step + 1, width_step, offset), _ribbon_point(step + 1, width_step + 1, offset), _ribbon_point(step, width_step + 1, offset), tint)
    return tool.commit()

func _instance(parent: Node3D, title: String, mesh: Mesh, pos: Vector3, material: Material) -> MeshInstance3D:
    var part := MeshInstance3D.new()
    part.name = title
    part.mesh = mesh
    part.material_override = material
    part.position = pos
    parent.add_child(part)
    return part

func _build_glacier() -> void:
    var ice_mesh := _ridge_mesh()
    var arch_mesh := _arch_mesh()
    var gate_mesh := _gate_mesh()
    var ice_material := _material(Color.WHITE)
    var gate_material := _material(Color("#72fff0"), true)
    # Silhouette-defining sculpted ridges and ice arches, shared meshes for WebGL.
    for index in range(18):
        var side := -1.0 if index % 2 == 0 else 1.0
        var cluster := Node3D.new()
        cluster.name = "Glacier ridge cluster %d" % index
        cluster.position = Vector3(side * (12.5 + float(index % 4) * 1.8), -0.4, -16.0 - float(index) * 10.0)
        add_child(cluster)
        moving_parts.append(cluster)
        var ridge := _instance(cluster, "Sculpted ice ridge", ice_mesh, Vector3.ZERO, ice_material)
        ridge.scale = Vector3(0.85 + float(index % 3) * 0.23, 0.68 + float(index % 5) * 0.14, 0.85)
        ridge.rotation.y = float(index) * 0.65
        var satellite := _instance(cluster, "Floating glacier shard", ice_mesh, Vector3(-side * 1.6, 10.8, 0), ice_material)
        satellite.scale = Vector3(0.28, -0.29, 0.30)
        satellite.rotation.z = float(index) * 0.31
    for index in range(5):
        var bridge := Node3D.new()
        bridge.name = "Sculpted ice arch %d" % index
        bridge.position = Vector3(0, 0, -27.0 - float(index) * 32.0)
        add_child(bridge)
        moving_parts.append(bridge)
        _instance(bridge, "Continuous sculpted ice arch", arch_mesh, Vector3.ZERO, ice_material)
        var crown := _instance(bridge, "Aurora arch crown", gate_mesh, Vector3(0, 8.6, 0), gate_material)
        crown.scale = Vector3(0.45, 0.45, 0.45)
    # Layered translucent aurora silk uses vertex gradients, not flat neon boxes.
    for index in range(4):
        var silk := _instance(self, "Aurora silk %d" % index, _ribbon_mesh(float(index) * 1.37), Vector3(float(index - 2) * 2.4, 0, -float(index) * 8.0), _material(Color(1.0, 1.0, 1.0, 0.72), false, true, true))
        aurora_ribbons.append(silk)
    # Five real airborne jump gates: clearing at least three earns a mission star.
    for index in range(5):
        var gate := Node3D.new()
        gate.name = "Aurora jump gate %d" % index
        gate.position = Vector3(float((index + 1) % 3 - 1) * 3.1, 0, -65.0 - float(index) * 190.0)
        gate.set_meta("passed", false)
        gate.set_meta("cleared", false)
        add_child(gate)
        jump_gates.append(gate)
        _instance(gate, "Sculpted jump ring", gate_mesh, Vector3(0, 2.35, 0), gate_material)
        var beacon := SphereMesh.new()
        beacon.radial_segments = 16
        beacon.rings = 8
        var heart := _instance(gate, "Jump gate energy heart", beacon, Vector3(0, 2.35, 0), gate_material)
        heart.scale = Vector3(0.18, 0.34, 0.18)

func reset_course() -> void:
    completed_gates = 0
    missed_gates = 0
    for index in range(jump_gates.size()):
        var gate := jump_gates[index]
        gate.position.z = -65.0 - float(index) * 190.0
        gate.set_meta("passed", false)
        gate.set_meta("cleared", false)
        gate.visible = true

func check_jump_gates(rider_x: float, rider_y: float) -> int:
    # The game calls this during a race, after updating the actual jump height.
    # Each gate is scored exactly once; steering and jumping both matter.
    var result := 0
    for gate in jump_gates:
        if bool(gate.get_meta("passed")) or gate.position.z < 0.2:
            continue
        gate.set_meta("passed", true)
        gate.visible = false
        if absf(rider_x - gate.position.x) <= 1.45 and rider_y >= 0.9:
            gate.set_meta("cleared", true)
            completed_gates += 1
            result += 1
        else:
            missed_gates += 1
            result -= 1
    return result

func _process(delta: float) -> void:
    elapsed += delta
    for index in range(aurora_ribbons.size()):
        var silk := aurora_ribbons[index]
        silk.rotation.z = sin(elapsed * 0.32 + float(index) * 1.3) * 0.07
        silk.rotation.x = sin(elapsed * 0.23 + float(index)) * 0.035
    if not running:
        return
    for cluster in moving_parts:
        cluster.position.z += travel_speed * delta
        if cluster.position.z > 20.0:
            cluster.position.z -= 190.0
    for gate in jump_gates:
        if not bool(gate.get_meta("passed")):
            gate.position.z += travel_speed * delta
            var ring := gate.get_node_or_null("Sculpted jump ring") as MeshInstance3D
            if ring != null:
                ring.rotation.z += delta * 0.38
