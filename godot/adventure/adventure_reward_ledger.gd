extends RefCounted
class_name AdventureRewardLedger

# Pure session-local reward gate. The runner remains the sole owner of XP/stars.
# Call award_once only after a validated adventure objective has completed.
const ALLOWED_REWARDS := {
    "neon_city_rooftop": {"xp": 40, "stars": 1}
}
var _awarded: Dictionary = {}

func award_once(world_id: String, session_id: String, objective_complete: bool) -> Dictionary:
    if not objective_complete or session_id.is_empty():
        return {"granted": false, "xp": 0, "stars": 0}
    if not ALLOWED_REWARDS.has(world_id):
        return {"granted": false, "xp": 0, "stars": 0}
    var key := session_id + ":" + world_id
    if _awarded.has(key):
        return {"granted": false, "xp": 0, "stars": 0}
    _awarded[key] = true
    var reward: Dictionary = ALLOWED_REWARDS[world_id]
    return {"granted": true, "xp": int(reward["xp"]), "stars": int(reward["stars"])}

func was_awarded(world_id: String, session_id: String) -> bool:
    return _awarded.has(session_id + ":" + world_id)

func reset_session(session_id: String) -> void:
    if session_id.is_empty():
        return
    for key in _awarded.keys():
        if String(key).begins_with(session_id + ":"):
            _awarded.erase(key)
