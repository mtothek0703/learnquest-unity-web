extends Node3D
## V116: continuous sculpted hoverboard chassis, top traction deck and curved
## edge-light rails. Procedural, no third-party assets or collision changes.
## The existing board node still owns all bob/roll/boost and jet animations.
const LENGTH_STEPS := 28
const RING_STEPS := 20
var built: bool = false
var chassis: MeshInstance3D
var grip: MeshInstance3D
var keel: MeshInstance3D
var rails: Array[MeshInstance3D] = []
var swept_wings: Array[MeshInstance3D] = []
var thruster_housings: Array[MeshInstance3D] = []
var thruster_cores: Array[MeshInstance3D] = []
var core_material: StandardMaterial3D
var rail_material: StandardMaterial3D
var wing_material: StandardMaterial3D
# Separate materials for existing port/starboard meshes make carve direction
# visible from the chase camera; no additional geometry or collision bodies.
var rail_materials: Array[StandardMaterial3D] = []
var carve_fins: Node3D

func _ready() -> void:
    var shell_material := StandardMaterial3D.new()
    shell_material.albedo_color = Color.WHITE
    shell_material.vertex_color_use_as_albedo = true
    shell_material.metallic = 0.44
    shell_material.roughness = 0.46
    shell_material.cull_mode = BaseMaterial3D.CULL_DISABLED
    var grip_material := StandardMaterial3D.new()
    grip_material.albedo_color = Color.WHITE
    grip_material.vertex_color_use_as_albedo = true
    grip_material.metallic = 0.22
    grip_material.roughness = 0.75
    grip_material.cull_mode = BaseMaterial3D.CULL_DISABLED
    # Closed side stabilizers are satin composite, not oversized glossy fins.
    wing_material = StandardMaterial3D.new()
    wing_material.albedo_color = Color.WHITE
    wing_material.vertex_color_use_as_albedo = true
    wing_material.metallic = 0.34
    wing_material.roughness = 0.61
    wing_material.cull_mode = BaseMaterial3D.CULL_DISABLED
    rail_material = StandardMaterial3D.new()
    rail_material.albedo_color = Color("#42cce8")
    rail_material.emission_enabled = true
    rail_material.emission = Color("#1dbcf5")
    rail_material.emission_energy_multiplier = 1.25
    rail_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    rail_material.cull_mode = BaseMaterial3D.CULL_DISABLED
    core_material = StandardMaterial3D.new()
    core_material.albedo_color = Color("#62dff7")
    core_material.emission_enabled = true
    core_material.emission = Color("#16c9ff")
    core_material.emission_energy_multiplier = 1.6
    core_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    core_material.cull_mode = BaseMaterial3D.CULL_DISABLED
    chassis = _attach("ContinuousAerodynamicChassis", _make_shell(), shell_material)
    grip = _attach("ContouredTractionDeck", _make_grip(), grip_material)
    keel = _attach("UndersideKeel", _make_keel(), shell_material)
    for side in [-1.0, 1.0]:
        var side_rail_material := rail_material.duplicate() as StandardMaterial3D
        rail_materials.append(side_rail_material)
        var rail := _attach("PortEdgeLight" if side < 0.0 else "StarboardEdgeLight",
            _make_rail(side), side_rail_material)
        rails.append(rail)
        swept_wings.append(_attach("PortSculptedAeroWing" if side < 0.0 else "StarboardSculptedAeroWing",
            _make_wing(side), wing_material))
        thruster_housings.append(_attach("PortSculptedTurbine" if side < 0.0 else "StarboardSculptedTurbine",
            _make_thruster_housing(side), shell_material))
        thruster_cores.append(_attach("PortExhaustHalo" if side < 0.0 else "StarboardExhaustHalo",
            _make_exhaust_halo(side), core_material))
    built = chassis != null and grip != null and keel != null and rails.size() == 2 and swept_wings.size() == 2 and thruster_housings.size() == 2 and thruster_cores.size() == 2
    if built:
        for part in [chassis, grip, keel] + rails + swept_wings + thruster_housings + thruster_cores:
            if part.mesh == null or part.mesh.get_surface_count() == 0:
                built = false
    if built:
        # Volumetric action trails are visual children of the existing board.
        # They never replace its physics, touch controls or original turbines.
        var wake := preload("res://hoverboard_boost_wake.gd").new() as Node3D
        wake.name = "BoostWake"
        add_child(wake)
        carve_fins = preload("res://hoverboard_dynamic_carve_fins.gd").new() as Node3D
        carve_fins.name = "ArticulatedCarveFins"
        add_child(carve_fins)

