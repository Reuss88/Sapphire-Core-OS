#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNTIME_DIR="${SAPPHIRE_RUNTIME_DIR:-$ROOT_DIR/.runtime}"
ARTIFACT_DIR="${SAPPHIRE_ARTIFACT_DIR:-$ROOT_DIR/artifacts}"
LLAMA_CPP_RELEASE="${LLAMA_CPP_RELEASE:-b10166}"
LLAMA_CPP_ARCHIVE_URL="${LLAMA_CPP_ARCHIVE_URL:-https://github.com/ggml-org/llama.cpp/releases/download/${LLAMA_CPP_RELEASE}/llama-${LLAMA_CPP_RELEASE}-bin-macos-arm64.tar.gz}"
LLAMA_CPP_DIR="$RUNTIME_DIR/llama.cpp"
LLAMA_CPP_EXTRACTED_DIR="$LLAMA_CPP_DIR/llama-${LLAMA_CPP_RELEASE}"
LLAMA_SERVER_BIN="$LLAMA_CPP_EXTRACTED_DIR/llama-server"
LOG_DIR="$ROOT_DIR/logs"
PID_FILE="$RUNTIME_DIR/llama-server.pid"
LOG_FILE="$LOG_DIR/llama-server.log"

NEMOTRON_HF_REPO="${NEMOTRON_HF_REPO:-nvidia/NVIDIA-Nemotron-3-Nano-4B-GGUF}"
NEMOTRON_HF_QUANT="${NEMOTRON_HF_QUANT:-Q4_K_M}"
NEMOTRON_HF_FILE="${NEMOTRON_HF_FILE:-NVIDIA-Nemotron3-Nano-4B-Q4_K_M.gguf}"
NEMOTRON_ALIAS="${NEMOTRON_ALIAS:-nemotron-nano-4b-q4km-local}"
NEMOTRON_HOST="${NEMOTRON_HOST:-127.0.0.1}"
NEMOTRON_PORT="${NEMOTRON_PORT:-8080}"
NEMOTRON_CONTEXT_SIZE="${NEMOTRON_CONTEXT_SIZE:-65536}"
NEMOTRON_API_KEY="${NEMOTRON_API_KEY:-}"

if [[ -z "$NEMOTRON_API_KEY" ]]; then
  echo "NEMOTRON_API_KEY must be set." >&2
  exit 1
fi

mkdir -p "$RUNTIME_DIR" "$ARTIFACT_DIR/hf-cache" "$LOG_DIR" "$LLAMA_CPP_DIR"

if [[ -f "$PID_FILE" ]]; then
  existing_pid="$(cat "$PID_FILE")"
  if kill -0 "$existing_pid" 2>/dev/null; then
    echo "llama-server already running with pid $existing_pid"
    exit 0
  fi
  rm -f "$PID_FILE"
fi

if [[ ! -x "$LLAMA_SERVER_BIN" ]]; then
  archive_path="$RUNTIME_DIR/llama.cpp-${LLAMA_CPP_RELEASE}.tar.gz"
  curl -L "$LLAMA_CPP_ARCHIVE_URL" -o "$archive_path"
  tar -xzf "$archive_path" -C "$LLAMA_CPP_DIR"
fi

export HF_HOME="${HF_HOME:-$ARTIFACT_DIR/hf-cache}"
export HUGGINGFACE_HUB_CACHE="${HUGGINGFACE_HUB_CACHE:-$ARTIFACT_DIR/hf-cache}"

nohup "$LLAMA_SERVER_BIN" \
  --hf-repo "${NEMOTRON_HF_REPO}:${NEMOTRON_HF_QUANT}" \
  --hf-file "$NEMOTRON_HF_FILE" \
  --alias "$NEMOTRON_ALIAS" \
  --host "$NEMOTRON_HOST" \
  --port "$NEMOTRON_PORT" \
  --cors-origins localhost \
  --api-key "$NEMOTRON_API_KEY" \
  -c "$NEMOTRON_CONTEXT_SIZE" \
  >"$LOG_FILE" 2>&1 &

echo $! > "$PID_FILE"

echo "started llama-server pid $(cat "$PID_FILE")"
echo "waiting for readiness..."
"$ROOT_DIR/scripts/hermes-local-nemotron-health.sh"
