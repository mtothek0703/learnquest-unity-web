extends Area3D
## Activates a safe respawn position when the walker enters the checkpoint.
@export var walker_path: NodePath = NodePath("../Walker")
@export var respawn_offset: Vector3 = Vector3(0.0, 1.2, 0.0)

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	var walker := get_node_or_null(walker_path) as CharacterBody3D
	if body == walker and walker.has_method("set_checkpoint"):
		walker.set_checkpoint(global_position + respawn_offset)
