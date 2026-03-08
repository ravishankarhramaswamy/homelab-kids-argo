ARG BASE_IMAGE=learningequality/kolibri:66b8239a56ede39f3068ccb4550c99a3cc430779
FROM ${BASE_IMAGE}

USER root

# Optional: install Kolibri OIDC plugin via pip package or URL.
# Example: --build-arg KOLIBRI_PLUGIN_PIP="kolibri-oidc"
ARG KOLIBRI_PLUGIN_PIP=""
RUN /bin/sh -c 'set -eu; \
    if [ -n "${KOLIBRI_PLUGIN_PIP}" ]; then \
      python -m pip install --no-cache-dir "${KOLIBRI_PLUGIN_PIP}"; \
    fi'

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
