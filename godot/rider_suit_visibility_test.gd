extends SceneTree
## V100 visibility regression: the actually skinned shell must not sit hidden
## behind older rigid backplates; preserve reactor, boots and real gameplay.
func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("SUIT VISIBILITY TEST FAILED: " + message)
    quit(1)

func _check() -> void:
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    root.add_child(rider)
    await process_frame
    var model := rider.get_node_or_null("ImportedRider") as Node3D
    if model == null:
        _fail("original rider missing")
        return
    var suit := model.get_node_or_null("SculptedSkinnedFlightSuit") as Node3D
    var rig := model.get_node_or_null("OriginalBodySkinRig") as Node3D
    var harness := model.get_node_or_null("AnimatedAeroHarness") as Node3D
    if suit == null or rig == null or harness == null:
        _fail("suit, original skin and aero harness must coexist")
        return
    var skeleton := rig.get_node_or_null("OriginalBodySkeleton13") as Skeleton3D
    var parts: Array = suit.get("suit_parts")
    if skeleton == null or skeleton.get_bone_count() != 13 or parts.size() != 5:
        _fail("all five suit pieces must share the actual 13-bone body")
        return
    var back := parts[0] as MeshInstance3D
    if back == null or back.skin == null or back.get_node_or_null(back.skeleton) != skeleton:
        _fail("visible back shell must be GPU-skinned, not a rigid overlay")
        return
    var arrays: Array = back.mesh.surface_get_arrays(0)
    var points: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
    var colors: PackedColorArray = arrays[Mesh.ARRAY_COLOR]
    var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
    if points.size() < 1500 or colors.size() != points.size() or normals.size() != points.size():
        _fail("shaded curved back shell geometry missing")
        return
    var min_z := INF
    var max_z := -INF
    var min_x := INF
    var max_x := -INF
    for point in points:
        min_z = minf(min_z, point.z)
        max_z = maxf(max_z, point.z)
        min_x = minf(min_x, point.x)
        max_x = maxf(max_x, point.x)
    # The older rigid jacket reaches only z~=0.78; V99's shell was
    # at z~=0.56 and was consequently hidden from the chase camera.
    if min_z < 0.80 or max_z < 0.95 or min_x > -0.48 or max_x < 0.48:
        _fail("back shell still occluded or too narrow in landscape chase view")
        return
    for path in ["SculptedJacketBack", "NeonJacketEmblem"]:
        var old := model.get_node_or_null(path) as MeshInstance3D
        if old == null or old.visible:
            _fail("duplicate rigid jacket must be hidden behind V100 skin")
            return
    var old_plate := harness.get_node_or_null("CurvedAeroBackplate") as MeshInstance3D
    var reactor := harness.get_node_or_null("RotatingEnergyReactor") as Node3D
    if old_plate == null or old_plate.visible or reactor == null or not reactor.visible:
        _fail("hide only rigid aero backplate; keep working reactor")
        return
    for i in range(2):
        var leg := model.get_node_or_null("BalanceLeg%d" % i) as Node3D
        if leg == null:
            _fail("animated leg missing")
            return
        for name in ["LegacyShin", "LegacyAnkleBand"]:
            var old := leg.get_node_or_null(name) as MeshInstance3D
            if old == null or old.visible:
                _fail("duplicated rigid shin or ankle box still covers skinned leg")
                return
        if leg.get_node_or_null("SculptedHoverBoot") == null or leg.get_node_or_null("AnimatedKneeKinematics") == null:
            _fail("sculpted boots and articulated knees must remain")
            return
    if suit.find_children("*", "CollisionObject3D", true, false).size() != 0:
        _fail("visual replacement must never add collision or touch nodes")
        return
    var old_pose := skeleton.get_bone_pose_rotation(2)
    rider.set("lean", 0.85)
    rider.set("boosting", true)
    rider.position.y = 0.9
    rig.call("_process", 0.25)
    if skeleton.get_bone_pose_rotation(2).angle_to(old_pose) < 0.02:
        _fail("visible suit must still follow animated original-body skeleton")
        return
    print("SUIT VISIBILITY TEST PASSED: exposed curved skinned shell, hidden rigid overlaps, retained reactor and boots, active pose, no collisions")
    quit(0)
