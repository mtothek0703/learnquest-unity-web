extends SceneTree
## V125 integration regression: a real modeled Neon City boss, three telegraphed
## sweep beats, shield/jump safety, attack defeat, mission reward and reset.

func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("NEON CONDUCTOR TEST FAILED: " + message)
    quit(1)

func _check() -> void:
    var boss := preload("res://neon_conductor.gd").new() as Node3D
    root.add_child(boss)
    await process_frame
    var meshes := boss.find_children("*", "MeshInstance3D", true, false)
    if meshes.size() < 7:
        _fail("boss must have modeled continuous body, fins, core and three coils")
        return
    var shell := boss.get_node_or_null("Continuous ribbed conductor body") as MeshInstance3D
    if shell == null or not shell.mesh is ArrayMesh or shell.mesh.surface_get_array_len(0) < 4000:
        _fail("boss body must use substantial curved procedural geometry")
        return
    var fins: Array = boss.get("fins")
    if fins.size() != 2 or boss.get_node_or_null("Counter-rotating conductor coils") == null:
        _fail("two animated fins and orbiting coils are required")
        return
    if boss.find_children("*", "CollisionObject3D", true, false).size() != 0:
        _fail("boss visual must not introduce untested collisions")
        return
    boss.set("active", true)
    boss.call("_process", 0.5)
    if not float(boss.get("elapsed")) > 0.0:
        _fail("conductor geometry must animate when active")
        return
    boss.call("take_hit")
    if float(boss.get("hit_flash")) <= 0.0:
        _fail("boss must react visibly to super attack")
        return
    boss.queue_free()

    var game := preload("res://world.gd").new() as Node3D
    root.add_child(game)
    await process_frame
    game.set("world_choice", 0)
    game.call("_reset_run")
    var conductor := game.get("neon_conductor") as Node3D
    var warning := game.get("neon_beam") as MeshInstance3D
    if conductor == null or warning == null or conductor.visible or warning.visible:
        _fail("Neon boss must exist but stay hidden before its checkpoint")
        return
    if game.get("phase") != "race" or int(game.get("world_choice")) != 0:
        _fail("Neon boss must use the existing uninterrupted Neon City race")
        return
    game.call("_update_neon_conductor", 0.5)
    if bool(game.get("neon_active")):
        _fail("boss must not spawn before the mid-level checkpoint")
        return
    game.set("distance", 470.0)
    game.call("_update_neon_conductor", 0.1)
    if not bool(game.get("neon_active")) or not conductor.visible:
        _fail("boss must enter the actual Neon City race")
        return
    game.call("_update_neon_conductor", 2.1)
    if not warning.visible or int(game.get("neon_sweep_lane")) != -1:
        _fail("first sweep beat must visibly telegraph the left lane")
        return
    var hero := game.get("rider") as Node3D
    hero.position.y = 0.0
    game.set("lane", 1)
    game.call("_update_neon_conductor", 1.4)
    if int(game.get("lives")) != 3 or int(game.get("neon_sweep_lane")) != 0:
        _fail("dodging the first beam must preserve lives and warn the center lane")
        return
    game.set("lane", 0)
    game.call("_update_neon_conductor", 1.0)
    if int(game.get("lives")) != 2 or int(game.get("neon_sweep_lane")) != 1:
        _fail("remaining in the warned lane must cause one hit and advance the sweep")
        return
    game.set("lane", 1)
    game.set("shield_left", 4.0)
    game.call("_update_neon_conductor", 1.0)
    if int(game.get("lives")) != 2 or warning.visible or int(game.get("neon_sweep_direction")) != -1:
        _fail("shield must protect against the third beat and reverse the next sweep")
        return
    game.set("phase", "training")
    var paused_timer: float = game.get("neon_attack_timer")
    game.call("_update_neon_conductor", 10.0)
    if not is_equal_approx(float(game.get("neon_attack_timer")), paused_timer):
        _fail("vocabulary/menu phase must never advance boss attacks")
        return
    game.set("phase", "race")
    game.set("shield_left", 0.0)
    for index in range(3):
        game.set("power", 100)
        game.set("attack_left", 0.0)
        game.call("_use_super_attack")
        if index < 2 and int(game.get("neon_hp")) != 2 - index:
            _fail("each Super Attack must remove exactly one boss core point")
            return
    if not bool(game.get("neon_defeated")) or bool(game.get("neon_active")) or warning.visible or conductor.visible:
        _fail("third hit must defeat and hide the boss without leaving a live warning")
        return
    game.set("lives", 3)
    game.set("distance", game.get("mission_target"))
    game.call("_finish_run")
    var reward := game.get("reward_label") as Label
    if reward == null or not reward.text.contains("NEON-DIRIGENT BESIEGT"):
        _fail("full level result must explicitly award the new boss bonus")
        return
    if int(game.get("total_stars")) != 4:
        _fail("three lives plus defeated Neon boss must award four stars")
        return
    game.call("_reset_run")
    if int(game.get("neon_hp")) != 3 or bool(game.get("neon_defeated")) or conductor.visible or warning.visible:
        _fail("next race must reset all boss state without stale hazards")
        return
    # New optional lane skill: a shield/jump save is valid survival, but it
    # must not count as a clean dodge of the warned lane.
    game.set("distance", 470.0)
    game.call("_update_neon_conductor", 0.1)
    game.set("neon_warning_left", 0.1)
    game.set("neon_sweep_lane", -1)
    game.set("lane", 1)
    game.call("_update_neon_conductor", 0.2)
    if int(game.get("neon_dodge_streak")) != 1:
        _fail("safe-lane steering must count as one clean boss dodge")
        return
    game.set("neon_warning_left", 0.1)
    game.set("neon_sweep_lane", 0)
    game.set("lane", 0)
    game.set("shield_left", 4.0)
    game.call("_update_neon_conductor", 0.2)
    if int(game.get("neon_dodge_streak")) != 0 or int(game.get("lives")) != 3:
        _fail("shield must preserve life without crediting clean lane mastery")
        return
    game.call("_reset_run")
    game.set("distance", 470.0)
    game.call("_update_neon_conductor", 0.1)
    for beat in range(3):
        game.set("neon_warning_left", 0.1)
        game.set("neon_sweep_lane", beat - 1)
        game.set("lane", 1 if beat < 2 else -1)
        game.call("_update_neon_conductor", 0.2)
    if not bool(game.get("neon_dodge_mastery")) or int(game.get("neon_dodge_streak")) != 3 or \
            int(game.get("xp")) != 60 or float(game.get("turbo_left")) < 2.0:
        _fail("three actual clean dodges must award exactly 60 XP and 2s Turbo")
        return
    game.call("_refresh_hud")
    var skill_hud := game.get("hud") as Label
    if skill_hud == null or not skill_hud.text.contains("AUSWEICH 3/3"):
        _fail("Neon boss clean-dodge progress must be visible in race HUD")
        return
    game.set("mobile_hud_layout", true)
    game.call("_refresh_hud")
    if not skill_hud.text.contains("BOSS 3/3  AUSWEICH 3/3") or skill_hud.text.contains("NEON-DIRIGENT 3/3"):
        _fail("narrow phone landscape HUD needs a compact boss dodge indicator")
        return
    game.set("mobile_hud_layout", false)
    game.set("neon_warning_left", 0.1)
    game.set("neon_sweep_lane", 0)
    game.set("lane", 1)
    game.call("_update_neon_conductor", 0.2)
    if int(game.get("xp")) != 60:
        _fail("clean-dodge mastery must be awarded only once per round")
        return
    game.set("distance", game.get("mission_target"))
    game.call("_finish_run")
    if not (game.get("reward_label") as Label).text.contains("NEON-TANZ"):
        _fail("completed race results must recognize three clean boss dodges")
        return
    game.call("_reset_run")
    if bool(game.get("neon_dodge_mastery")) or int(game.get("neon_dodge_streak")) != 0:
        _fail("next race must reset boss dodge streak and mastery")
        return
    game.set("world_choice", 1)
    game.call("_apply_world_theme")
    game.set("distance", 900.0)
    game.call("_update_neon_conductor", 5.0)
    if bool(game.get("neon_active")):
        _fail("Neon boss must never appear in other worlds")
        return
    print("NEON CONDUCTOR TEST PASSED: sculpted 3D boss, 3-beat lane sweep, dodge, shield, pause, attack, star, reset")
    quit(0)
