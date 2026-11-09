extends SceneTree
func _initialize() -> void:
    var asset = ResourceLoader.load("res://assets/3d/learnquest_portal.glb")
    if asset == null or not (asset is PackedScene):
        push_error("BLENDER PORTAL TEST FAILED: Godot could not import GLB")
        quit(1)
        return
    var portal = (asset as PackedScene).instantiate()
    if portal == null or portal.get_child_count() == 0:
        push_error("BLENDER PORTAL TEST FAILED: imported model empty")
        quit(1)
        return
    print("LEARNQUEST BLENDER PORTAL TEST PASSED")
    portal.free()
    quit(0)
