extends SceneTree
## Actual Godot import and bone-pose regression for original Blender hero.
## Run after Blender Cloud built godot/assets/3d/learnquest_walk_hero.glb.
func _initialize() -> void:
    call_deferred("_verify")

func _fail(reason: String) -> void:
    push_error("RIGGED HERO IMPORT FAILED: " + reason)
    quit(1)

func _verify() -> void:
    var scene := load("res://assets/3d/learnquest_walk_hero.glb") as PackedScene
    if scene == null:
        _fail("Blender-exported GLB is not an imported PackedScene")
        return
    var hero := scene.instantiate() as Node3D
    if hero == null:
        _fail("imported GLB has no Node3D root")
        return
    root.add_child(hero)
    var bones := hero.find_children("*", "Skeleton3D", true, false)
    if bones.is_empty():
        _fail("no Skeleton3D imported")
        return
    var rig := bones[0] as Skeleton3D
    if rig.get_bone_count() < 14:
        _fail("fewer than 14 real deform bones")
        return
    var skinned := 0
    for item in hero.find_children("*", "MeshInstance3D", true, false):
        if item is MeshInstance3D and (item as MeshInstance3D).skin != null:
            skinned += 1
    if skinned < 12:
        _fail("armature has no real GPU skinned mesh surfaces")
        return
    var players := hero.find_children("*", "AnimationPlayer", true, false)
    if players.is_empty():
        _fail("no Blender-authored animation player")
        return
    var animator := players[0] as AnimationPlayer
    var clip := ""
    for key in animator.get_animation_list():
        if key != "RESET":
            clip = key
            break
    if clip.is_empty() or animator.get_animation(clip).length < 8.0:
        _fail("expected imported multi-state walk/jump/sprint timeline missing")
        return
    var arm := rig.find_bone("UpperArm.L")
    if arm < 0:
        _fail("missing left arm in exported skeleton")
        return
    animator.play(clip)
    animator.seek(2.60, true)
    var pose_a := rig.get_bone_pose_rotation(arm)
    animator.seek(3.10, true)
    var pose_b := rig.get_bone_pose_rotation(arm)
    if pose_a.angle_to(pose_b) < 0.08:
        _fail("walking bone has no real animated rotation")
        return
    print("LEARNQUEST RIGGED HERO IMPORT TEST PASSED: %d bones, %d skinned shells, animated walk arm" % [rig.get_bone_count(), skinned])
    quit(0)
