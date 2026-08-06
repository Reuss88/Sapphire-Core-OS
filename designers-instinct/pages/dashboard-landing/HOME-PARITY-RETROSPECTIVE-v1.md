# HOME Parity Prototype Retrospective v1

## Purpose

This is the worked lesson behind `CS-UI-001`. It records why a credible first HOME prototype reached approximately 80% visual parity but could not honestly be called 1:1.

It is not an approved-image handoff package and must not be copied as one. Future handoffs use the canonical package structure under `designers-instinct/parity-handoffs/`.

## Outcome

The prototype successfully reproduced the approved screen's broad hierarchy, density, dark material language, primary regions and no-scroll desktop composition. It also established typed fixtures, component boundaries and a migration path from a lightweight prototype into a later Next.js product implementation.

Director review assessed it at approximately **80% parity**.

## What worked

- the original local reference was opened and inspected directly;
- the page hierarchy and visible widget order were transcribed before implementation;
- the prototype used a reversible Vite-powered React stack with strict TypeScript and Next-compatible route boundaries;
- fixture data was deterministic and isolated from future backend ownership;
- the canonical 1920 × 1080 logical viewport fit without ordinary page scrolling;
- visible controls had routes or honest controlled placeholders;
- build, type, lint, render tests and browser-console checks passed;
- a Director-reviewable screenshot and implementation report were produced.

## Why it stopped at 80%

### Reference integrity was not reproducible

The repository's `home-approved-v1.webp` was 1000 × 562 and visibly corrupted. The usable source existed only at `/Users/reuss/Downloads/Generated image 2.png`. Another agent could not reproduce the same visual analysis from the repository alone.

Under CS-UI-001 this fails the reference-asset integrity gate. Final parity work must pause until the exact approved source is committed, decoded, hashed and visually verified.

### Geometry was inferred too loosely

The broad composition matched, but several paddings, gaps, row heights, panel proportions and text wraps drifted. The earlier mission described hierarchy well but did not provide a complete measured bounding-box model.

CS-UI-001 now requires canvas, shell, region and alignment measurements before implementation prose.

### Asset fidelity was knowingly approximate

Programmatic globe/map treatments and symbolic glyphs substituted for the approved geographic imagery, icon family, logo treatment and Director portrait. These were reasonable prototype substitutions but remain visible parity defects.

CS-UI-001 now distinguishes prototype substitutes from exact production assets and bars substitute icons, improvised SVGs and approximate logos from final parity.

### Comparison evidence was incomplete

The prototype had a review screenshot and DOM geometry checks, but no equal-size canonical reference capture, registered overlay, diff heatmap or committed metric report. Browser backing-scale behaviour also meant the available bitmap was not a canonical 1920 × 1080 comparison frame.

CS-UI-001 now requires a controlled capture contract, overlay/diff evidence and binary acceptance gates before a 1:1 claim.

## Constitutional correction

For every later approved Sapphire image, the handoff author must now:

1. commit and validate the exact approved raster;
2. create a schema-valid manifest;
3. measure geometry and inventory content, assets and interactions;
4. declare whether the stage is a visual prototype or product implementation;
5. separate allowed prototype substitutions from final blockers;
6. prescribe reproducible screenshot, overlay, diff and metric evidence;
7. require a completion report that identifies deviations honestly;
8. leave final acceptance behind the Director Approval Lock.

## Related evidence

- Original page mission: `CODEX-MISSION-HOME-PARITY-v1.md`
- Original parity specification: `parity-spec-v1.md`
- Prototype implementation: `apps/home-prototype/`
- Prototype report: `artifacts/HOME-PARITY-PROTOTYPE-REPORT.md`
- Prototype review screenshot: `artifacts/home-parity-prototype-review-1703x1080.jpg`
- Governing replacement flow: `designers-instinct/constitutional/CS-UI-001-APPROVED-IMAGE-TO-WEB-PARITY-CONSTITUTION.md`
