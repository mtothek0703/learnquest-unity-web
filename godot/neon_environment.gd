extends Node3D
## LearnQuest Skyway: a self-contained, fully three-dimensional stylized track environment.
## Procedural geometry is deliberately asset-free to keep the web game small and kid-safe.
var elapsed := 0.0
var floaters: Array[Node3D] = []
var lights: Array[Node3D] = []
var scenery: Array[Node3D] = []
var running := false
var speed_streaks: Array[MeshInstance3D] = []
var travel_speed := 14.0
var cinematic_bridges: Node3D
var cinematic_traffic: Node3D
var rand := RandomNumberGenerator.new()

func _ready() -> void:
    rand.seed = 6212026
    _build_track()
    _build_roadside()
    _build_skyline()
    _build_portals()
    _build_floating_traffic()
    _build_speed_streaks()
    _build_landmarks()
    _build_sunset_landmark()
    # Wide-screen foreground architecture creates strong depth and parallax.
    var bridge_script := preload("res://cinematic_city_bridges.gd")
    cinematic_bridges = bridge_script.new()
    cinematic_bridges.name = "Cinematic skybridges"
    add_child(cinematic_bridges)
    # Animated side-lane maglev convoys add shaded silhouettes and moving
    # light trails without altering the confirmed touch/gameplay systems.
    var traffic_script := preload("res://cinematic_sky_traffic.gd")
    cinematic_traffic = traffic_script.new()
    cinematic_traffic.name = "Cinematic maglev traffic"
    add_child(cinematic_traffic)

func material(tint: Color, glow: bool = false) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = tint
    m.metallic = 0.15
    m.roughness = 0.54
    if glow:
        m.emission_enabled = true
        m.emission = tint
        m.emission_energy_multiplier = 2.1
        m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    return m

func shape(parent: Node3D, mesh: PrimitiveMesh, pos: Vector3, tint: Color, glow: bool = false) -> MeshInstance3D:
    var n := MeshInstance3D.new()
    n.mesh = mesh
    n.material_override = material(tint, glow)
    n.position = pos
    parent.add_child(n)
    return n

func block(parent: Node3D, pos: Vector3, dimensions: Vector3, tint: Color, glow: bool = false) -> MeshInstance3D:
    var m := BoxMesh.new()
    m.size = dimensions
    return shape(parent, m, pos, tint, glow)

func globe(parent: Node3D, pos: Vector3, dimensions: Vector3, tint: Color, glow: bool = false) -> MeshInstance3D:
    var m := SphereMesh.new()
    m.radial_segments = 12
    m.rings = 6
    var n := shape(parent, m, pos, tint, glow)
    n.scale = dimensions
    return n

func tower(parent: Node3D, pos: Vector3, height: float, base_width: float, tint: Color) -> MeshInstance3D:
    var m := CylinderMesh.new()
    m.height = height
    m.top_radius = base_width * 0.65
    m.bottom_radius = base_width
    m.radial_segments = 8
    return shape(parent, m, pos, tint)

func _build_track() -> void:
    # Colored asphalt skin adds depth over the existing collision-free prototype road.
    block(self, Vector3(0, -0.028, -53), Vector3(10.65, 0.075, 153), Color("#283352"))
    for side in [-1.0, 1.0]:
        block(self, Vector3(side * 4.92, 0.10, -53), Vector3(0.15, 0.04, 151), Color("#ffc360"), true)
        block(self, Vector3(side * 5.24, -0.17, -53), Vector3(0.4, 0.14, 151), Color("#ac6fff"), true)
    for i in range(17):
        var z := 11.0 - float(i) * 8.0
        block(self, Vector3(0, 0.035, z), Vector3(9.6, 0.03, 0.14), Color("#42516a"))
        for side in [-1.0, 1.0]:
            block(self, Vector3(side * 3.18, 0.045, z - 2), Vector3(0.17, 0.035, 1.7), Color("#62f5ec"), true)
    # Platform edges and side terrain are real meshes; the environment has wide playable depth.
    for side in [-1.0, 1.0]:
        block(self, Vector3(side * 14.2, -1.24, -58), Vector3(15, 2.2, 165), Color("#1b344d"))
        block(self, Vector3(side * 8.8, -0.03, -58), Vector3(6.2, 0.16, 155), Color("#335c63"))
        for index in range(10):
            var z := -float(index) * 14.0 - 4.0
            block(self, Vector3(side * 8.1, 0.025, z), Vector3(3.6, 0.06, 0.17), Color("#64bdad"))

