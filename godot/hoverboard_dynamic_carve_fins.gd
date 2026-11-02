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
    fin_material.metallic = 0.12
    fin_material.roughness = 0.70
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
        # Inset and lower the fin hinge so its sculpted fairing overlaps both
        # the chassis top and the aerofoil. The previous floating silhouette
        # was visually disconnected in actual landscape chase captures.
        # Visual only: the animated board root and collisions stay unchanged.
        hinge.position = Vector3(side * 0.99, 0.525, 0.22)
        add_child(hinge)
        # The closed mount now starts INSIDE the hull and terminates inside the
        # swept aerofoil near its 42% span. Earlier mounting ended short of
        # the fin, leaving a floating leaf in real landscape chase captures.
        var mount := MeshInstance3D.new()
        mount.name = "SculptedBoardMount"
        mount.mesh = _make_mount(side)
        mount.material_override = fin_material
        hinge.add_child(mount)
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

# Eight-sided swept mounting spar, integrated with each animated hinge.
# Its inboard root overlaps the sculpted hull; its tip enters the aerofoil.
# No new physics, texture, lights or separate animation is introduced.
func _mount_point(side: float, t: float, angle: float) -> Vector3:
    # Closed, tapered deck fairing. Its inboard root is embedded in the
    # original chassis top, while the outboard tip intersects the real
    # aerofoil around t=0.42 (same local Z, X and Y). No floating gap.
    # A brighter upper satin face makes the connection legible on phones.
    var sweep := sin(PI * t)
    var height_radius := 0.014 + 0.012 * sweep
    var chord_radius := 0.085 + 0.035 * sweep
    # Mold a raised, smoothly blended dorsal chine into the SAME closed
    # fairing surface. A circular tube made the deck-to-fin joint look like
    # an exposed pipe in the oblique landscape camera.
    var dorsal_chine := 0.022 * sweep * pow(maxf(0.0, cos(angle)), 4.0)
    return Vector3(
        lerpf(-side * 0.49, side * 0.20, t),
        lerpf(-0.18, 0.15, t) + 0.025 * sweep +
            height_radius * cos(angle) + dorsal_chine,
        lerpf(0.05, 0.01, t) + chord_radius * sin(angle))

# The mounting fairing climbs and sweeps sideways as it meets the aerofoil.
# Cylindrical (0, cos, sin) normals lit it like a separate straight pipe.
# Calculate the real curved-surface normal; no extra draw call or shader.
func _mount_normal(side: float, t: float, angle: float) -> Vector3:
    var h := 0.001
    var along := _mount_point(side, clampf(t + h, 0.0, 1.0), angle) - \
        _mount_point(side, clampf(t - h, 0.0, 1.0), angle)
    var around := _mount_point(side, t, angle + h) - \
        _mount_point(side, t, angle - h)
    var result := around.cross(along) * side
    if not result.is_finite() or result.length_squared() < 0.000001:
        return Vector3(0.0, cos(angle), sin(angle)).normalized()
    return result.normalized()

func _make_mount(side: float) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for segment in range(10):
        var t0 := float(segment) / 10.0
        var t1 := float(segment + 1) / 10.0
        for radial in range(10):
            var a0 := TAU * float(radial) / 10.0
            var a1 := TAU * float(radial + 1) / 10.0
            for sample in [Vector2(t0, a0), Vector2(t1, a0), Vector2(t1, a1),
                    Vector2(t0, a0), Vector2(t1, a1), Vector2(t0, a1)]:
                var angle: float = sample.y
                tool.set_normal(_mount_normal(side, sample.x, angle))
                var upper := maxf(0.0, cos(angle))
                var deck_tone := Color("#172d4b").lerp(Color("#638ea8"),
                    0.22 + 0.44 * upper)
                var wing_tone := Color("#536f89").lerp(Color("#b7d1e1"),
                    0.23 + 0.46 * upper)
                # Transition toward the existing aerofoil's satin composite
                # instead of ending the dark fairing in a bright hard seam.
                tool.set_color(deck_tone.lerp(wing_tone,
                    0.62 * smoothstep(0.56, 1.0, sample.x)))
                tool.add_vertex(_mount_point(side, sample.x, angle))
    for end in [0.0, 1.0]:
        var center := _mount_point(side, end, 0.0).lerp(
            _mount_point(side, end, PI), 0.5)
        for radial in range(10):
            var a0 := TAU * float(radial) / 10.0
            var a1 := TAU * float(radial + 1) / 10.0
            for p in [center,
                    _mount_point(side, end, a1 if end == 0.0 else a0),
                    _mount_point(side, end, a0 if end == 0.0 else a1)]:
                tool.set_normal(Vector3(-side, 0.0, 0.0) if end == 0.0 else Vector3(side, 0.0, 0.0))
                tool.set_color(Color("#263e5b"))
                tool.add_vertex(p)
    return tool.commit()

