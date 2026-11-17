#!/usr/bin/env bash
# Independent Cloudflare Pages preview build for LearnQuest Blender PR #160.
# Builds ONLY the active feature branch, never modifies GitHub Pages or main.
set -euo pipefail

GODOT_VERSION=4.4.1
ENGINE="/tmp/Godot_v${GODOT_VERSION}-stable_linux.x86_64"
DOWNLOAD_ROOT="https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable"
OUTPUT_ROOT="${PWD}/blender-preview-dist"

if [ ! -x "$ENGINE" ]; then
  curl --fail --location --retry 4 --silent --show-error \
    "${DOWNLOAD_ROOT}/Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip" -o /tmp/learnquest-godot.zip
  unzip -qo /tmp/learnquest-godot.zip -d /tmp
  chmod +x "$ENGINE"
fi

TEMPLATE_DIR="${HOME}/.local/share/godot/export_templates/${GODOT_VERSION}.stable"
if [ ! -f "$TEMPLATE_DIR/web_release.zip" ]; then
  curl --fail --location --retry 4 --silent --show-error \
    "${DOWNLOAD_ROOT}/Godot_v${GODOT_VERSION}-stable_export_templates.tpz" -o /tmp/learnquest-templates.tpz
  mkdir -p "$TEMPLATE_DIR"
  unzip -qo /tmp/learnquest-templates.tpz -d /tmp/learnquest-templates
  cp /tmp/learnquest-templates/templates/* "$TEMPLATE_DIR/"
fi

test -s godot/assets/3d/learnquest_portal.glb
test -s godot/blender_race_integration_test.gd
mkdir -p "$OUTPUT_ROOT"

"$ENGINE" --headless --editor --path godot --quit
"$ENGINE" --headless --path godot --script res://blender_portal_test.gd | tee /tmp/blender-model-test.log
grep -Fq 'LEARNQUEST BLENDER PORTAL TEST PASSED' /tmp/blender-model-test.log
"$ENGINE" --headless --path godot --script res://blender_race_integration_test.gd | tee /tmp/blender-race-test.log
grep -Fq 'BLENDER RACE INTEGRATION TEST PASSED' /tmp/blender-race-test.log

"$ENGINE" --headless --path godot --export-release Web "$OUTPUT_ROOT/index.html"
for name in index.html index.js index.wasm index.pck; do
  test -s "$OUTPUT_ROOT/$name" || { echo "Missing preview asset: $name" >&2; exit 1; }
done

git rev-parse --verify HEAD > "$OUTPUT_ROOT/build.txt"
printf 'User-agent: *\nDisallow: /\n' > "$OUTPUT_ROOT/robots.txt"
printf 'LEARNQUEST BLENDER TESTVERSION — nicht die Live-Version\n' > "$OUTPUT_ROOT/preview-info.txt"
echo "Blender preview built from $(cat "$OUTPUT_ROOT/build.txt")"
