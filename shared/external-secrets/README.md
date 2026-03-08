# External Secrets (ESO) + Vault

This directory defines External Secrets Operator resources that pull app secrets from Vault.

## Assumptions
- ESO is installed in the `external-secrets` namespace and uses the `external-secrets` ServiceAccount.
- Vault is reachable at `https://vault.family.home.arpa` from inside the cluster.
- Vault KV v2 mount is `secret`.
- Kids-games secrets live under `secret/homelab/kids-games/*`.
- Vault TLS is not trusted by default in-cluster, so the SecretStore uses `insecureSkipVerify: true`.
  Replace with a CA bundle if you want strict TLS.

## Vault policy
Create a Vault policy that allows read access to the kids-games paths:

```
path "secret/data/homelab/kids-games/*" {
  capabilities = ["read"]
}

path "secret/metadata/homelab/kids-games/*" {
  capabilities = ["read"]
}
```

## Vault Kubernetes auth
Enable and configure the Kubernetes auth backend (if not already enabled), then bind a role:

```
vault auth enable kubernetes

vault write auth/kubernetes/config \
  kubernetes_host="https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT" \
  kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
  token_reviewer_jwt=@/var/run/secrets/kubernetes.io/serviceaccount/token

vault write auth/kubernetes/role/kids-games-eso \
  bound_service_account_names=external-secrets \
  bound_service_account_namespaces=external-secrets \
  policies=kids-games-eso \
  ttl=1h
```

## Vault secret paths and keys
Create the KV secrets with the keys expected by each app:

```
# Moodle
vault kv put secret/homelab/kids-games/moodle-secrets \
  moodle-password=CHANGE_ME \
  smtp-password=CHANGE_ME

vault kv put secret/homelab/kids-games/moodle-mariadb \
  mariadb-root-password=CHANGE_ME \
  mariadb-password=CHANGE_ME

vault kv put secret/homelab/kids-games/moodle-oidc \
  MOODLE_OIDC_CLIENT_SECRET=CHANGE_ME

# Kolibri
vault kv put secret/homelab/kids-games/kolibri-oidc \
  client-secret=CHANGE_ME

# VirtualTabletop (oauth2-proxy)
vault kv put secret/homelab/kids-games/virtualtabletop-oauth2-proxy \
  client-secret=CHANGE_ME \
  cookie-secret=CHANGE_ME

# Open edX
vault kv put secret/homelab/kids-games/openedx-secrets \
  OPENEDX_SUPERUSER_PASSWORD=CHANGE_ME \
  MYSQL_ROOT_PASSWORD=CHANGE_ME \
  SMTP_PASSWORD=CHANGE_ME
```

## What gets created
- `ClusterSecretStore` named `vault-homelab`
- `ExternalSecret` resources in each app namespace for:
  - `moodle-secrets`, `moodle-mariadb`, `moodle-oidc`
  - `kolibri-oidc`
  - `virtualtabletop-oauth2-proxy`
  - `openedx-secrets`

If you change the Vault path or mount, update `clustersecretstore-vault.yaml` and the ExternalSecret `remoteRef.key` values.
