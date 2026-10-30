extends SceneTree
## V130: six real three-lane 3D signal gates must be caught without a miss
## for a separate full-round mastery star, energy and short Turbo.
## No new controls, collisions, or interruptions to the three-question round.
func _initialize() -> void:
    call_deferred("_check")

func _fail(reason: String) -> void:
    push_error("NEON PERFECT CHAIN TEST FAILED: " + reason)
    quit(1)

func _check() -> void:
    var game := preload("res://world.gd").new() as Node3D
    root.add_child(game)
    await process_frame
    game.set("world_choice", 0)
    game.call("_reset_run")
    var city := game.get("skyway_zone") as Node3D
    var course := city.get_node_or_null("Playable Neon City signal chain") as Node3D
    var rider := game.get("rider") as Node3D
    if course == null or rider == null:
        _fail("Neon City race, gates or rider missing")
        return
    var gates: Array = course.get("gates")
    var rings: Array = course.get("rings")
    if gates.size() != 6 or rings.size() != 6:
        _fail("six visible signal arches required")
        return
    course.set("running", true)
    var expected_xp := 0
    for index in range(6):
        gates[index].position.z = 0.3
        var lane_index: int = (index + 2) % 3 - 1
        rider.position.x = float(lane_index) * 3.1
        game.call("_update_neon_signals")
        expected_xp += 20 + mini(index + 1, 4) * 5
        if int(game.get("xp")) != expected_xp or int(city.call("get_signal_streak")) != index + 1:
            _fail("perfect streak must award each gate once and grow 1..6")
            return
        if index == 1:
            var glow := rings[2].material_override as StandardMaterial3D
            if glow == null or glow.emission_energy_multiplier <= 2.0 or rings[2].scale.x <= 1.0:
                _fail("upcoming real 3D gates must visibly react to the streak")
                return
        if not (city.call("check_neon_signal", rider.position.x) as Dictionary).is_empty():
            _fail("already collected gate rewarded twice")
            return
    if not bool(city.call("get_signal_perfect_run")) or expected_xp != 210:
        _fail("six consecutive hits must complete mastery without duplicate XP")
        return
    if int(game.get("power")) != 100 or float(game.get("turbo_left")) < 2.49:
        _fail("sixth gate must grant extra energy and 2.5-second Turbo")
        return
    var hud := game.get("hud") as Label
    if hud == null or not hud.text.contains("KETTE 6/6") or not hud.text.contains("PERFEKT!"):
        _fail("landscape HUD must clearly show completed mastery")
        return
    game.set("distance", game.get("mission_target"))
    game.call("_finish_run")
    var reward := game.get("reward_label") as Label
    if int(game.get("total_stars")) != 5 or reward == null or not reward.text.contains("PERFEKTE NEON-SIGNALRUNDE"):
        _fail("full race must award separate Neon mastery star")
        return

    game.call("_reset_run")
    if bool(city.call("get_signal_perfect_run")) or int(city.call("get_signal_streak")) != 0:
        _fail("new round must reset mastery and streak")
        return
    var reset_glow := rings[0].material_override as StandardMaterial3D
    if reset_glow == null or absf(reset_glow.emission_energy_multiplier - 2.0) > 0.01 or absf(rings[0].scale.x - 1.0) > 0.01:
        _fail("new round must reset actual gate visuals")
        return
    course.set("running", true)
    for index in range(6):
        gates[index].position.z = 0.3
        var lane_index: int = (index + 2) % 3 - 1
        rider.position.x = -3.1 if index == 2 else float(lane_index) * 3.1
        game.call("_update_neon_signals")
    if bool(city.call("get_signal_perfect_run")) or int(city.call("get_signal_count")) != 5 or int(city.call("get_signal_streak")) != 3:
        _fail("a missed third gate must break mastery despite five catches")
        return
    game.set("distance", game.get("mission_target"))
    game.call("_finish_run")
    reward = game.get("reward_label") as Label
    if int(game.get("total_stars")) != 9 or reward == null or reward.text.contains("PERFEKTE NEON-SIGNALRUNDE"):
        _fail("broken chain must receive regular mission star but no mastery star")
        return
    if not reward.text.contains("NEON-SIGNALKETTE"):
        _fail("normal mission bonus must remain")
        return
    print("NEON PERFECT CHAIN TEST PASSED: six 3D gates, visible streak, 210 XP, energy/Turbo, extra full-round star, miss and reset")
    quit(0)
