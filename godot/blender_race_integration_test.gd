extends SceneTree

func _initialize() -> void:
    call_deferred("_run")

func _fail(message: String) -> void:
    push_error("BLENDER RACE INTEGRATION FAILED: " + message)
    quit(1)

func _run() -> void:
    var scene := load("res://main.tscn") as PackedScene
    if scene == null:
        _fail("main scene could not load")
        return
    var world := scene.instantiate() as Node3D
    root.add_child(world)
    await process_frame
    var portal := world.get_node_or_null("Blender Bonus Portal") as Node3D
    var rider := world.get("rider") as Node3D
    if portal == null or rider == null or portal.get_node_or_null("Actual Blender 3D Portal") == null:
        _fail("Blender mesh not instantiated in running game")
        return

    world.call("_reset_run")
    if not portal.visible or portal.position.z != -65.0:
        _fail("Neon City portal did not reset at its first location")
        return

    var score_before := int(world.get("xp"))
    rider.position.x = 0.0
    portal.position.z = rider.position.z - 0.7
    portal.set("travel_speed", 14.0)
    portal.set("running", true)
    portal.call("advance", 0.10)
    if int(world.get("xp")) != score_before + 25 or int(world.get("power")) != 15:
        _fail("center-lane portal crossing did not award 25 XP and 15 energy")
        return
    if float(world.get("turbo_left")) < 2.0 or not bool(portal.get("passed")):
        _fail("portal boost or one-time guard failed")
        return
    portal.call("advance", 0.15)
    if int(world.get("xp")) != score_before + 25:
        _fail("same portal granted XP twice")
        return

    world.call("_reset_run")
    rider.position.x = 3.1
    portal.position.z = rider.position.z - 0.7
    portal.set("running", true)
    portal.call("advance", 0.10)
    if int(world.get("xp")) != 0 or int(world.get("power")) != 0:
        _fail("portal granted reward from the wrong lane")
        return

    world.call("_reset_run")
    portal.set("running", false)
    var previous_z := portal.position.z
    portal.call("advance", 1.0)
    if portal.position.z != previous_z:
        _fail("portal moved while race was paused")
        return

    portal.call("reset_for_world", 2)
    if portal.visible:
        _fail("Neon portal leaked into another world")
        return
    portal.set("running", true)
    portal.call("advance", 1.0)
    if portal.position.z != -65.0:
        _fail("hidden portal moved in a different world")
        return
    print("BLENDER RACE INTEGRATION TEST PASSED")
    quit(0)