func _process(delta: float) -> void:
    if not built:
        return
    var controller := get_parent().get_parent() as Node3D
    if controller == null:
        return
    var boost := bool(controller.get("boosting"))
    # Exponential response is time-based: 30/60/120 FPS smartphones show the
    # same boost and carve glow over the same elapsed time.
    var response := 1.0 - exp(-12.0 * maxf(delta, 0.0))
    rail_material.emission_energy_multiplier = lerpf(
        rail_material.emission_energy_multiplier, 3.0 if boost else 1.25, response)
    core_material.emission_energy_multiplier = lerpf(
        core_material.emission_energy_multiplier, 5.0 if boost else 1.6, response)
    # A turn brightens the outside rail, while the original shared exhaust
    # and boost response stay unchanged. Use existing mobile-safe materials.
    var lean := clampf(float(controller.get("lean")), -1.0, 1.0)
    for i in range(rail_materials.size()):
        var side := -1.0 if i == 0 else 1.0
        var turn_strength := maxf(0.0, side * lean)
        var material := rail_materials[i]
        var target_energy := (3.0 if boost else 1.25) + turn_strength * 1.40
        material.emission_energy_multiplier = lerpf(
            material.emission_energy_multiplier, target_energy, response)
        material.emission = Color("#1dbcf5").lerp(Color("#cf4df7"), turn_strength * 0.68)
    if carve_fins != null:
        carve_fins.call("update_state", lean, boost, delta)

func _attach(part_name: String, mesh: ArrayMesh, material: Material) -> MeshInstance3D:
    if mesh == null or mesh.get_surface_count() == 0:
        return null
    var part := MeshInstance3D.new()
    part.name = part_name
    part.mesh = mesh
    part.material_override = material
    add_child(part)
    return part

func _half_width(t: float) -> float:
    # Narrow arrowhead at the front, broad stable mid-deck, trimmed rear.
    var nose := smoothstep(0.0, 0.28, t)
    var tail := smoothstep(0.78, 1.0, t)
    return 0.77 * (0.48 + 0.52 * nose) * (1.0 - 0.16 * tail)

func _shell_point(t: float, angle: float) -> Vector3:
    var z := lerpf(-1.37, 1.33, t)
    var width := _half_width(t)
    var raised_nose := 0.07 * (1.0 - smoothstep(0.0, 0.30, t))
    var rear_sweep := 0.025 * smoothstep(0.76, 1.0, t)
    var thickness := 0.105 + 0.025 * sin(PI * t)
    return Vector3(width * cos(angle),
        0.285 + raised_nose + rear_sweep + thickness * sin(angle), z)

# Analytic normals follow the actual swept chassis instead of treating every
# unindexed triangle as a separate flat facet. This preserves highlights along
# the entire 360-degree hull without additional meshes or mobile draw calls.
func _shell_normal(t: float, angle: float) -> Vector3:
    var h := 0.001
    var tangent_t := _shell_point(clampf(t + h, 0.0, 1.0), angle) - \
        _shell_point(clampf(t - h, 0.0, 1.0), angle)
    var tangent_ring := _shell_point(t, angle + h) - _shell_point(t, angle - h)
    return tangent_ring.cross(tangent_t).normalized()

func _emit_shell(tool: SurfaceTool, t: float, angle: float) -> void:
    var edge := absf(cos(angle))
    var upper := maxf(0.0, sin(angle))
    # Smooth normals need a brighter satin base than the former flat-facet specular.
    # Keep the underside dark but restore legibility in the chase camera.
    var color := Color("#283956").lerp(Color("#7089a8"), upper * 0.65)
    color = color.lerp(Color("#586c90"), edge * (0.14 + 0.20 * t))
    tool.set_color(color)
    tool.set_normal(_shell_normal(t, angle))
    tool.add_vertex(_shell_point(t, angle))

