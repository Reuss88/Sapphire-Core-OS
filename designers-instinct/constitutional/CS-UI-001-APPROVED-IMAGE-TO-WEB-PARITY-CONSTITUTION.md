# CS-UI-001 — Approved Image to Web Parity Constitution

## Status

- Authority: **Director-approved constitutional implementation law**
- Scope: every Sapphire Core OS web page or application surface commissioned from an approved raster design
- Applies to: PNG, JPEG/JPG, WebP and any later approved raster format that can be decoded deterministically
- Applies to agents: ChatGPT, Codex and every human or automated handoff author, implementer and verifier
- Version: 1.0

## Constitutional purpose

This standard makes an approved image reproducibly implementable as a faithful, functional web page.

It exists so that:

1. the Director approves one visual authority;
2. a handoff author packages that authority without redesigning it;
3. an implementation agent can build it without guessing;
4. a verifier can reproduce the parity decision from committed evidence;
5. another capable agent can continue the work without relying on private conversation history.

The objective is not “similar”, “inspired by” or “design-system aligned”. The objective is the closest technically correct implementation of the approved composition at the canonical viewport, followed by governed responsive adaptations.

## Article 1 — Authority and precedence

### 1.1 Visual authority

Once the Director marks an image `APPROVED`, that exact committed file is the visual authority for the named surface and viewport.

The implementation must follow its:

- silhouette;
- region order;
- grid and proportions;
- spacing and density;
- typography hierarchy and line wrapping;
- colour balance and material treatment;
- visible content hierarchy;
- imagery and icon placement;
- control placement;
- no-scroll or overflow behaviour.

The implementer may not redesign, beautify, simplify, modernise, reinterpret or merge the reference with another concept.

### 1.2 Doctrine authority

The approved image governs appearance. Sapphire doctrine governs meaning.

No image may:

- grant authority;
- bypass permissions;
- redefine record ownership;
- invent business logic;
- turn AI inference into verified fact;
- override accessibility, security or legal correctness;
- make an irreversible action executable from a summary surface when doctrine prohibits it.

When visual appearance and doctrine conflict, preserve doctrine and document the smallest visible deviation for Director decision.

### 1.3 Explicit instruction authority

A later explicit Director instruction may amend the approved image for a named element. The handoff must record the instruction, date, affected region and replacement rule. Silent interpretation is prohibited.

## Article 2 — Role separation

### Director

- selects and approves the visual authority;
- approves any material change;
- accepts or rejects final parity.

### Handoff author

Usually ChatGPT or another planning agent.

- validates and commits the exact reference asset;
- measures and describes the reference;
- packages all required implementation contracts;
- records facts, assumptions and unresolved questions separately;
- never claims that a specification is an implementation.

### Implementer

Usually Codex or another coding agent.

- validates the handoff before writing UI code;
- chooses the least-committing prototype stack that satisfies the requested stage;
- builds components rather than baking UI into images;
- captures and compares implementation screenshots;
- iterates until acceptance thresholds pass or exact blockers are reported.

### Verifier

- repeats asset, viewport, build and screenshot checks;
- examines the reference and implementation directly;
- rejects parity claims unsupported by committed evidence.

One agent may perform more than one role, but the evidence and gates remain separate.

## Article 3 — The canonical handoff package

Every approved-image implementation must have one self-contained package under:

`designers-instinct/parity-handoffs/<surface-id>/<approval-version>/`

Required structure:

```text
<approval-version>/
├── MISSION.md
├── APPROVAL.md
├── HANDOFF.md
├── ACCEPTANCE.md
├── manifest.json
├── reference/
│   └── approved-source.<ext>
├── annotations/
│   ├── geometry.md
│   ├── content.md
│   ├── assets.md
│   └── interactions.md
├── fixtures/
│   └── fixture-contract.md
└── evidence/
    └── README.md
```

The package may link to governing doctrine elsewhere in the repository. It may not depend on an uncommitted attachment, expired URL, private chat, clipboard item or agent memory.

## Article 4 — Reference asset integrity gate

The handoff author must validate the actual file bytes, not trust its filename or extension.

Before implementation:

1. commit the original approved source at its approved dimensions;
2. detect the real media type from file contents;
3. decode it with at least two independent decoders when practical;
4. record width, height, aspect ratio, colour space/profile, alpha and orientation;
5. calculate and record SHA-256;
6. open and visually inspect the committed raw file;
7. compare the committed file with the Director-approved source;
8. reject corruption, accidental thumbnails, screenshots of screenshots and silent resampling.

### Format-independent rule

PNG, JPEG and WebP are equal as handoff inputs when the committed bytes decode correctly and match the approved source.

The implementation process must not depend on an extension-specific assumption. It consumes the dimensions and media type recorded in `manifest.json`.

