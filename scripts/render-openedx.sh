#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RENDER_DIR="${ROOT_DIR}/applications/openedx/rendered"
SCRATCH_DIR="$(mktemp -d)"

if ! command -v tutor >/dev/null 2>&1; then
  echo "ERROR: tutor is required to render Open edX manifests." >&2
  echo "Install Tutor and configure it before running this script." >&2
  exit 1
fi

OPENEDX_LMS_HOST="${OPENEDX_LMS_HOST:-openedx.family.home.arpa}"
OPENEDX_CMS_HOST="${OPENEDX_CMS_HOST:-studio.openedx.family.home.arpa}"
GATEWAY_NAME="${GATEWAY_NAME:-family-gateway}"
GATEWAY_NAMESPACE="${GATEWAY_NAMESPACE:-envoy-gateway-system}"
GATEWAY_SECTION="${GATEWAY_SECTION:-https}"

mkdir -p "${RENDER_DIR}" "${RENDER_DIR}/tmp/secrets" "${RENDER_DIR}/tmp/ingress"

# NOTE: Adjust these commands for your Tutor version and configuration.
# This script is intentionally conservative and avoids committing secrets.

echo "Rendering Open edX manifests with Tutor..."
tutor config save --set LMS_HOST="${OPENEDX_LMS_HOST}" --set CMS_HOST="${OPENEDX_CMS_HOST}"

TUTOR_ROOT="$(tutor config printroot)"
K8S_DIR="${TUTOR_ROOT}/env/k8s"

if [ ! -d "${K8S_DIR}" ]; then
  echo "ERROR: Expected Tutor k8s manifests in ${K8S_DIR}, but directory does not exist." >&2
  echo "Run 'tutor config save' and ensure Tutor is configured for k8s." >&2
  exit 1
fi

cp -R "${K8S_DIR}/." "${SCRATCH_DIR}/"

# Remove Secret manifests from the rendered output to keep secrets out of Git.
# Move any detected Secret manifests into rendered/tmp/secrets for manual handling.
while IFS= read -r -d '' file; do
  kinds="$(awk '/^kind: /{print $2}' "${file}" | sort -u | tr '\n' ' ')"
  if echo "${kinds}" | grep -q "Secret"; then
    if [ "${kinds}" = "Secret " ] || [ "${kinds}" = "Secret" ]; then
      mv "${file}" "${RENDER_DIR}/tmp/secrets/" || true
    else
      echo "WARNING: Secret mixed with other resources in ${file}. Review manually." >&2
    fi
  fi
done < <(find "${SCRATCH_DIR}" -type f \( -name "*.yaml" -o -name "*.yml" \) -print0)

# Remove Ingress manifests (Envoy Gateway handles routing).
while IFS= read -r -d '' file; do
  kinds="$(awk '/^kind: /{print $2}' "${file}" | sort -u | tr '\n' ' ')"
  if echo "${kinds}" | grep -q "Ingress"; then
    if [ "${kinds}" = "Ingress " ] || [ "${kinds}" = "Ingress" ]; then
      mv "${file}" "${RENDER_DIR}/tmp/ingress/" || true
    else
      echo "WARNING: Ingress mixed with other resources in ${file}. Review manually." >&2
    fi
  fi
done < <(find "${SCRATCH_DIR}" -type f \( -name "*.yaml" -o -name "*.yml" \) -print0)

# Replace the rendered directory contents (except tmp/ and .gitkeep)
find "${RENDER_DIR}" -mindepth 1 -maxdepth 1 ! -name "tmp" ! -name ".gitkeep" -exec rm -rf {} +

