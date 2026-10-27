extends Node3D
## Sprint 1 / V98: chest/hips pose drives existing detailed costume assemblies.
## No new geometry, collisions or touch-input changes. Child animations (cloth,
## glowing reactor, exosuit and cape) remain independently animated.
const PARTS := [
    "AnimatedTailoredFlightJacket",
    "AnimatedSculptedCoat",
    "AnimatedAeroHarness",
    "AnimatedSkeletalExosuit",
    "AnimatedMotionCloak"
]
const CHEST_INFLUENCE := [1.0, 0.72, 0.90, 0.78, 0.80]
const CHEST_ANCHOR := Vector3(0.0, 1.95, 0.0)
var skeleton: Skeleton3D
var hips_bind_origin := Vector3.ZERO
var chest_bind_origin := Vector3.ZERO
var tracked: Array[Node3D] = []
var rest_transforms: Array[Transform3D] = []
var strengths: Array[float] = []

func _ready() -> void:
    # The original body pose runs at 10, face/helmet/hair at 20.
    process_priority = 30
    var model := get_parent() as Node3D
    var rig := model.get_node_or_null("OriginalBodySkinRig") as Node3D
    if rig == null:
        return
    skeleton = rig.get_node_or_null("OriginalBodySkeleton13") as Skeleton3D
    if skeleton == null:
        return
    var bind := skeleton.create_skin_from_rest_transforms()
    hips_bind_origin = bind.get_bind_pose(0).affine_inverse().origin
    chest_bind_origin = bind.get_bind_pose(2).affine_inverse().origin
    for i in range(PARTS.size()):
        var part := model.get_node_or_null(NodePath(PARTS[i])) as Node3D
        if part != null:
            tracked.append(part)
            rest_transforms.append(part.transform)
            strengths.append(CHEST_INFLUENCE[i])

func _process(_delta: float) -> void:
    if skeleton == null:
        return
    var hips := skeleton.get_bone_global_pose(0)
    var chest := skeleton.get_bone_global_pose(2)
    var hips_shift := hips.origin - hips_bind_origin
    var chest_shift := chest.origin - chest_bind_origin
    var hip_rotation := Quaternion(hips.basis.orthonormalized())
    var chest_rotation := Quaternion(chest.basis.orthonormalized())
    for i in range(tracked.size()):
        var part := tracked[i]
        if not is_instance_valid(part):
            continue
        var strength := strengths[i]
        var rotation_basis := Basis(hip_rotation.slerp(chest_rotation, strength))
        var displacement := hips_shift.lerp(chest_shift, strength)
        var rest: Transform3D = rest_transforms[i]
        part.transform = Transform3D(
            rotation_basis * rest.basis,
            CHEST_ANCHOR + displacement + rotation_basis * (rest.origin - CHEST_ANCHOR)
        )
