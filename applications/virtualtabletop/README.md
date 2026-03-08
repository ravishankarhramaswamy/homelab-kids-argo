# VirtualTabletop

Local Helm chart that deploys VirtualTabletop and protects it with an in-cluster oauth2-proxy instance.

## Defaults
- Hostname: `boardgames.family.home.arpa`
- Namespace: `games-virtualtabletop`
- Routing: Gateway API `HTTPRoute` via Envoy Gateway (`family-gateway`)
- oauth2-proxy is deployed in the same namespace and exposed on `/oauth2` under the same hostname.
- Image: `arnoldsmith86/virtualtabletop:latest`

## Secrets
Create this secret out of band (see examples in `shared/secrets/examples/`):
- `virtualtabletop-oauth2-proxy`
  - `client-secret`
  - `cookie-secret` (must be 16, 24, or 32 bytes)

## Auth flow
- Envoy Gateway routes `/oauth2/*` to oauth2-proxy and `/` to VirtualTabletop.
- oauth2-proxy handles OIDC with Keycloak and forwards to the app service.

## Keycloak / OIDC configuration
- Issuer URL and client ID live in `values.yaml`.
- Client and cookie secrets come from the `virtualtabletop-oauth2-proxy` Secret.
- Use `oauth2Proxy.oidc.allowedGroups` in `values.yaml` if you want group-based access control.
 - This repo uses the shared `homelab-apps` client for kids-games apps.

## Manual post-deploy steps
- Confirm the VirtualTabletop container image tag you want to run and pin it in `values.yaml`.
- Create the oauth2-proxy secret and verify login via Keycloak.
