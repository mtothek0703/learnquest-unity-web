extends Area3D
## Single-use collectible, independent of Runner rewards.
@export var crystal_id: String = ""
@export var mission_path: NodePath = NodePath("../Mission")
@export var walker_path: NodePath = NodePath("../Walker")

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body != get_node_or_null(walker_path):
		return
	var mission := get_node_or_null(mission_path)
	if mission != null and mission.collect_crystal(crystal_id):
		visible = false
		set_deferred("monitoring", false)

func reset_crystal() -> void:
	visible = true
	set_deferred("monitoring", true)
