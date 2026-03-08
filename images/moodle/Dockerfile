ARG BASE_IMAGE=bitnamilegacy/moodle:5.0.2-debian-12-r2
FROM ${BASE_IMAGE}

USER root

# Install tooling needed to unpack Moodle plugin archives.
RUN install_packages curl unzip

# Provide plugin URLs at build time (space-separated) to install OIDC, H5P, and game plugins.
# Example:
#   --build-arg MOODLE_PLUGIN_URLS="https://example/oidc.zip https://example/h5p.zip"
ARG MOODLE_PLUGIN_URLS=""
RUN set -euo pipefail; \
    if [ -n "${MOODLE_PLUGIN_URLS}" ]; then \
      for url in ${MOODLE_PLUGIN_URLS}; do \
        echo "Installing Moodle plugin from ${url}"; \
        curl -fsSL "${url}" -o /tmp/plugin.zip; \
        unzip -q /tmp/plugin.zip -d /opt/bitnami/moodle; \
        rm -f /tmp/plugin.zip; \
      done; \
    fi; \
    chown -R 1001:1001 /opt/bitnami/moodle

USER 1001