### Conversion rule

Do not convert the approved source merely for convenience.

When a conversion is explicitly required:

- preserve pixel dimensions and orientation;
- use lossless output where the source permits;
- keep the original beside the derivative;
- record both hashes;
- label the original as visual authority;
- visually verify the derivative before use.

AI regeneration, enhancement, generative fill and unapproved upscaling create a new design and require Director approval.

### Failed integrity gate

If the repository reference is corrupt or dimensionally wrong, the implementer may use a separately supplied verified original for local analysis, but may not declare final parity until the canonical repository asset is repaired.

## Article 5 — Required manifest

`manifest.json` is the machine-readable source of implementation facts. It must validate against:

`designers-instinct/templates/approved-image-parity-manifest.schema.json`

Required facts include:

- stable surface and approval identifiers;
- approval state and Director approval date;
- canonical reference path, media type, dimensions, aspect ratio and SHA-256;
- canonical viewport width and height;
- expected browser zoom and device pixel ratio;
- page-scroll rule;
- target route and delivery stage;
- required framework constraints, if any;
- governing doctrine paths;
- dynamic-content masks or fixed fixture rules;
- required validation evidence.

No agent may replace an unknown value with a plausible invention. Unknowns are recorded as `null` with a corresponding blocker or Director decision request where the schema permits.

## Article 6 — Measurement before prose

The handoff author must inspect the reference directly and produce a measured model.

### Geometry annotation

Record at minimum:

- canvas bounds;
- fixed shell regions;
- major x/y alignment lines;
- column count and spans;
- outer padding and major gaps;
- region bounding boxes as pixels and percentages;
- row heights;
- sidebar/header/footer dimensions;
- overflow and no-scroll expectations;
- layering, crop and background behaviour.

Measurements may be approximate during handoff but must be labelled with their tolerance. Words such as “large”, “small”, “near” or “roughly” cannot replace bounding-box information.

### Content annotation

Record all visible:

- headings and labels;
- values, units, currencies and periods;
- row counts and ordering;
- badges and statuses;
- line breaks that materially affect geometry;
- fixture-versus-production classification.

### Asset annotation

For every nontrivial visual asset, record one of:

- exact approved repository asset;
- existing approved icon or design-system primitive;
- programmatic chart or map with a defined data contract;
- temporary placeholder explicitly barred from final parity.

Generic Unicode symbols, improvised SVGs and approximate logos may support an early prototype but cannot pass final asset parity.

### Interaction annotation

Every visible control must declare:

- accessible name;
- intended action;
- route or controlled placeholder;
- hover, focus, pressed and disabled state;
- authority boundary;
- expected keyboard behaviour.

## Article 7 — Stage-aware technology choice

The handoff must name the delivery stage:

### Visual prototype

Use the lightest stack that can reproduce the approved surface and interactions. Vite + React, framework-neutral React or another reversible web prototype is acceptable.

The prototype must still preserve:

- typed data contracts;
- component boundaries;
- semantic CSS tokens;
- accessible HTML;
- route/action adapters;
- a clean migration path to the production stack.

### Product implementation

Use the approved product architecture and framework. For Sapphire Core OS this is currently governed separately as Next.js 16 App Router where the relevant product contract requires it.

### Prohibition

Do not force a production architecture merely to show a visual prototype. Do not build a disposable static mock whose UI must be rewritten to migrate.

## Article 8 — Implementation sequence

Every implementation follows this order:

1. **Intake audit** — validate package completeness and asset integrity.
2. **Reference inspection** — open the image and read every governing file completely.
3. **Implementation map** — declare routes, component tree, fixtures, asset plan and known gaps.
4. **Canvas lock** — establish viewport, shell, scrolling and major alignment lines.
5. **Silhouette pass** — reproduce region order, spans, row heights and density without polish.
6. **Component pass** — create real semantic components and deterministic fixtures.
7. **Typography pass** — match font family, hierarchy, line height and wrapping.
8. **Material pass** — match colour, borders, elevation, imagery and controlled effects.
9. **Asset pass** — replace temporary icons and images with approved assets.
10. **Interaction pass** — wire every visible control to a route or honest controlled placeholder.
11. **Accessibility pass** — landmarks, labels, focus, contrast and reduced motion.
12. **Screenshot pass** — capture the canonical viewport.
13. **Comparison pass** — overlay, diff and measure against the approved source.
14. **Correction loop** — fix the largest visible drift first and recapture.
15. **Validation pass** — type, lint, build, tests, console and overflow checks.
16. **Completion report** — publish evidence, score, deviations and deferred dependencies.

An agent may not skip directly from prose handoff to “complete”.

## Article 9 — Screenshot and comparison protocol