func _emit_shell_cap(tool: SurfaceTool, end: float, angle: float) -> void:
    # Duplicate the perimeter only for the hard cap normal; the curved
    # chassis surface keeps its own smooth analytic normal at the same point.
    tool.set_color(Color("#283956"))
    tool.set_normal(Vector3.FORWARD if end == 0.0 else Vector3.BACK)
    tool.add_vertex(_shell_point(end, angle))

func _make_shell() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for i in range(LENGTH_STEPS):
        var a := float(i) / float(LENGTH_STEPS)
        var b := float(i + 1) / float(LENGTH_STEPS)
        for j in range(RING_STEPS):
            var u := TAU * float(j) / float(RING_STEPS)
            var v := TAU * float(j + 1) / float(RING_STEPS)
            _emit_shell(tool, a, u)
            _emit_shell(tool, b, u)
            _emit_shell(tool, b, v)
            _emit_shell(tool, a, u)
            _emit_shell(tool, b, v)
            _emit_shell(tool, a, v)
    # Close both ends: the replacement is a genuine 360-degree volume.
    for end in [0.0, 1.0]:
        for j in range(RING_STEPS):
            var u := TAU * float(j) / float(RING_STEPS)
            var v := TAU * float(j + 1) / float(RING_STEPS)
            tool.set_color(Color("#283956"))
            tool.set_normal(Vector3.FORWARD if end == 0.0 else Vector3.BACK)
            tool.add_vertex(Vector3(0.0, _shell_point(end, 0.0).y, lerpf(-1.37, 1.33, end)))
            _emit_shell_cap(tool, end, v if end == 0.0 else u)
            _emit_shell_cap(tool, end, u if end == 0.0 else v)
    return tool.commit()

# Two molded traction footbeds and a recessed center channel are sculpted
# into the SAME deck surface (no extra draw calls, collision or input changes).
# Taper the relief to zero near the nose/tail to avoid hard raised edges.
func _grip_relief_fade(t: float) -> float:
    return smoothstep(0.16, 0.32, t) * (1.0 - smoothstep(0.68, 0.84, t))

func _grip_footbed(t: float, across: float) -> float:
    var lateral := (absf(across) - 0.55) / 0.27
    return exp(-lateral * lateral) * _grip_relief_fade(t)

func _grip_channel(t: float, across: float) -> float:
    var lateral := across / 0.20
    return exp(-lateral * lateral) * _grip_relief_fade(t)

func _grip_point(t: float, across: float) -> Vector3:
    var z := lerpf(-0.96, 0.95, t)
    var deck_t := (z + 1.37) / 2.70
    var width := _half_width(deck_t) * 0.65
    var relief := 0.035 * _grip_footbed(t, across) - 0.018 * _grip_channel(t, across)
    return Vector3(across * width,
        0.415 + 0.022 * (1.0 - across * across) + 0.012 * cos(PI * t) + relief, z)

func _grip_normal(t: float, across: float) -> Vector3:
    var h := 0.001
    var tangent_t := _grip_point(clampf(t + h, 0.0, 1.0), across) - \
        _grip_point(clampf(t - h, 0.0, 1.0), across)
    var tangent_across := _grip_point(t, clampf(across + h, -1.0, 1.0)) - \
        _grip_point(t, clampf(across - h, -1.0, 1.0))
    return tangent_t.cross(tangent_across).normalized()

func _emit_grip(tool: SurfaceTool, t: float, across: float) -> void:
    var footbed := _grip_footbed(t, across)
    var channel := _grip_channel(t, across)
    # The raised pads read as satin rubber; the recessed central channel stays dark.
    var tone := clampf(0.22 + 0.52 * footbed - 0.18 * channel, 0.0, 1.0)
    tool.set_color(Color("#1b2944").lerp(Color("#5e8092"), tone))
    tool.set_normal(_grip_normal(t, across))
    tool.add_vertex(_grip_point(t, across))

func _make_grip() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for i in range(24):
        var a := float(i) / 24.0
        var b := float(i + 1) / 24.0
        for j in range(8):
            var u := -1.0 + float(j) / 4.0
            var v := -1.0 + float(j + 1) / 4.0
            _emit_grip(tool, a, u)
            _emit_grip(tool, b, v)
            _emit_grip(tool, b, u)
            _emit_grip(tool, a, u)
            _emit_grip(tool, a, v)
            _emit_grip(tool, b, v)
    return tool.commit()

