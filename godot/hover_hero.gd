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
var visor: MeshInstance3D
var helmet_glow: MeshInstance3D
var landing_ring: MeshInstance3D
var jump_pose := 0.0
var last_jump_height := 0.0
var landing_pulse := 0.0
var knee_guards: Array[MeshInstance3D] = []
var shoulder_lights: Array[MeshInstance3D] = []
var flames: Array[MeshInstance3D] = []
var energy_trails: Array[MeshInstance3D] = []
var lean := 0.0
var boosting := false
# Smoothed animation weights keep lane changes and turbo poses fluid.
var steering_pose := 0.0
var turbo_pose := 0.0

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

func thruster(parent: Node3D, pos: Vector3, radius: float, tint: Color) -> Node3D:
    var group := Node3D.new()
    group.position = pos
    parent.add_child(group)
    var cylinder := CylinderMesh.new()
    cylinder.height = 0.72
    cylinder.bottom_radius = radius
    cylinder.top_radius = radius * 0.7
    cylinder.radial_segments = 12
    var tube := piece(group, cylinder, Vector3.ZERO, Vector3.ONE, tint)
    tube.rotation_degrees.x = 90
    var ring := TorusMesh.new()
    ring.inner_radius = radius * 0.78
    ring.outer_radius = radius
    ring.rings = 20
    ring.ring_segments = 8
    var halo := piece(group, ring, Vector3(0, 0, 0.39), Vector3.ONE, Color("#80fff4"), true)
    halo.rotation_degrees.x = 90
    return group

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
    # Twin neon contrails stretch behind the board during turbo without particles.
    # Just two inexpensive meshes: suitable for iPhone WebGL rendering.
    for side in [-1.0, 1.0]:
        var trail_color := cyan if side < 0.0 else bright
        var trail := box(board, Vector3(side * 0.48, 0.16, 2.0), Vector3(0.07, 0.06, 0.48), trail_color, true)
        trail.name = "Animated boost contrail"
        energy_trails.append(trail)
    # V12: prominent swept side wings, rear stabilisers and an illuminated
    # centre spine. These change the board outline even from the chase camera.
    for side in [-1.0, 1.0]:
        var wing := PrismMesh.new()
        wing.size = Vector3(0.76, 0.14, 1.45)
        var wing_mesh := piece(board, wing, Vector3(side * 0.98, 0.27, 0.19), Vector3.ONE, suit)
        wing_mesh.rotation_degrees.y = side * 14.0
        var fin := PrismMesh.new()
        fin.size = Vector3(0.18, 0.63, 0.81)
        var stabilizer := piece(board, fin, Vector3(side * 0.87, 0.56, 1.03), Vector3.ONE, navy)
        stabilizer.rotation_degrees.z = side * 15.0
        box(board, Vector3(side * 1.01, 0.43, 0.28), Vector3(0.11, 0.06, 1.02), cyan, true)
        ball(board, Vector3(side * 1.05, 0.38, -0.40), Vector3(0.15, 0.12, 0.22), bright, true)
    box(board, Vector3(0, 0.46, -0.30), Vector3(0.12, 0.07, 1.6), yellow, true)

    # A single expanding neon ring celebrates a successful landing.
    # Kept hidden outside the brief landing animation to save mobile GPU work.
    var shock_mesh := TorusMesh.new()
    shock_mesh.inner_radius = 0.66
    shock_mesh.outer_radius = 0.77
    shock_mesh.rings = 28
    shock_mesh.ring_segments = 6
    landing_ring = piece(self, shock_mesh, Vector3(0, 0.10, 0), Vector3.ONE, cyan, true)
    landing_ring.name = "Landing shockwave"
    landing_ring.visible = false
    box(board, Vector3(0, 0.38, -1.24), Vector3(0.82, 0.05, 0.13), yellow, true)
    box(board, Vector3(0, 0.39, -0.8), Vector3(0.6, 0.06, 0.22), cyan, true)
    # Streamlined pointed nose, asymmetric colored panels, two solid rear jet nacelles.
    var nose := PrismMesh.new()
    nose.size = Vector3(1.32, 0.17, 0.73)
    var prow := piece(board, nose, Vector3(0, 0.30, -1.37), Vector3.ONE, suit)
    prow.rotation_degrees.y = 180
    for side in [-1.0, 1.0]:
        thruster(board, Vector3(side * 0.48, 0.17, 1.18), 0.27, navy)
        box(board, Vector3(side * 0.92, 0.37, -0.35), Vector3(0.35, 0.08, 1.30), bright, true)
        ball(board, Vector3(side * 0.48, 0.17, 1.62), Vector3(0.20, 0.22, 0.34), cyan, true)
        box(board, Vector3(side * 0.37, 0.43, -0.28), Vector3(0.21, 0.06, 1.32), yellow, true)

    var body := Node3D.new()
    body.name = "Animated racer rig"
    character_body = body
    add_child(body)
    capsule(body, Vector3(0, 1.55, 0), Vector3(0.49, 0.64, 0.35), suit)
    box(body, Vector3(0, 1.50, 0.38), Vector3(0.53, 0.7, 0.27), yellow)
    box(body, Vector3(0, 1.93, -0.18), Vector3(0.39, 0.12, 0.12), cyan, true)
    # Shoulder armour and curved energy seams read clearly from the chase camera.
    for side in [-1.0, 1.0]:
        var pad := ball(body, Vector3(side * 0.58, 1.93, -0.06), Vector3(0.28, 0.18, 0.31), bright)
        shoulder_lights.append(pad)
        box(body, Vector3(side * 0.47, 1.53, 0.23), Vector3(0.12, 0.46, 0.06), cyan, true)
    # Layered curved jacket armour replaces a flat rectangular torso silhouette.
    # Low-poly geometry keeps this lightweight in the iPhone browser.
    var torso_plate := SphereMesh.new()
    torso_plate.radial_segments = 20
    torso_plate.rings = 10
    piece(body, torso_plate, Vector3(0, 1.57, -0.22), Vector3(0.48, 0.53, 0.22), navy)
    piece(body, torso_plate, Vector3(0, 1.65, -0.40), Vector3(0.24, 0.29, 0.055), cyan, true)
    for side in [-1.0, 1.0]:
        var rib := capsule(body, Vector3(side * 0.37, 1.45, -0.20), Vector3(0.16, 0.41, 0.17), suit)
        rib.rotation_degrees.z = side * 14.0
        ball(body, Vector3(side * 0.47, 1.25, -0.15), Vector3(0.22, 0.14, 0.20), bright)
    # Visible collar and shoulder-to-helmet neck connection.
    capsule(body, Vector3(0, 2.11, 0), Vector3(0.24, 0.19, 0.24), navy)
    ball(body, Vector3(0, 2.14, -0.18), Vector3(0.24, 0.10, 0.13), yellow)

    # Curved back armour and a layered, tapered waist remain visible from the
    # chase camera. Lightweight primitives use no imported binary dependencies.
    var back_shell := SphereMesh.new()
    back_shell.radial_segments = 20
    back_shell.rings = 10
    piece(body, back_shell, Vector3(0, 1.61, 0.31), Vector3(0.47, 0.52, 0.19), suit)
    for side in [-1.0, 1.0]:
        var flank := capsule(body, Vector3(side * 0.35, 1.40, 0.18), Vector3(0.18, 0.44, 0.21), navy)
        flank.rotation_degrees.z = side * 12.0
        ball(body, Vector3(side * 0.29, 1.18, 0.08), Vector3(0.23, 0.20, 0.24), suit)
    box(body, Vector3(0, 1.23, 0.37), Vector3(0.57, 0.11, 0.13), cyan, true)

    # V15: broad hood, high-contrast shoulder cape and bright rear insignia.
    # Designed for the rear chase camera where small facial details are invisible.
    var hood := SphereMesh.new()
    hood.radial_segments = 28
    hood.rings = 14
    piece(body, hood, Vector3(0, 2.48, 0.18), Vector3(0.62, 0.66, 0.51), navy)
    piece(body, hood, Vector3(0, 2.53, 0.49), Vector3(0.54, 0.54, 0.15), suit)
    for side in [-1.0, 1.0]:
        var shoulder_cape := PrismMesh.new()
        shoulder_cape.size = Vector3(0.52, 0.92, 0.35)
        var cape_part := piece(body, shoulder_cape, Vector3(side * 0.51, 1.66, 0.40), Vector3.ONE, bright)
        cape_part.rotation_degrees.z = -side * 13.0
        box(body, Vector3(side * 0.34, 1.83, 0.59), Vector3(0.10, 0.41, 0.06), cyan, true)
    var insignia := PrismMesh.new()
    insignia.size = Vector3(0.47, 0.52, 0.11)
    var badge := piece(body, insignia, Vector3(0, 1.58, 0.78), Vector3.ONE, yellow, true)
    badge.rotation_degrees.z = 180.0

    # Twin backpack modules and glowing power cell face the player.
    box(body, Vector3(0, 1.62, 0.48), Vector3(0.62, 0.80, 0.25), navy)
    globe_power(body, Vector3(0, 1.66, 0.65), cyan)
    for side in [-1.0, 1.0]:
        box(body, Vector3(side * 0.22, 1.70, 0.65), Vector3(0.11, 0.61, 0.1), bright, true)
    ball(body, Vector3(0, 2.45, 0), Vector3(0.51, 0.54, 0.45), skin)
    # Hair silhouette and fringe are visible from the rear/side.
    ball(body, Vector3(0, 2.82, 0.04), Vector3(0.54, 0.21, 0.46), navy)
    for side in [-1.0, 1.0]:
        ball(body, Vector3(side * 0.44, 2.6, 0.09), Vector3(0.12, 0.22, 0.20), navy)
    box(body, Vector3(0, 2.45, -0.40), Vector3(0.67, 0.21, 0.12), cyan, true)
    box(body, Vector3(0, 2.84, -0.17), Vector3(0.21, 0.08, 0.29), bright, true)
    # Hero's hair, visor frame, earpieces and helmet sticker.
    for side in [-1.0, 1.0]:
        ball(body, Vector3(side * 0.47, 2.49, 0.04), Vector3(0.14, 0.30, 0.26), bright)
        box(body, Vector3(side * 0.24, 2.47, -0.43), Vector3(0.08, 0.22, 0.07), yellow, true)
    ball(body, Vector3(0, 2.95, 0.13), Vector3(0.19, 0.26, 0.27), navy)
    ball(body, Vector3(-0.25, 2.94, 0.02), Vector3(0.18, 0.22, 0.24), navy)
    ball(body, Vector3(0.25, 2.94, 0.04), Vector3(0.18, 0.23, 0.25), navy)
    box(body, Vector3(0, 2.87, 0.38), Vector3(0.20, 0.09, 0.08), yellow, true)
    # Distinctive stylized full-face racing visor, clearly visible from side angles.
    visor = ball(body, Vector3(0, 2.48, -0.40), Vector3(0.39, 0.23, 0.12), Color("#38e5f8"), true)
    helmet_glow = box(body, Vector3(0, 2.75, 0.39), Vector3(0.56, 0.08, 0.07), yellow, true)
    # Helmet side fins and contrasting tech panels create a readable character silhouette.
    for side in [-1.0, 1.0]:
        var fin := PrismMesh.new()
        fin.size = Vector3(0.24, 0.43, 0.57)
        var fin_shape := piece(body, fin, Vector3(side * 0.50, 2.69, 0.10), Vector3.ONE, suit)
        fin_shape.rotation_degrees.z = side * 20.0
        box(body, Vector3(side * 0.56, 2.52, 0.16), Vector3(0.08, 0.14, 0.31), cyan, true)


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
        # Articulated glove, elbow shell and wrist cuff.
        ball(arm, Vector3(0, -0.38, -0.18), Vector3(0.21, 0.16, 0.21), bright)
        ball(arm, Vector3(0, -0.59, -0.25), Vector3(0.20, 0.13, 0.23), skin)
        box(arm, Vector3(0, -0.49, -0.20), Vector3(0.24, 0.09, 0.20), cyan, true)
        # Slim tapered forearm and shoulder seam read as a single articulated suit.
        var sleeve := capsule(arm, Vector3(0, -0.24, 0.06), Vector3(0.21, 0.35, 0.21), navy)
        sleeve.rotation_degrees.z = 8.0
        ball(arm, Vector3(0, -0.06, 0.06), Vector3(0.23, 0.17, 0.25), suit)
    for leg in [left_leg, right_leg]:
        capsule(leg, Vector3(0, -0.23, 0), Vector3(0.22, 0.44, 0.24), navy)
        box(leg, Vector3(0, -0.60, -0.16), Vector3(0.29, 0.19, 0.48), yellow)
        var guard := ball(leg, Vector3(0, -0.37, -0.18), Vector3(0.25, 0.17, 0.08), bright)
        knee_guards.append(guard)
        box(leg, Vector3(0, -0.58, -0.38), Vector3(0.28, 0.09, 0.08), cyan, true)
        # Smooth shin guards and thick cuff visually attach the boot to the leg.
        var shin := capsule(leg, Vector3(0, -0.35, 0.08), Vector3(0.19, 0.36, 0.22), suit)
        shin.rotation_degrees.x = -12.0
        ball(leg, Vector3(0, -0.53, -0.02), Vector3(0.22, 0.13, 0.24), bright)


