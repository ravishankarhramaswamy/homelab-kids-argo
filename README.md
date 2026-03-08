# homelab-kids-argo

A production-leaning GitOps repository for deploying a kids-oriented learning and games stack via Argo CD. It manages four apps:
- Moodle
- Kolibri
- VirtualTabletop
- Open edX

## What this repo is for
- A clean, extendable Argo CD GitOps layout.
- A single root application plus an ApplicationSet that discovers child apps from `applications/*`.
- Homelab-friendly defaults with explicit namespaces and placeholders for domains and secrets.

## Assumptions
- Argo CD is installed in the `argocd` namespace.
- Envoy Gateway is installed in `envoy-gateway-system` with a `family-gateway` listener for `*.family.home.arpa`.
- TLS is managed by cert-manager or equivalent (`gateway-tls` secret).
- Keycloak is the identity provider for OIDC (`https://keycloak.family.home.arpa/realms/homelab`).
- The Keycloak hostname resolves and is TLS-trusted from inside the cluster.
- Custom images are pushed to `ghcr.io/ravishankarhramaswamy/` with tags you control (defaults set to `latest`).

## Architecture summary
- `bootstrap/root-application.yaml` bootstraps the repo into Argo CD.
- `bootstrap/project.yaml` defines the `kids-games` AppProject.
- `bootstrap/applicationset.yaml` discovers apps in `applications/*`.
- Each app syncs automatically with prune + self-heal and `CreateNamespace=true`.
- Routing is handled via Envoy Gateway using Gateway API `HTTPRoute` resources.

## Folder structure
```
bootstrap/                Argo CD AppProject, ApplicationSet, root app
applications/             App definitions (Helm and Kustomize)
images/                   Custom Dockerfiles for Moodle and Kolibri
shared/                   Shared manifests and secret examples
scripts/                  Bootstrap, validation, and render helpers
docs/                     Architecture and SSO documentation
```

## Bootstrapping Argo CD
1. If you fork this repo, update `repoURL` in:
   - `bootstrap/project.yaml`
   - `bootstrap/applicationset.yaml`
   - `bootstrap/root-application.yaml`
2. Apply the root application:
   - `kubectl apply -f bootstrap/root-application.yaml`
3. Argo CD will create the AppProject and ApplicationSet, then sync child apps.

You can also run:
```
./scripts/bootstrap.sh
```

## Root application creation
The root application is defined in `bootstrap/root-application.yaml`. Apply it once; Argo CD will manage everything else.

## Secrets (out of band)
Secrets are not committed to Git. Example manifests live in `shared/secrets/examples/`:
- `moodle-secrets.example.yaml`
- `kolibri-secrets.example.yaml`
- `virtualtabletop-oauth2-proxy-secrets.example.yaml`
- `openedx-secrets.example.yaml`
- `keycloak-oidc-client.example.yaml`

Real secret manifests should be created separately and are gitignored.

## Open edX differences
Open edX is managed as rendered manifests (Kustomize) rather than a Helm chart. Use `scripts/render-openedx.sh` to render with Tutor and commit the output to `applications/openedx/rendered/`.

## Known limitations
- Pin image tags and update image repositories if you do not use GHCR under the same GitHub owner.
- Custom images for Moodle and Kolibri must be built and pushed.
- Open edX requires local Tutor configuration and rendering before Argo CD can sync.
- Keycloak realm import is still managed by Terraform; the Argo client sync only appends redirect URIs and web origins.

## Next steps
- Update hostnames and Gateway API settings in app values.
- Create secrets from the example templates.
- Build and push the custom images.
- Render Open edX manifests and commit them.
