# Sapphire Engineering Framework

## Purpose

This directory governs how Sapphire Core OS is implemented by Codex and future engineering agents. It is development infrastructure only. It does not define product behaviour and must never override Broker OS doctrine, architecture, Designers Instinct, Governance, or Director-approved parity references.

## Codex entrypoint

Codex must start here for every implementation mission.

Read in this order:

1. `engineering/README.md`
2. `engineering/WORKFLOW.md`
3. `engineering/IMPLEMENTATION-STANDARDS.md`
4. `engineering/DATABASE-STANDARDS.md` when data/backend work is involved
5. `engineering/UI-PARITY-STANDARDS.md` when UI work is involved
6. `engineering/codex/AGENT-RULES.md`
7. the mission file
8. all doctrine and architecture referenced by the mission

## Authority order

If instructions conflict, follow this precedence:

1. Director-approved locked doctrine / parity reference
2. Broker OS and canonical architecture
3. Designers Instinct and Sapphire Design System
4. Governance / authority architecture
5. Engineering Framework
6. Mission file
7. Existing implementation details
8. Agent preference

No lower layer may silently redefine a higher layer.

## Safe implementation rule

Inspect before modifying. Extend before replacing. Reuse before creating. Never duplicate systems of record.

## Mission location

Product-specific missions remain with their workspace doctrine, for example:

`designers-instinct/pages/actions/codex-mission-actions-v1.md`

The Engineering Framework supplies the permanent execution rules so missions can remain concise and consistent.
