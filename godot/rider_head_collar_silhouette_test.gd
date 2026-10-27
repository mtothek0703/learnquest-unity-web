extends SceneTree
## V109: pixel-informed organic head/collar silhouette regression.
## Geometric assertions complement (but never replace) rendered QA and iPhone FPS.
func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("HEAD/COLLAR SILHOUETTE TEST FAILED: " + message)
    quit(1)

func _check() -> void:
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    root.add_child(rider)
    await process_frame
    var model := rider.get_node_or_null("ImportedRider") as Node3D
    if model == null:
        _fail("imported rider is missing")
        return
    var head := model.get_node_or_null("SculptedSkinnedFace") as Node3D
    var jacket := model.get_node_or_null("UnifiedSkinnedUpperJacket") as Node3D
    var rig := model.get_node_or_null("OriginalBodySkinRig") as Node3D
    if head == null or jacket == null or rig == null:
        _fail("original rig, continuous head and jacket are required")
        return
    var skeleton := rig.get_node_or_null("OriginalBodySkeleton13") as Skeleton3D
    var face := head.get_node_or_null("ContinuousSkinnedFace") as MeshInstance3D
    var garment := jacket.get_node_or_null("UnifiedSkinnedJacket") as MeshInstance3D
    var collar := jacket.get_node_or_null("SkinnedCollarEdge") as MeshInstance3D
    if skeleton == null or skeleton.get_bone_count() != 13 or face == null or garment == null or collar == null:
        _fail("head and collar must share the original 13-bone rig")
        return
    for part in [face, garment, collar]:
        if part.mesh == null or part.skin == null or part.skin.get_bind_count() != 13:
            _fail("replacement is not a genuine skinned 3D mesh")
            return
        if part.get_node_or_null(part.skeleton) != skeleton:
            _fail("mesh uses a different skeleton")
            return
        var arrays: Array = part.mesh.surface_get_arrays(0)
        var points: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
        var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
        if points.size() < 100 or weights.size() != points.size() * 4:
            _fail("missing skinned vertex geometry")
            return
    # In the V108 PNGs the crown narrowed to a sharp point. A fuller
    # upper skull should keep >=83% of temple width at 82% head height.
    var crown: Vector3 = head.call("_point", 0.82, 0.25)
    var temple: Vector3 = head.call("_point", 0.50, 0.25)
    var jaw: Vector3 = head.call("_point", 0.22, 0.25)
    if crown.x < 0.39 or crown.x / temple.x < 0.83 or jaw.x < 0.35:
        _fail("cranial silhouette still tapers into an egg shape")
        return
    # Front points toward -Z. Its neckline must sit below the lower face,
    # while side/back protection remains high and continuous.
    var front: Vector3 = jacket.call("_point", 1.0, 0.50, 0)
    var side: Vector3 = jacket.call("_point", 1.0, 0.25, 0)
    var back: Vector3 = jacket.call("_point", 1.0, 0.0, 0)
    if front.y > 2.02 or back.y - front.y < 0.38 or side.y < 2.30:
        _fail("front V-neck obscures the face or side/back collar collapsed")
        return
    if front.z >= -0.35 or absf(side.y - back.y) > 0.06:
        _fail("neckline has invalid orientation or asymmetric back contour")
        return
    if int(rig.get("retired_head_surfaces")) != 3:
        _fail("old opaque glTF head surfaces cover the new head")
        return
    var eyes := model.get_node_or_null("ExpressiveFace") as Node3D
    if eyes == null or eyes.get_node_or_null("LeftEye") == null or eyes.get_node_or_null("RightEye") == null:
        _fail("expressive eyes must survive")
        return
    # The first V109 render exposed a regression: the new rounded chin
    # covered the old unskinned smile. Keep its curved tube in front of the
    # actual GPU-skinned face, not merely present in the scene tree.
    var smile := eyes.get_node_or_null("CurvedSmile") as MeshInstance3D
    if smile == null or not smile.visible or smile.mesh == null:
        _fail("the animated facial smile disappeared")
        return
    var smile_points: PackedVector3Array = smile.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
    var closest := INF
    for vertex in smile_points:
        closest = minf(closest, vertex.z)
    var face_at_mouth: Vector3 = head.call("_point", (2.19 - 1.98) / 1.10, 0.5)
    if closest > face_at_mouth.z - 0.025:
        _fail("the new chin occludes the curved smile")
        return
    if model.find_children("*", "CollisionObject3D", true, false).size() != 0:
        _fail("visual refinement must not change gameplay collisions")
        return
    print("HEAD/COLLAR SILHOUETTE TEST PASSED: rounded skinned cranium, open front neckline, high back collar, original 13-bone rig")
    quit(0)
