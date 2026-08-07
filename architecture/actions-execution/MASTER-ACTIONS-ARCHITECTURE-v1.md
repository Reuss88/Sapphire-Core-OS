# Actions Workspace Architecture v1

## Status
Authoritative execution architecture for Sapphire Core OS Actions.

## Purpose
Actions is Sapphire's execution engine. It converts commercial intent, workflow events, communications, approvals, market signals and Director instructions into accountable work.

Dominant question: **What must be done, by whom, by when, with what dependency, authority, evidence and commercial consequence?**

Actions is not a generic to-do list and must not duplicate the source-of-truth records owned by other workspaces.

## Core model

### Mission
Outcome-bound body of work. A mission has an objective, owner, contributors, scope, success criteria, target date, commercial context, status, risk state and linked records.

### Action Item
Discrete executable work. Supported kinds at v1: task, follow_up, review, approval_request, decision_request, reminder, coordination.

`Waiting on` and `blocked` are execution states, not separate task systems.

### Dependency
A directed prerequisite between action items or between an action item and an external condition. Circular dependencies are prohibited.

### Assignment
Defines owner, contributors and responsibility role for a mission or action item. Authority is not inferred from assignment.

### Link
Typed relationship from a mission/action to its commercial context: profile, person, company, demand, supply, opportunity, match, deal, document, inbox thread, market signal, finance record, approval or other governed record.

### Evidence
Proof of completion or progress: document, message, note, structured result, external confirmation or governed system event.

### Execution Event
Immutable audit record of creation, assignment, state transition, due-date change, dependency change, completion, reopen, cancellation and escalation.

### Activity
Shared collaborative context around work, governed by `architecture/activity/MASTER-ACTIVITY-ARCHITECTURE-v1.md`.

Actions must not create a competing notes/comments/call-log system. Missions and Action Items consume Activity to provide instructions, progress updates, questions, call outcomes, research findings, handoffs, evidence context and Work Journal history.

Activity does not replace Action state or Execution Events.

## Ownership boundary
Actions owns missions, action items, dependencies, assignments, reminders, follow-up commitments, execution evidence and execution events.

Activity owns collaborative notes, comments, work-journal entries, call/research outcomes and contextual updates linked to Actions.

Governance remains source of truth for authority, approvals and decision policy. Actions may surface a pending approval/decision as an executable work item but must reference the Governance record rather than duplicate its authoritative state.

Inbox owns communication threads/messages. Actions may create follow-ups from Inbox and link to threads. Message truth remains in Inbox; Activity may reference or summarize it.

Other workspaces own their commercial records. Actions references them.

## State model
Mission: planned -> active -> at_risk | blocked -> completed | cancelled.

Action item: draft -> queued -> ready -> in_progress -> waiting | blocked -> completed | cancelled.

Reopen is permitted from completed only with actor, reason and audit event.

Overdue is derived from `due_at` and state; it is not a mutable status.

## Priority
critical, high, normal, low. Priority must represent commercial consequence/urgency, not personal preference alone.

## Mission health
Derived from overdue items, blocked critical path, unresolved dependencies, target-date risk, completion ratio and explicit risk flags. AI may explain health but may not silently change authoritative state.

## Roles
Director, Closer, Research Specialist / Lead Generation, Finance, Compliance, Operations, external contributor and configurable future roles. Role labels are configurable; permissions remain policy-driven.

## Creation pathways
Director assignment; user-created task; workflow transaction; Inbox follow-up; Market Radar signal accepted by an authorised user; deal/opportunity milestone; missing evidence/compliance condition; document expiry; scheduled obligation; approved AI recommendation.

Every created item must record `created_by`, `creation_source`, and where applicable `source_record_type/source_record_id`.

## Team collaboration contract
A delegated Action must support the full handoff loop:

```text
Director/user assigns Action
→ assignee sees due date, priority, linked context and instructions
→ assignee performs work
→ assignee records Activity outcome/progress/evidence
→ permitted Director/team users can review the Work Journal
→ explicit follow-up Action is created when more work is required
```

Examples:

- Closer call: instruction + due date + call outcome + next follow-up.
- Cold caller/researcher: sourcing brief + findings + evidence + handoff.
- Finance: request + bank/counterparty update + blocker/outcome.

Completion policy may require an outcome Activity and/or evidence for commercially material Actions.

## Work Journal
Every Mission and Action Item must expose a chronological Work Journal that combines:

- visibility-permitted Activity entries;
- selected authoritative Execution Events;
- evidence references;
- linked communication context where permitted.

The Work Journal must distinguish contextual Activity from authoritative state changes.

## Queue model
Actions must support these canonical lenses without duplicating data: My Actions, Missions, Team, Approvals & Decisions, Waiting On, Overdue, Completed.

Director mode adds cross-team risk, critical missions, unowned work and authority-required items.

## Realtime and automation
Changes should invalidate affected queues and Work Journals in realtime. Automation must be idempotent. Scheduled escalation may create notifications/events but must not manufacture approvals or authority.

## Non-negotiables
- no frontend-only completion state;
- no duplicate approval system;
- no independent Actions notes/comments system;
- no silent ownership changes;
- no completion without evidence/outcome where policy requires it;
- no AI assignment/approval without a traceable authorised rule or user action;
- no hard deletion of audited execution history or material Activity outside governed retention/redaction policy.
