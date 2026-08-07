# Sapphire Engineering Framework

## Purpose

This directory governs how Sapphire Core OS is implemented by Codex and future engineering agents. It is development infrastructure only. It does not define product behaviour and must never override Broker OS doctrine, canonical architecture, Designers Instinct, Governance, or Director-approved parity references.

## Single Codex entrypoint

For every implementation mission, Codex starts with:

`engineering/START-HERE-CODEX.md`

The Director should not need to reteach Codex the framework. The simplest instruction is:

> Read `engineering/START-HERE-CODEX.md`, then execute `<mission-file>`.

## Framework files

- `START-HERE-CODEX.md` — mandatory entrypoint and shortest operating instruction.
- `WORKFLOW.md` — mission lifecycle, pre-flight, stop conditions and Mission Result.
- `IMPLEMENTATION-STANDARDS.md` — Next.js, TypeScript and implementation discipline.
- `DATABASE-STANDARDS.md` — Supabase, DDL, RPC, functions, triggers, RLS, realtime and audit rules.
- `UI-PARITY-STANDARDS.md` — Designers Instinct and Director-approved parity implementation rules.
- `SECURITY-SAFETY-STANDARDS.md` — secrets, authority, tenancy, mutation and migration safety.
- `TESTING-QUALITY-STANDARDS.md` — verification requirements and PASS discipline.
- `MISSION-TEMPLATE.md` — standard structure for future engineering missions.
- `REVIEW-TEMPLATE.md` — standard Director/engineering review record.
- `codex/AGENT-RULES.md` — Codex-specific behaviour inside Sapphire.

## Authority order

If instructions conflict, follow this precedence:

1. Director-approved locked doctrine / parity reference
2. Broker OS and canonical architecture
3. Designers Instinct and Sapphire Design System
4. Governance / authority architecture
5. Engineering Framework
6. Mission file
7. Existing implementation details
8. Agent preference

No lower layer may silently redefine a higher layer.

## Safe implementation rule

Inspect before modifying. Extend before replacing. Reuse before creating. Never duplicate systems of record.

## Mission location

Product-specific missions remain with their workspace doctrine, for example:

`designers-instinct/pages/actions/codex-mission-actions-v1.md`

The Engineering Framework supplies permanent execution rules so workspace missions remain focused on the feature being built rather than repeating engineering policy.

## Lifecycle

The framework remains in the repository as durable engineering governance. It is not runtime product code and should not be bundled into the client. After the initial product build it remains useful for maintenance, migrations, refactors, new workspaces and future engineering agents; it does not need to be deleted or archived merely because v1 ships.