func _keel_point(t: float, across: float) -> Vector3:
    var z := lerpf(-1.18, 1.13, t)
    var bow := 1.0 - smoothstep(0.0, 0.25, t)
    return Vector3(across * (0.15 + 0.06 * sin(PI * t)),
        0.13 - 0.09 * (1.0 - absf(across)) + 0.035 * bow, z)

func _make_keel() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for i in range(24):
        var a := float(i) / 24.0
        var b := float(i + 1) / 24.0
        for j in range(6):
            var u := -1.0 + float(j) / 3.0
            var v := -1.0 + float(j + 1) / 3.0
            for point in [_keel_point(a, u), _keel_point(b, u), _keel_point(b, v),
                _keel_point(a, u), _keel_point(b, v), _keel_point(a, v)]:
                tool.set_color(Color("#18264a").lerp(Color("#5775a0"), 0.3 + 0.3 * absf(u)))
                tool.add_vertex(point)
    tool.generate_normals()
    return tool.commit()

func _rail_point(side: float, t: float, offset: float) -> Vector3:
    var width := _half_width(t)
    return Vector3(side * (width * 0.97 + offset),
        _shell_point(t, PI * 0.24).y + 0.004, lerpf(-1.30, 1.27, t))

func _make_rail(side: float) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for i in range(28):
        var a := float(i) / 28.0
        var b := float(i + 1) / 28.0
        for point in [_rail_point(side, a, -0.016), _rail_point(side, b, -0.016),
            _rail_point(side, b, 0.016), _rail_point(side, a, -0.016),
            _rail_point(side, b, 0.016), _rail_point(side, a, 0.016)]:
            tool.add_vertex(point)
    tool.generate_normals()
    return tool.commit()

func _wing_point(side: float, t: float, angle: float) -> Vector3:
    # V124 compact, swept stabilizer integrated into the board silhouette.
    # Keep the existing animated board root, physics and touch controls.
    var swell := pow(maxf(0.0, sin(PI * t)), 1.15)
    var z := lerpf(-1.05, 0.97, t)
    var inner := 0.70 + 0.055 * swell
    var outer := 0.92 + 0.25 * swell + 0.04 * t
    var center := (inner + outer) * 0.5
    var radius := (outer - inner) * 0.5
    var curl := 0.065 * smoothstep(0.70, 1.0, t)
    return Vector3(side * (center + radius * cos(angle)),
        0.295 + curl + (0.035 + 0.022 * swell) * sin(angle), z)

func _wing_normal(side: float, t: float, angle: float) -> Vector3:
    var h := 0.001
    var tangent_t := _wing_point(side, clampf(t + h, 0.0, 1.0), angle) - \
        _wing_point(side, clampf(t - h, 0.0, 1.0), angle)
    var tangent_ring := _wing_point(side, t, angle + h) - \
        _wing_point(side, t, angle - h)
    # Mirrored stabilizers must retain outward-facing normals on both sides.
    return (tangent_ring.cross(tangent_t) * side).normalized()

func _make_wing(side: float) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for i in range(24):
        var a := float(i) / 24.0
        var b := float(i + 1) / 24.0
        for j in range(12):
            var u := TAU * float(j) / 12.0
            var v := TAU * float(j + 1) / 12.0
            for sample in [Vector2(a, u), Vector2(b, u), Vector2(b, v),
                Vector2(a, u), Vector2(b, v), Vector2(a, v)]:
                var point := _wing_point(side, sample.x, sample.y)
                var highlight := maxf(0.0, sin(sample.y))
                tool.set_color(Color("#152640").lerp(Color("#56718a"),
                    0.18 + 0.35 * highlight + 0.07 * sin(PI * sample.x)))
                tool.set_normal(_wing_normal(side, sample.x, sample.y))
                tool.add_vertex(point)
    # Both aerofoil ends now have real 3D caps, avoiding open tubular wings.
    for end in [0.0, 1.0]:
        var outer_point := _wing_point(side, end, 0.0)
        var inner_point := _wing_point(side, end, PI)
        var cap_center := (outer_point + inner_point) * 0.5
        for j in range(12):
            var u := TAU * float(j) / 12.0
            var v := TAU * float(j + 1) / 12.0
            for point in [cap_center,
                _wing_point(side, end, v if end == 0.0 else u),
                _wing_point(side, end, u if end == 0.0 else v)]:
                tool.set_color(Color("#20334e"))
                tool.set_normal(Vector3.FORWARD if end == 0.0 else Vector3.BACK)
                tool.add_vertex(point)
    return tool.commit()


