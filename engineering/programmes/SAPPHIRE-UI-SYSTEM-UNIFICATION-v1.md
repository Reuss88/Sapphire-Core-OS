# Sapphire UI System and Runtime Unification Programme v1

## Status

Director-approved programme plan.

## Goal

Remove visual drift and disconnected runtimes by establishing one live Sapphire design system, migrating Actions and HOME to it, and serving both workspaces from one routed Sapphire Core OS application.

## Director direction incorporated

- Actions is the current quality baseline for density, restraint and execution-first layout.
- Actions is the governing design-system extraction source. HOME retains its commercial purpose and required information, but older HOME visual instructions are subordinate wherever they conflict with Actions.
- The Severovsky design-system/style-guide approach is the organisational foundation: systematic foundations, reusable variants, documented components and controlled composition rather than page-specific styling.
- Sapphire doctrine remains the visual and semantic authority. External reference material cannot override Quiet Power, commercial meaning, accessibility or authority boundaries.
- The system must include live cards, card types, navigation, tab collections, buttons, headers, fields, forms, calendar/date controls, overlays and shared states.
- Card bezels use a restrained polished-chrome highlight in opposing corners.
- Headers and focus areas may use subtle low-contrast gradients.
- Pages consume the live components directly. A safe design-system change must propagate through the OS without copying patches into each page.

## Mission order

1. `SAPPHIRE-DESIGN-SYSTEM-001` — coded foundations, components, catalogue and migration of Actions.
2. `HOME-DESIGN-SYSTEM-MIGRATION-001` — HOME implementation using the shared system and the locked HOME reference.
3. `OS-APP-UNIFICATION-001` — one Next.js runtime, shared shell and connected navigation.

The order is binding. HOME may not establish a competing component language, and runtime unification may not copy either page into a second application.

## Design-system ownership model

The design system owns:

- primitive and semantic tokens;
- typography, spacing, radii, borders, elevation, motion, z-index and responsive values;
- chrome-corner bezel and focus-gradient recipes;
- component structure, variants, interaction states and accessibility contracts;
- page-shell geometry and navigation behaviour;
- shared loading, empty, stale, partial, offline, error and unauthorised states;
- the component catalogue and visual regression fixtures.

Pages own:

- doctrine-defined content hierarchy;
- commercial data and typed fixtures;
- workspace-specific composition;
- authorised actions, routes and data contracts.

Pages may supply semantic variants and layout composition. They may not restyle shared component internals or introduce raw visual values when a system token or variant exists.

## Acceptance matrix

| Outcome | Proof |
| --- | --- |
| One visual source of truth | versioned CSS tokens plus typed token exports and shared React components |
| Safe global patches | Actions and HOME import the same primitives; no duplicated shell/card/button/tab/form CSS |
| Actions remains approved | desktop/tablet/mobile visual regression against the execution-canvas baseline |
| HOME follows Sapphire direction | common Actions-derived shell, density, typography, material, components and interactions while HOME's commercial questions remain intact |
| One OS | one install, one server, one origin, `/dashboard` and `/actions` routes, working navigation |
| Full component control | catalogue covers foundations, variants, states, forms, calendar, cards, navigation and overlays |
| Doctrine compliance | commercial semantics, authority and provenance remain visible and unchanged |
| Quality | typecheck, lint, tests, build, accessibility, keyboard, reduced-motion and viewport checks pass |

## Routing decision

- `/dashboard` remains canonical HOME because it is locked by HOME doctrine.
- `/home` redirects to `/dashboard` for readable navigation compatibility.
- `/` redirects to `/dashboard`.
- `/actions` remains canonical Actions.
- All shell links use same-origin App Router navigation.

## Reversibility

Each mission is committed separately. The design-system foundation, page migrations and route unification must be independently revertible. Existing untracked HOME prototype output is evidence only and must not be deleted or adopted as source without a separate, explicit repository decision.
