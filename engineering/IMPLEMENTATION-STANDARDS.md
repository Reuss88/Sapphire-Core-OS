# Implementation Standards

## Core rule

Code implements Sapphire doctrine. Code does not redefine Sapphire doctrine.

## General standards

- Prefer extension over replacement.
- Reuse existing primitives, types and services before creating new ones.
- Keep business rules in canonical backend/domain layers rather than UI-only logic.
- Maintain one source of truth for identity, authority, communications, audit and workflow state.
- Use explicit types for cross-layer contracts.
- Keep fixtures deterministic and centralized.
- Avoid speculative abstractions that are not required by doctrine.
- Every irreversible or authority-sensitive action requires explicit permission and auditable intent.

## Next.js standards

- Use the existing App Router structure.
- Prefer React Server Components for read-heavy surfaces.
- Use Client Components only where browser interaction requires them.
- Keep page files thin; move domain UI into reusable components.
- Centralize data contracts in typed modules.
- Provide `loading.tsx` and `error.tsx` for primary workspaces where appropriate.
- Never expose Supabase service-role credentials to the browser.

## TypeScript standards

- Strict mode.
- No untyped `any` for domain data.
- Use discriminated unions for stateful domain objects where useful.
- Prefer shared domain contracts over duplicated interface definitions.
- Validate untrusted external payloads at boundaries.

## Change discipline

A mission should make the smallest coherent set of changes necessary. Large unrelated refactors require a separate mission.
