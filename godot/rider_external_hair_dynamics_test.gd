extends SceneTree
## V124: real imported Head bone, scalp-pivoted action hair, neutral reset.
func _initialize() -> void:
    call_deferred("_check")

func _fail(reason: String) -> void:
    push_error("EXTERNAL HAIR DYNAMICS TEST FAILED: " + reason)
    quit(1)

func _check() -> void:
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    rider.set("prefer_cc0_rigged_hero", true)
    root.add_child(rider)
    await process_frame
    var adapter := rider.get_node_or_null("ExternalHeroPose") as Node
    if adapter == null:
        _fail("imported hero pose adapter missing")
        return
    var rig := adapter.get("skeleton") as Skeleton3D
    if rig == null or rig.get_bone_count() < 50:
        _fail("original imported skeleton missing")
        return
    var head := rig.get_node_or_null("ExternalHeroHeadgear") as BoneAttachment3D
    if head == null or head.bone_name != "Head":
        _fail("dynamic hair must follow the real Head joint")
        return
    var motion := head.get_node_or_null("ExternalHairDynamics") as Node
    if motion == null:
        _fail("scalp-pivoted hair controller missing")
        return
    var entries: Array = motion.get("locks")
    if entries.size() != 11:
        _fail("five rear locks, two temple sweeps and four broad fringe locks must participate")
        return
    var original: Array[Transform3D] = []
    var scalp: Array[Vector3] = []
    for entry in entries:
        var part := entry["mesh"] as MeshInstance3D
        if part == null or part.mesh == null:
            _fail("real modeled lock missing")
            return
        var rest: Transform3D = entry["rest"]
        var anchor: Vector3 = entry["anchor"]
        original.append(rest)
        scalp.append(rest * anchor)
    motion.call("set_motion", 0.85, 1.0, 0.8, 1.2)
    var moving := 0
    for i in range(entries.size()):
        var entry: Dictionary = entries[i]
        var part := entry["mesh"] as MeshInstance3D
        var anchor: Vector3 = entry["anchor"]
        if part.transform.basis != original[i].basis:
            moving += 1
        if (part.transform * anchor).distance_to(scalp[i]) > 0.0001:
            _fail("hair root pulled away from original Head attachment")
            return
    if moving < 11:
        _fail("action pose must animate rear, side and fringe volumes")
        return
    motion.call("set_motion", -0.85, 1.0, 0.8, 1.2)
    var first := entries[0]["mesh"] as MeshInstance3D
    var left_roll := first.rotation.z
    motion.call("set_motion", 0.85, 1.0, 0.8, 1.2)
    if absf(first.rotation.z - left_roll) < 0.08:
        _fail("left/right carve must produce different hair flow")
        return
    motion.call("set_motion", 0.0, 0.0, 0.0, 0.0)
    for i in range(entries.size()):
        var part := entries[i]["mesh"] as MeshInstance3D
        if not part.transform.is_equal_approx(original[i]):
            _fail("neutral hair pose must reset without drift")
            return
    rider.set("lean", 0.7)
    rider.set("boosting", true)
    rider.position.y = 0.75
    adapter.call("_process", 0.2)
    if first.transform.is_equal_approx(original[0]):
        _fail("actual gameplay pose adapter must drive hair")
        return
    var hero := rider.get_node_or_null("ExternalRiggedHero") as Node3D
    var body := hero.find_child("SuperHero_Male", true, false) as MeshInstance3D
    if body == null or body.skin == null or body.skin.get_bind_count() < 50:
        _fail("original genuine GPU skin was altered")
        return
    if hero.find_children("*", "CollisionObject3D", true, false).size() > 0:
        _fail("cosmetic hair may not introduce collision shapes")
        return
    print("EXTERNAL HAIR DYNAMICS TEST PASSED: %d scalp-anchored modeled locks, bidirectional carve, boost-jump and neutral reset" % entries.size())
    quit(0)
