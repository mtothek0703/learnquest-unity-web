extends SceneTree
## V113: keep the skinned 13-bone hero legible at cruise while retaining
## the original four aerofoil fins and six jointed cloak panels for action.
## Pure visual transforms; no input, collision, vocabulary or level changes.
func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("AERO SILHOUETTE TEST FAILED: " + message)
    quit(1)

func _check() -> void:
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    root.add_child(rider)
    await process_frame
    var model := rider.get_node_or_null("ImportedRider") as Node3D
    if model == null:
        _fail("imported rider missing")
        return
    var rig := model.get_node_or_null("OriginalBodySkinRig/OriginalBodySkeleton13") as Skeleton3D
    var wings := model.get_node_or_null("AnimatedAeroWings") as Node3D
    var cloak := model.get_node_or_null("AnimatedMotionCloak") as Node3D
    var sails := model.get_node_or_null("AnimatedKineticSails") as Node3D
    if rig == null or rig.get_bone_count() != 13 or wings == null or cloak == null or sails == null:
        _fail("13-bone original body and all existing aero systems must survive")
        return
    var wing_roots: Array = wings.get("wings")
    var cloak_roots: Array = cloak.get("cloak_roots")
    var cloak_joints: Array = cloak.get("cloak_joints")
    if wing_roots.size() != 2 or cloak_roots.size() != 2 or cloak_joints.size() != 6:
        _fail("two original winglets and six articulated cloak joints required")
        return
    var mesh_ids: Array[int] = []
    for wing in wing_roots:
        var upper := (wing as Node3D).get_node_or_null("SculptedUpperFin") as MeshInstance3D
        var lower := (wing as Node3D).get_node_or_null("SculptedLowerFin") as MeshInstance3D
        if upper == null or lower == null or upper.mesh == null or lower.mesh == null:
            _fail("original curved aerofoil geometry missing")
            return
        mesh_ids.append(upper.mesh.get_instance_id())
        mesh_ids.append(lower.mesh.get_instance_id())
        if (wing as Node3D).visible:
            _fail("idle winglets still obscure the skinned chase silhouette")
            return
    for cloak_root in cloak_roots:
        if not (cloak_root as Node3D).visible or (cloak_root as Node3D).scale.x > 0.56:
            _fail("idle cloak must remain visible but tucked against the rider")
            return
    for joint in cloak_joints:
        if (joint as Node3D).get_node_or_null("FlowingFabric") == null:
            _fail("original articulated cloak cloth missing")
            return
    rider.set("boosting", true)
    wings.call("_process", 0.30)
    cloak.call("_process", 0.30)
    for wing in wing_roots:
        if not (wing as Node3D).visible or (wing as Node3D).scale.x < 0.85:
            _fail("boost does not fully deploy the original aerofoils")
            return
    for cloak_root in cloak_roots:
        if (cloak_root as Node3D).scale.x < 0.90:
            _fail("boost does not spread the original cloak")
            return
    rider.set("boosting", false)
    rider.position.y = 0.80
    wings.call("_process", 0.30)
    cloak.call("_process", 0.30)
    for wing in wing_roots:
        if not (wing as Node3D).visible:
            _fail("jump incorrectly hides the aerofoils")
            return
    for cloak_root in cloak_roots:
        if (cloak_root as Node3D).scale.x < 0.80:
            _fail("jump incorrectly tucks the cloak")
            return
    rider.position.y = 0.0
    wings.call("_process", 0.60)
    cloak.call("_process", 0.60)
    for wing in wing_roots:
        if (wing as Node3D).visible or (wing as Node3D).scale.x > 0.13:
            _fail("winglets fail to stow after landing")
            return
    for cloak_root in cloak_roots:
        if absf((cloak_root as Node3D).scale.x - 0.52) > 0.015:
            _fail("cloak does not return to compact cruise silhouette")
            return
    for i in range(wing_roots.size()):
        var wing := wing_roots[i] as Node3D
        if (wing.get_node("SculptedUpperFin") as MeshInstance3D).mesh.get_instance_id() != mesh_ids[i * 2] or (wing.get_node("SculptedLowerFin") as MeshInstance3D).mesh.get_instance_id() != mesh_ids[i * 2 + 1]:
            _fail("aerofoil geometry recreated during action")
            return
    if wings.find_children("*", "CollisionObject3D", true, false).size() != 0 or cloak.find_children("*", "CollisionObject3D", true, false).size() != 0:
        _fail("visual-only wing/cloak changes introduced gameplay collisions")
        return
    if (sails.get("feathers") as Array).size() != 6:
        _fail("V112's original six kinetic sails were changed")
        return
    print("AERO SILHOUETTE TEST PASSED: four fins stowed at cruise, six cloak joints preserved, boost/jump deployment, landing reset, original rig and collisions")
    quit(0)
