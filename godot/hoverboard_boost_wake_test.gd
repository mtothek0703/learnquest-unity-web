extends SceneTree
## Boost-wake geometry and phone-refresh-rate regression. Visual only.
func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("VOLUMETRIC BOOST WAKE TEST FAILED: " + message)
    quit(1)

func _check() -> void:
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    root.add_child(rider)
    await process_frame
    var legacy := rider.get_node_or_null("LegacyRider") as Node3D
    var board := rider.get_node_or_null("LegacyRider/Floating hoverboard") as Node3D
    var wake := rider.get_node_or_null("LegacyRider/Floating hoverboard/SculptedHoverboardChassis/BoostWake") as Node3D
    if legacy == null or board == null or wake == null:
        _fail("boost wake must follow the original animated hoverboard")
        return
    # The V83 cinematic wake caused the huge striped sheets seen even when
    # the new helix was disabled. Keep its nodes for fallback but retire their
    # renderers only when the sculpted board/helix initialized successfully.
    var legacy_ion := board.get_node_or_null("Cinematic ion wake") as Node3D
    if legacy_ion == null or not bool(legacy_ion.get("streamlined_mode")):
        _fail("sculpted board must disable duplicate legacy ion ribbons")
        return
    var legacy_roots: Array = legacy_ion.get("wake_roots")
    var legacy_sparks: Array = legacy_ion.get("sparks")
    if legacy_roots.size() != 2 or legacy_sparks.size() != 12:
        _fail("old ion wake fallback geometry and sparks must be preserved")
        return
    for old_root in legacy_roots:
        for old_name in ["Translucent curved plasma", "Bright sculpted ion core"]:
            var old_mesh := (old_root as Node3D).get_node_or_null(old_name) as MeshInstance3D
            if old_mesh == null or old_mesh.visible:
                _fail("old broad ion sheet must be retained but not rendered")
                return
    for old_spark in legacy_sparks:
        if (old_spark as MeshInstance3D).visible:
            _fail("old floating sparks must not obscure the new helix silhouette")
            return
    if legacy_ion.get_node_or_null("Pulsing cinematic engine light") == null:
        _fail("old ambient propulsion lighting must be preserved")
        return
    var old_flames: Array = legacy.get("flames")
    var old_boxes: Array = legacy.get("energy_trails")
    if old_flames.size() != 2 or old_boxes.size() != 2:
        _fail("old flame and boost-box fallback meshes must be preserved")
        return
    for duplicate in old_flames + old_boxes:
        if (duplicate as MeshInstance3D).visible:
            _fail("primitive flame or straight contrail obscures the sculpted jets")
            return
    var parts: Array = wake.get("wake_meshes")
    var materials: Array = wake.get("wake_materials")
    if parts.size() != 2 or materials.size() != 2:
        _fail("exactly two swept wake surfaces and materials required")
        return
    for part in parts:
        var mesh := part as MeshInstance3D
        if mesh == null or mesh.mesh == null or mesh.mesh.get_surface_count() != 1:
            _fail("missing single-pass continuous wake surface")
            return
        var arrays: Array = mesh.mesh.surface_get_arrays(0)
        var points: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
        var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
        var colors: PackedColorArray = arrays[Mesh.ARRAY_COLOR]
        if points.size() < 2600 or normals.size() != points.size() or colors.size() != points.size():
            _fail("wake must have real curved 3D geometry, normals and fading vertex colors")
            return
        if mesh.visible:
            _fail("wake must be hidden at idle to avoid mobile overdraw")
            return
    for t in [0.0, 0.25, 0.5, 0.85, 1.0]:
        for angle in [0.0, PI * 0.5, PI]:
            var left: Vector3 = wake.call("_point", -1.0, t, angle)
            var right: Vector3 = wake.call("_point", 1.0, t, angle)
            if absf(left.x + right.x) > 0.001 or absf(left.y - right.y) > 0.001 or absf(left.z - right.z) > 0.001:
                _fail("both 3D wakes must remain mirrored around the original board")
                return
    var middle: Vector3 = wake.call("_point", 1.0, 0.5, 0.0)
    var root_point: Vector3 = wake.call("_point", 1.0, 0.0, 0.0)
    var tip: Vector3 = wake.call("_point", 1.0, 1.0, 0.0)
    if tip.z - root_point.z < 0.90 or tip.z - root_point.z > 1.05 or middle.x - root_point.x < 0.040 or tip.x >= middle.x:
        _fail("wake must keep a visible but slender tapered 3D ion trail")
        return
    # A real volumetric tube must have narrow bright spirals, not a flat
    # translucent sheet across every azimuth. Check both angle and distance.
    var bright: float = float(wake.call("_opacity", 0.5, 0.0))
    var dark: float = float(wake.call("_opacity", 0.5, PI / 3.0))
    var tip_alpha: float = float(wake.call("_opacity", 0.95, 0.0))
    if bright < dark * 4.0 or bright <= 0.10 or tip_alpha >= bright * 0.15:
        _fail("boost wakes need tapered, high-contrast helical 3D filaments")
        return
    # Real mesh, not alpha-striped broad exhaust sheets: each engine now
    # contains three separate narrow helical 3D tubes in a single draw call.
    if int(wake.get_script().get_script_constant_map().get("STRAND_COUNT", 0)) != 3:
        _fail("triple-helical jet must use three volumetric strands")
        return
    for side_index in range(2):
        var side := -1.0 if side_index == 0 else 1.0
        var actual: PackedVector3Array = (parts[side_index] as MeshInstance3D).mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
        for strand in range(3):
            var center: Vector3 = wake.call("_filament_center", side, 0.5, strand)
            var mirror: Vector3 = wake.call("_filament_center", -side, 0.5, strand)
            if absf(center.x + mirror.x) > 0.0001 or absf(center.y - mirror.y) > 0.0001:
                _fail("new 3D helix must remain mirrored between engines")
                return
            var sample: Vector3 = wake.call("_filament_point", side, 0.5, 0.0, strand)
            var found := false
            for vertex in actual:
                if vertex.distance_to(sample) < 0.0001:
                    found = true
                    break
            if not found:
                _fail("each helix must exist in the actual uploaded render mesh")
                return
        var strand_a: Vector3 = wake.call("_filament_center", side, 0.5, 0)
        var strand_b: Vector3 = wake.call("_filament_center", side, 0.5, 1)
        if strand_a.distance_to(strand_b) < 0.06:
            _fail("three helices must be spatially distinct, not coincident")
            return
        var mid_radius: float = wake.call("_filament_radius", 0.5)
        var tip_radius: float = wake.call("_filament_radius", 1.0)
        if mid_radius > 0.025 or tip_radius >= mid_radius * 0.5:
            _fail("filament tubes must stay narrow and taper at their tips")
            return
    if wake.find_children("*", "CollisionObject3D", true, false).size() > 0:
        _fail("boost wake may not create gameplay collision objects")
        return
    legacy.set("boosting", true)
    legacy.set("lean", 0.7)
    wake.call("_process", 0.25)
    if not (parts[0] as MeshInstance3D).visible or not (parts[1] as MeshInstance3D).visible:
        _fail("both wake surfaces must appear during boost")
        return
    if float(materials[1].emission_energy_multiplier) <= float(materials[0].emission_energy_multiplier):
        _fail("carving must brighten the outside wake")
        return
    # Both original exhaust openings stay attached even when the outside
    # plume becomes physically longer and wider during a right-hand carve.
    var port := parts[0] as MeshInstance3D
    var starboard := parts[1] as MeshInstance3D
    if starboard.scale.z <= port.scale.z + 0.15 or \
            starboard.scale.x <= port.scale.x + 0.10:
        _fail("outside boost wake needs visibly longer, wider 3D geometry")
        return
    for part in parts:
        var plume := part as MeshInstance3D
        if absf(plume.position.z + 1.58 * plume.scale.z - 1.58) > 0.0001:
            _fail("wake scaling detached its root from the turbine exhaust")
            return
    var at_30 := 0.0
    var length_30 := 0.0
    for fps in [30, 60]:
        wake.set("intensity", 0.0)
        for frame in range(3 if fps == 30 else 6):
            wake.call("_process", 1.0 / float(fps))
        var level := float(wake.get("intensity"))
        if fps == 30:
            at_30 = level
            length_30 = starboard.scale.z
        elif absf(level - at_30) > 0.001 or \
                absf(starboard.scale.z - length_30) > 0.001:
            _fail("wake fade and 3D trail length must match at 30 and 60 FPS")
            return
    # A reversed turn must switch which actual plume extends farther.
    legacy.set("lean", -0.7)
    wake.call("_process", 0.25)
    if port.scale.z <= starboard.scale.z + 0.15:
        _fail("left-hand carve must extend the port wake instead")
        return
    legacy.set("boosting", false)
    for frame in range(30):
        wake.call("_process", 0.0333)
    if (parts[0] as MeshInstance3D).visible or (parts[1] as MeshInstance3D).visible:
        _fail("wake must fade out after boost instead of persisting during vocabulary rounds")
        return
    if rider.get_node_or_null("LegacyRider/Floating hoverboard") != board:
        _fail("original animated hoverboard hierarchy changed")
        return
    print("VOLUMETRIC BOOST WAKE TEST PASSED: mirrored 3D trails, action glow, mobile fade, original board/touch/collisions")
    quit(0)
