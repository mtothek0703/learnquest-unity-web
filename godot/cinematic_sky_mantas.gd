extends Node3D
## V85: Two original sculpted sky-manta holograms glide past Neon City.
## Wing membranes are real curved 3D meshes, not sprites or screen overlays.
## The creatures stay outside the road and have no physics/collision nodes.
## Geometry and lights are intentionally modest for landscape mobile WebGL.

var running := false
var travel_speed := 14.0
var clock := 0.0
var creatures: Array[Node3D] = []
var wings: Array[Node3D] = []
var tails: Array[Node3D] = []

func _material(tint: Color, transparent: bool = false, luminous: bool = false) -> StandardMaterial3D:
    var result := StandardMaterial3D.new()
    result.albedo_color = tint
    result.metallic = 0.24
    result.roughness = 0.35
    result.cull_mode = BaseMaterial3D.CULL_DISABLED
    if transparent:
        result.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
        result.vertex_color_use_as_albedo = true
    if luminous:
        result.emission_enabled = true
        result.emission = Color("#56dfff")
        result.emission_energy_multiplier = 0.75 if transparent else 1.9
    return result

func _body_point(t: float, angle: float) -> Vector3:
    var radius := pow(maxf(0.0, sin(PI * t)), 0.72)
    return Vector3(
        cos(angle) * 0.93 * radius,
        sin(angle) * 0.43 * radius + 0.10 * sin(t * PI),
        -1.75 + t * 3.5
    )

func _body_mesh() -> ArrayMesh:
    var surface := SurfaceTool.new()
    surface.begin(Mesh.PRIMITIVE_TRIANGLES)
    for row in range(12):
        var t0 := float(row) / 12.0
        var t1 := float(row + 1) / 12.0
        for col in range(16):
            var a0 := TAU * float(col) / 16.0
            var a1 := TAU * float(col + 1) / 16.0
            var tint := Color("#334e9e").lerp(Color("#c16dc9"), maxf(0.0, sin(a0)) * 0.65)
            for vertex in [
                _body_point(t0, a0), _body_point(t1, a0), _body_point(t1, a1),
                _body_point(t0, a0), _body_point(t1, a1), _body_point(t0, a1)
            ]:
                surface.set_color(tint)
                surface.add_vertex(vertex)
    surface.generate_normals()
    return surface.commit()

func _wing_point(t: float, u: float, side: float) -> Vector3:
    var chord := (1.65 - 0.95 * t) * sin(0.15 + t * (PI - 0.3))
    return Vector3(
        side * (0.04 + 3.55 * t),
        0.12 + 0.55 * t * t + 0.23 * sin(PI * t) + (u - 0.5) * 0.11,
        (u - 0.5) * chord + 0.45 * t * t
    )

func _wing_mesh(side: float, edge: bool) -> ArrayMesh:
    var surface := SurfaceTool.new()
    surface.begin(Mesh.PRIMITIVE_TRIANGLES)
    for row in range(18):
        var t0 := float(row) / 18.0
        var t1 := float(row + 1) / 18.0
        for col in range(7 if not edge else 1):
            var u0 := float(col) / 7.0 if not edge else 0.94
            var u1 := float(col + 1) / 7.0 if not edge else 0.985
            var offset := Vector3(0.0, 0.014 if edge else 0.0, 0.0)
            var tint0 := Color(0.13, 0.89, 1.0, 0.83).lerp(Color(0.94, 0.33, 0.94, 0.35), t0)
            var tint1 := Color(0.13, 0.89, 1.0, 0.83).lerp(Color(0.94, 0.33, 0.94, 0.35), t1)
            if edge:
                tint0 = Color(0.65, 1.0, 1.0, 0.98 - t0 * 0.25)
                tint1 = Color(0.65, 1.0, 1.0, 0.98 - t1 * 0.25)
            var p00 := _wing_point(t0, u0, side) + offset
            var p10 := _wing_point(t1, u0, side) + offset
            var p11 := _wing_point(t1, u1, side) + offset
            var p01 := _wing_point(t0, u1, side) + offset
            for point in [p00, p10, p11, p00, p11, p01]:
                surface.set_color(tint0 if point == p00 or point == p01 else tint1)
                surface.add_vertex(point)
    surface.generate_normals()
    return surface.commit()