func _build_roadside() -> void:
    for i in range(15):
        var z := -7.0 - float(i) * 9.0
        var side := -1.0 if i % 2 == 0 else 1.0
        var station := Node3D.new()
        station.position = Vector3(side * 8.4, 0, z)
        add_child(station)
        scenery.append(station)
        # Glowing canopy on sculpted sci-fi column, with a contrasting central core.
        tower(station, Vector3(0, 1.6, 0), 3.2, 0.38, Color("#526783"))
        globe(station, Vector3(0, 3.5, 0), Vector3(0.67, 0.25, 0.67), Color("#ffdc8d"), true)
        globe(station, Vector3(0, 3.65, 0), Vector3(0.28, 0.5, 0.28), Color("#34e9ed"), true)
        block(station, Vector3(0, 0.20, 0), Vector3(1.4, 0.38, 1.4), Color("#7958a5"))
        if i % 3 != 1:
            var tree := Node3D.new()
            tree.position = Vector3(-side * 10.7, 0, z - 3.5)
            add_child(tree)
            scenery.append(tree)
            tower(tree, Vector3(0, 1.1, 0), 2.1, 0.20, Color("#785b73"))
            globe(tree, Vector3(0, 3.0, 0), Vector3(1.6, 1.6, 1.45), Color("#1b9d9c"))
            globe(tree, Vector3(-0.5, 3.6, 0.3), Vector3(0.98, 1.1, 0.98), Color("#58e3bb"))
            globe(tree, Vector3(0.6, 3.3, -0.45), Vector3(1.0, 1.2, 1.0), Color("#449fd3"))
    for i in range(8):
        var z := -12.0 - float(i) * 16.0
        for side in [-1.0, 1.0]:
            var crystal := Node3D.new()
            crystal.position = Vector3(side * (12.8 + float(i % 3)), 0, z)
            add_child(crystal)
            scenery.append(crystal)
            var height := 2.4 + float(i % 3)
            tower(crystal, Vector3(0, height * 0.5, 0), height, 0.65, Color("#bd61f0"))
            globe(crystal, Vector3(0, height + 0.1, 0), Vector3(0.44, 0.46, 0.44), Color("#63f9f4"), true)

func _build_skyline() -> void:
    # Different silhouettes, roofs, stacked floors and accent strips: not a row of identical boxes.
    for i in range(20):
        var z := -11.0 - float(i) * 7.5
        var side := -1.0 if i % 2 == 0 else 1.0
        var x := side * (17.0 + float(i % 4) * 3.0)
        var height := 6.0 + float((i * 7) % 13)
        var building := Node3D.new()
        building.position = Vector3(x, 0, z)
        building.rotation.y = float(i % 4) * 0.16
        add_child(building)
        scenery.append(building)
        var main_tint := Color("#384e72") if i % 3 == 0 else Color("#443e75")
        block(building, Vector3.ZERO + Vector3(0, height * 0.5, 0), Vector3(4.0, height, 4.2), main_tint)
        block(building, Vector3(0, height + 0.35, 0), Vector3(4.7, 0.7, 4.7), Color("#e06fbb"))
        tower(building, Vector3(0, height + 1.75, 0), 2.3, 0.22, Color("#baf6e7"))
        var window_color := Color("#6aeee9") if i % 2 == 0 else Color("#ffd38c")
        for row in range(1, int(height) - 1, 3):
            for column in [-1.0, 1.0]:
                block(building, Vector3(column * 1.15, float(row) + 0.75, -2.13), Vector3(0.75, 1.10, 0.09), window_color, true)
        if i % 4 == 0:
            block(building, Vector3(0, height + 3.1, 0), Vector3(2.1, 0.13, 2.1), Color("#61f2ed"), true)
    # Landmark towers frame the horizon.
    for side in [-1.0, 1.0]:
        tower(self, Vector3(side * 23.0, 11, -118), 22, 4.4, Color("#6c5592"))
        globe(self, Vector3(side * 23.0, 22.1, -118), Vector3(2.2, 2.2, 2.2), Color("#ffd17f"), true)

