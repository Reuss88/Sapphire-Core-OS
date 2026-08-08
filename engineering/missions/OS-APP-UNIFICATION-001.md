# CODEX MISSION — Sapphire OS Application Unification v1

## Mission ID

`OS-APP-UNIFICATION-001`

## Status

Director-approved; begins only after the design-system and HOME missions pass.

## Objective

Deliver HOME and Actions as connected workspaces in one Next.js App Router application, one shared shell, one origin and one local production runtime.

## Authority

Existing runtime, identity, authority, Activity and workspace doctrine remain authoritative. This mission consolidates presentation and routing only; it does not merge systems of record.

## Routing contract

- `/` redirects to `/dashboard`.
- `/dashboard` renders canonical HOME.
- `/home` redirects to `/dashboard`.
- `/actions` renders canonical Actions.
- shared navigation marks the current route and uses App Router links.
- unavailable future workspaces render an explicit governed placeholder or remain disabled; they must not silently redirect to unrelated surfaces.

## Shared application contract

- one `apps/web` application and dependency graph;
- one root layout and metadata strategy;
- one shared `SapphireShell` and navigation configuration;
- one design-system token/runtime import;
- route-specific Server/Client Component boundaries;
- route-level loading and error states;
- same-origin navigation with no separate localhost ports or full-page application handoffs;
- preserved PWA manifest and future Capacitor compatibility.

## Pre-flight

Inspect existing local servers, worktrees, generated HOME output, package manifests, App Router routes, Supabase adapters, auth/session boundaries and PWA configuration. Do not delete or overwrite untracked output. Identify every navigation link and classify it as implemented, placeholder or unavailable.

## Do not

- Do not run HOME as a second application.
- Do not copy the shell into route components.
- Do not create route-specific token files that fork global meaning.
- Do not fake implemented workspaces with broken links.
- Do not alter database, authority or identity contracts merely to join navigation.

## Acceptance criteria

1. One install and one production server serves both `/dashboard` and `/actions`.
2. HOME → Actions and Actions → HOME work through visible shared navigation without reload to another origin.
3. Active navigation, keyboard focus, mobile drawer and back navigation are correct on both routes.
4. `/`, `/home`, `/dashboard` and `/actions` follow the routing contract.
5. Shared shell/component code is not duplicated by either route.
6. Direct-load, refresh, loading and error behaviour works for both routes.
7. PWA manifest and production build remain valid.
8. Full test, accessibility, responsive and browser navigation suite passes.
9. A single localhost URL and Director Review Package are delivered.
10. Mission commit is pushed and remote SHA verified.

## Definition of done

PASS only when the Director can use one local production URL to move between HOME and Actions as one coherent Sapphire Core OS application.

## Mission Result

Use `engineering/WORKFLOW.md`.
