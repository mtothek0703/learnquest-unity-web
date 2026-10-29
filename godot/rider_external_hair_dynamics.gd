extends Node
## V124 draft: Head-bone-bound hair motion with scalp-anchored pivots.
## Reuses the existing closed swept hair geometry and materials. No new
## draw calls, external assets, collision shapes, input or gameplay changes.
var headwear: BoneAttachment3D
var locks: Array[Dictionary] = []

func configure(attachment: BoneAttachment3D) -> bool:
    if attachment == null:
        return false
    headwear = attachment
    locks.clear()
    for group in ["WindSweptBackLock*", "SideHairSweep*", "SculptedTaperedFringe*"]:
        var kind := 0
        if group.begins_with("Side"):
            kind = 1
        elif group.begins_with("Sculpted"):
            kind = 2
        for item in attachment.find_children(group, "MeshInstance3D", false, false):
            var mesh := item as MeshInstance3D
            if mesh == null or mesh.mesh == null:
                continue
            var bounds := mesh.mesh.get_aabb()
            # The uppermost part of each lock is embedded in the continuous
            # crown. Rotate around that scalp anchor, not around the head
            # origin (which would pull the roots out of the hairline).
            var anchor := Vector3(bounds.get_center().x, bounds.end.y,
                bounds.get_center().z)
            locks.append({
                "mesh": mesh,
                "rest": mesh.transform,
                "anchor": anchor,
                "kind": kind,
                "index": locks.size()
            })
    return locks.size() >= 13

func set_motion(steer: float, boost: float, jump: float, clock: float) -> void:
    if headwear == null:
        return
    var turn := clampf(steer, -1.0, 1.0)
    var speed := clampf(boost, 0.0, 1.0)
    var air := clampf(jump, 0.0, 1.0)
    for entry in locks:
        var part := entry["mesh"] as MeshInstance3D
        if not is_instance_valid(part):
            continue
        var kind: int = entry["kind"]
        var index: int = entry["index"]
        var rest: Transform3D = entry["rest"]
        var anchor: Vector3 = entry["anchor"]
        # Rear locks react more strongly than temple/fringe geometry. Keep
        # face-framing bangs nearly fixed to avoid eye/visor intersections.
        var strength := 1.0 if kind == 0 else (0.43 if kind == 1 else 0.20)
        var gust := sin(clock * 3.1 + float(index) * 0.67) * speed * 0.028
        var roll := strength * (-turn * 0.12 + speed * 0.07 + air * 0.055 + gust)
        var pitch := strength * (speed * 0.085 + air * 0.045)
        var yaw := strength * turn * 0.065
        var rotation := Basis(Quaternion(Vector3.FORWARD, roll) *
            Quaternion(Vector3.RIGHT, pitch) *
            Quaternion(Vector3.UP, yaw))
        # T(anchor) * R * T(-anchor) * rest; the root remains attached to
        # the original Head bone even through carve and turbo-jump poses.
        var pivot: Vector3 = rest * anchor
        part.transform = Transform3D(rotation, pivot - rotation * pivot) * rest
