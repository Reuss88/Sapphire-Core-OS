# MISSION — HOME 1:1 PARITY BUILD v1.0

## Mission status

Approved for implementation by the Director.

This is a build mission, not a design exercise.

Codex must implement the Sapphire Core OS HOME page with faithful visual, structural and behavioural parity to the approved desktop reference stored in this repository.

## Canonical visual authority

The approved reference image is:

`designers-instinct/pages/dashboard-landing/reference/home-approved-v1.webp`

This image is the visual law for the first HOME build.

Do not redesign it. Do not reinterpret its hierarchy. Do not replace it with a generic dashboard. Do not merge in elements from earlier concepts.

Where implementation differs materially from the reference, change the implementation.

## Governing doctrine

Read these files before changing code:

- `designers-instinct/pages/dashboard-landing/page-doctrine.md`
- `designers-instinct/pages/dashboard-landing/surface-contract.md`
- `designers-instinct/pages/dashboard-landing/data-contract.md`
- `designers-instinct/pages/dashboard-landing/design-tokens.md`
- `designers-instinct/pages/dashboard-landing/parity-spec-v1.md`
- `designers-instinct/pages/dashboard-landing/codex-handoff.md`
- `designers-instinct/sapphire-design-system/README.md`
- `designers-instinct/sapphire-design-system/foundations.md`
- `designers-instinct/sapphire-design-system/colour-system.md`
- `designers-instinct/sapphire-design-system/typography-layout.md`
- `designers-instinct/sapphire-design-system/motion-interaction.md`
- `designers-instinct/sapphire-design-system/commercial-semantics.md`
- `designers-instinct/sapphire-design-system/component-standards.md`
- `designers-instinct/sapphire-design-system/implementation-contract.md`

The reference controls visual composition. Doctrine controls commercial meaning, ownership, authority, permissions and data behaviour.

## Technology contract

Use the repository's existing application architecture where present. Do not create a competing application shell.

The intended stack is:

- Next.js 16 App Router
- TypeScript in strict mode
- React Server Components by default
- Client Components only where interaction requires them
- Tailwind CSS v4
- shadcn/ui as low-level primitives only, not as a visual identity
- Lucide icons or the existing approved icon system
- Framer Motion or the repository's approved motion layer

Inspect the repository before installing or replacing dependencies.

## Build sequence

1. Inspect the repository, package configuration, existing routes, tokens and components.
2. Identify the existing application entry point and HOME route.
3. Reuse existing foundations where they conform to doctrine.
4. Establish missing Sapphire tokens before styling page components.
5. Build the page shell and exact desktop grid.
6. Build widgets in the order specified below.
7. Populate the first pass using deterministic typed brokerage fixtures.
8. Add meaningful interactions, focus states and reduced-motion behaviour.
9. Capture a desktop implementation screenshot at the parity viewport.
10. Compare it directly with `reference/home-approved-v1.webp` and correct visible drift.
11. Run validation commands and report their results.

Do not begin by inventing Supabase schema. The first mission is an approved Director-reviewable parity surface. Backend integration must follow the existing data contract and schema-mapping process.

## Desktop viewport contract

Primary parity viewport:

- Width: `1920px`
- Height: `1080px`

Approved reference aspect ratio:

- `1672 × 940`
- approximately `1.779:1`

Minimum full desktop target:

- `1600 × 900`

At the primary parity viewport, HOME must present the complete command deck without ordinary page-level vertical scrolling.

Internal overflow may be used only where a component contract explicitly requires it. Do not hide required regions to force the page to fit.

## Structural layout

### Application shell

- Permanent left navigation rail on desktop.
- Compact global utility rail across the top of the main content.
- Main content uses a controlled twelve-column grid.
- Use an 8px spacing foundation.
- Target outer content padding: approximately 32px.
- Target major grid gap: approximately 20–24px.
- Sidebar target width: approximately 220–240px, adjusted only to preserve reference proportions.
- Borders must be subtle and low-contrast.
- Surfaces must feel matte, dense and institutional rather than glassy or playful.

