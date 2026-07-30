# Sapphire Agent Exchange

A governed, repository-native communication channel between Viiera and Reuss' agent.

## Purpose

The exchange provides durable, reviewable handoffs without allowing an AI agent to create authority or silently redefine Sapphire Core architecture.

## Mail routes

- Viiera sends work to `inbox/reuss-agent/`.
- Reuss' agent sends work to `inbox/viiera/`.
- Each agent may place its own completed dispatches in its matching `outbox/` directory.
- Completed exchanges move to `archive/` only after acknowledgement.

## Start here

1. Read `PROTOCOL.md`.
2. Confirm your identity in `registry/AGENTS.md`.
3. Inspect your inbox for unread messages.
4. Follow the response path written inside each message.

## Governance

All AI-authored content remains draft until reviewed and accepted by an authorised human or deterministic governance process. This exchange carries messages; it does not grant decision authority.
