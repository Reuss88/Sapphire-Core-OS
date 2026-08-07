# Actions Supabase Architecture

## Goal
Provide the backend contract required for Actions without forcing Codex to guess database behaviour.

## Recommended tables

### action_missions
Core fields: id uuid pk, org_id, title, objective, status, priority, owner_user_id, target_at, health_override nullable, success_criteria jsonb, source_workspace, source_record_type, source_record_id, created_by, created_at, updated_at, completed_at, cancelled_at.

### action_items
Core fields: id uuid pk, org_id, mission_id nullable fk, title, description, item_kind, status, priority, owner_user_id, due_at, started_at, completed_at, cancelled_at, waiting_reason, expected_resume_at, blocked_reason, source_workspace, source_record_type, source_record_id, authority_required bool, evidence_required bool, created_by, created_at, updated_at.

### action_assignments
id, org_id, mission_id nullable, action_item_id nullable, user_id/contact_id as supported by identity architecture, assignment_role, assigned_by, assigned_at, removed_at. Enforce exactly one target (mission or item).

### action_dependencies
id, org_id, predecessor_item_id, successor_item_id, dependency_type, created_by, created_at, resolved_at. Unique predecessor/successor pair. Server-side cycle prevention required.

### action_links
id, org_id, mission_id nullable, action_item_id nullable, linked_type, linked_id, link_role, created_by, created_at. Enforce exactly one execution target.

### action_evidence
id, org_id, action_item_id, evidence_type, linked_document_id/message_id/record reference, note, supplied_by, created_at.

### action_events
Append-only audit/event stream: id, org_id, mission_id nullable, action_item_id nullable, event_type, actor_user_id, payload jsonb, occurred_at, correlation_id, causation_id. No update/delete for ordinary app roles.

### action_saved_views
id, org_id, user_id, name, lens, filters jsonb, sort jsonb, grouping jsonb, created_at, updated_at.

## Enums / constrained values
Prefer Postgres enum or checked text according to existing project convention:
- mission_status: planned, active, at_risk, blocked, completed, cancelled
- action_status: draft, queued, ready, in_progress, waiting, blocked, completed, cancelled
- action_kind: task, follow_up, review, approval_request, decision_request, reminder, coordination
- priority: critical, high, normal, low

## Derived state
Do not store `overdue` as status. Derive from due_at < now() and non-terminal state.
Mission health should be derived through a stable SQL function/view using open critical items, overdue count, blocked critical path and target-date pressure, with optional authorised override if doctrine later approves it.

## Required SQL functions
- action_validate_transition(current_status, next_status)
- action_dependency_would_cycle(predecessor, successor)
- action_compute_due_state(status, due_at)
- action_compute_mission_health(mission_id)
- action_rank_score(action_item_id, actor_context)

## Required RPCs
Read RPCs and mutation RPCs are defined in `data-contract.md`. All mutation RPCs should run as single transactions, write audit events, and return authoritative state.

## Triggers
Use triggers only for invariant/audit responsibilities, not business logic better expressed in RPCs.
Recommended:
- updated_at maintenance
- append audit event on protected direct changes if direct table mutations are permitted
- realtime/outbox enqueue where project architecture requires it
- prevent mutation/deletion of immutable action_events

Avoid cron-based status mutation for overdue. Calculate due state at read time and use scheduled jobs only for notification/escalation generation.

## RLS
Every table is org-scoped. Policies must distinguish:
- record visibility
- execution permission
- assignment permission
- Director/team-wide visibility
- protected authority-linked items
- audit visibility

Assignment does not equal permission. A user may be assigned an item but still require an authorised workflow/RPC for protected actions.

## Authority integration
Approval/decision records live in Governance architecture. action_items of kind approval_request/decision_request contain a governed reference; RPCs must call or defer to the authoritative Governance mutation rather than updating approval truth locally.

## Inbox integration
Follow-ups can reference Inbox threads/messages through action_links/evidence. Message ingestion must never directly complete work unless an explicit trusted automation rule exists and is audited.

## Realtime
Publish invalidation for changed mission/item ids and affected owner/team scopes. Clients refetch authoritative summaries rather than trusting raw realtime payloads as business truth.

## Indexes
At minimum: org/status, org/owner/status/due_at, org/mission/status, org/priority/status, source record composite, dependencies predecessor/successor, links linked_type/linked_id, events item/occurred_at and mission/occurred_at.

## Migration rule
Before writing DDL, Codex must inspect existing schema, naming conventions, identity tables, org/tenant model, audit/event architecture and Governance approval records. Reuse established primitives; do not create parallel user/org/audit systems.