### Navigation order

The desktop rail contains:

1. Home
2. Actions
3. Inbox
4. Market Radar
5. Demand
6. Supply
7. Opportunities
8. Matching
9. Deals
10. Network
11. Profiles
12. Intelligence
13. Performance
14. Documents
15. Finance
16. Governance

The lower rail contains Director Mode and operational status.

### Utility rail

The top utility area contains:

- global search;
- date and time context;
- notifications;
- inbox/messages indicator;
- Director identity and menu.

Do not add breadcrumbs or a duplicate page title.

## Exact information hierarchy

### Row 1 — Orientation and money

#### Director Briefing — left, dominant

Target span: approximately 8 of 12 columns.

Must contain:

- `SAPPHIRE AI | DIRECTOR BRIEFING` eyebrow;
- personalised greeting;
- one concise orientation line;
- a short evidence-led briefing list;
- exactly two or three immediate action buttons;
- the approved globe/market-network treatment positioned as supporting atmosphere rather than the primary content.

Approved first-pass CTAs:

- `Review Opportunity`
- `Open Approvals`
- `Show Full Analysis`

Typography, not decorative AI artwork, must remain dominant.

#### Commercial Position — right

Target span: approximately 4 of 12 columns.

Must present:

- Pipeline Value;
- Expected Commission;
- High Confidence Deals;
- Value at Risk;
- Settlement Due;
- Cash Position.

The primary money figure dominates. Labels and period comparisons remain subordinate. Financial definitions must remain consistent with the data contract.

### Row 2 — Geographic intelligence and movement

#### Market Radar — left, dominant

Target span: approximately 8 of 12 columns.

Must contain:

- a dark global map;
- restrained signal markers;
- market signal context;
- a compact `Hot Right Now` list integrated on the right side of the radar card;
- a clear route to the full Market Radar workspace.

The map is not decorative. Each signal must be modelled as drillable data, even when fixtures are used.

#### Commercial Movement — right

Target span: approximately 4 of 12 columns.

Must show concise movement for:

- Demand;
- Supply;
- Opportunities;
- Matching;
- Deals;
- Finance.

Use compact figures and restrained sparklines. Do not turn this region into a large charting suite.

### Row 3 — Execution surfaces

Four equal-width cards in this exact order:

1. Director Attention
2. Actions Summary
3. Inbox Summary
4. Hot Right Now

These sit below the briefing, financial context, radar and movement so the Director reaches execution after becoming oriented.

All four cards must share a consistent height, density and visual weight. No card may pretend to be more important through arbitrary size.

#### Director Attention

Only Director-worthy exceptions, approvals, risks and blocked commercial conditions.

#### Actions Summary

Missions, tasks, waiting-on items, follow-ups and approvals.

#### Inbox Summary

Unread conversations, mentions, deal updates, supplier messages and system notifications.

#### Hot Right Now

Evidence-backed buy, sell, list, watch, source, avoid or investigate signals. Status colours communicate state only.

### Row 4 — Workspace pulse

A thin, full-width supporting strip matching the reference.

It summarises workspace health without competing with the command deck above it.

The row should feel like a status rail, not a second dashboard.

## Visual language

Emotional objective: **Quiet Power**.

The platform must feel like an institutional commodity trading and private-capital environment handling multi-million-pound contracts.

It must not feel like:

- gaming software;
- crypto software;
- a neon cyberpunk terminal;
- a generic CRM;
- an unmodified shadcn dashboard;
- a decorative analytics template.

### Colour discipline

Use predominantly:

- Midnight Obsidian;
- Graphite Navy;
- controlled elevated navy surfaces;
- neutral white and cool-grey typography;
- restrained Sapphire Blue;
- restrained Luxury Gold.

Green, red and amber are reserved for commercial state, risk or movement. They are not general decoration.

Avoid multicoloured headings. Prefer neutral headings with a small semantic icon, rule or eyebrow accent.

### Typography discipline

Use Geist Sans or the repository's approved primary UI family throughout the operating interface.

