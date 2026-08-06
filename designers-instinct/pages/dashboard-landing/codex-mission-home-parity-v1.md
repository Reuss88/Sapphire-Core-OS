# CODEX MISSION — HOME 1:1 PARITY BUILD v1.0

## Status

Director-approved implementation mission.

This document is the authoritative handoff for Codex to build the Sapphire Core OS HOME page.

This is not a redesign exercise.

This is not a concept exploration.

This is a production implementation mission.

## Repository

`Reuss88/Sapphire-Core-OS`

## Canonical visual authority

The Director-approved reference is the wide desktop HOME image confirmed in the design review immediately before this mission.

Codex must treat that exact composition as the visual authority.

The approved composition is characterised by:

- true wide desktop proportions;
- permanent left navigation rail;
- top utility bar;
- Director Briefing as the first and dominant content block;
- Commercial Position to the right of the briefing;
- Market Radar and Commercial Movement beneath;
- Director Attention, Actions Summary, Inbox Summary and Hot Right Now on the lower action row;
- Workspace Pulse, Recent Activity and system context as supporting information;
- restrained midnight, graphite, sapphire and gold palette;
- one typography family;
- minimal use of status colour;
- no decorative AI cube;
- no tablet composition;
- no generic colourful SaaS styling.

If the build differs materially from this approved composition, the build is wrong.

## Mission objective

Build the first production-grade HOME page for Sapphire Core OS with 1:1 structural, visual and behavioural parity to the approved Director reference.

The result must feel like an elite commodity brokerage command deck handling million-pound commercial transactions.

The emotional objective is **Quiet Power**.

The interface must feel:

- opulent without being decorative;
- institutional without being cold;
- information-rich without becoming cluttered;
- technologically advanced without looking cyberpunk;
- authoritative, calm and expensive.

## Required stack

Use the repository's current architecture. Where the application shell is not yet present, use:

- Next.js 16 App Router;
- TypeScript with strict mode;
- React Server Components by default;
- Client Components only where interaction requires them;
- Tailwind CSS v4;
- CSS custom properties for semantic design tokens;
- shadcn/ui primitives only as implementation foundations;
- Lucide icons unless a repository-standard icon set already exists;
- Motion/Framer Motion only where motion is justified by the doctrine;
- typed fixtures until live backend contracts are connected.

Do not add a competing component framework.

Do not expose Supabase service-role credentials to the browser.

## Read before implementation

Codex must inspect and follow:

- `designers-instinct/README.md`
- `designers-instinct/dashboard-landing-principles.md`
- `designers-instinct/product-surface-map.md`
- `designers-instinct/parity-laws-v0.md`
- `designers-instinct/pages/dashboard-landing/README.md`
- `designers-instinct/pages/dashboard-landing/page-doctrine.md`
- `designers-instinct/pages/dashboard-landing/surface-contract.md`
- `designers-instinct/pages/dashboard-landing/data-contract.md`
- `designers-instinct/pages/dashboard-landing/design-tokens.md`
- `designers-instinct/pages/dashboard-landing/parity-spec-v1.md`
- `designers-instinct/sapphire-design-system/README.md`
- `designers-instinct/sapphire-design-system/foundations.md`
- `designers-instinct/sapphire-design-system/colour-system.md`
- `designers-instinct/sapphire-design-system/typography-layout.md`
- `designers-instinct/sapphire-design-system/motion-interaction.md`
- `designers-instinct/sapphire-design-system/commercial-semantics.md`
- `designers-instinct/sapphire-design-system/component-standards.md`
- `designers-instinct/sapphire-design-system/implementation-contract.md`

Existing repository doctrine outranks personal preference.

## Director Approval Lock

Once the Director approves a screen, it becomes immutable visual reference material.

Codex may improve:

- code quality;
- accessibility;
- performance;
- responsiveness;
- maintainability;
- test coverage.

Codex may not alter without new Director approval:

- visual hierarchy;
- widget order;
- information architecture;
- interaction model;
- commercial meaning;
- primary dimensions and proportions;
- palette balance;
- typography character.

## Reference viewport

Primary parity viewport:

