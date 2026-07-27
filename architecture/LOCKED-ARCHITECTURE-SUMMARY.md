# Locked Architecture — Reconstructed Canonical Summary

> Provenance: This document preserves the approved architecture summary available in the active Sapphire Core OS project context. It is not represented as a verbatim replacement for unavailable original module prose.

## 1. Business Object Architecture

Defines canonical enterprise objects and object families.

Business Objects are governed semantic entities. They are not merely database tables, API resources, or application records.

The architecture establishes object identity, canonical meaning, attributes, ownership, provenance, history, and implementation independence.

## 2. Relationship Architecture

Defines governed relationships between Business Objects.

Relationships carry meaning and must define, where applicable:

- source and target;
- semantic type;
- direction;
- cardinality;
- validity;
- effective time;
- ownership;
- provenance;
- history.

A relationship is not an incidental foreign key. Database links implement relationship truth; they do not define it.

## 3. Lifecycle & State Architecture

Defines how business truth changes over time.

Lifecycle state is distinct from workflow state.

Locked standards:

- LS-001 — Lifecycle Standard
- LS-002 — Lifecycle Pattern Library

A lifecycle must govern:

- allowed states;
- state meaning;
- permitted transitions;
- transition guards;
- authority requirements;
- evidence;
- effective time;
- history;
- terminal conditions.

## 4. Workflow & Orchestration Architecture

Defines how work is coordinated without redefining business truth or organisational authority.

### Canonical chain

```text
Business Objective
→ Process
→ Workflow Definition
→ Workflow Instance
→ Step Instance
→ Human Work or Automated Execution
→ Result, Event, or Transition Request
→ Governed Business Consequence
```

### Locked runtime objects

1. Workflow Instance
2. Step Instance
3. Work Assignment
4. Workflow Exception
5. Transition Request
6. External Execution Record

### Important boundaries

- Workflow coordinates work.
- Lifecycle defines business truth.
- Routing never grants authority.
- Work Assignment is not Task.
- Workflow Definitions are versioned.
- Waits and exceptions are explicit.
- History is append-only.
- AI never creates authority.

### Workflow Definition lifecycle

```text
Draft
→ Under Review
→ Approved
→ Effective
→ Retired
```

Alternative states:

- Rejected
- Withdrawn
- Suspended
- Superseded

### Workflow Instance lifecycle

```text
Created
→ Ready
→ Running
→ Completed
→ Closed
```

Alternative terminals:

- Cancelled
- Terminated

Independent execution conditions:

- Waiting
- Blocked
- Suspended
- Recovery Required
- Degraded

### Step Instance lifecycle

```text
Created
→ Ready
→ Active
→ Completed
```

Alternative terminals:

- Failed
- Cancelled
- Skipped
- Expired

### Work Assignment lifecycle

```text
Created
→ Available
→ Accepted
→ In Progress
→ Submitted
→ Closed
```

Alternative outcomes:

- Declined
- Cancelled
- Expired

Independent conditions:

- Queued
- Offered
- Claimed
- Delegated
- Reassigned
- Returned
- Blocked
- Suspended

### Integration interaction types

- Command
- Request
- Query
- Response
- Event
- Acknowledgement

Acknowledgement is not completion.

### Retry and replay distinctions

- Retry
- Re-execution
- Rework
- Replay
- Correction
- Compensation

Replay modes:

- Analytical Replay
- Technical Recovery Replay
- Business Reprocessing

Business Reprocessing requires explicit authority.

### AI permission levels

- Observe
- Recommend
- Prepare
- Execute under deterministic authority

AI may never:

- create authority;
- approve commitments;
- override controls;
- decide legal effectiveness.

### Locked standards

- WS-001 — Workflow Standard
- WS-002 — Workflow Pattern Library
- WS-003 — Workflow Runtime Object Register
- WS-004 — Workflow Conformance Checklist
