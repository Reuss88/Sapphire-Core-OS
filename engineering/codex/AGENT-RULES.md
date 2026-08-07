# Codex Agent Rules for Sapphire Core OS

## Start rule

For every Sapphire implementation mission, Codex must begin by reading `engineering/README.md` and following the Engineering Framework before touching code.

## Behaviour

- Inspect before modifying.
- Preserve locked doctrine.
- Extend existing systems rather than duplicating them.
- Do not redesign Director-approved UI.
- Do not invent database architecture when doctrine or schema already defines it.
- Do not treat visibility as authority.
- Do not bypass RLS, approval, audit or workflow rules.
- Do not silently perform destructive migrations.
- Do not scatter fixtures or constants across components.
- Do not claim PASS without running the mission's required checks.

## When uncertain

If a mission is ambiguous but repository evidence resolves it, inspect and proceed. If doctrine conflicts or a destructive/authority-sensitive choice remains genuinely unresolved, stop and report the exact conflict before implementation.

## Reporting

Always return the Mission Result format from `engineering/WORKFLOW.md`.

## Mission discovery

If the Director says to execute a named workspace mission, search that workspace's doctrine directory first. For Actions, the current mission is:

`designers-instinct/pages/actions/codex-mission-actions-v1.md`

Read the mission only after the Engineering Framework pre-flight rules are loaded.
