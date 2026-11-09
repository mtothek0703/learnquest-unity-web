"""Fail the workflow if Blender did not generate a usable asset."""
import json
from pathlib import Path
import struct
import sys

out = Path(sys.argv[1]).resolve()
names = ["learnquest_portal.glb", "learnquest_portal.blend", "portal_preview.png", "manifest.json"]
for name in names:
    path = out / name
    assert path.is_file(), f"Missing output: {path}"
    assert path.stat().st_size > 100, f"Output unexpectedly small: {path}"

glb = (out / names[0]).read_bytes()
assert glb[:4] == b"glTF", "Invalid GLB signature"
assert struct.unpack_from("<I", glb, 4)[0] == 2, "Expected GLB version 2"
assert struct.unpack_from("<I", glb, 8)[0] == len(glb), "GLB file length mismatch"
chunk_length = struct.unpack_from("<I", glb, 12)[0]
assert glb[16:20] == b"JSON", "GLB JSON chunk missing"
data = json.loads(glb[20:20+chunk_length].decode("utf-8"))
assert len(data.get("meshes", [])) >= 10, "Not enough mesh components in GLB"
assert len(data.get("materials", [])) >= 3, "Missing expected GLB materials"
assert (out / "portal_preview.png").read_bytes()[:8] == b"\x89PNG\r\n\x1a\n"
info = json.loads((out / "manifest.json").read_text(encoding="utf-8"))
assert info["asset_objects"] >= 20, "Missing asset objects"
print("BLENDER GLB VALIDATION PASSED:", len(data["meshes"]), "meshes,",
      len(data["materials"]), "materials,", info["vertices"], "vertices")