- width: `1672px`;
- height: `940px`.

Production desktop target:

- `1920 × 1080`.

Minimum supported desktop:

- `1600 × 900`.

At the reference and production desktop viewports, HOME should fit within the viewport without page-level vertical scrolling.

If exact content causes overflow, preserve hierarchy and use controlled internal truncation, compact responsive spacing or card-level overflow. Do not turn HOME into a long scrolling dashboard.

## Desktop application shell

### Left navigation rail

Permanent on desktop.

Approximate width:

- `220px–240px` at the reference viewport;
- must not dominate the canvas.

Navigation order:

1. HOME
2. ACTIONS
3. INBOX
4. MARKET RADAR
5. DEMAND
6. SUPPLY
7. OPPORTUNITIES
8. MATCHING
9. DEALS
10. NETWORK
11. PROFILES
12. INTELLIGENCE
13. PERFORMANCE
14. DOCUMENTS
15. FINANCE
16. GOVERNANCE

Bottom rail content:

- Director Mode indicator;
- system status;
- settings access if already supported by the app shell.

Rules:

- HOME is visibly active;
- use one icon family;
- no coloured navigation labels;
- active state uses restrained sapphire treatment;
- avoid large pills or oversized selection backgrounds;
- preserve compact executive-terminal density.

### Top utility bar

Contains:

- global search;
- current time or session context;
- notifications;
- inbox/messages shortcut;
- Director identity/avatar;
- optional command palette trigger.

Do not add breadcrumbs to HOME.

Do not repeat the page title in the top bar.

## HOME information hierarchy

The page must tell this story:

1. Where are we?
2. What changed?
3. What is the commercial position?
4. Where is movement coming from?
5. What requires action?
6. What supporting context should the Director know?

The visual order is mandatory.

## Row 1 — orientation and money

### Director Briefing

Position:

- upper left;
- dominant content surface;
- approximately two-thirds of the main content width.

Purpose:

- greet the Director;
- summarise material commercial change;
- give immediate direction for the rest of HOME.

Required content:

- contextual greeting, such as `Good afternoon, Christopher.`;
- `Director Briefing` label or equivalent;
- concise evidence-linked briefing;
- key commercial conditions since the last session;
- explicit uncertainty where relevant;
- two or three immediate CTA buttons.

Initial CTA labels:

- `Review Opportunity`;
- `Open Approvals`;
- `Show Full Analysis`.

The actions may use typed fixtures until routes exist, but must be implemented as real interactive controls.

Rules:

- typography is the visual hero;
- no 3D AI cube;
- no oversized illustration;
- no chatbot transcript treatment;
- maximum one restrained supporting visual if the approved reference includes it;
- briefing copy must be scannable in under ten seconds;
- AI recommendations must be visually distinguishable from verified system facts.

### Commercial Position

Position:

- upper right;
- aligned with Director Briefing;
- approximately one-third of the main content width.

Purpose:

- show the Director the current financial/commercial position before geography or execution detail.

Required metrics:

- Pipeline;
- Expected Commission;
- High Confidence Deals;
- Value at Risk;
- Settlement Due;
- Cash Position or equivalent finance state.

Rules:

- numbers dominate;
- labels remain quiet;
- no fake enlargement of low-value metrics;
- all values use consistent currency and formatting;
- status colour is applied only to the state or delta, not the whole card;
- no rainbow KPI grid.

## Row 2 — source and movement

### Market Radar

Position:

- lower-left primary card;
- large enough for a meaningful map;
- wider than Commercial Movement.

Purpose:

- show where commercially relevant signals originate;
- become a signature Sapphire interaction surface.

Initial behaviour:

- render a high-quality dark world map;
- show restrained markers or heat states;
- distinguish BUY, SELL, WATCH, SOURCE, LIST or INVESTIGATE through semantic labels and minimal status colour;
- allow hover/focus inspection;
- support future drill-down by geography, profile, signal and opportunity.

Rules:

- no decorative tourism map;
- no random glowing routes;
- no excessive marker colours;
- map must remain legible at desktop density;
- use accessible text equivalents for all meaningful signals.

### Commercial Movement

