#!/usr/bin/env bash
set -euo pipefail

: "${KOLIBRI_HOME:=/root/.kolibri}"
: "${KOLIBRI_PORT:=8080}"
: "${KOLIBRI_RUN_MIGRATIONS:=true}"

export KOLIBRI_HOME

if [ "${KOLIBRI_RUN_MIGRATIONS}" = "true" ]; then
  kolibri manage migrate --noinput
fi

exec kolibri start --foreground --port "${KOLIBRI_PORT}"
