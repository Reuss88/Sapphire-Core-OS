# CODEX MISSION — Live Sapphire Design System v1

## Mission ID

`SAPPHIRE-DESIGN-SYSTEM-001`

## Status

Director-approved for implementation.

## Objective

Create the coded, live source of truth for Sapphire Core OS visual foundations and shared components, then migrate Actions onto it without changing the approved Actions hierarchy or commercial behaviour.

## Authority

Sapphire doctrine and the approved Actions execution canvas are authoritative. Severovsky is a structural foundation for disciplined organisation and component coverage, not permission to import a generic visual skin. The Director's 8 August 2026 chrome-corner, focus-gradient and live-component requirements are approved additions to the Sapphire material language.

## Read first

1. `engineering/START-HERE-CODEX.md` and its full mandatory load order;
2. `engineering/programmes/SAPPHIRE-UI-SYSTEM-UNIFICATION-v1.md`;
3. `designers-instinct/sapphire-design-system/`;
4. Actions doctrine, architecture, mission contracts and current implementation;
5. the approved Actions desktop/tablet/mobile screenshots;
6. the public Severovsky reference identified during pre-flight.

## Pre-flight

Inventory every raw colour, gradient, radius, shadow, spacing value and repeated UI structure in Actions. Map existing components and CSS to a proposed system primitive or workspace-owned composition. Confirm current routes, tests, fixtures, identity, authority and Activity boundaries before editing.

## Live architecture

Create a shared system inside the routed web application, organised as:

- foundations: CSS custom properties and typed token exports;
- primitives: accessible low-level interactive elements;
- components: Sapphire-owned semantic variants;
- patterns: shell, command surface, queue, form, calendar and state compositions;
- catalogue: a deterministic Director/developer review route rendering every supported variant and state.

The runtime CSS token layer is canonical. Components consume only semantic variables. Page components import the shared React implementation and may not duplicate its internal styling.

## Required token families

- colour, including canvas, surface, text, border, action, status, AI, focus and chrome;
- typography and tabular numerals;
- spacing and density;
- radii and bezel geometry;
- borders, elevation and opposing-corner chrome highlights;
- motion and reduced-motion fallbacks;
- z-index and overlay layers;
- breakpoints, safe areas and touch targets;
- focus-area and header-gradient recipes.

## Required live component families

### Shell and navigation

- `SapphireShell`
- `WorkspaceRail` and overlay `NavigationPanel`
- `CommandHeader`
- `GlobalSearch`
- `DirectorIdentity`
- `WorkspaceFooter`
- mobile navigation sheet

### Navigation and commands

- `TabCollection` / lens tabs
- compact filter tabs and status tabs
- `Button`, `IconButton`, `ButtonGroup`
- command strip and overflow menu
- link and drill-down treatments

### Cards and card types

One `Card` frame owns bezel, surface, header, focus and state styling. Required semantic variants:

- standard surface;
- command/focus;
- Director briefing / AI intelligence;
- commercial metric and financial position;
- attention, warning, critical and approval;
- opportunity / positive movement;
- summary / compact operational;
- evidence and provenance;
- timeline / Work Journal;
- table, queue and list container;
- map, chart and visualisation frame;
- form and settings surface;
- calendar / schedule surface.

All card variants support title, eyebrow, actions, status, freshness, ownership, body and footer slots as appropriate. Decorative variants may not change commercial semantics.

### Chrome bezel and focus material

- Default premium cards receive a subtle polished-chrome highlight in opposing corners, implemented by the shared frame rather than page pseudo-elements.
- The highlight must read as a restrained metal edge, not neon, glass or a full luminous border.
- Orientation may be top-left/bottom-right or top-right/bottom-left through a documented variant.
- Header/focus gradients remain low contrast, sit behind content, preserve text contrast and never imply status by themselves.
- Critical, warning, success and AI meaning continues to use semantic state tokens and labels.

### Forms and calendar

- field wrapper, label, hint, error and authority note;
- text input, search input, textarea, select, checkbox, radio, switch and segmented control;
- date, time and date-time field;
- accessible calendar month grid, date picker and compact agenda/list pattern;
- required, optional, disabled, read-only, pending, success and error states;
- form section, action row and irreversible-action confirmation pattern.

Calendar controls must support keyboard movement, locale-ready labels, explicit timezone context and 44px mobile targets. They must not silently mutate governed records.

### Overlays, feedback and states

- dialog, drawer, sheet, popover, tooltip and command palette frame;
- toast/notification;
- skeleton, empty, stale, partial, offline, error and unauthorised states;
- status badge/chip, avatar and provenance marker.

## Catalogue contract

Provide a `/design-system` catalogue or equivalent repository-native live surface that renders every component family, variant, interactive state and responsive mode from deterministic fixtures. It must be part of tests and may be excluded from production navigation.

## Actions migration

- Replace page-local shell, button, tab, card, form, overlay and state styling with shared components.
- Preserve approved queue → central Action Context → Work Journal geometry.
- Preserve all current labels, authority boundaries, Activity distinctions and fixture/RPC disclosures.
- Visual deltas must be limited to approved system refinements: consistent chrome corners, restrained gradients, token alignment and accessibility corrections.

## Do not

- Do not create a second design-system package or alternate theme inside a page.
- Do not import a generic library skin.
- Do not change Actions product hierarchy or backend contracts.
- Do not encode commercial state in decorative chrome or gradients.
- Do not edit or delete the unrelated untracked HOME prototype.

## Acceptance criteria

1. Tokens exist once and are consumed by shared components.
2. No unapproved raw colour values remain in migrated Actions component styling.
3. Required component families and card variants render in the catalogue.
4. Chrome opposing-corner and focus-gradient treatments are shared, subtle and accessible.
5. Calendar and form controls pass keyboard and mobile interaction checks.
6. Actions visual regression preserves its approved hierarchy at 1600×1000, 900×900 and 390×844.
7. Existing Actions and Activity contract tests pass.
8. Token/component lint, typecheck, lint, tests and production build pass.
9. Director Review Package is produced and the mission commit is pushed.

## Definition of done

PASS only when the live design system and catalogue exist, Actions consumes them, regression evidence passes, and no parallel page-local visual system remains for the migrated component families.

## Mission Result

Use `engineering/WORKFLOW.md`.
