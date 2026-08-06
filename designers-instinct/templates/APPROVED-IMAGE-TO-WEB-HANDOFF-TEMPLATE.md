# Approved Image to Web — Agent Handoff Template

## How to use this template

This is the mandatory handoff format for every Director-approved Sapphire Core OS image.

The handoff author must:

1. read `designers-instinct/constitutional/CS-UI-001-APPROVED-IMAGE-TO-WEB-PARITY-CONSTITUTION.md`;
2. replace every bracketed field with verified information;
3. commit the exact approved source;
4. create and validate `manifest.json`;
5. inspect the image directly;
6. measure its layout;
7. separate facts, Director instructions, inferences and unknowns;
8. create the complete handoff package;
9. never call the handoff itself a build.

Copy the completed package to:

`designers-instinct/parity-handoffs/[surface-id]/[approval-version]/`

---

# MISSION — [SURFACE NAME] APPROVED IMAGE PARITY [VERSION]

## Constitutional authority

This mission is governed by:

`designers-instinct/constitutional/CS-UI-001-APPROVED-IMAGE-TO-WEB-PARITY-CONSTITUTION.md`

Compliance is mandatory.

## Mission state

- Surface ID: `[surface-id]`
- Approval version: `[v1]`
- Approval state: `DIRECTOR_APPROVED`
- Approved by: `[Director identity/authority]`
- Approval timestamp: `[ISO-8601]`
- Delivery stage: `[visual_prototype | product_implementation]`

## Canonical visual authority

- Repository path: `[reference/approved-source.png]`
- Actual media type: `[image/png | image/jpeg | image/webp]`
- Width: `[px]`
- Height: `[px]`
- Aspect ratio: `[decimal]`
- SHA-256: `[64 lowercase hexadecimal characters]`
- Colour profile: `[value | null]`
- Orientation: `[1–8 | null]`
- Alpha: `[true | false | null]`
- Decoders used: `[decoder A, decoder B]`
- Visual inspection result: `[PASS]`

The implementer must open this exact repository file. The implementer must not use a conversation attachment, thumbnail, generated substitute or earlier design.

## Source-integrity declaration

State exactly how the committed bytes were compared with the approved source:

`[method and result]`

List any conversion:

`[none | original path, derivative path, method, both hashes and verification result]`

If this section is incomplete, implementation must stop at the integrity gate.

## Governing doctrine

Read completely before implementation:

- `[path]`
- `[path]`
- `[path]`

Visual composition comes from the approved image. Commercial meaning, ownership, permissions and authority come from these files.

## Canonical capture contract

- Viewport: `[width] × [height] CSS pixels`
- Browser zoom: `[100%]`
- Device pixel ratio: `[1]`
- Page scrolling: `[none | vertical | horizontal | both]`
- Motion state: `[settled | reduced motion]`
- Theme: `[dark/light]`
- Locale: `[locale]`
- Timezone: `[timezone]`
- Font-loading condition: `[all required fonts loaded]`

## Delivery and migration contract

- Target stack for this stage: `[e.g. Vite + React + strict TypeScript]`
- Production migration target: `[e.g. Next.js 16 App Router]`
- Required portable boundaries:
  - typed fixture/data contract;
  - framework-neutral presentational components where practical;
  - semantic CSS custom properties;
  - route/action adapter;
  - no business calculations hidden in components;
  - no baked screenshot UI.

Do not add production infrastructure merely to demonstrate a visual prototype. Do not create a throwaway mock that must be rewritten to migrate.

## Measured canvas and shell

| Region | x | y | width | height | Tolerance | Notes |
|---|---:|---:|---:|---:|---:|---|
| Canvas | `[0]` | `[0]` | `[px]` | `[px]` | `0px` | `[notes]` |
| Navigation | `[px]` | `[px]` | `[px]` | `[px]` | `±2px` | `[notes]` |
| Utility/header | `[px]` | `[px]` | `[px]` | `[px]` | `±2px` | `[notes]` |
| Main content | `[px]` | `[px]` | `[px]` | `[px]` | `±2px` | `[notes]` |
| Footer/status | `[px]` | `[px]` | `[px]` | `[px]` | `±2px` | `[notes]` |

State:

- column grid: `[count and gutter]`;
- outer padding: `[top/right/bottom/left]`;
- repeated gap: `[px]`;
- major alignment lines: `[list]`;
- fixed/sticky regions: `[list]`;
- clipping/crop rules: `[list]`;
- background behaviour: `[list]`.

## Exact region hierarchy

List every region in reading and visual order. Do not collapse two visually distinct regions into one vague description.

1. `[region]`
2. `[region]`
3. `[region]`

## Region geometry

| Order | Region | Grid span | x | y | width | height | Emphasis |
|---:|---|---:|---:|---:|---:|---:|---|
| 1 | `[name]` | `[span]` | `[px]` | `[px]` | `[px]` | `[px]` | `[primary/secondary/tertiary]` |

For each dominant region, describe:

- internal columns/rows;
- padding;
- exact visible item count;
- content overflow;
- asset placement and crop;
- relationship to adjacent alignment lines.

## Typography inventory

| Role | Text example | Family | Size | Weight | Line height | Tracking | Colour | Wrap rule |
|---|---|---|---:|---:|---:|---:|---|---|
| Display | `[text]` | `[font]` | `[px]` | `[value]` | `[px]` | `[value]` | `[token]` | `[exact line breaks]` |

Required font files or approved web-font source:

- `[path/source]`

Fallback rule:

`[rule]`

A fallback may support an early prototype. Final parity cannot pass when it materially changes line wrapping or metrics.

