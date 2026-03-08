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
require_cmd kustomize

echo "==> Helm lint"
helm lint --skip-deps "${ROOT_DIR}/applications/moodle"
helm lint "${ROOT_DIR}/applications/kolibri"
helm lint "${ROOT_DIR}/applications/virtualtabletop"

echo "==> Helm template"
if [ -d "${ROOT_DIR}/applications/moodle/charts" ]; then
  helm template "${ROOT_DIR}/applications/moodle" >/dev/null
else
  echo "Skipping Moodle template: dependencies not fetched (run 'helm dependency build applications/moodle')."
fi
helm template "${ROOT_DIR}/applications/kolibri" >/dev/null
helm template "${ROOT_DIR}/applications/virtualtabletop" >/dev/null

echo "==> Kustomize build (Open edX)"
if find "${ROOT_DIR}/applications/openedx/rendered" -type f \( -name "*.yaml" -o -name "*.yml" \) | grep -q .; then
  kustomize build "${ROOT_DIR}/applications/openedx" >/dev/null
else
  echo "Skipping Open edX build: no rendered manifests found."
fi

echo "Validation completed."
