# Keycloak client sync (kids-games)

This directory keeps the `homelab-apps` client updated in the `homelab` realm by appending the kids-games redirect URIs and web origins.

## How it works
- A ConfigMap includes a small Python script that calls the Keycloak Admin API.
- A Sync hook Job runs during Argo CD sync to merge redirect URIs and web origins into the existing `homelab-apps` client.
- A CronJob re-runs hourly to re-append URLs if another system (Terraform) re-imports the realm.
- The Job targets the Keycloak public hostname (`https://keycloak.family.home.arpa`) so browser-based auth flows match.

## Secrets
- `keycloak-initial-admin` (in `keycloak` namespace): provides admin `username` and `password`.
- `keycloak-oidc-client` (in `keycloak` namespace): provides the `homelab-apps` client secret.

## Notes
- This job merges new URLs and does not remove existing redirect URIs or web origins.
- If the client does not exist, it will be created using the secret from `keycloak-oidc-client`.
- Provide a CA bundle in the `keycloak-oidc-ca` ConfigMap (`ca.crt`) or set `KEYCLOAK_INSECURE_SKIP_VERIFY=true` if the Keycloak TLS certificate is not trusted by the cluster.
