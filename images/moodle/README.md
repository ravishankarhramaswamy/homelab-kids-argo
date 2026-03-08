# Moodle image

This Dockerfile builds a Moodle image on top of the Bitnami base image and can bundle extra plugins at build time.

## Build args
- `BASE_IMAGE` (default: `bitnami/moodle:5.0.0-debian-12-r0`)
- `MOODLE_PLUGIN_URLS` (space-separated list of plugin zip URLs)

## Intended plugins
- OIDC/auth plugin
- H5P
- Game plugin

Provide the plugin zip URLs when building the image, then set the resulting image in `applications/moodle/values.yaml`.
