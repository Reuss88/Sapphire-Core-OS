# Actions Interaction Contract

## Core transitions

### Action item
Allowed transitions:
- draft -> queued
- queued -> ready
- ready -> in_progress
- in_progress -> waiting | blocked | completed
- waiting -> ready | in_progress | cancelled
- blocked -> ready | in_progress | cancelled
- any non-terminal state -> cancelled when authorised
- completed -> reopened only through explicit reopen command with reason

Invalid transitions must fail server-side.

### Mission
- planned -> active
- active -> at_risk | blocked | completed | cancelled
- at_risk -> active | blocked | completed | cancelled
- blocked -> active | at_risk | cancelled

Mission completion must enforce configured success criteria and open-critical-action policy.

## Commands
Required user commands:
- create mission
- create action
- start
- complete
- mark waiting
- block / resolve blocker
- reassign
- add/remove contributor
- reschedule
- change priority
- link/unlink governed record
- add evidence
- reopen
- cancel
- create follow-up
- create sub-action

Each command must return the resulting authoritative record plus any validation or authority failure.

## Optimistic UI
Optimistic rendering is acceptable for low-risk cosmetic ordering only. Authoritative status, assignment, completion, approval, evidence and dependency changes must reconcile with the server response.

## Completion
Completion captures actor, timestamp, optional/required completion note, evidence references and outcome. If evidence is required by policy, completion must be rejected without it.

## Waiting On
Waiting requires a reason and optionally an external party/record, expected response date and follow-up date. Waiting items may automatically surface for follow-up but are not silently moved back to ready.

## Blocking
A blocker must identify a cause or dependency. Removing a blocker must be audited. Derived blocked state may result from unresolved dependencies.

## Dependencies
Dependencies are directed. The server must prevent self-dependency and cycles. Completion of a prerequisite may make dependants ready and publish a realtime invalidation event.

## Assignment
Assignment does not grant authority. Reassignment may require elevated permission for protected missions/actions. Ownership history is immutable in the execution event stream.

## Notifications
Notifications are delivery surfaces, not execution truth. Dismissal of a notification never completes an action.

## Keyboard
Desktop must support command palette, quick search, next/previous item navigation, open inspector, complete where safe, and creation shortcuts. Destructive/authority commands require explicit confirmation.
