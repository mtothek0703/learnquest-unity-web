extends Node3D
## Scene-local binding only; no changes to the hoverboard session.
@onready var mission: Node = $Mission
@onready var mission_hud: Control = $TouchUI/MissionHUD

func _ready() -> void:
	mission_hud.bind_mission(mission)

## Reset the entire playable scene, not just the mission counters.
## Reused scenes must not retain invisible crystals or activated switches.
func reset_adventure() -> void:
	mission.reset_mission()
	for collectible in [$Crystal1, $Crystal2, $Crystal3]:
		collectible.reset_crystal()
	for switch_node in [$Switch1, $Switch2]:
		switch_node.reset_switch()
	$ExitPortal.reset_portal()
	$Walker.respawn_at_checkpoint()