To match the approved reference, a single controlled display serif may be used only for the personalised Director greeting. It must not leak into cards, tables, navigation, buttons or body copy.

No uncontrolled font mixing.

### Surface discipline

- Matte surfaces.
- Low-contrast borders.
- Minimal shadows.
- No widespread glassmorphism.
- No excessive gradients.
- No decorative glows except restrained map signals and approved focus treatments.
- Corners and spacing must come from system tokens.

## Motion contract

Motion communicates hierarchy and state; it does not decorate.

Recommended timings:

- hover and micro-feedback: `120ms`;
- card/panel reveal: `220ms`;
- route/workspace transition: `300ms`.

Use controlled easing with no bounce or springy novelty.

Support `prefers-reduced-motion` and preserve comprehension when motion is disabled.

## Data and behaviour

Until production backend contracts are connected, use deterministic typed fixtures that reflect credible commodity brokerage operations.

Do not generate random values during rendering.

Every widget must be structured so that it can later bind to the approved dashboard snapshot contract without a visual rewrite.

No frontend component may invent commercial authority, approval logic, metric definitions or record ownership.

## Required interactions

The first parity build must include meaningful routes or controlled placeholders for:

- global search;
- Review Opportunity;
- Open Approvals;
- Show Full Analysis;
- View Finance;
- View Full Radar;
- Director Attention detail;
- Actions workspace;
- Inbox workspace;
- Hot Right Now detail;
- each navigation item.

A placeholder may explain that a workspace is not yet implemented, but buttons must not silently fail.

## Responsive rule

Desktop parity is the priority of this mission.

Do not damage desktop parity in pursuit of premature mobile redesign.

Below desktop widths, preserve information hierarchy and progressively stack regions. Tablet, PWA and Capacitor-specific layouts will receive separate Director approval.

## Accessibility and quality

Required:

- semantic landmarks;
- keyboard navigation;
- visible focus treatment;
- meaningful labels for icon-only controls;
- status not communicated by colour alone;
- readable contrast;
- reduced-motion support;
- no console errors;
- no TypeScript errors.

Aim for Lighthouse Accessibility `95+`, but do not falsify or claim a score without running it.

## Visual parity validation

Before declaring completion:

1. Run the app at `1920 × 1080`.
2. Capture a screenshot of the implemented HOME page.
3. Compare it side-by-side with:
   `designers-instinct/pages/dashboard-landing/reference/home-approved-v1.webp`
4. Correct discrepancies in:
   - shell proportions;
   - sidebar width;
   - row heights;
   - column spans;
   - card alignment;
   - typography scale;
   - spacing;
   - surface contrast;
   - colour restraint;
   - widget order;
   - visible scrolling.

Do not claim 1:1 parity without producing and checking the implementation screenshot.

## Acceptance criteria

The mission passes only when:

- the approved reference is recognisable immediately in the implementation;
- the desktop hierarchy and widget order match exactly;
- the primary viewport fits the complete command deck without ordinary page scroll;
- Director Briefing and Commercial Position lead the page;
- Market Radar and Commercial Movement form the second row;
- the four execution cards form the third row;
- Workspace Pulse forms the final supporting strip;
- colours remain restrained and commercially semantic;
- design tokens are used instead of arbitrary values;
- buttons, routes and focus states behave meaningfully;
- TypeScript, lint and production build checks pass, or exact blockers are reported;
- an implementation screenshot is committed or otherwise supplied for Director review.

## Director Approval Lock

This reference and hierarchy are Director-approved.

Engineering may improve accessibility, performance, semantics, maintainability and responsiveness without changing the approved visual hierarchy, interaction model or information architecture.

Any material product or visual change requires a new Director approval.

## Required Codex completion report

When finished, report:

- branch;
- commit SHA;
- files created and modified;
- route implemented;
- validation commands and results;
- screenshot path;
- known deviations from the reference;
- backend or product dependencies intentionally deferred.

Do not report the mission complete while known material parity deviations remain hidden.