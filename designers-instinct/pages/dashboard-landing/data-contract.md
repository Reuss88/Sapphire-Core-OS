# Dashboard Landing Data Contract

## Principle

The Dashboard Landing consumes governed read models. It does not assemble commercial truth by joining arbitrary tables in frontend code.

Database objects remain implementation detail. Commercial Workspaces own records and expose only the data required by this page.

## Canonical snapshot

The frontend should load the page through one versioned RPC contract:

`dashboard_get_director_snapshot_v1(p_scope jsonb, p_period tstzrange, p_timezone text)`

The RPC must return a stable JSON object containing:

- `generated_at`;
- `data_as_of`;
- `scope`;
- `permission_context` without sensitive policy internals;
- `attention_items`;
- `commercial_movement`;
- `emerging_value`;
- `workspace_pulse`;
- `performance_context`;
- `ai_briefing` or a reference to an asynchronously prepared briefing;
- per-section `freshness`, `partial`, and `error` metadata.

The RPC is read-only, `security invoker` by default, and subject to RLS. Any justified `security definer` helper must use a locked `search_path`, explicit grants and audit review.

## Required read models

Implementation may use versioned SQL views or materialized projections, but their commercial contracts must include:

- `dashboard_attention_candidates_v1`;
- `dashboard_commercial_movement_v1`;
- `dashboard_emerging_value_v1`;
- `dashboard_workspace_pulse_v1`;
- `dashboard_performance_context_v1`.

These names are contracts, not permission bypasses. Each model must filter through the current user's organisation, role, workspace access and record-level policies.

## Attention item schema

Each attention item must include:

- stable `attention_id`;
- `source_workspace`;
- `source_record_type` and `source_record_id`;
- `condition_code`;
- `severity`;
- `urgency_at` or `expires_at`;
- `commercial_value_exposure` and currency when applicable;
- `reason_code` and display-safe explanation;
- `confidence` and evidence references for inferred conditions;
- `required_authority`;
- `allowed_actions` calculated from permissions;
- `route`;
- `created_at`, `updated_at`, and `data_as_of`.

## DDL expectations

Do not create a generic dashboard table containing copied workspace records.

Persist only dashboard-specific state, such as:

- user layout and density preferences;
- saved dashboard scopes;
- dismissals or acknowledgements where doctrine permits;
- snapshot/cache metadata;
- generated briefing metadata;
- attention-condition lifecycle state when it cannot be derived safely from source records.

All persisted dashboard tables require:

- UUID primary keys;
- organisation/tenant boundary where applicable;
- `created_at` and `updated_at` in UTC;
- actor attribution for mutable records;
- explicit foreign keys to owning records where stable;
- RLS enabled before application access;
- no client-controlled authority or severity fields unless validated server-side.

## Functions and RPCs

Expected implementation contracts include:

- `dashboard_get_director_snapshot_v1(...)` — canonical read payload;
- `dashboard_acknowledge_attention_v1(p_attention_id uuid)` — acknowledgement only, never underlying approval;
- `dashboard_get_widget_detail_v1(p_widget_key text, p_scope jsonb, p_cursor jsonb)` — paginated detail when a workspace route is not yet required;
- internal pure functions for severity, urgency and value-at-risk calculation;
- internal permission functions that return allowed actions without exposing hidden records.

Mutating commercial RPCs remain owned by their workspaces. The dashboard routes to them; it does not duplicate them.

## Trigger and event requirements

Source-workspace mutations must emit stable domain events or update an outbox in the same transaction. Relevant events include:

- demand qualification changed;
- supply verification changed;
- opportunity stage or material value changed;
- match status changed;
- deal milestone, settlement or commission state changed;
- mandate or document approaching expiry;
- KYC/KYB or trust condition changed;
- workflow exception created or resolved.

Triggers must:

- remain small and deterministic;
- avoid remote network calls;
- write to a transactional outbox or enqueue recalculation work;
- prevent recursive update loops;
- preserve the source workspace as owner of truth.

Derived dashboard projections may be recalculated synchronously only when cheap and safe. Expensive aggregation or AI briefing generation belongs in queued/background processing, with freshness exposed to the UI.

## Realtime

Realtime subscriptions must publish invalidation or minimal domain events, not unrestricted table rows. The client re-fetches affected snapshot sections through authorised RPCs.

Disconnects, delayed events and partial subscriptions must produce a visible stale state rather than false freshness.

## RLS and permissions

- RLS is mandatory on all exposed tables and views.
- The dashboard must never reveal hidden-record counts through totals, errors or timing differences.
- `allowed_actions` are calculated server-side from current permissions and record state.
- Workflow state does not imply authority.
- Director-specific access must be a real policy/role capability, not a frontend role string.
- AI services receive only the minimum authorised evidence needed for the briefing.

## Audit

Audit events are required for:

- attention acknowledgement or dismissal;
- filter/scope changes only when they affect governed saved views, not ordinary browsing;
- any authorised mutation launched from a dashboard drill-down;
- AI recommendation generation, evidence set, model/config version and user acceptance or rejection when commercially material;
- permission denials for high-consequence attempted actions, subject to security policy.

## Performance target

The snapshot contract should support server rendering and fast client hydration. Expensive calculations must be pre-aggregated or cached with explicit `data_as_of`; correctness and permission safety outrank apparent realtime speed.

## Migration rule

Every DDL/RPC/function/trigger implementation must be delivered through ordered, idempotent Supabase migrations with rollback or forward-fix notes, grants, RLS policies, indexes and contract tests. Codex must not infer schema names from visual labels without first mapping them to the owning workspace doctrine.
