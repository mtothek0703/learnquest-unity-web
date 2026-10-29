extends RefCounted
## Sculpted sidewalls are part of the EXISTING helmet surface/draw call.
## They connect the upper crown silhouette to the jaw line without covering
## the eyes, and follow the genuine imported Head bone through its attachment.
## Geometry is procedural, self-contained, and uses no third-party asset.
const VERTICAL_STEPS := 18
const DEPTH_STEPS := 12

func append_to(surface: SurfaceTool, center: Vector3, size: Vector3, face_sign: float) -> void:
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
    var shell := 0.560 + 0.023 * sin(PI * t)
    var thickness := 0.025 if outer else -0.015
    var depth := -0.14 + (0.46 - 0.16 * t) * u + 0.025 * sin(PI * t)
    return Vector3(
        c.x + side * s.x * (shell + thickness),
        c.y + s.y * (0.35 - 0.59 * t + 0.014 * sin(PI * u) * sin(PI * t)),
        c.z + facing * s.z * depth)

func _quad(surface: SurfaceTool, a: Vector3, b: Vector3,
        c: Vector3, d: Vector3, expected: Vector3) -> void:
    var normal := (b - a).cross(c - a).normalized()
    if normal.dot(expected) < 0.0:
        var swap := b
        b = d
        d = swap
        normal = -normal
    for vertex in [a, b, c, a, c, d]:
        surface.set_normal(normal)
        surface.add_vertex(vertex)
