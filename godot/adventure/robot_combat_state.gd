extends RefCounted
## Deterministic, engine-independent combat rules for the future Neon City walking arena.
## This is deliberately NOT connected to the existing runner or its bosses.
## The encounter only advances when its owner calls advance(delta), so pausing
## the adventure pauses all attacks without relying on real-time timers.

signal warning_started
signal attack_resolved(blocked: bool)
signal robot_damaged(remaining_health: int)
signal robot_defeated

const MAX_HEALTH := 3
const WARNING_SECONDS := 1.1
const RECOVERY_SECONDS := 1.0
const ATTACK_RANGE := 2.4
const PLAYER_ATTACK_RANGE := 2.0

var health: int = MAX_HEALTH
var state: String = "idle" # idle -> warning -> recovery -> idle / defeated
var remaining: float = 0.0
var player_in_range: bool = false
var guard_active: bool = false
var hits_taken: int = 0

func reset() -> void:
    health = MAX_HEALTH
    state = "idle"
    remaining = 0.0
    player_in_range = false
    guard_active = false
    hits_taken = 0

func set_player_distance(distance: float) -> void:
    player_in_range = distance >= 0.0 and distance <= ATTACK_RANGE

func set_guard(active: bool) -> void:
    guard_active = active

func player_attack(distance: float) -> bool:
    if state == "defeated" or distance < 0.0 or distance > PLAYER_ATTACK_RANGE:
        return false
    health -= 1
    robot_damaged.emit(health)
    if health <= 0:
        health = 0
        state = "defeated"
        remaining = 0.0
        robot_defeated.emit()
    return true

func advance(delta: float) -> void:
    if delta <= 0.0 or state == "defeated":
        return
    # Resolve at most one state transition per update; excess frame time is
    # intentionally discarded to prevent an invisible multi-hit on tab resume.
    if state == "idle":
        if player_in_range:
            state = "warning"
            remaining = WARNING_SECONDS
            warning_started.emit()
    elif state == "warning":
        remaining -= delta
        if remaining <= 0.0:
            if player_in_range:
                if not guard_active:
                    hits_taken += 1
                attack_resolved.emit(guard_active)
            state = "recovery"
            remaining = RECOVERY_SECONDS
    elif state == "recovery":
        remaining -= delta
        if remaining <= 0.0:
            state = "idle"
            remaining = 0.0
