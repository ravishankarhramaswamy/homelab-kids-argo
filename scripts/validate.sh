#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "ERROR: '$1' is required but not installed." >&2
    exit 1
  fi
}

require_cmd helm
echo "==> Helm lint"
helm lint "${ROOT_DIR}/applications/wordpress-h5p"
helm lint "${ROOT_DIR}/applications/jclic"
helm lint "${ROOT_DIR}/applications/virtualtabletop"

echo "==> Helm template"
helm template "${ROOT_DIR}/applications/wordpress-h5p" >/dev/null
helm template "${ROOT_DIR}/applications/jclic" >/dev/null
helm template "${ROOT_DIR}/applications/virtualtabletop" >/dev/null

echo "Validation completed."
