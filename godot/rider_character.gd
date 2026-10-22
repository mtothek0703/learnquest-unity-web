extends Node3D
## Independent rider assembly. The legacy hero is a fallback while we replace
## geometry with imported, rigged character assets in a later graphics pass.
@onready var legacy_rider: Node3D = $LegacyRider

var lean: float = 0.0
var boosting: bool = false
var animation_clock: float = 0.0

func _process(delta: float) -> void:
    animation_clock += delta
    if is_instance_valid(legacy_rider):
        legacy_rider.set("lean", lean)
        legacy_rider.set("boosting", boosting)

func set_character_model(model: Node3D) -> void:
    # Replace only the visual rider; gameplay continues to track this root.
    # Imported models can use AnimationPlayer or AnimationTree independently.
    if model == null:
        return
    var old := get_node_or_null("ImportedRider")
    if old != null:
        old.queue_free()
    model.name = "ImportedRider"
    add_child(model)
    if is_instance_valid(legacy_rider):
        legacy_rider.visible = false

func restore_fallback() -> void:
    var imported := get_node_or_null("ImportedRider")
    if imported != null:
        imported.queue_free()
    if is_instance_valid(legacy_rider):
        legacy_rider.visible = true
