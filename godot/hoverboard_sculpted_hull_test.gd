extends SceneTree
## V116: real 360-degree board geometry, preserved action motion and touch.
func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("SCULPTED HOVERBOARD TEST FAILED: " + message)
    quit(1)

func _check() -> void:
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    root.add_child(rider)
    await process_frame
    var legacy := rider.get_node_or_null("LegacyRider") as Node3D
    var board := rider.get_node_or_null("LegacyRider/Floating hoverboard") as Node3D
    if legacy == null or board == null:
        _fail("original animated hoverboard is missing")
        return
    var sculpt := board.get_node_or_null("SculptedHoverboardChassis") as Node3D
    if sculpt == null or not bool(sculpt.get("built")):
        _fail("new sculpted board did not initialize")
        return
    for name in ["ContinuousAerodynamicChassis", "ContouredTractionDeck",
        "UndersideKeel", "PortEdgeLight", "StarboardEdgeLight"]:
        var part := sculpt.get_node_or_null(name) as MeshInstance3D
        if part == null or part.mesh == null or not part.visible:
            _fail("missing visible board part: " + name)
            return
        var arrays: Array = part.mesh.surface_get_arrays(0)
        var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
        var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
        if vertices.size() < 120 or normals.size() != vertices.size():
            _fail("board geometry is too coarse or unshaded: " + name)
            return
    var chassis := sculpt.get_node("ContinuousAerodynamicChassis") as MeshInstance3D
    var points: PackedVector3Array = chassis.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
    var colors: PackedColorArray = chassis.mesh.surface_get_arrays(0)[Mesh.ARRAY_COLOR]
    if points.size() < 3000 or colors.size() != points.size():
        _fail("chassis needs substantial shaded custom geometry")
        return
    var nose: float = sculpt.call("_half_width", 0.0)
    var middle: float = sculpt.call("_half_width", 0.52)
    var tail: float = sculpt.call("_half_width", 1.0)
    if nose >= middle * 0.75 or tail >= middle or middle < 0.70:
        _fail("aerodynamic silhouette does not taper nose and tail")
        return
    var top: Vector3 = sculpt.call("_shell_point", 0.5, PI * 0.5)
    var bottom: Vector3 = sculpt.call("_shell_point", 0.5, PI * 1.5)
    if top.y - bottom.y < 0.20 or top.z != bottom.z:
        _fail("board chassis is not a genuine rounded 360-degree volume")
        return
    var old_boxes := 0
    for child in board.get_children():
        if child is MeshInstance3D and child.mesh is BoxMesh:
            var box_mesh := child.mesh as BoxMesh
            # Legacy piece() uses unit BoxMesh geometry and node.scale for dimensions.
            var size: Vector3 = box_mesh.size * (child as MeshInstance3D).scale
            if size.z > 1.85 and size.x > 0.8:
                old_boxes += 1
                if child.visible:
                    _fail("old rectangular chassis/deck overlaps sculpted replacement")
                    return
    if old_boxes != 2:
        _fail("expected both original central deck boxes to be retired")
        return
    if sculpt.find_children("*", "CollisionObject3D", true, false).size() > 0:
        _fail("visual board must not change collisions or touch input")
        return
    var original_y := board.position.y
    rider.set("lean", 0.85)
    rider.set("boosting", true)
    legacy.call("_process", 0.28)
    sculpt.call("_process", 0.28)
    if absf(board.rotation.z) < 0.01 or absf(board.position.y - original_y) < 0.001:
        _fail("existing lean and hover animation must remain active")
        return
    var light := sculpt.get("rail_material") as StandardMaterial3D
    if light == null or light.emission_energy_multiplier <= 1.25:
        _fail("boost must visibly intensify the curved light rails")
        return
    if rider.get_node_or_null("ImportedRider/OriginalBodySkinRig/OriginalBodySkeleton13") == null:
        _fail("original 13-bone skinned character must remain")
        return
    print("SCULPTED HOVERBOARD TEST PASSED: 360-degree tapered hull, contoured deck, dynamic rails, original hover/lean and untouched collisions")
    quit(0)
