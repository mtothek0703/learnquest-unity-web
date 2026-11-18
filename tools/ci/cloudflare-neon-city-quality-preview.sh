#!/usr/bin/env bash
# Cloudflare isolated Neon City graphics QA, with real Godot import, gameplay gates and WebGL export.
set -euo pipefail
test "${CF_PAGES_BRANCH:-feature/adventure-a1-walkable-neon-testbed-20261106-19}" = "feature/adventure-a1-walkable-neon-testbed-20261106-19" || { echo "Wrong preview branch; stop."; exit 1; }
test -s godot/assets/3d/learnquest_walk_hero.glb
test -s godot/adventure/neon_city_facade.gdshader
# Portal PR #160 is intentionally excluded: validate the newer adventure hero directly.

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
for name in smoke_test adventure/adventure_bridge_test adventure/rigged_hero_asset_test; do
  echo "Testing $name"
  log="/tmp/lq-neon-${name//\//_}.log"
  timeout 90s "$GODOT" --headless --path godot --script "res://${name}.gd" > "$log" 2>&1 || { cat "$log"; exit 1; }
  case "$name" in
    smoke_test) marker='LEARNQUEST SMOKE TEST PASSED' ;;
    adventure/adventure_bridge_test) marker='ADVENTURE BRIDGE TEST PASSED' ;;
    adventure/rigged_hero_asset_test) marker='LEARNQUEST RIGGED HERO IMPORT TEST PASSED' ;;
  esac
  grep -Fq "$marker" "$log" || { cat "$log"; exit 1; }
done

mkdir -p dist-neon
"$GODOT" --headless --path godot --export-release Web "$PWD/dist-neon/index.html"
for name in index.html index.js index.wasm index.pck; do test -s "dist-neon/$name"; done
# Pages caps individual file size at 25 MiB. Godot's raw wasm may be over 25 MiB.
# Store compressed bytes and deliver them via the Pages Worker .wasm route.
# Browsers decode with Content-Encoding: gzip before WebAssembly instantiation.
python3 - <<'PY'
from pathlib import Path
import gzip, hashlib, shutil
root = Path("dist-neon")
wasm = root / "index.wasm"
raw_hash = hashlib.sha256(wasm.read_bytes()).hexdigest()
tmp = root / "index.wasm.gz.tmp"
with wasm.open("rb") as src, gzip.open(tmp, "wb", compresslevel=9) as dst:
    shutil.copyfileobj(src, dst, 1024 * 1024)
with gzip.open(tmp, "rb") as src:
    assert hashlib.sha256(src.read()).hexdigest() == raw_hash, "Wasm gzip roundtrip failed"
size = tmp.stat().st_size
assert size < 25 * 1024 * 1024, f"Wasm still exceeds Pages 25MiB limit: {size}"
# Keep this file explicitly named .gz. Cloudflare Pages automatically
# compresses other assets, so _headers alone causes double-compression.
tmp.replace(root / "index.wasm.gz")
wasm.unlink()
(root / "_headers").write_text(
    "/*\n"
    "  X-Robots-Tag: noindex\n",
    encoding="utf-8",
)
(root / "_worker.js").write_text("""export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    if (url.pathname === "/index.wasm") {
      if (request.method !== "GET" && request.method !== "HEAD") {
        return new Response("Method not allowed", {status: 405});
      }
      const packed = new URL("/index.wasm.gz", url);
      const asset = await env.ASSETS.fetch(new Request(packed, {
        headers: {"Accept-Encoding": "identity"}
      }));
      if (!asset.ok) return asset;
      // Cloudflare Workers' default automatic encoding double-gzips
      // pre-compressed assets. This must be sent with manual encoding.
      return new Response(request.method === "HEAD" ? null : asset.body, {
        status: 200,
        encodeBody: "manual",
        headers: {
          "Content-Type": "application/wasm",
          "Content-Encoding": "gzip",
          "Cache-Control": "public, max-age=0, must-revalidate, no-transform",
          "Vary": "Accept-Encoding",
          "Access-Control-Allow-Origin": "*"
        }
      });
    }
    return env.ASSETS.fetch(request);
  }
};
""", encoding="utf-8")
print(f"LEARNQUEST WASM GZIP VERIFIED: {size:,} bytes, SHA256 {raw_hash}")
PY
printf '%s\n' "${CF_PAGES_COMMIT_SHA:-$(git rev-parse HEAD)}" > dist-neon/build.txt
printf '%s\n' 'LearnQuest Neon City – GRAFIK-TESTVERSION, NICHT STABIL' > dist-neon/testversion.txt
printf 'User-agent: *\nDisallow: /\n' > dist-neon/robots.txt
touch dist-neon/.nojekyll
echo "LEARNQUEST NEON CITY ISOLATED GRAPHICS QA PASSED"
