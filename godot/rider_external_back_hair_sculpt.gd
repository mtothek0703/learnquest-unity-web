extends RefCounted
## V124 visual study: one continuous five-channel sculpted rear hair shell.
## Procedural CC0-compatible original geometry; no textures, extra nodes or
## physics. This deforms the EXISTING Head-bone-bound closed curtain surface.
const CHANNELS := 5

func channel_count() -> int:
    return CHANNELS

func ridge(t: float, u: float) -> float:
    var height := sin(PI * clampf(t, 0.0, 1.0))
    var flow := u + 0.018 * height + 0.009 * t * t
    var wave := -cos(TAU * float(CHANNELS) * flow)
    return pow(maxf(0.0, wave), 2.0) * height

func sculpt(point: Vector3, size: Vector3, face_sign: float,
        t: float, u: float, outer: bool) -> Vector3:
    # The five raised streams travel across a continuous double-wall shell,
    # not five disconnected parallel strips. Preserve the inner wall depth.
    var crest := ridge(t, u)
    var taper := sin(PI * t)
    var depth := size.z * (0.105 * crest +
        0.018 * taper * sin(TAU * (1.5 * u + 0.30 * t)))
    var result := point
    result.z -= face_sign * depth * (1.0 if outer else 0.16)
    result.x += size.x * 0.024 * taper * sin(TAU * (u + 0.27 * t))
    result.y += size.y * 0.018 * taper * cos(TAU * float(CHANNELS) * u)
    return result

func tone(t: float, u: float, outer: bool) -> Color:
    # Vertex-painted soft highlights follow the actual sculpted ridges.
    # Multiply the existing matte chestnut material; no texture or shader pass.
    var highlight := ridge(t, u) if outer else 0.0
    var root_shadow := 0.12 * (1.0 - smoothstep(0.0, 0.32, t))
    var tip_shadow := 0.08 * smoothstep(0.78, 1.0, t)
    var value := 0.79 + 0.20 * highlight - root_shadow - tip_shadow
    return Color(value, value * (0.96 + 0.035 * highlight),
        value * (0.94 + 0.020 * highlight), 1.0)
