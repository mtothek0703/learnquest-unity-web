extends Node3D
## V50: sculpted, shader-free hero presentation for the world/level menu.
## All geometry and colors are original; no external asset or runtime download.
## The gallery is purely visual and disappears during races.

var floor_halo: MeshInstance3D
var backdrop: MeshInstance3D
var clock := 0.0

func _ready() -> void:
    var material := StandardMaterial3D.new()
    material.albedo_color = Color(1.0, 1.0, 1.0, 0.72)
    material.vertex_color_use_as_albedo = true
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    material.emission_enabled = true
    material.emission = Color(0.17, 0.48, 0.68)
    material.emission_energy_multiplier = 1.35

    floor_halo = MeshInstance3D.new()
    floor_halo.name = "Layered luminous landing rings"
    floor_halo.mesh = _make_floor_halo()
    floor_halo.material_override = material
    add_child(floor_halo)

    backdrop = MeshInstance3D.new()
    backdrop.name = "Sculpted cinematic light arches"
    backdrop.mesh = _make_arches()
    backdrop.material_override = material
    add_child(backdrop)

func _process(delta: float) -> void:
    if not visible:
        return
    clock += delta
    floor_halo.rotation.y = clock * 0.12
    backdrop.rotation.y = sin(clock * 0.45) * 0.075
    backdrop.position.y = sin(clock * 0.7) * 0.045

func _quad(tool: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, tint_a: Color, tint_b: Color) -> void:
    tool.set_color(tint_a)
    tool.add_vertex(a)
    tool.set_color(tint_b)
    tool.add_vertex(b)
    tool.set_color(tint_b)
    tool.add_vertex(c)
    tool.set_color(tint_a)
    tool.add_vertex(a)
    tool.set_color(tint_b)
    tool.add_vertex(c)
    tool.set_color(tint_a)
    tool.add_vertex(d)

func _make_floor_halo() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    const SEGMENTS := 80
    for band in range(3):
        var inner: float = 1.20 + float(band) * 0.31
        var outer: float = inner + (0.16 if band == 0 else 0.07)
        var height: float = 0.10 + float(band) * 0.018
        for segment in range(SEGMENTS):
            var t0: float = TAU * float(segment) / float(SEGMENTS)
            var t1: float = TAU * float(segment + 1) / float(SEGMENTS)
            var glow: float = 0.75 + 0.25 * sin(t0 * 8.0 + float(band))
            var inner_tint := Color(0.04, 0.78 * glow, 1.0, 0.45)
            var outer_tint := Color(0.68 * glow, 0.24, 1.0, 0.16)
            _quad(tool,
                Vector3(cos(t0) * inner, height, sin(t0) * inner),
                Vector3(cos(t1) * inner, height, sin(t1) * inner),
                Vector3(cos(t1) * outer, height, sin(t1) * outer),
                Vector3(cos(t0) * outer, height, sin(t0) * outer),
                inner_tint, outer_tint)
    return tool.commit()

func _arch_point(t: float, radius: float, height: float, z: float) -> Vector3:
    return Vector3(cos(t) * radius, 0.48 + sin(t) * height, z + 0.12 * sin(t * 3.0))

func _make_arches() -> ArrayMesh:
    # Broad layered light ribbons form a coherent silhouette around the hero.
    # Placed behind the face when viewed from the front (-Z).
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    const STEPS := 96
    for band in range(3):
        var radius: float = 2.05 + float(band) * 0.18
        var height: float = 4.00 + float(band) * 0.18
        var depth: float = 1.10 + float(band) * 0.15
        var width: float = 0.13 if band == 0 else 0.055
        for segment in range(STEPS):
            var t0: float = PI * float(segment) / float(STEPS)
            var t1: float = PI * float(segment + 1) / float(STEPS)
            var fade: float = 0.45 + 0.55 * sin((t0 + t1) * 0.5)
            var bright := Color(0.05, 0.86, 1.0, 0.80 * fade) if band != 1 else Color(1.0, 0.32, 0.77, 0.72 * fade)
            var edge := Color(0.25, 0.19, 0.95, 0.16 * fade)
            _quad(tool,
                _arch_point(t0, radius, height, depth),
                _arch_point(t1, radius, height, depth),
                _arch_point(t1, radius + width, height + width, depth),
                _arch_point(t0, radius + width, height + width, depth),
                bright, edge)
    return tool.commit()
