extends Node3D
## Sprint 1 / V104: volumetric swept hair locks with an actual GPU skin
## bound to the ORIGINAL 13-bone body rig. Replaces overlapping rigid scalp
## plates; retains the expressive wind-driven curls and ponytail. No assets,
## input, physics, or collision changes. Built once for mobile WebGL.
const CAP_ROWS := 16
const CAP_SIDES := 36
const LOCK_ROWS := 20
const LOCK_COLS := 10
var skeleton: Skeleton3D
var skinned_hair: MeshInstance3D

func _ready() -> void:
    var model := get_parent() as Node3D
    var rig := model.get_node_or_null("OriginalBodySkinRig") as Node3D
    if rig == null:
        return
    skeleton = rig.get_node_or_null("OriginalBodySkeleton13") as Skeleton3D
    if skeleton == null or skeleton.get_bone_count() != 13:
        return
    var surface := _make_hair()
    if surface == null or surface.get_surface_count() == 0:
        return
    skinned_hair = MeshInstance3D.new()
    skinned_hair.name = "UnifiedSkinnedHairSilhouette"
    skinned_hair.mesh = surface
    skinned_hair.skin = skeleton.create_skin_from_rest_transforms()
    var material := StandardMaterial3D.new()
    material.albedo_color = Color.WHITE
    material.vertex_color_use_as_albedo = true
    material.metallic = 0.14
    material.roughness = 0.44
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    skinned_hair.material_override = material
    add_child(skinned_hair)
    skinned_hair.skeleton = skinned_hair.get_path_to(skeleton)
    # Retire rigid duplicates ONLY after the shared 13-bone skin exists.
    # Preserve articulated wind locks, both temple curls, braid and cascade.
    var old := model.get_node_or_null("SculptedVolumetricHair") as Node3D
    if old != null:
        for part in old.get_children():
            if part is MeshInstance3D and (part.name == "VolumetricScalp" or
                    part.name.begins_with("SweptLayer") or
                    part.name.begins_with("LuminousHairSheen")):
                part.visible = false
    # Five pre-V103 rigid swept tufts still covered the newly skinned scalp.
    # Hide only those static meshes; keep all three reactive WindHair pivots.
    var rigid := model.get_node_or_null("RiderHair") as Node3D
    if rigid != null:
        for part in rigid.get_children():
            if part is MeshInstance3D and String(part.name).begins_with("SweptHair"):
                part.visible = false

func _emit(tool: SurfaceTool, point: Vector3, t: float, u: float, accent: float) -> void:
    # Blend Head/Neck on long nape locks, while scalp stays attached to Head.
    # Four normalized weights match the original GPU skin layout.
    var head := 0.74 + 0.26 * smoothstep(2.30, 2.88, point.y)
    tool.set_bones(PackedInt32Array([4, 3, 2, 1]))
    tool.set_weights(PackedFloat32Array([head, 1.0 - head, 0.0, 0.0]))
    var root_color := Color("#21153e")
    var tip_color := Color("#9b4aaf")
    var shade := root_color.lerp(tip_color, clampf(0.16 + t * 0.69 + accent * 0.10, 0.0, 1.0))
    # Narrow strand highlights reveal rounded volume in mobile chase views.
    var glint := pow(maxf(0.0, cos(u * TAU - 0.7)), 6.0)
    shade = shade.lightened(0.08 + 0.18 * glint)
    tool.set_color(shade)
    tool.add_vertex(point)

func _cap_point(t: float, angle: float) -> Vector3:
    var latitude := t * PI * 0.5
    var spread := sin(latitude)
    return Vector3(
        0.492 * spread * cos(angle),
        2.69 + 0.435 * cos(latitude),
        0.060 + 0.495 * spread * sin(angle)
    )

func _lock_tube_point(t: float, angle: float, index: int) -> Vector3:
    # Each lock is a tapered, closed 3D volume, not a flat ribbon.
    # The root intersects the scalp; the tail sweeps behind the helmet.
    # Circular cross-sections make a readable silhouette from both cameras.
    var side := float(index) - 3.0
    var length := 0.80 + 0.07 * float(index % 3)
    var sway := 0.07 * sin(t * PI) * (1.0 if index % 2 == 0 else -1.0)
    var taper := pow(1.0 - t, 0.72)
    var radius_x := (0.10 + 0.02 * float(index % 2)) * (0.08 + 0.92 * taper)
    var radius_z := (0.065 + 0.01 * float(index % 3)) * (0.10 + 0.90 * taper)
    return Vector3(
        side * 0.145 + sway + cos(angle) * radius_x,
        2.96 - length * t + 0.018 * sin(angle) * sin(t * PI),
        0.405 + 0.39 * t + 0.035 * sin(t * PI) + sin(angle) * radius_z
    )

func _fringe_point(t: float, u: float, index: int) -> Vector3:
    var across := 2.0 * u - 1.0
    var side := float(index) - 1.5
    var width := 0.15 * (1.0 - 0.65 * t)
    return Vector3(
        side * 0.205 + across * width * 0.5 + side * 0.012 * t,
        2.88 - 0.21 * t + 0.025 * sin(t * PI),
        -0.395 - 0.060 * sin(t * PI) - 0.024 * t
    )

func _quad(tool: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3,
        t0: float, t1: float, u0: float, u1: float, accent: float) -> void:
    _emit(tool, a, t0, u0, accent)
    _emit(tool, b, t1, u0, accent)
    _emit(tool, c, t1, u1, accent)
    _emit(tool, a, t0, u0, accent)
    _emit(tool, c, t1, u1, accent)
    _emit(tool, d, t0, u1, accent)

func _make_hair() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for row in range(CAP_ROWS):
        var t0 := float(row) / float(CAP_ROWS)
        var t1 := float(row + 1) / float(CAP_ROWS)
        for column in range(CAP_SIDES):
            var a0 := TAU * float(column) / float(CAP_SIDES)
            var a1 := TAU * float(column + 1) / float(CAP_SIDES)
            _quad(tool, _cap_point(t0, a0), _cap_point(t1, a0),
                _cap_point(t1, a1), _cap_point(t0, a1),
                t0, t1, float(column) / float(CAP_SIDES),
                float(column + 1) / float(CAP_SIDES), 0.0)
    for index in range(7):
        for row in range(LOCK_ROWS):
            var t0 := float(row) / float(LOCK_ROWS)
            var t1 := float(row + 1) / float(LOCK_ROWS)
            for column in range(LOCK_COLS):
                var u0 := float(column) / float(LOCK_COLS)
                var u1 := float(column + 1) / float(LOCK_COLS)
                _quad(tool, _lock_tube_point(t0, u0 * TAU, index),
                    _lock_tube_point(t1, u0 * TAU, index),
                    _lock_tube_point(t1, u1 * TAU, index),
                    _lock_tube_point(t0, u1 * TAU, index),
                    t0, t1, u0, u1, float(index) / 7.0)
    # Four sculpted, side-parted bangs complete the face-to-scalp transition.
    # They end above the eyebrows, preserving eye/blink readability.
    for index in range(4):
        for row in range(8):
            var t0 := float(row) / 8.0
            var t1 := float(row + 1) / 8.0
            for column in range(6):
                var u0 := float(column) / 6.0
                var u1 := float(column + 1) / 6.0
                _quad(tool, _fringe_point(t0, u0, index), _fringe_point(t1, u0, index),
                    _fringe_point(t1, u1, index), _fringe_point(t0, u1, index),
                    t0, t1, u0, u1, 0.2)
    tool.generate_normals()
    return tool.commit()
