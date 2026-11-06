extends SceneTree

const Bridge = preload("res://adventure/race_pause_bridge.gd")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var root_node := Node.new()
    root.add_child(root_node)
    var bridge := Bridge.new()
    root_node.add_child(bridge)
    var race := Node.new()
    root_node.add_child(race)
    race.process_mode = Node.PROCESS_MODE_ALWAYS
    var hazard := Node.new()
    root_node.add_child(hazard)
    hazard.process_mode = Node.PROCESS_MODE_INHERIT
    assert(not bridge.enter_on_foot([race, hazard], false))
    assert(race.process_mode == Node.PROCESS_MODE_ALWAYS)
    assert(not bridge.enter_on_foot([race, race], true))
    assert(bridge.enter_on_foot([race, hazard], true))
    assert(bridge.is_on_foot())
    assert(race.process_mode == Node.PROCESS_MODE_DISABLED)
    assert(hazard.process_mode == Node.PROCESS_MODE_DISABLED)
    assert(not bridge.enter_on_foot([race], true))
    assert(bridge.return_to_race())
    assert(not bridge.is_on_foot())
    assert(race.process_mode == Node.PROCESS_MODE_ALWAYS)
    assert(hazard.process_mode == Node.PROCESS_MODE_INHERIT)
    assert(not bridge.return_to_race())
    assert(bridge.enter_on_foot([race], true))
    bridge.abort_transition()
    assert(race.process_mode == Node.PROCESS_MODE_ALWAYS)
    assert(bridge.enter_on_foot([race], true))
    bridge.queue_free()
    await process_frame
    assert(race.process_mode == Node.PROCESS_MODE_ALWAYS)
    print("ADVENTURE RACE PAUSE BRIDGE TEST PASSED")
    quit(0)
