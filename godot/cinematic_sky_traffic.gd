extends Node3D
## V81: Two fully modeled maglev convoys bring moving foreground parallax to
## Neon City in landscape. Original procedural meshes, no external assets.
## All rails and carriages sit outside the three collision-free race lanes.

var running := false
var travel_speed := 14.0
var clock := 0.0
var trains: Array[Node3D] = []
var spark_groups: Array = []

func _material(color: Color, glowing: bool = false, glass: bool = false) -> StandardMaterial3D:
    var result := StandardMaterial3D.new()
    result.albedo_color = color
    result.metallic = 0.58 if not glass else 0.18
    result.roughness = 0.26 if not glass else 0.12
    if glass:
        result.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
        result.cull_mode = BaseMaterial3D.CULL_DISABLED
    if glowing:
        result.emission_enabled = true
        result.emission = Color(color.r, color.g, color.b)
        result.emission_energy_multiplier = 2.0
    return result

func _box(parent: Node3D, title: String, size: Vector3, location: Vector3, surface: Material) -> MeshInstance3D:
    var piece := MeshInstance3D.new()
    piece.name = title
    var geometry := BoxMesh.new()
    geometry.size = size
    piece.mesh = geometry
    piece.position = location
    piece.material_override = surface
    parent.add_child(piece)
    return piece

func _hull_point(section: int, angle: float) -> Vector3:
    var lengths := PackedFloat32Array([-1.75, -1.23, 1.20, 1.75])
    var widths := PackedFloat32Array([0.62, 1.16, 1.16, 0.66])
    var heights := PackedFloat32Array([0.36, 0.66, 0.66, 0.38])
    return Vector3(cos(angle) * widths[section], sin(angle) * heights[section], lengths[section])

func _hull_mesh() -> ArrayMesh:
    var surface := SurfaceTool.new()
    surface.begin(Mesh.PRIMITIVE_TRIANGLES)
    for section in range(3):
        for side in range(12):
            var a0 := TAU * float(side) / 12.0
            var a1 := TAU * float(side + 1) / 12.0
            var shade := Color("#7b9ac8").lerp(Color("#d8e9ff"), maxf(0.0, sin(a0)) * 0.72)
            for vertex in [
                _hull_point(section, a0), _hull_point(section, a1), _hull_point(section + 1, a0),
                _hull_point(section, a1), _hull_point(section + 1, a1), _hull_point(section + 1, a0)
            ]:
                surface.set_color(shade)
                surface.add_vertex(vertex)
    for end in [0, 3]:
        for side in range(12):
            var a0 := TAU * float(side) / 12.0
            var a1 := TAU * float(side + 1) / 12.0
            var center := Vector3(0.0, 0.0, -1.75 if end == 0 else 1.75)
            surface.set_color(Color("#49668d"))
            surface.add_vertex(center)
            surface.add_vertex(_hull_point(end, a1 if end == 0 else a0))
            surface.add_vertex(_hull_point(end, a0 if end == 0 else a1))
    surface.generate_normals()
    return surface.commit()

