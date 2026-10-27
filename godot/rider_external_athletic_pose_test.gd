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
    rider.set("lean", 0.0)
    rider.set("boosting", false)
    rider.position.y = 0.0
    adapter.call("_process", 0.60)
    if rig.get_bone_pose_rotation(thigh_id).angle_to(neutral_thigh) > 0.035 or \
            rig.get_bone_pose_rotation(calf_id).angle_to(neutral_calf) > 0.035:
        _fail("surf stance must settle to the same stable neutral knee pose")
        return
    if hero.find_children("*", "CollisionObject3D", true, false).size() > 0:
        _fail("animation may not change collisions")
        return
    var original := hero.find_child("SuperHero_Male", true, false) as MeshInstance3D
    if original == null or original.skin == null or original.skin.get_bind_count() < 50:
        _fail("real weighted imported body must remain")
        return
    print("EXTERNAL ATHLETIC POSE TEST PASSED: 65-bone crouch, elbow articulation, boost balance and neutral recovery")
    quit(0)
