extends SceneTree
## V140: three English tasks -> real landscape jump gesture -> 3 airborne
## energy pickups -> capped mastery -> results -> next-round reset.
func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("AERIAL ENERGY MASTERY TEST FAILED: " + message)
    quit(1)

func _three_questions(game: Node) -> bool:
    game.call("_begin_training")
    for question in range(3):
        if str(game.get("phase")) != "training" or not bool(game.get("quiz_active")):
            _fail("missing mandatory vocabulary question %d" % question)
            return false
        var choices: Array = game.get("options")
        var correct := choices.find(int(game.get("correct_index")))
        if correct < 0:
            _fail("no correct answer")
            return false
        game.call("_answer", correct)
    if str(game.get("phase")) != "race" or bool(game.get("quiz_active")) or not bool(game.get("started")):
        _fail("three questions did not unlock the continuous race")
        return false
    return true

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

func _catch(game: Node, item: Node3D, airborne: bool) -> void:
    var rider := game.get("rider") as Node3D
    game.set("jump_left", 0.42 if airborne else 0.0)
    item.position = Vector3(rider.position.x, 0.0, rider.position.z - 0.10)
    item.set_meta("collected", false)
    item.visible = true
    game.call("_update_run_items", 0.016)

func _check() -> void:
    root.size = Vector2i(1280, 720)
    var game := preload("res://main.tscn").instantiate() as Node3D
    root.add_child(game)
    await process_frame
    if not _three_questions(game):
        return
    var items := game.get("run_items") as Node3D
    var gates: Array[Node3D] = []
    for item in items.get_children():
        if bool(item.get_meta("energy")):
            gates.append(item as Node3D)
            var ring := item.get_node_or_null("Aerial energy bonus ring") as MeshInstance3D
            if ring == null or not (ring.mesh is TorusMesh) or ring.position.y < 2.3:
                _fail("raised 3D aerial target missing")
                return
            if not ring.find_children("*", "CollisionShape3D", true, false).is_empty():
                _fail("visual target introduced collision")
                return
    if gates.size() < 5:
        _fail("existing energy pickups missing")
        return
    if int(game.get("aerial_energy_count")) != 0 or bool(game.get("aerial_energy_mastery")):
        _fail("new race did not reset aerial progress")
        return
    # An ordinary ground pickup retains the previous +15 XP and +18 energy.
    var start_xp := int(game.get("xp"))
    var start_power := int(game.get("power"))
    _catch(game, gates[0], false)
    if int(game.get("xp")) != start_xp + 15 or int(game.get("aerial_energy_count")) != 0:
        _fail("ground energy pickup changed")
        return
    if int(game.get("power")) != mini(100, start_power + 18):
        _fail("ground energy recharge changed")
        return
    # Exercise the existing real touch interpreter, not a new button.
    game.call("_input", _touch(true, Vector2(640, 360)))
    game.call("_input", _drag(Vector2(640, 250)))
    if float(game.get("jump_left")) <= 0.0:
        _fail("landscape touch jump no longer works")
        return
    game.call("_input", _touch(false, Vector2(640, 250)))
    var baseline := int(game.get("xp"))
    for i in range(3):
        _catch(game, gates[i + 1], true)
        var expected := baseline + (i + 1) * 35 + (40 if i == 2 else 0)
        if int(game.get("aerial_energy_count")) != i + 1 or int(game.get("xp")) != expected:
            _fail("airborne reward or streak mismatch at %d" % i)
            return
        if float(game.get("turbo_left")) < (2.0 if i == 2 else 1.0):
            _fail("real Turbo reward missing")
            return
    if not bool(game.get("aerial_energy_mastery")):
        _fail("third aerial catch did not complete mastery")
        return
    var hud := game.get("hud") as Label
    game.call("_refresh_hud")
    if hud == null or not hud.text.contains("LUFT 3/3"):
        _fail("landscape progress not visible")
        return
    # The fourth aerial catch must not re-award a capped mastery.
    var capped_xp := int(game.get("xp"))
    _catch(game, gates[4], true)
    if int(game.get("xp")) != capped_xp + 15 or int(game.get("aerial_energy_count")) != 3:
        _fail("airborne bonus can be farmed past the cap")
        return
    game.set("distance", float(game.get("mission_target")))
    game.call("_finish_run")
    var reward := game.get("reward_label") as Label
    if str(game.get("phase")) != "results" or reward == null or not reward.text.contains("LUFT-ENERGIE"):
        _fail("mastery missing from completed results")
        return
    if not _three_questions(game):
        return
    if int(game.get("aerial_energy_count")) != 0 or bool(game.get("aerial_energy_mastery")):
        _fail("next round did not reset aerial mastery")
        return
    print("AERIAL ENERGY MASTERY TEST PASSED: 3 English questions, real touch jump, raised 3D rings, capped airborne XP/Turbo, results and replay")
    quit(0)
