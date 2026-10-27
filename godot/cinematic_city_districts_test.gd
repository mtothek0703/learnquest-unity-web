extends SceneTree
## V118: actual city geometry, three styles, instanced facade detail,
## safe racing lanes and deterministic movement must survive CI.
func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("NEON DISTRICTS TEST FAILED: " + message)
    quit(1)

func _check() -> void:
    var city := preload("res://neon_environment.gd").new() as Node3D
    root.add_child(city)
    await process_frame
    var district := city.get_node_or_null("Cinematic facade districts") as Node3D
    if district == null:
        _fail("Sprint 3 district missing from actual Neon City")
        return
    var towers: Array = district.get("towers")
    var batches: Array = district.get("window_batches")
    var crowns: Array = district.get("roof_crowns")
    var styles: Array = district.get("district_styles")
    if towers.size() != 12 or batches.size() != 12 or crowns.size() != 12 or styles.size() != 12:
        _fail("expected 12 complete architectural towers")
        return
    var total_windows := 0
    var variants := {}
    var heights := {}
    for i in range(towers.size()):
        var tower := towers[i] as Node3D
        variants[styles[i]] = true
        if absf(tower.position.x) < 13.0:
            _fail("architecture invades the playable road")
            return
        var shell := tower.get_node_or_null("Sculpted facade shell") as MeshInstance3D
        if shell == null or not shell.mesh is ArrayMesh:
            _fail("continuous tiered facade geometry missing")
            return
        var mesh := shell.mesh as ArrayMesh
        if mesh.get_surface_count() != 1:
            _fail("facade must be a single low-draw-call mesh")
            return
        var arrays: Array = mesh.surface_get_arrays(0)
        var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
        var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
        var colors: PackedColorArray = arrays[Mesh.ARRAY_COLOR]
        if vertices.size() < 350 or normals.size() != vertices.size() or colors.size() != vertices.size():
            _fail("missing sculpted shaded 3D facade geometry")
            return
        heights[int(mesh.get_aabb().size.y)] = true
        var windows := tower.get_node_or_null("Instanced luminous windows") as MultiMeshInstance3D
        var ribs := tower.get_node_or_null("Four instanced vertical neon ribs") as MultiMeshInstance3D
        if windows == null or windows.multimesh == null or windows.multimesh.instance_count < 30:
            _fail("missing batched multi-floor glass windows")
            return
        if ribs == null or ribs.multimesh == null or ribs.multimesh.instance_count != 4:
            _fail("missing four low-cost vertical luminous ribs")
            return
        total_windows += windows.multimesh.instance_count
        if tower.get_node_or_null("Luminous roof observation crown") == null:
            _fail("missing roof silhouette")
            return
    if variants.size() != 3 or heights.size() < 5 or total_windows < 450:
        _fail("city must contain three districts, varied heights and hundreds of windows")
        return
    if district.find_children("*", "CollisionObject3D", true, false).size() != 0:
        _fail("visual architecture must not introduce collisions")
        return
    var before: float = towers[0].position.z
    district.set("running", true)
    district.set("travel_speed", 12.0)
    district.call("_process", 0.25)
    if not is_equal_approx(towers[0].position.z, before + 3.0):
        _fail("district scenery must scroll with gameplay speed")
        return
    district.set("running", false)
    var paused: float = towers[0].position.z
    district.call("_process", 0.5)
    if not is_equal_approx(towers[0].position.z, paused):
        _fail("architecture must freeze during vocabulary and menus")
        return
    if city.get_node_or_null("Cinematic skybridges") == null or city.get_node_or_null("Cinematic neon searchlights") == null:
        _fail("original Neon City architecture must be preserved")
        return
    print("NEON DISTRICTS TEST PASSED: 12 volumetric towers, three styles, %d instanced windows, safe lanes and paused scrolling" % total_windows)
    quit(0)