Position:

- lower-right beside Market Radar.

Required categories:

- Demand;
- Supply;
- Matching;
- Deals;
- Finance.

Purpose:

- show material movement, not raw activity volume.

Rules:

- compact sparklines or trend indicators;
- one shared visual grammar;
- no large generic chart;
- every metric must drill into its owning workspace;
- directional movement must include period and definition.

## Row 3 — action surfaces

Place these four widgets on one lower row with equal visual weight:

1. Director Attention
2. Actions Summary
3. Inbox Summary
4. Hot Right Now

They belong below the briefing, money and context because the Director should understand the situation before entering execution.

### Director Attention

Contains only:

- approvals;
- high-value blockers;
- compliance or trust exceptions;
- expiring mandates or offers;
- material value deterioration;
- decisions requiring Director authority.

This is not a duplicate task list.

### Actions Summary

Must summarise:

- active missions;
- tasks due today;
- overdue work;
- waiting-on items;
- delegated work requiring review;
- mission progress.

Actions must link to the Actions workspace.

### Inbox Summary

Must summarise:

- unread priority communications;
- counterparty replies;
- internal team messages;
- finance/bank communications;
- communications linked to deals, profiles and missions.

Inbox must not look like a generic email client.

### Hot Right Now

Must summarise evidence-backed commercial signals such as:

- BUY;
- SELL;
- SOURCE;
- LIST;
- HOLD;
- AVOID;
- INVESTIGATE.

Every signal must expose:

- subject/profile;
- direction;
- evidence summary;
- confidence;
- time sensitivity;
- next valid action.

## Supporting row

Use remaining lower support space for:

- Workspace Pulse;
- Recent Activity;
- System Health or freshness context.

These are secondary.

They must never compete visually with the Director Briefing, Commercial Position, Market Radar or action row.

## Colour contract

Target balance:

- approximately 90% midnight, graphite and deep navy;
- approximately 8% sapphire blue;
- approximately 2% restrained luxury gold.

Status colours:

- emerald only for positive/verified/safe state;
- ruby only for critical/negative state;
- amber only for caution/pending state.

Rules:

- headings remain neutral white or soft-white;
- do not colour every heading;
- do not use green as decoration;
- do not use multiple bright blues;
- no neon gradients;
- no cyberpunk glow;
- no crypto-dashboard styling.

Use the Sapphire Design System semantic tokens. Do not hard-code ad hoc colours in components.

## Typography contract

Use one family only:

- Geist preferred;
- Inter Variable acceptable if Geist is unavailable or conflicts with the current repository.

Rules:

- no serif display font;
- no mixed typefaces;
- tabular numerals for financial data;
- restrained tracking;
- clear hierarchy through scale and weight, not colour;
- avoid excessively large KPI numerals that distort information importance.

## Surface and material contract

The interface should feel matte and titanium-like.

Cards:

- deep navy/graphite surfaces;
- thin low-contrast borders;
- subtle elevation only;
- radius around `16px–20px` according to existing tokens;
- no strong glassmorphism;
- no thick luminous outlines;
- no exaggerated shadows.

## Spacing and grid

Use an 8px base system.

Recommended desktop values:

- outer content padding: `24px–32px`;
- grid gap: `16px–24px`;
- internal card padding: `20px–24px`;
- compact navigation spacing;
- 12-column main content grid.

Do not introduce arbitrary spacing outside the token scale.

## Motion contract

Motion must feel deliberate, heavy and controlled.

Reference timings:

- hover/focus response: `120ms`;
- card/panel reveal: `180ms–220ms`;
- route/workspace transition: `260ms–300ms`.

Rules:

- no bounce;
- no springy overshoot;
- no looping decorative animation;
- no pulsing cards unless representing a genuine live state;
- support `prefers-reduced-motion`;
- animations must not delay access to critical information.

## Component architecture

Build reusable components rather than one large page component.

Suggested structure:

