extends RefCounted
## Derive lighting normals from the ACTUAL displaced, four-weight garment
## surface. The previous shells kept the source-body normals after sculpting,
## so raised pectorals, shin guards and boot toes shaded as flat skin.
## This runs once during mesh construction; no shader pass, asset or collider.

static func corrected(point: Vector3, source_normal: Vector3, bounds: AABB,
        offset: Callable) -> Vector3:
    var n := source_normal.normalized()
    if n.length_squared() < 0.5 or not offset.is_valid():
        return source_normal
    var tangent := n.cross(Vector3.UP if absf(n.y) < 0.88 else Vector3.FORWARD).normalized()
    var bitangent := n.cross(tangent).normalized()
    var step := clampf(bounds.size.y * 0.002, 0.001, 0.015)
    var pt := point + tangent * step
    var mt := point - tangent * step
    var pb := point + bitangent * step
    var mb := point - bitangent * step
    var dt: Vector3 = (pt + offset.call(pt, n, bounds)) - (mt + offset.call(mt, n, bounds))
    var db: Vector3 = (pb + offset.call(pb, n, bounds)) - (mb + offset.call(mb, n, bounds))
    var result := dt.cross(db).normalized()
    # Prevent a sharp relief from flipping a triangle's light-facing normal.
    if result.length_squared() < 0.5 or result.dot(n) < 0.55:
        return n
    return result
