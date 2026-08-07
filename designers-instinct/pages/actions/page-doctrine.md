# Actions Page Doctrine

## Status
Authoritative page doctrine for the Actions workspace.

## Primary purpose
Give each user a decision-ready execution surface that makes accountable work obvious without becoming a generic project-management app.

## Dominant question
What must I or my team do next to move Sapphire's commercial system forward?

## Required page regions
1. **Actions command header** — current lens, scope, owner/team filter, date scope, search, create action/mission.
2. **Execution brief** — concise system-generated summary of what changed, what is at risk and what deserves focus.
3. **Primary queue** — ranked actionable work for the selected lens.
4. **Mission rail / mission context** — active missions, health and progress.
5. **Context inspector** — selected item's linked records, dependencies, evidence, authority and timeline without leaving the page.
6. **Secondary lenses** — My Actions, Missions, Team, Approvals & Decisions, Waiting On, Overdue, Completed.

## Ranking doctrine
Default queue ordering must consider: criticality, due/overdue state, commercial value exposure, dependency critical path, authority requirement, mission risk, waiting duration and confidence. The ranking explanation must be inspectable.

## Action card contract
Every visible action must answer:
- What must happen?
- Why does it matter?
- Who owns it?
- When is it due?
- What is blocking it?
- What record or mission does it serve?
- What is the next valid action?

## Mission card contract
Every mission summary must expose objective, owner, health, progress, target date, critical blockers, next milestone and linked commercial context.

## Director mode
Director mode is not a separate database. It is a privileged lens that may show:
- cross-team critical work;
- actions requiring Director authority;
- unowned or orphaned critical work;
- at-risk missions;
- blocked high-value commercial execution;
- overdue external dependencies;
- workload/concentration exceptions.

## Interaction principles
- Work happens in context, not through modal mazes.
- Selecting an action should reveal its context inspector.
- Users may complete, reassign, reschedule, link evidence, mark waiting, resolve blockers or open the owning workspace according to permission.
- Bulk actions are allowed only where semantics remain safe and auditable.
- Drag-and-drop may change ordering or status only where the resulting transition is valid and authorised.

## AI boundary
AI may summarise, rank, recommend, draft sub-tasks, identify missing dependencies and explain risk. It may not approve, close, reassign privileged work or modify authority without an authorised user/policy action.

## Empty states
Empty states must explain whether the user has no work, filters exclude work, data is unavailable, or permission prevents visibility. They must never imply system-wide absence when only the current scope is empty.

## Mobile/PWA
Desktop is the primary working surface. PWA/mobile uses a single-column queue with sticky lens controls and an inspector drawer. Critical actions and mission health remain visible without horizontal scrolling.

## Acceptance
The page passes when a user can identify top priorities, understand context, act, provide evidence, see dependencies and trace ownership without leaving Actions except for deliberate drill-down into an owning workspace.