func _ready() -> void:
    var chassis := _material(Color("#7385bd"))
    chassis.vertex_color_use_as_albedo = true
    var track := _material(Color("#253453"))
    var neon := _material(Color("#62f7ec"), true)
    var pink := _material(Color("#ff70ca"), true)
    var glass := _material(Color(0.17, 0.82, 0.96, 0.64), true, true)
    var hull := _hull_mesh()
    for index in range(2):
        var side := -1.0 if index == 0 else 1.0
        var rail := Node3D.new()
        rail.name = "Elevated maglev rail %d" % index
        rail.position.x = side * 11.8
        add_child(rail)
        _box(rail, "Structural rail deck", Vector3(2.85, 0.26, 160.0), Vector3(0.0, 5.35, -66.0), track)
        for edge in [-1.0, 1.0]:
            _box(rail, "Luminous guide rail", Vector3(0.12, 0.13, 160.0), Vector3(edge * 1.23, 5.55, -66.0), neon if index == 0 else pink)
        for support in range(8):
            var z := -7.0 - float(support) * 19.0
            _box(rail, "Elevated rail support", Vector3(0.38, 5.25, 0.55), Vector3(0.0, 2.6, z), track)
            _box(rail, "Support beacon", Vector3(0.68, 0.12, 0.68), Vector3(0.0, 5.45, z), neon)

        var train := Node3D.new()
        train.name = "Sky tram %d" % index
        train.position = Vector3(side * 11.8, 7.0, -22.0 - float(index) * 69.0)
        add_child(train)
        trains.append(train)
        for car_index in range(3):
            var car := Node3D.new()
            car.name = "Car %d" % car_index
            car.position.z = -float(car_index) * 3.72
            train.add_child(car)
            var shell := MeshInstance3D.new()
            shell.name = "Sculpted car hull"
            shell.mesh = hull
            shell.material_override = chassis
            car.add_child(shell)
            _box(car, "Panoramic windscreen", Vector3(1.37, 0.54, 0.08), Vector3(0.0, 0.14, 1.65), glass)
            _box(car, "Roof light ribbon", Vector3(1.42, 0.075, 2.42), Vector3(0.0, 0.63, 0.0), pink if index == 0 else neon)
            for window_side in [-1.0, 1.0]:
                _box(car, "Side panoramic window", Vector3(0.065, 0.39, 1.76), Vector3(window_side * 1.12, 0.16, -0.03), glass)
                _box(car, "Magnetic levitation coil", Vector3(0.22, 0.18, 2.8), Vector3(window_side * 0.84, -0.58, 0.0), neon if index == 0 else pink)
            _box(car, "Rear marker", Vector3(1.0, 0.15, 0.07), Vector3(0.0, -0.08, -1.73), pink)
        var lamp := OmniLight3D.new()
        lamp.name = "Moving neon train light"
        lamp.light_color = Color("#54f9f4") if index == 0 else Color("#ff85cc")
        lamp.light_energy = 0.65
        lamp.omni_range = 5.0
        lamp.shadow_enabled = false
        lamp.position = Vector3(0.0, -0.25, 1.7)
        train.add_child(lamp)
        var sparks: Array[MeshInstance3D] = []
        for spark_index in range(10):
            var spark := MeshInstance3D.new()
            spark.name = "Trailing energy spark %d" % spark_index
            var sparkle_mesh := SphereMesh.new()
            sparkle_mesh.radius = 0.12
            sparkle_mesh.height = 0.24
            sparkle_mesh.radial_segments = 6
            sparkle_mesh.rings = 4
            spark.mesh = sparkle_mesh
            spark.material_override = neon if index == 0 else pink
            spark.position = Vector3(-0.78 if spark_index % 2 == 0 else 0.78, -0.63, -11.5 - float(spark_index) * 0.75)
            train.add_child(spark)
            sparks.append(spark)
        spark_groups.append(sparks)

func _process(delta: float) -> void:
    clock += delta
    for index in range(trains.size()):
        var train := trains[index]
        if running:
            train.position.z += travel_speed * delta * (1.10 if index == 0 else 0.94)
            if train.position.z > 20.0:
                train.position.z -= 150.0
        train.position.y = 7.0 + sin(clock * 2.1 + float(index)) * 0.12
        train.rotation.z = sin(clock * 0.72 + float(index)) * 0.012
        var sparks: Array = spark_groups[index]
        for spark_index in range(sparks.size()):
            var spark: MeshInstance3D = sparks[spark_index]
            var pulse := 0.65 + 0.33 * sin(clock * 7.0 - float(spark_index) * 0.68)
            spark.scale = Vector3.ONE * pulse
            spark.position.z = -11.5 - float(spark_index) * 0.75 - fposmod(clock * 4.0, 2.0)
