# Dashboard Landing Page Doctrine

## Status

Authoritative page doctrine for the first Director-facing Dashboard Landing design.

## Primary purpose

Provide the Director with a decision-ready commercial command centre that reveals system movement, material risk, required intervention and emerging value.

## Dominant commercial question

What requires the Director's attention now, what is progressing, and where is commercial value being created or blocked?

## Mandatory questions answered

1. What is happening?
2. What needs attention?
3. What is progressing?
4. What commercial value is emerging?

## Mandatory page regions

The first landing design must contain these regions in this order of importance:

1. **Command header** — page identity, current scope, last successful refresh and global period/filter controls.
2. **Director attention queue** — the highest-priority exceptions, approvals, blockers and expiring conditions.
3. **Commercial movement** — concise stage movement across opportunities, matches and deals.
4. **Emerging value** — weighted pipeline value, expected commission and material value changes.
5. **Workspace pulse** — compact summaries for Demand, Supply, Opportunities, Matching, Deals, Network and Intelligence.
6. **Performance context** — only metrics that explain current commercial conditions or direct the user to action.
7. **AI briefing** — evidence-linked explanation and recommendations, never autonomous approval or authority.

## Priority order

1. Safety, compliance and execution risk.
2. Director decisions and approvals.
3. Time-sensitive blockers and deadlines.
4. Material stage movement.
5. Emerging value and value-at-risk.
6. Contextual performance.
7. Informational background.

## Required card contract

Every card or widget must answer:

- **What?** The current state or change.
- **Why?** Why the condition matters commercially.
- **What next?** The next valid action or drill-down.

Every widget must declare:

- owning workspace;
- referenced records;
- data source or RPC;
- freshness state;
- permission boundary;
- drill-down route;
- empty, loading, stale and error states.

## Director attention queue

The queue is not a generic task list. It contains only conditions that justify Director awareness or intervention, including:

- approvals reserved for Director authority;
- blocked high-value opportunities or deals;
- expiring mandates, offers or material documents;
- unresolved KYC/KYB or trust risk affecting execution;
- missing execution evidence;
- material value deterioration;
- critical workflow exceptions;
- AI recommendations explicitly awaiting human judgement.

Items must be ranked by severity, urgency, value exposure and confidence. The ranking may recommend order but may not grant authority.

## Commercial movement

Movement must show meaningful transitions rather than raw activity. Examples include:

- demand qualified;
- supply verified;
- match accepted or rejected;
- opportunity advanced, stalled or lost;
- deal milestone completed or blocked;
- settlement or commission status changed.

## Emerging value

Value must distinguish:

- gross potential value;
- probability-weighted value;
- expected commission;
- realised revenue or commission;
- value at risk;
- change over the selected period.

No value number may appear without its definition, currency, period and drill-down.

## AI boundary

AI may:

- summarise evidence;
- explain changes;
- identify likely causes;
- rank attention candidates;
- recommend next actions;
- highlight uncertainty.

AI may not:

- approve a deal, mandate, counterparty or payment;
- bypass RLS or workflow permissions;
- represent inference as verified fact;
- mutate commercial records from the briefing surface without an explicit authorised user action.

## Prohibitions

The Dashboard Landing must not become:

- a CRM record browser;
- a full reporting suite;
- every workspace reproduced on one page;
- a decorative chart gallery;
- a place where hidden business logic is invented in the frontend;
- a substitute for workspace ownership;
- a surface where visibility implies permission.

## Personalisation

Personalisation may control ordering, density, saved scope and collapsed regions. It may not hide mandatory critical alerts, alter authority, change metric definitions or create different business truth for different users.

## Acceptance standard

The page passes doctrine review only when the Director can, within one scan:

- identify the most important commercial condition;
- understand why it matters;
- see the next valid action;
- distinguish verified data from AI inference;
- drill into the owning workspace;
- recognise stale, incomplete or unavailable data;
- use the same commercial meaning on desktop, installed PWA and future Capacitor surfaces.
