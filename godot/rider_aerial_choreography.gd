extends Node3D
## V87: cinematic jump wind ribbons and a radial landing spark burst.
## Procedural low-cost meshes only; no collision, touch handling or external assets.
## Both effects sit beside the rider in the 16:9 chase view, never over the HUD.

const ARC_STEPS := 28
const SPARK_COUNT := 12

var clock: float = 0.0
var air_weight: float = 0.0
var landing_energy: float = 0.0
var was_airborne: bool = false
var arcs: Array[MeshInstance3D] = []
var sparks: Array[MeshInstance3D] = []
var landing_light: OmniLight3D

func _ready() -> void:
    var arc_material := StandardMaterial3D.new()
    arc_material.albedo_color = Color(1.0, 1.0, 1.0, 0.82)
    arc_material.vertex_color_use_as_albedo = true
    arc_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    arc_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    arc_material.cull_mode = BaseMaterial3D.CULL_DISABLED
    arc_material.emission_enabled = true
    arc_material.emission = Color("#57dfff")
    arc_material.emission_energy_multiplier = 1.6
    for side in [-1.0, 1.0]:
        var arc := MeshInstance3D.new()
        arc.name = "Left sculpted aerial ribbon" if side < 0.0 else "Right sculpted aerial ribbon"
        arc.mesh = _build_arc(side)
        arc.material_override = arc_material
        arc.visible = false
        add_child(arc)
        arcs.append(arc)

    var spark_material := StandardMaterial3D.new()
    spark_material.albedo_color = Color("#ffe5c6")
    spark_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    spark_material.emission_enabled = true
    spark_material.emission = Color("#9efaff")
    spark_material.emission_energy_multiplier = 2.0
    var spark_mesh := PrismMesh.new()
    spark_mesh.size = Vector3(0.14, 0.12, 0.42)
    for index in range(SPARK_COUNT):
        var spark := MeshInstance3D.new()
        spark.name = "Landing energy shard %d" % index
        spark.mesh = spark_mesh
        spark.material_override = spark_material
        spark.visible = false
        add_child(spark)
        sparks.append(spark)

    landing_light = OmniLight3D.new()
    landing_light.name = "Soft cinematic landing flash"
    landing_light.position = Vector3(0.0, 0.4, 0.0)
    landing_light.light_color = Color("#7eefff")
    landing_light.light_energy = 0.0
    landing_light.omni_range = 4.5
    landing_light.shadow_enabled = false
    add_child(landing_light)

func _arc_point(side: float, t: float, across: float) -> Vector3:
    # An arched, tapered 3D windstream starts at each shoulder and fans outward
    # behind the character instead of obscuring its silhouette or the road.
    var sweep := 0.63 + 1.18 * sin(t * PI * 0.72)
    var width := 0.20 * (1.0 - t * 0.75)
    return Vector3(
        side * sweep + across * width,
        1.48 + 0.60 * sin(t * PI) - t * 0.56 + across * 0.035,
        0.35 + 3.35 * t
    )

func _arc_vertex(tool: SurfaceTool, point: Vector3, tint: Color) -> void:
    tool.set_color(tint)
    tool.add_vertex(point)

func _build_arc(side: float) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for step in range(ARC_STEPS):
        var t0 := float(step) / float(ARC_STEPS)
        var t1 := float(step + 1) / float(ARC_STEPS)
        var a := _arc_point(side, t0, -1.0)
        var b := _arc_point(side, t0, 1.0)
        var c := _arc_point(side, t1, 1.0)
        var d := _arc_point(side, t1, -1.0)
        var start_tint := Color(0.38, 0.95, 1.0, 0.82 * pow(1.0 - t0, 1.25))
        var end_tint := Color(1.0, 0.38, 0.90, 0.82 * pow(1.0 - t1, 1.25))
        _arc_vertex(tool, a, start_tint)
        _arc_vertex(tool, b, start_tint)
        _arc_vertex(tool, c, end_tint)
        _arc_vertex(tool, a, start_tint)
        _arc_vertex(tool, c, end_tint)
        _arc_vertex(tool, d, end_tint)
    tool.generate_normals()
    return tool.commit()

func _process(delta: float) -> void:
    var rider := get_parent() as Node3D
    if rider == null:
        return
    update_visuals(delta, maxf(0.0, rider.position.y), float(rider.get("lean")), bool(rider.get("boosting")))

func update_visuals(delta: float, jump_height: float, steering: float, turbo: bool) -> void:
    clock += delta
    var airborne := jump_height > 0.12
    if was_airborne and not airborne:
        landing_energy = 1.0
    was_airborne = airborne
    air_weight = lerpf(air_weight, clampf(jump_height / 1.25, 0.0, 1.0), minf(1.0, delta * 8.0))
    landing_energy = maxf(0.0, landing_energy - delta * 2.4)

    for index in range(arcs.size()):
        var arc := arcs[index]
        var side := -1.0 if index == 0 else 1.0
        arc.visible = air_weight > 0.035
        arc.scale = Vector3(0.50 + 0.50 * air_weight, 1.0, 0.30 + 0.75 * air_weight)
        arc.position.y = 0.05 * sin(clock * (12.0 if turbo else 6.0) + float(index))
        arc.rotation.y = steering * 0.08 + side * sin(clock * 4.0) * 0.045

    var burst_progress := 1.0 - landing_energy
    for index in range(sparks.size()):
        var spark := sparks[index]
        spark.visible = landing_energy > 0.02
        var angle := TAU * float(index) / float(SPARK_COUNT)
        var radius := 0.55 + burst_progress * 3.2
        spark.position = Vector3(
            cos(angle) * radius,
            0.16 + sin(burst_progress * PI) * 0.52,
            sin(angle) * radius
        )
        spark.rotation = Vector3(0.0, angle, burst_progress * 1.8)
        spark.scale = Vector3.ONE * maxf(0.05, 0.75 - burst_progress * 0.68)
    landing_light.light_energy = landing_energy * 1.25
