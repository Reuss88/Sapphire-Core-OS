# CODEX MISSION — Actions Execution Canvas v1

## Mission ID

`ACTIONS-EXECUTION-CANVAS-001`

## Status

Director-approved for implementation.

## Repository and baseline

- Repository: `Reuss88/Sapphire-Core-OS`
- Required baseline: `d2a13ca862af27ce9471bfcc4b2f3bdde37625bc`
- Baseline capability: completed Actions workspace plus shared Activity Work Journal.
- Mission branch: `agent/actions-execution-canvas-001`

This mission is intentionally isolated from the Actions and Activity foundation commits so it can be reviewed, reverted or superseded without removing their domain, RPC, RLS or collaboration contracts.

## Objective

Turn Actions from a conventional dashboard arrangement into a denser, calmer, execution-first operating surface. Reclaim permanent screen estate, make selected Action Context the central working canvas and retain the ranked queue and shared Work Journal as supporting execution surfaces.

## Authority

The Director approved the product direction in conversation on 8 August 2026. This mission formalises that approval as the implementation contract. Existing Actions, Activity, Identity, Governance, audit and source-workspace boundaries remain authoritative.

## Read first

1. `engineering/START-HERE-CODEX.md`
2. all files required by its mandatory load order;
3. `designers-instinct/pages/actions/`;
4. `designers-instinct/doctrine/actions-missions-doctrine.md`;
5. `architecture/actions-execution/MASTER-ACTIONS-ARCHITECTURE-v1.md`;
6. `architecture/activity/MASTER-ACTIVITY-ARCHITECTURE-v1.md`;
7. `designers-instinct/sapphire-design-system/`;
8. the current Actions and Work Journal implementation and tests.

## Pre-flight

Before implementation, inspect and record:

- current branch, baseline commit and unrelated worktree changes;
- Actions route, component hierarchy, fixtures and shared contracts;
- current navigation, header, briefing, queue, context and Work Journal behaviour;
- desktop, tablet and mobile breakpoints;
- focus, keyboard, reduced-motion and touch behaviour;
- existing browser persistence conventions;
- current production build and test commands.

## Locked product decisions

### 1. Overlay workspace navigation

- Desktop navigation is collapsed by default to a thin left rail.
- Pointer approach/hover and keyboard focus reveal the full navigation.
- Expanded navigation overlays the workspace and never pushes page content sideways.
- Leaving the navigation retracts it after a short, calm delay.
- A pin control may keep it open for the current browser session.
- Touch layouts use an explicit menu control; they do not depend on hover.
- Navigation remains keyboard accessible and respects reduced motion.

### 2. Compact Actions command bar

- Replace the oversized heading region with a 56–64px command bar on desktop.
- Keep `Actions` and a muted execution-workspace label on the left.
- Keep compact `+ Action` and `+ Mission` commands on the right.
- Preserve Director identity without ceremonial spacing.

### 3. Dismissible Execution Brief

- Render new briefing information as a compact strip, not a permanent hero.
- Expose `Open full brief` and `Dismiss` commands.
- Dismissal persists locally against the brief identifier.
- A materially new brief uses a new identifier and appears again.
- Full brief access remains available from the page during this fixture-backed phase.

### 4. Reduced creation footprint

- Action and Mission creation remain immediately visible.
- Controls use compact command-bar treatment.
- Existing structured preview and authoritative-RPC boundary remain unchanged.

## Main execution canvas

After the four space-recovery changes, use the reclaimed width for this priority order:

1. ranked Actions/lens queue — selection and prioritisation;
2. central Action Context — objective, commercial consequence, ownership, due state, governed links, completion conditions and next commands;
3. Work Journal or Mission context — collaborative Activity, authoritative execution events and evidence.

Action Context is the primary canvas. It must not remain a narrow supporting inspector. The Work Journal remains a shared Activity consumer and must retain the distinction between contextual Activity, Actions execution state and evidence.

Mission selection may adapt the central canvas for mission objective, progress, conditions and journal context without creating another execution system.

## Responsive contract

- Desktop primary viewport: `1600 × 1000`.
- Tablet review viewport: `900 × 900`.
- Mobile review viewport: `390 × 844`.
- Tablet may use an overlay/drawer for secondary context while preserving queue selection.
- Mobile uses explicit navigation and contextual sheets; it must preserve Action meaning, Activity visibility and reachable collaboration controls.
- No document-level horizontal scrolling.

## State and persistence

- Sidebar pinned state may persist for the current browser session only.
- Brief dismissal persists in local storage using a versioned key containing the brief identifier.
- Persistence is presentation state only and must not claim backend execution truth.
- Fixture commands must continue to disclose that an authoritative RPC is required.

## Do not

- Do not alter Actions, Activity, Identity, Governance or audit database contracts.
- Do not create an Actions-private notes, comments or call-log implementation.
- Do not make visibility imply authority.
- Do not duplicate Inbox, Documents or governed records.
- Do not remove canonical lenses, ranking explanations, completion conditions or Work Journal distinctions.
- Do not convert the page into equal-weight dashboard cards.
- Do not stage or modify unrelated Home prototype work.

## Expected files

Likely modifications:

- `apps/web/components/actions/actions-workspace.tsx`
- `apps/web/components/actions/work-journal.tsx` only if composition requires it
- `apps/web/app/globals.css`
- `apps/web/components/actions/actions-fixture.ts` only for a stable brief identifier
- `apps/web/tests/actions-contract.test.mjs`

Expected additions:

- a mission-specific UI contract validator if the existing validator cannot express the locked behaviour;
- responsive Director review screenshots;
- an implementation report.

## Acceptance criteria

1. Desktop navigation is collapsed by default, expands over content on pointer/focus and does not change the workspace's measured horizontal position.
2. Navigation has an explicit pin control and keyboard-accessible expansion.
3. Touch navigation opens through an explicit control and can be dismissed.
4. Desktop command bar is no taller than 64px.
5. Create Action and Create Mission remain visible and functional as structured previews.
6. Execution Brief can open its full content, dismiss, remain dismissed after reload and reappear for a new brief identifier.
7. Selected Action Context is the widest primary working region at the desktop viewport.
8. Ranked queue and Work Journal remain concurrently usable on desktop.
9. Closer and research Activity scenarios remain visible and distinct from execution/evidence entries.
10. Tablet and mobile preserve commercial priority and accessible collaboration controls.
11. Keyboard focus is visible; reduced motion disables reveal animation.
12. Typecheck, lint, tests and production build pass.
13. Browser review reports no console errors and provides desktop, tablet and mobile screenshots.

## Backout strategy

Revert only the implementation commit(s) produced after this mission contract. The baseline `d2a13ca` must remain intact. This restores the prior Actions layout while preserving Actions/Activity backend and collaboration capability. Brief dismissal storage is presentation-only and safe to abandon.

## Definition of done

PASS only when every acceptance criterion is verified, the Director Review Package is delivered, the mission branch is pushed, and the remote SHA matches the reported commit.

## Mission Result

Use the standard format in `engineering/WORKFLOW.md`. Include the mission document, baseline, implementation commits, screenshots, localhost URL and exact deferred items.
