extends SceneTree
## Three English tasks, actual alternating gate pickups, damage and 3D reward.
func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("ENERGY WEAVE MASTERY TEST FAILED: " + message)
    quit(1)

func _catch(game: Node3D, gate: Node3D, target_lane: int) -> void:
    var rider := game.get("rider") as Node3D
    rider.position.x = float(target_lane) * 3.1
    rider.position.y = 0.0
    game.set("lane", target_lane)
    game.set("jump_left", 0.0)
    gate.position = Vector3(rider.position.x, 0.0, rider.position.z - 0.1)
    gate.set_meta("collected", false)
    gate.visible = true
    game.call("_update_run_items", 0.016)

func _check() -> void:
    root.size = Vector2i(1280, 720)
    var game := preload("res://main.tscn").instantiate() as Node3D
    root.add_child(game)
    await process_frame
    game.call("_begin_training")
    for i in range(3):
        if str(game.get("phase")) != "training" or not bool(game.get("quiz_active")):
            _fail("three mandatory English tasks lost")
            return
        var answers: Array = game.get("options")
        game.call("_answer", answers.find(int(game.get("correct_index"))))
    if str(game.get("phase")) != "race" or not bool(game.get("started")):
        _fail("three answers did not unlock full race")
        return
    var ring := game.get("energy_weave_ring") as MeshInstance3D
    if ring == null or not (ring.mesh is TorusMesh) or ring.visible:
        _fail("initially hidden 3D slalom pulse missing")
        return
    if not ring.find_children("*", "CollisionObject3D", true, false).is_empty():
        _fail("slalom VFX introduced collision")
        return
    var items := game.get("run_items") as Node3D
    var gates: Array[Node3D] = []
    var hazard: Node3D
    for item in items.get_children():
        item.position.z = -100.0
        item.set_meta("collected", true)
        if bool(item.get_meta("energy")):
            gates.append(item as Node3D)
        elif hazard == null:
            hazard = item as Node3D
    if gates.size() < 6 or hazard == null:
        _fail("existing energy gates and barriers missing")
        return
    var start_xp := int(game.get("xp"))
    _catch(game, gates[0], -1)
    # Only a different lane receives a visible 3D navigation beacon.
    var same_beacon := gates[1].get_node_or_null("Next slalom lane beacon") as Node3D
    var other_beacon := gates[2].get_node_or_null("Next slalom lane beacon") as Node3D
    if same_beacon == null or other_beacon == null:
        _fail("real 3D slalom guidance missing")
        return
    gates[1].position.x = -3.1
    gates[2].position.x = 3.1
    for gate in [gates[1], gates[2]]:
        gate.set_meta("collected", false)
        gate.visible = true
    game.call("_update_energy_weave_guides")
    if same_beacon.visible or not other_beacon.visible:
        _fail("beacons must highlight only an uncollected alternate-lane gate")
        return
    if other_beacon.find_children("*", "CollisionObject3D", true, false).size() > 0:
        _fail("3D slalom beacon must never add a collision")
        return
    _catch(game, gates[1], -1)
    if int(game.get("energy_weave_streak")) != 1 or int(game.get("xp")) != start_xp + 30:
        _fail("same-lane catches must not advance streak")
        return
    _catch(game, gates[2], 1)
    if int(game.get("energy_weave_streak")) != 2 or bool(game.get("energy_weave_mastery")):
        _fail("alternating catch must advance streak to two")
        return
    var rider := game.get("rider") as Node3D
    rider.position.x = 3.1
    rider.position.y = 0.0
    game.set("turbo_left", 0.0)
    game.set("shield_left", 0.0)
    game.set("hit_cooldown", 0.0)
    hazard.position = Vector3(3.1, 0.0, rider.position.z - 0.1)
    hazard.set_meta("collected", false)
    game.call("_update_run_items", 0.016)
    if int(game.get("lives")) != 2 or int(game.get("energy_weave_streak")) != 0:
        _fail("real barrier hit must break unfinished streak")
        return
    _catch(game, gates[3], -1)
    _catch(game, gates[4], 1)
    _catch(game, gates[5], -1)
    if not bool(game.get("energy_weave_mastery")) or int(game.get("energy_weave_streak")) != 3:
        _fail("three alternating catches did not earn mastery")
        return
    for gate in gates:
        var guide := gate.get_node_or_null("Next slalom lane beacon") as Node3D
        if guide == null or guide.visible:
            _fail("completed slalom must hide all guidance")
            return
    if int(game.get("xp")) != start_xp + 6 * 15 + 75 or float(game.get("turbo_left")) < 2.0:
        _fail("one-shot slalom XP/Turbo incorrect")
        return
    if not ring.visible or ring.scale.x < 0.65:
        _fail("3D mastery pulse not visible")
        return
    game.call("_update_energy_weave_pulse", 1.1)
    if ring.visible:
        _fail("3D pulse must expire")
        return
    var capped_xp := int(game.get("xp"))
    _catch(game, gates[0], 1)
    if int(game.get("xp")) != capped_xp + 15:
        _fail("repeat energy gates must not farm slalom reward")
        return
    game.set("distance", float(game.get("mission_target")))
    game.call("_finish_run")
    var result := game.get("reward_label") as Label
    if str(game.get("phase")) != "results" or result == null or not result.text.contains("ENERGIE-SLALOM"):
        _fail("slalom missing from successful results")
        return
    game.call("_begin_training")
    for i in range(3):
        var answers: Array = game.get("options")
        game.call("_answer", answers.find(int(game.get("correct_index"))))
    if int(game.get("energy_weave_streak")) != 0 or bool(game.get("energy_weave_mastery")) or ring.visible:
        _fail("next round did not reset slalom")
        return
    print("ENERGY WEAVE MASTERY TEST PASSED: 3 English tasks, 3D alternate-lane guidance, damage reset, mastery pulse, capped XP/Turbo, results and replay")
    quit(0)
