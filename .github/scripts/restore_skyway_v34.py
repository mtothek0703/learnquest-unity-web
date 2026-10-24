#!/usr/bin/env python3
"""Recover byte-identical Skyway V34 files from its successful Pages artifact.

V35 accidentally omitted V34 from its snapshot list. Only the immutable,
successful V34 GitHub Pages artifact may repair this historical directory.
No re-export or overwriting of a different historical version is allowed.
"""
from pathlib import Path, PurePosixPath
import tarfile

SOURCE = Path("/tmp/skyway-v34-original/artifact.tar")
DEST = Path("_site/skyway-v34")
ORIGINAL_RUN = "40053310388"
ORIGINAL_COMMIT = "6592da3530ed86904e972b9c375742f533f3d69a"
FILES = {
    "index.html", "index.js", "index.wasm", "index.pck", "build.txt",
    "index.png", "index.icon.png", "index.apple-touch-icon.png",
    "index.audio.worklet.js", "index.worker.js",
}
REQUIRED = {"index.html", "index.js", "index.wasm", "index.pck", "build.txt"}


def restore(archive: Path = SOURCE, destination: Path = DEST) -> None:
    if not archive.is_file():
        raise RuntimeError("Original Skyway V34 Pages artifact.tar is unavailable")
    destination.mkdir(parents=True, exist_ok=True)
    restored = set()
    with tarfile.open(archive, "r:*") as bundle:
        for member in bundle:
            path = PurePosixPath(member.name)
            if len(path.parts) != 2 or path.parts[0] != "skyway-v34":
                continue
            name = path.parts[1]
            if name not in FILES or not member.isfile():
                continue
            source = bundle.extractfile(member)
            if source is None:
                raise RuntimeError("Cannot read original V34 asset " + name)
            target = destination / name
            if target.exists():
                raise RuntimeError("Refusing to overwrite preexisting V34 asset " + name)
            with source, target.open("wb") as output:
                while chunk := source.read(1024 * 1024):
                    output.write(chunk)
            if target.stat().st_size == 0:
                raise RuntimeError("Empty original V34 asset " + name)
            restored.add(name)
    if not REQUIRED.issubset(restored):
        raise RuntimeError("Original V34 Pages artifact is incomplete: " + str(REQUIRED - restored))
    if (destination / "build.txt").read_text().strip() != ORIGINAL_COMMIT:
        raise RuntimeError("Original V34 build commit mismatch; refusing restoration")
    (destination / ".restored-from-original-pages").write_text(ORIGINAL_RUN + "\n")
    print("Restored original Skyway V34 from successful Pages run " + ORIGINAL_RUN)


if __name__ == "__main__":
    restore()