### Canonical capture

The implementation screenshot must use the manifest’s:

- viewport width and height;
- browser zoom;
- device pixel ratio or documented equivalent;
- fixed deterministic fixture state;
- font state;
- motion-disabled or settled state;
- scrollbar rule.

The screenshot must show the complete target canvas. A clipped browser panel is not canonical evidence.

### Required comparison evidence

Commit or supply:

1. `implementation.png` — canonical implementation capture;
2. `overlay.png` — reference and implementation at equal dimensions with 50% blend or equivalent flicker comparison;
3. `diff.png` — visual difference heatmap where tooling permits;
4. `metrics.json` — geometry, overflow and similarity measurements;
5. `COMPLETION.md` — human-readable result.

If dynamic data must differ, the handoff must define masks before comparison. An implementer cannot mask a region merely because it failed parity.

### Correction order

Always correct in this order:

1. canvas and shell;
2. major rows and columns;
3. dominant cards;
4. typography and wrapping;
5. spacing and alignment;
6. assets and icons;
7. colour and material;
8. micro-details.

Polishing icons while the grid is wrong is prohibited.

## Article 10 — Acceptance thresholds

### Binary gates

All must pass:

- reference integrity gate;
- exact widget/region order;
- canonical route renders;
- canonical viewport and no-scroll rule;
- no missing required region;
- no silently dead control;
- no TypeScript/build failure for a typed implementation;
- no browser console error;
- accessibility essentials present;
- required evidence produced.

### Geometry tolerances at the canonical viewport

- canvas and fixed shell boundaries: target within 2px;
- major card boundaries: target within 3px;
- repeated gaps and padding: target within 2px, never inconsistently rounded;
- minor internal spacing: target within 4px;
- line wrapping: exact for dominant headings and geometry-critical copy;
- ordinary page scroll: exactly as approved.

The completion report must list any boundary outside tolerance.

### Parity score

The verifier reports a 100-point score:

- shell and overall silhouette: 20;
- grid, boundaries and spacing: 25;
- typography and wrapping: 15;
- colour, surface and elevation: 10;
- approved assets and icons: 10;
- content density and ordering: 10;
- interaction states and functional fidelity: 5;
- accessibility and technical correctness: 5.

Interpretation:

- below 80: structural prototype;
- 80–89: strong prototype, not parity-complete;
- 90–94: high-fidelity implementation with visible deviations;
- 95–98: Director-reviewable parity candidate;
- 99–100: 1:1 parity claim permitted, subject to Director Approval Lock.

A score never overrides a failed binary gate. The Director is the final acceptance authority.

## Article 11 — Handoff quality gate

A handoff is implementation-ready only when another capable agent can answer, without prior chat history:

- Which exact file is authoritative?
- Has it been decoded and visually verified?
- What viewport must be reproduced?
- What are the measured major bounds?
- Which text and data are fixed fixtures?
- Which assets must be exact?
- What may be a temporary prototype substitute?
- What does every visible control do?
- Which doctrine governs meaning and authority?
- What evidence proves completion?
- Which uncertainties require Director decision?

If any answer is absent, the handoff author must complete the package rather than telling the implementer to infer it.

## Article 12 — Required completion report

`COMPLETION.md` must contain:

- repository, branch and commit;
- surface ID and approval version;
- route implemented;
- framework/runtime used and delivery stage;
- files created and modified;
- validation commands and results;
- screenshot, overlay, diff and metrics paths;
- parity score with category breakdown;
- every known deviation;
- every intentionally deferred backend/product dependency;
- confirmation that the canonical asset was decoded and inspected;
- Director approval status.

“Done”, “pixel perfect” and “1:1” without this evidence are invalid completion statements.

## Article 13 — Failure and escalation rules

Stop and report rather than guess when:

- the reference is corrupt, missing or differs from its manifest;
- two files claim visual authority;
- the canonical viewport is absent;
- a required font, logo, icon or image is unavailable;
- doctrine conflicts with the approved visual behaviour;
- the implementation surface already exists and changing it would destroy approved behaviour;
- required comparison evidence cannot be captured accurately.

The agent must still make safe progress on non-blocked work and identify the smallest decision needed to resume.

## Article 14 — Amendment and change control

This constitution may be amended only through an explicit Director-approved change identifying:

- the article changed;
- the reason;
- the evidence;
- migration implications for active parity missions;
- the new version.

Individual page missions may tighten this law. They may not weaken it silently.

## Constitutional command

For every Director-approved Sapphire design image:

> Commit the exact source, prove its integrity, measure before describing, package facts so no agent must guess, build real components, compare at the canonical viewport, correct visible drift, publish reproducible evidence, and reserve the words “1:1 parity” for a verified result accepted by the Director.
