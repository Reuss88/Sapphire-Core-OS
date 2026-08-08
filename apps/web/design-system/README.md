# Sapphire live design system

This directory is the runtime source of truth for Sapphire Core OS presentation. It follows the structural discipline of Severovsky while taking its visual language from the approved Actions workspace.

## Ownership

- `tokens.css` owns every visual value and semantic recipe.
- `tokens.ts` exposes typed token references where React composition needs them.
- `primitives.tsx` owns buttons, cards, fields, badges, avatars and provenance.
- `form-controls.tsx` owns choice, switch, segmented and native date/time controls.
- `calendar.tsx` owns the keyboard calendar and compact agenda.
- `overlays.tsx` owns dialogs, drawers, popovers, tooltips, toasts and command-palette framing.
- `tab-collection.tsx` owns the Director-approved enclosed segmented tab/link pattern.
- `shell.tsx` owns the workspace rail, navigation panel, command header, global search, identity, footer and mobile navigation behaviour.
- `components.css` owns component internals. Workspaces may compose these components but must not copy or override their internal visual contracts.

The live review surface is `/design-system`. It renders production components from deterministic state rather than parallel mock markup.

## Safe patch rule

Change a shared visual or interaction rule here when the intended result should propagate through the OS. Do not patch Actions or HOME separately for a covered family. Page CSS is limited to workspace-specific geometry and data composition.

Raw colour values are permitted only in `tokens.css`. Run `pnpm lint:tokens` before committing a system change.

## Material contract

Cards use one shared bezel. Premium surfaces can select `chrome="forward"` or `chrome="reverse"` for restrained polished highlights on opposite corners. `headerGradient` and semantic card variants select low-contrast focus material without encoding commercial status decoratively.

## Accessibility contract

- shared controls expose visible focus;
- dialogs trap focus, close with Escape and can restore a supplied trigger reference;
- tab collections support Left, Right, Home and End;
- calendars support Left, Right, Up, Down, Home and End;
- mobile controls use the 44px touch target token;
- reduced motion collapses component transitions through canonical motion tokens;
- authority, freshness, evidence and system state remain explicit text, never colour alone.
