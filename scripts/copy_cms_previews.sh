#!/usr/bin/env bash
# Publish the generated golden previews into the docs component-reference folder
# (the canonical, layout_name-named assets for the virpanai central marketplace).
#
# Run AFTER generating goldens:
#   flutter test test/cms_preview/cms_preview_golden_test.dart --update-goldens
#   bash scripts/copy_cms_previews.sh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/test/cms_preview/goldens"
DST="$ROOT/docs/component-reference"
mkdir -p "$DST"
count=0
for f in "$SRC"/*.png; do
  cp "$f" "$DST/$(basename "$f")"
  count=$((count + 1))
done
echo "Copied $count preview(s) -> docs/component-reference/"
