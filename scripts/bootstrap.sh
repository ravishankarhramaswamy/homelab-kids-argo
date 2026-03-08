#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v kubectl >/dev/null 2>&1; then
  echo "ERROR: kubectl is required." >&2
  exit 1
fi

if grep -R "CHANGE_ME_REPO_URL" "${ROOT_DIR}/bootstrap" >/dev/null 2>&1; then
  echo "ERROR: Update CHANGE_ME_REPO_URL in bootstrap/*.yaml before bootstrapping." >&2
  exit 1
fi

echo "Applying root Argo CD application..."
kubectl apply -f "${ROOT_DIR}/bootstrap/root-application.yaml"

echo "Done. Monitor Argo CD for sync status."
