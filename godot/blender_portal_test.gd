extends SceneTree
func _initialize() -> void:
    # SceneTree._initialize happens before root enters the rendering tree.
    call_deferred("_run")

func _run() -> void:
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
    # Sampling only at 1.0s can land exactly on a looping clip boundary.
    # Evaluate several interior keyframe times to verify actual displacement.
    var clip := animator.get_animation(clip_name)
    if clip == null or clip.length <= 0.0:
        push_error("BLENDER PORTAL TEST FAILED: invalid imported animation duration")
        quit(1)
        return
    animator.play(clip_name)
    var max_displacement := 0.0
    for fraction in [0.20, 0.40, 0.60, 0.80]:
        animator.seek(clip.length * fraction, true)
        max_displacement = maxf(max_displacement, shard.global_position.distance_to(before))
    if max_displacement < 0.15:
        push_error("BLENDER PORTAL TEST FAILED: keyframed orbit did not visibly move")
        quit(1)
        return
    print("LEARNQUEST BLENDER PORTAL TEST PASSED")
    portal.queue_free()
    quit(0)
