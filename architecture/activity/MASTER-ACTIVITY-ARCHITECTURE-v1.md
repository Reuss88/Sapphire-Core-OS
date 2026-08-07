# Sapphire Activity Architecture v1

## Status
Authoritative cross-workspace collaboration and commercial-memory architecture.

## Purpose
Activity records meaningful human or system participation around Sapphire records without creating competing note, comment, timeline or collaboration systems inside individual workspaces.

Dominant question: **Who did or said what, when, in relation to which commercial object, with what visibility, outcome, evidence and next consequence?**

Activity is not an audit log replacement, an Inbox replacement or an Actions replacement.

## Core principle

```text
Actions owns accountable work.
Inbox owns communications.
Governance owns authority and approvals.
Audit owns immutable compliance history.
Activity owns collaborative commercial context and work journal.
```

Every workspace may publish or consume Activity. No workspace may create an independent notes/comments system where Activity can satisfy the requirement.

## Activity object

An Activity represents a meaningful contextual event, contribution, observation or outcome associated with one or more Sapphire records.

Minimum fields:

- activity_id;
- organisation_id;
- actor_id or governed system actor;
- activity_type;
- occurred_at;
- body/structured_content;
- visibility_scope;
- primary_subject_type / primary_subject_id;
- optional linked subjects;
- source_workspace;
- source_record_type / source_record_id;
- outcome classification where applicable;
- evidence references where applicable;
- created_at;
- immutable provenance metadata.

## Canonical activity types

Initial types:

- note;
- comment;
- call_attempt;
- call_connected;
- meeting;
- research_update;
- outcome;
- status_update;
- handoff;
- instruction;
- coaching_note;
- evidence_added;
- document_shared;
- message_summary;
- system_observation;
- AI_summary;
- escalation_note.

Type expansion must preserve the distinction between Activity and authoritative domain state.

## Visibility

Activity visibility must be explicit and permission-aware. Initial scopes:

- private_actor;
- director_only;
- assigned_users;
- mission_team;
- workspace_team;
- organisation;
- governed_external_party where explicitly supported later.

Visibility never grants authority over the linked object.

Sensitive coaching/private notes must not be exposed because a user can otherwise see the linked mission or deal.

## Linking model

An Activity may link to multiple commercial objects, including:

- mission;
- action item;
- person/contact;
- company;
- buyer/supplier profile;
- commodity or universal profile;
- demand record;
- supply record;
- opportunity;
- match;
- deal;
- document;
- Inbox thread/message;
- Governance decision/approval;
- finance record;
- market signal.

One primary subject is required for predictable ownership and retrieval. Additional links provide context.

## Work Journal

Every mission and action item must expose a chronological Work Journal derived from Activity plus selected authoritative execution events.

The Work Journal must allow the Director and permitted collaborators to understand:

- what was assigned;
- what work occurred;
- what was learned;
- what changed;
- what evidence was produced;
- what the outcome was;
- what should happen next.

The journal is not merely a feed. Entries must preserve type, actor, time, visibility, commercial context and links.

## Outcome capture

Completing an action may require an Activity outcome.

Examples:

Closer call outcome:
- contact reached/not reached;
- person spoken to;
- commercial interest;
- objection;
- next request;
- promised follow-up;
- next action/date;
- linked profile or opportunity updates.

Research outcome:
- sources found;
- confidence;
- evidence links;
- new organisation/contact candidates;
- proposed profile enrichment;
- follow-up recommendation.

Structured outcomes should be captured where useful while preserving free-text commercial nuance.

## Notes and instructions

A Director may attach an instruction/note to a mission or action for an assignee.

An assignee may add progress notes, questions, outcomes and evidence.

Activity entries must support mentions/references but must not silently create assignments or authority.

Where an Activity implies new work, the user or governed automation may create/link an Action item explicitly.

## Activity versus Inbox

Inbox owns communication channels and message truth.

Activity may reference or summarize an Inbox message/thread, but must not copy the Inbox into a second message store.

Example:

Inbox message received -> linked Activity `message_summary` -> optional Action follow-up.

## Activity versus Audit

Activity is collaborative business context and may be editable only under governed rules for limited periods where doctrine permits.

Audit is immutable compliance/security history.

Material Activity mutations must themselves generate audit events. Deleting material commercial memory should default to soft-withdrawn/redacted semantics, not physical deletion.

## Activity versus Execution Events

Execution Events represent authoritative state transitions in Actions.

Activity represents contextual participation around those transitions.

Example:

- Action state changed to completed = Execution Event.
- Closer writes "Buyer wants revised pricing by Friday" = Activity outcome.

Both may appear in the Work Journal but remain distinct records.

## Notifications and Inbox integration

Activity can trigger notifications when:

- user is mentioned;
- Director note/instruction is added to assigned work;
- assignee posts an outcome requiring review;
- material evidence is added;
- a question/blocker is directed to another actor.

Notification delivery is not Activity ownership and must be idempotent.

## Commercial Memory

Approved Activity becomes part of Sapphire institutional memory.

AI may summarize Activity, detect unresolved questions, propose next actions and surface recurring patterns. AI summaries must retain provenance to underlying Activity and must never replace authoritative records.

## Supabase implementation expectations

Implementation should support:

- canonical `activities` records;
- typed `activity_links` where needed;
- structured payload/schema versioning;
- attachments/evidence references without duplicating Documents;
- visibility-aware RLS;
- actor/team/Director permission evaluation via existing identity/access runtime;
- append/withdraw/redact semantics;
- Work Journal read RPCs;
- transactional create/update/withdraw commands;
- audit/outbox integration;
- realtime invalidation followed by authoritative refetch;
- indexes for subject, actor, organisation, time and visibility-aware retrieval.

## Non-negotiables

- no per-workspace competing notes system;
- no Activity field may grant authority;
- no duplicate Inbox message truth;
- no replacement of audit history;
- no hard deletion of material commercial memory without explicit governed policy;
- AI-generated Activity must be marked as AI-originated and provenance-linked;
- visibility must be enforced server-side, not only hidden in UI.
