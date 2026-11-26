#!/usr/bin/env bash
# Build an itch.io-compatible ZIP from export/web (HTML5).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="${ROOT}/dist"
WEB="${ROOT}/export/web"
ZIP="${OUT_DIR}/baga-and-friends-web-itch.zip"

if [[ ! -f "${WEB}/index.html" ]]; then
  echo "Missing ${WEB}/index.html — run Godot Web export first." >&2
  exit 1
fi

mkdir -p "${OUT_DIR}"
rm -f "${ZIP}"
(cd "${WEB}" && zip -r9 "${ZIP}" .)
echo "Wrote ${ZIP}"
ls -lh "${ZIP}"
