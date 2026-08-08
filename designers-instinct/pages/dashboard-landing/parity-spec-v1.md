# HOME Desktop Parity Specification v1

## Status

Authoritative visual parity contract for the first Director-facing HOME implementation in Sapphire Core OS.

This document extends:

- `page-doctrine.md`
- `surface-contract.md`
- `data-contract.md`
- `design-tokens.md`
- `codex-handoff.md`
- `../../sapphire-design-system/`

It does not replace them.

## Canonical reference

The Director-approved wide desktop concept supplied on 6 August 2026 remains the authority for HOME commercial content, widget order and broad composition. The later Director-approved `../../sapphire-design-system/actions-visual-direction-v1.md` is the authority for shell, density, material, shared components and interaction language.

Reference identity:

- source filename: `Generated image 2.png`
- canonical repository asset: `reference/home-approved-v1.png`
- source dimensions: `1672 × 940`
- aspect ratio: approximately `1.779:1`
- intended production class: desktop-first, 16:9 command-deck viewport

The older `reference/home-approved-v1.webp` derivative is retained only for repository history; it is dimensionally reduced and visually corrupted and must not be used for parity inspection. Codex must not combine the canonical PNG with earlier concepts. It must implement the reference through the Actions-derived live design system rather than reproducing conflicting page-local styling.

The implementation must preserve the approved composition, hierarchy, density, restraint and commercial emphasis while replacing illustrative or invented content with real components, typed fixtures and later Supabase-backed data.

## Product identity

HOME is not a conventional dashboard.

HOME is the Director's command deck and daily executive briefing.

The page must feel:

- opulent but restrained;
- institutional rather than decorative;
- high-value, controlled and commercially serious;
- suitable for managing million-pound commodity contracts;
- closer to a private trading floor than a generic SaaS homepage.

The visual doctrine is **Quiet Power**.

## Desktop target

The parity build is desktop-first.

Primary review viewport:

- `1920 × 1080`
- browser zoom: `100%`
- device pixel ratio: normal desktop reference

Secondary desktop validation:

- `1728 × 1117`
- `1600 × 900`
- `1440 × 900`

At the primary review viewport, all mandatory HOME regions must fit within one viewport without vertical page scrolling.

At narrower desktop widths, controlled density reduction is permitted. The page must not collapse into a tablet composition until the design system breakpoint explicitly requires it.

## Shell geometry

### Workspace navigation

- fixed thin rail, collapsed to approximately `64px` by default;
- full navigation reveals to approximately `224px` on pointer intent or keyboard focus;
- expanded navigation overlays the canvas and never changes content geometry;
- full viewport height with a darker background and subtle right divider;
- logo at top, primary navigation in the middle and system state toward the bottom;
- explicit mobile menu and drawer; no hover dependency on touch devices.

The navigation follows Actions and must feel narrow, disciplined and terminal-like.

### Main canvas

- occupies remaining width;
- target outer padding: `24px` left/right and `16px–20px` top/bottom;
- grid gap: `16px`;
- no arbitrary card offsets;
- all major boundaries align to a consistent column grid.

### Top utility bar

The top utility bar sits above the command content and contains:

- global search on the left;
- date, time and timezone context;
- notification and Inbox indicators;
- Director avatar and role on the right.

It must remain visually subordinate to the briefing.

## Canonical page hierarchy

The approved order is permanent for HOME v1:

1. Global utility bar
2. Director Briefing hero
3. Commercial Position
4. Market Radar
5. Commercial Movement
6. Director Attention
7. Actions Summary
8. Inbox Summary
9. Hot Right Now
10. Workspace Pulse

The sequence expresses the Director's cognitive journey:

1. What matters now?
2. What is the financial position?
3. Where are the signals coming from?
4. What is moving commercially?
5. What must be acted on?

Action widgets intentionally sit below briefing, money, radar and movement. They must not be promoted above those regions in the default Director layout.

## Grid composition

Use a 12-column desktop grid within the main canvas.

### Row 1

- Director Briefing: 8 columns
- Commercial Position: 4 columns

### Row 2

- Market Radar: 8 columns
- Commercial Movement: 4 columns

### Row 3

Four equal operational cards:

