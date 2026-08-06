# Dashboard Landing Page Doctrine

## Status

Authoritative page doctrine for the first Director-facing HOME design.

## Primary purpose

Provide the Director with a decision-ready commercial command centre that reveals system movement, material risk, required intervention, communication obligations, execution priorities and emerging value.

## Dominant commercial question

What requires the Director's attention now, what must be done, who requires a response, what is progressing, and where is commercially actionable value being created or blocked?

## Mandatory questions answered

1. What is happening?
2. What needs attention?
3. What must be done today?
4. Who or what requires a response?
5. What is progressing or blocked?
6. What commercial value is emerging?
7. What is hot right now, why, and what action is justified?

## Mandatory page regions

The first HOME design must contain these regions in order of commercial priority, not merely visual preference:

1. **Command Header** — page identity, current scope, last successful refresh and global period/filter controls.
2. **Director Attention Queue** — highest-priority exceptions, approvals, blockers, risks and expiring conditions.
3. **Actions Summary** — missions, tasks, decisions, follow-ups, overdue work, blocked work and waiting-on states requiring Director awareness.
4. **Inbox Summary** — communications requiring response, high-value or high-risk conversations and overdue external replies.
5. **Hot Right Now** — strongest evidence-backed buy, sell, source, list, hold, avoid or investigate signals.
6. **Commercial Movement** — concise meaningful movement across demand, supply, opportunities, matches and deals.
7. **Emerging Value** — weighted pipeline, expected commission, value at risk and material changes.
8. **Workspace Pulse** — compact summaries across the permanent Commercial Workspaces.
9. **Performance Context** — only metrics that explain current conditions or direct action.
10. **AI Director Brief** — evidence-linked explanation and recommendation, never autonomous approval or authority.

Responsive layouts may change placement, but may not erase these distinctions or hide critical conditions.

## Required card contract

Every card or widget must answer:

- **What?** Current state, obligation, signal or change.
- **Why?** Why it matters commercially.
- **What next?** Next valid action or drill-down.

Every widget must declare:

- owning workspace;
- referenced records or profiles;
- data source or RPC;
- freshness and evidence state;
- permission boundary;
- drill-down route;
- empty, loading, partial, stale, offline and error states.

## Director Attention Queue

This queue is not a generic task list. It contains only conditions justifying Director awareness or intervention, including:

- approvals reserved for Director authority;
- blocked high-value missions, opportunities or deals;
- material compliance, trust or finance risk;
- expiring mandates, offers or documents;
- missing execution evidence;
- material value deterioration;
- critical workflow exceptions;
- AI recommendations explicitly awaiting human judgement.

Ranking may consider severity, urgency, value exposure and confidence, but may not grant authority.

## Actions Summary

The Actions Summary must reveal:

- actions due today;
- overdue actions;
- missions at risk;
- tasks blocked by dependencies;
- items waiting on external parties;
- decisions requiring Director authority;
- assignments by role, including Closers and Research Specialists;
- recently completed material actions.

Every item must link to the canonical Action, Mission, Decision or owning commercial record.

HOME must not maintain a duplicate task state.

## Inbox Summary

The Inbox Summary must reveal:

- messages requiring the Director's response;
- communications affecting active deals, missions, finance or compliance;
- high-value and high-risk threads;
- overdue external replies;
- communication-derived actions or decisions;
- channel, participant, commercial context and response status.

Read state must not be presented as resolved state.

HOME must not become a full messaging client.

## Hot Right Now

Hot Right Now must reveal only the strongest current decision-relevant signals.

Each signal must show:

- subject profile;
- proposed action: buy, sell, source, list, hold, avoid, monitor or investigate;
- reason the action matters now;
- expected upside, downside or value exposure;
- confidence and freshness;
- key evidence and unresolved uncertainty;
- action window;
- next valid action;
- link to Market Radar or the subject Profile.

Examples may include commodity price dislocation, rising demand, verified inventory, property market timing or acquisition pricing gaps.

No signal may appear as a bare arrow, colour or unsupported instruction.

## Commercial Movement

Movement must show meaningful transitions rather than raw activity, including demand qualification, supply verification, match outcomes, opportunity stage changes, deal milestones, finance progress and mission execution.

## Emerging Value

Value must distinguish:

- gross potential value;
- probability-weighted value;
- expected commission;
- realised revenue or commission;
- value at risk;
- change over the selected period.

No value number may appear without definition, currency, period and drill-down.

## Profile dependency

HOME summaries and signals must reference canonical Profiles where the subject is an asset, commodity, property, vehicle, watch, company, person, contract, deal, bank, facility, route or other commercially relevant object.

HOME must not create shadow profile data.

## AI boundary

AI may summarise evidence, explain changes, identify likely causes, rank attention candidates, recommend actions, extract communication commitments and highlight uncertainty.

AI may not approve a deal, acquisition, mandate, payment, message or counterparty; bypass RLS; represent inference as verified fact; or mutate records without explicit authorised action or approved policy.

## Prohibitions

HOME must not become:

- a CRM record browser;
- a full task manager;
- a full messaging client;
- a general market terminal;
- a full reporting suite;
- every workspace reproduced on one page;
- a decorative chart gallery;
- a place where business logic is invented in the frontend;
- a surface where visibility implies permission.

## Acceptance standard

HOME passes doctrine review only when the Director can, within one scan:

- identify the most important commercial condition;
- identify today's most important actions and missions;
- see who requires a response;
- recognise the strongest current acquisition or market signal;
- understand why each item matters;
- see the next valid action;
- distinguish verified evidence from AI inference;
- drill into the owning workspace or canonical profile;
- recognise stale, incomplete, offline or unavailable data;
- preserve the same commercial meaning across desktop, installed PWA and future Capacitor surfaces.
