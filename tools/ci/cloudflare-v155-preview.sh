#!/usr/bin/env bash
# Cloudflare Pages isolated V155 playtest: builds only this branch, not GitHub Pages.
set -euo pipefail
test "${CF_PAGES_BRANCH:-preview/v155-playtest-20261110}" = "preview/v155-playtest-20261110" || { echo "Wrong preview branch; stop."; exit 1; }
test -s godot/assets/3d/learnquest_walk_hero.glb
test -s godot/assets/3d/learnquest_portal.glb

BASE=https://github.com/godotengine/godot/releases/download/4.4.1-stable
curl -fLsS --retry 3 "$BASE/Godot_v4.4.1-stable_linux.x86_64.zip" -o /tmp/learnquest-godot.zip
unzip -q /tmp/learnquest-godot.zip -d /tmp
GODOT=/tmp/Godot_v4.4.1-stable_linux.x86_64
chmod +x "$GODOT"
curl -fLsS --retry 3 "$BASE/Godot_v4.4.1-stable_export_templates.tpz" -o /tmp/learnquest-templates.tpz
mkdir -p /tmp/learnquest-templates "$HOME/.local/share/godot/export_templates/4.4.1.stable"
unzip -q /tmp/learnquest-templates.tpz -d /tmp/learnquest-templates
cp /tmp/learnquest-templates/templates/* "$HOME/.local/share/godot/export_templates/4.4.1.stable/"

"$GODOT" --headless --editor --path godot --quit
for name in smoke_test adventure/adventure_bridge_test adventure/rigged_hero_asset_test blender_portal_test blender_race_integration_test; do
  echo "Testing $name"
  log="/tmp/lq-v155-${name//\//_}.log"
  timeout 90s "$GODOT" --headless --path godot --script "res://${name}.gd" > "$log" 2>&1 || { cat "$log"; exit 1; }
  case "$name" in
    smoke_test) marker='LEARNQUEST SMOKE TEST PASSED' ;;
    adventure/adventure_bridge_test) marker='ADVENTURE BRIDGE TEST PASSED' ;;
    adventure/rigged_hero_asset_test) marker='LEARNQUEST RIGGED HERO IMPORT TEST PASSED' ;;
    blender_portal_test) marker='LEARNQUEST BLENDER PORTAL TEST PASSED' ;;
    blender_race_integration_test) marker='BLENDER RACE INTEGRATION TEST PASSED' ;;
  esac
  grep -Fq "$marker" "$log" || { cat "$log"; exit 1; }
done

mkdir -p dist-v155
"$GODOT" --headless --path godot --export-release Web "$PWD/dist-v155/index.html"
for name in index.html index.js index.wasm index.pck; do test -s "dist-v155/$name"; done
# Pages caps individual file size at 25 MiB. Godot's raw wasm is ~42 MiB.
# Store the identical bytes as gzip on disk under the expected .wasm URL.
# Browsers transparently decode with Content-Encoding: gzip before WebAssembly
# instantiation, so game logic and loader URLs stay unchanged.
python3 - <<'PY'
from pathlib import Path
import gzip, hashlib, shutil
root = Path("dist-v155")
wasm = root / "index.wasm"
raw_hash = hashlib.sha256(wasm.read_bytes()).hexdigest()
tmp = root / "index.wasm.gz.tmp"
with wasm.open("rb") as src, gzip.open(tmp, "wb", compresslevel=9) as dst:
    shutil.copyfileobj(src, dst, 1024 * 1024)
with gzip.open(tmp, "rb") as src:
    assert hashlib.sha256(src.read()).hexdigest() == raw_hash, "Wasm gzip roundtrip failed"
size = tmp.stat().st_size
assert size < 25 * 1024 * 1024, f"Wasm still exceeds Pages 25MiB limit: {size}"
tmp.replace(wasm)
(root / "_headers").write_text(
    "/index.wasm\n"
    "  Content-Type: application/wasm\n"
    "  Content-Encoding: gzip\n"
    "  Cache-Control: no-transform\n"
    "/*\n"
    "  X-Robots-Tag: noindex\n",
    encoding="utf-8",
)
print(f"LEARNQUEST WASM GZIP VERIFIED: {size:,} bytes, SHA256 {raw_hash}")
PY
printf '%s\n' "${CF_PAGES_COMMIT_SHA:-$(git rev-parse HEAD)}" > dist-v155/build.txt
printf '%s\n' 'LearnQuest V155 – unveroeffentlichte TESTVERSION' > dist-v155/testversion.txt
printf 'User-agent: *\nDisallow: /\n' > dist-v155/robots.txt
touch dist-v155/.nojekyll
echo "LEARNQUEST V155 CLOUDFLARE PLAYTEST BUILD PASSED"
