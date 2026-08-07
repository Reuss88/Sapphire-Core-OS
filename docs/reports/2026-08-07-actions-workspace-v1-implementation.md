# Actions Workspace v1 — Implementation Notes

## Mission

Implementation of `designers-instinct/pages/actions/codex-mission-actions-v1.md` (`ACTIONS-001`).

## Pre-flight and reuse decisions

The mission was restarted from the current Engineering Framework and revalidated after `SUPABASE-DEV-RUNTIME-001` and `IDENTITY-ACCESS-001` passed. Actions reuses, rather than recreates:

- `sca_identity.actor`, organisation membership, team membership and capability grants;
- `sca_identity.current_actor_id()` and `sca_identity.has_capability()` for server-resolved identity and access;
- `sca_governance.authority_rule`, `authority_grant` and `has_authority()` for protected execution;
- the existing immutable audit conventions and local Supabase runtime.

Actions stores actor IDs, not authentication user IDs. Assignment can make an item visible, but never supplies mutation authority. Cross-team Director access is a canonical `actions.director.view` capability, not a role-label comparison.

## Web implementation

`apps/web` is a Next.js 16 App Router soft build with strict TypeScript and deterministic typed fixtures. `/actions` provides:

- command header and execution brief;
- all seven canonical lenses;
- ranked actions with search, priority filtering, due/rank sorting and mission/priority/owner grouping;
- mission summaries with distinct health, progress, blockers, value exposure and milestones;
- action and mission context inspectors;
- structured create-action and create-mission previews;
- linked owning-workspace records and guarded mutation commands;
- desktop three-zone, tablet overlay and mobile bottom-sheet layouts;
- a standalone web manifest and reduced-motion/focus-visible support.

Fixture interactions cannot mutate execution truth. They explain that a canonical RPC connection is required. Supabase repository and invalidation adapters preserve the integration boundary without creating another store.

## Database implementation

Migrations:

- `20260807010100_actions_foundation.sql`
- `20260807010200_actions_rpcs.sql`
- `20260807010300_actions_rls_realtime.sql`

Authoritative records:

- `sca_core.action_mission`
- `sca_core.action_item`
- `sca_core.action_assignment`
- `sca_core.action_dependency`
- `sca_core.action_link`
- `sca_core.action_evidence`
- `sca_core.action_saved_view`
- `sca_audit.action_event`

All cross-record relationships are organisation-scoped. Overdue remains derived. Approval and decision items require an owning Governance reference; protected commands pass a declared authority subject, decision class, limits and context to canonical Governance evaluation. Governance-linked items cannot be authorised or completed inside Actions.

Mutation RPCs are transactional, transition-validating, capability/authority checked and event-writing. Read RPCs provide personal, Director, mission detail, item detail and team-load projections. Direct mutation grants are revoked except for an actor's own saved views.

RLS covers personal ownership/creation, explicit assignment visibility, team visibility through accessible teams plus `actions.team.read`, cross-team Director visibility, organisation isolation, service-role reads and immutable events. Realtime table events are invalidation signals only; clients refetch authoritative projections.

## Doctrine-to-code mapping

| Doctrine | Implementation |
|---|---|
| Missions are outcome-bound | mission objective, success criteria, target, health and progress contracts |
| Overdue is derived | `action_compute_due_state`; no overdue status exists |
| Invalid transitions fail server-side | item and mission transition validators invoked by RPCs |
| Assignment is not authority | assignment visibility test plus independent capability/authority checks |
| Dependencies cannot cycle | recursive `action_dependency_would_cycle` gate |
| Evidence-required completion | `actions_complete_item_v1` rejects completion without evidence |
| Governance remains authoritative | protected context uses `sca_governance.has_authority`; approval/decision completion is rejected |
| Audit is immutable | transactional `action_write_event` and mutation-rejection trigger |
| Realtime is invalidation | publication registration plus typed client invalidation keys |
| Rank is explainable | rank score/factors are returned and visible in the inspector |
| Quiet Power | Sapphire tokens, matte surfaces and restrained semantic accents |

## Validation evidence

Executed against the local Supabase runtime on 7 August 2026:

- `scripts/supabase-dev.sh static-check` — PASS
- `scripts/supabase-dev.sh reset` — PASS; all migrations applied cleanly
- `scripts/supabase-dev.sh test` — PASS; Actions, business-object, identity/access and relationship SQL suites
- `scripts/supabase-dev.sh lint` — PASS; zero schema errors
- `pnpm typecheck` — PASS
- `pnpm lint` — PASS
- `pnpm test` — PASS; UI contract and schema/RPC/RLS validator
- `pnpm build` — PASS; `/actions` and `/manifest.webmanifest` statically generated

The Actions SQL suite proves legal/illegal transitions, derived overdue state, dependency cycle prevention, evidence gating, Governance ownership, protected-authority denial, team visibility, assignment-without-mutation, Director cross-team visibility, organisation isolation and event immutability.

## Intentional boundary

The Director-reviewable UI remains fixture-backed until the authenticated application shell supplies a live Supabase session and repository. This is the mission's approved soft-code boundary, not a second execution system. Backend migrations, RPCs, RLS and architecture tests are live and passing.

Owning workspaces remain authoritative for Governance, Inbox, Market Radar, Opportunities, Deals and Documents. Actions holds typed references and adapters only.
