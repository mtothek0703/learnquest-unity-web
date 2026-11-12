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
    scene.render.engine = "BLENDER_WORKBENCH"
    scene.render.resolution_x=640
    scene.render.resolution_y=800
    scene.render.resolution_percentage=100
    scene.render.image_settings.file_format="PNG"
    scene.render.film_transparent=False
    scene.display.shading.light="STUDIO"
    scene.display.shading.color_type="MATERIAL"
    scene.display.shading.show_cavity=True
    scene.display.shading.show_shadows=True
    scene.display.shading.background_type="WORLD"
    scene.display.shading.background_color=(.89,.87,.91)
    scene.render.filepath = str(OUT / ("character-" + person + "-preview.png"))
    bpy.ops.render.render(write_still=True)
    print("PREVIEW_SAVED",scene.render.filepath,flush=True)
