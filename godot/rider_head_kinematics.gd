extends Node3D
## V93: articulated cinematic helmet and synchronized head/face/hair motion.
## All geometry is original and visual-only; the imported rider, hoverboard,
## collision physics and proven smartphone touch interpreter are unchanged.
const HEAD_CENTER := Vector3(0.0, 2.42, 0.01)
const SHELL_ROWS := 20
const SHELL_SIDES := 32
var clock: float = 0.0
var head_pivot: Node3D
var fins: Array[Node3D] = []
var tracked: Array[Node3D] = []
var rest_transforms: Array[Transform3D] = []
var neon_material: StandardMaterial3D

func _ready() -> void:
    head_pivot = Node3D.new()
    head_pivot.name = "ArticulatedHeadPivot"
    head_pivot.position = HEAD_CENTER
    add_child(head_pivot)
    _build_helmet()
    _build_fins()
    # Keep the original parent paths: hair/face scripts expect model -> rider.
    # Rotating their visual transforms together avoids disjointed facial motion.
    var model := get_parent() as Node3D
    for part_name in ["ExpressiveFace", "RiderHair", "SculptedVolumetricHair", "AnimatedWindHairCascade", "AnimatedBraidedPonytail"]:
        var part := model.get_node_or_null(NodePath(part_name)) as Node3D
        if part != null:
            tracked.append(part)
            rest_transforms.append(part.transform)

func _process(delta: float) -> void:
    if head_pivot == null:
        return
    var rider := get_parent().get_parent() as Node3D
    if rider == null:
        return
    clock += delta
    var steering := clampf(float(rider.get("lean")), -1.0, 1.0)
    var turbo := bool(rider.get("boosting"))
    var air := clampf(rider.position.y / 1.25, 0.0, 1.0)
    var weight := minf(1.0, delta * 7.0)
    # A readable anticipation pose: look into corners, duck into Turbo,
    # lift the chin when airborne. Gentle idle scanning adds life in menus.
    var yaw := -0.26 * steering + sin(clock * 1.1) * 0.035
    var pitch := (0.16 if turbo else -0.025) - 0.19 * air
    var roll := -0.15 * steering + sin(clock * 1.8) * 0.018
    head_pivot.rotation.y = lerpf(head_pivot.rotation.y, yaw, weight)
    head_pivot.rotation.x = lerpf(head_pivot.rotation.x, pitch, weight)
    head_pivot.rotation.z = lerpf(head_pivot.rotation.z, roll, weight)
    var rotation_basis := Basis.from_euler(head_pivot.rotation)
    for index in range(tracked.size()):
        if not is_instance_valid(tracked[index]):
            continue
        var original: Transform3D = rest_transforms[index]
        tracked[index].transform = Transform3D(
            rotation_basis * original.basis,
            HEAD_CENTER + rotation_basis * (original.origin - HEAD_CENTER)
        )
    for index in range(fins.size()):
        var side := -1.0 if index == 0 else 1.0
        var target := side * (0.08 + (0.33 if turbo else 0.0) + 0.13 * air)
        fins[index].rotation.z = lerpf(fins[index].rotation.z, target, weight)
    if neon_material != null:
        neon_material.emission_energy_multiplier = 1.35 + (0.95 if turbo else 0.20) * (0.72 + 0.28 * sin(clock * 5.0))

func _shell_material() -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = Color.WHITE
    material.vertex_color_use_as_albedo = true
    material.metallic = 0.58
    material.roughness = 0.31
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    return material

func _neon() -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = Color("#a6f7ff")
    material.emission_enabled = true
    material.emission = Color("#37d6ff")
    material.emission_energy_multiplier = 1.35
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    return material

func _helmet_point(t: float, u: float, offset: float = 0.0) -> Vector3:
    # Back-facing shell, leaving the existing eyes and mouth unobstructed.
    var angle := lerpf(-1.79, 1.79, u)
    var bulge := 0.82 + 0.18 * sin(t * PI)
    return Vector3(
        sin(angle) * (0.51 + offset) * bulge,
        -0.19 + 0.66 * t + 0.035 * cos(angle * 2.0),
        0.055 + cos(angle) * (0.49 + offset) * bulge
    )

func _vertex(tool: SurfaceTool, t: float, u: float, offset: float = 0.0) -> void:
    var shade := Color("#1a2b55").lerp(Color("#a36dd2"), 0.18 + 0.60 * t)
    shade = shade.lerp(Color("#65e2ec"), 0.12 + 0.12 * absf(2.0 * u - 1.0))
    tool.set_color(shade)
    tool.add_vertex(_helmet_point(t, u, offset))

func _shell_mesh() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for row in range(SHELL_ROWS):
        var t0 := float(row) / float(SHELL_ROWS)
        var t1 := float(row + 1) / float(SHELL_ROWS)
        for side in range(SHELL_SIDES):
            var u0 := float(side) / float(SHELL_SIDES)
            var u1 := float(side + 1) / float(SHELL_SIDES)
            _vertex(tool, t0, u0)
            _vertex(tool, t1, u0)
            _vertex(tool, t1, u1)
            _vertex(tool, t0, u0)
            _vertex(tool, t1, u1)
            _vertex(tool, t0, u1)
    tool.generate_normals()
    return tool.commit()

