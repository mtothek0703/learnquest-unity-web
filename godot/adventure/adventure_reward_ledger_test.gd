extends SceneTree

const Ledger = preload("res://adventure/adventure_reward_ledger.gd")

func _initialize() -> void:
    var ledger = Ledger.new()
    _check(not ledger.award_once("neon_city_rooftop", "run-1", false)["granted"], "locked objective")
    _check(not ledger.award_once("neon_city_rooftop", "", true)["granted"], "empty session")
    _check(not ledger.award_once("unknown", "run-1", true)["granted"], "unknown world")
    var first: Dictionary = ledger.award_once("neon_city_rooftop", "run-1", true)
    _check(first["granted"] and first["xp"] == 40 and first["stars"] == 1, "first reward")
    _check(ledger.was_awarded("neon_city_rooftop", "run-1"), "awarded marker")
    _check(not ledger.award_once("neon_city_rooftop", "run-1", true)["granted"], "no duplicate")
    _check(ledger.award_once("neon_city_rooftop", "run-2", true)["granted"], "independent session")
    ledger.reset_session("run-1")
    _check(not ledger.was_awarded("neon_city_rooftop", "run-1"), "reset one session")
    _check(ledger.was_awarded("neon_city_rooftop", "run-2"), "preserve other session")
    _check(ledger.award_once("neon_city_rooftop", "run-1", true)["granted"], "retry new session state")
    print("Adventure reward ledger tests passed")
    quit(0)

func _check(condition: bool, label: String) -> void:
    if not condition:
        push_error("Adventure reward ledger: " + label)
        quit(1)
