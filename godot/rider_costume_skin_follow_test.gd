extends SceneTree
## Sprint 1 / V98: original skin, face, hair, helmet and coat must share poses.
## Explicit deterministic poses avoid mistaking node existence for animation.
func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("COSTUME SKIN FOLLOW TEST FAILED: " + message)
    quit(1)

func _check() -> void:
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    root.add_child(rider)
    await process_frame
    var model := rider.get_node_or_null("ImportedRider") as Node3D
    if model == null:
        _fail("imported glTF rider missing")
        return
    var rig := model.get_node_or_null("OriginalBodySkinRig") as Node3D
    var head := model.get_node_or_null("AnimatedHeadKinematics") as Node3D
    var follower := model.get_node_or_null("SkinnedCostumePoseFollower") as Node3D
    if rig == null or head == null or follower == null:
        _fail("shared original-body, head and costume pose nodes required")
        return
    var skeleton := rig.get_node_or_null("OriginalBodySkeleton13") as Skeleton3D
    if skeleton == null or skeleton.get_bone_count() != 13:
        _fail("original imported body must have the 13-bone skin")
        return
    var head_pivot := head.get_node_or_null("ArticulatedHeadPivot") as Node3D
    var face := model.get_node_or_null("ExpressiveFace") as Node3D
    var hair := model.get_node_or_null("AnimatedWindHairCascade") as Node3D
    var jacket := model.get_node_or_null("AnimatedTailoredFlightJacket") as Node3D
    var coat := model.get_node_or_null("AnimatedSculptedCoat") as Node3D
    if head_pivot == null or face == null or hair == null or jacket == null or coat == null:
        _fail("visible helmet, face, hair, jacket and coat are required")
        return
    var face_rest := face.transform
    var hair_rest := hair.transform
    var jacket_rest := jacket.transform
    var coat_rest := coat.transform
    if int(rig.process_priority) >= int(head.process_priority) or int(head.process_priority) >= int(follower.process_priority):
        _fail("skin must update before face and costume")
        return
    rider.set("lean", 0.95)
    rider.set("boosting", true)
    rider.position.y = 1.1
    rig.call("_process", 0.35)
    head.call("_process", 0.35)
    follower.call("_process", 0.35)
    var posed_head := skeleton.get_bone_global_pose(4)
    var head_basis := posed_head.basis.orthonormalized()
    var shift := posed_head.origin - skeleton.get_bone_global_rest(4).origin
    var anchor := Vector3(0.0, 2.42, 0.01) + shift
    if head_pivot.basis.get_rotation_quaternion().angle_to(head_basis.get_rotation_quaternion()) > 0.002:
        _fail("helmet does not follow the skinned Head bone")
        return
    if head_pivot.position.distance_to(anchor) > 0.002:
        _fail("helmet must follow inherited neck/chest displacement")
        return
    for part in [face, hair]:
        var rest: Transform3D = face_rest if part == face else hair_rest
        var expected := anchor + head_basis * (rest.origin - Vector3(0.0, 2.42, 0.01))
        if part.position.distance_to(expected) > 0.002:
            _fail("face or hair is drifting from the skinned head")
            return
        if part.basis.get_rotation_quaternion().angle_to(head_basis.get_rotation_quaternion()) > 0.002:
            _fail("face or hair does not inherit original Head rotation")
            return
    if jacket.basis.get_rotation_quaternion().angle_to(jacket_rest.basis.get_rotation_quaternion()) < 0.08:
        _fail("tailored jacket does not follow original Chest bone")
        return
    if coat.basis.get_rotation_quaternion().angle_to(coat_rest.basis.get_rotation_quaternion()) < 0.06:
        _fail("coat does not follow blended original Hips/Chest pose")
        return
    if follower.find_children("*", "CollisionObject3D", true, false).size() > 0:
        _fail("pose synchronization must not affect gameplay collision")
        return
    rider.set("lean", 0.0)
    rider.set("boosting", false)
    rider.position.y = 0.0
    rig.call("_process", 0.35)
    head.call("_process", 0.35)
    follower.call("_process", 0.35)
    if jacket.position.distance_to(jacket_rest.origin) > 0.003 or coat.position.distance_to(coat_rest.origin) > 0.003:
        _fail("costume roots drift after neutral reset")
        return
    print("COSTUME SKIN FOLLOW TEST PASSED: shared 13-bone head/face/hair and chest/coat poses, safe reset")
    quit(0)
