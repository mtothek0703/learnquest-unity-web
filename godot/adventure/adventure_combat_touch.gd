extends Control
## Separate on-foot combat controls. Never receives runner gestures.
signal attack_requested
signal guard_changed(active: bool)

var attack_button: Button
var guard_button: Button
var guard_held := false
var combat_enabled := false

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    attack_button = _make_button("ANGRIFF", 0)
    guard_button = _make_button("ABWEHR", 1)
    attack_button.pressed.connect(_on_attack)
    guard_button.button_down.connect(_on_guard_down)
    guard_button.button_up.connect(_on_guard_up)
    visibility_changed.connect(_on_visibility_changed)
    _sync_enabled()

func _make_button(caption: String, slot: int) -> Button:
    var button := Button.new()
    button.text = caption
    button.name = "AttackButton" if slot == 0 else "GuardButton"
    button.custom_minimum_size = Vector2(104, 72)
    button.mouse_filter = Control.MOUSE_FILTER_STOP
    button.anchor_left = 1.0
    button.anchor_right = 1.0
    button.anchor_top = 1.0
    button.anchor_bottom = 1.0
    button.offset_left = -232.0 + 116.0 * slot
    button.offset_right = -128.0 + 116.0 * slot
    button.offset_top = -92.0
    button.offset_bottom = -20.0
    button.focus_mode = Control.FOCUS_NONE
    add_child(button)
    return button

func set_combat_enabled(value: bool) -> void:
    combat_enabled = value
    if not value:
        _release_guard()
    _sync_enabled()

func _sync_enabled() -> void:
    if attack_button != null:
        attack_button.disabled = not combat_enabled
    if guard_button != null:
        guard_button.disabled = not combat_enabled

func _on_attack() -> void:
    if combat_enabled and is_visible_in_tree():
        attack_requested.emit()

func _on_guard_down() -> void:
    if combat_enabled and is_visible_in_tree() and not guard_held:
        guard_held = true
        guard_changed.emit(true)

func _on_guard_up() -> void:
    _release_guard()

func _release_guard() -> void:
    if guard_held:
        guard_held = false
        guard_changed.emit(false)

func _on_visibility_changed() -> void:
    if not visible:
        _release_guard()

func _exit_tree() -> void:
    _release_guard()
