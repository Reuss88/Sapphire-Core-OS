# Approved Image Parity Handoffs

Every Director-approved raster design receives a self-contained implementation handoff in this directory.

## Governing law

All packages must comply with:

- [`CS-UI-001 — Approved Image to Web Parity Constitution`](../constitutional/CS-UI-001-APPROVED-IMAGE-TO-WEB-PARITY-CONSTITUTION.md)
- [`Approved Image to Web — Agent Handoff Template`](../templates/APPROVED-IMAGE-TO-WEB-HANDOFF-TEMPLATE.md)
- [`Approved Image Parity Manifest Schema`](../templates/approved-image-parity-manifest.schema.json)

## Directory convention

`<surface-id>/<approval-version>/`

Example:

`home/v1/`

Packages are immutable records of an approval version. A materially changed design creates a new approval version rather than silently replacing the earlier authority.

## Minimum package

See CS-UI-001 Article 3. Packages without the canonical reference, manifest, measured handoff and evidence contract are not implementation-ready.
