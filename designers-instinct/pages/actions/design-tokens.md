# Actions Design Tokens

Actions inherits the Sapphire Design System. This file adds page-level semantic tokens only; it does not create a competing visual system.

## Surface roles
- `--actions-surface-queue`: primary execution pane
- `--actions-surface-inspector`: selected-item context pane
- `--actions-surface-rail`: lens/navigation rail
- `--actions-surface-mission`: mission summary surface

## Semantic accents
Status colours are reserved for meaning, not decoration:
- critical/blocked/error -> system critical token
- waiting/warning -> system warning token
- completed/healthy -> system success token
- selected/focus/active -> sapphire accent
- authority-required -> restrained gold semantic accent

Headings remain neutral/white. Do not colour-code whole card headings by status.

## Density
Desktop Actions is intentionally denser than HOME because it is an execution workspace.
- queue row min height: 56px
- comfortable row: 64px
- compact row: 48px where user opts in
- inspector internal spacing follows 8px grid

## Radius
Use global Sapphire radii. Queue rows may use smaller radius than command cards but must remain within global token set.

## Typography
Single global family (Geist preferred). Numeric due dates, counts and values use tabular numerals where available. Priority labels are not oversized.

## Motion
- row hover/focus: 120ms
- inspector open/selection transition: 180-220ms
- filter/lens transition: <=220ms
- workspace route transition: 300ms maximum
- no bounce/spring motion for business-state changes
- obey reduced-motion preference

## Selection
Selection uses subtle sapphire border/background treatment, not bright glow.

## Completion
Completion feedback should be restrained: check/state change and brief fade. Do not use confetti or gamification.

## Waiting/blocked
Use icon + text + semantic border/accent. Never rely on colour alone.

## Authority
Director/authority-required items may use a thin gold accent and explicit text label. Gold must not become a generic premium decoration.

## Tables/queues
Lines are low-contrast. Important data is carried by type scale, alignment and spacing before colour.

## Responsive
At desktop, preserve three-zone rail / queue / inspector where width permits. Tablet collapses inspector into drawer. Mobile is single-column with sticky lens and filter controls.
