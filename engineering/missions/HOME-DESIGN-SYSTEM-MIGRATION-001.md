# CODEX MISSION — HOME Design-System Migration v1

## Mission ID

`HOME-DESIGN-SYSTEM-MIGRATION-001`

## Status

Director-approved; begins only after `SAPPHIRE-DESIGN-SYSTEM-001` passes.

## Objective

Implement the locked HOME command deck inside the routed web app using only the live Sapphire design system, matching the approved Actions quality, material discipline and interaction language without changing HOME's approved commercial hierarchy.

## Authority and approved evolution

`designers-instinct/sapphire-design-system/actions-visual-direction-v1.md` is the visual authority. The HOME reference remains a guide to commercial content, executive questions and broad composition, but is subordinate wherever it conflicts with Actions. HOME must use Actions-derived overlay navigation, density, controls, typography, chrome-corner bezels and restrained header/focus gradients. Page-specific composition may adapt where required to achieve one coherent OS, provided HOME's commercial questions remain answered.

## Read first

Read the Engineering Framework, the programme plan, all HOME doctrine and parity files, the full design-system contract and the completed `SAPPHIRE-DESIGN-SYSTEM-001` Mission Result.

## Required result

- Canonical route `/dashboard`.
- Same `SapphireShell`, navigation, command/header, card, button, tab, form, state and overlay components as Actions.
- Approved HOME grid and order: utility context, Director Briefing, Commercial Position, Market Radar, Commercial Movement, four compact operational cards and Workspace Pulse.
- Chrome bezel and subtle focus-gradient variants selected through component props/tokens, never copied CSS.
- Typed deterministic fixtures that preserve HOME ownership, freshness, evidence, permission and drill-down contracts.
- Desktop no-scroll review at the canonical 1672×940 reference viewport, plus 1920×1080 and 1600×900 checks.
- Tablet and mobile reprioritisation that preserves Director Attention and commercial meaning.

## Component mapping

- Director Briefing → intelligence/focus card;
- Commercial Position → financial position card plus metric primitives;
- Market Radar → visualisation frame plus signal list;
- Commercial Movement → compact data rows/sparklines;
- Director Attention → attention/critical summary card;
- Actions and Inbox → compact operational summary cards;
- Hot Right Now → opportunity/signal card;
- Workspace Pulse → tab/status collection strip.

## Do not

- Do not use output-only files under the untracked `apps/home-prototype/` as authoritative source code.
- Do not introduce HOME-local button, tab, form, nav or card implementations.
- Do not duplicate Actions state or Inbox records.
- Do not change the locked widget order.
- Do not use chrome or gradient intensity that competes with Director Attention or verified commercial meaning.

## Acceptance criteria

1. HOME uses the shared design system for every covered component family.
2. HOME and Actions visibly belong to the same OS.
3. HOME answers every doctrine-required commercial question while its shell, material, density and components match Actions.
4. Reference viewport has no page-level vertical scroll.
5. All actions link to a meaningful same-app route or disclose typed-fixture limitations.
6. Loading, empty, stale, partial, offline, error and unauthorised states are demonstrable.
7. Keyboard, screen-reader, reduced-motion and responsive checks pass.
8. Typecheck, lint, tests, production build and screenshot comparison pass.
9. Director Review Package is produced and the mission commit is pushed.

## Definition of done

PASS only after visual parity and doctrine compliance are verified and HOME is reviewable inside the same web application codebase as Actions.

## Mission Result

Use `engineering/WORKFLOW.md`.