func _fin_point(side: float, t: float, angle: float) -> Vector3:
    # Longitudinal sweep and elliptical section form a genuine closed 3D wing.
    # Its deployed outer tip stays within the original 1.2-unit board profile.
    # The previous nearly flat vane was hard to distinguish from the deck.
    # A curved, rising aft crest now exposes a genuine swept 3D silhouette
    # during carving without adding geometry, materials or collisions.
    # The former near-constant chord at both tips read as a dark paddle in
    # the real 3/4 chase captures. A narrow root and swept trailing taper
    # give the stabilizer an aircraft-like pointed planform, not a shovel.
    var taper := pow(maxf(0.0, sin(PI * t)), 1.35)
    var center := 0.11 + 0.18 * t
    var half_span := 0.012 + 0.145 * taper
    var thickness := 0.010 + 0.030 * taper
    # Taller rearward-raked stabilizer trial: the aft tip rises clearly above
    # the traction deck in chase view, while the root remains tucked in.
    # Do not widen the chord: the prior broad silhouette looked like a paddle.
    var swept_lift := 0.025 + 0.075 * sin(PI * t) + 0.30 * t * t
    return Vector3(side * (center + half_span * cos(angle)),
        swept_lift + thickness * sin(angle),
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
    # Lighter satin composite keeps the lower surface readable in the
    # phone's oblique camera instead of becoming a black flat silhouette.
    tool.set_color(Color("#536f89").lerp(Color("#b7d1e1"),
        0.23 + 0.46 * upper + 0.10 * sin(PI * t)))
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
                tool.set_color(Color("#536f89"))
                tool.set_normal(Vector3.FORWARD if end == 0.0 else Vector3.BACK)
                tool.add_vertex(point)
    return tool.commit()

# The old two-triangle signal stripe was flat and disappeared in oblique
# lighting. A small, eight-sided luminous rail now hugs the sculpted upper
# crest in real 3D, with smooth analytic normals and tapered ends. Same mesh
# instance and draw-call budget; no new textures or collision.
func _edge_point(side: float, t: float, angle: float) -> Vector3:
    var center := _fin_point(side, t, PI * 0.5) + Vector3.UP * 0.006
    var radius := 0.009 + 0.018 * sin(PI * t)
    return center + Vector3(cos(angle) * radius, sin(angle) * radius, 0.0)

func _make_edge(side: float) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for i in range(LENGTH_SEGMENTS):
        var a := float(i) / float(LENGTH_SEGMENTS)
        var b := float(i + 1) / float(LENGTH_SEGMENTS)
        for j in range(8):
            var u := TAU * float(j) / 8.0
            var v := TAU * float(j + 1) / 8.0
            for sample in [Vector2(a, u), Vector2(b, u), Vector2(b, v),
                    Vector2(a, u), Vector2(b, v), Vector2(a, v)]:
                var angle: float = sample.y
                tool.set_normal(Vector3(cos(angle), sin(angle), 0.0))
                tool.add_vertex(_edge_point(side, sample.x, angle))
    # Close both narrow ends: the luminous trim is a volume, not a decal.
    for end in [0.0, 1.0]:
        var center := _fin_point(side, end, PI * 0.5) + Vector3.UP * 0.006
        for j in range(8):
            var u := TAU * float(j) / 8.0
            var v := TAU * float(j + 1) / 8.0
            for point in [center,
                    _edge_point(side, end, v if end == 0.0 else u),
                    _edge_point(side, end, u if end == 0.0 else v)]:
                tool.set_normal(Vector3.FORWARD if end == 0.0 else Vector3.BACK)
                tool.add_vertex(point)
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
        # A real two-axis articulated stabilizer: the outside wing rises,
        # slides slightly outboard and pitches into the airflow. This keeps
        # the whole closed 3D aerofoil readable in a landscape chase camera.
        # It is attached to the existing visual board; physics stays intact.
        var deployment := clampf(carve + (0.35 if boosting else 0.0), 0.0, 1.0)
        var target_height := 0.525 + 0.10 * deployment
        var target_outboard := side * (0.99 + 0.045 * carve)
        var target_pitch := -0.09 - 0.08 * carve - (0.035 if boosting else 0.0)
        fins[i].position.y = lerpf(fins[i].position.y, target_height, response)
        fins[i].position.x = lerpf(fins[i].position.x, target_outboard, response)
        fins[i].rotation.x = lerpf(fins[i].rotation.x, target_pitch, response)
        var edge_light := edge_materials[i]
        var target_energy := (2.3 if boosting else 1.1) + 1.55 * carve
        edge_light.emission_energy_multiplier = lerpf(
            edge_light.emission_energy_multiplier, target_energy, response)
        # Ease the hue too; instant cyan/magenta jumps made fast alternating
        # touch swipes look like flicker even while the fin motion was smooth.
        var target_color := Color("#25c7e9").lerp(Color("#c56cff"), carve * 0.65)
        edge_light.emission = edge_light.emission.lerp(target_color, response)
    edge_material.emission_energy_multiplier = lerpf(
        edge_material.emission_energy_multiplier,
        2.3 if boosting else 1.1, response)
