extends SceneTree
# Structural regression only. Runtime transition still requires Godot gameplay QA.
func _initialize() -> void:
    var source := FileAccess.get_file_as_string("res://world.gd")
    var start := source.find("func _enter_neon_adventure()")
    var end := source.find("func _leave_neon_adventure()", start)
    if start < 0 or end < start:
        push_error("Adventure transition functions missing")
        quit(1)
        return
    var entry := source.substr(start, end - start)
    for required in ['zone.set("running", false)', 'phase = "on_foot"', 'portal.exit_requested.connect(_leave_neon_adventure)']:
        if not entry.contains(required):
            push_error("Race-pause entry regression: " + required)
            quit(1)
            return
    if entry.find('zone.set("running", false)') > entry.find('phase = "on_foot"'):
        push_error("Race scenery must stop before on-foot transition")
        quit(1)
        return
    print("ADVENTURE RACE PAUSE STRUCTURAL TEST PASSED")
    quit(0)
