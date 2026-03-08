SHELL := /bin/bash

.PHONY: help validate bootstrap-print render-openedx lint tree

help:
	@echo "Targets:"
	@echo "  help             Show this help"
	@echo "  validate         Run local validation (helm/kustomize/yaml)"
	@echo "  bootstrap-print  Print kubectl commands for bootstrap"
	@echo "  render-openedx   Render Open edX manifests into applications/openedx/rendered"
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