func _build_portals() -> void:
    for i in range(7):
        var z := -24.0 - float(i) * 18.5
        var portal := Node3D.new()
        portal.position = Vector3(0, 3.9, z)
        add_child(portal)
        scenery.append(portal)
        var ring_mesh := TorusMesh.new()
        ring_mesh.outer_radius = 5.07
        ring_mesh.inner_radius = 4.8
        ring_mesh.rings = 32
        ring_mesh.ring_segments = 8
        var ring := shape(portal, ring_mesh, Vector3.ZERO, Color("#ffd379") if i % 2 == 0 else Color("#57f3e1"), true)
        ring.rotation_degrees.x = 90
        portal.scale = Vector3(1.05, 0.69, 1)
        floaters.append(portal)
        block(portal, Vector3(0, 4.0, 0), Vector3(1.6, 0.22, 0.48), Color("#ff7eb8"), true)

func _build_floating_traffic() -> void:
    for i in range(10):
        var side := -1.0 if i % 2 == 0 else 1.0
        var flyer := Node3D.new()
        flyer.position = Vector3(side * (12.5 + float(i % 4) * 3), 5.0 + float(i % 3) * 2.2, -11.0 - float(i) * 13)
        add_child(flyer)
        scenery.append(flyer)
        globe(flyer, Vector3.ZERO, Vector3(1.7, 0.32, 0.8), Color("#8f94d4"))
        globe(flyer, Vector3(0, 0.25, -0.25), Vector3(0.85, 0.47, 0.42), Color("#38f0ed"))
        for wing in [-1.0, 1.0]:
            block(flyer, Vector3(wing * 1.15, -0.04, 0), Vector3(1.8, 0.10, 0.38), Color("#ec7dac"))
            globe(flyer, Vector3(wing * 1.7, 0, 0.0), Vector3(0.20, 0.17, 0.2), Color("#fff4b2"), true)
        lights.append(flyer)


func _build_speed_streaks() -> void:
    # Animated luminous dashes stream underneath the player, making speed tangible.
    for i in range(36):
        var z := 8.0 - float(int(i / 3)) * 11.0
        var x := float(i % 3 - 1) * 3.1
        var streak := block(self, Vector3(x, 0.065, z), Vector3(0.12, 0.045, 2.3), Color("#86fff3"), true)
        speed_streaks.append(streak)

func _build_landmarks() -> void:
    # A pastel ringed moon and floating sculptural islands add a recognizable skyline.
    var moon := Node3D.new()
    moon.name = "Distant ringed moon"
    moon.position = Vector3(-35, 30, -114)
    add_child(moon)
    globe(moon, Vector3.ZERO, Vector3(8.5, 8.5, 8.5), Color("#ffcbbd"))
    var orbit := TorusMesh.new()
    orbit.inner_radius = 11.0
    orbit.outer_radius = 11.55
    orbit.rings = 48
    orbit.ring_segments = 7
    var moon_ring := shape(moon, orbit, Vector3.ZERO, Color("#70f2ff"), true)
    moon_ring.rotation_degrees = Vector3(24, 0, 67)

    for i in range(8):
        var side := -1.0 if i % 2 == 0 else 1.0
        var island := Node3D.new()
        island.name = "Floating island %d" % i
        island.position = Vector3(side * (23.0 + float(i % 3) * 7.0), 7.5 + float(i % 3) * 2.5, -25.0 - float(i) * 17.0)
        add_child(island)
        scenery.append(island)
        var base := CylinderMesh.new()
        base.top_radius = 5.0
        base.bottom_radius = 1.0
        base.height = 3.6
        base.radial_segments = 7
        shape(island, base, Vector3(0, -1.7, 0), Color("#56649b"))
        var turf := CylinderMesh.new()
        turf.top_radius = 5.25
        turf.bottom_radius = 5.0
        turf.height = 0.7
        turf.radial_segments = 7
        shape(island, turf, Vector3(0, 0.2, 0), Color("#46c5b0"))
        for j in range(3):
            var x := float(j - 1) * 2.1
            tower(island, Vector3(x, 1.8, -0.3), 2.5, 0.28, Color("#9075ac"))
            globe(island, Vector3(x, 3.4, -0.3), Vector3(1.15, 1.0, 1.1), Color("#78e5d0"))
        globe(island, Vector3(0, -3.8, 0), Vector3(0.55, 0.75, 0.55), Color("#a7faff"), true)

