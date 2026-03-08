# Architecture

This repository is a GitOps layout for a homelab Argo CD deployment that manages four applications:

- Moodle (Helm dependency wrapper)
- Kolibri (local Helm chart)
- VirtualTabletop (local Helm chart + oauth2-proxy)
- Open edX (rendered manifests managed by Kustomize)

## Control plane
- Argo CD runs in the `argocd` namespace.
- A single root Application (`kids-games-root`) syncs the bootstrap manifests.
- The bootstrap manifests define:
  - `kids-games` AppProject
  - `kids-games-apps` ApplicationSet
- ApplicationSet discovers apps from `applications/*` and renders one child Application per directory.

## Namespaces
- `games-moodle`
- `games-kolibri`
- `games-virtualtabletop`
- `games-openedx`

Namespaces are created automatically via `CreateNamespace=true`.

## Routing and TLS
- Routing is handled by Envoy Gateway using Gateway API `HTTPRoute` resources.
- Gateway name: `family-gateway` in namespace `envoy-gateway-system`.
- TLS is terminated by the gateway using the `gateway-tls` secret.
- Hostnames are subdomains of `family.home.arpa` by default and should match your wildcard DNS.

## Secrets
- Secrets are not stored in Git.
- Example secret manifests live in `shared/secrets/examples/`.
- Actual secret files should be created out of band and are gitignored.

## Open edX workflow
- Open edX manifests are rendered via Tutor and committed to `applications/openedx/rendered/`.
- Argo CD syncs the rendered output via Kustomize.
