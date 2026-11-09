"""LearnQuest original, mobile-budget animated 3D hero.

Blender-only procedural geometry; no external mesh, textures, license or API.
Usage: blender -b --factory-startup --python-exit-code 1 --python tools/blender/make_walk_hero.py -- --output-dir out/hero
Animation is a single skinned GLB timeline with fixed segments:
  idle 1..49, walk 49..97, sprint 97..145,
  jump 145..169, fall 169..193, land 193..217 (24 fps).
Godot controls segments; the same skeleton and original materials are retained.
"""
import argparse
import json
import math
from pathlib import Path
import sys

import bpy
from mathutils import Vector


def args():
    raw = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    p = argparse.ArgumentParser()
    p.add_argument("--output-dir", type=Path, default=Path("out/hero"))
    return p.parse_args(raw)


out = args().output_dir.resolve()
out.mkdir(parents=True, exist_ok=True)
bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)
bpy.context.scene.render.fps = 24
bpy.context.scene.frame_start = 1
bpy.context.scene.frame_end = 217


def mat(name, rgb, metallic=0.0, roughness=0.65, glow=0.0):
    m = bpy.data.materials.new(name)
    m.diffuse_color = (*rgb, 1.0)
    m.use_nodes = True
    p = m.node_tree.nodes.get("Principled BSDF")
    p.inputs["Base Color"].default_value = (*rgb, 1.0)
    p.inputs["Metallic"].default_value = metallic
    p.inputs["Roughness"].default_value = roughness
    if glow:
        p.inputs["Emission Color"].default_value = (*rgb, 1.0)
        p.inputs["Emission Strength"].default_value = glow
    return m


suit = mat("Deep navy flight suit", (0.038, 0.083, 0.175), roughness=0.78)
armor = mat("Pearl lilac molded armor", (0.58, 0.50, 0.86), metallic=0.12, roughness=0.37)
cyan = mat("Soft cyan illuminated seams", (0.10, 0.72, 0.91), roughness=0.31, glow=2.1)
boots = mat("Graphite soft boots and gloves", (0.075, 0.105, 0.17), roughness=0.77)
visor = mat("Opaque iridescent glass visor", (0.06, 0.17, 0.29), metallic=0.4, roughness=0.16)
accent = mat("Amber signature badge", (0.91, 0.43, 0.12), metallic=0.3, roughness=0.32)

# Designed with Blender Z-up; glTF converts Z-up to Godot Y-up.
# Facing Blender -Y == facing Godot -Z.
rig_data = bpy.data.armatures.new("LearnQuest Hero Skeleton")
rig = bpy.data.objects.new("LearnQuest Hero Rig", rig_data)
bpy.context.collection.objects.link(rig)
bpy.context.view_layer.objects.active = rig
rig.select_set(True)
bpy.ops.object.mode_set(mode="EDIT")
bones = [
    ("Root", (0, 0, 0.15), (0, 0, 0.42), None),
    ("Hips", (0, 0, 0.96), (0, 0, 1.16), "Root"),
    ("Spine", (0, 0, 1.15), (0, 0, 1.45), "Hips"),
    ("Chest", (0, 0, 1.43), (0, 0, 1.68), "Spine"),
    ("Neck", (0, 0, 1.68), (0, 0, 1.76), "Chest"),
    ("Head", (0, 0, 1.77), (0, 0, 2.00), "Neck"),
    ("UpperArm.L", (-0.35, 0, 1.58), (-0.62, 0, 1.30), "Chest"),
    ("LowerArm.L", (-0.62, 0, 1.30), (-0.77, 0, 1.05), "UpperArm.L"),
    ("UpperArm.R", (0.35, 0, 1.58), (0.62, 0, 1.30), "Chest"),
    ("LowerArm.R", (0.62, 0, 1.30), (0.77, 0, 1.05), "UpperArm.R"),
    ("Thigh.L", (-0.20, 0, 0.94), (-0.24, 0, 0.55), "Hips"),
    ("Shin.L", (-0.24, 0, 0.55), (-0.24, 0, 0.13), "Thigh.L"),
    ("Foot.L", (-0.24, 0, 0.13), (-0.24, -0.15, 0.11), "Shin.L"),
    ("Thigh.R", (0.20, 0, 0.94), (0.24, 0, 0.55), "Hips"),
    ("Shin.R", (0.24, 0, 0.55), (0.24, 0, 0.13), "Thigh.R"),
    ("Foot.R", (0.24, 0, 0.13), (0.24, -0.15, 0.11), "Shin.R"),
]
for name, head, tail, _ in bones:
    b = rig_data.edit_bones.new(name)
    b.head = head
    b.tail = tail
