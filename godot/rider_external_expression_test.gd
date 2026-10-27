extends SceneTree
## V124: actual Head-bone face animation, not a fake static face mesh.
## Exercise gaze, brows, boost smile, timed blink and exact neutral reset.
func _initialize() -> void:
    call_deferred("_check")

func _fail(reason: String) -> void:
    push_error("EXTERNAL EXPRESSION TEST FAILED: " + reason)
    quit(1)

func _check() -> void:
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    rider.set("prefer_cc0_rigged_hero", true)
    root.add_child(rider)
    await process_frame
    var adapter := rider.get_node_or_null("ExternalHeroPose") as Node
    var hero := rider.get_node_or_null("ExternalRiggedHero") as Node3D
    if adapter == null or hero == null:
        _fail("65-bone imported character or pose adapter missing")
        return
    var rig := adapter.get("skeleton") as Skeleton3D
    if rig == null or rig.get_bone_count() < 50:
        _fail("original humanoid rig was replaced")
        return
    var head := rig.get_node_or_null("ExternalHeroHeadgear") as BoneAttachment3D
    if head == null or head.bone_name != "Head":
        _fail("facial acting must follow the original Head bone")
        return
    var acting := head.get_node_or_null("ExternalFacialActing") as Node
    if acting == null:
        _fail("face animation controller not installed")
        return
    var eye := head.find_child("EyeWhite*", false, false) as MeshInstance3D
    var iris := head.find_child("Iris-1*", false, false) as MeshInstance3D
    var brow := head.find_child("CurvedBrow*", false, false) as MeshInstance3D
    var smile := head.get_node_or_null("CurvedSmile") as MeshInstance3D
    if eye == null or iris == null or brow == null or smile == null:
        _fail("original modeled eye/iris/brow/mouth meshes missing")
        return
    var original_eye_scale := eye.scale
    var original_iris_pos := iris.position
    var original_brow_pos := brow.position
    var original_smile_scale := smile.scale
    var dimensions: Vector3 = head.get("head_bounds").size
    var visual_scale: float = float(head.get("visual_scale"))
    acting.call("animate", 0.8, true, 0.5, 0.0, 0.0)
    if iris.position.x - original_iris_pos.x < dimensions.x * visual_scale * 0.010:
        _fail("gaze must follow steering, not stay fixed")
        return
    if brow.position.y - original_brow_pos.y < dimensions.y * visual_scale * 0.018:
        _fail("brows must react to boost/jump")
        return
    if smile.scale.x <= original_smile_scale.x * 1.12:
        _fail("smile must visibly react to speed")
        return
    acting.call("animate", 0.0, false, 0.0, 3.2, 1.0)
    if eye.scale.y > original_eye_scale.y * 0.25:
        _fail("eyelid blink must close the modeled eye")
        return
    acting.call("animate", 0.0, false, 0.0, 0.0, 0.0)
    if eye.scale.distance_to(original_eye_scale) > 0.0001 or \
            iris.position.distance_to(original_iris_pos) > 0.0001 or \
            brow.position.distance_to(original_brow_pos) > 0.0001 or \
            smile.scale.distance_to(original_smile_scale) > 0.0001:
        _fail("neutral pose must restore all face transforms without drift")
        return
    rider.set("lean", -0.75)
    rider.set("boosting", true)
    rider.position.y = 0.65
    adapter.call("_process", 0.20)
    if original_iris_pos.x - iris.position.x < dimensions.x * visual_scale * 0.008:
        _fail("real gameplay pose adapter must drive face in opposite steering direction")
        return
    if head.find_children("*", "CollisionObject3D", true, false).size() > 0:
        _fail("face animation may not add gameplay collisions")
        return
    var source := hero.find_child("SuperHero_Male", true, false) as MeshInstance3D
    if source == null or source.skin == null or source.skin.get_bind_count() < 50:
        _fail("original GPU-skinned body must remain unchanged")
        return
    print("EXTERNAL EXPRESSION TEST PASSED: gaze, boost brows, blink, smile, neutral reset, original 65-bone Skin")
    quit(0)
