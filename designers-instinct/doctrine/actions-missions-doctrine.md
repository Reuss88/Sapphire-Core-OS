# Actions and Missions Doctrine

## Status

Permanent cross-product doctrine for execution inside Sapphire Core OS.

## Governing principle

Sapphire must not only explain the commercial system. It must organise and drive the work required to move that system forward.

**Actions is a first-class Commercial Workspace.**

It is not a dashboard widget, a generic to-do list, or an activity feed.

## Dominant commercial question

What must be done, by whom, by when, with what authority, evidence and commercial consequence?

## Core execution objects

### Mission

A mission is an outcome-bound body of work with a clear commercial objective, owner, contributors, scope, success criteria and completion state.

Examples:

- source five verified gold suppliers;
- qualify buyers for a copper cathode mandate;
- complete bank onboarding for a transaction;
- secure pricing evidence before issuing an offer;
- prepare a property acquisition for Director approval.

A mission may contain tasks, communications, documents, decisions, dependencies and linked records.

### Task

A task is a discrete executable action that contributes to a mission, record, workflow or obligation.

Every task must define:

- title and required outcome;
- owner and optional contributors;
- source and owning workspace;
- linked profile, opportunity, deal or communication;
- priority, due state and dependency state;
- required authority;
- completion evidence;
- audit history.

### Decision

A decision is an action requiring explicit judgement or authority. It must never be represented as ordinary task completion.

### Waiting On

Waiting On records represent work blocked by an external person, organisation, event, document, payment or system condition.

### Follow-up

A follow-up is a time-bound commitment to re-engage a person, record or conversation.

## Mission roles

Sapphire must support, at minimum:

- Director;
- Closer;
- Research Specialist / Lead Generation;
- Finance and banking counterparties;
- Compliance and verification contributors;
- Introducers, brokers and external specialists;
- AI as recommender and coordinator, never final authority.

Role labels are configurable. Authority remains governed by permissions and workflow rules.

## Creation sources

Actions and missions may originate from:

- Director assignment;
- workspace workflow;
- inbox communication;
- opportunity or deal progression;
- Market Radar signal;
- missing evidence or compliance condition;
- document expiry;
- scheduled obligation;
- AI recommendation accepted by an authorised user.

No AI recommendation becomes an assigned mission or authoritative action without traceable human or policy approval.

## HOME contract

HOME must include an **Actions Summary** that answers:

- what requires action today;
- what is overdue;
- what is blocked;
- what is waiting on others;
- which missions are progressing or at risk;
- which actions require Director authority.

The summary must drill into Actions and must not attempt to reproduce the full workspace.

## Ownership

Actions owns:

- missions;
- tasks;
- task dependencies;
- assignments;
- decisions and approvals awaiting action;
- waiting-on states;
- follow-ups;
- reminders;
- completion evidence;
- execution audit events.

Other workspaces may create, reference and resolve Actions, but may not create competing task systems.

## Implementation contract

The implementation must support:

- mission and task DDL;
- parent-child and dependency relationships;
- assignment and collaborator models;
- role- and record-aware RLS;
- RPCs for personal, team and Director action queues;
- triggers for due, overdue, blocked and completion state;
- transactional creation from workflow events;
- immutable audit events;
- realtime queue invalidation;
- idempotent automation and notification delivery.

Frontend-only task state is prohibited.
