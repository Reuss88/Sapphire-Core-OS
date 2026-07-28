#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NEMOTRON_HOST="${NEMOTRON_HOST:-127.0.0.1}"
NEMOTRON_PORT="${NEMOTRON_PORT:-8080}"
NEMOTRON_API_KEY="${NEMOTRON_API_KEY:-}"
NEMOTRON_ALIAS="${NEMOTRON_ALIAS:-nemotron-nano-4b-q4km-local}"
HEALTH_URL="http://${NEMOTRON_HOST}:${NEMOTRON_PORT}/health"
MODELS_URL="http://${NEMOTRON_HOST}:${NEMOTRON_PORT}/v1/models"
max_attempts="${HEALTH_MAX_ATTEMPTS:-90}"

auth_header=()
if [[ -n "$NEMOTRON_API_KEY" ]]; then
  auth_header=(-H "Authorization: Bearer ${NEMOTRON_API_KEY}")
fi

attempt=1
while [[ "$attempt" -le "$max_attempts" ]]; do
  if curl -fsS "${auth_header[@]}" "$HEALTH_URL" >/dev/null 2>&1; then
    models_json="$(curl -fsS "${auth_header[@]}" "$MODELS_URL")"
    if printf '%s' "$models_json" | grep -Eq "${NEMOTRON_ALIAS}|NVIDIA-Nemotron"; then
      printf '%s\n' "$models_json"
      exit 0
    fi
  fi
  sleep 2
  attempt=$((attempt + 1))
done

echo "local Nemotron endpoint failed readiness checks at ${HEALTH_URL}" >&2
exit 1
