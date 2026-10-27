extends SceneTree
## V121: four playable 3D Crystal Canyon fork decisions, not just scenery.
func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("CANYON ROUTES TEST FAILED: " + message)
    quit(1)

func _check() -> void:
    var canyon := preload("res://crystal_canyon.gd").new() as Node3D
    root.add_child(canyon)
    await process_frame
    var routes := canyon.get_node_or_null("Playable canyon route choices") as Node3D
    if routes == null:
        _fail("the playable fork module is not attached to Crystal Canyon")
        return
    var junctions: Array = routes.get("junctions")
    var portals: Array = routes.get("portals")
    var ribbons: Array = routes.get("ribbons")
    if junctions.size() != 4 or portals.size() != 8 or ribbons.size() != 8:
        _fail("four fork events must each contain two 3D portals and guides")
        return
    for index in range(8):
        var portal := portals[index] as MeshInstance3D
        var ribbon := ribbons[index] as MeshInstance3D
        if portal == null or not portal.mesh is TorusMesh or ribbon == null or not ribbon.mesh is ArrayMesh:
            _fail("missing curved 3D route guidance")
            return
        var arrays: Array = (ribbon.mesh as ArrayMesh).surface_get_arrays(0)
        var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
        var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
        if verts.size() < 500 or normals.size() != verts.size():
            _fail("branch guides must be true curved 3D geometry with normals")
            return
        if not is_equal_approx(absf(portal.position.x), 3.1):
            _fail("both route choices must align with the existing touch lanes")
            return
    if routes.find_children("*", "CollisionObject3D", true, false).size() != 0:
        _fail("optional branches may not add new collisions or obstacles")
        return
    routes.set("running", true)
    routes.set("travel_speed", 12.0)
    var initial_z: float = junctions[0].position.z
    routes.call("_process", 0.5)
    if not is_equal_approx(junctions[0].position.z, initial_z + 6.0):
        _fail("route portals must move at the level's speed")
        return
    routes.call("reset_course")
    junctions[0].position.z = 0.3
    var left: Dictionary = routes.call("check_route_choice", -3.1)
    if left.get("choice", "") != "energy" or int(left.get("energy", 0)) != 20 or int(left.get("xp", 0)) != 15:
        _fail("left path must award energy and XP")
        return
    if not (routes.call("check_route_choice", -3.1) as Dictionary).is_empty():
        _fail("a route must never be rewarded twice")
        return
    junctions[1].position.z = 0.3
    var right: Dictionary = routes.call("check_route_choice", 3.1)
    if right.get("choice", "") != "xp" or int(right.get("xp", 0)) != 40 or int(right.get("energy", -1)) != 0:
        _fail("right path must award distinct XP without energy")
        return
    junctions[2].position.z = 0.3
    var center: Dictionary = routes.call("check_route_choice", 0.0)
    if not bool(center.get("missed", false)) or int(routes.get("missed_routes")) != 1:
        _fail("the center lane must safely skip the optional fork")
        return
    junctions[3].position.z = 0.3
    routes.call("check_route_choice", 3.1)
    if int(routes.get("completed_routes")) != 3:
        _fail("three successful choices must count toward the bonus mission")
        return
    routes.call("reset_course")
    routes.set("running", false)
    junctions[0].position.z = 0.3
    if not (routes.call("check_route_choice", -3.1) as Dictionary).is_empty() or int(routes.get("completed_routes")) != 0:
        _fail("paused training/menu must not award a route")
        return

    # Exercise the actual game integration, including energy, XP and star.
    canyon.queue_free()
    var game := preload("res://world.gd").new() as Node3D
    root.add_child(game)
    await process_frame
    game.set("world_choice", 1)
    game.call("_reset_run")
    var active_canyon := game.get("canyon_zone") as Node3D
    var active_routes := active_canyon.get_node("Playable canyon route choices") as Node3D
    active_routes.set("running", true)
    var active_junctions: Array = active_routes.get("junctions")
    var hero := game.get("rider") as Node3D
    var starting_xp: int = int(game.get("xp"))
    var starting_power: int = int(game.get("power"))
    active_junctions[0].position.z = 0.3
    hero.position.x = -3.1
    game.call("_update_canyon_routes")
    if int(game.get("xp")) != starting_xp + 15 or int(game.get("power")) != mini(100, starting_power + 20):
        _fail("the real game must apply the left-route reward exactly once")
        return
    for index in [1, 2]:
        active_junctions[index].position.z = 0.3
        hero.position.x = 3.1
        game.call("_update_canyon_routes")
    if int(active_canyon.get("completed_routes")) != 3:
        _fail("world-level canyon route progress is not synchronized")
        return
    game.set("distance", game.get("mission_target"))
    game.call("_finish_run")
    var reward := game.get("reward_label") as Label
    if reward == null or not reward.text.contains("KRISTALL-PFAD-MISSION"):
        _fail("three route choices must award the documented bonus star")
        return
    if int(game.get("total_stars")) != 4:
        _fail("three lives plus one optional route star must total four")
        return
    print("CANYON ROUTES TEST PASSED: four playable forks, distinct rewards, pause/reset, three-task rule and mission star")
    quit(0)
