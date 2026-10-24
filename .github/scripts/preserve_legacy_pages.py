#!/usr/bin/env python3
"""Preserve existing GitHub Pages game builds before publishing a new version.

GitHub Pages replaces the entire website on every deployment. Rebuilding every
historic Skyway URL from the latest Godot export silently changes old versions.
This script snapshots the currently published assets into the next _site.
"""
from __future__ import annotations

import hashlib
import json
import os
from pathlib import Path
import time
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

BASE = "https://mtothek0703.github.io/learnquest-unity-web/"
VERSIONS = (
    "neon-city-v3", "neon-city-v4", "neon-city-v5",
    "skyway-v6", "skyway-v7", "skyway-v8", "skyway-v9",
    "skyway-v10", "skyway-v11", "skyway-v12", "skyway-v13",
    "skyway-v14", "skyway-v15", "skyway-v16", "skyway-v17", "skyway-v18", "skyway-v19", "skyway-v20", "skyway-v21", "skyway-v22", "skyway-v23", "skyway-v24", "skyway-v25", "skyway-v26", "skyway-v27", "skyway-v28", "skyway-v29", "skyway-v30", "skyway-v31",
)
REQUIRED = ("index.html", "index.js", "index.wasm", "index.pck")
OPTIONAL = (
    "build.txt", "index.png", "index.icon.png",
    "index.apple-touch-icon.png", "index.audio.worklet.js",
    "index.worker.js",
)


def download(url: str, destination: Path) -> bool:
    """Download atomically; return False only for a genuine HTTP 404."""
    destination.parent.mkdir(parents=True, exist_ok=True)
    temporary = destination.with_name(destination.name + ".part")
    for attempt in range(3):
        try:
            request = Request(
                url, headers={"User-Agent": "LearnQuest-version-archiver/1.0",
                              "Cache-Control": "no-cache"}
            )
            with urlopen(request, timeout=90) as response, temporary.open("wb") as out:
                while chunk := response.read(1024 * 1024):
                    out.write(chunk)
            if temporary.stat().st_size == 0:
                raise RuntimeError("Downloaded empty file: " + url)
            temporary.replace(destination)
            return True
        except HTTPError as error:
            temporary.unlink(missing_ok=True)
            if error.code == 404:
                return False
            if error.code not in (429, 500, 502, 503, 504):
                raise
            print(f"Retrying HTTP {error.code}: {url}", flush=True)
        except (URLError, TimeoutError, RuntimeError) as error:
            temporary.unlink(missing_ok=True)
            print(f"Retrying {url}: {error}", flush=True)
        if attempt < 2:
            time.sleep(3 * (attempt + 1))
    raise RuntimeError("Could not archive existing published file: " + url)


def main() -> None:
    destination = Path(os.environ.get("SITE_ROOT", "_site"))
    manifest: dict[str, dict[str, object]] = {}
    for version in VERSIONS:
        folder = destination / version
        url = BASE + version + "/"
        if not download(url + "index.html", folder / "index.html"):
            if version in ("skyway-v16", "skyway-v17", "skyway-v18", "skyway-v19", "skyway-v20", "skyway-v21", "skyway-v22", "skyway-v23", "skyway-v24", "skyway-v25", "skyway-v26", "skyway-v27", "skyway-v28", "skyway-v29", "skyway-v30", "skyway-v31"):
                raise RuntimeError("Verified %s is missing; refusing to replace old Pages site" % version)
            print(f"SKIP: {version} is not currently published", flush=True)
            continue
        missing = []
        for name in REQUIRED[1:]:
            if not download(url + name, folder / name):
                missing.append(name)
        for name in OPTIONAL:
            download(url + name, folder / name)
        if missing:
            # Any incomplete historical snapshot must block the entire deploy.
            # A warning here would permanently remove files from an older URL.
            raise RuntimeError(
                f"Published {version} is incomplete ({missing}); refusing to deploy"
            )
        manifest[version] = {
            "html_sha256": hashlib.sha256((folder / "index.html").read_bytes()).hexdigest(),
            "build": (folder / "build.txt").read_text().strip()
            if (folder / "build.txt").exists() else None,
            "missing_required": missing,
        }
        print(f"Archived {version}: {len(list(folder.iterdir()))} files", flush=True)
    for required_version in ("skyway-v16", "skyway-v17", "skyway-v18", "skyway-v19", "skyway-v20", "skyway-v21", "skyway-v22", "skyway-v23", "skyway-v24", "skyway-v25", "skyway-v26", "skyway-v27", "skyway-v28", "skyway-v29", "skyway-v30", "skyway-v31"):
        if required_version not in manifest:
            raise RuntimeError("%s preservation failed" % required_version)
    (destination / "preserved-versions.json").write_text(
        json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8"
    )
    print(f"Preserved {len(manifest)} historical version directories", flush=True)


if __name__ == "__main__":
    main()
