# Engineering Review Template

## Mission

`<MISSION ID>`

## Review status

PASS / CHANGES REQUIRED / BLOCKED

## Doctrine conformance

- Does implementation match canonical business architecture?
- Does it preserve workspace ownership?
- Does it respect Governance and authority boundaries?
- Does it comply with Designers Instinct and the Sapphire Design System?

## Frontend review

- Route and component structure
- Loading/error/empty/stale states
- Accessibility
- Responsive behaviour
- Visual parity where applicable
- No ad hoc design tokens

## Backend review

- Schema alignment
- Migration safety
- RPC/function/trigger correctness
- RLS and grants
- Audit and provenance
- Realtime/invalidation
- Idempotency

## Quality gates

- Typecheck
- Lint
- Tests
- Build
- Migration verification
- Visual regression/parity check

## Director review

Required: YES / NO

Director decision: APPROVED / CHANGES REQUIRED / NOT REVIEWED

## Follow-up

List exact changes or next mission.
