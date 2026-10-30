extends SceneTree
## Four consecutive lane catches award a fifth full-round star; a miss breaks the chain.
func _initialize() -> void:
    call_deferred("_check")

func _fail(reason: String) -> void:
    push_error("AURORA PERFECT LINE TEST FAILED: " + reason)
    quit(1)

func _check() -> void:
    var game := preload("res://world.gd").new() as Node3D
    root.add_child(game)
    await process_frame
    game.set("world_choice", 3)
    game.call("_reset_run")
    var glacier := game.get("glacier_zone") as Node3D
    var course := glacier.get_node("Playable Aurora slipstream course") as Node3D
    var stations: Array = course.get("stations")
    var rider := game.get("rider") as Node3D
    course.set("running", true)
    var expected_xp := 0
    for index in range(4):
        stations[index].position.z = 0.3
        rider.position.x = stations[index].position.x
        game.call("_update_aurora_slipstream")
        expected_xp += 35 + 10 * index
        if int(game.get("xp")) != expected_xp or int(glacier.call("get_aurora_streak")) != index + 1:
            _fail("consecutive real catches must raise XP and streak")
            return
        if not (glacier.call("check_aurora_stream", rider.position.x) as Dictionary).is_empty():
            _fail("a scored wind tunnel paid out twice")
            return
    if expected_xp != 200 or int(game.get("power")) != 60 or float(game.get("turbo_left")) < 3.99:
        _fail("four-tunnel perfect line must grant 200 XP, 60 energy and 4-second Turbo")
        return
    if not bool(glacier.call("get_aurora_perfect_line")):
        _fail("four consecutive intercepts must complete the perfect line")
        return
    var hud := game.get("hud") as Label
    if hud == null or not hud.text.contains("KETTE: 4/4"):
        _fail("landscape HUD must show streak progress")
        return
    game.set("distance", game.get("mission_target"))
    game.call("_finish_run")
    var reward := game.get("reward_label") as Label
    if int(game.get("total_stars")) != 5 or reward == null or not reward.text.contains("PERFEKTE AURORA-LINIE"):
        _fail("full round must award a separate mastery star")
        return
    game.call("_reset_run")
    course.set("running", true)
    if bool(glacier.call("get_aurora_perfect_line")) or int(glacier.call("get_aurora_streak")) != 0:
        _fail("next round must reset perfect-line state")
        return
    for index in range(4):
        stations[index].position.z = 0.3
        rider.position.x = -3.1 if index == 2 else stations[index].position.x
        game.call("_update_aurora_slipstream")
    if bool(glacier.call("get_aurora_perfect_line")) or int(glacier.call("get_aurora_streak")) != 1:
        _fail("missed third tunnel must break chain despite three total catches")
        return
    game.set("distance", game.get("mission_target"))
    game.call("_finish_run")
    reward = game.get("reward_label") as Label
    if int(game.get("total_stars")) != 9 or reward == null:
        _fail("broken chain must award normal stream star only")
        return
    if not reward.text.contains("AURORA-WINDSTROM") or reward.text.contains("PERFEKTE AURORA-LINIE"):
        _fail("result must distinguish regular bonus from flawless mastery")
        return
    print("AURORA PERFECT LINE TEST PASSED: consecutive catches, escalating Turbo/XP, miss reset, extra full-round star")
    quit(0)
