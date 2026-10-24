extends Node3D
## Original V43 boss: curved vertex-colored armor and articulated fins.
## No third-party assets, network calls or extra services.
var active := false
var hit_flash := 0.0
var elapsed := 0.0
var core: MeshInstance3D
var halo: Node3D
var fins: Array[Node3D] = []

func _material(color: Color, luminous: bool = false) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.metallic = 0.45
    m.roughness = 0.26
    if luminous:
        m.emission_enabled = true
        m.emission = color
        m.emission_energy_multiplier = 2.4
    return m

func _shell_point(t: float, angle: float) -> Vector3:
    var radius := (0.66 + 1.02 * sin(t * PI)) * (1.0 + 0.10 * cos(angle * 6.0 + t * 4.0))
    return Vector3(cos(angle) * radius, 0.3 + t * 3.6, sin(angle) * radius * 0.85)

func _shell_mesh() -> ArrayMesh:
    var surface := SurfaceTool.new()
    surface.begin(Mesh.PRIMITIVE_TRIANGLES)
    const SIDES := 28
    const LEVELS := 15
    for level in range(LEVELS - 1):
        var t0 := float(level) / float(LEVELS - 1)
        var t1 := float(level + 1) / float(LEVELS - 1)
        for side in range(SIDES):
            var a0 := TAU * float(side) / float(SIDES)
            var a1 := TAU * float(side + 1) / float(SIDES)
            var color := Color("#303a87").lerp(Color("#c45fda"), t0)
            if side % 5 == 0:
                color = color.lerp(Color("#8bfcff"), 0.32)
            surface.set_color(color)
            var p00 := _shell_point(t0, a0)
            var p01 := _shell_point(t0, a1)
            var p10 := _shell_point(t1, a0)
            var p11 := _shell_point(t1, a1)
            surface.add_vertex(p00)
            surface.add_vertex(p10)
            surface.add_vertex(p11)
            surface.add_vertex(p00)
            surface.add_vertex(p11)
            surface.add_vertex(p01)
    surface.generate_normals()
    return surface.commit()

func _blade_mesh() -> ArrayMesh:
    var surface := SurfaceTool.new()
    surface.begin(Mesh.PRIMITIVE_TRIANGLES)
    for i in range(28):
        var t0 := float(i) / 28.0
        var t1 := float(i + 1) / 28.0
        var p0 := Vector3(0.75 + t0 * 2.65, 1.9 + sin(t0 * PI) * 1.4, 0.0)
        var p1 := Vector3(0.75 + t1 * 2.65, 1.9 + sin(t1 * PI) * 1.4, 0.0)
        var mid0 := Vector3(p0.x, p0.y + 0.36 * (1.0 - t0), -0.30 * sin(t0 * PI))
        var mid1 := Vector3(p1.x, p1.y + 0.36 * (1.0 - t1), -0.30 * sin(t1 * PI))
        surface.set_color(Color("#61d9ff").lerp(Color("#e679fc"), t0))
        surface.add_vertex(p0)
        surface.add_vertex(mid0)
        surface.add_vertex(mid1)
        surface.add_vertex(p0)
        surface.add_vertex(mid1)
        surface.add_vertex(p1)
    surface.generate_normals()
    return surface.commit()

func _ready() -> void:
    var shell := MeshInstance3D.new()
    shell.name = "Sculpted guardian armor"
    shell.mesh = _shell_mesh()
    var shell_mat := _material(Color.WHITE)
    shell_mat.vertex_color_use_as_albedo = true
    shell.material_override = shell_mat
    add_child(shell)
    core = MeshInstance3D.new()
    core.name = "Pulsing guardian energy core"
    var core_mesh := SphereMesh.new()
    core_mesh.radial_segments = 24
    core_mesh.rings = 12
    core.mesh = core_mesh
    core.material_override = _material(Color("#71faff"), true)
    core.position = Vector3(0, 2.1, 1.42)
    core.scale = Vector3(0.72, 0.83, 0.33)
    add_child(core)
    halo = Node3D.new()
    halo.name = "Rotating guardian halo"
    halo.position.y = 2.2
    add_child(halo)
    for i in range(2):
        var ring := MeshInstance3D.new()
        ring.name = "Guardian energy ring %d" % i
        var ring_mesh := TorusMesh.new()
        ring_mesh.inner_radius = 1.85 + float(i) * 0.40
        ring_mesh.outer_radius = 1.93 + float(i) * 0.40
        ring_mesh.rings = 40
        ring_mesh.ring_segments = 8
        ring.mesh = ring_mesh
        ring.material_override = _material(Color("#7bfaff") if i == 0 else Color("#fc82ff"), true)
        ring.rotation.x = 0.25 + float(i) * 0.55
        halo.add_child(ring)
    var fin_mesh := _blade_mesh()
    var fin_mat := _material(Color.WHITE)
    fin_mat.vertex_color_use_as_albedo = true
    for i in range(4):
        var fin := Node3D.new()
        fin.name = "Animated guardian blade %d" % i
        fin.rotation.y = TAU * float(i) / 4.0
        add_child(fin)
        var blade := MeshInstance3D.new()
        blade.name = "Curved crystalline blade"
        blade.mesh = fin_mesh
        blade.material_override = fin_mat
        fin.add_child(blade)
        fins.append(fin)

func take_hit() -> void:
    hit_flash = 0.5

func _process(delta: float) -> void:
    if not active:
        return
    elapsed += delta
    hit_flash = maxf(0.0, hit_flash - delta)
    halo.rotation.y += delta * 0.65
    halo.rotation.z = sin(elapsed * 0.8) * 0.18
    core.scale = Vector3(0.72, 0.83, 0.33) * (1.0 + sin(elapsed * 5.0) * 0.13 + hit_flash * 0.5)
    for i in range(fins.size()):
        fins[i].rotation.z = sin(elapsed * 1.5 + float(i) * 1.7) * 0.18
