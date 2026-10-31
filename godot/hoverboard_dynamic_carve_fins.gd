extends Node3D
## Experimental CC0 rider board: articulated, closed aerofoil carve vanes.
## Both fins are procedural and share the original animated hoverboard root.
## No collision, touch, physics, or imported assets are changed.
const LENGTH_SEGMENTS := 22
const SECTION_SEGMENTS := 12
var fins: Array[Node3D] = []
var fin_material: StandardMaterial3D
var edge_material: StandardMaterial3D
var edge_materials: Array[StandardMaterial3D] = []
var ready_to_animate: bool = false

func _ready() -> void:
    fin_material = StandardMaterial3D.new()
    fin_material.albedo_color = Color.WHITE
    fin_material.vertex_color_use_as_albedo = true
    fin_material.metallic = 0.27
    fin_material.roughness = 0.53
    fin_material.cull_mode = BaseMaterial3D.CULL_DISABLED
    edge_material = StandardMaterial3D.new()
    edge_material.albedo_color = Color("#53d9ed")
    edge_material.emission_enabled = true
    edge_material.emission = Color("#25c7e9")
    edge_material.emission_energy_multiplier = 1.1
    edge_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    edge_material.cull_mode = BaseMaterial3D.CULL_DISABLED
    for side in [-1.0, 1.0]:
        var hinge := Node3D.new()
        hinge.name = "PortArticulatedVane" if side < 0.0 else "StarboardArticulatedVane"
        # The former hinge was buried inside the 1.2-unit sculpted side wing:
        # zero visible pixels changed in the actual rear chase camera. Mount
        # this closed aerofoil on the outboard upper chine, slightly aft, so
        # the deployed wing and emissive edge contribute to the board outline.
        # Visual only: the animated board root and collisions stay unchanged.
        hinge.position = Vector3(side * 1.09, 0.59, 0.22)
        add_child(hinge)
        var aerofoil := MeshInstance3D.new()
        aerofoil.name = "ClosedSweptAerofoil"
        aerofoil.mesh = _make_aerofoil(side)
        aerofoil.material_override = fin_material
        hinge.add_child(aerofoil)
        var edge := MeshInstance3D.new()
        edge.name = "CurvedSignalEdge"
        edge.mesh = _make_edge(side)
        # Each outboard signal edge reacts to its own steering side.
        # Reuse the same two existing meshes: no new draw calls or collision.
        var side_edge_material := edge_material.duplicate() as StandardMaterial3D
        edge_materials.append(side_edge_material)
        edge.material_override = side_edge_material
        hinge.add_child(edge)
        fins.append(hinge)
    ready_to_animate = fins.size() == 2

func _fin_point(side: float, t: float, angle: float) -> Vector3:
    # Longitudinal sweep and elliptical section form a genuine closed 3D wing.
    # Its deployed outer tip stays within the original 1.2-unit board profile.
    var taper := pow(maxf(0.0, sin(PI * t)), 0.85)
    var center := 0.105 + 0.085 * t
    var half_span := 0.045 + 0.125 * taper
    var thickness := 0.012 + 0.028 * taper
    return Vector3(side * (center + half_span * cos(angle)),
        0.014 + 0.018 * t + thickness * sin(angle),
        lerpf(-0.62, 0.87, t))

# Analytic normals are shared by coincident triangle vertices. The old
# SurfaceTool.generate_normals() gave every unindexed triangle a separate
# flat normal, producing distracting faceted highlights during steering.
# Preserve hard end-cap normals; only the swept shell is smooth.
func _fin_normal(side: float, t: float, angle: float) -> Vector3:
    var h := 0.001
    var tangent_t := _fin_point(side, clampf(t + h, 0.0, 1.0), angle) - \
        _fin_point(side, clampf(t - h, 0.0, 1.0), angle)
    var tangent_ring := _fin_point(side, t, angle + h) - \
        _fin_point(side, t, angle - h)
    return (tangent_ring.cross(tangent_t) * side).normalized()

func _emit_fin(tool: SurfaceTool, side: float, t: float, angle: float) -> void:
    var upper := maxf(0.0, sin(angle))
    tool.set_color(Color("#1c2e4b").lerp(Color("#6886a3"),
        0.16 + 0.50 * upper + 0.12 * sin(PI * t)))
    tool.set_normal(_fin_normal(side, t, angle))
    tool.add_vertex(_fin_point(side, t, angle))

func _make_aerofoil(side: float) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for i in range(LENGTH_SEGMENTS):
        var a := float(i) / float(LENGTH_SEGMENTS)
        var b := float(i + 1) / float(LENGTH_SEGMENTS)
        for j in range(SECTION_SEGMENTS):
            var u := TAU * float(j) / float(SECTION_SEGMENTS)
            var v := TAU * float(j + 1) / float(SECTION_SEGMENTS)
            for sample in [Vector2(a, u), Vector2(b, u), Vector2(b, v),
                Vector2(a, u), Vector2(b, v), Vector2(a, v)]:
                _emit_fin(tool, side, sample.x, sample.y)
    # Both ends are capped; unlike a decal, the aerofoil has real thickness.
    for end in [0.0, 1.0]:
        var center := _fin_point(side, end, 0.0).lerp(_fin_point(side, end, PI), 0.5)
        for j in range(SECTION_SEGMENTS):
            var u := TAU * float(j) / float(SECTION_SEGMENTS)
            var v := TAU * float(j + 1) / float(SECTION_SEGMENTS)
            for point in [center,
                _fin_point(side, end, v if end == 0.0 else u),
                _fin_point(side, end, u if end == 0.0 else v)]:
                tool.set_color(Color("#253956"))
                tool.set_normal(Vector3.FORWARD if end == 0.0 else Vector3.BACK)
                tool.add_vertex(point)
    return tool.commit()

func _make_edge(side: float) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for i in range(LENGTH_SEGMENTS):
        var a := float(i) / float(LENGTH_SEGMENTS)
        var b := float(i + 1) / float(LENGTH_SEGMENTS)
        for sample in [Vector2(a, PI * 0.40), Vector2(b, PI * 0.40),
            Vector2(b, PI * 0.60), Vector2(a, PI * 0.40),
            Vector2(b, PI * 0.60), Vector2(a, PI * 0.60)]:
            tool.add_vertex(_fin_point(side, sample.x, sample.y) + Vector3.UP * 0.003)
    tool.generate_normals()
    return tool.commit()

func update_state(lean: float, boosting: bool, delta: float) -> void:
    if not ready_to_animate:
        return
    # Frame-time smoothing avoids different deployment at 30/60/120 FPS.
    var response := 1.0 - exp(-9.0 * maxf(delta, 0.0))
    for i in range(2):
        var side := -1.0 if i == 0 else 1.0
        var carve := maxf(0.0, side * clampf(lean, -1.0, 1.0))
        var angle := side * (0.045 + 0.42 * carve + (0.12 if boosting else 0.0))
        fins[i].rotation.z = lerpf(fins[i].rotation.z, angle, response)
        var edge_light := edge_materials[i]
        var target_energy := (2.3 if boosting else 1.1) + 1.55 * carve
        edge_light.emission_energy_multiplier = lerpf(
            edge_light.emission_energy_multiplier, target_energy, response)
        edge_light.emission = Color("#25c7e9").lerp(Color("#c56cff"), carve * 0.65)
    edge_material.emission_energy_multiplier = lerpf(
        edge_material.emission_energy_multiplier,
        2.3 if boosting else 1.1, response)
