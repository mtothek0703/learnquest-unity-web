"""Render inspectable portraits of two generic CC0 Blender avatars.
No private files, user images, network texture uploads or API tokens.
"""
import bpy
from mathutils import Vector
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "generated" / "avatar-assets"
for person in ("avatara", "avatarb"):
    source = OUT / ("character-" + person + "-premium.glb")
    assert source.is_file(), source
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=str(source))
    meshes = [o for o in bpy.context.scene.objects if o.type == "MESH"]
    assert meshes, "No authored geometry"
    coords = [ob.matrix_world @ Vector(c) for ob in meshes for c in ob.bound_box]
    low = Vector((min(v.x for v in coords), min(v.y for v in coords), min(v.z for v in coords)))
    high = Vector((max(v.x for v in coords), max(v.y for v in coords), max(v.z for v in coords)))
    target = (low + high) * .5
    tall = max(high.z - low.z, .4)
    print("Preview bounds", person, tuple(round(v,2) for v in low), tuple(round(v,2) for v in high),flush=True)
    bpy.ops.object.camera_add(location=(target.x+tall*.11, target.y-tall*1.6, target.z+tall*.04))
    camera = bpy.context.object
    direction = target - camera.location
    camera.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()
    camera.data.type = "ORTHO"
    camera.data.ortho_scale = tall*1.24
    scene=bpy.context.scene
    scene.camera=camera
    # CPU Cycles works headlessly; Workbench needs libEGL on this runner.
    scene.render.engine = "CYCLES"
    scene.cycles.device = "CPU"
    scene.cycles.samples = 12
    scene.render.resolution_x=480
    scene.render.resolution_y=600
    scene.render.resolution_percentage=100
    scene.render.image_settings.file_format="PNG"
    scene.render.film_transparent=False
    scene.world = bpy.data.worlds.new("Soft studio backdrop")
    scene.world.use_nodes = True
    bg = scene.world.node_tree.nodes.get("Background")
    bg.inputs["Color"].default_value=(.73,.69,.76,1)
    bg.inputs["Strength"].default_value=.8
    for pos,energy,size in [
        ((target.x-tall*.55,target.y-tall*.95,target.z+tall*.7),570,tall*1.3),
        ((target.x+tall*.7,target.y-tall*.4,target.z+tall*.45),330,tall*1.0)
    ]:
        bpy.ops.object.light_add(type="AREA",location=pos)
        lamp=bpy.context.object
        lamp.rotation_euler=(target-lamp.location).to_track_quat("-Z","Y").to_euler()
        lamp.data.energy=energy
        lamp.data.shape="DISK"
        lamp.data.size=size
    scene.render.filepath = str(OUT / ("character-" + person + "-preview.png"))
    bpy.ops.render.render(write_still=True)
    print("PREVIEW_SAVED",scene.render.filepath,flush=True)
