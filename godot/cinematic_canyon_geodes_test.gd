extends SceneTree
## V120 regression: Crystal Canyon gains sculpted 3D geode reefs, not flat props.
func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("CANYON GEODES TEST FAILED: " + message)
    quit(1)

func _check() -> void:
    var canyon := preload("res://crystal_canyon.gd").new() as Node3D
    root.add_child(canyon)
    await process_frame
    var reefs_node := canyon.get_node_or_null("Cinematic floating geode reefs") as Node3D
    if reefs_node == null:
        _fail("geode scenery not integrated into Crystal Canyon")
        return
    var reefs: Array = reefs_node.get("reefs")
    var islands: Array = reefs_node.get("rock_islands")
    var spires: Array = reefs_node.get("crystal_spires")
    var halos: Array = reefs_node.get("halos")
    var shards: Array = reefs_node.get("floating_shards")
    if reefs.size() != 10 or islands.size() != 10 or spires.size() != 10 or halos.size() != 10 or shards.size() != 20:
        _fail("expected ten islands, geode spires, halos and twenty animated shards")
        return
    var distinct_shapes := {}
    for index in range(10):
        var reef := reefs[index] as Node3D
        if absf(reef.position.x) < 14.0:
            _fail("decorative reef intrudes into the racing lanes")
            return
        for instance in [islands[index], spires[index]]:
            var mesh_node := instance as MeshInstance3D
            if mesh_node == null or not mesh_node.mesh is ArrayMesh:
                _fail("missing original faceted 3D geometry")
                return
            var mesh := mesh_node.mesh as ArrayMesh
            if mesh.get_surface_count() != 1:
                _fail("faceted geometry must remain a single draw batch")
                return
            var arrays: Array = mesh.surface_get_arrays(0)
            var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
            var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
            var colors: PackedColorArray = arrays[Mesh.ARRAY_COLOR]
            if vertices.size() < 100 or normals.size() != vertices.size() or colors.size() != vertices.size():
                _fail("missing volumetric facets, normals or vertex shading")
                return
            var volume: Vector3 = mesh.get_aabb().size
            if volume.x < 2.0 or volume.y < 2.0 or volume.z < 2.0:
                _fail("geode is a flat silhouette, not a 360-degree mesh")
                return
        distinct_shapes[str((spires[index] as MeshInstance3D).mesh.get_rid())] = true
        var halo := halos[index] as MeshInstance3D
        var mat := halo.material_override as StandardMaterial3D
        if mat == null or not mat.emission_enabled:
            _fail("floating geode lacks its luminous halo")
            return
    if distinct_shapes.size() < 3:
        _fail("geode spires need three distinct sculpted profiles")
        return
    if reefs_node.find_children("*", "CollisionObject3D", true, false).size() != 0:
        _fail("decorative scenery must not alter physics")
        return
    var start_z: float = reefs[0].position.z
    reefs_node.set("running", true)
    reefs_node.set("travel_speed", 12.0)
    reefs_node.call("_process", 0.25)
    if not is_equal_approx(reefs[0].position.z, start_z + 3.0):
        _fail("geodes must scroll during the complete racing level")
        return
    reefs_node.set("running", false)
    var paused_z: float = reefs[0].position.z
    var paused_rotation: float = shards[0].rotation.y
    reefs_node.call("_process", 0.4)
    if not is_equal_approx(reefs[0].position.z, paused_z) or not is_equal_approx(shards[0].rotation.y, paused_rotation):
        _fail("scenery must pause during the three English vocabulary tasks")
        return
    print("CANYON GEODES TEST PASSED: ten sculpted 360-degree reefs, twenty animated shards, no collisions, safe lanes and pause")
    quit(0)
