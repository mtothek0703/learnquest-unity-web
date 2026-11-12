"""Neutral avatars: Blender character build (source: CC0 Quaternius).
Requires Blender 3.6+. Exports real rigged GLB files for browser animation.
These are sculpt-enhanced base characters, not exact 3D reconstructions from a 2D image.
No user photos or private data are uploaded.
"""
import bpy
import bmesh
import hashlib
import math
from pathlib import Path
from urllib.request import Request, urlopen
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "generated" / "avatar-assets"
ASSETS.mkdir(parents=True, exist_ok=True)
REV = "c06a6fa9a1b13576edf3bd62d7b52aba334f8fc0"
BASE = "https://raw.githubusercontent.com/trebeljahr/quaternius-showcase/" + REV + "/public/glb/"
SOURCES = {
    "AvatarA": ("modular_women/Casual.glb", 804896, "f64c3d48148aef1e431abec40ae0cf33c1db93d5"),
    "AvatarB": ("modular_men/Casual.glb", 785308, "a74f94183952267a874c24ac73c4d2382fd0187d")
}
PALETTES = {
    "AvatarA": {"top": "#AF8DBD", "pants": "#635071", "hair": "#62443B", "shoe": "#E3D5F2"},
    "AvatarB": {"top": "#557BA9", "pants": "#354967", "hair": "#59403A", "shoe": "#BFD6F1"}
}

def rgba(hex_color):
    p = [int(hex_color[i:i+2], 16) / 255.0 for i in (1, 3, 5)]
    return tuple(v/12.92 if v <= 0.04045 else ((v+0.055)/1.055)**2.4 for v in p) + (1.0,)

def load_source(name):
    url, size, sha = SOURCES[name]
    target = ASSETS / ("source-" + name.lower() + ".glb")
    if target.exists():
        blob = target.read_bytes()
    else:
        req = Request(BASE + url, headers={"User-Agent": "FamilyKohler/Blender3D"})
        with urlopen(req, timeout=90) as response:
            blob = response.read()
        target.write_bytes(blob)
    digest = hashlib.sha1(b"blob " + str(len(blob)).encode() + b"\0" + blob).hexdigest()
    if len(blob) != size or blob[:4] != b"glTF" or digest != sha:
        raise RuntimeError("Unverified character asset: " + name)
    return target

def material_color(material, color):
    c = rgba(color)
    material.diffuse_color = c
    if material.use_nodes:
        for n in material.node_tree.nodes:
            if n.type == "BSDF_PRINCIPLED":
                base = n.inputs.get("Base Color")
                if base: base.default_value = c
                rough = n.inputs.get("Roughness")
                if rough: rough.default_value = .77

def make_material(name, color, roughness=.87):
    m = bpy.data.materials.new(name)
    m.diffuse_color = rgba(color)
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get("Principled BSDF")
    if bsdf:
        bsdf.inputs["Base Color"].default_value = rgba(color)
        bsdf.inputs["Roughness"].default_value = roughness
    return m

def remove_avatar_b_hair():
    face_count = 0
    for obj in list(bpy.data.objects):
        if obj.type != "MESH" or "casual_head" not in obj.name.lower():
            continue
        indices = {i for i, mat in enumerate(obj.data.materials)
                   if mat is not None and mat.name.split(".")[0].lower() == "hair"}
        bm = bmesh.new()
        bm.from_mesh(obj.data)
        to_delete = [f for f in bm.faces if f.material_index in indices]
        face_count += len(to_delete)
        if to_delete:
            bmesh.ops.delete(bm, geom=to_delete, context="FACES")
            bm.to_mesh(obj.data)
            obj.data.update()
        bm.free()
    if face_count == 0:
        raise RuntimeError("AvatarB's removable hair geometry not found")
    print("AvatarB bald: deleted", face_count, "hair polygons", flush=True)

def skin_and_style(name):
    palette = PALETTES[name]
    for obj in list(bpy.data.objects):
        if obj.type != "MESH":
            continue
        n = obj.name.lower()
        for p in obj.data.polygons:
            p.use_smooth = True
        # Own copies of each material: no accidental changes to face or eyes.
        for i, material in enumerate(list(obj.data.materials)):
            if material is None:
                continue
            mn = material.name.split(".")[0].lower()
            color = None
            if "casual_body" in n and mn in ("purple", "lightblue"):
                color = palette["top"]
            elif "casual_legs" in n and mn in ("purple", "lightblue"):
                color = palette["pants"]
            elif "casual_feet" in n and mn == "lightblue":
                color = palette["shoe"]
            elif name == "AvatarA" and mn == "hair":
                color = palette["hair"]
            if color:
                new = material.copy()
                new.name = "Avatar_" + name + "_" + str(i) + "_" + obj.name[:30]
                material_color(new, color)
                obj.data.materials[i] = new
    rigs = [x for x in bpy.data.objects if x.type == "ARMATURE" and "Head" in x.pose.bones]
    if not rigs:
        raise RuntimeError(name + ": rigged Head bone absent")
    return rigs[0]

