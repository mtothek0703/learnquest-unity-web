extends SceneTree
## Regression for a genuine first-frame mobile visual bug: the ion wake must
## never render twelve unscaled radius-one sparks over the hoverboard.
func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("ION WAKE FIRST FRAME TEST FAILED: " + message)
    quit(1)

func _check() -> void:
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    root.add_child(rider)
    # Deliberately do NOT await a frame: verify _ready state before _process.
    var board := rider.get_node_or_null("LegacyRider/Floating hoverboard") as Node3D
    var wake: Node3D = null
    if board != null:
        wake = board.get_node_or_null("Cinematic ion wake") as Node3D
    if board == null or wake == null:
        _fail("original animated board or its cinematic wake is missing")
        return
    var sparks: Array = wake.get("sparks")
    if sparks.size() != 12:
        _fail("both original six-spark ion trails must remain intact")
        return
    for index in range(sparks.size()):
        var spark := sparks[index] as MeshInstance3D
        if spark == null or not (spark.mesh is SphereMesh):
            _fail("real ion spark mesh missing")
            return
        var phase := float(index % 6) / 6.0
        var side := -1.0 if index < 6 else 1.0
        var expected_scale := 0.055 * (1.0 - phase * 0.65)
        var expected_position: Vector3 = wake.call("_plasma_point", side, phase, 0.0, 0.1)
        expected_position += Vector3(0.0, 0.07, 0.0)
        if spark.get_parent() == null or spark.scale.distance_to(Vector3.ONE * expected_scale) > 0.0001:
            _fail("uninitialized first-frame spark size could obscure the board")
            return
        if spark.position.distance_to(expected_position) > 0.0001:
            _fail("first-frame spark must begin on the actual plasma ribbon")
            return
        if spark.scale.x >= 0.11:
            _fail("spark radius must remain mobile-safe")
            return
    var legacy := rider.get_node_or_null("LegacyRider") as Node3D
    if legacy == null:
        _fail("original rider controls were lost")
        return
    legacy.set("boosting", true)
    wake.call("_process", 1.0 / 60.0)
    for spark in sparks:
        if (spark as MeshInstance3D).scale.x > 0.101:
            _fail("turbo must preserve bounded spark size")
            return
    if wake.find_children("*", "CollisionObject3D", true, false).size() > 0:
        _fail("visual-only fix must not add collision objects")
        return
    print("ION WAKE FIRST FRAME TEST PASSED: 12 safely initialized sparks and preserved turbo animation")
    quit(0)