```text
app/
  (director)/
    home/
      page.tsx
      loading.tsx
      error.tsx

components/
  sapphire/
    app-shell/
    navigation/
    home/
      director-briefing.tsx
      commercial-position.tsx
      market-radar.tsx
      commercial-movement.tsx
      director-attention.tsx
      actions-summary.tsx
      inbox-summary.tsx
      hot-right-now.tsx
      workspace-pulse.tsx
      recent-activity.tsx
      system-health.tsx

lib/
  fixtures/
    home-director-snapshot.ts
  contracts/
    home.ts
```

Adapt paths to the existing repository rather than duplicating structure.

## Data contract

Use the existing page data doctrine and prepare the UI for:

`dashboard_get_director_snapshot_v1(p_scope jsonb, p_period tstzrange, p_timezone text)`

Until the RPC exists or is safe to connect:

- use typed, deterministic fixtures;
- keep fixtures realistic for commodity brokerage;
- do not scatter mock values across components;
- expose one page-level typed snapshot contract;
- preserve loading, stale, partial, offline and error states.

Do not invent permanent database business logic in the frontend.

## Required states

Every major widget must implement:

- loading;
- populated;
- empty;
- stale;
- partial data;
- permission denied;
- error;
- offline/PWA state where relevant.

Critical alerts may not disappear merely because one secondary data source fails.

## Accessibility

Requirements:

- semantic landmarks;
- keyboard navigation;
- visible focus states;
- WCAG-compliant contrast;
- text alternatives for map/chart signals;
- no colour-only meaning;
- minimum practical desktop target sizes;
- reduced motion support.

Target Lighthouse accessibility score: `95+`.

## Responsive behaviour

Desktop parity is the priority.

For widths below the supported desktop threshold:

- preserve information hierarchy;
- allow controlled reflow;
- do not simply shrink the desktop canvas;
- keep Director Briefing first;
- keep Commercial Position immediately after;
- preserve action ordering;
- use drawers/sheets for navigation on mobile/PWA;
- retain commercial meaning across future Capacitor surfaces.

Responsive work must not compromise the approved desktop composition.

## Visual regression requirement

Create a repeatable visual test at the canonical viewport.

At minimum:

- capture HOME at `1672 × 940`;
- compare against the approved composition;
- verify sidebar, header, row heights, card proportions, typography hierarchy and colour balance;
- document intentional deviations;
- require Director approval for any material deviation.

If Playwright is available, add a screenshot test. Otherwise create the test scaffolding and document the command.

## Validation commands

Run the relevant repository commands, including where available:

- install;
- lint;
- typecheck;
- unit tests;
- production build;
- accessibility check;
- visual screenshot test.

Do not report completion with failing TypeScript, lint or build checks.

## Deliverables

Codex must provide:

1. production HOME implementation;
2. reusable Sapphire components;
3. central semantic tokens;
4. typed fixture snapshot;
5. loading/error/empty states;
6. responsive behaviour;
7. visual regression screenshot/test;
8. implementation notes describing any unavoidable deviation;
9. validation results;
10. commit and branch details.

## Explicit prohibitions

Do not:

- redesign the page;
- reorder the widgets;
- move actions above the briefing;
- create a tablet-first composition;
- add colourful headings;
- add decorative 3D AI artwork;
- use multiple font families;
- inflate minor metrics;
- turn HOME into a generic CRM dashboard;
- add fake glass, neon glow or cyberpunk styling;
- replace the map with a generic chart;
- introduce backend authority logic in the browser;
- claim 1:1 parity without a canonical viewport screenshot.

## Acceptance gate

The mission passes only when:

- the approved wide desktop composition is recognisable immediately;
- Director Briefing is the first visual and cognitive anchor;
- Commercial Position is the second anchor;
- Market Radar and Commercial Movement occupy the contextual middle row;
- the four action widgets form the lower execution row;
- colour is restrained and commercially semantic;
- one font family is used;
- the desktop viewport does not become a long scrolling dashboard;
- all components use design-system tokens;
- accessibility, typecheck, lint and build checks pass;
- a visual parity screenshot is produced for Director review.

## Final instruction

Implement the approved design.

Do not reinterpret it.

Where doctrine is clear, follow it.

Where implementation detail is genuinely undefined, choose the least visually disruptive, most maintainable option and document it for Director review.
