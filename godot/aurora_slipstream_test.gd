extends SceneTree
## Aurora Glacier: moving 3D wind tunnels, readable lane lock, real Turbo,
## harmless misses, pause/reset and full uninterrupted race reward.

func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("AURORA SLIPSTREAM TEST FAILED: " + message)
    quit(1)

func _check() -> void:
    var glacier := preload("res://aurora_glacier.gd").new() as Node3D
    root.add_child(glacier)
    await process_frame
    var course := glacier.get_node_or_null("Playable Aurora slipstream course") as Node3D
    if course == null:
        _fail("moving wind course is missing from actual Glacier world")
        return
    var stations: Array = course.get("stations")
    var arches: Array = course.get("arches")
    var cores: Array = course.get("cores")
    var helices: Array = course.get("helices")
    var aerial_targets: Array = course.get("aerial_targets")
    if stations.size() != 4 or arches.size() != 4 or cores.size() != 4 or helices.size() != 8 or aerial_targets.size() != 4:
        _fail("four complete 3D moving wind tunnels are required")
        return
    for index in range(4):
        if stations[index].get_child_count() != 9:
            _fail("each tunnel needs three hoops, two helices, a core, two guides and an aerial ring")
            return
        var ring := arches[index] as MeshInstance3D
        var core := cores[index] as MeshInstance3D
        if ring == null or not ring.mesh is TorusMesh or core == null or not core.mesh is SphereMesh:
            _fail("wind tunnel is not volumetric 3D geometry")
            return
        if not (helices[index * 2] as MeshInstance3D).mesh is ArrayMesh or \
                (helices[index * 2] as MeshInstance3D).mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX].size() < 300:
            _fail("actual continuous sculpted helical 3D wind ribbons are required")
            return
        var aerial_ring := aerial_targets[index] as MeshInstance3D
        if aerial_ring == null or not aerial_ring.mesh is TorusMesh or \
                aerial_ring.position.y <= core.position.y + 1.0 or \
                not (aerial_ring.material_override as StandardMaterial3D).emission_enabled:
            _fail("elevated illuminated 3D jump ring must visibly signal the aerial bonus")
            return
        if not (ring.material_override as StandardMaterial3D).emission_enabled:
            _fail("moving tunnel must be visibly illuminated")
            return
    if course.find_children("*", "CollisionObject3D", true, false).size() != 0:
        _fail("wind tunnels must not add new collision hazards")
        return

    glacier.set("running", true)
    glacier.set("travel_speed", 14.0)
    glacier.call("_process", 0.0)
    var initial_z: float = stations[0].position.z
    var initial_x: float = stations[1].position.x
    course.call("_process", 0.5)
    if not is_equal_approx(stations[0].position.z, initial_z + 7.0):
        _fail("wind tunnels must scroll at actual world speed")
        return
    if is_equal_approx(stations[1].position.x, initial_x):
        _fail("target lane must actually move before the approach lock")
        return
    stations[1].position.z = -21.5
    var lock_x: float = stations[1].position.x
    course.call("_process", 0.5)
    if not bool(stations[1].get_meta("locked")) or not is_equal_approx(stations[1].position.x, lock_x):
        _fail("final target lane must freeze at least 22 metres before arrival")
        return

    glacier.call("reset_course")
    course.set("running", true)
    stations[0].position.z = 0.3
    var first: Dictionary = glacier.call("check_aurora_stream", stations[0].position.x)
    if not bool(first.get("caught", false)) or int(first.get("xp", 0)) != 35 or \
            int(first.get("energy", 0)) != 15 or float(first.get("turbo_seconds", 0.0)) != 2.5:
        _fail("correct steering must grant XP, energy and a real Turbo burst")
        return
    if not (glacier.call("check_aurora_stream", stations[0].position.x) as Dictionary).is_empty():
        _fail("one tunnel must never pay out twice")
        return
    stations[1].position.z = 0.3
    var miss: Dictionary = glacier.call("check_aurora_stream", -3.1)
    if not bool(miss.get("missed", false)) or int(course.get("missed_streams")) != 1:
        _fail("wrong lane must safely miss without giving a reward")
        return
    glacier.call("reset_course")
    course.set("running", false)
    stations[0].position.z = 0.3
    if not (glacier.call("check_aurora_stream", stations[0].position.x) as Dictionary).is_empty():
        _fail("paused menu/vocabulary must never award a wind tunnel")
        return
    if int(glacier.call("get_aurora_stream_count")) != 0:
        _fail("reset must clear the wind mission")
        return

    glacier.queue_free()
    var game := preload("res://world.gd").new() as Node3D
    root.add_child(game)
    await process_frame
    game.set("world_choice", 3)
    game.call("_reset_run")
    var active_glacier := game.get("glacier_zone") as Node3D
    var active_course := active_glacier.get_node("Playable Aurora slipstream course") as Node3D
    active_course.set("running", true)
    var active_stations: Array = active_course.get("stations")
    var rider := game.get("rider") as Node3D
    for index in range(3):
        active_stations[index].position.z = 0.3
        rider.position.x = active_stations[index].position.x
        game.call("_update_aurora_slipstream")
    if int(active_glacier.call("get_aurora_stream_count")) != 3:
        _fail("three real catches must complete the optional Aurora mission")
        return
    if int(game.get("xp")) != 135 or int(game.get("power")) != 45 or \
            float(game.get("turbo_left")) < 3.49:
        _fail("actual game must grant escalating chain XP and activate existing Turbo")
        return
    var hud := game.get("hud") as Label
    if hud == null or not hud.text.contains("WINDSTROM: 3/3"):
        _fail("landscape HUD must show wind mission progress")
        return
    game.set("distance", game.get("mission_target"))
    game.call("_finish_run")
    var reward := game.get("reward_label") as Label
    if reward == null or not reward.text.contains("AURORA-WINDSTROM"):
        _fail("full uninterrupted Glacier result must display wind mission star")
        return
    if int(game.get("total_stars")) != 4:
        _fail("three lives plus the optional wind mission must award four stars")
        return
    game.call("_reset_run")
    if int(active_glacier.call("get_aurora_stream_count")) != 0:
        _fail("next round must reset all moving tunnels and their rewards")
        return
    # V133: four true airborne interceptions, using the existing jump input,
    # are distinct from ordinary ground catches and grant a mastery XP bonus.
    game.call("_reset_run")
    active_course.set("running", true)
    rider.position.y = 0.0
    active_stations[0].position.z = 0.3
    rider.position.x = active_stations[0].position.x
    game.call("_update_aurora_slipstream")
    if int(game.get("xp")) != 35 or int(active_glacier.call("get_aurora_aerial_catches")) != 0:
        _fail("ground interception must retain original reward without aerial XP")
        return
    game.call("_reset_run")
    active_course.set("running", true)
    for index in range(4):
        active_stations[index].position.z = 0.3
        rider.position.x = active_stations[index].position.x
        rider.position.y = 1.1
        game.call("_update_aurora_slipstream")
        if int(active_glacier.call("get_aurora_aerial_catches")) != index + 1:
            _fail("real airborne catches must increment the aerial mastery")
            return
    if int(game.get("xp")) != 330 or int(game.get("power")) != 60 or \
            float(game.get("turbo_left")) < 4.74 or \
            not bool(active_glacier.call("get_aurora_perfect_aerial_line")):
        _fail("four airborne catches must grant base 200 XP +80 aerial +50 mastery and extra Turbo")
        return
    if not (game.get("hud") as Label).text.contains("LUFT: 4/4"):
        _fail("landscape HUD must display airborne mastery")
        return
    game.set("mobile_hud_layout", true)
    game.call("_refresh_hud")
    var mobile_hud := (game.get("hud") as Label).text
    if not mobile_hud.contains("WINDSTROM: 3/3") or not mobile_hud.contains("LUFT: 4/4"):
        _fail("mobile landscape HUD must keep original mission and new aerial goal")
        return
    # The existing world-status row is intentionally longer and predates
    # V133; constrain only the two NEW Aurora rows, not unrelated legacy UI.
    for line in mobile_hud.split("\n"):
        if (line.contains("WINDSTROM") or line.contains("LUFT")) and line.length() > 48:
            _fail("new Aurora landscape HUD row exceeds safe 360px panel: " + line)
            return
    game.set("mobile_hud_layout", false)
    game.call("_refresh_hud")
    game.set("distance", game.get("mission_target"))
    game.call("_finish_run")
    reward = game.get("reward_label") as Label
    if reward == null or not reward.text.contains("AURORA-LUFTAKROBAT"):
        _fail("completed full round must report the aerial mastery reward")
        return
    game.call("_reset_run")
    if int(active_glacier.call("get_aurora_aerial_catches")) != 0 or \
            bool(active_glacier.call("get_aurora_perfect_aerial_line")):
        _fail("a new round must clear all airborne mastery rewards")
        return
    rider.position.y = 0.0
    print("AURORA SLIPSTREAM TEST PASSED: moving 3D tunnels, lane lock, Turbo, ground/aerial rewards, 330 XP aerial mastery, reset and full-level result")
    quit(0)
