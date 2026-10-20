#!/usr/bin/env python3
"""Prepare a Unity Cloud WebGL ZIP for GitHub Pages without rebuilding Unity.

Supports Unity's 'UnityWeb Compressed Content (brotli)' assets and the already
repaired uncompressed ZIP. Does not preserve IndexedDB filesystem persistence.
"""
import argparse
import pathlib
import re
import zipfile
import brotli

HEADER = b"UnityWeb Compressed Content (brotli)"
IDBFS_FALLBACK = "var IDBFS={mount:MEMFS.mount,syncfs:function(mount,populate,callback){callback(null)}};"

def prepare(source, destination):
    root = pathlib.Path(destination)
    root.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(source) as archive:
        files = [f for f in archive.infolist() if not f.is_dir()]
        indexes = [f.filename for f in files if f.filename.endswith("/index.html") or f.filename == "index.html"]
        if not indexes:
            raise RuntimeError("No Unity index.html found")
        prefix = min(indexes, key=len)[:-len("index.html")]
        for item in files:
            name = item.filename
            if not name.startswith(prefix):
                continue
            rel = name[len(prefix):]
            parts = pathlib.PurePosixPath(rel).parts
            if not parts or ".." in parts or rel.startswith("/"):
                raise RuntimeError("Unsafe ZIP member: " + name)
            data = archive.read(item)
            if rel.endswith(".br"):
                if not data.startswith(HEADER):
                    raise RuntimeError("Unexpected Unity Brotli header: " + rel)
                data = brotli.decompress(data[len(HEADER):])
                rel = rel[:-3]
            if rel.endswith(".framework.js"):
                js = data.decode("utf-8")
                if "injectIndexedDBToAutomaticallyPersist()" in js and "var IDBFS={mount:MEMFS.mount,syncfs:function(mount,populate,callback){callback(null)}}" not in js:
                    js = js.replace("injectIndexedDBToAutomaticallyPersist();",
                       IDBFS_FALLBACK + "injectIndexedDBToAutomaticallyPersist();", 1)
                if "IDBFS.queuePersist" in js and IDBFS_FALLBACK not in js and "var IDBFS=" not in js:
                    raise RuntimeError("Could not patch IDBFS safely")
                data = js.encode("utf-8")
            if rel == "index.html":
                html = data.decode("utf-8")
                for extension in (".data.br", ".framework.js.br", ".wasm.br"):
                    html = html.replace(extension, extension[:-3])
                data = html.encode("utf-8")
            target = root.joinpath(*pathlib.PurePosixPath(rel).parts)
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(data)
    if not (root / "index.html").is_file():
        raise RuntimeError("No published index.html")
    if not list((root / "Build").glob("*.wasm")):
        raise RuntimeError("WebAssembly binary missing")
    (root / ".nojekyll").touch()

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("archive")
    parser.add_argument("output")
    args = parser.parse_args()
    prepare(args.archive, args.output)
