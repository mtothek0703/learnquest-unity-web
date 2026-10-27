extends SceneTree
## V122: Star Harbor 3D drydock geometry, movement and mobile-safe lanes.
func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("HARBOR DRYDOCKS TEST FAILED: " + message)
    quit(1)

func _check() -> void:
    var harbor := preload("res://star_harbor.gd").new() as Node3D
    root.add_child(harbor)
    await process_frame
    var docks_node := harbor.get_node_or_null("Cinematic Star Harbor loading drydocks") as Node3D
    if docks_node == null:
        _fail("new 3D loading docks missing from Star Harbor")
        return
    var docks: Array = docks_node.get("docks")
    var cradles: Array = docks_node.get("cradles")
    var gantries: Array = docks_node.get("gantries")
    var pods: Array = docks_node.get("cargo_pods")
    if docks.size() != 8 or cradles.size() != 8 or gantries.size() != 8 or pods.size() != 16:
        _fail("expected eight drydocks, eight animated gantries and sixteen cargo pods")
        return
    for index in range(docks.size()):
        var dock := docks[index] as Node3D
        if absf(dock.position.x) < 16.0:
            _fail("the drydock intrudes into the three racing lanes")
            return
        var cradle := cradles[index] as MeshInstance3D
        if cradle == null or not cradle.mesh is ArrayMesh:
            _fail("missing extruded U-shaped cradle")
            return
        var mesh := cradle.mesh as ArrayMesh
        var arrays: Array = mesh.surface_get_arrays(0)
        var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
        var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
        var colors: PackedColorArray = arrays[Mesh.ARRAY_COLOR]
        if vertices.size() < 700 or normals.size() != vertices.size() or colors.size() != vertices.size():
            _fail("cradle lacks sculpted volumetric shading")
            return
        var volume := mesh.get_aabb().size
        if volume.x < 6.0 or volume.y < 3.0 or volume.z < 5.0:
            _fail("cradle is not a true 360-degree U-shaped dock")
            return
        var arm := gantries[index] as Node3D
        var structural := arm.get_node_or_null("Curved structural gantry") as MeshInstance3D
        if structural == null or not structural.mesh is ArrayMesh:
            _fail("loading gantry is missing curved structural geometry")
            return
        var arm_arrays: Array = (structural.mesh as ArrayMesh).surface_get_arrays(0)
        if (arm_arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).size() < 500:
            _fail("loading gantry lacks detailed 3D surface")
            return
    if docks_node.find_children("*", "CollisionObject3D", true, false).size() != 0:
        _fail("docks may not change player collision physics")
        return
    docks_node.set("running", true)
    docks_node.set("travel_speed", 12.0)
    var z0: float = docks[0].position.z
    docks_node.call("_process", 0.5)
    if not is_equal_approx(docks[0].position.z, z0 + 6.0):
        _fail("drydocks must scroll with the race")
        return
    var rotation: float = gantries[0].rotation.y
    var pod_y: float = pods[0].position.y
    docks_node.set("running", false)
    docks_node.call("_process", 0.5)
    if not is_equal_approx(gantries[0].rotation.y, rotation) or not is_equal_approx(pods[0].position.y, pod_y):
        _fail("docks must pause during vocabulary tasks and menus")
        return
    print("HARBOR DRYDOCKS TEST PASSED: eight 3D cradles, animated gantries, sixteen pods, safe lanes and pause")
    quit(0)
