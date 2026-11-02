extends SceneTree
## V151: a real three-barrier alternating near-miss challenge, with safeguards
## against jump, shield, turbo, attack, collision, and repeat reward farming.
func _initialize() -> void:
    call_deferred("_check")

func _fail(reason: String) -> void:
    push_error("ALTERNATING NEAR MISS TEST FAILED: " + reason)
    quit(1)

func _pass(game: Node3D, hazard: Node3D, hazard_x: float, rider_x: float) -> void:
    var rider := game.get("rider") as Node3D
    rider.position.x = rider_x
    hazard.position = Vector3(hazard_x, 0.0, rider.position.z - 0.20)
    hazard.set_meta("collected", false)
    hazard.visible = true
    game.call("_update_run_items", 0.03)

func _check() -> void:
    root.size = Vector2i(1280, 720)
    var game := preload("res://main.tscn").instantiate() as Node3D
    root.add_child(game)
    await process_frame
    game.call("_begin_training")
    for i in range(3):
        if str(game.get("phase")) != "training" or not bool(game.get("quiz_active")):
            _fail("three English tasks must precede the full race")
            return
        var answers: Array = game.get("options")
        game.call("_answer", answers.find(int(game.get("correct_index"))))
    if str(game.get("phase")) != "race" or not bool(game.get("started")):
        _fail("three correct tasks did not unlock the race")
        return
    var ring := game.get("near_miss_ring") as MeshInstance3D
    if ring == null or not (ring.mesh is TorusMesh) or ring.visible:
        _fail("initially hidden real 3D board shockwave missing")
        return
    if not ring.find_children("*", "CollisionObject3D", true, false).is_empty():
        _fail("near-miss VFX must not affect collision")
        return
    var items := game.get("run_items") as Node3D
    var hazards: Array[Node3D] = []
    for item in items.get_children():
        item.position.z = -200.0
        item.set_meta("collected", true)
        if not bool(item.get_meta("energy")):
            hazards.append(item as Node3D)
    if hazards.size() < 10:
        _fail("not enough real in-game hazards")
        return
    game.set("turbo_left", 0.0)
    game.set("shield_left", 0.0)
    game.set("attack_left", 0.0)
    var start_xp := int(game.get("xp"))
    _pass(game, hazards[0], -3.1, 0.0)
    if int(game.get("near_miss_streak")) != 1:
        _fail("first real adjacent-lane hazard did not register")
        return
    _pass(game, hazards[1], -3.1, 0.0)
    if int(game.get("near_miss_streak")) != 1:
        _fail("same-side dodge must reset the alternating chain")
        return
    # Merely watching random left/right hazards while remaining in the
    # center lane is NOT a playable skill challenge.
    _pass(game, hazards[2], 3.1, 0.0)
    if int(game.get("near_miss_streak")) != 1:
        _fail("stationary rider must not earn a chain from random alternating barriers")
        return
    # Restart on the left, then switch the rider to the left lane and
    # pass a center-lane hazard on the opposite side.
    _pass(game, hazards[2], -3.1, 0.0)
    _pass(game, hazards[2], 0.0, -3.1)
    if int(game.get("near_miss_streak")) != 2:
        _fail("opposite-side dodge must advance the chain")
        return
    # Jumping safely above the obstacle is not a ground-level near miss.
    game.set("jump_left", 0.50)
    _pass(game, hazards[3], -3.1, 0.0)
    if int(game.get("near_miss_streak")) != 2:
        _fail("jumped barrier falsely counted as a near miss")
        return
    game.set("jump_left", 0.0)
    # A real hit breaks the chain; XP from earlier rewards is unaffected.
    _pass(game, hazards[4], 0.0, 0.0)
    if int(game.get("lives")) != 2 or int(game.get("near_miss_streak")) != 0:
        _fail("actual barrier damage did not reset near-miss streak")
        return
    game.set("hit_cooldown", 0.0)
    # A shielded adjacent barrier cannot earn a near-miss streak.
    game.set("shield_left", 2.0)
    _pass(game, hazards[5], -3.1, 0.0)
    if int(game.get("near_miss_streak")) != 0:
        _fail("shielded barrier incorrectly counted")
        return
    game.set("shield_left", 0.0)
    _pass(game, hazards[6], -3.1, 0.0)
    _pass(game, hazards[7], 0.0, -3.1)
    _pass(game, hazards[8], -3.1, 0.0)
    if not bool(game.get("near_miss_mastery")) or int(game.get("near_miss_streak")) != 3:
        _fail("three real alternating ground-level dodges did not complete mastery")
        return
    if int(game.get("xp")) != start_xp + 70 or float(game.get("turbo_left")) < 1.70 or not ring.visible:
        _fail("one-shot XP, Turbo and 3D ring reward missing")
        return
    game.call("_update_near_miss_pulse", 1.2)
    if ring.visible:
        _fail("3D ring must expire automatically")
        return
    game.set("turbo_left", 0.0)
    _pass(game, hazards[9], 0.0, -3.1)
    if int(game.get("xp")) != start_xp + 70:
        _fail("repeat hazards must never farm the completed bonus")
        return
    game.set("distance", float(game.get("mission_target")))
    game.call("_finish_run")
    var reward := game.get("reward_label") as Label
    if str(game.get("phase")) != "results" or reward == null or not reward.text.contains("HAARSCHARF"):
        _fail("completed near-miss challenge absent from race results")
        return
    game.call("_begin_training")
    for i in range(3):
        var answers: Array = game.get("options")
        game.call("_answer", answers.find(int(game.get("correct_index"))))
    if bool(game.get("near_miss_mastery")) or int(game.get("near_miss_streak")) != 0 or ring.visible:
        _fail("new full race did not reset the near-miss challenge")
        return
    print("ALTERNATING NEAR MISS TEST PASSED: three English tasks, real barrier crossings, side alternation, jump/shield exclusions, damage reset, 3D reward, replay")
    quit(0)
