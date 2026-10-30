extends Node
## V124 draft: paired sculpted shoulder armor that moves with the original
## 65-bone CC0 GPU Skin. This is a connected visual silhouette pass, not a
## gameplay collision, rigid primitive, new asset or finished graphics milestone.
## Narrow deltoid caps now hug the true skinned sleeves: reduced front/back
## bulk, sloped upper rim and a raised leading lip replace inflated cylinders.
const ROWS := 20
const SEGMENTS := 24
var shells: Array[MeshInstance3D] = []
var generated_vertices: int = 0
var shoulder_span: float = 0.0

func install(source_meshes: Array[MeshInstance3D], rig: Skeleton3D, face_sign: float) -> bool:
    if rig == null:
        return false
    for body in source_meshes:
        if body == null or body.mesh == null or body.skin == null:
            continue
        if not String(body.name).contains("SuperHero"):
            continue
        var spine := _bind(body.skin, rig, "spine_02")
        if spine < 0:
            spine = _bind(body.skin, rig, "spine_01")
        var pelvis := _bind(body.skin, rig, "pelvis")
        var left_arm := _bind(body.skin, rig, "upperarm_l")
        var right_arm := _bind(body.skin, rig, "upperarm_r")
        if spine < 0 or pelvis < 0 or left_arm < 0 or right_arm < 0:
            continue
        var bounds := body.mesh.get_aabb()
        if bounds.size.x < 0.2 or bounds.size.y < 0.5:
            continue
        var shoulder_z := _shoulder_depth(body.mesh, bounds)
        for side in [-1, 1]:
            var arm := left_arm if side < 0 else right_arm
            var shape := _sculpt(bounds, shoulder_z, float(side), spine, pelvis, arm, face_sign)
            if shape == null:
                return false
            var part := MeshInstance3D.new()
            part.name = "LeftSkinnedFlightPauldron" if side < 0 else "RightSkinnedFlightPauldron"
            part.mesh = shape
            part.skin = body.skin
            part.skeleton = body.skeleton
            part.transform = body.transform
            var mat := ShaderMaterial.new()
            mat.shader = preload("res://rider_external_pauldron.gdshader")
            part.material_override = mat
            body.get_parent().add_child(part)
            shells.append(part)
            generated_vertices += shape.surface_get_arrays(0)[Mesh.ARRAY_VERTEX].size()
        var left_bounds := shells[0].mesh.get_aabb()
        var right_bounds := shells[1].mesh.get_aabb()
        shoulder_span = right_bounds.end.x - left_bounds.position.x
        return shells.size() == 2
    return false

func _bind(skin: Skin, rig: Skeleton3D, target: String) -> int:
    for index in range(skin.get_bind_count()):
        var name_text := String(skin.get_bind_name(index))
        var bone_id := skin.get_bind_bone(index)
        if name_text == target or (name_text.is_empty() and bone_id >= 0 and bone_id < rig.get_bone_count() and rig.get_bone_name(bone_id) == target):
            return index
    return -1

func _shoulder_depth(mesh: Mesh, bounds: AABB) -> float:
    var total := 0.0
    var count := 0
    for surface in range(mesh.get_surface_count()):
        var vertices: PackedVector3Array = mesh.surface_get_arrays(surface)[Mesh.ARRAY_VERTEX]
        for p in vertices:
            var y := (p.y - bounds.position.y) / bounds.size.y
            var x := absf(p.x - bounds.get_center().x) / bounds.size.x
            if y > 0.64 and y < 0.76 and x > 0.11 and x < 0.29:
                total += p.z
                count += 1
    return total / float(count) if count > 0 else bounds.get_center().z

