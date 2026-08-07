# Actions Information Architecture

## Canonical lenses
- My Actions
- Missions
- Team
- Approvals & Decisions
- Waiting On
- Overdue
- Completed

These are views over the same execution model, not separate task stores.

## Desktop structure

### Left workspace rail
Persistent lens navigation and saved views.

### Main execution pane
Ranked queue or mission list. Supports search, filters, grouping, sorting and explicit density controls.

### Context inspector
Persistent right-side inspector for the selected action/mission. Contains:
- objective / required outcome;
- ownership and contributors;
- due/target dates;
- priority and health;
- mission context;
- linked commercial records;
- dependencies and blockers;
- authority/approval reference;
- completion evidence;
- timeline/audit summary;
- safe next actions.

## Queue groupings
Supported grouping: priority, due state, mission, owner, source workspace, action kind, linked deal/opportunity, blocked/waiting state.

## Mission detail hierarchy
1. Mission objective and health
2. Success criteria
3. Critical path / blockers
4. Milestones and target date
5. Open actions
6. Waiting-on items
7. Linked communications/documents
8. Commercial context and value exposure
9. Execution timeline

## Search
Search must support titles, mission names, people, companies, profiles, deals, opportunities and linked record identifiers. Search is permission-filtered.

## Filters
Owner, contributor, team, status, priority, due window, action kind, mission, workspace source, linked record type, authority-required, evidence-required, blocked/waiting, created source.

## Saved views
Users may save filter/sort/group combinations. Saved views never change authority or data ownership.

## Creation UX
Create Mission and Create Action are explicit commands. Quick-create may accept natural language, but the system must show structured fields before commit when ambiguity affects owner, due date, mission, linked record or authority.

## Drill-down
Every referenced commercial object opens its owning workspace. Actions preserves return context when the user comes back.
