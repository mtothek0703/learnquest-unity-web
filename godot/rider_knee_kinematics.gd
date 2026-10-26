extends Node3D
## Skyway V92: independent knee and ankle posing on both rider legs.
## The original sculpted boots, knee guards and hoverboard remain in place;
## only visual nodes move. No collisions, touch controls or physics changes.
@export var side_sign: float = 1.0

const SHIN_ROWS := 16
const SHIN_SIDES := 20
var elapsed: float = 0.0
var knee_joint: Node3D
var hover_boot: Node3D
var glow_material: StandardMaterial3D

func _ready() -> void:
    hover_boot = get_parent().get_node_or_null("SculptedHoverBoot") as Node3D
    _build_knee()
    # The existing shin and light band now follow the actual lower-leg hinge,
    # rather than remaining rigidly attached to the thigh.
    var old_shin := get_parent().get_node_or_null("LegacyShin") as MeshInstance3D
    if old_shin != null:
        old_shin.reparent(knee_joint, false)
        old_shin.position = Vector3(0.0, 0.10, 0.0)
    var ankle_light := get_parent().get_node_or_null("LegacyAnkleBand") as MeshInstance3D
    if ankle_light != null:
        ankle_light.reparent(knee_joint, false)
        ankle_light.position = Vector3(0.0, -0.06, 0.16)

func _process(delta: float) -> void:
    if knee_joint == null or hover_boot == null:
        return
    elapsed += delta
    var rider := get_parent().get_parent().get_parent() as Node3D
    if rider == null:
        return
    var steering := clampf(float(rider.get("lean")), -1.0, 1.0)
    var turbo := bool(rider.get("boosting"))
    var air := clampf(rider.position.y / 1.25, 0.0, 1.0)
    # Two independent lower-leg hinges respond to acceleration, cornering and
    # airtime. The opposite roll makes a deliberate, readable balance stance.
    var bend := 0.06 + (0.21 if turbo else 0.0) + 0.53 * air + absf(steering) * 0.12
    bend += sin(elapsed * (8.0 if turbo else 3.1) + side_sign) * 0.016
    var bank := side_sign * (0.04 + 0.17 * air) - steering * 0.17
    var weight := minf(1.0, delta * 9.0)
    knee_joint.rotation.x = lerpf(knee_joint.rotation.x, bend, weight)
    knee_joint.rotation.z = lerpf(knee_joint.rotation.z, bank, weight)
    # Preserve the original boot's parent path (its glow script relies on it).
    # The ankle follows the knee's actual hinge position, not just a rotation
    # around the boot's own center.
    var ankle_offset := Vector3(0.0, -0.16, -0.10)
    hover_boot.position = knee_joint.position + knee_joint.basis * ankle_offset
    hover_boot.rotation.x = knee_joint.rotation.x
    hover_boot.rotation.z = knee_joint.rotation.z
    if glow_material != null:
        glow_material.emission_energy_multiplier = 1.3 + (0.8 if turbo else 0.15) * (0.65 + 0.35 * sin(elapsed * 7.0))

func _fabric() -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color.WHITE
    mat.vertex_color_use_as_albedo = true
    mat.metallic = 0.42
    mat.roughness = 0.36
    mat.cull_mode = BaseMaterial3D.CULL_DISABLED
    return mat

func _neon() -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color("#9beeff")
    mat.emission_enabled = true
    mat.emission = Color("#45cfff")
    mat.emission_energy_multiplier = 1.3
    mat.cull_mode = BaseMaterial3D.CULL_DISABLED
    return mat

func _build_knee() -> void:
    var fabric := _fabric()
    glow_material = _neon()
    knee_joint = Node3D.new()
    knee_joint.name = "ArticulatedKnee"
    knee_joint.position = Vector3(0.0, -0.33, 0.02)
    add_child(knee_joint)
    var socket := MeshInstance3D.new()
    socket.name = "ShadedKneeSocket"
    var sphere := SphereMesh.new()
    sphere.radius = 0.18
    sphere.height = 0.29
    sphere.radial_segments = 18
    sphere.rings = 10
    socket.mesh = sphere
    socket.material_override = fabric
    knee_joint.add_child(socket)
    var armor := MeshInstance3D.new()
    armor.name = "SculptedShinArmor"
    armor.mesh = _shin_mesh()
    armor.material_override = fabric
    knee_joint.add_child(armor)
    var trim := MeshInstance3D.new()
    trim.name = "LuminousKneeRings"
    trim.mesh = _ring_mesh()
    trim.material_override = glow_material
    knee_joint.add_child(trim)

func _shin_point(t: float, angle: float, extra: float = 0.0) -> Vector3:
    var radius := lerpf(0.175, 0.125, t) + 0.012 * sin(t * PI) + extra
    return Vector3(
        cos(angle) * radius,
        0.06 - 0.33 * t,
        0.025 + sin(angle) * radius * 0.88 + 0.03 * sin(t * PI)
    )

func _vertex(tool: SurfaceTool, point: Vector3, t: float) -> void:
    var shade := Color("#242650").lerp(Color("#a66de0"), 0.24 + 0.54 * (1.0 - t))
    tool.set_color(shade)
    tool.add_vertex(point)

func _shin_mesh() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for row in range(SHIN_ROWS):
        var t0 := float(row) / float(SHIN_ROWS)
        var t1 := float(row + 1) / float(SHIN_ROWS)
        for side in range(SHIN_SIDES):
            var a0 := TAU * float(side) / float(SHIN_SIDES)
            var a1 := TAU * float(side + 1) / float(SHIN_SIDES)
            _vertex(tool, _shin_point(t0, a0), t0)
            _vertex(tool, _shin_point(t1, a0), t1)
            _vertex(tool, _shin_point(t1, a1), t1)
            _vertex(tool, _shin_point(t0, a0), t0)
            _vertex(tool, _shin_point(t1, a1), t1)
            _vertex(tool, _shin_point(t0, a1), t0)
    tool.generate_normals()
    return tool.commit()

func _ring_mesh() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    const SEGMENTS := 32
    for band in [0.08, 0.77]:
        for index in range(SEGMENTS):
            var a := TAU * float(index) / float(SEGMENTS)
            var b := TAU * float(index + 1) / float(SEGMENTS)
            var p00 := _shin_point(band, a, 0.014)
            var p01 := _shin_point(band, b, 0.014)
            var p10 := _shin_point(band + 0.055, a, 0.014)
            var p11 := _shin_point(band + 0.055, b, 0.014)
            tool.add_vertex(p00)
            tool.add_vertex(p10)
            tool.add_vertex(p11)
            tool.add_vertex(p00)
            tool.add_vertex(p11)
            tool.add_vertex(p01)
    tool.generate_normals()
    return tool.commit()