func _build_sunset_landmark() -> void:
    # Giant warm sun, layered skyline silhouettes, and large coloured arches
    # give the first frame a different composition without relying on textures.
    var sun := Node3D.new()
    sun.name = "V14 giant sunset"
    sun.position = Vector3(13.0, 24.0, -138.0)
    add_child(sun)
    var sun_mesh := SphereMesh.new()
    sun_mesh.radial_segments = 32
    sun_mesh.rings = 16
    var disc := shape(sun, sun_mesh, Vector3.ZERO, Color("#ffcb86"), true)
    disc.scale = Vector3(16.0, 16.0, 1.1)
    var halo_mesh := TorusMesh.new()
    halo_mesh.inner_radius = 17.8
    halo_mesh.outer_radius = 18.4
    halo_mesh.rings = 48
    halo_mesh.ring_segments = 8
    shape(sun, halo_mesh, Vector3.ZERO, Color("#ff7db7"), true)
    for i in range(4):
        var band_y := -7.0 + float(i) * 3.0
        block(sun, Vector3(0, band_y, 1.5), Vector3(31.0 - float(i) * 2.6, 0.7, 0.15), Color("#6b407f"))
    for side in [-1.0, 1.0]:
        # Decorative elevated ribbon bridges keep the world unmistakably 3D.
        for i in range(6):
            var z := -9.0 - float(i) * 23.0
            var arch := Node3D.new()
            arch.name = "V14 luminous sky ribbon"
            arch.position = Vector3(side * 9.7, 4.6 + float(i % 2) * 1.5, z)
            add_child(arch)
            scenery.append(arch)
            var mesh := TorusMesh.new()
            mesh.inner_radius = 2.5
            mesh.outer_radius = 2.7
            mesh.rings = 24
            mesh.ring_segments = 6
            var ribbon := shape(arch, mesh, Vector3.ZERO, Color("#ff99d9") if side < 0 else Color("#81fff0"), true)
            ribbon.rotation_degrees.y = 90
            arch.scale = Vector3(1.0, 1.5, 1.0)

func _process(delta: float) -> void:
    cinematic_bridges.set("running", running)
    cinematic_bridges.set("travel_speed", travel_speed)
    cinematic_traffic.set("running", running)
    cinematic_traffic.set("travel_speed", travel_speed)
    elapsed += delta
    if running:
        for streak in speed_streaks:
            streak.position.z += travel_speed * delta * 1.15
            if streak.position.z > 15.0:
                streak.position.z -= 132.0
        for prop in scenery:
            prop.position.z += travel_speed * delta
            if prop.position.z > 14.0:
                prop.position.z -= 155.0
    for i in range(floaters.size()):
        var portal := floaters[i]
        portal.rotation.z = sin(elapsed * 0.38 + float(i)) * 0.025
    for i in range(lights.size()):
        var flyer := lights[i]
        flyer.position.y += sin(elapsed * 1.6 + float(i) * 1.7) * delta * 0.35
        flyer.rotation.y = sin(elapsed * 0.48 + float(i)) * 0.16
