SHELL := /bin/bash

.PHONY: help validate bootstrap-print lint tree

help:
	@echo "Targets:"
	@echo "  help             Show this help"
	@echo "  validate         Run local validation (helm)"
	@echo "  bootstrap-print  Print kubectl commands for bootstrap"
	@echo "  lint             Alias for validate"
	@echo "  tree             Print repo tree (depth 4)"

validate:
	@./scripts/validate.sh

bootstrap-print:
	@echo "kubectl apply -f bootstrap/root-application.yaml"
	@echo "# Ensure REPO_URL placeholders in bootstrap/*.yaml are updated before applying"

lint: validate

tree:
	@command -v tree >/dev/null 2>&1 && tree -a -L 4 || find . -maxdepth 4 -print | sed 's#^\./##'
