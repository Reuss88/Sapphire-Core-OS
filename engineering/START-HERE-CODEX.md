# START HERE — Codex Engineering Entry Point

This is the single entry point for Codex and future engineering agents implementing Sapphire Core OS.

## Director shortcut

For any approved mission, the Director should only need to say:

> Read `engineering/START-HERE-CODEX.md`, then execute `<mission-file>` exactly as governed by the repository.

Example:

> Read `engineering/START-HERE-CODEX.md`, then execute `designers-instinct/pages/actions/codex-mission-actions-v1.md`.

No additional explanation of Sapphire engineering standards should be required.

## Mandatory load order

Before writing code, read:

1. `engineering/README.md`
2. `engineering/WORKFLOW.md`
3. `engineering/IMPLEMENTATION-STANDARDS.md`
4. `engineering/DATABASE-STANDARDS.md` when backend/data work is involved
5. `engineering/UI-PARITY-STANDARDS.md` when UI/design work is involved
6. `engineering/SECURITY-SAFETY-STANDARDS.md`
7. `engineering/TESTING-QUALITY-STANDARDS.md`
8. `engineering/codex/AGENT-RULES.md`
9. the named mission file
10. every doctrine, architecture and parity reference linked by that mission

## Pre-flight is mandatory

Inspect the actual repository before changing it. Detect existing routes, schema, migrations, RPCs, functions, triggers, RLS, components, tokens, types, tests, identity, audit, authority, communications and workflow primitives.

Do not duplicate existing systems because the mission uses different wording.

## Authority rule

Repository doctrine outranks implementation preference. Director-approved parity outranks redesign. Governance remains authoritative for permissions and approvals. Visibility, assignment and workflow state never imply authority.

## Safe change rule

Extend before replacing. Reuse before creating. Prefer additive, reversible changes. Destructive, authority-sensitive or system-of-record changes require explicit approval and a migration plan.

## Mission completion

Codex may report PASS only after running the mission-required checks and returning the Mission Result format from `engineering/WORKFLOW.md`.

If a genuine doctrine conflict, missing parity reference, destructive migration ambiguity or unresolved authority boundary remains, stop and report it precisely instead of guessing.