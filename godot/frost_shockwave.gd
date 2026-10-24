extends MeshInstance3D
## Original animated, swept ice-shockwave warning for Aurora's two dangerous lanes.
## Built once from shaded triangle surfaces; no external textures, assets or shaders.
const WIDTH_STEPS := 12
const LENGTH_STEPS := 42
var elapsed := 0.0

func _quad(tool: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, tint: Color) -> void:
    tool.set_color(tint)
    tool.add_vertex(a)
    tool.add_vertex(b)
    tool.add_vertex(c)
    tool.add_vertex(a)
    tool.add_vertex(c)
    tool.add_vertex(d)

func _wave_point(across: int, along: int) -> Vector3:
    var u := float(across) / float(WIDTH_STEPS)
    var t := float(along) / float(LENGTH_STEPS)
    var ridge := pow(maxf(0.0, 1.0 - absf(2.0 * u - 1.0)), 1.3)
    var swell := 0.48 + 0.18 * sin(t * TAU * 4.0 + u * 5.0)
    return Vector3((u - 0.5) * 2.75, 0.07 + ridge * swell, (t - 0.5) * 35.0)

func _wave_mesh() -> ArrayMesh:
    var surface := SurfaceTool.new()
    surface.begin(Mesh.PRIMITIVE_TRIANGLES)
    for along in range(LENGTH_STEPS):
        var t := float(along) / float(LENGTH_STEPS)
        for across in range(WIDTH_STEPS):
            var u := float(across) / float(WIDTH_STEPS)
            var tint := Color("#1e8db9").lerp(Color("#b6faff"), 0.28 + 0.44 * sin(u * PI) + 0.15 * sin(t * TAU * 3.0))
            tint.a = 0.74
            _quad(surface, _wave_point(across, along), _wave_point(across + 1, along),
                _wave_point(across + 1, along + 1), _wave_point(across, along + 1), tint)
    surface.generate_normals()
    var result := surface.commit()

    # Tall, asymmetric ice crests make the danger readable from the chase camera.
    # They share one surface/material and therefore need no per-spike draw calls.
    var crests := SurfaceTool.new()
    crests.begin(Mesh.PRIMITIVE_TRIANGLES)
    for side in [-1.0, 1.0]:
        for step in range(14):
            var t := (float(step) + 0.5) / 14.0
            var z := (t - 0.5) * 35.0
            var height := 0.65 + 0.58 * absf(sin(t * TAU * 3.5))
            var x := side * 1.08
            var root_front := Vector3(x, 0.13, z - 0.9)
            var root_back := Vector3(x, 0.13, z + 0.9)
            var tip := Vector3(side * 0.52, height, z + 0.25)
            var spine := Vector3(side * 1.27, height * 0.46, z)
            _quad(crests, root_front, tip, root_back, spine, Color(0.38, 0.94, 1.0, 0.86))
    crests.generate_normals()
    crests.commit(result)
    return result

func _material(tint: Color, glow: float) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = tint
    material.vertex_color_use_as_albedo = true
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    material.roughness = 0.24
    material.metallic = 0.18
    material.emission_enabled = true
    material.emission = Color("#48d8ff")
    material.emission_energy_multiplier = glow
    return material

func _ready() -> void:
    mesh = _wave_mesh()
    mesh.surface_set_material(0, _material(Color.WHITE, 1.1))
    mesh.surface_set_material(1, _material(Color.WHITE, 2.0))

func _process(delta: float) -> void:
    if not visible:
        return
    elapsed += delta
    scale = Vector3(1.0 + 0.035 * sin(elapsed * 6.0),
        0.90 + 0.20 * (0.5 + 0.5 * sin(elapsed * 9.0)), 1.0)
    position.y = 0.14 + 0.07 * sin(elapsed * 7.0)
