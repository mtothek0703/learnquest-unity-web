extends Node3D
## V88: mobile-friendly cinematic rider lighting and projected ground contact.
## All meshes are generated locally; no textures, physics bodies or touch input.
## The dark soft shadow anchors the board while colored edge lighting and
## speed ribbons emphasize motion without obscuring the 16:9 playfield.

const SEGMENTS := 64
const STREAK_STEPS := 30

var rider: Node3D
var shadow_disc: MeshInstance3D
var energy_halo: MeshInstance3D
var rim_light: OmniLight3D
var speed_ribbons: Array[MeshInstance3D] = []
var clock: float = 0.0
var world_tints: Array[Color] = [
    Color("#65eaff"), Color("#ffb25e"), Color("#8d9cff"), Color("#8dffdb")
]

func _ready() -> void:
    var shadow_mat := StandardMaterial3D.new()
    shadow_mat.albedo_color = Color.WHITE
    shadow_mat.vertex_color_use_as_albedo = true
    shadow_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    shadow_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    shadow_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
    shadow_disc = MeshInstance3D.new()
    shadow_disc.name = "Soft projected hoverboard shadow"
    shadow_disc.mesh = _make_ground_disc(false)
    shadow_disc.material_override = shadow_mat
    shadow_disc.position.y = -0.042
    add_child(shadow_disc)

    var glow_mat := StandardMaterial3D.new()
    glow_mat.albedo_color = Color.WHITE
    glow_mat.vertex_color_use_as_albedo = true
    glow_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    glow_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    glow_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
    glow_mat.emission_enabled = true
    glow_mat.emission = Color("#66eaff")
    glow_mat.emission_energy_multiplier = 1.35
    energy_halo = MeshInstance3D.new()
    energy_halo.name = "Layered hoverboard ground glow"
    energy_halo.mesh = _make_ground_disc(true)
    energy_halo.material_override = glow_mat
    energy_halo.position.y = -0.039
    add_child(energy_halo)

    var ribbon_mat := StandardMaterial3D.new()
    ribbon_mat.albedo_color = Color.WHITE
    ribbon_mat.vertex_color_use_as_albedo = true
    ribbon_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    ribbon_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    ribbon_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
    ribbon_mat.emission_enabled = true
    ribbon_mat.emission = Color("#6eefff")
    ribbon_mat.emission_energy_multiplier = 1.8
    for side in [-1.0, 1.0]:
        var ribbon := MeshInstance3D.new()
        ribbon.name = "Left cinematic ground speed ribbon" if side < 0.0 else "Right cinematic ground speed ribbon"
        ribbon.mesh = _make_speed_ribbon(side)
        ribbon.material_override = ribbon_mat
        ribbon.visible = false
        add_child(ribbon)
        speed_ribbons.append(ribbon)

    rim_light = OmniLight3D.new()
    rim_light.name = "Dynamic colored rider rim light"
    rim_light.light_color = world_tints[0]
    rim_light.light_energy = 1.15
    rim_light.omni_range = 5.2
    rim_light.shadow_enabled = false
    rim_light.position = Vector3(1.65, 2.75, 1.5)
    add_child(rim_light)

func _disc_vertex(tool: SurfaceTool, point: Vector3, tint: Color) -> void:
    tool.set_color(tint)
    tool.add_vertex(point)

