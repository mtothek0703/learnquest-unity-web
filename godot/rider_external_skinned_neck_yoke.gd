extends Node
## V124 draft: one closed, anatomically tapered neck-to-shoulder flight yoke.
## The 360-degree surface is genuinely weighted to four ORIGINAL CC0 bones,
## shares the imported Skin and never creates gameplay collision objects.
## Open front / raised rear preserves the face in both landscape cameras.
const ROWS := 14
const SEGMENTS := 32
var collar: MeshInstance3D
var generated_vertices: int = 0
var face_direction: float = -1.0
var source_bounds: AABB

func install(source_meshes: Array[MeshInstance3D], rig: Skeleton3D, face_sign: float) -> bool:
    if rig == null:
        return false
    face_direction = 1.0 if face_sign > 0.0 else -1.0
    for body in source_meshes:
        if body == null or body.mesh == null or body.skin == null:
            continue
        if not String(body.name).contains("SuperHero"):
            continue
        var spine_low := _bind(body.skin, rig, "spine_01")
        var spine_high := _bind(body.skin, rig, "spine_02")
        var neck := _bind(body.skin, rig, "neck_01")
        var head := _bind(body.skin, rig, "Head")
        if spine_low < 0 or spine_high < 0 or neck < 0 or head < 0:
            continue
        source_bounds = body.mesh.get_aabb()
        if source_bounds.size.x < 0.2 or source_bounds.size.y < 0.5:
            continue
        var surface := SurfaceTool.new()
        surface.begin(Mesh.PRIMITIVE_TRIANGLES)
        var joints := PackedInt32Array([spine_low, spine_high, neck, head])
        for row in range(ROWS):
            var t0 := float(row) / float(ROWS)
            var t1 := float(row + 1) / float(ROWS)
            for segment in range(SEGMENTS):
                var a0 := TAU * float(segment) / float(SEGMENTS)
                var a1 := TAU * float(segment + 1) / float(SEGMENTS)
                for inside in [false, true]:
                    _quad(surface, joints, t0, t1, a0, a1, inside)
        # Closed upper/lower rims, including the inside of the neck opening.
        for segment in range(SEGMENTS):
            var a0 := TAU * float(segment) / float(SEGMENTS)
            var a1 := TAU * float(segment + 1) / float(SEGMENTS)
            for t in [0.0, 1.0]:
                _rim(surface, joints, t, a0, a1)
        var mesh := surface.commit()
        if mesh == null:
            return false
        collar = MeshInstance3D.new()
        collar.name = "TrueSkinnedOpenNeckYoke"
        collar.mesh = mesh
        collar.skin = body.skin
        collar.skeleton = body.skeleton
        collar.transform = body.transform
        var material := StandardMaterial3D.new()
        material.albedo_color = Color(0.10, 0.16, 0.28)
        material.vertex_color_use_as_albedo = true
        material.metallic = 0.22
        material.roughness = 0.58
        material.cull_mode = BaseMaterial3D.CULL_BACK
        collar.material_override = material
        body.get_parent().add_child(collar)
        generated_vertices = mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX].size()
        return generated_vertices > 5000
    return false

func _bind(skin: Skin, rig: Skeleton3D, target: String) -> int:
    for index in range(skin.get_bind_count()):
        var name_text := String(skin.get_bind_name(index))
        var bone_id := skin.get_bind_bone(index)
        if name_text == target or (name_text.is_empty() and bone_id >= 0 and
                bone_id < rig.get_bone_count() and rig.get_bone_name(bone_id) == target):
            return index
    return -1

func _collar_point(bounds: AABB, angle: float, t: float, inside: bool) -> Vector3:
    var front := maxf(0.0, sin(angle) * face_direction)
    var back := maxf(0.0, -sin(angle) * face_direction)
    # V-shaped low front, high protective rear and smoothly shrinking neck.
    # Both radii are relative to the actual imported body, never world units.
    # A low V-neck in front replaces the oversized horizontal chest ring,
    # while the rear collar remains raised behind the original skinned neck.
    var top := 0.765 + 0.042 * back - 0.018 * front
    var base := 0.730 + 0.006 * back
    var height_fraction := lerpf(base, top, t)
    var flare := 1.0 - smoothstep(0.0, 1.0, t)
    # Fit the collar to the anatomical neck/upper trapezius instead of the
    # previous broad shoulder-width disc in 16:9 chase and front views.
    var radius_x := bounds.size.x * (0.110 + 0.063 * flare)
    var radius_z := bounds.size.x * (0.078 + 0.050 * flare)
    var inset := bounds.size.x * 0.010 if inside else 0.0
    var seam := 0.004 * bounds.size.y * sin(PI * t) * cos(angle * 2.0)
    return Vector3(
        bounds.get_center().x + cos(angle) * (radius_x - inset),
        bounds.position.y + bounds.size.y * height_fraction + seam,
        bounds.get_center().z + sin(angle) * (radius_z - inset))

func _weights(t: float, back: float) -> PackedFloat32Array:
    var low := 0.21 + 0.0 * back
    var high := 0.60 - 0.40 * t
    var neck := 0.10 + 0.50 * t
    var head := 0.05 + 0.10 * t * back
    # Normalize all four original influences, preserving positive lower-spine
    # support even when the Head turns independently of the shoulders.
    var total := low + high + neck + head
    return PackedFloat32Array([low / total, high / total, neck / total, head / total])

func _vertex(surface: SurfaceTool, joints: PackedInt32Array,
        bounds: AABB, angle: float, t: float, inside: bool) -> void:
    var back := maxf(0.0, -sin(angle) * face_direction)
    var front := maxf(0.0, sin(angle) * face_direction)
    var outward := Vector3(cos(angle), 0.22 - 0.35 * t, sin(angle)).normalized()
    surface.set_normal(-outward if inside else outward)
    surface.set_bones(joints)
    surface.set_weights(_weights(t, back))
    surface.set_uv(Vector2(angle / TAU, t))
    # One continuous dark technical textile with muted cyan raised rear edge.
    surface.set_color(Color(0.75 + 0.15 * back, 0.84 + 0.10 * back,
        0.95, 1.0) if t > 0.90 else Color(0.75, 0.82, 0.94, 1.0))
    surface.add_vertex(_collar_point(bounds, angle, t, inside))

func _quad(surface: SurfaceTool, joints: PackedInt32Array,
        t0: float, t1: float, a0: float, a1: float, inside: bool) -> void:
    var corners := [
        Vector2(a0, t0), Vector2(a0, t1), Vector2(a1, t1),
        Vector2(a0, t0), Vector2(a1, t1), Vector2(a1, t0)]
    if inside:
        corners.reverse()
    for p in corners:
        _vertex(surface, joints, source_bounds, p.x, p.y, inside)

func _rim(surface: SurfaceTool, joints: PackedInt32Array,
        t: float, a0: float, a1: float) -> void:
    var points := [
        Vector2(a0, 0.0), Vector2(a1, 0.0), Vector2(a1, 1.0),
        Vector2(a0, 0.0), Vector2(a1, 1.0), Vector2(a0, 1.0)]
    if t < 0.5:
        points.reverse()
    for p in points:
        _vertex(surface, joints, source_bounds, p.x, t, p.y > 0.5)
