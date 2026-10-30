extends Node3D
## V83: lightweight cinematic ion wake behind the playable hoverboard.
## Original procedural meshes only. No collisions, textures, shaders or downloads.
## Four curved translucent plasma ribbons and twelve moving sparks are visible
## from the 16:9 chase camera; Turbo stretches them without changing physics.

const RIBBON_STEPS := 32
const SPARKS_PER_SIDE := 6

var elapsed := 0.0
var wake_roots: Array[Node3D] = []
var sparks: Array[MeshInstance3D] = []
var engine_light: OmniLight3D

func _ready() -> void:
    var halo_material := _plasma_material(Color(0.07, 0.78, 1.0), 1.35)
    var core_material := _plasma_material(Color(1.0, 0.29, 0.83), 1.8)
    var spark_material := StandardMaterial3D.new()
    spark_material.albedo_color = Color("#fff1b9")
    spark_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    spark_material.emission_enabled = true
    spark_material.emission = Color("#9efcff")
    spark_material.emission_energy_multiplier = 2.2
    var spark_mesh := SphereMesh.new()
    spark_mesh.radius = 1.0
    spark_mesh.height = 2.0
    spark_mesh.radial_segments = 8
    spark_mesh.rings = 4

    for side in [-1.0, 1.0]:
        var root := Node3D.new()
        root.name = "Ion wake left" if side < 0.0 else "Ion wake right"
        root.position = Vector3(side * 0.51, 0.18, 1.54)
        root.scale.z = 0.38
        add_child(root)
        wake_roots.append(root)

        var halo := MeshInstance3D.new()
        halo.name = "Translucent curved plasma"
        halo.mesh = _ribbon_mesh(side, 0.34, 0.56)
        halo.material_override = halo_material
        root.add_child(halo)

        var core := MeshInstance3D.new()
        core.name = "Bright sculpted ion core"
        core.mesh = _ribbon_mesh(side, 0.095, 0.88)
        core.material_override = core_material
        core.position.y = 0.016
        root.add_child(core)

        for index in range(SPARKS_PER_SIDE):
            var spark := MeshInstance3D.new()
            spark.name = "Moving ion spark %d" % index
            spark.mesh = spark_mesh
            spark.material_override = spark_material
            # Initialize to the same safe idle dimensions as _process().
            # Previously each radius-1 sphere rendered at scale 1 until its
            # first process tick, forming enormous cream-colored foreground
            # blobs that hid the board in pose-locked chase screenshots and
            # could flash during the first frame on a slow mobile device.
            var initial_progress := float(index) / float(SPARKS_PER_SIDE)
            spark.position = _plasma_point(side, initial_progress, 0.0, 0.1) + Vector3(0.0, 0.07, 0.0)
            spark.scale = Vector3.ONE * (0.055 * (1.0 - initial_progress * 0.65))
            root.add_child(spark)
            sparks.append(spark)

    engine_light = OmniLight3D.new()
    engine_light.name = "Pulsing cinematic engine light"
    engine_light.position = Vector3(0.0, 0.27, 1.45)
    engine_light.light_color = Color("#6cecff")
    engine_light.light_energy = 0.65
    engine_light.omni_range = 3.0
    engine_light.shadow_enabled = false
    add_child(engine_light)

func _plasma_material(tint: Color, energy: float) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = Color(1.0, 1.0, 1.0, 0.86)
    material.vertex_color_use_as_albedo = true
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    material.emission_enabled = true
    material.emission = tint
    material.emission_energy_multiplier = energy
    return material

func _plasma_point(side: float, t: float, across: float, width: float) -> Vector3:
    # Trails flare outward rather than covering the character in the chase view.
    var bend := side * (0.08 + 0.66 * t * t)
    var flutter := sin(t * TAU * 1.3) * 0.085 * t
    return Vector3(
        bend + across * width * (1.0 - t * 0.62) + side * flutter,
        -0.015 + 0.11 * sin(t * TAU * 1.2) - 0.10 * t,
        4.1 * t
    )

func _ribbon_mesh(side: float, width: float, opacity: float) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for step in range(RIBBON_STEPS):
        var t0 := float(step) / float(RIBBON_STEPS)
        var t1 := float(step + 1) / float(RIBBON_STEPS)
        var a := _plasma_point(side, t0, -1.0, width)
        var b := _plasma_point(side, t0, 1.0, width)
        var c := _plasma_point(side, t1, 1.0, width)
        var d := _plasma_point(side, t1, -1.0, width)
        var start_tint := Color(0.55, 0.98, 1.0, opacity * pow(1.0 - t0, 1.35))
        var end_tint := Color(1.0, 0.38, 0.87, opacity * pow(1.0 - t1, 1.35))
        _vertex(tool, a, start_tint)
        _vertex(tool, b, start_tint)
        _vertex(tool, c, end_tint)
        _vertex(tool, a, start_tint)
        _vertex(tool, c, end_tint)
        _vertex(tool, d, end_tint)
    tool.generate_normals()
    return tool.commit()

func _vertex(tool: SurfaceTool, point: Vector3, tint: Color) -> void:
    tool.set_color(tint)
    tool.add_vertex(point)

func _process(delta: float) -> void:
    elapsed += delta
    var legacy := get_parent().get_parent() as Node3D
    var boosting := bool(legacy.get("boosting")) if legacy != null else false
    var steering := float(legacy.get("lean")) if legacy != null else 0.0
    var length_target := 1.0 if boosting else 0.38
    for index in range(wake_roots.size()):
        var root := wake_roots[index]
        var side := -1.0 if index == 0 else 1.0
        root.scale.z = lerpf(root.scale.z, length_target, minf(1.0, delta * 10.0))
        root.rotation.y = side * sin(elapsed * (11.0 if boosting else 4.0) + float(index)) * 0.045 + steering * 0.035
        root.scale.x = 1.0 + 0.065 * sin(elapsed * (16.0 if boosting else 6.0) + float(index))
    for index in range(sparks.size()):
        var spark := sparks[index]
        var side := -1.0 if index < SPARKS_PER_SIDE else 1.0
        var phase := float(index % SPARKS_PER_SIDE) / float(SPARKS_PER_SIDE)
        var progress := fposmod(elapsed * (0.75 if boosting else 0.31) + phase, 1.0)
        spark.position = _plasma_point(side, progress, 0.0, 0.1) + Vector3(0.0, 0.07, 0.0)
        var size := (0.10 if boosting else 0.055) * (1.0 - progress * 0.65)
        spark.scale = Vector3.ONE * size
    engine_light.light_energy = lerpf(engine_light.light_energy, 1.8 if boosting else 0.65, minf(1.0, delta * 8.0))