for name, _, _, parent in bones:
    if parent:
        rig_data.edit_bones[name].parent = rig_data.edit_bones[parent]
bpy.ops.object.mode_set(mode="OBJECT")
rig.select_set(False)

meshes = []


def part(name, position, dimensions, material, bone, kind="box"):
    if kind == "sphere":
        bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=10, location=position)
    else:
        bpy.ops.mesh.primitive_cube_add(size=1, location=position)
    obj = bpy.context.object
    obj.name = name
    obj.dimensions = dimensions
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if kind == "box":
        bev = obj.modifiers.new("Soft silhouette", "BEVEL")
        bev.width = min(dimensions) * 0.15
        bev.segments = 2
        obj.modifiers.new("Weighted highlights", "WEIGHTED_NORMAL")
    obj.data.materials.append(material)
    # One Skin influence per stylized shell is intentional: true bone-deformed
    # gameplay motion, crisp cartoon armor, no disconnected rigid parenting.
    group = obj.vertex_groups.new(name=bone)
    group.add(list(range(len(obj.data.vertices))), 1.0, "REPLACE")
    obj.parent = rig
    deform = obj.modifiers.new("CharacterBody Skin", "ARMATURE")
    deform.object = rig
    meshes.append(obj)
    return obj


part("Flexible torso", (0, 0, 1.30), (0.66, 0.35, 0.65), suit, "Spine")
part("Sculpted chest armor", (0, -0.205, 1.47), (0.59, 0.105, 0.30), armor, "Chest")
part("Chest energy badge", (0, -0.278, 1.51), (0.15, 0.045, 0.10), accent, "Chest")
part("Utility belt", (0, 0, 1.02), (0.69, 0.41, 0.12), boots, "Hips")
part("Helmet outer", (0, 0, 1.87), (0.46, 0.43, 0.45), armor, "Head", "sphere")
part("Helmet visible visor", (0, -0.20, 1.885), (0.35, 0.14, 0.20), visor, "Head", "sphere")
part("Helmet glowing brow", (0, -0.225, 1.995), (0.34, 0.09, 0.035), cyan, "Head")
part("Backpack spine shell", (0, 0.235, 1.40), (0.43, 0.18, 0.38), boots, "Chest")
for suffix, x in [("L", -1), ("R", 1)]:
    part("Upper arm " + suffix, (x * 0.48, 0, 1.45), (0.23, 0.24, 0.37), armor, "UpperArm." + suffix)
    part("Elbow flex " + suffix, (x * 0.65, 0, 1.28), (0.19, 0.20, 0.21), suit, "LowerArm." + suffix, "sphere")
    part("Forearm " + suffix, (x * 0.71, -0.015, 1.16), (0.21, 0.23, 0.33), suit, "LowerArm." + suffix)
    part("Glove " + suffix, (x * 0.79, 0, 1.015), (0.19, 0.24, 0.17), boots, "LowerArm." + suffix)
    part("Thigh armor " + suffix, (x * 0.21, 0, 0.75), (0.30, 0.32, 0.48), armor, "Thigh." + suffix)
    part("Knee bright guard " + suffix, (x * 0.25, -0.17, 0.52), (0.26, 0.07, 0.16), cyan, "Shin." + suffix)
    part("Lower leg " + suffix, (x * 0.245, 0, 0.32), (0.26, 0.28, 0.46), suit, "Shin." + suffix)
    part("Boot " + suffix, (x * 0.25, -0.085, 0.115), (0.30, 0.48, 0.20), boots, "Foot." + suffix)

# One complete Blender Action. Godot selects an animation frame range per
# movement state without swapping skeletons or introducing stateful input.
for pb in rig.pose.bones:
    pb.rotation_mode = "XYZ"


def pose(frame, arm=0.0, leg=0.0, knees=0.0, forward=0.0,
         head=0.0, twist=0.0, jump=False):
    for pb in rig.pose.bones:
        pb.rotation_euler = (0.0, 0.0, 0.0)
    r = rig.pose.bones
    r["UpperArm.L"].rotation_euler.x = arm if not jump else -0.55
    r["UpperArm.R"].rotation_euler.x = -arm if not jump else -0.55
    r["LowerArm.L"].rotation_euler.x = -0.15 if not jump else -0.43
    r["LowerArm.R"].rotation_euler.x = -0.15 if not jump else -0.43
    r["Thigh.L"].rotation_euler.x = leg if not jump else 0.52
    r["Thigh.R"].rotation_euler.x = -leg if not jump else 0.52
    r["Shin.L"].rotation_euler.x = knees
    r["Shin.R"].rotation_euler.x = -knees if not jump else knees
    r["Chest"].rotation_euler.x = forward
    r["Chest"].rotation_euler.z = twist
    r["Head"].rotation_euler.x = head
    for pb in rig.pose.bones:
        pb.keyframe_insert(data_path="rotation_euler", frame=frame, group="SkeletalLocomotion")


