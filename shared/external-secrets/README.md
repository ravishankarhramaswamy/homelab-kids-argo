# External Secrets (ESO) + Vault

This directory defines External Secrets Operator resources that pull app secrets from Vault.

## Assumptions
- ESO is installed in the `external-secrets` namespace and uses the `external-secrets` ServiceAccount.
- Vault is reachable in-cluster via `http://vault.vault.svc.cluster.local:8200`.
  If your Service name/namespace differ, update `clustersecretstore-vault.yaml`.
- Vault KV v2 mount is `secret`.
- Kids-games secrets live under `secret/homelab/kids-games/*`.
- If you need to use the external hostname instead, ensure CoreDNS can resolve it from inside the cluster
  or add a stub domain, and configure TLS trust as needed.

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
# WordPress + H5P
vault kv put secret/homelab/kids-games/wordpress-mariadb \
  mariadb-root-password=CHANGE_ME \
  mariadb-password=CHANGE_ME

# VirtualTabletop (oauth2-proxy)
vault kv put secret/homelab/kids-games/virtualtabletop-oauth2-proxy \
  client-secret=CHANGE_ME \
  cookie-secret=CHANGE_ME  # must be 16, 24, or 32 bytes (32 chars recommended)
```

## What gets created
- `ClusterSecretStore` named `vault-homelab`
- ExternalSecret resources for `wordpress-mariadb` and `virtualtabletop-oauth2-proxy`.

If you change the Vault path or mount, update `clustersecretstore-vault.yaml` and the ExternalSecret `remoteRef.key` values.
