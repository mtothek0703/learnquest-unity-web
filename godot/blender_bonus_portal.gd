extends Node3D
# Original Blender GLB: real race pickup, no added physics collider or save keys.
signal entered

const PORTAL_SCENE: PackedScene = preload("res://assets/3d/learnquest_portal.glb")
const START_Z := -65.0
const PICKUP_HALF_WIDTH := 1.25

var runner: Node3D
var running := false
var travel_speed := 14.0
var passed := false
var portal_model: Node3D

func _ready() -> void:
    portal_model = PORTAL_SCENE.instantiate() as Node3D
    portal_model.name = "Actual Blender 3D Portal"
    add_child(portal_model)
    reset_for_world(0)

func reset_for_world(world_index: int) -> void:
    position = Vector3(0.0, 0.0, START_Z)
    rotation = Vector3.ZERO
    passed = false
    running = false
    visible = world_index == 0

func advance(delta: float) -> void:
    if not running or passed or not visible or runner == null:
        return
    if not is_finite(delta) or delta <= 0.0 or not is_finite(travel_speed) or travel_speed <= 0.0:
        return
    var old_z := position.z
    position.z += travel_speed * delta
    if old_z < runner.position.z and position.z >= runner.position.z:
        passed = true
        if absf(runner.position.x - position.x) <= PICKUP_HALF_WIDTH:
            entered.emit()
    if position.z > runner.position.z + 5.0:
        visible = false

func _process(delta: float) -> void:
    advance(delta)