func _sculpt(bounds: AABB, depth: float, side: float, spine: int, pelvis: int,
        arm: int, face_sign: float) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for row in range(ROWS):
        var t0 := float(row) / float(ROWS)
        var t1 := float(row + 1) / float(ROWS)
        for segment in range(SEGMENTS):
            var a0 := TAU * float(segment) / float(SEGMENTS)
            var a1 := TAU * float(segment + 1) / float(SEGMENTS)
            _point(tool, bounds, depth, side, spine, pelvis, arm, face_sign, t0, a0, false)
            _point(tool, bounds, depth, side, spine, pelvis, arm, face_sign, t1, a0, false)
            _point(tool, bounds, depth, side, spine, pelvis, arm, face_sign, t1, a1, false)
            _point(tool, bounds, depth, side, spine, pelvis, arm, face_sign, t0, a0, false)
            _point(tool, bounds, depth, side, spine, pelvis, arm, face_sign, t1, a1, false)
            _point(tool, bounds, depth, side, spine, pelvis, arm, face_sign, t0, a1, false)
    # Actual top and bottom closure: no open cylinder / fake flat cap.
    for segment in range(SEGMENTS):
        var a0 := TAU * float(segment) / float(SEGMENTS)
        var a1 := TAU * float(segment + 1) / float(SEGMENTS)
        _point(tool, bounds, depth, side, spine, pelvis, arm, face_sign, 0.0, a0, true)
        _point(tool, bounds, depth, side, spine, pelvis, arm, face_sign, 0.0, a1, false)
        _point(tool, bounds, depth, side, spine, pelvis, arm, face_sign, 0.0, a0, false)
        _point(tool, bounds, depth, side, spine, pelvis, arm, face_sign, 1.0, a0, true)
        _point(tool, bounds, depth, side, spine, pelvis, arm, face_sign, 1.0, a0, false)
        _point(tool, bounds, depth, side, spine, pelvis, arm, face_sign, 1.0, a1, false)
    # Reuse continuous parametric normals across adjacent unindexed quads;
    # the previous per-triangle generated normals visibly faceted the armor.
    return tool.commit()

func _point(tool: SurfaceTool, bounds: AABB, depth: float, side: float,
        spine: int, pelvis: int, arm: int, face_sign: float, t: float,
        angle: float, center: bool) -> void:
    var width := bounds.size.x
    var height := bounds.size.y
    var profile := maxf(0.10, pow(maxf(0.0, sin(PI * t)), 0.86))
    if center:
        profile = 0.0
    var sweep := 0.010 * sin(PI * t)
    var x := bounds.get_center().x + side * width * (0.168 + sweep + cos(angle) * 0.057 * profile)
    var y := bounds.position.y + height * (0.756 - t * 0.108 + 0.008 * cos(angle) * sin(PI * t))
    # A curved back-to-front shell follows the actual torso depth, with a
    # raised outer ridge and a subtle aerodynamic taper toward the waist.
    var ridge := 0.007 * width * pow(absf(cos(angle)), 4.0) * sin(PI * t)
    var front_lip := 0.010 * width * maxf(0.0, sin(angle) * face_sign) * profile
    var z := depth + sin(angle) * width * (0.058 * profile + 0.008) + (ridge + front_lip) * face_sign
    var arm_weight := (0.42 + 0.22 * maxf(0.0, cos(angle))) * (1.0 - 0.22 * t)
    var pelvis_weight := 0.07 + 0.15 * t
    var spine_weight := 1.0 - arm_weight - pelvis_weight
    tool.set_bones(PackedInt32Array([spine, pelvis, arm, spine]))
    tool.set_weights(PackedFloat32Array([spine_weight, pelvis_weight, arm_weight, 0.0]))
    tool.set_uv(Vector2(float(angle) / TAU, t))
    var highlight := pow(maxf(0.0, cos(angle)), 2.0)
    var front := maxf(0.0, sin(angle) * face_sign)
    var tint := Color(0.11 + 0.14 * highlight, 0.18 + 0.12 * front, 0.31 + 0.19 * highlight, 1.0)
    tool.set_color(tint)
    tool.set_normal((Vector3.UP if t < 0.5 else Vector3.DOWN) if center else
        Vector3(cos(angle), 0.15 - 0.30 * t, sin(angle)).normalized())
    tool.add_vertex(Vector3(x, y, z))
