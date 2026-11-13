"""Regression of original Blender-authored skin and locomotion in binary GLB."""
import json
from pathlib import Path
import struct
import sys

directory = Path(sys.argv[1])
model = directory / "learnquest_walk_hero.glb"
blend = directory / "learnquest_walk_hero.blend"
image = directory / "walk_hero_studio.png"
manifest = directory / "manifest.json"
for name in (model, blend, image, manifest):
    assert name.is_file() and name.stat().st_size > 100, f"missing or empty asset: {name}"

data = model.read_bytes()
assert data[:4] == b"glTF", "GLB missing signature"
assert struct.unpack_from("<I", data, 4)[0] == 2, "GLB version must be 2"
assert struct.unpack_from("<I", data, 8)[0] == len(data), "GLB length mismatch"
assert data[16:20] == b"JSON", "GLB JSON chunk absent"
length = struct.unpack_from("<I", data, 12)[0]
gltf = json.loads(data[20:20 + length].decode("utf-8"))
skins = gltf.get("skins", [])
assert len(skins) == 1, f"expect exactly one actual skin, got {len(skins)}"
joints = skins[0].get("joints", [])
assert len(joints) >= 14, f"hero needs articulated bone hierarchy, got {len(joints)}"
assert len(gltf.get("meshes", [])) >= 14, "hero shells not exported"
assert len(gltf.get("materials", [])) >= 4, "hero materials not exported"
anim = gltf.get("animations", [])
assert anim and sum(len(a.get("channels", [])) for a in anim) >= 12, "real joint animation missing"
rotation_nodes = {c.get("target", {}).get("node")
                  for a in anim for c in a.get("channels", [])
                  if c.get("target", {}).get("path") == "rotation"}
assert len(rotation_nodes.intersection(joints)) >= 8, "fewer than 8 animated skinned bones"
joint_indices = set(joints)
skinned = 0
vertices = 0
for mesh in gltf.get("meshes", []):
    for primitive in mesh.get("primitives", []):
        attrs = primitive.get("attributes", {})
        if "JOINTS_0" in attrs and "WEIGHTS_0" in attrs:
            skinned += 1
        if "POSITION" in attrs:
            vertices += gltf["accessors"][attrs["POSITION"]]["count"]
assert skinned >= 12, f"meshes are not truly skinned: {skinned}"
assert vertices < 20000, f"mobile vertex budget exceeded: {vertices}"
assert image.read_bytes()[:8] == b"\x89PNG\r\n\x1a\n", "studio preview missing PNG header"
report = json.loads(manifest.read_text(encoding="utf-8"))
assert report["bones"] == len(joints), "skeleton mismatch between GLB and manifest"
assert all(key in report["segments"] for key in ("idle", "walk", "sprint", "jump", "fall", "land"))
print("LEARNQUEST BLENDER RIGGED HERO VALIDATION PASSED:",
      len(joints), "joints,", skinned, "skinned surfaces,",
      len(rotation_nodes.intersection(joint_indices)), "animated bones,", vertices, "vertices")
