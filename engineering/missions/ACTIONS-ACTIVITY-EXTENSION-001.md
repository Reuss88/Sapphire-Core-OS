# CODEX MISSION — Actions Activity Collaboration Extension v1

## Mission ID
`ACTIONS-ACTIVITY-001`

## Status
Approved for implementation after ACTIONS-001.

## Repository
`Reuss88/Sapphire-Core-OS`

## Engineering entrypoint — mandatory
Read and follow:

`engineering/START-HERE-CODEX.md`

before writing code.

## Objective
Extend the completed Actions workspace so Director-to-team collaboration, assignee outcomes, progress notes, call/research updates and Work Journal history use the shared Sapphire Activity architecture.

This mission must extend `ACTIONS-001`; it must not redesign or replace Actions and must not create a second notes/comments/call-log system.

## Mandatory reading
After loading the Engineering Framework, read:

1. `architecture/activity/MASTER-ACTIVITY-ARCHITECTURE-v1.md`
2. `designers-instinct/doctrine/activity-collaboration-doctrine.md`
3. `architecture/actions-execution/MASTER-ACTIONS-ARCHITECTURE-v1.md`
4. `designers-instinct/doctrine/actions-missions-doctrine.md`
5. `designers-instinct/pages/actions/`
6. `architecture/identity-access/MASTER-IDENTITY-ACCESS-ARCHITECTURE-v1.md`
7. `architecture/decision-authority-approval/`
8. existing ACTIONS-001 implementation and migrations

## Pre-flight
Before modifying code, inspect:

- current Actions route/components/contracts;
- current Actions migrations/RPCs/RLS;
- identity/team/capability runtime;
- audit/outbox/realtime conventions;
- Inbox-related primitives if already present;
- Documents/evidence primitives if already present;
- any existing generic note/activity/comment tables to avoid duplication.

If an existing canonical Activity primitive already exists, extend it instead of creating another.

## Required domain capabilities
Implement or adapt the shared Activity model so it can support:

- note;
- comment;
- instruction;
- call_attempt;
- call_connected;
- meeting;
- research_update;
- outcome;
- status_update;
- handoff;
- coaching_note;
- evidence_added;
- message_summary;
- AI_summary;
- escalation_note.

Activity must retain actor, organisation, time, type, visibility, primary subject, linked records, source workspace and provenance.

## Visibility contract
At minimum support and test:

- private_actor;
- director_only;
- assigned_users;
- mission_team;
- workspace_team;
- organisation.

Visibility must be enforced by RLS/server-side permission evaluation. Hiding UI is not sufficient.

Visibility must never imply authority to mutate linked domain objects.

## Actions UI extension
Extend the Director-reviewable Actions interface with:

### Work Journal
For selected Mission or Action Item, expose a chronological Work Journal containing:

- Activity entries visible to the current actor;
- selected authoritative Actions execution events;
- evidence references;
- actor and timestamp;
- clear distinction between contextual Activity and state transitions.

### Director instruction flow
Director must be able to leave an instruction/note on an assigned Action or Mission with explicit visibility.

### Assignee update flow
Assignee must be able to add:

- progress note;
- question/blocker;
- call attempt/connected-call outcome;
- research update;
- final outcome;
- handoff;
- evidence reference where supported.

### Completion outcome
For fixture/demo and backend contract, commercially material Actions must be able to require a completion outcome Activity and/or evidence before completion.

### Follow-up creation
From a relevant Activity outcome, user must be able to explicitly create a new follow-up Action linked back to the Activity and original subject.

Do not silently convert every note into a task.

## Closer workflow acceptance scenario
Support this Director-review scenario:

1. Director assigns a closer to call a named client/contact at a specified date/time.
2. Action shows owner, due date/time, priority, linked client/profile/opportunity and Director instruction.
3. Closer records either call attempt or connected call.
4. Connected-call outcome can capture free text plus useful structured fields such as interest, objection, requested information and next follow-up date.
5. Director can review the outcome in the Work Journal without leaving Sapphire.
6. A next follow-up can become an explicit linked Action.

## Research / cold-caller workflow acceptance scenario
Support:

1. Director/manager assigns sourcing or lead-generation Action.
2. Assignee sees brief, due date and target criteria.
3. Assignee posts research updates/findings and evidence links.
4. Findings may reference candidate companies/contacts/profiles without creating duplicate canonical records.
5. Director can review progress and handoff context from Work Journal.

## Backend contract
Implement the Activity architecture using current repository naming conventions. Expected concepts may include:

- canonical activities table;
- typed activity links if multi-linking cannot be represented safely by existing generic links;
- structured payload/version metadata;
- visibility enum or governed equivalent;
- create/read/update-or-withdraw RPCs;
- Work Journal read RPC;
- audit/outbox integration;
- realtime invalidation;
- indexes for organisation, subject, actor and occurred_at.

Do not duplicate Documents for attachments/evidence. Do not duplicate Inbox message storage.

## Audit and retention
Material Activity mutations must be auditable.

Prefer append/withdraw/redact semantics for material commercial memory. Do not hard-delete material Activity unless existing governed retention policy explicitly permits it.

AI-originated Activity must be marked as AI-originated and provenance-linked.

## Tests
Required tests include:

- organisation isolation;
- all visibility scopes;
- Director visibility boundaries;
- assigned-user visibility;
- private note isolation;
- Activity cannot grant domain authority;
- Work Journal returns only permitted Activity;
- execution events remain authoritative and distinct;
- completion outcome/evidence requirement where configured;
- follow-up Action linkage;
- no duplicate Inbox message truth;
- no hard deletion of protected Activity;
- typecheck/lint/build/UI contract tests.

## Director Review Package
This is a UI mission and must comply with `engineering/WORKFLOW.md` Director Review Package requirements.

Return:

- local Actions URL;
- desktop screenshot showing Work Journal and collaboration controls;
- tablet screenshot;
- mobile screenshot;
- Mission Result;
- commit SHA;
- branch;
- push confirmation;
- files created/modified;
- database/RPC/RLS changes.

## Definition of done
PASS only when:

- shared Activity infrastructure exists or a pre-existing canonical equivalent has been safely extended;
- Actions consumes Activity rather than owning a private notes/comments system;
- closer and research workflows above are demonstrable;
- visibility is server-enforced;
- database and UI checks pass;
- Director Review Package is delivered.

## Non-negotiables

- no competing notes systems;
- no Activity-based authority escalation;
- no duplicate Inbox storage;
- no replacement of immutable audit history;
- no broad redesign of approved Actions structure;
- no speculative adjacent workspace implementation beyond safe adapters/contracts.
