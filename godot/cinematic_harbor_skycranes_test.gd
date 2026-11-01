extends SceneTree
## V144 candidate: actual Star Harbor orbital crane mesh, lane, animation and pause regression.
func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("HARBOR SKYCRANES TEST FAILED: " + message)
    quit(1)

func _check() -> void:
    var harbor := preload("res://star_harbor.gd").new() as Node3D
    root.add_child(harbor)
    await process_frame
    var scene := harbor.get_node_or_null("Cinematic Star Harbor orbital cargo cranes") as Node3D
    if scene == null:
        _fail("orbital cranes are not integrated into the real Harbor")
        return
    var cranes: Array = scene.get("cranes")
    var supports: Array = scene.get("supports")
    var rings: Array = scene.get("transfer_rings")
    var pods: Array = scene.get("freight_pods")
    if cranes.size() != 4 or supports.size() != 4 or rings.size() != 4 or pods.size() != 8:
        _fail("expected four complete orbital cranes and eight freight pods")
        return
    for index in range(4):
        var crane := cranes[index] as Node3D
        if absf(crane.position.x) < 11.0:
            _fail("crane foundation intrudes into racing corridor")
            return
        var support := supports[index] as MeshInstance3D
        if support == null or not support.mesh is ArrayMesh:
            _fail("missing continuous curved 3D support")
            return
        var mesh := support.mesh as ArrayMesh
        var arrays: Array = mesh.surface_get_arrays(0)
        var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
        var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
        var colors: PackedColorArray = arrays[Mesh.ARRAY_COLOR]
        if vertices.size() < 1700 or normals.size() != vertices.size() or colors.size() != vertices.size():
            _fail("support lacks shaded volumetric geometry")
            return
        var bounds := mesh.get_aabb().size
        if bounds.y < 10.0 or bounds.x < 4.5 or bounds.z < 0.7:
            _fail("support must be an actual tall bent 3D structure")
            return
        if rings[index] == null or not (rings[index] as MeshInstance3D).mesh is TorusMesh:
            _fail("missing volumetric docking halo")
            return
    if scene.find_children("*", "CollisionObject3D", true, false).size() != 0:
        _fail("scenery must not introduce collisions")
        return
    scene.set("running", true)
    scene.set("travel_speed", 12.0)
    var before: float = cranes[0].position.z
    scene.call("_process", 0.5)
    if not is_equal_approx(cranes[0].position.z, before + 6.0):
        _fail("cranes do not scroll with race")
        return
    scene.set("running", false)
    var paused: float = cranes[0].position.z
    var pod_y: float = pods[0].position.y
    scene.call("_process", 0.5)
    if not is_equal_approx(cranes[0].position.z, paused) or not is_equal_approx(pods[0].position.y, pod_y):
        _fail("cranes must freeze during the three English questions")
        return
    cranes[0].position.z = 22.0
    scene.set("running", true)
    scene.call("_process", 0.5)
    if not is_equal_approx(cranes[0].position.z, 22.0 + 6.0 - 148.0):
        _fail("crane loop must not accumulate geometry")
        return
    print("HARBOR SKYCRANES TEST PASSED: four 3D cranes, eight cargo pods, lane safety, pause and wrap")
    quit(0)