## Colour and material inventory

All colours must map to semantic tokens.

| Meaning | Token | Sampled/reference value | Use |
|---|---|---|---|
| Canvas | `[token]` | `[value]` | `[use]` |

Record:

- border widths/contrast;
- radii;
- shadows;
- gradients;
- glow/bloom limits;
- opacity and texture;
- state colours and their text/icon companion.

## Content and deterministic fixture contract

All geometry-affecting content is fixed for parity capture.

| Region | Visible text/value | Unit/period | Evidence class | Fixture key | Production owner |
|---|---|---|---|---|---|
| `[region]` | `[text]` | `[value]` | `[verified/calculated/AI inference]` | `[key]` | `[workspace]` |

Rules:

- no random values;
- no current-clock drift during screenshot capture;
- no live network response may change canonical geometry;
- visible item counts and ordering are fixed;
- production data boundaries remain typed and separate.

## Asset inventory

| Asset | Reference location | Production source | Required fidelity | Prototype substitute allowed? | Final blocker? |
|---|---|---|---|---|---|
| Logo | `[region]` | `[repo path]` | exact | `[yes/no]` | `[yes/no]` |
| Icon family | `[regions]` | `[library/path]` | exact family/weight | `[yes/no]` | `[yes/no]` |
| Hero image/map | `[region]` | `[path/programmatic contract]` | `[rule]` | `[yes/no]` | `[yes/no]` |

Do not instruct the implementer to “use a similar SVG”. Name the exact asset, approved library or programmatic contract.

## Interaction inventory

| Visible control | Accessible name | Action | Route/result | Authority boundary | States required |
|---|---|---|---|---|---|
| `[control]` | `[name]` | `[action]` | `[route]` | `[rule]` | hover, focus, pressed, disabled |

Every visible control must work or expose an honest controlled placeholder. Silent failure is prohibited.

## Responsive boundary

This approved image governs: `[canonical desktop only | named viewport class]`.

Rules below the canonical width:

`[explicit approved behaviour or deferred statement]`

Do not squeeze the desktop composition into an unapproved mobile layout.

## Accessibility and correctness

Required:

- semantic landmarks and headings;
- keyboard-equivalent operation;
- visible focus;
- icon-only accessible names;
- status not communicated by colour alone;
- reduced-motion support;
- sufficient contrast;
- no irreversible or authority-bearing action from a prohibited summary surface;
- no console or type errors.

## Dynamic comparison rules

| Region | Rule | Reason | Pre-approved mask geometry |
|---|---|---|---|
| `[region]` | `[exact/fixed_fixture/mask]` | `[reason]` | `[none or bounds]` |

Masks must be declared before implementation comparison.

## Validation protocol

The implementer must produce:

- canonical implementation screenshot;
- equal-size 50% overlay or flicker comparison;
- visual diff heatmap where tooling permits;
- geometry and overflow metrics;
- type/lint/build/test results;
- browser console result;
- parity score and known deviations.

Required evidence paths:

- `evidence/implementation.png`
- `evidence/overlay.png`
- `evidence/diff.png`
- `evidence/metrics.json`
- `evidence/COMPLETION.md`

## Acceptance checklist

- [ ] Asset integrity gate passes.
- [ ] Canvas and shell are within tolerance.
- [ ] Exact region order is preserved.
- [ ] Major card bounds are within tolerance.
- [ ] Dominant typography wraps identically.
- [ ] Spacing is consistent and measured.
- [ ] Final approved assets replace prototype substitutes.
- [ ] Canonical no-scroll/overflow rule passes.
- [ ] All visible controls behave honestly.
- [ ] Accessibility essentials pass.
- [ ] Build and browser checks pass.
- [ ] Evidence package is complete.
- [ ] Parity score is at least 95 for Director review.
- [ ] Only the Director grants the final 1:1 Approval Lock.

## Known unknowns and decisions required

| Question | Why implementation cannot infer it | Owner | Blocking stage |
|---|---|---|---|
| `[question]` | `[reason]` | `[Director/product/etc.]` | `[stage]` |

If none, state `None` explicitly.

## Required implementer completion response

Report:

- branch and commit;
- route and runtime;
- files changed;
- validation results;
- evidence paths;
- 100-point category score;
- deviations;
- deferred dependencies;
- integrity verification result;
- Director Approval Lock status.

---

## Copy-ready instruction for ChatGPT or another handoff author

Use this exact instruction when commissioning a new handoff:

> Create a complete Sapphire Approved Image to Web parity handoff for the attached Director-approved design. Follow `CS-UI-001 — Approved Image to Web Parity Constitution` without weakening it. Do not design or implement the page. Commit the exact original image bytes to the canonical handoff package, regardless of whether the source is PNG, JPEG or WebP. Detect and record the real media type, dimensions, aspect ratio and SHA-256; decode and visually inspect the committed raw file; reject thumbnails, corruption and silent conversions. Measure the canvas, shell, major bounding boxes, grid, gaps, typography, assets, content and interactions. Create the required `MISSION.md`, `APPROVAL.md`, `HANDOFF.md`, `ACCEPTANCE.md`, `manifest.json`, annotations, fixture contract and evidence README under `designers-instinct/parity-handoffs/<surface-id>/<approval-version>/`. Separate verified facts, Director instructions, inferences and unknowns. Specify whether this is a lightweight visual prototype or a production implementation and preserve a typed, componentised migration path. Require canonical screenshots, overlay, diff, metrics, validation and a scored completion report. Never claim that the handoff is the build, never instruct Codex to guess, and never use the words “1:1 parity” unless the completed implementation has reproducible evidence and Director approval.
