extends RefCounted
## Skyway V49: original, low-overhead ribbon surfaces for three abilities.
## Meshes are generated once on startup and animated as transforms, not rebuilt.
## No external textures, shaders, licensed models, or third-party assets.

static func _vertex(tool: SurfaceTool, point: Vector3, tint: Color) -> void:
    tool.set_color(tint)
    tool.add_vertex(point)

static func _quad(tool: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, near_color: Color, far_color: Color) -> void:
    _vertex(tool, a, near_color)
    _vertex(tool, b, far_color)
    _vertex(tool, c, far_color)
    _vertex(tool, a, near_color)
    _vertex(tool, c, far_color)
    _vertex(tool, d, near_color)

static func effect_material(tint: Color, opacity: float) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = Color(1.0, 1.0, 1.0, opacity)
    material.vertex_color_use_as_albedo = true
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    material.emission_enabled = true
    material.emission = tint
    material.emission_energy_multiplier = 1.65
    return material

static func _shield_point(theta: float, angle: float) -> Vector3:
    # A rippling energy dome with eight longitudinal luminous wave ridges.
    var radius: float = 1.34 + 0.045 * sin(angle * 8.0 + theta * 5.0)
    return Vector3(radius * sin(theta) * cos(angle), 1.36 * cos(theta), radius * sin(theta) * sin(angle))

static func shield_mesh() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    const LATITUDES := 24
    const LONGITUDES := 48
    for row in range(LATITUDES):
        var t0: float = PI * float(row) / float(LATITUDES)
        var t1: float = PI * float(row + 1) / float(LATITUDES)
        for column in range(LONGITUDES):
            var a0: float = TAU * float(column) / float(LONGITUDES)
            var a1: float = TAU * float(column + 1) / float(LONGITUDES)
            var light: float = 0.65 + 0.35 * pow(absf(cos(a0 * 4.0)), 12.0)
            var near_color := Color(0.08 * light, 0.86 * light, 1.0 * light, 0.42)
            var far_color := Color(0.26 * light, 0.43 * light, 1.0 * light, 0.32)
            _quad(tool, _shield_point(t0, a0), _shield_point(t1, a0), _shield_point(t1, a1), _shield_point(t0, a1), near_color, far_color)
    tool.generate_normals()
    return tool.commit()

static func _jump_point(progress: float, side: float, strand: int) -> Vector3:
    # Two corkscrewing energy trails rise around the rider on a Mega Jump.
    var angle: float = progress * TAU * 2.4 + float(strand) * PI
    var radius: float = 0.79 + 0.12 * sin(progress * TAU * 3.0)
    return Vector3(cos(angle) * (radius + side * 0.085), progress * 2.35, sin(angle) * (radius + side * 0.085))

static func jump_mesh() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    const STEPS := 100
    for strand in range(2):
        for step in range(STEPS):
            var t0: float = float(step) / float(STEPS)
            var t1: float = float(step + 1) / float(STEPS)
            var bright := Color(1.0, 0.93, 0.27, 0.92) if strand == 0 else Color(0.33, 0.96, 1.0, 0.92)
            var tip := Color(1.0, 0.36, 0.83, 0.55) if strand == 0 else Color(0.43, 0.45, 1.0, 0.55)
            _quad(tool, _jump_point(t0, -1.0, strand), _jump_point(t1, -1.0, strand), _jump_point(t1, 1.0, strand), _jump_point(t0, 1.0, strand), bright, tip)
    tool.generate_normals()
    return tool.commit()

static func _attack_point(angle: float, cross: float, layer: int) -> Vector3:
    # Three concentric, undulating plasma toroids radiate from the hero.
    var major: float = 0.90 + float(layer) * 0.22
    var minor: float = 0.065 + float(layer) * 0.014
    var radius: float = major + cos(cross) * minor
    var height: float = sin(cross) * minor + 0.14 * sin(angle * 5.0 + float(layer) * 1.8)
    return Vector3(radius * cos(angle), height, radius * sin(angle))

static func attack_mesh() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    const SEGMENTS := 60
    const SIDES := 10
    for layer in range(3):
        for step in range(SEGMENTS):
            var a0: float = TAU * float(step) / float(SEGMENTS)
            var a1: float = TAU * float(step + 1) / float(SEGMENTS)
            for side in range(SIDES):
                var c0: float = TAU * float(side) / float(SIDES)
                var c1: float = TAU * float(side + 1) / float(SIDES)
                var hot := Color(1.0, 0.21 + float(layer) * 0.13, 0.78, 0.90)
                var cool := Color(0.49, 0.25, 1.0, 0.68)
                _quad(tool, _attack_point(a0, c0, layer), _attack_point(a1, c0, layer), _attack_point(a1, c1, layer), _attack_point(a0, c1, layer), hot, cool)
    tool.generate_normals()
    return tool.commit()
