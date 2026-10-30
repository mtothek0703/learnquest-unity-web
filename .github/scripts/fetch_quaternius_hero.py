#!/usr/bin/env python3
"""Fetch the exact CC0 Quaternius humanoid used for the V124 rigging trial.

The upstream project's repackaging is MIT; the actual Quaternius geometry and
skeleton remain CC0. Never use an unpinned, unverified asset in a release.
"""
from hashlib import sha1
from pathlib import Path
from urllib.request import Request, urlopen

SOURCE_COMMIT = "e225eee89835d121876b15bf4c887dc20d357950"
EXPECTED_GIT_BLOB = "b3fd79533fdb9fcedd077744f7e120920eb6cc97"
URL = (
    "https://raw.githubusercontent.com/programasweights/avatar/"
    + SOURCE_COMMIT + "/public/assets/character.glb"
)
DESTINATION = Path("godot/models/quaternius_hero.glb")

def main():
    with urlopen(Request(URL, headers={"User-Agent": "LearnQuest-CC0-Asset-Pin/1.0"}), timeout=45) as response:
        data = response.read(2_000_000)
    if not data.startswith(b"glTF") or len(data) < 200_000:
        raise SystemExit("Unexpected or truncated Quaternius GLB; refusing import")
    git_sha = sha1(b"blob " + str(len(data)).encode() + b"\0" + data).hexdigest()
    if git_sha != EXPECTED_GIT_BLOB:
        raise SystemExit(f"Asset digest mismatch: {git_sha}; expected {EXPECTED_GIT_BLOB}")
    DESTINATION.parent.mkdir(parents=True, exist_ok=True)
    DESTINATION.write_bytes(data)
    print(f"QUATERNIUS ASSET VERIFIED: {len(data)} bytes; git blob {git_sha}")

if __name__ == "__main__":
    main()
