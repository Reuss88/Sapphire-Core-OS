# Sapphire Dashboard Design Mission — v1

## Mission status

- Mission type: product-design exploration
- Deliverable: rough first dashboard design, not production UI
- Authority: Sapphire Broker OS doctrine is binding
- Scope: one operator dashboard for the lead-to-settlement vertical slice

## Objective

Design the first rough visual and interaction concept for Sapphire Core OS: a single operator-facing dashboard that makes the broker’s commercial loop legible and actionable.

The design must help an operator see:

1. What demand has entered the system.
2. Which opportunities are qualified and need action.
3. Where suitable supply and possible matches exist.
4. What is moving toward close, fulfilment, and settlement.
5. What commercial value, commission, and operational performance are emerging.

## Product doctrine to preserve

Sapphire is a Broker Operating System. It connects demand and supply, coordinates deals, captures relationship and pricing evidence, and earns subscription plus transaction revenue.

The dashboard supports the operating loop:

Demand detected → supply identified → lead qualified → opportunity matched → conversion → fulfilment → settlement → commission or revenue recorded → intelligence improves.

Do not frame Sapphire as a generic CRM, marketplace, or architecture tool.

## Primary user

The primary user is the broker or operator managing an active network of demand sources, suppliers, introducers, closers, fulfilment partners, and customers.

Secondary roles may appear through ownership, assignment, or performance views, but the first design is not a separate dashboard for every role.

## Required dashboard areas

Create a coherent first-screen experience containing:

- a concise commercial health summary: active pipeline, deal value, expected commission or margin, conversion, and items needing attention;
- a pipeline view following the lead-to-settlement lifecycle;
- an action queue for stalled, unassigned, overdue, or decision-blocked work;
- a compact matching view that pairs an opportunity with candidate supply, including match rationale or confidence;
- a network and relationship signal that shows relevant people, organisations, trust or performance context, and introductions;
- a performance view for lead sources, closer conversion, supplier outcomes, and major funnel movement;
- clear paths from summary cards to underlying leads, opportunities, matches, and deals.

Use illustrative data only. Every label, metric, state, and action should have a plausible connection to the Broker OS doctrine.

## Design boundaries

- Make the experience commercially useful before making it technically comprehensive.
- Preserve the distinction between workflow, lifecycle, authority, and access. A routed item is not automatically authorised.
- AI may present recommendations, match rationale, and prepared work; it must not appear to approve commercial commitments or create authority.
- Pricing, subscription tiers, commission percentages, settlement authority, and the first vertical are not decided. Represent these as configurable or clearly assumed; do not invent final policies.
- Do not turn the dashboard into a generic analytics wall. Prioritise decisions and next actions.
- This is a rough design mission. Do not implement application code, database schema, or production components.

## Expected output

Provide:

1. A desktop dashboard design, with the main screen fully composed.
2. A short design rationale explaining how the layout follows the commercial operating loop.
3. A concise component inventory and interaction notes.
4. A list of assumptions and unresolved decisions that require Director confirmation.
5. Optional: one supporting detail view for an opportunity, match, or action queue if it improves clarity.

## Acceptance criteria

The result is ready for an implementation agent to use as a first visual reference when:

- an operator can identify the most valuable or blocked work within seconds;
- the path from lead to settlement is visible;
- commercial outcomes and operational activity are connected;
- matching and relationship intelligence are visible but not overclaimed;
- unresolved policy decisions remain explicit;
- the visual language feels like a focused Broker Operating System rather than a generic CRM.

## Source doctrine

- Canonical Broker OS Definition
- Sapphire Business Comprehension Pack v2
- Locked Architecture Summary
- Architecture Status
- Sapphire Core OS Roadmap
