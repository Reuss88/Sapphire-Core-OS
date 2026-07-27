# Phase 3 — Relationship Foundation

## Status

Relationship Architecture is locked at the conceptual level; this phase adds the canonical implementation foundation.

## Purpose

Define governed semantic connections between Business Objects so relationship meaning, participants, validity, provenance, ownership, and history remain explicit across applications and technologies.

## Core principle

A Relationship is a governed semantic connection between Business Objects whose meaning, participants, validity, provenance, and history remain explicit.

A Relationship is not merely:

- a database foreign key;
- an application join;
- a UI link;
- a workflow assignment;
- an access grant;
- an authority grant;
- an inferred association without governance.

Database links may implement relationship truth. They do not define it.

## Canonical distinctions

### Relationship Type

A Relationship Type defines the governed semantic class of connection permitted between specified Business Object Types.

### Relationship Instance

A Relationship Instance is a stable governed identity representing one specific semantic connection between Business Objects.

### Relationship Version

A Relationship Version records one immutable accepted statement of relationship truth, including its participants, role semantics, validity, provenance, and supporting data.

## Stable identity

A Relationship Instance retains a stable identifier across corrections, effective-date changes, implementation changes, and superseding versions.

Stable identity must not depend solely on:

- mutable labels;
- the current database row;
- the current effective period;
- application-specific IDs;
- current status;
- current ownership.

## Participants

Every binary relationship must identify:

- source Business Object;
- target Business Object;
- source role;
- target role;
- Relationship Type.

Where a pattern requires more than two participants, additional governed Relationship Participants may be recorded without changing the meaning of the stable Relationship Instance.

## Directionality

Directionality must be explicit:

- **directed** — source-to-target meaning is material;
- **undirected** — participant order does not change meaning;
- **reciprocal** — each direction has a governed inverse meaning.

An inverse label aids navigation but must not silently create a second Relationship Instance.

## Cardinality

Cardinality is a rule of the Relationship Type, not an accidental database outcome.

Cardinality may constrain:

- source participation;
- target participation;
- minimum participation;
- maximum participation;
- exclusivity;
- uniqueness within an organisation or scope.

## Ownership

Relationship ownership must be explicit and separate from:

- authorship;
- responsibility;
- workflow assignment;
- access;
- organisational authority.

The owner is accountable for the governed relationship record, not automatically for either participating Business Object.

## Provenance and evidence

Every accepted Relationship Version must identify how the relationship truth entered or changed within the enterprise.

Examples include:

- human entry;
- contract extraction;
- external integration;
- imported dataset;
- system calculation;
- AI-assisted preparation;
- authorised automated execution;
- correction.

Evidence requirements are defined by the Relationship Type. Evidence supports relationship truth but does not itself constitute the relationship.

## Time model

The architecture distinguishes:

- **effective time** — when the relationship is valid in the business world;
- **recorded time** — when the system recorded that relationship statement.

Corrections create a new recorded version and preserve prior recorded history.

## Immutable history

Relationship history is append-only.

A new accepted statement creates a new Relationship Version. Prior versions are not overwritten. Retention, redaction, and legal erasure require governed procedures rather than silent mutation.

## Correction and supersession

Correction changes the recorded statement while preserving the stable Relationship Instance and superseded version.

Supersession must identify the prior Relationship Version and the reason for replacement.

## Activation and retirement

Relationship activation and retirement describe whether the stable Relationship Instance remains available for future business use.

Retirement does not erase prior versions or effective-time truth.

## Relationship status

This phase uses operational identity status only:

- active;
- retired.

It does not introduce a general lifecycle engine. Future Lifecycle Architecture may govern richer state models without redefining Relationship identity.

## Architectural boundaries

- Relationships connect Business Objects but do not redefine them.
- A relationship is not a lifecycle state.
- A relationship is not workflow routing.
- A relationship is not authority.
- A relationship is not access.
- A relationship is not evidence.
- AI may prepare or suggest relationship information but does not create organisational authority.
- Architecture metadata, runtime data, and audit data remain separate.

## Implementation boundary

The PostgreSQL and TypeScript artefacts in this phase implement the canonical metamodel. They do not define the complete domain Relationship Type catalogue.
