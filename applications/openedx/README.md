# Open edX

This app is managed by Argo CD from committed, rendered Kubernetes manifests. We do not run Tutor inside Argo CD.

## How it works
- `scripts/render-openedx.sh` renders manifests via Tutor into `applications/openedx/rendered/`.
- Argo CD syncs the rendered manifests via the `applications/openedx/kustomization.yaml`.
- Local overrides should live in `applications/openedx/patches/` and be wired into `kustomization.yaml`.
- The render script also strips Ingress manifests and generates Gateway API `HTTPRoute` resources when service names are detected.

## Hostnames
- LMS host default: `openedx.family.home.arpa`
- CMS (Studio) host default: `studio.openedx.family.home.arpa`
- Update these in `scripts/render-openedx.sh` or pass `OPENEDX_LMS_HOST` / `OPENEDX_CMS_HOST` when rendering.

## Keycloak / third-party auth
- Open edX auth is more involved than the other apps.
- Use Tutor configuration for OAuth/SAML or third-party auth plugins.
- Keep secrets out of Git and create them separately (see `shared/secrets/examples/openedx-secrets.example.yaml`).
 - This repo assumes the shared `homelab-apps` client unless you override it in Tutor.

## Manual follow-up
- Install Tutor locally and ensure it can render Kubernetes manifests.
- Configure your Open edX site settings in Tutor before rendering.
- Verify services and HTTPRoute hostnames after Argo CD sync.
