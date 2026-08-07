# Testing and Quality Standards

## Core rule

Codex must verify the change it claims to have completed. PASS is an engineering result, not a writing style.

## Required checks

Run the checks relevant to the repository and mission, including:

- TypeScript typecheck;
- lint;
- unit tests;
- integration tests;
- production build;
- database migration validation;
- RLS/permission tests for protected data;
- accessibility checks for user-facing UI;
- visual/parity comparison when a Director-approved reference exists.

If a check cannot run, report exactly why and mark the mission PARTIAL unless the mission explicitly permits otherwise.

## UI quality

Test loading, empty, error, stale, partial and permission-denied states where applicable. Verify keyboard navigation, focus visibility, reduced-motion behaviour and responsive layout.

## Database quality

Test legal and illegal transitions, tenant isolation, idempotency, concurrency-sensitive mutations where material, audit creation and rollback/backout assumptions.

## Regression discipline

Do not fix a new feature by silently breaking an existing contract. Run existing tests touching shared primitives and document any changed behaviour.

## Fixtures

Fixtures must be typed, deterministic, realistic and centralised. They may model backend contracts but must not become a second permanent business-rules engine.

## Mission evidence

The final Mission Result must list checks run and their actual outcomes. Do not claim a check passed if it was not run.