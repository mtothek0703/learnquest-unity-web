extends Node
## Reversible pause boundary for the future Neon City on-foot transition.
## Attach explicitly to a scene controller; never auto-discover or alter runner nodes.
signal entered_on_foot
signal returned_to_race

var _saved_modes: Dictionary = {}
var _on_foot := false

func is_on_foot() -> bool:
    return _on_foot

func enter_on_foot(race_nodes: Array[Node], allowed: bool) -> bool:
    if not allowed or _on_foot or race_nodes.is_empty():
        return false
    var unique: Dictionary = {}
    for node in race_nodes:
        if not is_instance_valid(node) or node == self or node.is_ancestor_of(self):
            return false
        if unique.has(node):
            return false
        unique[node] = true
    for node in race_nodes:
        _saved_modes[node] = node.process_mode
        node.process_mode = Node.PROCESS_MODE_DISABLED
    _on_foot = true
    entered_on_foot.emit()
    return true

func return_to_race() -> bool:
    if not _on_foot:
        return false
    _restore()
    returned_to_race.emit()
    return true

func abort_transition() -> void:
    _restore()

func _restore() -> void:
    for node in _saved_modes.keys():
        if is_instance_valid(node):
            node.process_mode = _saved_modes[node]
    _saved_modes.clear()
    _on_foot = false

func _exit_tree() -> void:
    _restore()
