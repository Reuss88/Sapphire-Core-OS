# Sapphire Core OS

Sapphire Core OS is a governed enterprise operating architecture and implementation foundation.

It is designed as three connected products:

1. **Sapphire Core Architecture Standard** — the canonical enterprise constitution and operating model.
2. **Sapphire Core Workbench** — the browser-based environment for navigating, maintaining, and governing the architecture.
3. **Sapphire Core Runtime** — the services, workflows, controls, data, evidence, and AI capabilities that implement the architecture.

## Repository version

**v0.1 — Repository Foundation**

This milestone establishes the canonical repository structure, governance rules, architecture index, contribution workflow, and implementation scaffolding.

## Start here

- [Master Architecture](architecture/MASTER-ARCHITECTURE.md)
- [Architecture Status](architecture/STATUS.md)
- [Repository Governance](GOVERNANCE.md)
- [Roadmap](docs/roadmap/ROADMAP.md)
- [Hermes Local Nemotron Runtime](docs/runtime/HERMES-LOCAL-NEMOTRON.md)
- [Hermes Local Nemotron Implementation Report](docs/reports/2026-07-28-hermes-local-nemotron-implementation.md)
- [Mission Debrief Bridge](debriefs/README.md)
- [Architecture Manifest](architecture-manifest.json)
- [Contributing](CONTRIBUTING.md)

## Locked architecture

The following areas are currently architecturally locked:

- Business Object Architecture
- Relationship Architecture
- Lifecycle & State Architecture
- LS-001 — Lifecycle Standard
- LS-002 — Lifecycle Pattern Library
- Workflow & Orchestration Architecture
- WS-001 — Workflow Standard
- WS-002 — Workflow Pattern Library
- WS-003 — Workflow Runtime Object Register
- WS-004 — Workflow Conformance Checklist

## Current design area

**Module 8 — Decision, Authority & Approval Architecture**

Completed:

- Pass 1 — Decision Foundations
- Pass 2 — Authority Architecture

Next:

- Pass 3 — Approval Architecture

## Development rule

No implementation may silently redefine locked architecture.

Applications, databases, workflows, APIs, permissions, and AI must conform to the canonical architecture rather than becoming independent sources of business truth.
