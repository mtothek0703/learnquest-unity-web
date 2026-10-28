extends SceneTree
## V124: actual original-skinned soles must sit ABOVE the sculpted hoverboard
## traction deck in both neutral and bobbed poses; never change touch/physics.
func _initialize() -> void:
    call_deferred("_check")

func _fail(reason: String) -> void:
    push_error("RIDER BOARD CONTACT TEST FAILED: " + reason)
    quit(1)

func _lowest_source_vertex(rider: Node3D, adapter: Node) -> float:
    var minimum := INF
    var sources: Array = adapter.get("skinned_meshes")
    for source in sources:
        var mesh := source as MeshInstance3D
        if mesh == null or mesh.mesh == null:
            continue
        var box := mesh.mesh.get_aabb()
        for x in [box.position.x, box.end.x]:
            for y in [box.position.y, box.end.y]:
                for z in [box.position.z, box.end.z]:
                    minimum = minf(minimum, rider.to_local(mesh.to_global(Vector3(x, y, z))).y)
    return minimum

func _clearance(rider: Node3D, adapter: Node, grip: MeshInstance3D) -> float:
    var top := rider.to_local(grip.to_global(Vector3(0.0, grip.mesh.get_aabb().end.y, 0.0))).y
    return _lowest_source_vertex(rider, adapter) - top

func _check() -> void:
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    rider.set("prefer_cc0_rigged_hero", true)
    root.add_child(rider)
    await process_frame
    var adapter := rider.get_node_or_null("ExternalHeroPose") as Node
    var hero := rider.get_node_or_null("ExternalRiggedHero") as Node3D
    var board := rider.get_node_or_null("LegacyRider/Floating hoverboard") as Node3D
    var grip := rider.get_node_or_null("LegacyRider/Floating hoverboard/SculptedHoverboardChassis/ContouredTractionDeck") as MeshInstance3D
    if adapter == null or hero == null or board == null or grip == null or grip.mesh == null:
        _fail("original skinned hero and real animated traction deck are required")
        return
    var rig := adapter.get("skeleton") as Skeleton3D
    if rig == null or rig.get_bone_count() != 65:
        _fail("original CC0 65-bone rig must remain intact")
        return
    var initial := _clearance(rider, adapter, grip)
    if absf(initial - 0.045) > 0.03:
        _fail("rest soles intersect the actual board deck: %.3f m" % initial)
        return
    # Refit to a changed hoverboard bob height, without modifying the board,
    # the original glTF Skin, input events, or gameplay collision geometry.
    var previous_y := board.position.y
    board.position.y += 0.14
    if not bool(adapter.call("fit_to_board")):
        _fail("rider did not refit to bobbed board")
        return
    var bobbed := _clearance(rider, adapter, grip)
    if absf(bobbed - 0.045) > 0.03:
        _fail("bobbed board/boot contact drift: %.3f m" % bobbed)
        return
    board.position.y = previous_y
    if not bool(adapter.call("fit_to_board")):
        _fail("rider could not restore original stance")
        return
    if absf(_clearance(rider, adapter, grip) - initial) > 0.005:
        _fail("board contact does not return to neutral")
        return
    if hero.find_children("*", "CollisionObject3D", true, false).size() != 0:
        _fail("visual contact correction must not add collision shapes")
        return
    print("RIDER BOARD CONTACT TEST PASSED: original 65-bone skinned soles aligned to sculpted deck in neutral and bobbed poses")
    quit(0)
