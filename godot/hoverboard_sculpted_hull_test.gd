extends SceneTree
## V116: real 360-degree board geometry, preserved action motion and touch.
func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("SCULPTED HOVERBOARD TEST FAILED: " + message)
    quit(1)

# Compare all coincident vertices in the real unindexed render mesh.
# At least three copies must agree to rule out per-triangle flat shading.
func _smooth_at(mesh: Mesh, point: Vector3, expected: Vector3) -> bool:
    var arrays: Array = mesh.surface_get_arrays(0)
    var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
    var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
    if normals.size() != vertices.size():
        return false
    var count := 0
    var first := Vector3.ZERO
    for i in range(vertices.size()):
        if vertices[i].distance_to(point) > 0.0001:
            continue
        var normal: Vector3 = normals[i]
        if normal.length_squared() < 0.95 or normal.dot(expected) < 0.75:
            return false
        if count > 0 and normal.dot(first) < 0.995:
            return false
        first = normal
        count += 1
    return count >= 3

func _check() -> void:
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    root.add_child(rider)
    await process_frame
    var legacy := rider.get_node_or_null("LegacyRider") as Node3D
    var board := rider.get_node_or_null("LegacyRider/Floating hoverboard") as Node3D
    if legacy == null or board == null:
        _fail("original animated hoverboard is missing")
        return
    # Ion sparks must be small from the first render, not only after the
    # first _process tick; otherwise they hide the chase-view board in QA.
    var ion_wake := board.get_node_or_null("Cinematic ion wake") as Node3D
    if ion_wake == null:
        _fail("original cinematic ion wake is missing")
        return
    var initial_sparks := ion_wake.find_children("Moving ion spark *", "MeshInstance3D", true, false)
    if initial_sparks.size() != 12:
        _fail("expected twelve original ion sparks")
        return
    for spark in initial_sparks:
        if (spark as MeshInstance3D).scale.x > 0.11:
            _fail("oversized first-frame ion spark obscures the board")
            return
    var sculpt := board.get_node_or_null("SculptedHoverboardChassis") as Node3D
    if sculpt == null or not bool(sculpt.get("built")):
        _fail("new sculpted board did not initialize")
        return
    for name in ["ContinuousAerodynamicChassis", "ContouredTractionDeck",
        "UndersideKeel", "PortEdgeLight", "StarboardEdgeLight",
        "PortSculptedAeroWing", "StarboardSculptedAeroWing"]:
        var part := sculpt.get_node_or_null(name) as MeshInstance3D
        if part == null or part.mesh == null or not part.visible:
            _fail("missing visible board part: " + name)
            return
        var arrays: Array = part.mesh.surface_get_arrays(0)
        var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
        var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
        if vertices.size() < 120 or normals.size() != vertices.size():
            _fail("board geometry is too coarse or unshaded: " + name)
            return
    var chassis := sculpt.get_node("ContinuousAerodynamicChassis") as MeshInstance3D
    var points: PackedVector3Array = chassis.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
    var colors: PackedColorArray = chassis.mesh.surface_get_arrays(0)[Mesh.ARRAY_COLOR]
    if points.size() < 3000 or colors.size() != points.size():
        _fail("chassis needs substantial shaded custom geometry")
        return
    # The smooth-shaded chassis must remain legible in the dark chase camera.
    # Highly metallic dark material lost the old faceted specular highlights.
    var chassis_material := chassis.material_override as StandardMaterial3D
    if chassis_material == null or chassis_material.metallic > 0.50 or \
            chassis_material.roughness < 0.40:
        _fail("smooth chassis needs readable satin material, not dark mirror metal")
        return
    var upper_point: Vector3 = sculpt.call("_shell_point", 0.5, PI * 0.5)
    var upper_luminance := -1.0
    for i in range(points.size()):
        if points[i].distance_to(upper_point) < 0.0001:
            upper_luminance = maxf(upper_luminance, colors[i].get_luminance())
    if upper_luminance < 0.10:
        _fail("smooth chassis top lost its readable vertex color")
        return
    var nose: float = sculpt.call("_half_width", 0.0)
    var middle: float = sculpt.call("_half_width", 0.52)
    var tail: float = sculpt.call("_half_width", 1.0)
    if nose >= middle * 0.75 or tail >= middle or middle < 0.70:
        _fail("aerodynamic silhouette does not taper nose and tail")
        return
    var top: Vector3 = sculpt.call("_shell_point", 0.5, PI * 0.5)
    var bottom: Vector3 = sculpt.call("_shell_point", 0.5, PI * 1.5)
    if top.y - bottom.y < 0.20 or top.z != bottom.z:
        _fail("board chassis is not a genuine rounded 360-degree volume")
        return
    # The actual rendered deck has two symmetric raised footbeds and a
    # continuous recessed center channel, not decorative unlit box meshes.
    var traction := sculpt.get_node("ContouredTractionDeck") as MeshInstance3D
    var left_pad: Vector3 = sculpt.call("_grip_point", 0.5, -0.5)
    var right_pad: Vector3 = sculpt.call("_grip_point", 0.5, 0.5)
    var center_channel: Vector3 = sculpt.call("_grip_point", 0.5, 0.0)
    var front_transition: Vector3 = sculpt.call("_grip_point", 0.08, 0.5)
    if absf(left_pad.y - right_pad.y) > 0.0001 or \
            left_pad.y < center_channel.y + 0.035 or \
            center_channel.y > 0.425 or \
            right_pad.y < front_transition.y + 0.018:
        _fail("3D traction pads/channel must be sculpted, symmetric and tapered")
        return
    var deck_arrays: Array = traction.mesh.surface_get_arrays(0)
    var deck_points: PackedVector3Array = deck_arrays[Mesh.ARRAY_VERTEX]
    var deck_colors: PackedColorArray = deck_arrays[Mesh.ARRAY_COLOR]
    var pad_luminance := -1.0
    var channel_luminance := -1.0
    if deck_colors.size() != deck_points.size():
        _fail("sculpted traction deck needs real per-vertex material contrast")
        return
    for i in range(deck_points.size()):
        if deck_points[i].distance_to(right_pad) < 0.0001:
            pad_luminance = maxf(pad_luminance, deck_colors[i].get_luminance())
        if deck_points[i].distance_to(center_channel) < 0.0001:
            channel_luminance = maxf(channel_luminance, deck_colors[i].get_luminance())
    if pad_luminance < 0.0 or channel_luminance < 0.0 or pad_luminance < channel_luminance + 0.15:
        _fail("rendered deck must contrast raised footbed against recessed channel")
        return
    var old_boxes := 0
    for child in board.get_children():
        if child is MeshInstance3D and child.mesh is BoxMesh:
            var box_mesh := child.mesh as BoxMesh
            # Legacy piece() uses unit BoxMesh geometry and node.scale for dimensions.
            var size: Vector3 = box_mesh.size * (child as MeshInstance3D).scale
            if size.z > 1.85 and size.x > 0.8:
                old_boxes += 1
                if child.visible:
                    _fail("old rectangular chassis/deck overlaps sculpted replacement")
                    return
    if old_boxes != 2:
        _fail("expected both original central deck boxes to be retired")
        return
    for side in [-1.0, 1.0]:
        var inner: Vector3 = sculpt.call("_wing_point", side, 0.52, PI)
        var outer: Vector3 = sculpt.call("_wing_point", side, 0.52, 0.0)
        if absf(outer.x - inner.x) < 0.42 or absf(outer.x) < 1.17 or absf(outer.x) > 1.23:
            _fail("compact stabilizer must be substantial but not an oversized side wing")
            return
        var wing := sculpt.get_node_or_null(
            "PortSculptedAeroWing" if side < 0.0 else "StarboardSculptedAeroWing") as MeshInstance3D
        var wing_arrays: Array = wing.mesh.surface_get_arrays(0)
        var wing_vertices: PackedVector3Array = wing_arrays[Mesh.ARRAY_VERTEX]
        var wing_colors: PackedColorArray = wing_arrays[Mesh.ARRAY_COLOR]
        if wing_vertices.size() < 1800 or wing_colors.size() != wing_vertices.size():
            _fail("side stabilizers need closed end caps and shaded color data")
            return
        var satin := wing.material_override as StandardMaterial3D
        if satin == null or satin.roughness < 0.55 or satin.metallic > 0.40:
            _fail("side stabilizers must use satin composite, not glossy purple")
            return
        for t in [0.15, 0.5, 0.85]:
            var mirrored: Vector3 = sculpt.call("_wing_point", -side, t, 0.0)
            var sample: Vector3 = sculpt.call("_wing_point", side, t, 0.0)
            if absf(mirrored.x + sample.x) > 0.001 or absf(mirrored.y - sample.y) > 0.001:
                _fail("integrated stabilizers lost their mirrored 3D sweep")
                return
    # V124: two closed, curved, symmetric propulsion housings and emissive
    # exhaust toruses, attached to the existing hoverboard (not touch/collision).
    var port_engine := sculpt.get_node_or_null("PortSculptedTurbine") as MeshInstance3D
    var starboard_engine := sculpt.get_node_or_null("StarboardSculptedTurbine") as MeshInstance3D
    var port_halo := sculpt.get_node_or_null("PortExhaustHalo") as MeshInstance3D
    var starboard_halo := sculpt.get_node_or_null("StarboardExhaustHalo") as MeshInstance3D
    for part in [port_engine, starboard_engine, port_halo, starboard_halo]:
        if part == null or part.mesh == null or not part.visible:
            _fail("missing sculpted propulsion volume or exhaust")
            return
        var geometry: Array = part.mesh.surface_get_arrays(0)
        var points3d: PackedVector3Array = geometry[Mesh.ARRAY_VERTEX]
        var normals3d: PackedVector3Array = geometry[Mesh.ARRAY_NORMAL]
        if points3d.size() < 1000 or normals3d.size() != points3d.size():
            _fail("propulsion geometry must be a smooth shaded 3D surface")
            return
    # The actual unindexed mesh vertices must now share smooth analytic
    # normals across triangle boundaries. Flat generated normals previously
    # made the chassis, traction deck, wings and turbines look faceted.
    var deck := sculpt.get_node("ContouredTractionDeck") as MeshInstance3D
    var port_wing := sculpt.get_node("PortSculptedAeroWing") as MeshInstance3D
    var starboard_wing := sculpt.get_node("StarboardSculptedAeroWing") as MeshInstance3D
    var normal_cases: Array[Dictionary] = [
        {"mesh": chassis.mesh, "point": sculpt.call("_shell_point", 0.5, PI * 0.5)},
        {"mesh": deck.mesh, "point": sculpt.call("_grip_point", 0.5, 0.0)},
        {"mesh": port_wing.mesh, "point": sculpt.call("_wing_point", -1.0, 0.5, PI * 0.5)},
        {"mesh": starboard_wing.mesh, "point": sculpt.call("_wing_point", 1.0, 0.5, PI * 0.5)},
        {"mesh": port_engine.mesh, "point": sculpt.call("_thruster_point", -1.0, 0.5, PI * 0.5)},
        {"mesh": starboard_engine.mesh, "point": sculpt.call("_thruster_point", 1.0, 0.5, PI * 0.5)}
    ]
    for sample_case in normal_cases:
        if not _smooth_at(sample_case["mesh"], sample_case["point"], Vector3.UP):
            _fail("swept board geometry has faceted, discontinuous or inward-facing surface normals")
            return
    # End caps need their own hard outward normals, unlike the curved sides.
    var front_cap: Vector3 = sculpt.call("_shell_point", 0.0, 0.0)
    if not _smooth_at(chassis.mesh, Vector3(0.0, front_cap.y, -1.37),
            Vector3.FORWARD):
        _fail("front chassis end cap is not closed with an outward normal")
        return
    for t in [0.0, 0.45, 0.80, 1.0]:
        var port: Vector3 = sculpt.call("_thruster_point", -1.0, t, 0.0)
        var starboard: Vector3 = sculpt.call("_thruster_point", 1.0, t, PI)
        if absf(port.x + starboard.x) > 0.001 or absf(port.y - starboard.y) > 0.001:
            _fail("twin turbines are not mirrored around the board centerline")
            return
    var engine_mid_top: Vector3 = sculpt.call("_thruster_point", 1.0, 0.5, PI * 0.5)
    var engine_mid_bottom: Vector3 = sculpt.call("_thruster_point", 1.0, 0.5, PI * 1.5)
    var engine_tip_top: Vector3 = sculpt.call("_thruster_point", 1.0, 0.0, PI * 0.5)
    var engine_front: Vector3 = sculpt.call("_thruster_point", 1.0, 0.0, 0.0)
    var engine_back: Vector3 = sculpt.call("_thruster_point", 1.0, 1.0, 0.0)
    if engine_mid_top.y - engine_mid_bottom.y < 0.40 or engine_mid_top.y - engine_tip_top.y < 0.08 or engine_back.z - engine_front.z < 1.0:
        _fail("propulsion housing lacks a swept, three-dimensional tapered body")
        return
    # Four genuinely recessed longitudinal channels must exist in the
    # turbine's ACTUAL render mesh, not just a shader or extra decoration.
    # The flutes fade away at both ends to preserve closed round end caps.
    for side in [-1.0, 1.0]:
        var center_x: float = side * (0.80 + 0.08 * 0.5)
        var groove: Vector3 = sculpt.call("_thruster_point", side, 0.5, PI / 4.0)
        var ridge: Vector3 = sculpt.call("_thruster_point", side, 0.5, 0.0)
        var groove_radius := absf(groove.x - center_x) / cos(PI / 4.0)
        var ridge_radius := absf(ridge.x - center_x)
        if ridge_radius - groove_radius < 0.030:
            _fail("turbine housing lacks four genuinely recessed 3D cooling channels")
            return
        var front_groove: Vector3 = sculpt.call("_thruster_point", side, 0.05, PI / 4.0)
        var front_ridge: Vector3 = sculpt.call("_thruster_point", side, 0.05, 0.0)
        var front_center: float = side * (0.80 + 0.08 * 0.05)
        if absf(absf(front_groove.x - front_center) / cos(PI / 4.0) -
                absf(front_ridge.x - front_center)) > 0.001:
            _fail("recessed turbine channels must fade before the closed front cap")
            return
        var turbine := port_engine if side < 0.0 else starboard_engine
        var actual_vertices: PackedVector3Array = turbine.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
        var found_groove := false
        var found_ridge := false
        for vertex in actual_vertices:
            if vertex.distance_to(groove) < 0.0001:
                found_groove = true
            if vertex.distance_to(ridge) < 0.0001:
                found_ridge = true
            if found_groove and found_ridge:
                break
        if not found_groove or not found_ridge:
            _fail("fluted turbine contour is absent from the actual GPU mesh")
            return
    var halo_outer: Vector3 = sculpt.call("_exhaust_halo_point", 1.0, 0.0, 0.0)
    var halo_inner: Vector3 = sculpt.call("_exhaust_halo_point", 1.0, 0.0, PI)
    if halo_outer.x - halo_inner.x < 0.04 or halo_outer.z < engine_back.z:
        _fail("exhaust halo is not a separate volumetric rear torus")
        return
    var retired_prisms := 0
    for child in board.get_children():
        if child is MeshInstance3D and child.mesh is PrismMesh:
            if absf(child.position.x) > 0.90 and absf(child.position.z - 0.19) < 0.02:
                retired_prisms += 1
                if child.visible:
                    _fail("flat legacy wing prism still occludes the sculpted wing")
                    return
    if retired_prisms != 2:
        _fail("both old wing prisms must remain archived but hidden")
        return
    if sculpt.find_children("*", "CollisionObject3D", true, false).size() > 0:
        _fail("visual board must not change collisions or touch input")
        return
    var original_y := board.position.y
    rider.set("lean", 0.85)
    rider.set("boosting", true)
    # The gameplay adapter copies rider input to LegacyRider during its own
    # process tick; explicitly mirror it in this deterministic manual tick.
    legacy.set("lean", 0.85)
    legacy.set("boosting", true)
    legacy.call("_process", 0.28)
    sculpt.call("_process", 0.28)
    if absf(board.rotation.z) < 0.01 or absf(board.position.y - original_y) < 0.001:
        _fail("existing lean and hover animation must remain active")
        return
    var light := sculpt.get("rail_material") as StandardMaterial3D
    if light == null or light.emission_energy_multiplier <= 1.25:
        _fail("boost must visibly intensify the curved light rails")
        return
    var exhaust_light := sculpt.get("core_material") as StandardMaterial3D
    if exhaust_light == null or not exhaust_light.emission_enabled or exhaust_light.emission_energy_multiplier <= 1.6:
        _fail("boost must brighten both sculpted exhaust halos")
        return
    # Both physical rails already existed. Their independent emission now
    # communicates steer direction without adding draw calls or touch input.
    var side_materials: Array = sculpt.get("rail_materials")
    if side_materials.size() != 2 or side_materials[0] == side_materials[1]:
        _fail("port/starboard rails need distinct materials for carve feedback")
        return
    var port_light := side_materials[0] as StandardMaterial3D
    var starboard_light := side_materials[1] as StandardMaterial3D
    if port_light == null or starboard_light == null or \
            starboard_light.emission_energy_multiplier <= port_light.emission_energy_multiplier + 0.10:
        _fail("right carve must brighten the right-hand existing rail")
        return
    legacy.set("lean", -0.85)
    legacy.set("boosting", false)
    for frame in range(16):
        sculpt.call("_process", 0.016)
    if port_light.emission_energy_multiplier <= starboard_light.emission_energy_multiplier + 0.35:
        _fail("left carve must switch the dominant rail and recover from boost")
        return
    if port_light.emission == starboard_light.emission:
        _fail("opposite rail emissions must use visibly distinct turn colors")
        return
    # The same 0.1-second lighting transition must look identical at
    # 30 and 60 FPS; fixed per-frame interpolation previously drifted.
    legacy.set("lean", 0.75)
    legacy.set("boosting", true)
    var energy_30 := 0.0
    for fps in [30, 60]:
        port_light.emission_energy_multiplier = 1.25
        starboard_light.emission_energy_multiplier = 1.25
        var frames := 3 if fps == 30 else 6
        for frame in range(frames):
            sculpt.call("_process", 1.0 / float(fps))
        if fps == 30:
            energy_30 = starboard_light.emission_energy_multiplier
        elif absf(starboard_light.emission_energy_multiplier - energy_30) > 0.015:
            _fail("hoverboard glow must have frame-rate-independent response on phones")
            return
    if starboard_light.emission_energy_multiplier <= port_light.emission_energy_multiplier + 0.25:
        _fail("frame-rate-independent lighting must preserve steer direction")
        return
    if sculpt.find_children("*", "CollisionObject3D", true, false).size() > 0:
        _fail("turn lighting must not add new collision objects")
        return
    # Experimental articulated board fins: closed curved meshes, distinct
    # starboard/port response and identical elapsed-time response at 30/60 FPS.
    var vanes := sculpt.get_node_or_null("ArticulatedCarveFins") as Node3D
    if vanes == null or not bool(vanes.get("ready_to_animate")):
        _fail("two procedural articulated aerofoil fins are missing")
        return
    var hinges: Array = vanes.get("fins")
    if hinges.size() != 2:
        _fail("both independently hinged fins are required")
        return
    for hinge in hinges:
        var aerofoil := (hinge as Node3D).get_node_or_null("ClosedSweptAerofoil") as MeshInstance3D
        var edge := (hinge as Node3D).get_node_or_null("CurvedSignalEdge") as MeshInstance3D
        if aerofoil == null or edge == null or aerofoil.mesh == null or edge.mesh == null:
            _fail("articulated fins need closed curved volume and emissive edge")
            return
        var arrays: Array = aerofoil.mesh.surface_get_arrays(0)
        var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
        var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
        if vertices.size() < 1500 or normals.size() != vertices.size():
            _fail("carve fin must be a smooth, substantial 3D aerofoil")
            return
        # Previously the entire vane sat inside the old side wing: the
        # OpenGL chase-camera A/B image changed exactly zero pixels.
        var side := -1.0 if (hinge as Node3D).name.begins_with("Port") else 1.0
        var wing_tip: Vector3 = sculpt.call("_wing_point", side, 0.5, 0.0)
        var fin_tip: Vector3 = (hinge as Node3D).position + \
            vanes.call("_fin_point", side, 0.5, 0.0)
        if absf(fin_tip.x) < absf(wing_tip.x) + 0.12 or \
                fin_tip.y < wing_tip.y + 0.17:
            _fail("carve fin tip is buried behind the sculpted board wing")
            return
        # The actual triangle mesh must have continuous, outward-facing
        # surface normals on both mirrored fins. A previous unindexed mesh
        # generated per-face normals and visibly faceted in the chase view.
        for ring_angle in [PI * 0.5, PI * 1.5]:
            var point: Vector3 = vanes.call("_fin_point", side, 0.5, ring_angle)
            var expected: Vector3 = vanes.call("_fin_normal", side, 0.5, ring_angle)
            if not expected.is_finite() or expected.length_squared() < 0.99:
                _fail("carve fin analytic normal is invalid")
                return
            var shared_count := 0
            var first_normal := Vector3.ZERO
            for index in range(vertices.size()):
                if vertices[index].distance_to(point) > 0.0001:
                    continue
                var normal: Vector3 = normals[index]
                if not normal.is_finite() or normal.length_squared() < 0.99 or \
                        normal.dot(expected) < 0.99:
                    _fail("carve fin has a wrong or faceted shell normal")
                    return
                if shared_count > 0 and normal.dot(first_normal) < 0.999:
                    _fail("coincident fin vertices have discontinuous shading")
                    return
                first_normal = normal
                shared_count += 1
            if shared_count < 3:
                _fail("carve fin smooth shading needs shared triangle vertices")
                return
    var starboard_angle_30 := 0.0
    for fps in [30, 60]:
        for hinge in hinges:
            (hinge as Node3D).rotation.z = 0.0
        for frame in range(3 if fps == 30 else 6):
            vanes.call("update_state", 0.9, true, 1.0 / float(fps))
        var port_angle := absf((hinges[0] as Node3D).rotation.z)
        var starboard_angle := absf((hinges[1] as Node3D).rotation.z)
        if starboard_angle < port_angle + 0.16:
            _fail("right carve must physically deploy the starboard fin")
            return
        if fps == 30:
            starboard_angle_30 = starboard_angle
        elif absf(starboard_angle - starboard_angle_30) > 0.003:
            _fail("fin animation changes with mobile frame rate")
            return
    for frame in range(12):
        vanes.call("update_state", -0.9, false, 0.016)
    if absf((hinges[0] as Node3D).rotation.z) <= absf((hinges[1] as Node3D).rotation.z) + 0.12:
        _fail("left carve must reverse the deployed aerofoil")
        return
    if not vanes.find_children("*", "CollisionObject3D", true, false).is_empty():
        _fail("articulated board art must never change collision or touch controls")
        return
    if rider.get_node_or_null("ImportedRider/OriginalBodySkinRig/OriginalBodySkeleton13") == null:
        _fail("original 13-bone skinned character must remain")
        return
    print("SCULPTED HOVERBOARD TEST PASSED: continuous hull, paired 3D turbines and boost exhaust, swept wings, hover/lean, original rig and untouched collisions")
    quit(0)
