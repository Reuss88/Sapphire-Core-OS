# 2026-07-28 Hermes Local Nemotron Implementation Report

## Mission status

Completed on the measured local machine.

## Discovery summary

- Host OS: macOS 26.2
- CPU: Apple M2
- RAM: 8 GB unified memory
- GPU: Apple M2 integrated GPU, 10 cores, Metal 4
- VRAM: shared unified memory
- Free disk during implementation: about 31 GiB
- Hermes location: local checkout adjacent to this repository
- Hermes startup method: CLI `hermes`, with `--oneshot` used for deterministic smoke testing
- Hermes provider interface: OpenAI-compatible local endpoint through `model.provider: "custom"` with `model.base_url` and `model.api_key`
- Existing runtimes before implementation:
  - Ollama: absent
  - llama.cpp: absent
  - vLLM: absent
  - LM Studio: absent
  - Docker: absent

## Chosen runtime

- Runtime: `llama.cpp` server
- Runtime release: `b10166`
- Local endpoint method: `http://127.0.0.1:8080/v1`

## Chosen Nemotron model

- Repository: `nvidia/NVIDIA-Nemotron-3-Nano-4B-GGUF`
- Quantisation: `Q4_K_M`
- File: `NVIDIA-Nemotron3-Nano-4B-Q4_K_M.gguf`
- Local alias: `nemotron-nano-4b-q4km-local`
- Context size: `65536`

## Files created

- `.gitignore`
- `.env.example`
- `config/hermes/local-nemotron.config.yaml.example`
- `scripts/hermes-local-nemotron-bootstrap.sh`
- `scripts/hermes-local-nemotron-health.sh`
- `scripts/hermes-local-nemotron-smoke.sh`
- `docs/runtime/HERMES-LOCAL-NEMOTRON.md`
- `docs/reports/2026-07-28-hermes-local-nemotron-implementation.md`

## Files updated

- `README.md`

## Validation record

- Health-check result: passed against `http://127.0.0.1:8080`
- Smoke-test result: passed with exact response `SAPPHIRE HERMES NEMOTRON LINK ACTIVE`
- Response latency: about `105` seconds end to end through Hermes `--oneshot`
- Runtime memory snapshot after smoke: `2,835,360` KiB resident for `llama-server` on macOS
- VRAM usage: not separately measurable on this unified-memory Apple Silicon host

## Commands used

```bash
uname -a
sw_vers
sysctl -n machdep.cpu.brand_string hw.memsize
system_profiler SPDisplaysDataType
df -h /

./scripts/hermes-local-nemotron-health.sh
./scripts/hermes-local-nemotron-smoke.sh
```

## Security posture

- localhost binding only by default
- API key required by default
- local runtime artefacts excluded from Git
- no remote worker or paid API fallback

## Known limitations

- The selected model is the smallest viable Nemotron path for 8 GB unified memory hardware.
- Hermes rejected a 4,096-token runtime window, so the working local configuration had to advertise `65536`.
- End-to-end latency is high on this machine, but the path is functional and private.
- Better quality or faster responses will likely require a larger local machine or a future hosted provider module.
