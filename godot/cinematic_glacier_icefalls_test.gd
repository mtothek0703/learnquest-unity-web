extends SceneTree
## Regression for the actual V143 Aurora Glacier icefall scene.
func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("GLACIER ICEFALLS TEST FAILED: " + message)
    quit(1)

func _check() -> void:
    var glacier := preload("res://aurora_glacier.gd").new() as Node3D
    root.add_child(glacier)
    await process_frame
    var falls := glacier.get_node_or_null("Cinematic sculpted glacier icefalls") as Node3D
    if falls == null:
        _fail("icefalls are not integrated into the Aurora world")
        return
    var roots: Array = falls.get("icefalls")
    var walls: Array = falls.get("ice_walls")
    var icicles: Array = falls.get("icicle_batches")
    if roots.size() != 6 or walls.size() != 6 or icicles.size() != 6:
        _fail("expected six continuous cascades and six batched icicle groups")
        return
    for index in range(6):
        if absf(roots[index].position.x) < 9.0:
            _fail("decorative icefall enters the three racing lanes")
            return
        var wall := walls[index] as MeshInstance3D
        var batch := icicles[index] as MultiMeshInstance3D
        if wall == null or not wall.mesh is ArrayMesh or batch == null or batch.multimesh == null:
            _fail("icefall must use real continuous mesh and batched icicles")
            return
        var mesh := wall.mesh as ArrayMesh
        var arrays: Array = mesh.surface_get_arrays(0)
        var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
        var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
        var colors: PackedColorArray = arrays[Mesh.ARRAY_COLOR]
        if vertices.size() < 2500 or normals.size() != vertices.size() or colors.size() != vertices.size():
            _fail("icefall lacks sculpted triangles, normals or vertex shading")
            return
        var bounds := mesh.get_aabb().size
        if bounds.x < 4.5 or bounds.y < 12.0 or bounds.z < 1.7:
            _fail("icefall has insufficient height, width or actual depth")
            return
        if batch.multimesh.instance_count != 12:
            _fail("each icefall must have twelve instanced 3D icicles")
            return
    if falls.find_children("*", "CollisionObject3D", true, false).size() != 0:
        _fail("decorative icefalls must not introduce collision bodies")
        return
    var start_z: float = roots[0].position.z
    falls.set("running", true)
    falls.set("travel_speed", 12.0)
    falls.call("_process", 0.25)
    if not is_equal_approx(roots[0].position.z, start_z + 3.0):
        _fail("icefalls must move with the world during the race")
        return
    falls.set("running", false)
    var paused_z: float = roots[0].position.z
    falls.call("_process", 0.5)
    if not is_equal_approx(roots[0].position.z, paused_z):
        _fail("icefalls must pause during the three English tasks")
        return
    roots[0].position.z = 22.0
    falls.set("running", true)
    falls.call("_process", 0.25)
    if not is_equal_approx(roots[0].position.z, 22.0 + 3.0 - 162.0):
        _fail("icefall loop must not accumulate geometry")
        return
    print("GLACIER ICEFALLS TEST PASSED: six volumetric cascades, 72 instanced icicles, no collisions, scroll/pause/wrap")
    quit(0)
