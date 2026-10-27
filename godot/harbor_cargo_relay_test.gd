extends SceneTree
## V123: optional Star Harbor cargo delivery course with no new controls.

func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("HARBOR CARGO RELAY TEST FAILED: " + message)
    quit(1)

func _check() -> void:
    var harbor := preload("res://star_harbor.gd").new() as Node3D
    root.add_child(harbor)
    await process_frame
    var relay := harbor.get_node_or_null("Playable Star Harbor cargo relay") as Node3D
    if relay == null:
        _fail("cargo relay is missing from the actual Star Harbor")
        return
    var stations: Array = relay.get("stations")
    var portals: Array = relay.get("portals")
    var pods: Array = relay.get("cargo")
    if stations.size() != 5 or portals.size() != 5 or pods.size() != 5:
        _fail("five complete orbital delivery checkpoints are required")
        return
    for index in range(5):
        var portal := portals[index] as MeshInstance3D
        var pod := pods[index] as MeshInstance3D
        if portal == null or not portal.mesh is TorusMesh or pod == null or not pod.mesh is CapsuleMesh:
            _fail("each dock must have a true 3D ring and cargo capsule")
            return
        var expected_x := -3.1 if index % 2 == 0 else 3.1
        if not is_equal_approx(portal.position.x, expected_x) or not is_equal_approx(pod.position.x, expected_x):
            _fail("cargo checkpoints must use the existing three steering lanes")
            return
        if portal.material_override == null or not (portal.material_override as StandardMaterial3D).emission_enabled:
            _fail("cargo docking ring must be visibly illuminated")
            return
    if relay.find_children("*", "CollisionObject3D", true, false).size() != 0:
        _fail("optional cargo mission must not add collision obstacles")
        return
    harbor.set("running", true)
    harbor.set("travel_speed", 20.0)
    harbor.call("_process", 0.1)
    var initial_z: float = stations[0].position.z
    relay.call("_process", 0.5)
    if not is_equal_approx(stations[0].position.z, initial_z + 10.0):
        _fail("delivery checkpoints must scroll at actual race speed")
        return
    harbor.call("reset_cargo_relay")
    relay.set("running", true)
    stations[0].position.z = 0.3
    var first: Dictionary = harbor.call("check_cargo_delivery", -3.1)
    if not bool(first.get("delivered", false)) or int(first.get("xp", 0)) != 30 or int(first.get("energy", 0)) != 12:
        _fail("correct lane must award cargo XP and energy")
        return
    if not (harbor.call("check_cargo_delivery", -3.1) as Dictionary).is_empty():
        _fail("one checkpoint must not pay out twice")
        return
    stations[1].position.z = 0.3
    var missed: Dictionary = harbor.call("check_cargo_delivery", 0.0)
    if not bool(missed.get("missed", false)) or int(relay.get("missed_deliveries")) != 1:
        _fail("middle lane must safely skip an optional cargo transfer")
        return
    harbor.call("reset_cargo_relay")
    relay.set("running", false)
    stations[0].position.z = 0.3
    if not (harbor.call("check_cargo_delivery", -3.1) as Dictionary).is_empty():
        _fail("paused menu or vocabulary phase must never award cargo")
        return

    harbor.queue_free()
    var game := preload("res://world.gd").new() as Node3D
    root.add_child(game)
    await process_frame
    game.set("world_choice", 2)
    game.call("_reset_run")
    var active_harbor := game.get("harbor_zone") as Node3D
    var active_relay := active_harbor.get_node("Playable Star Harbor cargo relay") as Node3D
    active_relay.set("running", true)
    var active_stations: Array = active_relay.get("stations")
    var hero := game.get("rider") as Node3D
    for index in range(3):
        active_stations[index].position.z = 0.3
        hero.position.x = -3.1 if index % 2 == 0 else 3.1
        game.call("_update_harbor_cargo_relay")
    if int(active_harbor.call("get_cargo_deliveries")) != 3:
        _fail("the real world must count three delivered cargo checkpoints")
        return
    if int(game.get("xp")) != 90 or int(game.get("power")) != 36:
        _fail("the game must apply exactly three XP and energy payouts")
        return
    game.set("distance", game.get("mission_target"))
    game.call("_finish_run")
    var reward := game.get("reward_label") as Label
    if reward == null or not reward.text.contains("HAFEN-FRACHTRELAIS"):
        _fail("completed cargo mission must be displayed in results")
        return
    if int(game.get("total_stars")) != 4:
        _fail("three lives plus optional cargo relay must award four stars")
        return
    game.call("_reset_run")
    if int(active_harbor.call("get_cargo_deliveries")) != 0:
        _fail("a new round must reset the cargo mission")
        return
    print("HARBOR CARGO RELAY TEST PASSED: five 3D delivery gates, lane rewards, safe miss, pause, reset and mission star")
    quit(0)
