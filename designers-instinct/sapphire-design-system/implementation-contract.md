# Next.js 16 Implementation Contract

## Target
Sapphire Core OS is implemented as a Next.js 16 App Router PWA with a future Capacitor wrapper. The design system must compile into code-level tokens and components, not remain descriptive documentation.

## Token architecture
Use CSS custom properties as the canonical runtime layer, with typed TypeScript token exports where required. Tailwind v4 utilities and component variants must consume semantic tokens rather than hard-coded values.

Required namespaces:
- `--sapphire-color-*`
- `--sapphire-space-*`
- `--sapphire-radius-*`
- `--sapphire-shadow-*`
- `--sapphire-motion-*`
- `--sapphire-font-*`
- `--sapphire-z-*`

## Component architecture
Build accessible primitives, then Sapphire variants. shadcn/ui or Radix primitives may support behaviour but must be visually and semantically transformed into Sapphire components. Do not ship an obvious default component library skin.

## Rendering
Prefer Server Components for stable read surfaces and Client Components only for interaction, realtime and local state. Avoid moving business logic into presentation components.

## Performance
- route-level loading and error boundaries
- streaming and Suspense where it improves perceived control
- local skeletons matching final geometry
- no full-screen spinner for routine navigation
- minimise client JavaScript
- virtualise large queues and tables
- respect Core Web Vitals

## PWA and Capacitor
Define installability, offline shell, stale-data labels, safe-area tokens, touch behaviour and native back handling. Offline mode must never imply that stale commercial data is current or that a mutation has completed.

## Quality gates
- token linting and no unapproved hard-coded colour values
- Storybook or equivalent component catalogue
- visual regression coverage
- keyboard and screen-reader testing
- reduced-motion testing
- responsive review across desktop, tablet, mobile PWA and Capacitor-safe viewport
- Director approval before patterns become locked

## Codex rule
Codex must read this directory, cross-product doctrine and the relevant page contract before implementation. It may not invent commercial semantics, permissions, data definitions or visual tokens.
