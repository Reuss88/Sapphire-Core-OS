# Actions Data Contract

## Canonical read contracts

### actions_get_my_queue_v1
Inputs: scope, due window, filters, cursor/limit.
Returns ranked action summaries with mission context, due state, priority, blockers, linked record summary, authority flag and ranking explanation.

### actions_get_director_queue_v1
Returns critical cross-team actions, authority-required items, orphaned work, at-risk missions and blocked high-value execution. Must enforce Director permission server-side.

### actions_get_missions_v1
Returns mission summaries with health, progress, owner, target date, critical blockers, next milestone and commercial context.

### actions_get_mission_detail_v1
Returns mission, success criteria, actions, dependencies, contributors, linked records, evidence summary and timeline.

### actions_get_item_detail_v1
Returns authoritative action item plus assignment, dependencies, links, evidence requirements, approval/decision reference and execution history summary.

### actions_get_team_load_v1
Returns permission-filtered workload and risk indicators. This is for coordination, not employee surveillance; avoid vanity activity metrics.

## Canonical mutation RPCs
- actions_create_mission_v1
- actions_update_mission_v1
- actions_create_item_v1
- actions_transition_item_v1
- actions_assign_item_v1
- actions_set_due_at_v1
- actions_set_priority_v1
- actions_set_waiting_v1
- actions_set_blocked_v1
- actions_add_dependency_v1
- actions_remove_dependency_v1
- actions_link_record_v1
- actions_add_evidence_v1
- actions_complete_item_v1
- actions_reopen_item_v1
- actions_cancel_item_v1

Mutations must validate actor, permissions, transition legality, record existence and protected authority rules transactionally.

## Snapshot shape
Action summary should include: id, title, item_kind, status, priority, owner, contributors summary, due_at, due_state, mission id/title, source workspace, linked commercial summary, blocked/waiting indicators, authority_required, evidence_required, commercial_value_exposure when available, updated_at, rank_score and rank_factors.

## Freshness
Queues are server-authoritative and realtime-invalidated. UI may cache for navigation continuity but must expose stale/error states.

## Pagination
Large queues use cursor pagination. Sorting must be deterministic with id as final tie-breaker.

## Currency/value
Any value exposure must carry currency, basis, source and timestamp. Actions does not invent commercial valuations.
