extends SceneTree
## V124 draft: verify a coherent one-pass contour-lighting treatment across
## the original CC0 skinned body and the derived weighted garments.
const SHADERS := [
    "res://rider_quaternius_suit.gdshader",
    "res://rider_external_jacket.gdshader",
    "res://rider_external_sleeves.gdshader",
    "res://rider_external_lower.gdshader",
    "res://rider_external_mantle.gdshader",
    "res://rider_external_yoke.gdshader",
]

func _initialize() -> void:
    call_deferred("_check")

func _fail(reason: String) -> void:
    push_error("EXTERNAL SILHOUETTE MATERIAL TEST FAILED: " + reason)
    quit(1)

func _check() -> void:
    for path in SHADERS:
        var shader := load(path) as Shader
        if shader == null:
            _fail("missing shader: " + path)
            return
        var code := shader.code
        for required in ["silhouette_rim", "NORMAL", "VIEW", "ALBEDO", "EMISSION", "cull_"]:
            if not code.contains(required):
                _fail("missing one-pass material feature " + required + " in " + path)
                return
        if code.contains("next_pass") or code.contains("depth_draw_always"):
            _fail("contour treatment must not add an outline pass: " + path)
            return
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    rider.set("prefer_cc0_rigged_hero", true)
    root.add_child(rider)
    await process_frame
    var adapter := rider.get_node_or_null("ExternalHeroPose") as Node
    var hero := rider.get_node_or_null("ExternalRiggedHero") as Node3D
    if adapter == null or hero == null:
        _fail("original rigged hero was not imported")
        return
    var rig := adapter.get("skeleton") as Skeleton3D
    if rig == null or rig.get_bone_count() != 65:
        _fail("the original CC0 65-bone skeleton was replaced")
        return
    var weighted_count := 0
    var rimmed_weighted_count := 0
    for candidate in hero.find_children("*", "MeshInstance3D", true, false):
        var mesh := candidate as MeshInstance3D
        if mesh == null or mesh.mesh == null or mesh.skin == null:
            continue
        weighted_count += 1
        var mat := mesh.material_override as ShaderMaterial
        if mat != null and mat.shader != null and mat.shader.code.contains("silhouette_rim"):
            rimmed_weighted_count += 1
            if mesh.get_node_or_null(mesh.skeleton) != rig:
                _fail("rim-lit weighted garment lost its imported skeleton")
                return
    if weighted_count < 6 or rimmed_weighted_count < 6:
        _fail("body and multiple genuinely skinned garments must share contour shading")
        return
    print("EXTERNAL SILHOUETTE MATERIAL TEST PASSED: %d/%d weighted meshes, 65 imported bones" % [
        rimmed_weighted_count, weighted_count])
    quit(0)