- Director Attention: 3 columns
- Actions Summary: 3 columns
- Inbox Summary: 3 columns
- Hot Right Now: 3 columns

### Row 4

- Workspace Pulse: 12 columns as a shallow horizontal status strip

The production implementation may refine exact pixel widths to preserve alignment, but it must not change this hierarchy without Director approval.

## Director Briefing hero

The briefing is the signature HOME experience and must dominate the first scan.

Required content:

- small overline such as `SAPPHIRE AI | DIRECTOR BRIEFING`;
- contextual greeting: `Good afternoon, Reuss.`;
- one-line framing statement: `Here's what matters right now.`;
- concise evidence-backed briefing points;
- no more than five visible briefing bullets in the default state;
- two or three immediate action buttons;
- visible freshness timestamp;
- distinction between verified fact, system calculation and AI inference.

Approved action pattern:

1. primary: `Review Opportunity`
2. secondary: `Open Approvals`
3. tertiary: `Show Full Analysis`

The primary button may use restrained gold emphasis. Secondary actions remain dark, bordered and calm.

The approved reference contains a geographic intelligence visual integrated into the right side of the hero. This may be implemented as a restrained globe, map or signal visual, but it must:

- remain subordinate to the briefing text;
- use navy, charcoal, sapphire and controlled gold;
- avoid game-like holograms, cyberpunk effects or excessive glow;
- carry commercial meaning rather than exist as decoration.

## Commercial Position

Commercial Position is the financial command surface and the second-most-important region.

Required visible measures:

- pipeline value;
- expected commission;
- high-confidence deals;
- value at risk;
- settlement due;
- cash position or equivalent liquidity condition.

The largest number is pipeline value.

The card must feel like private banking:

- large numerals;
- small precise labels;
- restrained dividers;
- minimal borders;
- no inflated empty space;
- no metric may appear visually larger than its information value justifies.

A compact line chart may support the main pipeline value. It must not dominate the figures.

## Market Radar

Market Radar is the approved large map region.

The map is not decorative. It must communicate live or recent commercial signals by geography.

Required behaviour:

- global overview;
- signal points or regions;
- clear but restrained signal intensity;
- drill-down to Market Radar;
- connection to Universal Profiles and evidence;
- ability to support commodity, property and other acquisition classes.

The approved reference includes a Hot Right Now list within or immediately adjacent to the map region. This embedded list may remain in the large radar card for context, while the dedicated operational Hot Right Now card in Row 3 remains the action-oriented summary.

Do not render a rainbow map. Default map styling is monochrome navy/graphite with controlled gold signal illumination and limited semantic state colour.

## Commercial Movement

Commercial Movement explains meaningful change across the operating system.

Default visible rows:

- Demand
- Supply
- Opportunities
- Matching
- Deals
- Finance

Each row contains:

- workspace label;
- principal figure;
- directional change;
- restrained sparkline;
- period context.

Sparklines use a single cool-blue family by default. Green and red may communicate positive or negative state but must not become decorative chart colours.

## Operational action row

The four Row 3 cards are deliberately compact. They are summaries, not full workspaces.

### Director Attention

Shows only conditions requiring Director awareness or authority.

### Actions Summary

Shows Missions, Tasks, Waiting On, Follow Ups and Approvals.

### Inbox Summary

Shows unread conversations, mentions, deal updates, supplier messages and system notifications.

### Hot Right Now

Shows the strongest current evidence-backed commercial signals with actions such as:

- Buy
- Sell
- List
- Watch
- Investigate
- Avoid

Every signal must expose confidence, freshness and evidence when opened.

## Workspace Pulse

Workspace Pulse is a shallow horizontal strip, not a large analytics panel.

It gives a compact health/status indication for the core workspaces and provides a route to recent activity or a fuller system view.

It must not compete with the Director Briefing, Commercial Position or Market Radar.

## Colour restraint

The implementation must follow the Sapphire Design System and the approved reference.

Visual proportion target:

- approximately 90% obsidian, graphite, navy and neutral text;
- approximately 8% sapphire/cool blue;
- approximately 2% controlled gold.

Semantic green, amber and red are allowed only when they communicate business state.

Prohibited:

