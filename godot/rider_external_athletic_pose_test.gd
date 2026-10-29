extends SceneTree
## V124: real 65-bone surf stance, articulated elbow/knee balance and reset.
func _initialize() -> void:
    call_deferred("_check")
func _fail(reason: String) -> void:
    push_error("EXTERNAL ATHLETIC POSE TEST FAILED: " + reason)
    quit(1)
func _check() -> void:
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    rider.set("prefer_cc0_rigged_hero", true)
    root.add_child(rider)
    await process_frame
    var adapter := rider.get_node_or_null("ExternalHeroPose") as Node
    var hero := rider.get_node_or_null("ExternalRiggedHero") as Node3D
    if adapter == null or hero == null:
        _fail("genuine CC0 avatar missing")
        return
    var rig := adapter.get("skeleton") as Skeleton3D
    if rig == null or rig.get_bone_count() < 50:
        _fail("original 65-bone rig missing")
        return
    for bone in ["pelvis", "spine_01", "upperarm_l", "lowerarm_l",
            "thigh_l", "calf_l", "thigh_r", "calf_r"]:
        if rig.find_bone(bone) < 0:
            _fail("missing original articulated bone " + bone)
            return
    adapter.call("_process", 0.22)
    var pelvis_id := rig.find_bone("pelvis")
    var thigh_id := rig.find_bone("thigh_l")
    var calf_id := rig.find_bone("calf_l")
    var elbow_id := rig.find_bone("lowerarm_l")
    var neutral_pelvis := rig.get_bone_pose_rotation(pelvis_id)
    var neutral_thigh := rig.get_bone_pose_rotation(thigh_id)
    var neutral_calf := rig.get_bone_pose_rotation(calf_id)
    var neutral_elbow := rig.get_bone_pose_rotation(elbow_id)
    var left_shoulder_id := rig.find_bone("upperarm_l")
    var right_shoulder_id := rig.find_bone("upperarm_r")
    var right_elbow_id := rig.find_bone("lowerarm_r")
    if left_shoulder_id < 0 or right_shoulder_id < 0 or right_elbow_id < 0:
        _fail("both original shoulders and elbows must articulate")
        return
    var neutral_left_shoulder := rig.get_bone_pose_rotation(left_shoulder_id)
    var neutral_right_shoulder := rig.get_bone_pose_rotation(right_shoulder_id)
    var neutral_right_elbow := rig.get_bone_pose_rotation(right_elbow_id)
    # Both arms must be visibly lowered from the imported superhero T-pose,
    # and must remain approximately balanced in the resting surf stance.
    if neutral_left_shoulder.get_angle() < 1.05 or neutral_right_shoulder.get_angle() < 1.05 or \
            absf(neutral_left_shoulder.get_angle() - neutral_right_shoulder.get_angle()) > 0.30:
        _fail("compact balanced shoulder surf silhouette is missing")
        return
    if neutral_elbow.get_angle() < 0.45 or neutral_right_elbow.get_angle() < 0.45:
        _fail("both original elbows must remain clearly flexed")
        return
    if neutral_thigh.get_angle() < 0.24 or neutral_calf.get_angle() < 0.35 or \
            neutral_elbow.get_angle() < 0.30:
        _fail("idle stance must be athletic, with bent knees and elbows")
        return
    rider.set("lean", 0.90)
    rider.set("boosting", true)
    rider.position.y = 0.90
    adapter.call("_process", 0.25)
    if rig.get_bone_pose_rotation(pelvis_id).angle_to(neutral_pelvis) < 0.10 or \
            rig.get_bone_pose_rotation(calf_id).angle_to(neutral_calf) < 0.07:
        _fail("turn/boost/jump must alter real hip and knee balance")
        return
    if rig.get_bone_pose_rotation(left_shoulder_id).angle_to(neutral_left_shoulder) < 0.10 or \
            rig.get_bone_pose_rotation(right_shoulder_id).angle_to(neutral_right_shoulder) < 0.10 or \
            rig.get_bone_pose_rotation(right_elbow_id).angle_to(neutral_right_elbow) < 0.10:
        _fail("turn/boost/jump must articulate both skinned arms")
        return
    rider.set("lean", 0.0)
    rider.set("boosting", false)
    rider.position.y = 0.0
    adapter.call("_process", 0.60)
    if rig.get_bone_pose_rotation(thigh_id).angle_to(neutral_thigh) > 0.035 or \
            rig.get_bone_pose_rotation(calf_id).angle_to(neutral_calf) > 0.035:
        _fail("surf stance must settle to the same stable neutral knee pose")
        return
    if rig.get_bone_pose_rotation(left_shoulder_id).angle_to(neutral_left_shoulder) > 0.04 or \
            rig.get_bone_pose_rotation(right_shoulder_id).angle_to(neutral_right_shoulder) > 0.04:
        _fail("both original shoulders must recover their compact idle stance")
        return
    # A full second of identical carve/boost at 30 and 60 Hz must converge
    # to the same original bone pose. This catches frame-dependent slerp and
    # asymmetric knee weight transfer regressions on mobile displays.
    var comparison_riders: Array[Node3D] = []
    var comparison_adapters: Array[Node] = []
    var comparison_rigs: Array[Skeleton3D] = []
    for refresh_rate in [30, 60]:
        var sample := preload("res://rider_character.tscn").instantiate() as Node3D
        sample.set("prefer_cc0_rigged_hero", true)
        root.add_child(sample)
        comparison_riders.append(sample)
    await process_frame
    for sample in comparison_riders:
        var sample_adapter := sample.get_node_or_null("ExternalHeroPose") as Node
        if sample_adapter == null:
            _fail("refresh-rate sample lost external pose adapter")
            return
        var sample_rig := sample_adapter.get("skeleton") as Skeleton3D
        if sample_rig == null or sample_rig.get_bone_count() < 50:
            _fail("refresh-rate sample lost real imported skin")
            return
        sample_adapter.set_process(false)
        sample.set("lean", 0.8)
        sample.set("boosting", true)
        comparison_adapters.append(sample_adapter)
        comparison_rigs.append(sample_rig)
    for sample_index in range(2):
        var fps := 30 if sample_index == 0 else 60
        for step in range(fps):
            comparison_adapters[sample_index].call("_process", 1.0 / float(fps))
    for bone in ["pelvis", "spine_01", "upperarm_l", "upperarm_r",
            "thigh_l", "thigh_r", "calf_l", "calf_r", "foot_l", "foot_r"]:
        var a := comparison_rigs[0].find_bone(bone)
        var b := comparison_rigs[1].find_bone(bone)
        if a < 0 or b < 0:
            _fail("missing source bone in refresh-rate comparison: " + bone)
            return
        var difference := comparison_rigs[0].get_bone_pose_rotation(a).angle_to(
            comparison_rigs[1].get_bone_pose_rotation(b))
        if difference > 0.025:
            _fail("30/60 Hz animation divergence at " + bone + ": " + str(difference))
            return
    var comparison_rig := comparison_rigs[1]
    var left_calf := comparison_rig.find_bone("calf_l")
    var right_calf := comparison_rig.find_bone("calf_r")
    if absf(comparison_rig.get_bone_pose_rotation(left_calf).get_angle() -
            comparison_rig.get_bone_pose_rotation(right_calf).get_angle()) < 0.08:
        _fail("carving must transfer weight asymmetrically across the real knee bones")
        return
    # A touchdown generates short-lived knee/hip compression without moving
    # the collision body or detaching the imported skin from the hoverboard.
    var landing_rider := comparison_riders[1]
    var landing_adapter := comparison_adapters[1]
    landing_rider.position.y = 0.8
    landing_adapter.call("_process", 1.0 / 60.0)
    landing_rider.position.y = 0.0
    landing_adapter.call("_process", 1.0 / 60.0)
    if float(landing_adapter.get("landing_impact")) < 0.25:
        _fail("real jump landing must generate a visible compression impulse")
        return
    landing_rider.set("lean", 0.0)
    landing_rider.set("boosting", false)
    for step in range(90):
        landing_adapter.call("_process", 1.0 / 60.0)
    if float(landing_adapter.get("landing_impact")) > 0.005:
        _fail("landing compression must decay without animation drift")
        return
    if hero.find_children("*", "CollisionObject3D", true, false).size() > 0:
        _fail("animation may not change collisions")
        return
    var original := hero.find_child("SuperHero_Male", true, false) as MeshInstance3D
    if original == null or original.skin == null or original.skin.get_bind_count() < 50:
        _fail("real weighted imported body must remain")
        return
    print("EXTERNAL ATHLETIC POSE TEST PASSED: 65-bone compact bilateral surf arms, crouch, boost balance and neutral recovery")
    quit(0)
