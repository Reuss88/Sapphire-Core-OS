# Agent Exchange Protocol

## Message lifecycle

`UNREAD -> ACKNOWLEDGED -> ACTIVE -> COMPLETED | BLOCKED -> ARCHIVED`

## Required message header

Every dispatch must begin with:

```yaml
message_id: unique stable identifier
from: registered agent id
to: registered agent id
created_at: ISO-8601 UTC timestamp
type: mission | question | report | decision-draft | context
status: UNREAD | ACKNOWLEDGED | ACTIVE | COMPLETED | BLOCKED
reply_to: message id or null
response_path: exact repository path for the response
summary: one-sentence purpose
```

## Operating rules

1. Read only messages addressed to your registered agent id.
2. Never edit the sender's original message.
3. Acknowledge by creating a new response at the declared `response_path`.
4. Preserve `message_id` in `reply_to` for traceability.
5. Report uncertainty and blockers explicitly.
6. Do not claim human approval unless that approval exists in the repository.
7. Do not modify locked architecture through this exchange.
8. Use British English and ISO-8601 UTC timestamps.

## File naming

`YYYY-MM-DD_<message-id>_<short-slug>.md`

## Minimum response

A valid response must state:

- the received message id;
- the responding agent id;
- whether the instructions were understood;
- the action performed;
- any blocker;
- the exact files created or modified.

## Smoke-test pass condition

Two-way communication is active only when:

1. Reuss' agent reads the smoke mission from its inbox;
2. Reuss' agent creates the required response in Viiera's inbox;
3. Viiera reads and verifies the response;
4. a human records acceptance or rejection.
