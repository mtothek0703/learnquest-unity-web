extends SceneTree
## Real Neon City mission integration: all three existing steering lanes,
## six 3D gates, streak energy, pause safety, full-level bonus and reset.

func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("NEON SIGNAL CHAIN TEST FAILED: " + message)
    quit(1)

func _check() -> void:
    var city := preload("res://neon_environment.gd").new() as Node3D
    root.add_child(city)
    await process_frame
    var chain := city.get_node_or_null("Playable Neon City signal chain") as Node3D
    if chain == null:
        _fail("playable signal chain is not part of Neon City")
        return
    var gates: Array = chain.get("gates")
    var rings: Array = chain.get("rings")
    var beacons: Array = chain.get("beacons")
    var precision_rings: Array = chain.get("precision_rings")
    if gates.size() != 6 or rings.size() != 6 or beacons.size() != 6 or precision_rings.size() != 6:
        _fail("six visible 3D signal gates are required")
        return
    for index in range(6):
        var ring := rings[index] as MeshInstance3D
        var beacon := beacons[index] as MeshInstance3D
        if ring == null or not ring.mesh is TorusMesh or beacon == null or not beacon.mesh is CylinderMesh:
            _fail("each gate must have a modeled 3D arch and animated signal")
            return
        var lane_index: int = (index + 2) % 3 - 1
        if not is_equal_approx(ring.position.x, float(lane_index) * 3.1):
            _fail("signal gates must align with the three confirmed touch lanes")
            return
        var bullseye := precision_rings[index] as MeshInstance3D
        if bullseye == null or not bullseye.mesh is TorusMesh or \
                absf(bullseye.position.x - ring.position.x) > 0.001 or \
                (bullseye.mesh as TorusMesh).outer_radius >= (ring.mesh as TorusMesh).inner_radius:
            _fail("each gate needs a concentric modeled gold precision target")
            return
        if not (ring.material_override as StandardMaterial3D).emission_enabled:
            _fail("signal arch must be visibly illuminated")
            return
        if gates[index].get_child_count() < 7:
            _fail("gates require 3D pylons and approach chevrons")
            return
    if chain.find_children("*", "CollisionObject3D", true, false).size() != 0:
        _fail("optional signals must never introduce collisions")
        return

    city.set("running", true)
    city.set("travel_speed", 14.0)
    city.call("_process", 0.0)
    var z_before: float = gates[0].position.z
    chain.call("_process", 0.5)
    if not is_equal_approx(gates[0].position.z, z_before + 7.0):
        _fail("signals must advance with the real race speed")
        return

    city.call("reset_signals")
    chain.set("running", true)
    for index in range(3):
        gates[index].position.z = 0.3
        var lane_index: int = (index + 2) % 3 - 1
        var event: Dictionary = city.call("check_neon_signal", float(lane_index) * 3.1)
        if not bool(event.get("hit", false)) or int(event.get("streak", 0)) != index + 1:
            _fail("consecutive correctly steered gates must grow the streak")
            return
        if index == 2 and (not bool(event.get("overdrive", false)) or int(event.get("energy", 0)) != 30):
            _fail("third consecutive gate must unlock a real overdrive energy bonus")
            return
        if not (city.call("check_neon_signal", float(lane_index) * 3.1) as Dictionary).is_empty():
            _fail("the same gate must never reward twice")
            return
    gates[3].position.z = 0.3
    var miss: Dictionary = city.call("check_neon_signal", -3.1)
    if not bool(miss.get("missed", false)) or int(city.call("get_signal_streak")) != 0:
        _fail("a missed lane must reset the streak without damaging the rider")
        return
    city.call("reset_signals")
    chain.set("running", false)
    gates[0].position.z = 0.3
    if not (city.call("check_neon_signal", 3.1) as Dictionary).is_empty():
        _fail("paused vocabulary/menu must never award a signal")
        return
    if int(city.call("get_signal_count")) != 0:
        _fail("reset must clear mission progress")
        return

    city.queue_free()
    var game := preload("res://world.gd").new() as Node3D
    root.add_child(game)
    await process_frame
    game.set("world_choice", 0)
    game.call("_reset_run")
    var active_city := game.get("skyway_zone") as Node3D
    var active_chain := active_city.get_node("Playable Neon City signal chain") as Node3D
    active_chain.set("running", true)
    var active_gates: Array = active_chain.get("gates")
    var rider := game.get("rider") as Node3D
    for index in range(4):
        active_gates[index].position.z = 0.3
        var lane_index: int = (index + 2) % 3 - 1
        rider.position.x = float(lane_index) * 3.1
        game.call("_update_neon_signals")
    if int(active_city.call("get_signal_count")) != 4:
        _fail("four real Neon City gates must complete the optional mission")
        return
    if int(game.get("xp")) != 25 + 30 + 35 + 40 + 4 * 10 or int(game.get("power")) != 12 + 12 + 30 + 12:
        _fail("world integration must apply each unique streak XP/energy payout")
        return
    game.set("distance", game.get("mission_target"))
    game.call("_finish_run")
    var reward := game.get("reward_label") as Label
    if reward == null or not reward.text.contains("NEON-SIGNALKETTE"):
        _fail("full uninterrupted level results must show the Neon mission star")
        return
    if int(game.get("total_stars")) != 4:
        _fail("three lives plus optional Neon mission must award four stars")
        return
    game.call("_reset_run")
    if int(active_city.call("get_signal_precision_count")) != 0 or bool(active_city.call("get_signal_precision_mastery")):
        _fail("new round must clear precision progress")
        return
    if int(active_city.call("get_signal_count")) != 0:
        _fail("new round must reset all six gates and progress")
        return
    city.call("reset_signals")
    chain.set("running", true)
    gates[0].position.z = 0.3
    var edge: Dictionary = city.call("check_neon_signal", 3.1 + 0.8)
    if not bool(edge.get("hit", false)) or bool(edge.get("precision", true)) or \
            int(edge.get("xp", 0)) != 25 or int(city.call("get_signal_precision_count")) != 0:
        _fail("existing 1.30m catch zone must remain valid without gold bonus")
        return
    print("NEON SIGNAL CHAIN TEST PASSED: six 3D gates, three lanes, overdrive, pause, reset, full-level star")
    quit(0)
