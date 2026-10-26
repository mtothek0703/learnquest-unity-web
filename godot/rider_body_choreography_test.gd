extends SceneTree
## V101 regression: full-body 13-bone choreography, airborne phases and
## landing compression. No changes to game physics or touch controls.
func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("BODY CHOREOGRAPHY TEST FAILED: " + message)
    quit(1)

func _check() -> void:
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    root.add_child(rider)
    await process_frame
    var model := rider.get_node_or_null("ImportedRider") as Node3D
    if model == null:
        _fail("imported character missing")
        return
    var rig := model.get_node_or_null("OriginalBodySkinRig") as Node3D
    var suit := model.get_node_or_null("SculptedSkinnedFlightSuit") as Node3D
    if rig == null or suit == null:
        _fail("original rig and GPU-skinned suit required")
        return
    var skeleton := rig.get_node_or_null("OriginalBodySkeleton13") as Skeleton3D
    if skeleton == null or skeleton.get_bone_count() != 13:
        _fail("13 real body bones required")
        return
    var parts: Array = suit.get("suit_parts")
    if parts.size() != 5:
        _fail("five skinned suit pieces must remain")
        return
    for part in parts:
        var mesh := part as MeshInstance3D
        if mesh == null or mesh.skin == null or mesh.get_node_or_null(mesh.skeleton) != skeleton:
            _fail("flight suit must share the original GPU skin")
            return
    var original_body: Array = rig.get("skinned_meshes")
    if original_body.is_empty():
        _fail("original body skin must not be replaced by decoration")
        return
    rider.set("lean", 0.0)
    rider.set("boosting", false)
    rider.position.y = 0.0
    rig.call("_process", 0.3)
    var rest_chest := skeleton.get_bone_pose_rotation(2)
    rider.set("lean", 0.95)
    rig.call("_process", 0.3)
    var turn_chest := skeleton.get_bone_pose_rotation(2)
    var turn_hips := skeleton.get_bone_pose_rotation(0)
    if turn_chest.angle_to(rest_chest) < 0.15 or turn_hips.get_angle() < 0.09:
        _fail("chest and hips must visibly counterbalance turns")
        return
    rider.set("lean", 0.0)
    rider.set("boosting", true)
    rider.position.y = 0.85
    rig.call("_process", 0.2)
    var ascent_arm := skeleton.get_bone_pose_rotation(5)
    var ascent_knee := skeleton.get_bone_pose_rotation(10)
    if ascent_arm.get_angle() < 0.20 or ascent_knee.get_angle() < 0.20:
        _fail("boost and jump must create visible arm and knee poses")
        return
    rider.position.y = 1.12
    rig.call("_process", 0.14)
    rider.position.y = 0.85
    rig.call("_process", 0.14)
    var descent_arm := skeleton.get_bone_pose_rotation(5)
    if ascent_arm.angle_to(descent_arm) < 0.07:
        _fail("ascent and descent must have different arm silhouettes")
        return
    rider.set("boosting", false)
    rider.position.y = 0.0
    rig.call("_process", 0.05)
    var landing_knee := skeleton.get_bone_pose_rotation(10)
    if landing_knee.get_angle() < 0.20:
        _fail("landing must compress the knee visibly")
        return
    rig.call("_process", 0.35)
    if skeleton.get_bone_pose_rotation(10).get_angle() > 0.03:
        _fail("knee must relax after landing")
        return
    if suit.find_children("*", "CollisionObject3D", true, false).size() > 0:
        _fail("visual animation must never add collisions or touch zones")
        return
    print("BODY CHOREOGRAPHY TEST PASSED: shared GPU skin, turn balance, ascent/descent, boost, landing and neutral recovery")
    quit(0)
