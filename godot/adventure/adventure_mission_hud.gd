extends Control
## Adventure-only mission HUD. Does not consume input or modify the runner.
## Attach with bind_mission() after instantiating the Neon City arena.
var mission: Node
var progress_label: Label
var portal_label: Label

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	custom_minimum_size = Vector2(300, 70)
	var panel := PanelContainer.new()
	panel.name = "MissionPanel"
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(panel)
	var rows := VBoxContainer.new()
	rows.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(rows)
	progress_label = Label.new()
	progress_label.name = "Progress"
	rows.add_child(progress_label)
	portal_label = Label.new()
	portal_label.name = "Portal"
	rows.add_child(portal_label)
	_refresh()

func bind_mission(next_mission: Node) -> void:
	if is_instance_valid(mission):
		if mission.crystals_changed.is_connected(_on_progress):
			mission.crystals_changed.disconnect(_on_progress)
		if mission.switches_changed.is_connected(_on_progress):
			mission.switches_changed.disconnect(_on_progress)
		if mission.portal_unlocked.is_connected(_refresh):
			mission.portal_unlocked.disconnect(_refresh)
	mission = next_mission
	if is_instance_valid(mission):
		mission.crystals_changed.connect(_on_progress)
		mission.switches_changed.connect(_on_progress)
		mission.portal_unlocked.connect(_refresh)
	_refresh()

func _on_progress(_current: int, _required: int) -> void:
	_refresh()

func _refresh() -> void:
	if not is_node_ready():
		return
	if not is_instance_valid(mission):
		progress_label.text = "Kristalle 0/3  |  Schalter 0/2"
		portal_label.text = "Portal gesperrt"
		return
	var crystals: int = mission.collected_ids.size()
	var switches: int = mission.activated_switch_ids.size()
	progress_label.text = "Kristalle %d/%d  |  Schalter %d/%d" % [crystals, mission.required_crystals, switches, mission.required_switches]
	portal_label.text = "Portal bereit!" if mission.can_open_portal() else "Portal gesperrt"
