extends Node3D
## Procedural stylized low-poly racer. All geometry generated inside Godot.
## Animated board, articulated limbs and exhaust: no binary assets or external licensing.
var time := 0.0
var left_arm: Node3D
var right_arm: Node3D
var left_leg: Node3D
var right_leg: Node3D
var board: Node3D
var character_body: Node3D
var flames: Array[MeshInstance3D] = []
var lean := 0.0
var boosting := false

func material(color: Color, emissive := false) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.metallic = 0.18
    m.roughness = 0.46
    if emissive:
        m.emission_enabled = true
        m.emission = color
        m.emission_energy_multiplier = 2.2
    return m

func piece(parent: Node3D, primitive: PrimitiveMesh, position: Vector3, scale_factor: Vector3, color: Color, glow := false) -> MeshInstance3D:
    var shape := MeshInstance3D.new()
    shape.mesh = primitive
    shape.material_override = material(color, glow)
    parent.add_child(shape)
    shape.position = position
    shape.scale = scale_factor
    return shape

func box(parent: Node3D, pos: Vector3, size: Vector3, tint: Color, glow := false) -> MeshInstance3D:
    return piece(parent, BoxMesh.new(), pos, size, tint, glow)

func ball(parent: Node3D, pos: Vector3, size: Vector3, tint: Color, glow := false) -> MeshInstance3D:
    var mesh := SphereMesh.new()
    mesh.radial_segments = 16
    mesh.rings = 8
    return piece(parent, mesh, pos, size, tint, glow)

func capsule(parent: Node3D, pos: Vector3, size: Vector3, tint: Color) -> MeshInstance3D:
    var mesh := CapsuleMesh.new()
    mesh.radial_segments = 12
    mesh.rings = 5
    return piece(parent, mesh, pos, size, tint)

func _ready() -> void:
    _assemble()

func _assemble() -> void:
    var navy := Color("#111a3e")
    var suit := Color("#8256e5")
    var cyan := Color("#20eaff")
    var bright := Color("#ef53bc")
    var yellow := Color("#ffcb58")
    var skin := Color("#eaa777")
    board = Node3D.new()
    board.name = "Floating hoverboard"
    add_child(board)
    box(board, Vector3(0, 0.25, 0), Vector3(1.55, 0.18, 2.65), navy)
    box(board, Vector3(0, 0.37, -0.04), Vector3(0.83, 0.06, 1.88), suit)
    for side in [-1.0, 1.0]:
        box(board, Vector3(side * 0.72, 0.33, 0), Vector3(0.14, 0.12, 2.42), cyan, true)
        box(board, Vector3(side * 0.51, 0.18, 1.0), Vector3(0.30, 0.2, 0.28), bright, true)
        var flame := ball(board, Vector3(side * 0.51, 0.18, 1.28), Vector3(0.17, 0.17, 0.5), cyan, true)
        flames.append(flame)
    box(board, Vector3(0, 0.38, -1.24), Vector3(0.82, 0.05, 0.13), yellow, true)

    var body := Node3D.new()
    body.name = "Animated racer rig"
    character_body = body
    add_child(body)
    capsule(body, Vector3(0, 1.55, 0), Vector3(0.49, 0.64, 0.35), suit)
    box(body, Vector3(0, 1.50, 0.38), Vector3(0.53, 0.7, 0.27), yellow)
    box(body, Vector3(0, 1.93, -0.18), Vector3(0.39, 0.12, 0.12), cyan, true)
    ball(body, Vector3(0, 2.45, 0), Vector3(0.51, 0.54, 0.45), skin)
    # Hair silhouette and fringe are visible from the rear/side.
    ball(body, Vector3(0, 2.82, 0.04), Vector3(0.54, 0.21, 0.46), navy)
    for side in [-1.0, 1.0]:
        ball(body, Vector3(side * 0.44, 2.6, 0.09), Vector3(0.12, 0.22, 0.20), navy)
    box(body, Vector3(0, 2.45, -0.40), Vector3(0.67, 0.21, 0.12), cyan, true)
    box(body, Vector3(0, 2.84, -0.17), Vector3(0.21, 0.08, 0.29), bright, true)

    left_arm = Node3D.new()
    right_arm = Node3D.new()
    left_leg = Node3D.new()
    right_leg = Node3D.new()
    for limb in [left_arm, right_arm, left_leg, right_leg]:
        body.add_child(limb)
    left_arm.position = Vector3(-0.51, 1.83, 0)
    right_arm.position = Vector3(0.51, 1.83, 0)
    left_leg.position = Vector3(-0.28, 1.04, 0)
    right_leg.position = Vector3(0.28, 1.04, 0)
    for arm in [left_arm, right_arm]:
        capsule(arm, Vector3(0, -0.25, -0.06), Vector3(0.17, 0.40, 0.20), suit)
        ball(arm, Vector3(0, -0.57, -0.16), Vector3(0.18, 0.15, 0.19), navy)
    for leg in [left_leg, right_leg]:
        capsule(leg, Vector3(0, -0.23, 0), Vector3(0.22, 0.44, 0.24), navy)
        box(leg, Vector3(0, -0.60, -0.16), Vector3(0.29, 0.19, 0.48), yellow)

func _process(delta: float) -> void:
    time += delta
    var bob := sin(time * (8.5 if boosting else 3.4)) * 0.06
    board.position.y = bob
    character_body.position.y = bob * 0.7
    character_body.rotation.z = lerpf(character_body.rotation.z, lean * 0.12, minf(1.0, delta * 4.0))
    character_body.rotation.x = -0.09 if boosting else -0.015
    board.rotation.z = lerpf(board.rotation.z, lean * -0.09, minf(1, delta * 5))
    left_arm.rotation.x = -0.22 + sin(time * 4.0) * 0.09
    right_arm.rotation.x = -0.22 - sin(time * 4.0) * 0.09
    left_leg.rotation.x = 0.22 + sin(time * 4.0) * 0.07
    right_leg.rotation.x = 0.22 - sin(time * 4.0) * 0.07
    for flame in flames:
        flame.scale.z = (1.5 if boosting else 0.65) + (0.15 * sin(time * 18.0))
