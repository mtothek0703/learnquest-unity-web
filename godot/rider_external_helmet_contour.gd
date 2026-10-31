extends RefCounted
## Sculpted sidewalls are part of the EXISTING helmet surface/draw call.
## They connect the upper crown silhouette to the jaw line without covering
## the eyes, and follow the genuine imported Head bone through its attachment.
## Geometry is procedural, self-contained, and uses no third-party asset.
const VERTICAL_STEPS := 18
const DEPTH_STEPS := 12
var _center: Vector3
var _size: Vector3
var _facing: float

func append_to(surface: SurfaceTool, center: Vector3, size: Vector3, face_sign: float) -> void:
    _center = center
    _size = size
    _facing = face_sign
    for side in [-1.0, 1.0]:
        for row in range(VERTICAL_STEPS):
            var t0 := float(row) / float(VERTICAL_STEPS)
            var t1 := float(row + 1) / float(VERTICAL_STEPS)
            for column in range(DEPTH_STEPS):
                var u0 := float(column) / float(DEPTH_STEPS)
                var u1 := float(column + 1) / float(DEPTH_STEPS)
                for outer in [true, false]:
                    _quad(surface,
                        _point(center, size, face_sign, side, t0, u0, outer),
                        _point(center, size, face_sign, side, t1, u0, outer),
                        _point(center, size, face_sign, side, t1, u1, outer),
                        _point(center, size, face_sign, side, t0, u1, outer),
                        Vector3(side if outer else -side, 0.0, 0.0))
        # Close front/back edges and crown/jaw rims. No single-sided sheets.
        for row in range(VERTICAL_STEPS):
            var t0 := float(row) / float(VERTICAL_STEPS)
            var t1 := float(row + 1) / float(VERTICAL_STEPS)
            for u in [0.0, 1.0]:
                _quad(surface,
                    _point(center, size, face_sign, side, t0, u, true),
                    _point(center, size, face_sign, side, t1, u, true),
                    _point(center, size, face_sign, side, t1, u, false),
                    _point(center, size, face_sign, side, t0, u, false),
                    Vector3(0.0, 0.0, face_sign if u > 0.5 else -face_sign))
        for column in range(DEPTH_STEPS):
            var u0 := float(column) / float(DEPTH_STEPS)
            var u1 := float(column + 1) / float(DEPTH_STEPS)
            for t in [0.0, 1.0]:
                _quad(surface,
                    _point(center, size, face_sign, side, t, u0, true),
                    _point(center, size, face_sign, side, t, u1, true),
                    _point(center, size, face_sign, side, t, u1, false),
                    _point(center, size, face_sign, side, t, u0, false),
                    Vector3(0.0, 1.0 if t < 0.5 else -1.0, 0.0))

func _point(c: Vector3, s: Vector3, facing: float, side: float,
        t: float, u: float, outer: bool) -> Vector3:
    # The sidewalls are behind the eyes and follow a tapered cheek/jaw
    # contour, rather than protruding as separate box-like ear decorations.
    # Athletic cheek/temple taper: the lower edge hugs the original jaw,
    # rather than creating the broad squared-off mobile silhouette.
    var shell := 0.552 + 0.016 * sin(PI * t) - 0.165 * t * t
    var thickness := 0.025 if outer else -0.015
    var jaw_taper := smoothstep(0.0, 1.0, t)
    var depth := -0.14 + (0.40 * (1.0 - 0.80 * jaw_taper)) * u + \
        0.018 * sin(PI * t) * sin(PI * u)
    return Vector3(
        c.x + side * s.x * (shell + thickness),
        c.y + s.y * (0.35 - 0.59 * t + 0.014 * sin(PI * u) * sin(PI * t)),
        c.z + facing * s.z * depth)

func _vertex_normal(vertex: Vector3) -> Vector3:
    # Identical shared positions get identical normals across every panel,
    # including closed edge rims. This avoids visible mobile-lighting seams.
    var side := -1.0 if vertex.x < _center.x else 1.0
    var t := clampf((0.35 - (vertex.y - _center.y) / _size.y) / 0.59, 0.0, 1.0)
    var shell := 0.552 + 0.016 * sin(PI * t) - 0.165 * t * t
    var outer := absf(vertex.x - _center.x) / _size.x > shell + 0.004
    return Vector3(side * (1.0 if outer else -1.0),
        0.10 * (0.5 - t), _facing * (0.12 if outer else -0.12)).normalized()

func _quad(surface: SurfaceTool, a: Vector3, b: Vector3,
        c: Vector3, d: Vector3, expected: Vector3) -> void:
    var geometric := (b - a).cross(c - a).normalized()
    if geometric.dot(expected) < 0.0:
        var swap := b
        b = d
        d = swap
    for vertex in [a, b, c, a, c, d]:
        surface.set_normal(_vertex_normal(vertex))
        surface.add_vertex(vertex)
