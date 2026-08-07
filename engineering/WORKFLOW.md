# Safe Engineering Workflow

## Standard mission lifecycle

1. **Pre-flight** — inspect repository state, relevant doctrine, schema, routes, components, tokens, RPCs, types and tests.
2. **Conflict check** — identify contradictions, duplicate systems, migration risk or authority ambiguity before writing code.
3. **Plan** — state files to create/modify and implementation order. Do not redesign product doctrine.
4. **Implement** — smallest coherent change that satisfies the mission.
5. **Verify** — typecheck, lint, tests, build, accessibility, migration safety and parity checks as applicable.
6. **Report** — return a standard Mission Result.
7. **Director review** — required for visual/product approval gates.
8. **Lock** — only after Director approval may parity/design be treated as immutable reference.

## Pre-flight checklist

Codex must inspect for existing:

- routes and layouts;
- components and design primitives;
- database tables, views and enums;
- RPCs, SQL functions and triggers;
- RLS policies and grants;
- shared TypeScript types;
- fixtures and test utilities;
- audit/event systems;
- identity/permission models;
- workspace ownership rules;
- current migrations and naming conventions.

Do not duplicate an existing implementation because a mission uses different wording.

## Stop conditions

Pause implementation and report before proceeding if:

- doctrine conflicts with locked architecture;
- the requested write would destroy or replace a system of record;
- a migration cannot be made safely or idempotently;
- an authority boundary is unclear;
- a mission requires credentials or external services not available;
- a visual reference is required for parity but missing.

## Default delivery strategy

For new workspaces:

1. ship a Director-reviewable UI with typed deterministic fixtures if live backend contracts are not yet ready;
2. preserve the final typed interface expected from Supabase;
3. implement backend contracts only after existing schema has been mapped;
4. never encode permanent business rules only in frontend fixtures.

## Mission Result format

Codex must end every mission with:

- Status: PASS / PARTIAL / FAIL
- Mission ID
- Files created
- Files modified
- Components added/changed
- Database changes
- RPCs/functions/triggers/RLS changes
- Tests/checks run and results
- Known issues
- Deferred work
- Risks or doctrine conflicts
- Ready for Director Review: YES / NO
- Recommended next action
