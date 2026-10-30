extends SceneTree
## V124: secondary animation must use the original imported 65-bone Skin,
## respond to touch-carve on both sides and converge at 30/60 Hz.
func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("EXTERNAL FOLLOW-THROUGH TEST FAILED: " + message)
    quit(1)

func _check() -> void:
    var riders: Array[Node3D] = []
    var adapters: Array[Node] = []
    var rigs: Array[Skeleton3D] = []
    for hz in [30, 60]:
        var rider := preload("res://rider_character.tscn").instantiate() as Node3D
        rider.set("prefer_cc0_rigged_hero", true)
        root.add_child(rider)
        riders.append(rider)
    await process_frame
    for rider in riders:
        var adapter := rider.get_node_or_null("ExternalHeroPose") as Node
        var hero := rider.get_node_or_null("ExternalRiggedHero") as Node3D
        if adapter == null or hero == null:
            _fail("genuine rigged character missing")
            return
        var rig := adapter.get("skeleton") as Skeleton3D
        if rig == null or rig.get_bone_count() != 65:
            _fail("original 65-bone skeleton replaced")
            return
        var body := hero.find_child("SuperHero_Male", true, false) as MeshInstance3D
        if body == null or body.skin == null or body.skin.get_bind_count() < 60:
            _fail("original four-weight GPU skin missing")
            return
        if hero.find_children("*", "CollisionObject3D", true, false).size() != 0:
            _fail("visual follow-through added collisions")
            return
        if rider.get_node_or_null("LegacyRider") == null:
            _fail("existing touch-controlled hoverboard missing")
            return
        adapter.set_process(false)
        rider.set("lean", 0.0)
        rider.set("boosting", false)
        adapter.call("_process", 0.25)
        adapters.append(adapter)
        rigs.append(rig)
    var rig := rigs[1]
    var left := rig.find_bone("upperarm_l")
    var right := rig.find_bone("upperarm_r")
    var left_elbow := rig.find_bone("lowerarm_l")
    var right_elbow := rig.find_bone("lowerarm_r")
    var head := rig.find_bone("Head")
    var chest := rig.find_bone("spine_02")
    for bone in [left, right, left_elbow, right_elbow, head, chest]:
        if bone < 0:
            _fail("articulated original arm/head/chest joint missing")
            return
    var idle_left := rig.get_bone_pose_rotation(left)
    var idle_right := rig.get_bone_pose_rotation(right)
    var idle_elbow_l := rig.get_bone_pose_rotation(left_elbow)
    var idle_elbow_r := rig.get_bone_pose_rotation(right_elbow)
    for i in range(2):
        riders[i].set("lean", 0.92)
        riders[i].set("boosting", true)
        var hz := 30 if i == 0 else 60
        for step in range(hz):
            adapters[i].call("_process", 1.0 / float(hz))
    var outside_delta := rig.get_bone_pose_rotation(right).angle_to(idle_right)
    var inside_delta := rig.get_bone_pose_rotation(left).angle_to(idle_left)
    var outside_elbow := rig.get_bone_pose_rotation(right_elbow).angle_to(idle_elbow_r)
    var inside_elbow := rig.get_bone_pose_rotation(left_elbow).angle_to(idle_elbow_l)
    if outside_delta < inside_delta + 0.10 or inside_elbow < outside_elbow + 0.07:
        _fail("outside arm must open and inside elbow tuck in a real carve")
        return
    for bone_name in ["pelvis", "spine_01", "spine_02", "neck_01", "Head",
            "upperarm_l", "upperarm_r", "lowerarm_l", "lowerarm_r",
            "thigh_l", "thigh_r", "calf_l", "calf_r"]:
        var a := rigs[0].find_bone(bone_name)
        var b := rigs[1].find_bone(bone_name)
        if a < 0 or b < 0:
            _fail("missing real bone " + bone_name)
            return
        if rigs[0].get_bone_pose_rotation(a).angle_to(
                rigs[1].get_bone_pose_rotation(b)) > 0.03:
            _fail("30/60 Hz pose divergence at " + bone_name)
            return
    if absf(float(adapters[0].get("torso_follow")) -
            float(adapters[1].get("torso_follow"))) > 0.001:
        _fail("torso inertia depends on display refresh rate")
        return
    # Releasing the turn must restore the original compact surf stance,
    # including both weighted shoulders and the head.
    for i in range(2):
        riders[i].set("lean", 0.0)
        riders[i].set("boosting", false)
        var hz := 30 if i == 0 else 60
        for step in range(hz * 2):
            adapters[i].call("_process", 1.0 / float(hz))
    if absf(float(adapters[1].get("torso_follow"))) > 0.002:
        _fail("upper-body follow-through never settles")
        return
    if rig.get_bone_pose_rotation(left).angle_to(idle_left) > 0.045 or \
            rig.get_bone_pose_rotation(right).angle_to(idle_right) > 0.045:
        _fail("skinned shoulders do not recover their neutral stance")
        return
    # Landing is an impulse in the original head/shoulder pose, not physics.
    riders[1].position.y = 0.9
    adapters[1].call("_process", 1.0 / 60.0)
    riders[1].position.y = 0.0
    adapters[1].call("_process", 1.0 / 60.0)
    if float(adapters[1].get("landing_impact")) < 0.25:
        _fail("landing impulse lost")
        return
    print("EXTERNAL FOLLOW-THROUGH TEST PASSED: original 65-bone arms/head, asymmetric carving, 30/60 Hz and landing")
    quit(0)
