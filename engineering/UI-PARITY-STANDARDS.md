# UI and Parity Standards

## Governing rule

Designers Instinct and Director-approved references define product experience. Engineering implements them faithfully.

## Visual authority

When a Director-approved parity reference exists:

- treat it as immutable visual authority;
- do not reorder widgets;
- do not change hierarchy;
- do not reinterpret colour balance;
- do not substitute generic SaaS patterns;
- improve accessibility and responsiveness without changing approved desktop character.

## Sapphire Design System

Use `designers-instinct/sapphire-design-system/` for:

- colour tokens;
- typography;
- spacing;
- radii;
- motion;
- component standards;
- commercial semantics.

No component may invent ad hoc visual tokens when an approved token exists.

## Parity workflow

1. Identify canonical reference.
2. Measure/derive layout proportions.
3. Build structural parity first.
4. Apply token parity.
5. Add interaction states.
6. Run visual comparison at reference viewport.
7. Fix implementation, not the approved design.
8. Submit for Director review.

## Accessibility

Parity never excuses inaccessible implementation. Preserve keyboard navigation, focus visibility, semantic HTML, contrast, reduced-motion support and meaningful text equivalents for charts/maps/status.

## Responsive behaviour

Desktop reference remains primary for Director workspaces. Responsive variants may reorganize layout only as necessary for smaller screens and must preserve commercial priority and meaning.
