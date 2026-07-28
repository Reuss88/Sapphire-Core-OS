# Hermes Local Nemotron Integration

## Objective

Connect a local Hermes agent to a local-only Nemotron inference path without any Cloudflare Worker, hosted proxy, or public model service.

## Measured host for the first implementation

- Date: 2026-07-28
- Host OS: macOS 26.2
- CPU: Apple M2
- RAM: 8 GB unified memory
- GPU: Apple M2 integrated GPU, 10 cores, Metal 4
- VRAM: shared with unified memory; no discrete VRAM pool
- Free disk at implementation time: about 31 GiB on `/`
- Existing local runtimes before implementation:
  - `ollama`: not installed
  - `llama.cpp`: not installed
  - `vllm`: not installed
  - `LM Studio`: not installed
  - `Docker`: not installed
- Hermes codebase location during implementation:
  - local checkout adjacent to this repository
- Hermes startup method during implementation:
  - CLI launcher script `hermes`
  - non-interactive smoke path uses `hermes --oneshot`

## Hermes provider surface

Hermes already supports:

- `model.provider: "custom"`
- `model.base_url`
- `model.api_key`
- OpenAI-compatible local endpoints
- per-provider request and stale timeouts

That makes a local `llama.cpp` server the smallest conformant runtime on this hardware.

## Chosen runtime and model

- Runtime: `llama.cpp` server
- Runtime release pin: `b10166`
- Model family: Nemotron
- Model pin: `nvidia/NVIDIA-Nemotron-3-Nano-4B-GGUF`
- Quantisation pin: `Q4_K_M`
- Exact file pin: `NVIDIA-Nemotron3-Nano-4B-Q4_K_M.gguf`
- Local alias: `nemotron-nano-4b-q4km-local`
- Bind address: `127.0.0.1`
- Default port: `8080`
- Default context size: `65536`

## Why this option was selected

This host has only 8 GB unified memory and no existing inference runtime. A local `llama.cpp` server:

- stays localhost-only by default;
- exposes an OpenAI-compatible API Hermes can already consume;
- avoids Docker and remote workers;
- supports pinned GGUF weights;
- fits the measured machine better than heavier Nemotron variants.

## Repository artefacts

- Config example:
  - `config/hermes/local-nemotron.config.yaml.example`
- Runtime bootstrap:
  - `scripts/hermes-local-nemotron-bootstrap.sh`
- Health check:
  - `scripts/hermes-local-nemotron-health.sh`
- End-to-end smoke test:
  - `scripts/hermes-local-nemotron-smoke.sh`
- Environment example:
  - `.env.example`
- Implementation report:
  - `docs/reports/2026-07-28-hermes-local-nemotron-implementation.md`

## Setup

1. Copy `.env.example` to `.env` or export the variables in your shell.
2. Set a local-only `NEMOTRON_API_KEY`.
3. Ensure `HERMES_BIN` points to an installed Hermes CLI if `hermes` is not on your `PATH`.
4. Start the local runtime:

```bash
./scripts/hermes-local-nemotron-bootstrap.sh
```

5. Verify health:

```bash
./scripts/hermes-local-nemotron-health.sh
```

6. Run the end-to-end Hermes smoke test:

```bash
./scripts/hermes-local-nemotron-smoke.sh
```

## Shutdown

If the runtime was started by the bootstrap script, stop it with:

```bash
kill "$(cat .runtime/llama-server.pid)"
```

## Failure behaviour

The scripts fail clearly when:

- `NEMOTRON_API_KEY` is missing
- the local runtime is offline
- the model has not loaded
- the endpoint is unreachable
- Hermes is not installed or `HERMES_BIN` is unset
- Hermes returns any text other than the required smoke acknowledgement

No script falls back to a hosted provider.

## Security posture

- The runtime binds to `127.0.0.1` by default.
- CORS is restricted to `localhost`.
- The runtime requires an API key.
- The repository ignores local `.env`, runtime caches, model artefacts, Hermes home state, and logs.
- Downloaded model weights are treated as external artefacts under ignored paths.

## Troubleshooting

### Hermes cannot connect

- Confirm `./scripts/hermes-local-nemotron-health.sh` passes.
- Confirm `HERMES_BIN` points to the Hermes installation you intend to test.
- Confirm the Hermes config uses `provider: "custom"` and the same endpoint as the runtime.

### Runtime starts but the model never becomes ready

- Check `logs/llama-server.log`.
- Confirm there is enough free disk for the GGUF download and cache.
- Hermes requires a minimum advertised context window of `65536`, so the runtime defaults to `65536` even on this smaller machine.
- If memory pressure appears, keep the 4B Q4 model and reduce concurrent activity before changing the context lower than Hermes accepts.

### Response quality or latency is weak

- This implementation intentionally chooses the smallest viable local Nemotron path for the measured machine.
- For higher quality, move to a machine with more memory and re-evaluate a larger Nemotron variant without changing Hermes core behaviour.