func _make_ground_disc(glowing: bool) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for band in range(3):
        var inner: float = float(band) / 3.0
        var outer: float = float(band + 1) / 3.0
        var inner_alpha: float = 0.0
        var outer_alpha: float = 0.0
        if glowing:
            inner_alpha = [0.0, 0.06, 0.36][band]
            outer_alpha = [0.06, 0.36, 0.0][band]
        else:
            inner_alpha = [0.48, 0.34, 0.13][band]
            outer_alpha = [0.34, 0.13, 0.0][band]
        var tint := Color("#67edff") if glowing else Color("#050918")
        for segment in range(SEGMENTS):
            var a0 := TAU * float(segment) / float(SEGMENTS)
            var a1 := TAU * float(segment + 1) / float(SEGMENTS)
            var x_radius := 1.85 if glowing else 1.18
            var z_radius := 2.15 if glowing else 1.55
            var a := Vector3(cos(a0) * inner * x_radius, 0.0, sin(a0) * inner * z_radius)
            var b := Vector3(cos(a1) * inner * x_radius, 0.0, sin(a1) * inner * z_radius)
            var c := Vector3(cos(a1) * outer * x_radius, 0.0, sin(a1) * outer * z_radius)
            var d := Vector3(cos(a0) * outer * x_radius, 0.0, sin(a0) * outer * z_radius)
            _disc_vertex(tool, a, Color(tint.r, tint.g, tint.b, inner_alpha))
            _disc_vertex(tool, b, Color(tint.r, tint.g, tint.b, inner_alpha))
            _disc_vertex(tool, c, Color(tint.r, tint.g, tint.b, outer_alpha))
            _disc_vertex(tool, a, Color(tint.r, tint.g, tint.b, inner_alpha))
            _disc_vertex(tool, c, Color(tint.r, tint.g, tint.b, outer_alpha))
            _disc_vertex(tool, d, Color(tint.r, tint.g, tint.b, outer_alpha))
    return tool.commit()

func _ribbon_point(side: float, t: float, edge: float) -> Vector3:
    var width := 0.15 * (1.0 - t * 0.8)
    return Vector3(side * (0.78 + t * 0.36) + edge * width, -0.036, 0.55 + 4.25 * t)

func _make_speed_ribbon(side: float) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for step in range(STREAK_STEPS):
        var t0 := float(step) / float(STREAK_STEPS)
        var t1 := float(step + 1) / float(STREAK_STEPS)
        var start := Color(0.45, 0.95, 1.0, 0.85 * (1.0 - t0))
        var finish := Color(1.0, 0.34, 0.83, 0.85 * (1.0 - t1))
        _disc_vertex(tool, _ribbon_point(side, t0, -1.0), start)
        _disc_vertex(tool, _ribbon_point(side, t0, 1.0), start)
        _disc_vertex(tool, _ribbon_point(side, t1, 1.0), finish)
        _disc_vertex(tool, _ribbon_point(side, t0, -1.0), start)
        _disc_vertex(tool, _ribbon_point(side, t1, 1.0), finish)
        _disc_vertex(tool, _ribbon_point(side, t1, -1.0), finish)
    return tool.commit()

func _process(delta: float) -> void:
    if not is_instance_valid(rider):
        return
    var game := get_parent()
    var racing: bool = str(game.get("phase")) == "race" and bool(game.get("started")) and not bool(game.get("quiz_active"))
    update_visuals(delta, rider.position, int(game.get("world_choice")), maxf(0.0, rider.position.y), bool(rider.get("boosting")), racing)

func update_visuals(delta: float, rider_position: Vector3, world_index: int, jump_height: float, turbo: bool, racing: bool) -> void:
    clock += delta
    position.x = rider_position.x
    position.z = rider_position.z
    # Ground projection never rises with the jumping rider.
    position.y = 0.0
    shadow_disc.transparency = clampf(jump_height / 2.8, 0.0, 0.83)
    shadow_disc.scale = Vector3.ONE * (1.0 + jump_height * 0.16)
    energy_halo.scale = Vector3.ONE * (1.0 + (0.38 if turbo and racing else 0.0) + jump_height * 0.08)
    energy_halo.transparency = clampf(0.12 + jump_height * 0.22, 0.0, 0.75)
    var tint: Color = world_tints[clampi(world_index, 0, world_tints.size() - 1)]
    rim_light.light_color = tint
    rim_light.position = Vector3(1.65, 2.75 + jump_height, 1.5)
    rim_light.light_energy = 2.2 if turbo and racing else 1.15
    for index in range(speed_ribbons.size()):
        var ribbon := speed_ribbons[index]
        ribbon.visible = turbo and racing
        ribbon.scale.z = 1.0 + 0.12 * sin(clock * 16.0 + float(index)) if ribbon.visible else 1.0
