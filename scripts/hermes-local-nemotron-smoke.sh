#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARTIFACT_DIR="${SAPPHIRE_ARTIFACT_DIR:-$ROOT_DIR/artifacts}"
HERMES_HOME_DIR="${HERMES_HOME_DIR:-$ARTIFACT_DIR/hermes-home}"
HERMES_BIN="${HERMES_BIN:-$(command -v hermes || true)}"

if [[ -z "$HERMES_BIN" ]]; then
  echo "HERMES_BIN is not set and hermes is not on PATH." >&2
  exit 1
fi

NEMOTRON_HOST="${NEMOTRON_HOST:-127.0.0.1}"
NEMOTRON_PORT="${NEMOTRON_PORT:-8080}"
NEMOTRON_API_KEY="${NEMOTRON_API_KEY:-}"
NEMOTRON_ALIAS="${NEMOTRON_ALIAS:-nemotron-nano-4b-q4km-local}"
NEMOTRON_CONTEXT_SIZE="${NEMOTRON_CONTEXT_SIZE:-65536}"
NEMOTRON_MAX_TOKENS="${NEMOTRON_MAX_TOKENS:-96}"
HERMES_MODEL_TIMEOUT_SECONDS="${HERMES_MODEL_TIMEOUT_SECONDS:-90}"
EXPECTED="SAPPHIRE HERMES NEMOTRON LINK ACTIVE"

if [[ -z "$NEMOTRON_API_KEY" ]]; then
  echo "NEMOTRON_API_KEY must be set." >&2
  exit 1
fi

"$ROOT_DIR/scripts/hermes-local-nemotron-health.sh" >/dev/null

mkdir -p "$HERMES_HOME_DIR"
cat > "$HERMES_HOME_DIR/config.yaml" <<EOF
model:
  provider: "custom"
  default: "${NEMOTRON_ALIAS}"
  base_url: "http://${NEMOTRON_HOST}:${NEMOTRON_PORT}/v1"
  api_key: "${NEMOTRON_API_KEY}"
  context_length: ${NEMOTRON_CONTEXT_SIZE}
  max_tokens: ${NEMOTRON_MAX_TOKENS}

providers:
  custom:
    request_timeout_seconds: ${HERMES_MODEL_TIMEOUT_SECONDS}
    stale_timeout_seconds: $((HERMES_MODEL_TIMEOUT_SECONDS * 2))

terminal:
  backend: "local"
  cwd: "."
  timeout: 180
EOF

export HERMES_HOME="$HERMES_HOME_DIR"
export OPENAI_API_KEY="$NEMOTRON_API_KEY"
export OPENAI_BASE_URL="http://${NEMOTRON_HOST}:${NEMOTRON_PORT}/v1"

nonce="$(date +%s)"
PROMPT="Smoke test nonce ${nonce}. Reply with exactly this text and nothing else: ${EXPECTED}"

tmp_out="$(mktemp)"
tmp_err="$(mktemp)"
trap 'rm -f "$tmp_out" "$tmp_err"' EXIT

start_epoch="$(date +%s)"
if ! "$HERMES_BIN" -z "$PROMPT" --provider custom --model "$NEMOTRON_ALIAS" --ignore-rules >"$tmp_out" 2>"$tmp_err"; then
  cat "$tmp_err" >&2
  exit 1
fi
end_epoch="$(date +%s)"

response="$(tr -d '\r' < "$tmp_out" | tail -n 1)"
if [[ "$response" != "$EXPECTED" ]]; then
  echo "unexpected Hermes response: $response" >&2
  cat "$tmp_err" >&2
  exit 1
fi

printf 'response=%s\n' "$response"
printf 'latency_seconds=%s\n' "$((end_epoch - start_epoch))"