for n in range(5):
    frame = 1 + n * 12
    pose(frame, arm=0.07 * math.sin(n * math.pi / 2),
         head=0.035 * math.sin(n * math.pi / 2))
for n in range(9):
    frame = 49 + n * 6
    phase = n * math.pi / 2
    pose(frame, arm=0.37 * math.sin(phase), leg=-0.41 * math.sin(phase),
         knees=0.16 * math.cos(phase), forward=-0.055,
         twist=0.055 * math.cos(phase))
for n in range(9):
    frame = 97 + n * 6
    phase = n * math.pi / 2
    pose(frame, arm=0.72 * math.sin(phase), leg=-0.62 * math.sin(phase),
         knees=0.25 * math.cos(phase), forward=-0.19,
         twist=0.075 * math.cos(phase))
for n in range(5):
    frame = 145 + n * 6
    pose(frame, jump=True, knees=-0.32,
         forward=-0.08, head=0.08 if n >= 2 else -0.06)
for n in range(5):
    frame = 169 + n * 6
    pose(frame, arm=-0.18, leg=0.13, knees=0.18,
         forward=0.12, head=-0.05)
for n in range(5):
    frame = 193 + n * 6
    t = n / 4.0
    pose(frame, arm=0.05 * (1.0 - t), leg=-0.12 * (1.0 - t),
         knees=0.24 * (1.0 - t), forward=0.23 * (1.0 - t))
rig.animation_data.action.name = "HeroLocomotion"

# Export only hero rig + skinned geometry, not studio objects.
bpy.ops.object.select_all(action="DESELECT")
rig.select_set(True)
for obj in meshes:
    obj.select_set(True)
bpy.context.view_layer.objects.active = rig
bpy.context.scene.frame_set(1)
glb = out / "learnquest_walk_hero.glb"
bpy.ops.export_scene.gltf(
    filepath=str(glb), export_format="GLB", use_selection=True,
    export_yup=True, export_animations=True,
    export_cameras=False, export_lights=False
)

blend = out / "learnquest_walk_hero.blend"
bpy.ops.wm.save_as_mainfile(filepath=str(blend))

# Fast reproducible offline studio view, not a simulated in-game screenshot.
bpy.ops.object.select_all(action="DESELECT")
bpy.ops.object.camera_add(location=(3.3, -5.2, 2.8))
camera = bpy.context.object
camera.rotation_euler = (Vector((0, 0, 1.18)) - camera.location).to_track_quat("-Z", "Y").to_euler()
camera.data.type = "ORTHO"
camera.data.ortho_scale = 3.5
bpy.context.scene.camera = camera
for xyz, strength in [((3, -4, 6), 520), ((-3, 1, 5), 320)]:
    bpy.ops.object.light_add(type="AREA", location=xyz)
    light = bpy.context.object
    light.data.energy = strength
    light.data.size = 4.0
    light.rotation_euler = (Vector((0, 0, 1.1)) - light.location).to_track_quat("-Z", "Y").to_euler()
bpy.context.scene.render.engine = "CYCLES"
bpy.context.scene.cycles.samples = 8
bpy.context.scene.render.threads_mode = "FIXED"
bpy.context.scene.render.threads = 2
bpy.context.scene.render.resolution_x = 520
bpy.context.scene.render.resolution_y = 520
bpy.context.scene.render.resolution_percentage = 100
bpy.context.scene.render.image_settings.file_format = "PNG"
bpy.context.scene.render.filepath = str(out / "walk_hero_studio.png")
bpy.ops.render.render(write_still=True)
manifest = {
    "name": "LearnQuest 3D original 16-bone stylized prototype",
    "license": "Original Blender geometry; no third-party models, textures or secrets",
    "source": "tools/blender/make_walk_hero.py",
    "bones": len(bones),
    "mesh_parts": len(meshes),
    "fps": 24,
    "segments": {"idle": [1, 49], "walk": [49, 97],
                 "sprint": [97, 145], "jump": [145, 169],
                 "fall": [169, 193], "land": [193, 217]},
    "notes": "True skinned GLB. DRAFT until Godot in-game visual and iPhone QA."
}
(out / "manifest.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")
print("LEARNQUEST ANIMATED HERO BLENDER GENERATION PASSED", manifest)
