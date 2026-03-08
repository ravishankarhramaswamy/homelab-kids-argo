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

## WordPress + H5P
- Uses native WordPress accounts by default.
- If you want SSO, install an OIDC plugin in WordPress and reuse `homelab-apps`.

## VirtualTabletop
- VirtualTabletop itself has no user system.
- oauth2-proxy handles OIDC with Keycloak in front of the app.
- Client and cookie secrets come from `virtualtabletop-oauth2-proxy` Secret.

## JClic.js
- Static content only; no auth by default.
- If you want auth, add an oauth2-proxy sidecar or put it behind an auth gateway.
