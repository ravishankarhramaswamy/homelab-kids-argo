# homelab-kids-argo

A production-leaning GitOps repository for a kids entertainment stack via Argo CD. It manages three apps:
- WordPress + H5P (activities, quizzes, puzzles)
- VirtualTabletop (board and card games, protected by oauth2-proxy)
- JClic.js (structured educational puzzles)

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

## Architecture summary
- `bootstrap/root-application.yaml` bootstraps the repo into Argo CD.
- `bootstrap/project.yaml` defines the `kids-games` AppProject.
- `bootstrap/applicationset.yaml` discovers apps in `applications/*`.
- Each app syncs automatically with prune + self-heal and `CreateNamespace=true`.
- Routing is handled via Envoy Gateway using Gateway API `HTTPRoute` resources.

## Folder structure
```
bootstrap/                Argo CD AppProject, ApplicationSet, root app
applications/             App definitions (Helm)
applications-disabled/    Disabled apps kept for reference
images-disabled/          Disabled custom images
shared/                   Shared manifests and secret examples
scripts/                  Bootstrap and validation helpers
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
- `wordpress-mariadb.example.yaml`
- `virtualtabletop-oauth2-proxy-secrets.example.yaml`
- `keycloak-oidc-client.example.yaml`

Real secret manifests should be created separately and are gitignored.

## External Secrets + Vault (ESO)
This repo includes ESO resources under `shared/external-secrets/` that pull secrets from Vault at `http://vault.vault.svc.cluster.local:8200`.
See `shared/external-secrets/README.md` for the Vault policy, Kubernetes auth role, and `vault kv put` commands.

## Known limitations
- WordPress uses the official image and expects the admin account to be created via the web installer.
- JClic.js ships as a static launcher; you must provide `.jclic.zip` activities under `/activities`.
- Keycloak realm import is still managed by Terraform; the Argo client sync only appends redirect URIs and web origins.

## Next steps
- Update hostnames and Gateway API settings in app values.
- Create secrets from the example templates.
- Upload JClic activities and set `content.projectUrl` in `applications/jclic/values.yaml`.
