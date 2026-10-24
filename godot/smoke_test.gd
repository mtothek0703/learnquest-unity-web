extends SceneTree
## Automated game-level smoke test used by GitHub Actions.
## Runs without a GPU: verifies that the actual level, character, pickups, quiz
## and input actions initialize and can be exercised without script errors.

func _initialize() -> void:
    call_deferred("_run_checks")

func _fail(message: String) -> void:
    push_error("LEARNQUEST TEST FAILED: " + message)
    quit(1)

func _run_checks() -> void:
    var scene := load("res://main.tscn") as PackedScene
    if scene == null:
        _fail("Unable to load main.tscn")
        return
    var game := scene.instantiate() as Node3D
    if game == null:
        _fail("Main scene is not a Node3D")
        return
    root.add_child(game)
    await process_frame
    if game.get_node_or_null("LearnQuest Skyway world") == null:
        _fail("Skyway 3D environment is missing")
        return
    if game.get("rider") == null:
        _fail("Animated hoverboard character is missing")
        return
    var rider := game.get("rider") as Node3D
    if rider == null or rider.get_node_or_null("LegacyRider/Floating hoverboard") == null:
        _fail("Rider scene must preserve the animated hoverboard")
        return
    var fallback := rider.get_node_or_null("LegacyRider/Animated racer rig") as Node3D
    if fallback == null:
        _fail("Legacy rider fallback must exist")
        return
    var installed_model := rider.get_node_or_null("ImportedRider")
    if installed_model == null:
        _fail("Bundled 3D rider model was not imported")
        return
    if fallback.visible:
        _fail("Fallback body must be hidden while imported 3D rider is active")
        return
    var hairstyle := installed_model.get_node_or_null("RiderHair") as Node3D
    if hairstyle == null or hairstyle.get_child_count() < 8:
        _fail("The stylized 3D rider hair and animated locks are missing")
        return
    var hair_lock := hairstyle.get_node_or_null("WindHair1") as Node3D
    if hair_lock == null:
        _fail("The central wind-animated hair lock is missing")
        return
    var sculpted_lock := hair_lock.get_node_or_null("HairLock") as MeshInstance3D
    if sculpted_lock == null or not (sculpted_lock.mesh is ArrayMesh):
        _fail("Hair must use the new sculpted 3D lock mesh")
        return
    if (sculpted_lock.mesh as ArrayMesh).surface_get_array_len(0) < 200:
        _fail("Tapered hair mesh has insufficient geometry")
        return
    # V33: a continuous three-strand braid and two luminous hair clasps.
    var braid := installed_model.get_node_or_null("AnimatedBraidedPonytail") as Node3D
    var sway := braid.get_node_or_null("WindSwayPivot") as Node3D if braid != null else null
    if sway == null:
        _fail("Braided ponytail is not attached to the imported rider")
        return
    for strand in range(3):
        var part := sway.get_node_or_null("BraidedStrand%d" % strand) as MeshInstance3D
        if part == null or not (part.mesh is ArrayMesh) or (part.mesh as ArrayMesh).surface_get_array_len(0) < 1500:
            _fail("Interlaced hair geometry missing: strand %d" % strand)
            return
        var hair_material := part.material_override as StandardMaterial3D
        if hair_material == null or not hair_material.vertex_color_use_as_albedo:
            _fail("Braided hair must preserve shaded strand colors")
            return
    for clasp_name in ["RootClasp", "TipClasp"]:
        var clasp := sway.get_node_or_null(clasp_name) as MeshInstance3D
        if clasp == null or not (clasp.material_override as StandardMaterial3D).emission_enabled:
            _fail("Luminous hair clasp missing: " + clasp_name)
            return
    # V31: expressive face has original curved geometry and timed blinking.
    var face := installed_model.get_node_or_null("ExpressiveFace") as Node3D
    if face == null:
        _fail("Expressive facial rig is missing")
        return
    var smile := face.get_node_or_null("CurvedSmile") as MeshInstance3D
    if smile == null or not (smile.mesh is ArrayMesh) or (smile.mesh as ArrayMesh).surface_get_array_len(0) < 200:
        _fail("Sculpted curved smile mesh is missing")
        return
    for eye_name in ["LeftEye", "RightEye"]:
        var eye := face.get_node_or_null(eye_name) as Node3D
        if eye == null or eye.get_node_or_null("EyeGlint") == null:
            _fail("Layered eye and highlight missing: " + eye_name)
            return
    if float(face.call("_blink_factor", 3.90)) > 0.2 or not is_equal_approx(float(face.call("_blink_factor", 1.0)), 1.0):
        _fail("Expressive face blink timing is incorrect")
        return
    for index in range(5):
        var swept := hairstyle.get_node_or_null("SweptHair%d" % index) as MeshInstance3D
        if swept == null or not (swept.mesh is ArrayMesh) or (swept.mesh as ArrayMesh).surface_get_array_len(0) < 200:
            _fail("Sculpted hair crest lock is missing")
            return
    # V35: true volumetric hair shell, layered gradient strands and
    # articulated side curls, all with original curved mesh geometry.
    var volume := installed_model.get_node_or_null("SculptedVolumetricHair") as Node3D
    if volume == null:
        _fail("Volumetric hair sculpture is missing")
        return
    var scalp := volume.get_node_or_null("VolumetricScalp") as MeshInstance3D
    if scalp == null or not (scalp.mesh is ArrayMesh) or (scalp.mesh as ArrayMesh).surface_get_array_len(0) < 2400:
        _fail("Hair crown must have a detailed continuous 3D surface")
        return
    var scalp_material := scalp.material_override as StandardMaterial3D
    if scalp_material == null or not scalp_material.vertex_color_use_as_albedo:
        _fail("Hair crown needs the original shaded color gradient")
        return
    for layer in range(6):
        var swept := volume.get_node_or_null("SweptLayer%d" % layer) as MeshInstance3D
        var glint := volume.get_node_or_null("LuminousHairSheen%d" % layer) as MeshInstance3D
        if swept == null or not (swept.mesh is ArrayMesh) or (swept.mesh as ArrayMesh).surface_get_array_len(0) < 450:
            _fail("Detailed layered hair plate missing: %d" % layer)
            return
        if glint == null or not (glint.mesh is ArrayMesh) or not (glint.material_override as StandardMaterial3D).emission_enabled:
            _fail("Glowing hair highlight missing: %d" % layer)
            return
    for curl_name in ["LeftTempleCurl", "RightTempleCurl"]:
        var curl := volume.get_node_or_null(curl_name) as Node3D
        var strand := curl.get_node_or_null("SculptedCurl") as MeshInstance3D if curl != null else null
        if strand == null or not (strand.mesh is ArrayMesh) or (strand.mesh as ArrayMesh).surface_get_array_len(0) < 1000:
            _fail("Sculpted articulated temple curl missing: " + curl_name)
            return
    # V38: two real curved jacket panels, raised collar, sculpted chest
    # plates and an animated luminous zipper; gameplay nodes are untouched.
    var torso := installed_model.get_node_or_null("AnimatedTailoredFlightJacket") as Node3D
    if torso == null:
        _fail("Sculpted front flight jacket is missing")
        return
    var breathing := torso.get_node_or_null("AnimatedBreathingJacket") as Node3D
    if breathing == null:
        _fail("Animated breathing jacket pivot is missing")
        return
    for part_name in ["TailoredLeftChest", "TailoredRightChest"]:
        var panel := breathing.get_node_or_null(part_name) as MeshInstance3D
        if panel == null or not (panel.mesh is ArrayMesh) or (panel.mesh as ArrayMesh).surface_get_array_len(0) < 1500:
            _fail("Sculpted high-resolution jacket panel missing: " + part_name)
            return
        var fabric := panel.material_override as StandardMaterial3D
        if fabric == null or not fabric.vertex_color_use_as_albedo:
            _fail("Tailored jacket requires shaded fabric gradients")
            return
    for part_name in ["LayeredLeftChestArmor", "LayeredRightChestArmor"]:
        var armor_panel := breathing.get_node_or_null(part_name) as MeshInstance3D
        if armor_panel == null or not (armor_panel.mesh is ArrayMesh) or (armor_panel.mesh as ArrayMesh).surface_get_array_len(0) < 800:
            _fail("Sculpted chest armor missing: " + part_name)
            return
    var collar := torso.get_node_or_null("RaisedFlightCollar") as MeshInstance3D
    if collar == null or not (collar.mesh is ArrayMesh) or (collar.mesh as ArrayMesh).surface_get_array_len(0) < 1200:
        _fail("Continuous curved flight collar is missing")
        return
    for seam_name in ["LuminousCenterZipper", "LuminousWaistPiping", "LuminousLeftChestEdge", "LuminousRightChestEdge"]:
        var seam := breathing.get_node_or_null(seam_name) as MeshInstance3D
        if seam == null or not (seam.mesh is ArrayMesh) or (seam.mesh as ArrayMesh).surface_get_array_len(0) < 100:
            _fail("Curved jacket piping missing: " + seam_name)
            return
        var seam_mat := seam.material_override as StandardMaterial3D
        if seam_mat == null or not seam_mat.emission_enabled:
            _fail("Flight jacket neon piping is not emissive")
            return
    torso.call("_process", 0.20)
    if absf(breathing.scale.z - 1.0) < 0.001:
        _fail("Jacket breathing animation does not move the sculpted mesh")
        return
    var jacket := installed_model.get_node_or_null("SculptedJacketBack") as MeshInstance3D
    var emblem := installed_model.get_node_or_null("NeonJacketEmblem") as MeshInstance3D
    if jacket == null or not (jacket.mesh is ArrayMesh) or (jacket.mesh as ArrayMesh).surface_get_array_len(0) < 300:
        _fail("Sculpted jacket shell is missing or incomplete")
        return
    if emblem == null or emblem.mesh == null or emblem.mesh.get_surface_count() == 0:
        _fail("Glowing jacket emblem is missing")
        return
    var scarf := installed_model.get_node_or_null("AnimatedScarfTail0") as Node3D
    var cloth := scarf.get_node_or_null("FlowingCloth") as MeshInstance3D if scarf != null else null
    var hem := scarf.get_node_or_null("NeonHem") as MeshInstance3D if scarf != null else null
    if cloth == null or not (cloth.mesh is ArrayMesh) or (cloth.mesh as ArrayMesh).surface_get_array_len(0) < 250:
        _fail("Flowing scarf must use a detailed curved mesh rather than a box")
        return
    if hem == null or not (hem.mesh is ArrayMesh) or (hem.mesh as ArrayMesh).surface_get_array_len(0) < 250:
        _fail("Curved neon scarf hem is missing")
        return
    # Curved shoulder plates and their emissive piping must exist on both
    # articulated arms, with sufficient original mesh geometry.
    for arm_name in ["BalanceArm0", "BalanceArm1"]:
        var guard := installed_model.get_node_or_null(arm_name + "/SculptedShoulderGuard") as MeshInstance3D
        var trim := installed_model.get_node_or_null(arm_name + "/ShoulderNeonTrim") as MeshInstance3D
        if guard == null or not (guard.mesh is ArrayMesh) or (guard.mesh as ArrayMesh).surface_get_array_len(0) < 700:
            _fail("Sculpted shoulder armor is missing on " + arm_name)
            return
        if trim == null or not (trim.mesh is ArrayMesh) or (trim.mesh as ArrayMesh).surface_get_array_len(0) < 150:
            _fail("Curved neon shoulder piping is missing on " + arm_name)
            return
        var trim_material := trim.material_override as StandardMaterial3D
        if trim_material == null or not trim_material.emission_enabled:
            _fail("Neon shoulder piping is not emissive on " + arm_name)
            return
    # V37: each hand has a shaped forearm, knuckles, articulated fingers
    # and a curved emissive wrist display, not just the legacy hand sphere.
    for arm_name in ["BalanceArm0", "BalanceArm1"]:
        var gauntlet := installed_model.get_node_or_null(arm_name + "/SculptedRiderGauntlet") as Node3D
        if gauntlet == null:
            _fail("Sculpted glove missing on " + arm_name)
            return
        for part_name in ["SculptedForearmShell", "LayeredKnuckleGuard", "LuminousGauntletSeams"]:
            var part := gauntlet.get_node_or_null(part_name) as MeshInstance3D
            if part == null or not (part.mesh is ArrayMesh) or (part.mesh as ArrayMesh).surface_get_array_len(0) < 180:
                _fail("Gauntlet mesh missing: " + arm_name + "/" + part_name)
                return
        var fabric := (gauntlet.get_node("SculptedForearmShell") as MeshInstance3D).material_override as StandardMaterial3D
        if fabric == null or not fabric.vertex_color_use_as_albedo:
            _fail("Gauntlet must retain sculpted fabric gradients")
            return
        var display := gauntlet.get_node_or_null("AnimatedWristDisplay/CurvedHolographicDisplay") as MeshInstance3D
        if display == null or not (display.mesh is ArrayMesh) or (display.mesh as ArrayMesh).surface_get_array_len(0) < 700:
            _fail("Curved wrist hologram missing on " + arm_name)
            return
        var display_material := display.material_override as StandardMaterial3D
        if display_material == null or not display_material.emission_enabled:
            _fail("Wrist display must glow")
            return
        for finger_index in range(4):
            var finger := gauntlet.get_node_or_null("ArticulatedFinger%d/TaperedFingerMesh" % finger_index) as MeshInstance3D
            if finger == null or not (finger.mesh is ArrayMesh) or (finger.mesh as ArrayMesh).surface_get_array_len(0) < 400:
                _fail("Articulated finger missing: " + arm_name)
                return
        if gauntlet.get_node_or_null("SculptedThumb") == null:
            _fail("Sculpted thumb missing: " + arm_name)
            return
    # V32: custom-meshed high-top footwear follows both articulated legs.
    for leg_name in ["BalanceLeg0", "BalanceLeg1"]:
        var footwear := installed_model.get_node_or_null(leg_name + "/SculptedHoverBoot") as Node3D
        if footwear == null:
            _fail("Animated high-top boot missing: " + leg_name)
            return
        for mesh_name in ["SculptedUpper", "SculptedSole"]:
            var part := footwear.get_node_or_null(mesh_name) as MeshInstance3D
            if part == null or not (part.mesh is ArrayMesh) or (part.mesh as ArrayMesh).surface_get_array_len(0) < 1000:
                _fail("Boot needs detailed sculpted geometry: " + leg_name + "/" + mesh_name)
                return
        for detail_name in ["NeonSoleWelt", "WovenLaces"]:
            var detail := footwear.get_node_or_null(detail_name) as MeshInstance3D
            if detail == null or not (detail.mesh is ArrayMesh):
                _fail("Boot detail missing: " + leg_name + "/" + detail_name)
                return
            var detail_material := detail.material_override as StandardMaterial3D
            if detail_material == null or not detail_material.emission_enabled:
                _fail("Boot edge and laces must glow")
                return
        if footwear.get_node_or_null("TailoredAnkleCuff") == null:
            _fail("Boot ankle cuff missing: " + leg_name)
            return
    # V34: original sculpted fabric legs and articulated knee armor.
    for leg_name in ["BalanceLeg0", "BalanceLeg1"]:
        var leg_armor := installed_model.get_node_or_null(leg_name + "/SculptedRiderLeg") as Node3D
        if leg_armor == null:
            _fail("Tailored rider leg mesh missing: " + leg_name)
            return
        var trousers := leg_armor.get_node_or_null("TailoredTrouserShell") as MeshInstance3D
        var seams := leg_armor.get_node_or_null("LuminousSideSeams") as MeshInstance3D
        var knee := leg_armor.get_node_or_null("KneeArmorPivot") as Node3D
        var guard := knee.get_node_or_null("CurvedKneeGuard") as MeshInstance3D if knee != null else null
        var trim := knee.get_node_or_null("KneeNeonPiping") as MeshInstance3D if knee != null else null
        if trousers == null or not (trousers.mesh is ArrayMesh) or (trousers.mesh as ArrayMesh).surface_get_array_len(0) < 1600:
            _fail("Sculpted trouser shell needs detailed original mesh: " + leg_name)
            return
        var fabric := trousers.material_override as StandardMaterial3D
        if fabric == null or not fabric.vertex_color_use_as_albedo:
            _fail("Trouser fabric gradient missing: " + leg_name)
            return
        if seams == null or not (seams.mesh is ArrayMesh) or (seams.material_override as StandardMaterial3D) == null or not (seams.material_override as StandardMaterial3D).emission_enabled:
            _fail("Glowing trouser seams missing: " + leg_name)
            return
        if guard == null or not (guard.mesh is ArrayMesh) or (guard.mesh as ArrayMesh).surface_get_array_len(0) < 800:
            _fail("Sculpted articulated knee guard missing: " + leg_name)
            return
        if trim == null or not (trim.mesh is ArrayMesh) or (trim.material_override as StandardMaterial3D) == null or not (trim.material_override as StandardMaterial3D).emission_enabled:
            _fail("Glowing knee armor piping missing: " + leg_name)
            return
    # V31: mesh-built two-panel coat, gradient fabric, luminous seams and collar.
    var coat := installed_model.get_node_or_null("AnimatedSculptedCoat") as Node3D
    if coat == null:
        _fail("Sculpted animated coat is missing")
        return
    for tail_name in ["LeftCoatTail", "RightCoatTail"]:
        var tail := coat.get_node_or_null(tail_name) as Node3D
        var coat_cloth := tail.get_node_or_null("SculptedCloth") as MeshInstance3D if tail != null else null
        var seams := tail.get_node_or_null("NeonSeams") as MeshInstance3D if tail != null else null
        if coat_cloth == null or not (coat_cloth.mesh is ArrayMesh) or (coat_cloth.mesh as ArrayMesh).surface_get_array_len(0) < 650:
            _fail("Detailed curved coat fabric missing: " + tail_name)
            return
        if seams == null or not (seams.mesh is ArrayMesh) or (seams.mesh as ArrayMesh).surface_get_array_len(0) < 200:
            _fail("Glowing tailored coat seams missing: " + tail_name)
            return
        var seam_material := seams.material_override as StandardMaterial3D
        if seam_material == null or not seam_material.emission_enabled:
            _fail("Coat seams must be emissive")
            return
    var collar := coat.get_node_or_null("RaisedSculptedCollar") as MeshInstance3D
    var collar_light := coat.get_node_or_null("CollarLight") as MeshInstance3D
    if collar == null or not (collar.mesh is ArrayMesh) or (collar.mesh as ArrayMesh).surface_get_array_len(0) < 100 or collar_light == null:
        _fail("Raised curved collar and luminous trim are missing")
        return
    # V31: original articulated aerofoil costume must have sculpted geometry.
    var aero := installed_model.get_node_or_null("AnimatedAeroWings") as Node3D
    if aero == null:
        _fail("Animated sculpted aerofoil costume is missing")
        return
    for side_name in ["LeftWing", "RightWing"]:
        var wing := aero.get_node_or_null(side_name) as Node3D
        if wing == null:
            _fail("Articulated aerofoil missing: " + side_name)
            return
        for fin_name in ["SculptedUpperFin", "SculptedLowerFin"]:
            var fin := wing.get_node_or_null(fin_name) as MeshInstance3D
            if fin == null or not (fin.mesh is ArrayMesh) or (fin.mesh as ArrayMesh).surface_get_array_len(0) < 700:
                _fail("Detailed sculpted wing geometry missing: " + side_name + "/" + fin_name)
                return
        for edge_name in ["UpperNeonEdge", "LowerNeonEdge", "UpperNeonVein", "LowerNeonVein"]:
            var light := wing.get_node_or_null(edge_name) as MeshInstance3D
            if light == null or not (light.mesh is ArrayMesh) or not (light.material_override as StandardMaterial3D).emission_enabled:
                _fail("Luminous aerofoil edge missing: " + side_name + "/" + edge_name)
                return
    # V36: the sculpted aero harness must be visible, vertex-shaded and animated.
    var harness := installed_model.get_node_or_null("AnimatedAeroHarness") as Node3D
    if harness == null:
        _fail("Back-mounted aero harness is missing")
        return
    var plate := harness.get_node_or_null("CurvedAeroBackplate") as MeshInstance3D
    if plate == null or not (plate.mesh is ArrayMesh) or (plate.mesh as ArrayMesh).surface_get_array_len(0) < 1400:
        _fail("Curved back armor requires detailed original mesh geometry")
        return
    var plate_material := plate.material_override as StandardMaterial3D
    if plate_material == null or not plate_material.vertex_color_use_as_albedo:
        _fail("Back armor color gradients are missing")
        return
    var reactor := harness.get_node_or_null("RotatingEnergyReactor") as Node3D
    var ring := reactor.get_node_or_null("SculptedReactorRing") as MeshInstance3D if reactor != null else null
    if ring == null or not (ring.mesh is ArrayMesh) or (ring.mesh as ArrayMesh).surface_get_array_len(0) < 250:
        _fail("Sculpted rotating reactor ring is missing")
        return
    for thruster_name in ["LeftAeroThruster", "RightAeroThruster"]:
        var thruster := harness.get_node_or_null(thruster_name) as Node3D
        var housing := thruster.get_node_or_null("SculptedThrusterHousing") as MeshInstance3D if thruster != null else null
        var plume := thruster.get_node_or_null("NeonExhaustPlume") as MeshInstance3D if thruster != null else null
        if housing == null or not (housing.mesh is ArrayMesh) or (housing.mesh as ArrayMesh).surface_get_array_len(0) < 1200:
            _fail("Sculpted thruster housing is missing: " + thruster_name)
            return
        if plume == null or not (plume.mesh is ArrayMesh) or not (plume.material_override as StandardMaterial3D).emission_enabled:
            _fail("Neon thruster exhaust is missing: " + thruster_name)
            return
    var old_reactor_angle := reactor.rotation.z
    rider.set("boosting", true)
    rider.set("lean", 0.8)
    await process_frame
    if reactor.rotation.z <= old_reactor_angle or absf(reactor.scale.x - 1.0) < 0.001:
        _fail("Aero reactor did not animate under turbo")
        return
    var glove := installed_model.get_node("BalanceArm0/SculptedRiderGauntlet") as Node3D
    var finger := glove.get_node("ArticulatedFinger0") as Node3D
    var display_pivot := glove.get_node("AnimatedWristDisplay") as Node3D
    if finger.rotation.x <= 0.0 or absf(display_pivot.rotation.z) < 0.001:
        _fail("Gauntlet fingers and wrist display must respond to turbo and steering")
        return
    var left_thruster := harness.get_node("LeftAeroThruster") as Node3D
    if absf(left_thruster.rotation.z) < 0.001:
        _fail("Aero thrusters must react to steering")
        return
    if absf(scarf.rotation.x) < 0.001:
        _fail("Flowing scarf did not respond to rider motion")
        return
    if absf(hair_lock.rotation.x) < 0.001 or absf(hair_lock.rotation.z) < 0.001:
        _fail("The 3D rider hair is not responding to turbo and steering")
        return
    var temple := volume.get_node("LeftTempleCurl") as Node3D
    if absf(temple.rotation.x) < 0.001 or absf(temple.rotation.z) < 0.001:
        _fail("Sculpted temple hair must respond to turbo and steering")
        return
    var left_tail := coat.get_node("LeftCoatTail") as Node3D
    if left_tail.rotation.x >= 0.0:
        _fail("Coat fabric does not respond to turbo wind")
        return
    var left_wing := aero.get_node("LeftWing") as Node3D
    if absf(left_wing.rotation.z) < 0.001 or absf(left_wing.rotation.x) < 0.001:
        _fail("Articulated aerofoil does not react to steering and turbo")
        return
    if absf(sway.rotation.x) < 0.001 or absf(sway.rotation.z) < 0.001:
        _fail("Braided ponytail must sway with turbo and steering")
        return
    rider.set("boosting", false)
    rider.set("lean", 0.0)
    # Exercise the new replacement contract without requiring any paid model.
    var placeholder := Node3D.new()
    rider.call("set_character_model", placeholder)
    if rider.get_node_or_null("ImportedRider") == null or fallback.visible:
        _fail("Imported visual does not replace the legacy character correctly")
        return
    rider.call("restore_fallback")
    if not fallback.visible:
        _fail("Restoring the legacy character failed")
        return
    # Regression: jumping moves the RiderCharacter root, not its LegacyRider child.
    rider.position.y = 1.4
    await process_frame
    await process_frame
    var legacy := rider.get_node("LegacyRider")
    if float(legacy.get("jump_pose")) <= 0.0:
        _fail("Hoverboard rider does not animate during a real jump")
        return
    rider.position.y = 0.0
    await process_frame
    if float(legacy.get("landing_pulse")) <= 0.0:
        _fail("Hoverboard landing shockwave did not trigger")
        return
    var items := game.get("run_items") as Node3D
    if items == null or items.get_child_count() < 10:
        _fail("Obstacles and pickups were not created")
        return
    # Simulate portrait and desktop viewport widths without a real phone.
    var controls := game.get("controls_grid") as GridContainer
    if controls == null or controls.get_child_count() != 4:
        _fail("Hoverboard touch controls are missing")
        return
    game.call("_apply_mobile_layout", 390.0)
    if controls.columns != 2 or controls.offset_top > -130.0:
        _fail("Phone portrait controls must use two rows")
        return
    for panel in [game.get("splash"), game.get("quiz_box"), game.get("end_panel")]:
        if (panel as PanelContainer).custom_minimum_size.x > 366.0:
            _fail("Phone portrait overlay exceeds the available width")
            return
    var mobile_hud := game.get("hud") as Label
    var hud_panel := game.get("hud_panel") as PanelContainer
    if mobile_hud == null or hud_panel == null:
        _fail("Race HUD or its panel is missing")
        return
    if not mobile_hud.text.contains("V31") or not mobile_hud.text.contains("\n") or not mobile_hud.text.contains("KOMBO x0"):
        _fail("Phone portrait HUD must display version, stats and combo on separate lines")
        return
    if hud_panel.custom_minimum_size.x > 360.0:
        _fail("Phone portrait HUD panel is too wide")
        return
    game.call("_apply_mobile_layout", 960.0)
    if controls.columns != 4:
        _fail("Desktop controls must return to one row")
        return
    if not mobile_hud.text.contains("SKYWAY V31") or mobile_hud.text.contains("\n"):
        _fail("Desktop HUD must return to its single-line layout")
        return
    game.call("_start_game")
    var hud := game.get("hud") as Label
    if hud == null or not hud.text.contains("SKYWAY V31") or not hud.text.contains("KOMBO x0"):
        _fail("Race HUD must show the current version and starting combo")
        return
    if not bool(game.get("started")):
        _fail("The race did not start")
        return
    game.call("_shift", 1)
    if int(game.get("lane")) != 1:
        _fail("Player cannot steer to the right")
        return
    game.call("_shift", -1)
    if int(game.get("lane")) != 0:
        _fail("Player cannot steer to the center")
        return
    game.call("_jump")
    if float(game.get("jump_left")) <= 0.0:
        _fail("Jump did not trigger")
        return
    # Regression: repeated turbo taps must not spend energy while boost is active.
    game.set("power", 80)
    game.call("_use_turbo")
    if int(game.get("power")) != 40 or float(game.get("turbo_left")) <= 0.0:
        _fail("Turbo did not activate or charge the expected energy")
        return
    var active_boost: float = float(game.get("turbo_left"))
    game.call("_use_turbo")
    if int(game.get("power")) != 40 or not is_equal_approx(float(game.get("turbo_left")), active_boost):
        _fail("Repeated turbo tap consumed energy or reset the active boost")
        return
    game.set("turbo_left", 0.0)
    game.call("_use_turbo")
    if int(game.get("power")) != 0 or float(game.get("turbo_left")) <= 0.0:
        _fail("Turbo cannot be reactivated after the previous boost expires")
        return
    game.set("turbo_left", 0.0)
    # Energy rings must rotate and pulse without replacing the existing meshes.
    var energy_gate: MeshInstance3D = null
    for item in items.get_children():
        if bool(item.get_meta("energy")):
            energy_gate = item.get_node_or_null("Energy gate") as MeshInstance3D
            break
    if energy_gate == null:
        _fail("Collectible energy gate is missing")
        return
    var previous_angle := energy_gate.rotation.z
    game.set("distance", 14.0)
    game.call("_update_run_items", 0.016)
    if energy_gate.rotation.z <= previous_angle or absf(energy_gate.scale.x - 1.0) < 0.001:
        _fail("Collectible energy gate rotation or pulse is not animated")
        return
    var camera := game.get("chase_camera") as Camera3D
    if camera == null:
        _fail("Chase camera missing")
        return
    game.call("_update_camera", 0.2)
    if camera.fov < 63.0:
        _fail("Camera field of view is invalid")
        return
    game.call("_ask")
    if not bool(game.get("quiz_active")):
        _fail("Vocabulary challenge did not open")
        return
    if game.get("quiz_box") == null:
        _fail("Vocabulary overlay is missing")
        return
    # A child should not receive the same word twice in a row.
    var previous_word: int = int(game.get("correct_index"))
    for attempt in range(20):
        game.call("_ask")
        var current_word: int = int(game.get("correct_index"))
        if current_word == previous_word:
            _fail("Vocabulary challenge repeated the previous word")
            return
        var choices: Array = game.get("options")
        if choices.size() != 3 or not choices.has(current_word):
            _fail("Vocabulary answers are missing the correct translation")
            return
        if choices[0] == choices[1] or choices[0] == choices[2] or choices[1] == choices[2]:
            _fail("Vocabulary challenge contains duplicate answer options")
            return
        previous_word = current_word
    # Cover both the youngest and oldest available grade bands.
    for school_grade in [1, 10]:
        game.set("grade", school_grade)
        game.call("_ask")
        if (game.get("question_label") as Label).text.is_empty():
            _fail("Vocabulary question missing for grade %d" % school_grade)
            return
    # Correct vocabulary answers must update the visible streak counter.
    game.set("grade", 5)
    game.call("_ask")
    var correct_option: int = (game.get("options") as Array).find(int(game.get("correct_index")))
    if correct_option < 0:
        _fail("Correct vocabulary option cannot be selected")
        return
    # An invalid or delayed tap must not crash or change the challenge.
    var before_xp: int = int(game.get("xp"))
    var before_power: int = int(game.get("power"))
    game.call("_answer", -1)
    game.call("_answer", 3)
    if not bool(game.get("quiz_active")) or int(game.get("xp")) != before_xp or int(game.get("power")) != before_power:
        _fail("Invalid quiz answer index modified the active challenge")
        return
    game.call("_answer", correct_option)
    if int(game.get("combo")) != 1 or not hud.text.contains("KOMBO x1"):
        _fail("Correct vocabulary answer does not update the HUD combo")
        return
    # Double tapping a correct answer must never grant a second reward.
    var rewarded_xp: int = int(game.get("xp"))
    var rewarded_power: int = int(game.get("power"))
    game.call("_answer", correct_option)
    if bool(game.get("quiz_active")) or int(game.get("combo")) != 1 or int(game.get("xp")) != rewarded_xp or int(game.get("power")) != rewarded_power:
        _fail("Stale answer awarded vocabulary rewards twice")
        return
    # Wrong answers must reset the visible combo immediately while the quiz
    # is paused; disable only the incorrect choice, not the whole quiz.
    game.call("_ask")
    var next_choices: Array = game.get("options")
    var next_correct: int = int(game.get("correct_index"))
    var wrong_option: int = -1
    for option_index in range(next_choices.size()):
        if int(next_choices[option_index]) != next_correct:
            wrong_option = option_index
            break
    if wrong_option < 0:
        _fail("Could not find an incorrect vocabulary choice")
        return
    game.call("_answer", wrong_option)
    var quiz_buttons: Array = game.get("answer_buttons")
    if not bool(game.get("quiz_active")) or int(game.get("combo")) != 0 or not hud.text.contains("KOMBO x0"):
        _fail("Wrong vocabulary answer did not reset the visible combo")
        return
    if not quiz_buttons[wrong_option].disabled:
        _fail("Wrong vocabulary choice remains tappable")
        return
    game.call("_ask")
    for answer_button in quiz_buttons:
        if answer_button.disabled:
            _fail("A new vocabulary question kept an old answer disabled")
            return
    print("LEARNQUEST SMOKE TEST PASSED: scene, 3D world, V35 sculpted hair volume, sculpted V34 rider legs, V33 braid and V32 boots, rider, steering, jump, pickups, vocabulary, responsive HUD")
    quit(0)
