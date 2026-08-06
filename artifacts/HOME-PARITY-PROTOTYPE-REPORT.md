# HOME parity prototype report

## Delivery state

Director-reviewable local prototype. This is not the final backend-integrated HOME implementation and does not claim pixel-perfect completion.

## Source

- Base branch: `main`
- Base commit: `9d671434ccfa6959af7523e2beb22d4e0cf80858`
- Canonical local reference used for visual review: `/Users/reuss/Downloads/Generated image 2.png`
- Repository reference issue: `home-approved-v1.webp` decodes with severe corruption and is 1000 × 562 rather than the documented 1672 × 940.

## Prototype surface

- Application: `apps/home-prototype`
- Routes: `/` and `/dashboard`
- Runtime: Vite-powered React Server Component prototype using Next-compatible App Router conventions
- Migration posture: page, component, token and fixture boundaries are compatible with a later Next.js 16 App Router implementation

## Implemented

- permanent desktop navigation rail and utility bar;
- Director Briefing and Commercial Position;
- Market Radar and Commercial Movement;
- Director Attention, Actions Summary, Inbox Summary and Hot Right Now;
- Workspace Pulse;
- deterministic typed brokerage fixtures;
- programmatic globe, map and sparklines;
- controlled placeholder destinations for all visible navigation and actions;
- semantic landmarks, keyboard focus treatment and reduced-motion support;
- no ordinary page scrolling at the 1920 × 1080 logical review viewport.

## Validation

- production build: passed;
- application TypeScript check: passed;
- lint: passed;
- server-render tests: 2 passed;
- browser console warnings/errors: none;
- Review Opportunity controlled route: passed;
- viewport geometry: 1920 × 1080 logical viewport, 1920px document width, 1080px document height, Workspace Pulse bottom at 1068px.

## Screenshot

- Browser viewport capture: `artifacts/home-parity-prototype-review-1703x1080.jpg`

The in-app browser captured JPEG output at a physical viewport of 1703 × 1080 while reporting and rendering a 1920 × 1080 logical CSS viewport. Geometry was therefore also verified from DOM bounds rather than inferred only from bitmap dimensions. This capture is prototype review evidence, not a canonical parity-comparison screenshot.

## Known prototype deviations

- globe and world map are lightweight programmatic representations rather than final geographic assets;
- symbolic glyphs stand in for the final approved icon family and Director portrait;
- workspace routes expose controlled prototype notices rather than implemented destination workspaces;
- fixtures are isolated from Supabase and do not imply production authority or permissions;
- final visual-regression approval remains pending a clean repository reference asset.

## Deferred intentionally

- Supabase schema, RPCs, RLS, realtime and audit integration;
- authentication and server-authorised capability resolution;
- final workspace routes;
- PWA offline behaviour and Capacitor adaptations;
- Director Approval Lock for the completed production surface.
