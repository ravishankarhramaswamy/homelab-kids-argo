SHELL := /bin/bash

.PHONY: help validate bootstrap-print render-openedx lint tree image-moodle image-kolibri images

help:
	@echo "Targets:"
	@echo "  help             Show this help"
	@echo "  validate         Run local validation (helm/kustomize/yaml)"
	@echo "  bootstrap-print  Print kubectl commands for bootstrap"
	@echo "  render-openedx   Render Open edX manifests into applications/openedx/rendered"
	@echo "  image-moodle     Build and push Moodle image"
	@echo "  image-kolibri    Build and push Kolibri image"
	@echo "  images           Build and push all custom images"
	@echo "  lint             Alias for validate"
	@echo "  tree             Print repo tree (depth 4)"

validate:
	@./scripts/validate.sh

bootstrap-print:
	@echo "kubectl apply -f bootstrap/root-application.yaml"
	@echo "# Ensure REPO_URL placeholders in bootstrap/*.yaml are updated before applying"

render-openedx:
	@./scripts/render-openedx.sh

lint: validate

tree:
	@command -v tree >/dev/null 2>&1 && tree -a -L 4 || find . -maxdepth 4 -print | sed 's#^\./##'

DOCKER ?= docker
PLATFORM ?= linux/amd64
IMAGE_TAG ?= latest
REGISTRY ?= ghcr.io

MOODLE_IMAGE ?= $(REGISTRY)/ravishankarhramaswamy/homelab-kids-moodle:$(IMAGE_TAG)
KOLIBRI_IMAGE ?= $(REGISTRY)/ravishankarhramaswamy/homelab-kids-kolibri:$(IMAGE_TAG)

MOODLE_BUILD_ARGS :=
ifneq ($(strip $(MOODLE_PLUGIN_URLS)),)
MOODLE_BUILD_ARGS += --build-arg MOODLE_PLUGIN_URLS="$(MOODLE_PLUGIN_URLS)"
endif

KOLIBRI_BUILD_ARGS :=
ifneq ($(strip $(KOLIBRI_PLUGIN_PIP)),)
KOLIBRI_BUILD_ARGS += --build-arg KOLIBRI_PLUGIN_PIP="$(KOLIBRI_PLUGIN_PIP)"
endif

image-moodle:
	@$(DOCKER) buildx build \
		--platform $(PLATFORM) \
		$(MOODLE_BUILD_ARGS) \
		-t $(MOODLE_IMAGE) \
		--push images/moodle

image-kolibri:
	@$(DOCKER) buildx build \
		--platform $(PLATFORM) \
		$(KOLIBRI_BUILD_ARGS) \
		-t $(KOLIBRI_IMAGE) \
		--push images/kolibri

images: image-moodle image-kolibri
