# Actions Workspace

This directory is the implementation-grade product contract for the Sapphire Core OS **Actions** workspace.

Actions is Sapphire's execution engine. It turns commercial intent into accountable missions and action items while preserving authority, source-record ownership and auditability.

## Governing doctrine
Read first: `../../doctrine/actions-missions-doctrine.md`.

## Files
- `page-doctrine.md` — product purpose, hierarchy and Director/user experience.
- `information-architecture.md` — canonical lenses and screen structure.
- `interaction-contract.md` — allowed commands and state transitions.
- `data-contract.md` — read/mutation contracts and snapshot shapes.
- `supabase-architecture.md` — required tables, SQL functions, RLS, RPC, trigger and realtime architecture.
- `design-tokens.md` — Actions-specific semantic use of the Sapphire Design System.
- `codex-mission-actions-v1.md` — self-contained implementation mission for Codex.

## Cross-system architecture
The backend ownership and execution model is also recorded at `../../../architecture/actions-execution/MASTER-ACTIONS-ARCHITECTURE-v1.md` so the architecture is not dependent on page-design documentation alone.

## Authority rule
Actions never becomes a parallel approval engine. Governance owns authority and approval truth; Actions owns the executable work that may reference those records.

## Build sequence
1. Inspect existing repo/schema and reconcile with this contract.
2. Implement typed UI fixtures and Actions shell.
3. Implement/extend Supabase migrations using existing project primitives.
4. Wire RPCs and realtime invalidation.
5. Validate RLS and authority boundaries.
6. Director review of Actions soft build.
7. Promote approved visual parity specification before final parity lock.
