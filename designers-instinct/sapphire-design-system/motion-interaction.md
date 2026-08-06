# Motion and Interaction

## Motion objective
Motion communicates weight, causality and commercial state. Sapphire moves like precision machinery: controlled, quiet and deliberate.

## Duration tokens
- instant feedback: 80ms
- hover and focus: 120ms
- compact state change: 160ms
- panel reveal: 220ms
- workspace transition: 300ms
- complex orchestration maximum: 420ms

## Easing
Use restrained ease-out for entrances, ease-in for exits and standard ease-in-out for rearrangement. Avoid bounce, elastic, springy or playful motion in core commercial workflows.

## Required motion semantics
- confirmation: brief settle, never celebration
- escalation: controlled emphasis pulse, maximum two cycles
- data refresh: local crossfade or value transition; never reload the whole page
- drill-down: preserve spatial context
- modal: dim and elevate without theatrical zoom
- AI briefing: subtle upward fade; inference status remains visible
- settlement or irreversible action: deliberate confirmation sequence

## Reduced motion
When `prefers-reduced-motion` is active, replace translation and scale with opacity or immediate state changes. No information may depend on animation.

## Feedback
Every authorised action must expose pending, success, failure and recovery states. Optimistic UI is forbidden for irreversible finance, governance, contract or approval actions unless the server contract explicitly supports safe reversal.

## Sound and haptics
Sound is optional and off by default. Future sound must be subtle, mechanical and reserved for critical confirmation or escalation. Capacitor haptics may support confirmation, warning and failure but may never replace visible feedback.
