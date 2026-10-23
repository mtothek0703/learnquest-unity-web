extends Node3D
## Original, lightweight facial model for the imported rider. No external assets.
## Curved mesh brows/smile, layered eyes, blush, and animated blinks replace
## the previous box-based face without touching physics or the hoverboard.
var clock: float = 0.0
var eyes: Array[Node3D] = []
var brows: Array[Node3D] = []

func _ready() -> void:
    _build_face()

func _process(delta: float) -> void:
    var rider := get_parent().get_parent()
    var turbo := bool(rider.get("boosting")) if rider != null else false
    clock += delta * (1.3 if turbo else 1.0)
    var openness := _blink_factor(clock)
    for eye in eyes:
        eye.scale.y = lerpf(eye.scale.y, openness, minf(1.0, delta * 32.0))
    for i in range(brows.size()):
        var sign := -1.0 if i == 0 else 1.0
        var target := sign * (0.10 if turbo else 0.0)
        brows[i].rotation.z = lerpf(brows[i].rotation.z, target, minf(1.0, delta * 8.0))

func _blink_factor(time: float) -> float:
    var phase := fposmod(time, 4.0)
    if phase > 3.82 and phase < 3.98:
        return clampf(absf(phase - 3.90) / 0.08, 0.08, 1.0)
    return 1.0

func _material(color: Color, metallic: float = 0.0, glow: bool = false) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.metallic = metallic
    material.roughness = 0.48
    if glow:
        material.emission_enabled = true
        material.emission = color * 0.65
        material.emission_energy_multiplier = 1.8
    return material

func _sphere(name: String, parent: Node3D, position_3d: Vector3, radius: float, height: float, material: StandardMaterial3D) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.name = name
    var mesh := SphereMesh.new()
    mesh.radius = radius
    mesh.height = height
    mesh.radial_segments = 12
    mesh.rings = 6
    node.mesh = mesh
    node.material_override = material
    node.position = position_3d
    parent.add_child(node)
    return node

func _tube(name: String, parent: Node3D, points: PackedVector3Array, radius: float, material: StandardMaterial3D) -> MeshInstance3D:
    # Six-sided swept tube: smooth curved silhouette, minimal mobile GPU cost.
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    const SIDES := 8
    for i in range(points.size() - 1):
        var a := points[i]
        var b := points[i + 1]
        var tangent := (b - a).normalized()
        var across := Vector3(-tangent.y, tangent.x, 0.0).normalized()
        for j in range(SIDES):
            var angle0 := TAU * float(j) / float(SIDES)
            var angle1 := TAU * float(j + 1) / float(SIDES)
            var p00 := a + across * cos(angle0) * radius + Vector3.FORWARD * sin(angle0) * radius
            var p01 := a + across * cos(angle1) * radius + Vector3.FORWARD * sin(angle1) * radius
            var p10 := b + across * cos(angle0) * radius + Vector3.FORWARD * sin(angle0) * radius
            var p11 := b + across * cos(angle1) * radius + Vector3.FORWARD * sin(angle1) * radius
            tool.add_vertex(p00)
            tool.add_vertex(p10)
            tool.add_vertex(p11)
            tool.add_vertex(p00)
            tool.add_vertex(p11)
            tool.add_vertex(p01)
    tool.generate_normals()
    var node := MeshInstance3D.new()
    node.name = name
    node.mesh = tool.commit()
    node.material_override = material
    parent.add_child(node)
    return node

func _build_face() -> void:
    var white := _material(Color(0.99, 0.96, 0.91))
    var iris := _material(Color(0.15, 0.42, 0.74))
    var pupil := _material(Color(0.04, 0.05, 0.12))
    var glint := _material(Color(0.9, 1.0, 1.0), 0.0, true)
    var outline := _material(Color(0.14, 0.07, 0.21))
    var blush := _material(Color(0.94, 0.38, 0.49))
    var skin := _material(Color(0.93, 0.67, 0.49))
    var headset := _material(Color(0.12, 0.16, 0.34), 0.55)
    var headset_glow := _material(Color(0.16, 0.86, 1.0), 0.12, true)
    for i in range(2):
        var side := -1.0 if i == 0 else 1.0
        var eye := Node3D.new()
        eye.name = "LeftEye" if i == 0 else "RightEye"
        eye.position = Vector3(side * 0.17, 2.47, -0.405)
        add_child(eye)
        _sphere("EyeOutline", eye, Vector3(0.0, 0.0, -0.015), 0.125, 0.19, outline)
        _sphere("EyeWhite", eye, Vector3(0.0, 0.0, -0.052), 0.103, 0.16, white)
        _sphere("Iris", eye, Vector3(-side * 0.012, 0.0, -0.129), 0.060, 0.094, iris)
        _sphere("Pupil", eye, Vector3(-side * 0.012, 0.0, -0.168), 0.035, 0.060, pupil)
        _sphere("EyeGlint", eye, Vector3(-side * 0.029, 0.023, -0.191), 0.017, 0.025, glint)
        eyes.append(eye)
        var brow := Node3D.new()
        brow.name = "LeftBrow" if i == 0 else "RightBrow"
        brow.position = Vector3(side * 0.17, 2.62, -0.438)
        add_child(brow)
        _tube("SculptedBrow", brow, PackedVector3Array([
            Vector3(-0.105, -0.018, 0.0),
            Vector3(-0.055, 0.015, -0.015),
            Vector3(0.0, 0.027, -0.018),
            Vector3(0.055, 0.015, -0.015),
            Vector3(0.105, -0.018, 0.0)
        ]), 0.021, outline)
        brows.append(brow)
        _sphere("Cheek%d" % i, self, Vector3(side * 0.33, 2.31, -0.398), 0.078, 0.06, blush)
        # Layered neon headset remains readable from side and chase views.
        _sphere("HeadsetShell%d" % i, self, Vector3(side * 0.48, 2.43, 0.025), 0.16, 0.22, headset)
        _sphere("HeadsetLight%d" % i, self, Vector3(side * 0.55, 2.43, 0.035), 0.115, 0.14, headset_glow)
    _sphere("SculptedNose", self, Vector3(0.0, 2.34, -0.48), 0.066, 0.105, skin)
    _tube("CurvedSmile", self, PackedVector3Array([
        Vector3(-0.17, 2.235, -0.430),
        Vector3(-0.11, 2.205, -0.446),
        Vector3(-0.05, 2.193, -0.454),
        Vector3(0.0, 2.19, -0.457),
        Vector3(0.05, 2.193, -0.454),
        Vector3(0.11, 2.205, -0.446),
        Vector3(0.17, 2.235, -0.430)
    ]), 0.014, outline)