func globe_power(parent: Node3D, pos: Vector3, tint: Color) -> void:
    ball(parent, pos, Vector3(0.19, 0.23, 0.08), tint, true)
    ball(parent, pos + Vector3(0, 0, 0.06), Vector3(0.09, 0.13, 0.04), Color("#fff5c4"), true)

func _process(delta: float) -> void:
    time += delta
    var bob := sin(time * (8.5 if boosting else 3.4)) * 0.06
    board.position.y = bob
    # Natural counterbalance: knees, arms and upper body react together when steering.
    # Turbo blends into a forward crouch rather than snapping to a fixed pose.
    steering_pose = lerpf(steering_pose, clampf(lean, -1.0, 1.0), minf(1.0, delta * 5.5))
    turbo_pose = lerpf(turbo_pose, 1.0 if boosting else 0.0, minf(1.0, delta * 3.8))
    # Height is controlled by the existing gameplay script; animate the pose
    # from the real jump arc without changing jump timing or collision rules.
    # world.gd moves the RiderCharacter parent during a jump, not this child.
    # Read the actual race height so the legacy rig can crouch, land and pulse.
    var rider_root := get_parent() as Node3D
    var jump_height := maxf(0.0, rider_root.position.y if rider_root != null else position.y)
    jump_pose = lerpf(jump_pose, clampf(jump_height / 1.8, 0.0, 1.0), minf(1.0, delta * 11.0))
    if last_jump_height > 0.14 and jump_height < 0.05:
        landing_pulse = 1.0
    last_jump_height = jump_height
    if landing_pulse > 0.0:
        landing_pulse = maxf(0.0, landing_pulse - delta * 3.2)
        landing_ring.visible = true
        var expansion := 1.0 + (1.0 - landing_pulse) * 2.6
        landing_ring.scale = Vector3(expansion, 1.0, expansion)
    else:
        landing_ring.visible = false
    var cadence := sin(time * (8.0 if boosting else 4.0))
    character_body.position.y = bob * 0.7 - turbo_pose * 0.07 - jump_pose * 0.10
    character_body.position.x = -steering_pose * 0.08
    character_body.rotation.z = lerpf(character_body.rotation.z, steering_pose * 0.18, minf(1.0, delta * 4.0))
    character_body.rotation.x = lerpf(character_body.rotation.x, -0.015 - turbo_pose * 0.18 + jump_pose * 0.13, minf(1.0, delta * 5.0))
    board.rotation.z = lerpf(board.rotation.z, -steering_pose * 0.12, minf(1.0, delta * 5.0))
    board.rotation.x = lerpf(board.rotation.x, -turbo_pose * 0.065 + cadence * 0.014 + jump_pose * 0.16, minf(1.0, delta * 5.0))
    left_arm.rotation.x = -0.22 + cadence * 0.07 - turbo_pose * 0.20 + jump_pose * 0.52
    right_arm.rotation.x = -0.22 - cadence * 0.07 - turbo_pose * 0.20 + jump_pose * 0.52
    left_arm.rotation.z = lerpf(left_arm.rotation.z, -0.16 - steering_pose * 0.20 - jump_pose * 0.28, minf(1.0, delta * 6.0))
    right_arm.rotation.z = lerpf(right_arm.rotation.z, 0.16 - steering_pose * 0.20 + jump_pose * 0.28, minf(1.0, delta * 6.0))
    left_leg.rotation.x = 0.22 + cadence * 0.06 + turbo_pose * 0.12 + jump_pose * 0.38
    right_leg.rotation.x = 0.22 - cadence * 0.06 + turbo_pose * 0.12 + jump_pose * 0.38
    left_leg.rotation.z = lerpf(left_leg.rotation.z, -steering_pose * 0.10, minf(1.0, delta * 6.0))
    right_leg.rotation.z = lerpf(right_leg.rotation.z, -steering_pose * 0.10, minf(1.0, delta * 6.0))
    for i in range(shoulder_lights.size()):
        var light := shoulder_lights[i]
        light.scale.y = 0.18 + sin(time * 2.7 + float(i)) * 0.02
    visor.scale.y = 0.23 + 0.014 * sin(time * 3.0)
    helmet_glow.scale.x = 0.56 + 0.06 * sin(time * 2.0)
    for guard in knee_guards:
        guard.rotation.y = sin(time * 3.5) * 0.06
    for flame in flames:
        flame.scale.z = (1.5 if boosting else 0.65) + (0.15 * sin(time * 18.0))
    for i in range(energy_trails.size()):
        var trail := energy_trails[i]
        var trail_length := (2.6 if boosting else 0.48) + sin(time * (22.0 if boosting else 9.0) + float(i) * 1.7) * (0.25 if boosting else 0.08)
        trail.scale.z = trail_length
        trail.scale.x = 0.11 if boosting else 0.055
        trail.position.z = 1.72 + trail_length * 0.5
