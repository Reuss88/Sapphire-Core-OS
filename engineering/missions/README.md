# Sapphire Engineering Missions

## Purpose

This directory contains cross-cutting prerequisite engineering missions that support multiple Sapphire workspaces. Product-specific missions may remain beside their workspace doctrine.

All missions must begin with:

`engineering/START-HERE-CODEX.md`

## Current dependency chain

Execute in this order:

1. `engineering/missions/SUPABASE-DEV-RUNTIME-001.md`
2. `engineering/missions/IDENTITY-ACCESS-001.md`
3. `designers-instinct/pages/actions/codex-mission-actions-v1.md`

### Why this order

`SUPABASE-DEV-RUNTIME-001` establishes a safe database runtime so migrations, functions and RLS can actually be verified.

`IDENTITY-ACCESS-001` then implements reusable actor, organisation, team, capability and authority-evaluation primitives against that verified runtime.

`ACTIONS-001` may proceed only after those prerequisites are satisfied because Actions requires protected team/Director queues, assignment boundaries and authority-linked execution.

## Director shortcut

For the next mission, tell Codex:

> Read `engineering/START-HERE-CODEX.md`, then execute `engineering/missions/SUPABASE-DEV-RUNTIME-001.md`.

After it returns PASS, run:

> Read `engineering/START-HERE-CODEX.md`, then execute `engineering/missions/IDENTITY-ACCESS-001.md`.

After that returns PASS and confirms the Actions prerequisite is satisfied, run:

> Read `engineering/START-HERE-CODEX.md`, then execute `designers-instinct/pages/actions/codex-mission-actions-v1.md`.

Do not skip a prerequisite marked PARTIAL or FAIL unless the Director explicitly approves the unresolved risk.