extends SceneTree
## V124 cohesive silhouette experiment: verify the actual 65-bone portrait,
## broad asymmetric fringe, fitted GPU-skinned shoulders and compact board.
## This is geometry QA, NOT a visual-art or real-iPhone FPS approval.
func _initialize() -> void:
    call_deferred("_check")

func _fail(reason: String) -> void:
    push_error("INTEGRATED HERO SILHOUETTE TEST FAILED: " + reason)
    quit(1)

func _check() -> void:
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    rider.set("prefer_cc0_rigged_hero", true)
    root.add_child(rider)
    await process_frame
    var pose := rider.get_node_or_null("ExternalHeroPose") as Node
    var hero := rider.get_node_or_null("ExternalRiggedHero") as Node3D
    var board := rider.get_node_or_null("LegacyRider/Floating hoverboard") as Node3D
    if pose == null or hero == null or board == null:
        _fail("original character, board or animation adapter missing")
        return
    var rig := pose.get("skeleton") as Skeleton3D
    if rig == null or rig.get_bone_count() != 65:
        _fail("the original 65-bone skeleton was changed")
        return
    var headwear := rig.get_node_or_null("ExternalHeroHeadgear") as BoneAttachment3D
    if headwear == null or absf(float(headwear.get("visual_scale")) - 2.12) > 0.01:
        _fail("balanced portrait scale missing")
        return
    var head_bounds: AABB = headwear.get("head_bounds")
    var bangs := headwear.find_children("SculptedTaperedFringe*", "MeshInstance3D", false, false)
    if bangs.size() != 4:
        _fail("four broad sculpted forehead locks required")
        return
    for bang in bangs:
        var mesh := bang as MeshInstance3D
        if mesh.mesh == null or mesh.mesh.get_surface_count() != 1:
            _fail("a modeled forehead lock is missing")
            return
        if mesh.mesh.get_aabb().size.x < head_bounds.size.x * 0.10:
            _fail("forehead locks reverted to thin separated spikes")
            return
    var suit := hero.find_child("SuperHero_Male", true, false) as MeshInstance3D
    if suit == null or suit.skin == null or not (suit.material_override is ShaderMaterial):
        _fail("original imported skinned torso must stay visible with its shader")
        return
    var jacket := hero.get_node_or_null("ExternalSkinnedFlightSuit") as Node
    var jacket_mesh := jacket.get("garment") as MeshInstance3D if jacket != null else null
    if jacket_mesh == null or jacket_mesh.skin != suit.skin:
        _fail("the new colorful torso crest must stay on the imported GPU Skin")
        return
    var armor := hero.get_node_or_null("ExternalSkinnedFlightPauldrons") as Node
    var source := hero.find_child("SuperHero_Male", true, false) as MeshInstance3D
    if armor == null or source == null or source.skin == null:
        _fail("genuine source Skin or weighted shoulders missing")
        return
    var shoulder_width := float(armor.get("shoulder_span")) / source.mesh.get_aabb().size.x
    if shoulder_width < 0.49 or shoulder_width > 0.53:
        _fail("fitted shoulder silhouette must be more compact than the previous shells")
        return
    for shell in armor.get("shells"):
        var weighted := shell as MeshInstance3D
        if weighted == null or weighted.skin != source.skin or weighted.skeleton != source.skeleton:
            _fail("fitted shoulders lost original GPU skinning")
            return
    var sculpt := board.get_node_or_null("SculptedHoverboardChassis") as Node3D
    if sculpt == null or not bool(sculpt.get("built")):
        _fail("animated 3D board missing")
        return
    for side in [-1.0, 1.0]:
        var outer: Vector3 = sculpt.call("_wing_point", side, 0.52, 0.0)
        if absf(outer.x) < 1.17 or absf(outer.x) > 1.23:
            _fail("board stabilizer silhouette is too wide or too narrow")
            return
    if not hero.find_children("*", "CollisionObject3D", true, false).is_empty():
        _fail("new art direction must not introduce collision or touch changes")
        return
    print("INTEGRATED HERO SILHOUETTE TEST PASSED: original 65 bones, four broad bangs, fitted GPU shoulders, compact board")
    quit(0)
