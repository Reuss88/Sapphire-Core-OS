# Relationship Runtime Architecture

## Purpose

Define the governed runtime objects, invariants, history rules, and query behaviour for Relationship truth.

## Runtime objects

### Relationship Instance

A stable identity for one governed semantic connection.

It records:

- relationship ID;
- organisation scope;
- Relationship Type;
- source Business Object;
- target Business Object;
- current version number;
- active or retired status;
- creation and retirement attribution.

### Relationship Version

An immutable accepted statement of relationship truth.

It records:

- version number;
- relationship data;
- source and target roles;
- effective period;
- recorded time;
- provenance;
- change reason;
- superseded version;
- integrity hash.

### Relationship Participant

A governed additional participant used only where a relationship pattern requires more than the canonical source and target.

It records:

- participant Business Object;
- semantic role;
- ordinal where ordering matters;
- effective period;
- provenance and attribution.

### Relationship Identifier

A governed external or internal identifier attached to the stable Relationship Instance.

### Relationship Event

An append-only audit record for creation, versioning, correction, retirement, identifier changes, and other governed runtime events.

## Activation

A newly created Relationship Instance is active after its initial Relationship Version is successfully recorded.

Creation must validate:

- organisation compatibility;
- Relationship Type effectiveness;
- source and target existence;
- source and target Business Object Type compatibility;
- duplicate and self-reference rules where configured.

## Versioning

New accepted truth creates a new Relationship Version.

The runtime must:

- lock the stable Relationship Instance during version creation;
- close the prior open effective period when appropriate;
- increment the current version number;
- link the superseded version;
- preserve prior recorded history;
- write a Relationship Event.

## Correction

A correction is represented as a new Relationship Version with provenance kind `correction` and an explicit change reason.

Correction never overwrites an earlier version.

## Retirement

Retirement marks the stable Relationship Instance unavailable for future active use and closes any open effective Relationship Version at the retirement time.

Retirement must preserve all identifiers, versions, and events.

## Supersession

Every new version after the first should identify the directly superseded Relationship Version.

The supersession chain must remain linear for the stable Relationship Instance in this phase.

## Conflict handling

The runtime must reject or surface:

- missing Business Objects;
- cross-organisation participants;
- incompatible Business Object Types;
- ineffective Relationship Types;
- duplicate active relationships where prohibited;
- invalid effective periods;
- invalid self-reference;
- concurrent version conflicts;
- cardinality violations where enforceable.

## Effective-time querying

A Relationship snapshot at a requested effective time returns the one Relationship Version whose effective period contains that time.

Effective containment is:

```text
effective_from <= requested_time
and
(effective_to is null or effective_to > requested_time)
```

## Recorded-time history

Recorded time is append-only and reflects when each version entered the system.

This phase preserves recorded timestamps but does not yet implement full as-recorded-at query reconstruction.

## Runtime invariants

- Stable Relationship identity never changes.
- Every Relationship belongs to one organisation scope.
- Source and target Business Objects belong to the same organisation as the Relationship Instance.
- Every Relationship Version belongs to exactly one Relationship Instance.
- Version numbers increase monotonically.
- At most one Relationship Version is open-ended for a Relationship Instance.
- Prior versions are never silently deleted or rewritten.
- Relationship Type meaning is resolved from architecture metadata.
- Audit events remain append-only.

## Relationship integrity

Integrity exists at three levels:

1. **Structural integrity** — valid IDs, references, periods, and version sequence.
2. **Semantic integrity** — participants conform to the Relationship Type.
3. **Governance integrity** — provenance, ownership, evidence, and authority boundaries remain explicit.

## Traversal

Runtime traversal may list relationships for a Business Object as:

- outgoing;
- incoming;
- either direction.

Traversal must return semantic type, participant roles, direction, and effective version rather than exposing only raw foreign keys.

## Snapshot rules

A Relationship snapshot must include:

- stable relationship ID;
- organisation ID;
- Relationship Type key;
- source and target Business Object IDs;
- source and target roles;
- version number;
- relationship data;
- effective period;
- recorded time;
- provenance;
- active status.

## Architectural boundaries

The runtime does not create:

- lifecycle transitions;
- workflow routing;
- decisions;
- approvals;
- authority;
- access grants.

Later modules may consume Relationship truth but must not redefine it.
