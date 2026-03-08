# Moodle

This is a wrapper Helm chart that depends on the upstream Bitnami Moodle chart. It exists to keep homelab-specific values in Git while pulling the upstream chart as a dependency.

## Defaults
- Hostname: `moodle.family.home.arpa`
- Namespace: `games-moodle`
- Routing: Gateway API `HTTPRoute` via Envoy Gateway (`family-gateway`)

## Secrets
Create these secrets out of band (see examples in `shared/secrets/examples/`):
- `moodle-secrets`
  - `moodle-password` (admin password)
  - `smtp-password` (SMTP password, optional if you do not use SMTP)
- `kids-games-moodle-mariadb`
  - `mariadb-root-password`
  - `mariadb-password`
- `moodle-oidc`
  - `MOODLE_OIDC_CLIENT_SECRET`

## Keycloak / OIDC configuration
- Issuer URL and client ID are set in `values.yaml` as environment variables.
- Client secret is loaded from the `moodle-oidc` Secret.
- You must enable and configure the OIDC plugin inside Moodle after the first deploy.
 - This repo uses the shared `homelab-apps` client for kids-games apps.

## Custom image
The wrapper values point to a custom Moodle image built from `images/moodle/`. That image is intended to bundle:
- OIDC/auth plugin support
- H5P
- Game plugin

## Manual post-deploy steps
- Log in as admin and complete the Moodle installer.
- Enable and configure the OIDC plugin.
- Enable H5P and any game-related plugins.
- Configure SMTP if you want outbound email.
