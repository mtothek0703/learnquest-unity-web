extends Node3D
## V124 draft: two continuous, tapered, volumetric energy wakes behind the
## existing sculpted hoverboard turbines. Original procedural geometry; no
## third-party assets, collision, touch, physics or game-rule modifications.
const LENGTH_STEPS := 40
const RING_STEPS := 12
var wake_meshes: Array[MeshInstance3D] = []
var wake_materials: Array[StandardMaterial3D] = []
var intensity: float = 0.0

func _ready() -> void:
    for side in [-1.0, 1.0]:
        var material := StandardMaterial3D.new()
        material.albedo_color = Color.WHITE
        material.vertex_color_use_as_albedo = true
        material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
        material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
        material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
        material.cull_mode = BaseMaterial3D.CULL_DISABLED
        material.emission_enabled = true
        material.emission = Color("#28d6ff") if side < 0.0 else Color("#ad75ff")
        material.emission_energy_multiplier = 0.0
        var part := MeshInstance3D.new()
        part.name = "PortVolumetricWake" if side < 0.0 else "StarboardVolumetricWake"
        part.mesh = _make_wake(side)
        part.material_override = material
        part.visible = false
        add_child(part)
        wake_meshes.append(part)
        wake_materials.append(material)

func _point(side: float, t: float, angle: float) -> Vector3:
    # Real chase-camera QA exposed oversized, balloon-like exhaust lobes.
    # Keep the original nozzle position but sculpt two slim, low-overdraw
    # ion jets with tighter flare, softer opacity and a cleaner taper.
    # Shorten the rear-chase trail so perspective does not blow it up into
    # a giant sheet that runs past the lower edge of a phone viewport.
    var taper := pow(maxf(0.0, 1.0 - t), 0.92)
    var flare := sin(PI * t)
    var radius_x := (0.075 + 0.10 * flare) * taper + 0.004
    var radius_y := (0.045 + 0.06 * flare) * taper + 0.004
    var sweep := 0.06 * sin(t * PI * 1.6)
    return Vector3(side * (0.88 + sweep + radius_x * cos(angle)),
        0.24 + 0.055 * sin(t * TAU) + radius_y * sin(angle),
        1.58 + 0.95 * t)

# Three intertwined luminous filaments are encoded in the existing tube's
# vertex alpha. The same two meshes/draw calls now read as coherent thruster
# energy rather than broad, evenly translucent plastic sheets.
func _opacity(t: float, angle: float) -> float:
    var phase := 3.0 * angle + t * TAU * 2.0
    var filament := pow(maxf(0.0, cos(phase)), 6.0)
    return (0.045 + 0.30 * filament) * pow(maxf(0.0, 1.0 - t), 1.3)

func _emit(tool: SurfaceTool, side: float, t: float, angle: float) -> void:
    var point := _point(side, t, angle)
    var root := Color("#37dfff") if side < 0.0 else Color("#8e8dff")
    var tip := Color("#c7f5ff") if side < 0.0 else Color("#efb5ff")
    var color := root.lerp(tip, smoothstep(0.15, 0.90, t))
    color.a = _opacity(t, angle)
    tool.set_color(color)
    tool.set_normal(Vector3(side * cos(angle), sin(angle), 0.05).normalized())
    tool.add_vertex(point)

func _make_wake(side: float) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for i in range(LENGTH_STEPS):
        var a := float(i) / float(LENGTH_STEPS)
        var b := float(i + 1) / float(LENGTH_STEPS)
        for j in range(RING_STEPS):
            var u := TAU * float(j) / float(RING_STEPS)
            var v := TAU * float(j + 1) / float(RING_STEPS)
            _emit(tool, side, a, u)
            _emit(tool, side, b, u)
            _emit(tool, side, b, v)
            _emit(tool, side, a, u)
            _emit(tool, side, b, v)
            _emit(tool, side, a, v)
    return tool.commit()

func _process(delta: float) -> void:
    # This is cosmetic: the original LegacyRider still owns acceleration,
    # steering, hover and the already-confirmed landscape touch interpreter.
    var controller := get_parent().get_parent().get_parent() as Node3D
    if controller == null:
        return
    var boost := bool(controller.get("boosting"))
    var response := 1.0 - exp(-10.0 * maxf(delta, 0.0))
    intensity = lerpf(intensity, 1.0 if boost else 0.0, response)
    var carve := clampf(float(controller.get("lean")), -1.0, 1.0)
    for i in range(wake_meshes.size()):
        var side := -1.0 if i == 0 else 1.0
        var part := wake_meshes[i]
        part.visible = intensity > 0.035
        part.transparency = clampf(1.0 - intensity * 0.92, 0.08, 1.0)
        # The outside engine works harder while carving: its actual 3D wake
        # extends farther and fans wider, rather than only changing color.
        # Keep the first wake ring fixed at the existing 1.58m exhaust plane
        # while scaling the already-uploaded mesh (no per-frame mesh rebuild).
        var outside := maxf(0.0, side * carve)
        var trail_length := 0.75 + 0.25 * intensity + 0.30 * outside * intensity
        part.scale = Vector3(1.0 + 0.20 * outside * intensity,
            1.0 + 0.12 * outside * intensity, trail_length)
        part.position.z = 1.58 * (1.0 - trail_length)
        part.position.x = carve * 0.08
        wake_materials[i].emission_energy_multiplier = intensity * (
            2.3 + outside * 0.75)
