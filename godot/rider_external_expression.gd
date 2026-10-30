extends Node
## V124 draft: lightweight animated facial acting for the real Head-bone
## attachment. Changes only existing visual transforms; never the CC0 Skin,
## original 65 bones, hoverboard controls, collision shapes or game rules.
var headwear: BoneAttachment3D
var features: Dictionary = {}

func configure(attachment: BoneAttachment3D) -> bool:
    if attachment == null:
        return false
    headwear = attachment
    features.clear()
    for pattern in ["EyeWhite*", "Iris*", "Pupil*", "IrisCatchlight*",
            "UpperLid*", "LowerLid*", "CurvedBrow*", "CurvedSmile",
            "LowerLipContour"]:
        for child in headwear.find_children(pattern, "MeshInstance3D", false, false):
            var part := child as MeshInstance3D
            features[String(part.name)] = {
                "node": part,
                "position": part.position,
                "scale": part.scale,
                "rotation": part.rotation
            }
    return _count("EyeWhite") == 2 and _count("Iris") >= 6 and \
        _count("Pupil") == 2 and _count("UpperLid") == 2 and \
        _count("LowerLid") == 2 and _count("CurvedBrow") == 2 and \
        features.has("CurvedSmile")

func _count(prefix: String) -> int:
    var total := 0
    for name in features:
        if String(name).begins_with(prefix):
            total += 1
    return total

func animate(steer: float, boosting: bool, jump: float, clock: float,
        forced_blink: float = -1.0) -> void:
    if headwear == null or features.is_empty():
        return
    var turn := clampf(steer, -1.0, 1.0)
    var air := clampf(jump, 0.0, 1.0)
    var speed := 1.0 if boosting else 0.0
    # Deterministic periodic eyelid closure; no timers or extra draw calls.
    # Override is exclusively useful for pose/visual regression captures.
    var phase := fposmod(clock, 4.3)
    var blink := clampf(1.0 - absf(phase - 3.2) / 0.13, 0.0, 1.0)
    if forced_blink >= 0.0:
        blink = clampf(forced_blink, 0.0, 1.0)
    var dimensions: Vector3 = headwear.get("head_bounds").size
    var scale_factor: float = float(headwear.get("visual_scale"))
    var width := dimensions.x * scale_factor
    var height := dimensions.y * scale_factor
    var gaze := Vector3(turn * width * 0.017,
        (air * 0.012 - speed * 0.008) * height, 0.0)
    for key in features:
        var item: Dictionary = features[key]
        var part := item["node"] as MeshInstance3D
        if not is_instance_valid(part):
            continue
        var base_position: Vector3 = item["position"]
        var base_scale: Vector3 = item["scale"]
        var base_rotation: Vector3 = item["rotation"]
        var name := String(key)
        part.position = base_position
        part.scale = base_scale
        part.rotation = base_rotation
        if name.begins_with("EyeWhite"):
            part.scale.y = base_scale.y * (1.0 - 0.85 * blink)
        elif name.begins_with("Iris") or name.begins_with("Pupil"):
            part.position += gaze
            part.scale.y = base_scale.y * (1.0 - 0.85 * blink)
        elif name.begins_with("UpperLid"):
            part.position.y -= height * 0.057 * blink
            part.position.y += height * (0.014 * speed + 0.008 * air)
        elif name.begins_with("LowerLid"):
            part.position.y += height * 0.028 * blink
        elif name.begins_with("CurvedBrow"):
            var side := -1.0 if name.contains("-1") else 1.0
            part.position.y += height * (0.014 * speed + 0.011 * air)
            part.rotation.z += side * (0.12 * speed + 0.10 * air) - turn * 0.045
        elif name == "CurvedSmile":
            part.scale.x = base_scale.x * (1.0 + 0.13 * speed + 0.06 * air)
            part.position.y += height * 0.009 * speed
        elif name == "LowerLipContour":
            part.position.y -= height * (0.013 * speed + 0.010 * air)
