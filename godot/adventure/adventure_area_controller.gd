extends Node3D
## Scene-local binding only; no changes to the hoverboard session.
@onready var mission: Node = $Mission
@onready var mission_hud: Control = $TouchUI/MissionHUD

func _ready() -> void:
	mission_hud.bind_mission(mission)
