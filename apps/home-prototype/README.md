# Sapphire HOME prototype

Director-reviewable HOME parity prototype for Sapphire Core OS.

## Purpose

This surface demonstrates the approved desktop command deck with deterministic typed fixtures. It intentionally defers production authentication, Supabase integration, permissions and workspace implementations.

The code uses App Router-style route and component boundaries so the prototype can migrate into the approved Next.js 16 application without rewriting its visual or fixture contracts.

## Local use

```bash
pnpm install
pnpm run dev
```

Open `/dashboard` for the canonical route. `/` renders the same prototype for convenient local review.

## Validation

```bash
pnpm exec tsc --noEmit
pnpm run lint
pnpm run build
pnpm test
```

## Boundaries

- Fixture values are deterministic and isolated in `app/home-fixtures.ts`.
- Commercial and UI types live in `app/home-types.ts`.
- Visible actions open controlled prototype notices; they do not imply authority.
- CSS custom properties provide the portable Sapphire token layer.
- Backend and PWA work begins only after Director approval of the parity surface.
