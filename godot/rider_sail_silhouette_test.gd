extends SceneTree
## V112: real chase silhouette must remain readable at rest while all six
## existing sail panels deploy for boost/jumps, without touching gameplay.
func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("SAIL SILHOUETTE TEST FAILED: " + message)
    quit(1)

func _check() -> void:
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    root.add_child(rider)
    await process_frame
    var model := rider.get_node_or_null("ImportedRider") as Node3D
    if model == null:
        _fail("original rider model missing")
        return
    var sails := model.get_node_or_null("AnimatedKineticSails") as Node3D
    var wings := model.get_node_or_null("AnimatedAeroWings") as Node3D
    var cloak := model.get_node_or_null("AnimatedMotionCloak") as Node3D
    var harness := model.get_node_or_null("AnimatedAeroHarness") as Node3D
    var rig := model.get_node_or_null("OriginalBodySkinRig/OriginalBodySkeleton13") as Skeleton3D
    if sails == null or wings == null or cloak == null or harness == null or rig == null or rig.get_bone_count() != 13:
        _fail("original skeleton and distinct aero equipment must survive")
        return
    var roots: Array = sails.get("sail_roots")
    var feathers: Array = sails.get("feathers")
    if roots.size() != 2 or feathers.size() != 6:
        _fail("both original sail roots and all six articulated feathers required")
        return
    var original_mesh_ids: Array[int] = []
    for feather in feathers:
        var membrane := (feather as Node3D).get_node_or_null("CurvedEnergyMembrane") as MeshInstance3D
        if membrane == null or membrane.mesh == null:
            _fail("original translucent sail mesh missing")
            return
        original_mesh_ids.append(membrane.mesh.get_instance_id())
    for sail in roots:
        if (sail as Node3D).visible:
            _fail("idle translucent sails still cover chase-view character")
            return
    if wings.get_node_or_null("LeftWing") == null or cloak.get_node_or_null("LeftCloakRoot") == null or harness.get_node_or_null("RotatingEnergyReactor") == null:
        _fail("original wings, cloak or reactor were removed")
        return
    rider.set("boosting", true)
    sails.call("_process", 0.30)
    for sail in roots:
        if not (sail as Node3D).visible or (sail as Node3D).scale.x < 0.75:
            _fail("boost fails to unfold the six original energy sails")
            return
    rider.set("boosting", false)
    rider.position.y = 0.55
    sails.call("_process", 0.25)
    for sail in roots:
        if not (sail as Node3D).visible:
            _fail("airborne sail deployment disappeared")
            return
    rider.position.y = 0.0
    sails.call("_process", 0.60)
    for sail in roots:
        if (sail as Node3D).visible or (sail as Node3D).scale.x > 0.13:
            _fail("sails fail to fold away after landing")
            return
    for index in range(feathers.size()):
        var membrane := (feathers[index] as Node3D).get_node("CurvedEnergyMembrane") as MeshInstance3D
        if membrane.mesh.get_instance_id() != original_mesh_ids[index]:
            _fail("sail mesh was recreated during deployment")
            return
    if sails.find_children("*", "CollisionObject3D", true, false).size() != 0:
        _fail("visual silhouette change added gameplay collisions")
        return
    print("SAIL SILHOUETTE TEST PASSED: six preserved sails folded at idle, boost/jump deployment, landing reset, original 13-bone rig and collisions")
    quit(0)
