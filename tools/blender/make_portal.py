"""Procedural, original Blender portal asset for LearnQuest 3D (no external assets).

Runs headlessly in a GitHub Actions Linux runner. All geometry is created locally
with Blender's bpy API. Outputs a Godot-compatible GLB, editable BLEND, and PNG.
"""
import argparse
import json
import math
from pathlib import Path
import sys

import bpy
from mathutils import Vector


def arguments():
    raw = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    parser = argparse.ArgumentParser()
    parser.add_argument("--output-dir", type=Path, default=Path("out/blender"))
    return parser.parse_args(raw)


def material(name, color, metallic=0.0, roughness=0.65, emission=None):
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = (*color, 1.0)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = (*color, 1.0)
    bsdf.inputs["Metallic"].default_value = metallic
    bsdf.inputs["Roughness"].default_value = roughness
    if emission is not None:
        bsdf.inputs["Emission Color"].default_value = (*emission, 1.0)
        bsdf.inputs["Emission Strength"].default_value = 2.5
    return mat


def bevel(obj, width=0.07, segments=2):
    modifier = obj.modifiers.new("Soft edges", "BEVEL")
    modifier.width = width
    modifier.segments = segments
    obj.modifiers.new("Weighted normals", "WEIGHTED_NORMAL")


def cube(name, pos, scale, mat, bevel_width=0.04):
    bpy.ops.mesh.primitive_cube_add(size=1, location=pos)
    obj = bpy.context.object
    obj.name = name
    obj.dimensions = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(mat)
    if bevel_width:
        bevel(obj, bevel_width)
    asset.append(obj)
    return obj


def cylinder(name, pos, radius, depth, mat, vertices=32):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radius, depth=depth, location=pos)
    obj = bpy.context.object
    obj.name = name
    obj.data.materials.append(mat)
    bevel(obj, 0.04, 2)
    asset.append(obj)
    return obj


def torus(name, pos, major, minor, mat):
    bpy.ops.mesh.primitive_torus_add(
        major_segments=48, minor_segments=12,
        location=pos, rotation=(math.pi / 2, 0.0, 0.0),
        major_radius=major, minor_radius=minor)
    obj = bpy.context.object
    obj.name = name
    obj.data.materials.append(mat)
    asset.append(obj)
    return obj


def point_at(obj, target):
    direction = Vector(target) - obj.location
    obj.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()


args = arguments()
out = args.output_dir.resolve()
out.mkdir(parents=True, exist_ok=True)
bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)
asset = []
stone = material("Portal | violet stone", (0.18, 0.13, 0.30), roughness=0.82)
trim = material("Portal | polished lavender", (0.45, 0.31, 0.65), metallic=0.20)
core = material("Portal | luminous teal", (0.04, 0.62, 0.80), roughness=0.22,
                emission=(0.08, 0.55, 0.85))
gold = material("Portal | copper detail", (0.82, 0.52, 0.22), metallic=0.62, roughness=0.30)
ground = material("Preview only | muted ground", (0.82, 0.81, 0.87))

# Portal faces the camera at negative Y, with Z up (Blender uses Z-up).
cube("Pedestal | lower stone step", (0, 0.0, 0.14), (3.8, 1.9, 0.28), stone)
cube("Pedestal | lavender step", (0, 0.0, 0.37), (3.3, 1.55, 0.19), trim)
cube("Pedestal | portal threshold", (0, 0.03, 0.52), (2.5, 0.97, 0.14), stone)

# Major torus diameter 2.95, center Z 2.18: overall height about 3.7 m.
torus("Portal | outer ring", (0, 0.10, 2.20), 1.43, 0.22, stone)
torus("Portal | gold inset ring", (0, -0.13, 2.20), 1.19, 0.055, gold)
torus("Portal | glowing inner ring", (0, -0.19, 2.20), 1.08, 0.055, core)

# A visible disc for the portal's energy; placed behind the rings.
disc = cylinder("Portal | energy field", (0, 0.16, 2.20), 1.06, 0.035, core, vertices=64)
disc.rotation_euler = (math.pi / 2, 0.0, 0.0)

# Stylized keystones along the circular ring.
for index in range(12):
    angle = (2 * math.pi * index / 12) + (math.pi / 12)
    x = 1.43 * math.sin(angle)
    z = 2.20 + 1.43 * math.cos(angle)
    block = cube("Ring stone %02d" % (index + 1), (x, -0.025, z),
                 (0.30, 0.33, 0.24), trim if index % 3 == 0 else stone, 0.055)
    block.rotation_euler[1] = angle

# Two sculptural side pylons.
for side in (-1, 1):
    cube("Side pillar %s" % side, (side * 1.70, 0.10, 0.92),
         (0.54, 0.65, 1.53), stone, 0.08)
    cube("Pillar cap %s" % side, (side * 1.70, 0.10, 1.71),
         (0.70, 0.72, 0.15), trim, 0.05)
    cube("Pillar beacon %s" % side, (side * 1.70, -0.27, 1.30),
         (0.24, 0.09, 0.40), core, 0.03)

# Export only art meshes; preview ground/camera/lights must not enter Godot.
bpy.ops.object.select_all(action="DESELECT")
for obj in asset:
    obj.select_set(True)
bpy.context.view_layer.objects.active = asset[0]
glb_path = out / "learnquest_portal.glb"
bpy.ops.export_scene.gltf(filepath=str(glb_path), export_format="GLB",
                          use_selection=True, export_yup=True, export_cameras=False,
                          export_lights=False, export_animations=False)

# Keep a fully editable native Blender document for future iterations.
blend_path = out / "learnquest_portal.blend"
bpy.ops.wm.save_as_mainfile(filepath=str(blend_path))

# A simple studio render makes the output easy to judge in the browser.
bpy.ops.mesh.primitive_plane_add(size=200, location=(0, 0, -0.02))
floor = bpy.context.object
floor.name = "Preview floor (not part of exported model)"
floor.data.materials.append(ground)
bpy.ops.object.camera_add(location=(5.2, -8.3, 5.3))
cam = bpy.context.object
point_at(cam, (0, 0.0, 1.85))
cam.data.type = "ORTHO"
cam.data.ortho_scale = 6.8
bpy.context.scene.camera = cam
for pos, power, size in [((2, -4, 7), 750, 5.0), ((-5, -3, 3), 460, 4.0)]:
    bpy.ops.object.light_add(type="AREA", location=pos)
    light = bpy.context.object
    light.data.energy = power
    light.data.shape = "DISK"
    light.data.size = size
    point_at(light, (0, 0, 1.8))
scene = bpy.context.scene
scene.render.engine = "CYCLES"
scene.cycles.samples = 12
scene.render.threads_mode = "FIXED"
scene.render.threads = 2
scene.render.resolution_x = 640
scene.render.resolution_y = 440
scene.render.resolution_percentage = 100
scene.render.image_settings.file_format = "PNG"
scene.render.filepath = str(out / "portal_preview.png")
scene.world.color = (0.30, 0.28, 0.34)
bpy.ops.render.render(write_still=True)

manifest = {
    "name": "LearnQuest – Portal (prototype)",
    "license": "Original procedural geometry (no external models or textures)",
    "blender_version": bpy.app.version_string,
    "asset_objects": len(asset),
    "vertices": sum(len(obj.data.vertices) for obj in asset if obj.type == "MESH"),
    "exports": ["learnquest_portal.glb", "learnquest_portal.blend", "portal_preview.png"],
    "notes": "Static prototype; visual/rigging/gameplay QA required before use in release"
}
(out / "manifest.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")
print("BLENDER ASSET GENERATION PASSED:", manifest)