func _orb(parent: Node3D, title: String, pos: Vector3, size: Vector3, material: StandardMaterial3D) -> MeshInstance3D:
    var mesh := SphereMesh.new()
    mesh.radial_segments = 12
    mesh.rings = 8
    var result := MeshInstance3D.new()
    result.name = title
    result.mesh = mesh
    result.material_override = material
    result.position = pos
    result.scale = size
    parent.add_child(result)
    return result

func _ready() -> void:
    var shell := _material(Color.WHITE)
    shell.vertex_color_use_as_albedo = true
    var membrane := _material(Color.WHITE, true, true)
    var edge := _material(Color.WHITE, true, true)
    edge.emission_energy_multiplier = 1.8
    var luminous := _material(Color("#9bf8ff"), false, true)
    var body_geometry := _body_mesh()
    for index in range(2):
        var side := -1.0 if index == 0 else 1.0
        var creature := Node3D.new()
        creature.name = "Sky manta %d" % index
        creature.position = Vector3(side * 13.2, 8.3, -21.0 - float(index) * 66.0)
        creature.rotation.y = side * 0.22
        add_child(creature)
        creatures.append(creature)
        var body := MeshInstance3D.new()
        body.name = "Sculpted shaded manta body"
        body.mesh = body_geometry
        body.material_override = shell
        creature.add_child(body)
        _orb(creature, "Raised holographic cockpit crest", Vector3(0.0, 0.38, -0.75), Vector3(0.60, 0.24, 0.75), luminous)
        for wing_index in range(2):
            var wing_side := -1.0 if wing_index == 0 else 1.0
            var pivot := Node3D.new()
            pivot.name = "Left articulated wing" if wing_index == 0 else "Right articulated wing"
            pivot.position = Vector3(wing_side * 0.62, 0.13, -0.12)
            creature.add_child(pivot)
            wings.append(pivot)
            var panel := MeshInstance3D.new()
            panel.name = "Curved translucent wing membrane"
            panel.mesh = _wing_mesh(wing_side, false)
            panel.material_override = membrane
            pivot.add_child(panel)
            var rim := MeshInstance3D.new()
            rim.name = "Luminous trailing wing edge"
            rim.mesh = _wing_mesh(wing_side, true)
            rim.material_override = edge
            pivot.add_child(rim)
            _orb(creature, "Glowing side eye %d" % wing_index, Vector3(wing_side * 0.51, 0.12, -1.25), Vector3(0.16, 0.16, 0.22), luminous)
        var tail := Node3D.new()
        tail.name = "Articulated comet tail"
        tail.position = Vector3(0.0, 0.0, 1.35)
        creature.add_child(tail)
        tails.append(tail)
        for segment in range(4):
            _orb(tail, "Tapered tail segment %d" % segment, Vector3(0.0, 0.0, 0.35 + float(segment) * 0.48), Vector3(0.20 - float(segment) * 0.035, 0.12, 0.36), luminous)
        var light := OmniLight3D.new()
        light.name = "Soft holographic manta light"
        light.light_color = Color("#63dfff") if index == 0 else Color("#ff80dd")
        light.light_energy = 0.65
        light.omni_range = 5.5
        light.shadow_enabled = false
        creature.add_child(light)

func _process(delta: float) -> void:
    clock += delta
    for index in range(creatures.size()):
        var creature := creatures[index]
        if running:
            creature.position.z += travel_speed * delta * (0.96 if index == 0 else 1.08)
            if creature.position.z > 20.0:
                creature.position.z -= 155.0
        creature.position.y = 8.3 + sin(clock * 1.6 + float(index) * 1.5) * 0.42
        creature.rotation.y = (-0.22 if index == 0 else 0.22) + sin(clock * 0.65 + float(index)) * 0.08
        for wing_index in range(2):
            var side := -1.0 if wing_index == 0 else 1.0
            var wing := wings[index * 2 + wing_index]
            wing.rotation.z = side * sin(clock * 3.5 + float(index) * 1.1) * 0.30
            wing.rotation.x = sin(clock * 2.4 + float(wing_index) * 0.8) * 0.09
        tails[index].rotation.y = sin(clock * 2.6 + float(index)) * 0.23