def head_measurements():
    heads = [o for o in bpy.data.objects if o.type == "MESH" and "casual_head" in o.name.lower()]
    if not heads:
        raise RuntimeError("Head mesh absent")
    ob = heads[0]
    verts = list(ob.data.vertices)
    material_names = [m.name.split(".")[0].lower() if m else "" for m in ob.data.materials]
    def points_by_material(wanted):
        ids = set()
        for poly in ob.data.polygons:
            if material_names[poly.material_index] in wanted:
                ids.update(poly.vertices)
        return [ob.matrix_world @ verts[i].co for i in ids]
    skin = points_by_material({"skin", "face", "skintone"})
    eyes = points_by_material({"eye", "eyes"})
    if not skin:
        skin = [ob.matrix_world @ v.co for v in verts]
    if not skin:
        raise RuntimeError("Head geometry has no vertices")
    all_min = Vector(tuple(min(v[k] for v in skin) for k in range(3)))
    all_max = Vector(tuple(max(v[k] for v in skin) for k in range(3)))
    face_mid = sum(skin, Vector()) / len(skin)
    if eyes:
        eye_mid = sum(eyes, Vector()) / len(eyes)
        forward = Vector((eye_mid.x - face_mid.x, eye_mid.y - face_mid.y, 0))
    else:
        # Some skinned source heads have no distinct eye material on import.
        # Use Blender's forward axis and the actual mesh bounds.
        forward = Vector((0, -1, 0))
        eye_mid = face_mid + forward * (max(all_max.x-all_min.x, all_max.y-all_min.y) * .20)
        eye_mid.z = all_min.z + (all_max.z-all_min.z) * .65
    if forward.length < .00001:
        forward = Vector((0, -1, 0))
    forward.normalize()
    print("Head details:", ob.name, "skin",len(skin),"eyes",len(eyes),"direction",tuple(round(v,3) for v in forward), flush=True)
    across = Vector((-forward.y, forward.x, 0))
    width = max(all_max.x-all_min.x, all_max.y-all_min.y)
    height = all_max.z-all_min.z
    return eye_mid, forward, across, width, height

def add_soft_sphere(name, center, size, mat, rig, joint="Head", segments=24, rings=16):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=segments, ring_count=rings, radius=1, location=center)
    ob = bpy.context.object
    ob.name = name
    ob.dimensions = size
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    ob.data.materials.append(mat)
    for f in ob.data.polygons:
        f.use_smooth = True
    # Bone parenting exports into glTF/GLB and follows the animated head.
    world_matrix = ob.matrix_world.copy()
    ob.parent = rig
    ob.parent_type = "BONE"
    ob.parent_bone = joint
    ob.matrix_world = world_matrix
    return ob

def add_face_details(name, rig):
    eye, forward, across, w, h = head_measurements()
    if not (.04 < w < 1.0 and .07 < h < 1.2):
        raise RuntimeError("Unexpected face scale: " + str((w,h)))
    if name == "AvatarB":
        beard = make_material("Avatar_AvatarB_warm_brown_beard", "#594037")
        # Clean bald scalp from original skin mesh, sculpted beard on chin/cheeks.
        add_soft_sphere("Beard_chin", eye-forward*w*.05-Vector((0,0,h*.33)),
                        (w*.63,w*.48,h*.40),beard,rig)
        for sign in (-1,1):
            add_soft_sphere("Beard_cheek_"+str(sign),
                eye+across*(sign*w*.30)+forward*w*.015-Vector((0,0,h*.20)),
                (w*.28,w*.34,h*.38),beard,rig)
            add_soft_sphere("Moustache_"+str(sign),
                eye+across*(sign*w*.17)+forward*w*.16-Vector((0,0,h*.16)),
                (w*.24,w*.19,h*.085),beard,rig,segments=20,rings=12)
    else:
        warm = make_material("Avatar_AvatarA_soft_brown_curls", "#62443B")
        # Soft modeled wavy locks around cheeks, replacing no rigged base hair:
        # each curl is bone-parented so greetings and head turns remain 3D.
        for side in (-1,1):
            for i in range(5):
                wave = math.sin(i*1.28+side)*w*.045
                center = (eye + across*(side*w*(.37+wave/w)) -
                          forward*w*.12 + Vector((0,0,h*(.12-i*.11))))
                diameter = w*(.22-.010*i)
                add_soft_sphere("AvatarA_soft_curl_%s_%s"%(side,i),center,
                                (diameter,diameter*.87,h*.24),warm,rig,segments=18,rings=12)

def export(name):
    source = load_source(name)
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=str(source))
    if name == "AvatarB":
        remove_avatar_b_hair()
    rig = skin_and_style(name)
    try:
        add_face_details(name, rig)
    except (ValueError, RuntimeError) as exc:
        print("Nonfatal extra detail warning:", str(exc), flush=True)
    # Keep the CC0 skeletal joints; they animate walking, waving and hugs.
    required = ("Head", "UpperArm.R", "LowerArm.R", "UpperArm.L",
                "UpperLeg.R", "UpperLeg.L")
    if any(n not in rig.pose.bones for n in required):
        raise RuntimeError(name + ": missing animation joints")
    glb = ASSETS / ("character-" + name.lower() + "-premium.glb")
    blend = ASSETS / ("character-" + name.lower() + "-premium.blend")
    bpy.ops.wm.save_as_mainfile(filepath=str(blend))
    bpy.ops.object.select_all(action="DESELECT")
    for ob in bpy.context.scene.objects:
        if ob.type in ("ARMATURE", "MESH", "EMPTY"):
            ob.select_set(True)
    bpy.ops.export_scene.gltf(filepath=str(glb), export_format="GLB",
        use_selection=True, export_skins=True, export_animations=True,
        export_apply=False)
    raw = glb.read_bytes()
    if len(raw) < 150_000 or raw[:4] != b"glTF":
        raise RuntimeError("GLB export invalid: " + str(glb))
    print("SUCCESS", name, glb, len(raw), flush=True)

for person in ("AvatarA", "AvatarB"):
    export(person)
print("Neutral avatars: two rigged GLBs exported.", flush=True)
