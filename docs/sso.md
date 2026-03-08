# SSO / Keycloak model

This repo uses a single shared OIDC client (`homelab-apps`) in the `homelab` realm.
Issuer: `https://keycloak.family.home.arpa/realms/homelab`.

Keycloak URLs are hostname-based to match browser flows, so in-cluster DNS and TLS
trust must work for `keycloak.family.home.arpa`.

## Client management
- Terraform owns the Keycloak realm import.
- Argo CD runs a sync hook Job plus an hourly CronJob from `shared/keycloak/kids-games-client-sync.yaml`.
- The job appends redirect URIs and web origins for kids-games apps to the existing `homelab-apps` client.
- It only appends and never removes existing entries.

## Moodle
- Uses a Moodle OIDC/auth plugin.
- Issuer URL and client ID are provided via values.
- Client secret should be stored in `moodle-oidc` Secret (`MOODLE_OIDC_CLIENT_SECRET`).
- Plugin configuration is finalized in the Moodle UI after deployment.

## Kolibri
- Uses a Kolibri OIDC plugin installed in the custom image.
- Issuer URL and client ID are provided via values.
- Client secret comes from `kolibri-oidc` Secret (`client-secret`).
- Plugin configuration is finalized in the Kolibri UI.

## VirtualTabletop
- VirtualTabletop itself has no user system.
- oauth2-proxy handles OIDC with Keycloak in front of the app.
- Client and cookie secrets come from `virtualtabletop-oauth2-proxy` Secret.

## Open edX
- Open edX requires Tutor-level configuration for OAuth/SAML or other third-party auth.
- Treat this as an advanced setup step and keep secrets out of Git.
- You can reuse `homelab-apps` if your Tutor config uses matching redirect URIs.
