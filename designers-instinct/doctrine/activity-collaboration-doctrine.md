# Activity and Collaboration Doctrine

## Status
Permanent cross-product doctrine for human collaboration and commercial memory inside Sapphire Core OS.

## Governing principle
Sapphire must preserve the context behind commercial work, not only the final state of records.

**Activity is the shared collaboration layer across Sapphire.**

It is not a generic social feed, not an Inbox replacement, not a task system, and not an audit log.

## Dominant commercial question
What happened around this work, who contributed, what was learned, what was decided or requested, and what should happen next?

## User experience contract
Every major record that supports collaborative work should expose a Work Journal or Activity surface appropriate to that workspace.

For Actions, this means:

- Director can leave instructions and notes for assignees;
- assignees can post progress updates, questions and outcomes;
- call attempts and connected calls can be recorded;
- research specialists can attach findings and evidence;
- action completion can require an outcome note where commercially useful;
- next steps can be converted explicitly into new Actions;
- notes can be scoped by visibility;
- the Director can review delegated work without leaving Sapphire.

## Collaboration model

A typical team workflow should support:

```text
Director creates/assigns Action
→ assignee receives work
→ assignee reviews Director notes/context
→ assignee executes work
→ assignee records Activity and evidence
→ outcome updates Work Journal
→ Director/team receives visibility-appropriate notification
→ new work is created explicitly if required
→ commercial records are enriched through their owning workspace
```

## Role examples

### Closer
A closer assigned to call a client must be able to see:

- client/contact context;
- due date/time;
- priority;
- Director instruction;
- previous relevant Activity;
- linked deal/opportunity/profile;
- expected outcome.

After the call, the closer should be able to record:

- reached/not reached;
- person spoken to;
- notes;
- objection/interest;
- requested information;
- next follow-up date;
- evidence/recording reference where permitted;
- recommendation or blocker.

### Research Specialist / Lead Generation
A research assignment should support:

- research brief;
- target criteria;
- due date;
- progress notes;
- candidate companies/contacts;
- evidence links;
- confidence/quality notes;
- handoff to Supply, Demand, Network or Profiles where the finding becomes a canonical record.

### Director
The Director should be able to:

- leave instructions before work begins;
- clarify or amend context without changing authority invisibly;
- review outcomes;
- request follow-up;
- leave private Director-only notes where appropriate;
- see who contributed and when;
- understand work history without contacting the assignee separately.

## Visibility doctrine
Activity visibility must be explicit. At minimum Sapphire must distinguish:

- private to actor;
- Director only;
- assigned users;
- mission team;
- workspace team;
- organisation.

Visibility does not grant permission to mutate the linked commercial record.

## Design doctrine
Activity should feel like a structured commercial Work Journal, not social-media comments.

Each Activity item should make clear:

- actor;
- timestamp;
- type;
- content/outcome;
- linked subject;
- evidence if present;
- visibility when not obvious;
- next valid action where relevant.

High-value outcomes and blockers should visually outrank routine status chatter.

## AI doctrine
AI may:

- summarize Activity;
- extract unresolved questions;
- identify promised follow-ups;
- propose Actions;
- highlight contradictions or missing evidence;
- generate Director briefs from Activity.

AI may not:

- fabricate Activity;
- erase attribution;
- silently convert notes into authoritative decisions;
- create authority from participation;
- hide uncertainty or provenance.

## Ownership boundary
Activity owns collaborative context and Work Journal entries.

Actions owns accountable work and execution state.
Inbox owns message/channel truth.
Governance owns decisions/approvals/authority.
Documents owns canonical document records.
Profiles and commercial workspaces own their domain records.
Audit owns immutable compliance/security history.

## Permanent rule
No new Sapphire workspace may create a standalone comments, notes, call-log or collaboration subsystem without first demonstrating why the shared Activity architecture cannot satisfy the requirement.
