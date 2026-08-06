# Dashboard Landing Design Tokens

## Purpose

These are page-level semantic tokens for the first Dashboard Landing design. They sit above raw colour, spacing and typography primitives and below page components.

Tokens describe commercial meaning. They must not hard-code visual styling that belongs in the future locked design system.

## Token layers

1. **Foundation tokens** — global colour, type, spacing, radius, elevation, motion and breakpoint primitives.
2. **Semantic tokens** — meaning such as critical, warning, progressing, positive, neutral, stale and AI-generated.
3. **Page tokens** — Dashboard Landing hierarchy, density, regions and widget states.
4. **Component tokens** — card, queue item, metric, chart and navigation implementation details.

No page component may consume raw colour values when a semantic token exists.

## Required page tokens

### Layout

- `dashboard.max-content-width`
- `dashboard.page-padding-inline`
- `dashboard.page-padding-block`
- `dashboard.region-gap`
- `dashboard.grid-gap`
- `dashboard.primary-column-span`
- `dashboard.secondary-column-span`
- `dashboard.mobile-stack-gap`
- `dashboard.safe-area-top`
- `dashboard.safe-area-bottom`

### Density

- `dashboard.density.comfortable`
- `dashboard.density.compact`
- `dashboard.card.min-height`
- `dashboard.queue.visible-items`
- `dashboard.workspace-pulse.visible-signals`

### Visual hierarchy

Maximum three emphasis levels:

- `dashboard.emphasis.primary` — Director attention and material commercial state.
- `dashboard.emphasis.secondary` — movement, emerging value and workspace pulse.
- `dashboard.emphasis.tertiary` — contextual support and metadata.

### Commercial state

- `state.critical`
- `state.warning`
- `state.attention`
- `state.progressing`
- `state.positive`
- `state.neutral`
- `state.stale`
- `state.partial`
- `state.offline`
- `state.unauthorised`

State tokens must define at minimum foreground, background, border, icon treatment and accessible text contrast. Colour may never be the only carrier of state.

### AI distinction

- `ai.recommendation.surface`
- `ai.recommendation.border`
- `ai.recommendation.label`
- `ai.confidence.high`
- `ai.confidence.medium`
- `ai.confidence.low`
- `ai.evidence-link`

AI recommendations must remain visibly distinct from verified commercial facts without appearing more authoritative.

### Freshness

- `freshness.live`
- `freshness.recent`
- `freshness.stale`
- `freshness.offline`
- `freshness.partial`

Each freshness token must pair a visual treatment with a human-readable timestamp or status label.

### Interaction

- `interaction.touch-target-min: 44px`
- `interaction.focus-ring`
- `interaction.hover`
- `interaction.pressed`
- `interaction.disabled`
- `interaction.destructive-confirmation`
- `interaction.authority-bearing-confirmation`

### Motion

- `motion.feedback-duration`
- `motion.region-transition-duration`
- `motion.reduced-motion-fallback`

Motion must clarify state change, not decorate. Critical information may not depend on animation.

## Typography roles

- `type.dashboard-title`
- `type.region-title`
- `type.primary-metric`
- `type.secondary-metric`
- `type.card-title`
- `type.card-body`
- `type.metadata`
- `type.status-label`
- `type.action-label`

Typography must preserve the three-level emphasis law and remain usable at mobile text scaling.

## Token implementation

For the Next.js 16 application, semantic tokens should be exposed through CSS custom properties and mapped into the chosen utility/component system. Names must remain stable even if primitive values change.

The installed PWA and Capacitor wrapper must consume the same semantic token source. Native-shell-specific safe-area tokens may extend, but not fork, page meaning.

## Prohibitions

- No one-off hex values in page components.
- No chart colour chosen without semantic meaning and accessible fallback.
- No different token meaning between web, PWA and Capacitor.
- No status represented by colour alone.
- No more than three simultaneous visual emphasis levels.
- No decorative elevation that competes with Director attention.

## Locking rule

Values remain provisional until the Director approves the first landing design. After approval, the accepted semantic names and meanings become the input to Phase 2 Design Laws and eventually the locked design system.
