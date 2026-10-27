extends SceneTree
## V124: regression for headwear generated from actual weighted Head vertices.
## Ensures it remains an accessory to the original imported 65-bone skin,
## follows real Head pose and does not create collisions or rigid face copies.

func _initialize() -> void:
    call_deferred("_check")

func _fail(reason: String) -> void:
    push_error("EXTERNAL HEADGEAR TEST FAILED: " + reason)
    quit(1)

func _check() -> void:
    if not ResourceLoader.exists("res://models/quaternius_hero.glb"):
        _fail("pinned CC0 source GLB not imported")
        return
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    rider.set("prefer_cc0_rigged_hero", true)
    root.add_child(rider)
    await process_frame
    var adapter := rider.get_node_or_null("ExternalHeroPose") as Node
    if adapter == null:
        _fail("external 65-bone character adapter missing")
        return
    var rig := adapter.get("skeleton") as Skeleton3D
    if rig == null or rig.get_bone_count() < 50:
        _fail("original skinned humanoid rig missing")
        return
    var headwear := rig.get_node_or_null("ExternalHeroHeadgear") as BoneAttachment3D
    if headwear == null or headwear.bone_name != "Head":
        _fail("headwear must be attached to original Head bone")
        return
    var meshes: Array = headwear.get("generated_meshes")
    if meshes.size() < 10:
        _fail("expected curved cap, face shield, visor edges and multiple hair locks")
        return
    for expected in ["CurvedFlightHelmetShell", "TranslucentFaceShield",
            "EyeWhite*", "Iris*", "Pupil*", "CurvedSmile"]:
        if headwear.find_child(expected, false, false) == null:
            _fail("missing expressive helmet/face feature: " + expected)
            return
    var vertices := 0
    for item in meshes:
        var part := item as MeshInstance3D
        if part == null or part.mesh == null or part.mesh.get_surface_count() == 0:
            _fail("headwear contains an invalid 3D surface")
            return
        vertices += part.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX].size()
    if vertices < 1800:
        _fail("headwear must be curved modeled geometry, not primitive boxes")
        return
    var bounds := headwear.get("head_bounds") as AABB
    if bounds.size.x < 0.08 or bounds.size.y < 0.08:
        _fail("head dimensions must come from actual imported weighted head vertices")
        return
    if headwear.find_children("*", "CollisionObject3D", true, false).size() > 0:
        _fail("cosmetic headwear must never alter gameplay collisions")
        return
    var head_id := rig.find_bone("Head")
    var initial := rig.get_bone_pose_rotation(head_id)
    rider.set("lean", 0.85)
    rider.set("boosting", true)
    adapter.call("_process", 0.40)
    await process_frame
    var moved := rig.get_bone_pose_rotation(head_id)
    if moved.angle_to(initial) < 0.08:
        _fail("headwear's imported Head bone did not animate")
        return
    var original_meshes: Array = adapter.get("skinned_meshes")
    var original_vertices := 0
    for item in original_meshes:
        var original := item as MeshInstance3D
        if original == null or original.skin == null or original.skin.get_bind_count() < 50:
            _fail("headwear must not remove or replace real GPU skin")
            return
        for surface in range(original.mesh.get_surface_count()):
            original_vertices += original.mesh.surface_get_arrays(surface)[Mesh.ARRAY_VERTEX].size()
    if original_vertices < 8000:
        _fail("original skinned body mesh unexpectedly changed")
        return
    print("EXTERNAL HEADGEAR TEST PASSED: %d curved accessory vertices, %d original skinned body vertices, real Head bone pose" % [vertices, original_vertices])
    quit(0)
