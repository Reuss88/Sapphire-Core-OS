# RS-001 — Relationship Standard

## Status

Normative Phase 3 foundation standard.

## Scope

Applies to every governed relationship represented by Sapphire Core OS.

## Normative rules

### RS-001-01 Semantic definition

Every Relationship Type must have explicit governed meaning.

### RS-001-02 Canonical participants

Every binary Relationship Instance must identify a source Business Object and a target Business Object.

### RS-001-03 Stable identity

A Relationship Instance must retain stable identity across accepted changes and implementation changes.

### RS-001-04 Type compatibility

Participants must conform to the source and target Business Object Types permitted by the Relationship Type.

### RS-001-05 Directionality

Directionality must be explicit and must not be inferred from storage order.

### RS-001-06 Roles

Source and target roles must be defined by the Relationship Type and preserved in runtime snapshots.

### RS-001-07 Cardinality

Cardinality and participation limits must be governed metadata and enforced where technically possible.

### RS-001-08 Effective time

Relationship truth must define the period for which it is valid.

### RS-001-09 Recorded time

The system must preserve when each accepted Relationship Version was recorded.

### RS-001-10 Immutable versions

Accepted Relationship Versions must be append-only. Correction creates a new version.

### RS-001-11 Provenance

Every accepted Relationship Version must identify its provenance kind and attribution where available.

### RS-001-12 Evidence

Evidence requirements must be defined by the Relationship Type where relationship truth requires documentary or other support.

### RS-001-13 Ownership

Relationship ownership must be explicit and separate from responsibility, access, workflow assignment, and authority.

### RS-001-14 Organisation scope

A runtime Relationship Instance must belong to an organisation scope, and its canonical participants must conform to that scope unless a future approved cross-organisation pattern explicitly permits otherwise.

### RS-001-15 Audit

Creation, version addition, correction, retirement, and identifier changes must produce append-only audit events.

### RS-001-16 Foreign-key boundary

A database foreign key may implement a relationship but must not be treated as its complete semantic definition.

### RS-001-17 Lifecycle boundary

Relationship status must not be confused with Business Object lifecycle state.

### RS-001-18 Workflow boundary

Relationship data must not silently encode workflow routing or work assignment.

### RS-001-19 Authority boundary

A Relationship Instance must not create organisational authority unless a future Authority Architecture explicitly consumes it under a governed rule.

### RS-001-20 Access boundary

Access to Relationship data does not grant authority over the relationship or participants.

### RS-001-21 AI boundary

AI may observe, extract, compare, recommend, or prepare relationship information. AI does not originate organisational authority.

### RS-001-22 Separation of concerns

Architecture metadata, runtime Relationship data, and audit data must remain distinct.

### RS-001-23 Traversal semantics

Relationship traversal must expose semantic type, participant roles, and effective validity rather than only raw linkage.

### RS-001-24 Retirement

Retirement must preserve historical Relationship Versions and events.

### RS-001-25 Conformance

An implementation is conformant only when it satisfies RS-001 and the applicable checks in RS-004.