- coloured headings for every widget;
- rainbow chart palettes;
- neon green as decoration;
- multiple competing accent colours;
- large glowing borders;
- cyberpunk gradients;
- colourful icon containers without semantic reason.

Gold communicates Director focus, premium emphasis, primary action or high-value intelligence. It must remain scarce.

## Typography parity

Use one primary UI type family across the application.

Preferred implementation:

- `Geist Variable` for UI, labels, controls and metrics;
- an approved restrained display serif may be used only for the greeting if the Sapphire Design System explicitly enables it.

If a display serif is used, it must be a deliberate brand exception—not an uncontrolled second UI font.

Rules:

- no random font mixing;
- tabular numerals for financial values;
- high contrast between major financial figures and their labels;
- headings remain restrained;
- body text must remain readable at dense desktop scale.

## Material and elevation

Surfaces should feel like matte titanium and dark institutional glass—not glossy consumer glassmorphism.

Use:

- deep navy-black canvas;
- slightly elevated graphite cards;
- subtle 1px borders;
- restrained inner highlights;
- minimal shadow;
- no exaggerated blur;
- no card that appears larger through decorative empty space.

## Motion parity

Motion must communicate weight and control.

Required behaviour:

- initial shell appears first;
- briefing and financial position enter with subtle stagger;
- remaining cards resolve without theatrical animation;
- hover transitions are restrained;
- card expansion uses deliberate, weighted easing;
- realtime updates do not flash the entire card.

Default durations:

- micro interaction: `120ms`
- hover/focus: `160ms`
- panel reveal: `220ms`
- workspace transition: `280ms–320ms`

Respect `prefers-reduced-motion`.

## Responsive boundaries

The canonical reference governs desktop only.

Do not infer tablet or mobile layouts by squeezing the desktop composition.

Responsive implementation must use separate approved adaptations:

- desktop command deck;
- compact desktop/laptop;
- tablet briefing layout;
- mobile/PWA action-first layout;
- future Capacitor shell.

Desktop parity must be completed and approved before mobile restructuring is considered complete.

## Asset rules

The implementation may use:

- Sapphire logo;
- Director avatar;
- vector icons from the approved icon family;
- programmatic charts;
- a lightweight vector, canvas or WebGL map if performance permits;
- type-specific acquisition thumbnails where commercially useful.

Avoid baking text, metrics or core UI into images.

The reference image is guidance, not a production background.

## Accessibility and correctness

Parity does not override correctness.

The build must include:

- keyboard navigation;
- visible focus states;
- sufficient contrast;
- semantic headings;
- accessible labels for charts and controls;
- reduced-motion support;
- no colour-only communication;
- accurate currencies, periods, confidence and freshness labels.

## Codex implementation order

1. Implement the shell, sidebar and utility bar.
2. Implement the 12-column desktop grid.
3. Build the Director Briefing and Commercial Position.
4. Build Market Radar and Commercial Movement.
5. Build the four operational summary cards.
6. Build Workspace Pulse.
7. Apply Sapphire Design System tokens.
8. Add motion and interaction states.
9. Connect typed fixtures matching the page data contract.
10. Run visual-regression comparison at `1920 × 1080`.
11. Present to the Director for parity approval.
12. Only then connect or generate final Supabase implementation where contracts remain unresolved.

## Parity acceptance criteria

The HOME build is not accepted until:

- the overall silhouette matches the canonical reference;
- the page reads as true widescreen desktop software;
- no mandatory region requires page scrolling at the primary review viewport;
- the Director Briefing dominates the first scan;
- Commercial Position clearly ranks second;
- Market Radar and Commercial Movement form the analytical second row;
- the action widgets remain in the lower operational row;
- colour use remains restrained;
- typography is coherent;
- information density feels premium rather than cramped;
- all cards align to the same grid;
- every visible metric has a definition, period and drill-down;
- the page remains functional when the illustrative reference assets are replaced by real data-driven components.

## Change control

Any material change to the following requires Director approval:

- widget order;
- desktop grid proportions;
- no-scroll objective;
- colour balance;
- typography family;
- briefing prominence;
- financial prominence;
- placement of action widgets;
- removal or demotion of Market Radar.

The canonical image and this document together form the HOME v1 parity authority.
