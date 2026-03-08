# Kolibri image

This Dockerfile builds a Kolibri image with optional OIDC plugin installation.

## Build args
- `BASE_IMAGE` (default: `learningequality/kolibri:66b8239a56ede39f3068ccb4550c99a3cc430779`)
- `KOLIBRI_PLUGIN_PIP` (pip package or URL for the OIDC plugin)

## Runtime env
- `KOLIBRI_HOME` (default: `/root/.kolibri`)
- `KOLIBRI_PORT` (default: `8080`)
- `KOLIBRI_RUN_MIGRATIONS` (default: `true`)