func _trim_mesh() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for band in [0.22, 0.76]:
        for side in range(SHELL_SIDES):
            var u0 := float(side) / float(SHELL_SIDES)
            var u1 := float(side + 1) / float(SHELL_SIDES)
            var a := _helmet_point(band, u0, 0.023)
            var b := _helmet_point(band + 0.034, u0, 0.023)
            var c := _helmet_point(band + 0.034, u1, 0.023)
            var d := _helmet_point(band, u1, 0.023)
            tool.add_vertex(a)
            tool.add_vertex(b)
            tool.add_vertex(c)
            tool.add_vertex(a)
            tool.add_vertex(c)
            tool.add_vertex(d)
    tool.generate_normals()
    return tool.commit()

func _visor_point(t: float, v: float) -> Vector3:
    var x := (t * 2.0 - 1.0) * 0.41
    return Vector3(x, 0.235 + 0.07 * (1.0 - x * x / 0.17) + v * 0.075,
        -0.415 + 0.10 * (x / 0.41) * (x / 0.41))

func _visor_mesh() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for col in range(28):
        var a := float(col) / 28.0
        var b := float(col + 1) / 28.0
        for row in range(3):
            var c := float(row) / 3.0
            var d := float(row + 1) / 3.0
            for point in [_visor_point(a,c), _visor_point(b,c), _visor_point(b,d),
                _visor_point(a,c), _visor_point(b,d), _visor_point(a,d)]:
                tool.set_color(Color(0.35, 0.93, 1.0, 0.26 + 0.24 * (1.0 - c)))
                tool.add_vertex(point)
    tool.generate_normals()
    return tool.commit()

func _build_helmet() -> void:
    var armor := _shell_material()
    neon_material = _neon()
    var shell := MeshInstance3D.new()
    shell.name = "FacetedCinematicHelmet"
    shell.mesh = _shell_mesh()
    shell.material_override = armor
    head_pivot.add_child(shell)
    var trims := MeshInstance3D.new()
    trims.name = "CurvedLuminousHelmetSeams"
    trims.mesh = _trim_mesh()
    trims.material_override = neon_material
    head_pivot.add_child(trims)
    var visor := MeshInstance3D.new()
    visor.name = "TranslucentCurvedVisor"
    visor.mesh = _visor_mesh()
    var glass := StandardMaterial3D.new()
    glass.albedo_color = Color.WHITE
    glass.vertex_color_use_as_albedo = true
    glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    glass.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    glass.cull_mode = BaseMaterial3D.CULL_DISABLED
    glass.emission_enabled = true
    glass.emission = Color("#1c8ce0")
    glass.emission_energy_multiplier = 0.55
    visor.material_override = glass
    head_pivot.add_child(visor)
    for side in [-1.0, 1.0]:
        var earpiece := MeshInstance3D.new()
        earpiece.name = "Left Sculpted Ear Armor" if side < 0.0 else "Right Sculpted Ear Armor"
        var mesh := SphereMesh.new()
        mesh.radius = 0.19
        mesh.height = 0.31
        mesh.radial_segments = 16
        mesh.rings = 8
        earpiece.mesh = mesh
        earpiece.position = Vector3(side * 0.50, 0.01, 0.06)
        earpiece.material_override = armor
        head_pivot.add_child(earpiece)
        var light := MeshInstance3D.new()
        light.name = "Neon Ear Communicator"
        var orb := SphereMesh.new()
        orb.radius = 0.095
        orb.height = 0.16
        light.mesh = orb
        light.position = Vector3(side * 0.64, 0.01, 0.07)
        light.material_override = neon_material
        head_pivot.add_child(light)

func _fin_point(t: float, u: float, side: float) -> Vector3:
    return Vector3(side * (0.06 + 0.47 * t + 0.045 * sin(u * PI)),
        0.04 + 0.32 * t + 0.09 * sin(u * PI),
        0.10 + 0.46 * t + 0.12 * u + 0.035 * sin(t * PI))

func _fin_mesh(side: float) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for row in range(12):
        var t0 := float(row) / 12.0
        var t1 := float(row + 1) / 12.0
        for col in range(6):
            var u0 := float(col) / 6.0
            var u1 := float(col + 1) / 6.0
            for point in [_fin_point(t0,u0,side), _fin_point(t1,u0,side), _fin_point(t1,u1,side),
                _fin_point(t0,u0,side), _fin_point(t1,u1,side), _fin_point(t0,u1,side)]:
                var progress := clampf((absf(point.x) - 0.06) / 0.47, 0.0, 1.0)
                var color := Color("#4ad7ff").lerp(Color("#d47bfa"), progress)
                tool.set_color(Color(color.r, color.g, color.b, 0.67 - 0.28 * progress))
                tool.add_vertex(point)
    tool.generate_normals()
    return tool.commit()

func _build_fins() -> void:
    var membrane := StandardMaterial3D.new()
    membrane.albedo_color = Color.WHITE
    membrane.vertex_color_use_as_albedo = true
    membrane.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    membrane.cull_mode = BaseMaterial3D.CULL_DISABLED
    membrane.roughness = 0.30
    membrane.metallic = 0.20
    membrane.emission_enabled = true
    membrane.emission = Color("#2976b5")
    membrane.emission_energy_multiplier = 0.55
    for side in [-1.0, 1.0]:
        var pivot := Node3D.new()
        pivot.name = "LeftReactiveAeroFin" if side < 0.0 else "RightReactiveAeroFin"
        pivot.position = Vector3(side * 0.39, 0.22, 0.19)
        head_pivot.add_child(pivot)
        fins.append(pivot)
        var fin := MeshInstance3D.new()
        fin.name = "ShadedCurvedEnergyFin"
        fin.mesh = _fin_mesh(side)
        fin.material_override = membrane
        pivot.add_child(fin)
