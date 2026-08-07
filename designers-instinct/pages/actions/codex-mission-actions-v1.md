# CODEX MISSION — Actions Workspace v1

## Repository
`Reuss88/Sapphire-Core-OS`

## Mission objective
Build the first production-grade **Actions** workspace for Sapphire Core OS using the existing architecture and design doctrine in this repository.

This is not a generic task manager. It is the execution engine for missions, tasks, follow-ups, waiting/blocking states, linked approvals/decisions, evidence and cross-workspace commercial work.

## Mandatory reading order
1. `designers-instinct/doctrine/actions-missions-doctrine.md`
2. `architecture/actions-execution/MASTER-ACTIONS-ARCHITECTURE-v1.md`
3. `designers-instinct/pages/actions/README.md`
4. `designers-instinct/pages/actions/page-doctrine.md`
5. `designers-instinct/pages/actions/information-architecture.md`
6. `designers-instinct/pages/actions/interaction-contract.md`
7. `designers-instinct/pages/actions/data-contract.md`
8. `designers-instinct/pages/actions/supabase-architecture.md`
9. `designers-instinct/pages/actions/design-tokens.md`
10. `designers-instinct/sapphire-design-system/`

## First rule
Inspect before implementing. Do not create parallel identity, organisation, audit, permissions, approval, document or communication systems if equivalents already exist.

## Phase A — Repository and schema reconnaissance
Document the actual current state before migration work:
- Next.js/app structure and existing component system;
- Supabase migration/schema conventions;
- auth/user/org/tenant primitives;
- Governance decision/authority/approval tables and RPCs;
- audit/event/outbox/realtime conventions;
- existing generic linking patterns;
- Documents and Inbox integration points if present.

If doctrine and current implementation conflict, preserve doctrine and report the conflict before destructive migration.

## Phase B — Soft-code Actions UI
Create the Actions route and component shell using typed realistic fixtures before requiring all backend work.

Required desktop structure:
- Actions command header;
- execution brief;
- lens rail: My Actions, Missions, Team, Approvals & Decisions, Waiting On, Overdue, Completed;
- ranked primary queue;
- mission summaries/context;
- right-side context inspector;
- create mission / create action flows;
- filter/search/sort/group controls.

The UI must use Sapphire Design System tokens. No generic default shadcn appearance, rainbow status headings, gamification or bright decorative colour.

## Phase C — Supabase implementation
Implement migrations only after mapping existing primitives.

Required domain model, adapted to existing naming conventions:
- action_missions
- action_items
- action_assignments
- action_dependencies
- action_links
- action_evidence
- action_events (append-only)
- action_saved_views

Do not store overdue as mutable status. Do not duplicate authoritative Governance approval/decision state.

Implement required SQL functions and RPCs from `supabase-architecture.md` and `data-contract.md`.

Mutation commands must be transactional, permission-checked, transition-validated, audit-writing and return authoritative state.

## Phase D — RLS and authority
Write explicit RLS policies and tests for:
- personal action visibility;
- team visibility;
- Director cross-team visibility;
- assignment vs permission distinction;
- protected authority-linked actions;
- append-only execution events;
- org isolation.

Actions must never grant authority because a user is assigned a task.

## Phase E — Realtime
Use project realtime/outbox conventions. Invalidate affected queues/mission summaries and refetch authoritative snapshots. Do not make raw realtime payloads the business source of truth.

## Phase F — Integration points
Wire safe links to owning workspaces. Minimum conceptual integrations:
- Inbox thread -> create follow-up/action;
- Market Radar accepted signal -> mission/action;
- Opportunity/Deal -> linked mission/action;
- Governance approval/decision -> executable linked action without duplicated approval truth;
- Documents -> completion evidence.

Use stubs/adapters where adjacent modules are not implemented; do not invent competing data stores.

## Phase G — Validation
Required before handoff:
- lint/typecheck/build pass;
- migration applies cleanly to target development database;
- RLS tests cover org/user/Director boundaries;
- illegal state transitions fail server-side;
- dependency cycle prevention works;
- evidence-required completion fails without evidence;
- Governance-linked approvals cannot be authorised through Actions alone;
- desktop, tablet and mobile/PWA layouts remain usable;
- no console errors.

## Deliverables
1. Actions route and components.
2. Typed fixture layer used only where backend data is unavailable.
3. Supabase migration(s), functions, RPCs, RLS and tests.
4. Integration adapters/links.
5. Implementation notes documenting doctrine-to-code mapping and any unresolved architecture conflicts.
6. Screenshots of the soft-coded desktop Actions view for Director review.

## Stop condition
This mission ends at the **Director-reviewable Actions soft build plus working execution infrastructure**. Do not invent a final pixel-parity visual design beyond the existing Sapphire Design System. The Director and Designers Instinct process will review the soft build and then lock any Actions parity spec separately.

## Non-negotiables
- No duplicate task systems.
- No duplicate approval system.
- No frontend-only execution truth.
- No hard deletion of audited history.
- No AI authority escalation.
- No schema guesses when repository inspection can answer the question.
- No redesign of HOME as part of this mission.
