extends SceneTree
## Real 3-question -> touch -> 3D checkpoint -> damage -> result regression.
func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("CLEAN FLIGHT MASTERY TEST FAILED: " + message)
    quit(1)

func _touch(pressed: bool, pos: Vector2) -> InputEventScreenTouch:
    var event := InputEventScreenTouch.new()
    event.index = 0
    event.pressed = pressed
    event.position = pos
    return event

func _drag(pos: Vector2) -> InputEventScreenDrag:
    var event := InputEventScreenDrag.new()
    event.index = 0
    event.position = pos
    return event

func _three_correct(game: Node) -> bool:
    game.call("_begin_training")
    for question in range(3):
        if str(game.get("phase")) != "training" or not bool(game.get("quiz_active")):
            _fail("missing mandatory English task %d" % question)
            return false
        var choices: Array = game.get("options")
        var answer := choices.find(int(game.get("correct_index")))
        if answer < 0:
            _fail("correct vocabulary option missing")
            return false
        game.call("_answer", answer)
    if str(game.get("phase")) != "race" or bool(game.get("quiz_active")) or not bool(game.get("started")):
        _fail("three English answers must unlock the full uninterrupted race")
        return false
    return true

func _check() -> void:
    root.size = Vector2i(1280, 720)
    var game := preload("res://main.tscn").instantiate() as Node3D
    root.add_child(game)
    await process_frame
    if not _three_correct(game):
        return
    var ring := game.get("clean_flight_ring") as MeshInstance3D
    if ring == null or not (ring.mesh is TorusMesh) or ring.visible:
        _fail("real 3D checkpoint ring missing or initially visible")
        return
    if not ring.find_children("*", "CollisionShape3D", true, false).is_empty():
        _fail("checkpoint ring must have no collision")
        return
    game.call("_input", _touch(true, Vector2(640, 360)))
    game.call("_input", _drag(Vector2(730, 360)))
    if int(game.get("lane")) != 1:
        _fail("actual landscape touch steering failed after English tasks")
        return
    game.call("_input", _touch(false, Vector2(730, 360)))
    game.call("_input", _touch(true, Vector2(640, 360)))
    game.call("_input", _drag(Vector2(640, 250)))
    if float(game.get("jump_left")) <= 0.0:
        _fail("actual landscape touch jump failed after English tasks")
        return
    game.call("_input", _touch(false, Vector2(640, 250)))
    game.set("jump_left", 0.0)
    game.set("lane", 0)
    var start_xp := int(game.get("xp"))
    game.set("distance", 249.0)
    game.call("_update_clean_flight", 0.016)
    if int(game.get("clean_flight_count")) != 0 or int(game.get("xp")) != start_xp:
        _fail("reward before the 250m checkpoint")
        return
    for step in range(2):
        game.set("distance", float(step + 1) * 250.0 + 0.1)
        game.call("_update_clean_flight", 0.016)
        if int(game.get("clean_flight_count")) != step + 1 or int(game.get("xp")) != start_xp + 25 * (step + 1):
            _fail("250m checkpoint XP/streak mismatch")
            return
    if not ring.visible:
        _fail("checkpoint did not show the reusable 3D pulse")
        return
    game.set("turbo_left", 0.0)
    game.set("shield_left", 0.0)
    game.set("hit_cooldown", 0.0)
    var rider := game.get("rider") as Node3D
    rider.position.y = 0.0
    rider.position.x = 0.0
    var items := game.get("run_items") as Node3D
    var hazard: Node3D
    for item in items.get_children():
        if not bool(item.get_meta("energy")):
            hazard = item as Node3D
            break
    if hazard == null:
        _fail("original playable hazards disappeared")
        return
    hazard.set_meta("collected", false)
    hazard.position = Vector3(0.0, 0.0, rider.position.z - 0.1)
    game.call("_update_run_items", 0.02)
    if int(game.get("lives")) != 2 or int(game.get("clean_flight_count")) != 0 or ring.visible:
        _fail("real obstacle damage must break the clean-flight streak")
        return
    if int(game.get("xp")) != start_xp + 50:
        _fail("damage removed earned checkpoint XP")
        return
    game.set("distance", 750.2)
    game.call("_update_clean_flight", 0.016)
    if int(game.get("clean_flight_count")) != 1 or int(game.get("clean_flight_rewards")) != 3:
        _fail("post-hit streak restart or reward cap broken")
        return
    game.set("distance", 1000.2)
    game.call("_update_clean_flight", 0.016)
    if bool(game.get("clean_flight_mastery")) or int(game.get("clean_flight_rewards")) != 3:
        _fail("non-consecutive streak awarded mastery")
        return
    game.call("_finish_run")
    if str(game.get("phase")) != "results":
        _fail("race result transition failed")
        return
    if not _three_correct(game):
        return
    start_xp = int(game.get("xp"))
    if int(game.get("clean_flight_rewards")) != 0 or ring.visible:
        _fail("next race did not reset progress and visuals")
        return
    for step in range(3):
        game.set("distance", float(step + 1) * 250.0 + 0.1)
        game.call("_update_clean_flight", 0.016)
    if not bool(game.get("clean_flight_mastery")) or int(game.get("xp")) != start_xp + 125:
        _fail("three consecutive 250m segments must award 125 XP")
        return
    game.set("distance", float(game.get("mission_target")))
    game.call("_finish_run")
    var result := game.get("reward_label") as Label
    if str(game.get("phase")) != "results" or result == null or not result.text.contains("SAUBERER FLUG"):
        _fail("mastery missing from successful result")
        return
    print("CLEAN FLIGHT MASTERY TEST PASSED: 3 English tasks, landscape touch, 3D pulse, damage reset, 125 XP, replay and results")
    quit(0)
