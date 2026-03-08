ARG BASE_IMAGE=learningequality/kolibri:0.16.0
FROM ${BASE_IMAGE}

USER root

# Optional: install Kolibri OIDC plugin via pip package or URL.
# Example: --build-arg KOLIBRI_PLUGIN_PIP="kolibri-oidc"
ARG KOLIBRI_PLUGIN_PIP=""
RUN set -euo pipefail; \
    if [ -n "${KOLIBRI_PLUGIN_PIP}" ]; then \
      python -m pip install --no-cache-dir "${KOLIBRI_PLUGIN_PIP}"; \
    fi

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
