# Kolibri

Local Helm chart for Kolibri with a custom container image that can include the OIDC client plugin.

## Defaults
- Hostname: `kolibri.family.home.arpa`
- Namespace: `games-kolibri`
- Data path: `/root/.kolibri` (PVC-backed)
 - Routing: Gateway API `HTTPRoute` via Envoy Gateway (`family-gateway`)

## Secrets
Create these out of band (see examples in `shared/secrets/examples/`):
- `kolibri-oidc`
  - `client-secret`

## Keycloak / OIDC configuration
- Issuer URL, client ID, and redirect URL live in `values.yaml`.
- Client secret is loaded from the `kolibri-oidc` Secret.
- You still need to enable the OIDC plugin and finish configuration inside Kolibri after first boot.
 - This repo uses the shared `homelab-apps` client for kids-games apps.

## PVC notes
- The PVC is created by the chart when `persistence.enabled=true`.
- Adjust size and storage class in `values.yaml`.

## Manual post-deploy steps
- Create an admin user in Kolibri.
- Enable and configure the OIDC plugin in Kolibri.
- Verify that the redirect URL matches your HTTPRoute hostname.