# V124 integrated propulsion: two genuinely volumetric, swept turbine housings
# and toroidal exhaust halos. Both are children of the existing animated board,
# so leaning, hovering, jumping and boost retain their original gameplay path.
# Geometry and materials are original procedural work; no external asset.
func _thruster_point(side: float, t: float, angle: float) -> Vector3:
    var z := lerpf(0.42, 1.55, t)
    var swell := pow(maxf(0.0, sin(PI * t)), 0.75)
    var radius := 0.115 + 0.145 * swell + 0.035 * smoothstep(0.68, 1.0, t)
    var center_x := side * (0.80 + 0.08 * t)
    return Vector3(center_x + radius * cos(angle),
        0.24 + radius * 0.82 * sin(angle), z)

func _thruster_normal(side: float, t: float, angle: float) -> Vector3:
    var h := 0.001
    var tangent_t := _thruster_point(side, clampf(t + h, 0.0, 1.0), angle) - \
        _thruster_point(side, clampf(t - h, 0.0, 1.0), angle)
    var tangent_ring := _thruster_point(side, t, angle + h) - \
        _thruster_point(side, t, angle - h)
    return tangent_ring.cross(tangent_t).normalized()

func _make_thruster_housing(side: float) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for i in range(24):
        var a := float(i) / 24.0
        var b := float(i + 1) / 24.0
        for j in range(16):
            var u := TAU * float(j) / 16.0
            var v := TAU * float(j + 1) / 16.0
            for sample in [Vector2(a, u), Vector2(b, u), Vector2(b, v),
                Vector2(a, u), Vector2(b, v), Vector2(a, v)]:
                var upper := maxf(0.0, sin(sample.y))
                var accent := smoothstep(0.66, 0.94, sample.x)
                tool.set_color(Color("#17213d").lerp(Color("#647ca6"),
                    0.20 + 0.48 * upper + 0.20 * accent))
                tool.set_normal(_thruster_normal(side, sample.x, sample.y))
                tool.add_vertex(_thruster_point(side, sample.x, sample.y))
    # End caps make each turbine a real closed volume, not a decorative plane.
    for end in [0.0, 1.0]:
        var edge := _thruster_point(side, end, 0.0)
        var center := Vector3(side * (0.80 + 0.08 * end), 0.24, edge.z)
        for j in range(16):
            var u := TAU * float(j) / 16.0
            var v := TAU * float(j + 1) / 16.0
            for point in [center,
                _thruster_point(side, end, v if end == 0.0 else u),
                _thruster_point(side, end, u if end == 0.0 else v)]:
                tool.set_color(Color("#283956"))
                tool.set_normal(Vector3.FORWARD if end == 0.0 else Vector3.BACK)
                tool.add_vertex(point)
    return tool.commit()

func _exhaust_halo_point(side: float, around: float, section: float) -> Vector3:
    var radius := 0.153 + 0.023 * cos(section)
    return Vector3(side * 0.88 + radius * cos(around),
        0.24 + radius * sin(around), 1.58 + 0.023 * sin(section))

func _make_exhaust_halo(side: float) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for i in range(32):
        var a := TAU * float(i) / 32.0
        var b := TAU * float(i + 1) / 32.0
        for j in range(8):
            var u := TAU * float(j) / 8.0
            var v := TAU * float(j + 1) / 8.0
            for point in [_exhaust_halo_point(side, a, u),
                _exhaust_halo_point(side, b, u),
                _exhaust_halo_point(side, b, v),
                _exhaust_halo_point(side, a, u),
                _exhaust_halo_point(side, b, v),
                _exhaust_halo_point(side, a, v)]:
                tool.add_vertex(point)
    tool.generate_normals()
    return tool.commit()