# Copy non-secret manifests into the render target
if find "${SCRATCH_DIR}" -type f \( -name "*.yaml" -o -name "*.yml" \) | grep -q .; then
  cp -R "${SCRATCH_DIR}"/* "${RENDER_DIR}/"
fi

rm -rf "${SCRATCH_DIR}"

extract_services() {
  find "${RENDER_DIR}" -type f \( -name "*.yaml" -o -name "*.yml" \) ! -path "${RENDER_DIR}/tmp/*" -print0 | while IFS= read -r -d '' file; do
    awk '
      BEGIN {in_service=0; in_metadata=0; in_ports=0; name=""; port=""}
      /^kind:[[:space:]]*Service/ {in_service=1; in_metadata=0; in_ports=0; name=""; port=""; next}
      in_service && /^metadata:/ {in_metadata=1; next}
      in_service && in_metadata && /^[[:space:]]+name:/ && name=="" {name=$2; next}
      in_service && /^[[:space:]]+ports:/ {in_ports=1; next}
      in_service && in_ports && /^[[:space:]]+port:/ && port=="" {port=$2; if (name!="") {print name\":\"port}; in_service=0; in_metadata=0; in_ports=0}
      /^---/ {in_service=0; in_metadata=0; in_ports=0; name=""; port=""}
      /^kind:/ {if ($2 != "Service") {in_service=0; in_metadata=0; in_ports=0; name=""; port=""}}
    ' "$file"
  done | sort -u
}

services="$(extract_services || true)"
lms_entry="$(printf '%s\n' "${services}" | awk -F: 'tolower($1) ~ /lms/ && tolower($1) !~ /cms|studio|worker/ {print; exit}')"
cms_entry="$(printf '%s\n' "${services}" | awk -F: 'tolower($1) ~ /cms|studio/ {print; exit}')"

if [ -n "${lms_entry}" ] && [ -n "${cms_entry}" ]; then
  lms_name="${lms_entry%%:*}"
  lms_port="${lms_entry##*:}"
  cms_name="${cms_entry%%:*}"
  cms_port="${cms_entry##*:}"

  cat > "${RENDER_DIR}/httproutes.yaml" <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: openedx-lms
  namespace: games-openedx
  labels:
    app.kubernetes.io/part-of: kids-games
    app.kubernetes.io/managed-by: argocd
    app.kubernetes.io/name: openedx
spec:
  parentRefs:
    - name: ${GATEWAY_NAME}
      namespace: ${GATEWAY_NAMESPACE}
      sectionName: ${GATEWAY_SECTION}
  hostnames:
    - ${OPENEDX_LMS_HOST}
  rules:
    - backendRefs:
        - name: ${lms_name}
          port: ${lms_port}
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: openedx-cms
  namespace: games-openedx
  labels:
    app.kubernetes.io/part-of: kids-games
    app.kubernetes.io/managed-by: argocd
    app.kubernetes.io/name: openedx
spec:
  parentRefs:
    - name: ${GATEWAY_NAME}
      namespace: ${GATEWAY_NAMESPACE}
      sectionName: ${GATEWAY_SECTION}
  hostnames:
    - ${OPENEDX_CMS_HOST}
  rules:
    - backendRefs:
        - name: ${cms_name}
          port: ${cms_port}
EOF
  echo "Generated HTTPRoutes for Open edX using services: ${lms_name} (port ${lms_port}) and ${cms_name} (port ${cms_port})."
else
  echo "WARNING: Could not detect LMS/CMS services for Open edX. HTTPRoutes not generated." >&2
fi

rendered_files="$(find "${RENDER_DIR}" -type f \( -name "*.yaml" -o -name "*.yml" \) ! -path "${RENDER_DIR}/tmp/*" ! -name "kustomization.yaml" | sed "s#${RENDER_DIR}/##" | sort)"
if [ -n "${rendered_files}" ]; then
  {
    echo "apiVersion: kustomize.config.k8s.io/v1beta1"
    echo "kind: Kustomization"
    echo "resources:"
    while IFS= read -r f; do
      echo "  - ${f}"
    done <<< "${rendered_files}"
  } > "${RENDER_DIR}/kustomization.yaml"
fi

echo "Rendered manifests updated in ${RENDER_DIR}"
