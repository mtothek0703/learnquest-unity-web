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
    # Transforms are only valid after the imported scene enters SceneTree.
    # Otherwise get_global_position() returns IDENTITY and falsely fails QA.
    root.add_child(portal)
    # Confirm that Blender exported real moving GLB keyframes, not just a
    # static mesh or a Godot-only shader. One shard must orbit in 3D.
    var animation_players := portal.find_children("*", "AnimationPlayer", true, false)
    if animation_players.is_empty():
        push_error("BLENDER PORTAL TEST FAILED: imported GLB has no AnimationPlayer")
        quit(1)
        return
    var animator := animation_players[0] as AnimationPlayer
    var clip_name := ""
    for name in animator.get_animation_list():
        if name != "RESET":
            clip_name = name
            break
    if clip_name.is_empty():
        push_error("BLENDER PORTAL TEST FAILED: no Blender animation clip imported")
        quit(1)
        return
    var shard := portal.find_child("*shard*01*", true, false) as Node3D
    if shard == null:
        push_error("BLENDER PORTAL TEST FAILED: animated orbit geometry missing")
        quit(1)
        return
    var before := shard.global_position
    animator.play(clip_name)
    animator.advance(1.0)
    if shard.global_position.distance_to(before) < 0.15:
        push_error("BLENDER PORTAL TEST FAILED: keyframed orbit did not visibly move")
        quit(1)
        return
    print("LEARNQUEST BLENDER PORTAL TEST PASSED")
    portal.queue_free()
    quit(0)
