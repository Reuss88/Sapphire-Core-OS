# Dashboard Landing — Codex Handoff Contract

## Objective

Build the first Director-reviewable Dashboard Landing surface for Sapphire Core OS as a Next.js 16 App Router PWA, while preserving a clean path to a future Capacitor wrapper.

Codex must treat the doctrine in this directory as authoritative. It may not invent business rules, authority, record ownership, metric definitions or Supabase schema to make the screen look complete.

## Required reading order

1. `designers-instinct/README.md`
2. `designers-instinct/dashboard-landing-principles.md`
3. `designers-instinct/product-surface-map.md`
4. `designers-instinct/parity-laws-v0.md`
5. this directory's `page-doctrine.md`
6. `surface-contract.md`
7. `data-contract.md`
8. `design-tokens.md`
9. relevant Broker OS, architecture and Supabase doctrine already present in the repository.

## Delivery sequence

### Stage 1 — Contract mapping

Produce a short implementation map showing:

- route and component tree;
- widget-to-workspace ownership;
- widget-to-data-contract mapping;
- required existing tables/views/functions that can be reused;
- schema gaps requiring migrations;
- permission and RLS dependencies;
- unresolved doctrine conflicts.

Do not generate speculative migrations before this map is complete.

### Stage 2 — Director design surface

Create the first functional landing design using governed fixture data or typed mocks when backend contracts are not yet available.

The design must include:

- command header;
- Director Attention Queue;
- Commercial Movement;
- Emerging Value;
- Workspace Pulse;
- Performance Context;
- AI Briefing;
- loading, empty, stale, partial, error and offline states;
- responsive desktop, tablet and mobile behaviour.

Fixture data must be clearly isolated and must not masquerade as production Supabase integration.

### Stage 3 — Director approval

The Director reviews:

- information priority;
- commercial clarity;
- page hierarchy;
- widget usefulness;
- drill-down logic;
- token meaning;
- mobile experience.

Approval locks the first page contract sufficiently to begin backend implementation. Visual refinement may continue without changing commercial meaning.

### Stage 4 — Supabase implementation

Only after contract mapping and Director approval:

- create ordered migrations;
- add or reuse authorised read models;
- implement `dashboard_get_director_snapshot_v1`;
- add required helper functions and indexes;
- add transactional outbox/event integration where source workspaces require it;
- enable and test RLS;
- add grants explicitly;
- add RPC and policy contract tests;
- document forward-fix or rollback strategy.

Do not create a duplicated dashboard-owned copy of commercial records.

### Stage 5 — Live integration

Replace fixtures with typed server-side RPC access. Add controlled realtime invalidation, stale/offline handling, telemetry and error boundaries.

## Next.js 16 requirements

- App Router route at `/dashboard`;
- server-first data loading for the initial authorised snapshot;
- client components only where interaction or subscription requires them;
- strict TypeScript;
- schema validation at the RPC boundary;
- accessible HTML and keyboard interaction;
- no hidden business calculations in React components;
- route-level and widget-level error handling;
- URL-preserved scope/period filters where appropriate.

## PWA requirements

- installable manifest and appropriate icons supplied by the product asset system;
- offline app shell;
- cached read-only last-successful snapshot with visible capture time;
- no queued high-consequence mutations while offline;
- clear reconnect and refresh behaviour;
- responsive navigation that preserves workspace hierarchy.

## Capacitor readiness

- do not depend on hover;
- respect safe-area insets;
- maintain 44px minimum touch targets;
- isolate browser-only APIs behind adapters;
- use full-screen or sheet patterns that can translate to native shells;
- keep authentication, deep-link and notification boundaries replaceable;
- preserve the same routes and semantic token source.

## Supabase prohibitions

Codex must not:

- bypass RLS with a service role in user-facing requests;
- create `security definer` functions without locked `search_path`, explicit grants and justification;
- put remote network calls inside database triggers;
- use frontend role labels as authority;
- infer hidden-record counts;
- create direct table mutations for authority-bearing workflows when an owned RPC/state transition is required;
- generate unversioned RPC contracts;
- silently change existing schema ownership.

## Definition of done for first Director deployment

The first deployment is ready when:

- `/dashboard` renders the complete page hierarchy;
- all mandatory widgets exist with realistic typed fixtures or governed live data;
- every widget declares its owner, route and data state;
- desktop, tablet and mobile layouts preserve priority;
- loading, empty, stale, partial, error and offline presentations are demonstrable;
- AI content is labelled, evidence-linked and non-authoritative;
- no irreversible action can be completed from a summary card;
- semantic tokens are used instead of one-off styling;
- automated accessibility and type checks pass;
- the repository contains an explicit record of known backend gaps;
- the Director can approve or reject the surface without needing to inspect code.

## Escalation rule

When doctrine and existing implementation conflict, Codex must report the conflict and preserve current production behaviour until the Director or authorised architecture process resolves it. It must not silently choose a new business rule.
