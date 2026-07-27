# Relationship Type Architecture

## Purpose

Define the canonical metadata required to govern every class of relationship in Sapphire Core OS.

## Canonical Relationship Type metamodel

Every Relationship Type must define:

- stable type key;
- canonical name;
- description;
- relationship family;
- source Business Object Type;
- target Business Object Type;
- directionality;
- inverse relationship name where applicable;
- source role;
- target role;
- cardinality;
- minimum and maximum source participation;
- minimum and maximum target participation;
- exclusivity rules;
- symmetry rules;
- transitivity rules where applicable;
- composition semantics;
- aggregation semantics;
- dependency semantics;
- validity rules;
- ownership model;
- provenance requirements;
- evidence requirements;
- lifecycle participation;
- versioning policy;
- implementation mappings;
- architecture status;
- architecture version;
- effective period.

## Stable type key

The type key is immutable after use in runtime data. Human-readable names may evolve without changing the type key.

## Participant compatibility

A Relationship Type must explicitly identify which Business Object Types may occupy the source and target roles.

Compatibility rules may allow:

- one exact Business Object Type;
- a governed family of types;
- a controlled list of types;
- a future policy expression.

This phase implements exact source and target Business Object Type references.

## Directionality

Allowed directionality values are:

- `directed`;
- `undirected`;
- `reciprocal`.

For undirected relationships, participant ordering must not change semantic meaning.

For reciprocal relationships, the inverse label must preserve governed inverse meaning without creating duplicate runtime truth.

## Cardinality

Cardinality is represented as a source-to-target rule:

- one-to-one;
- one-to-many;
- many-to-one;
- many-to-many.

Minimum and maximum participation constraints refine the broad cardinality category.

A null maximum means unbounded participation.

## Exclusivity

An exclusive relationship restricts a Business Object from holding more than the permitted number of concurrent effective relationships of the same type and role.

Exclusivity checks must use effective time, not only current database rows.

## Symmetry and transitivity

Symmetry and transitivity are explicit semantic properties.

They must not be inferred from labels or data shape.

A symmetric relationship treats source and target order as semantically equivalent.

A transitive relationship permits governed inference across compatible chains, but inferred relationships must remain distinguishable from asserted relationships.

This phase records these properties but does not implement inference.

## Composition and aggregation

Composition indicates strong whole-part dependency in which the part's business meaning is materially bound to the whole.

Aggregation indicates weaker whole-part association where each participant retains independent meaning.

Neither property automatically grants ownership, authority, deletion cascade, or lifecycle effects.

## Dependency semantics

Dependency rules describe whether one participant's validity depends on the other participant or the relationship itself.

This phase records dependency metadata but does not implement lifecycle consequences.

## Validity rules

Validity rules may constrain:

- participant status;
- organisation scope;
- effective period;
- uniqueness;
- evidence completeness;
- compatible classifications;
- allowed self-reference;
- duplicate prevention.

## Ownership model

The Relationship Type defines which actor, team, organisational unit, or policy determines relationship ownership.

Ownership does not create authority.

## Provenance and evidence requirements

The Relationship Type defines accepted provenance kinds and whether supporting evidence is required before a Relationship Version may be accepted.

## Lifecycle participation

A Relationship Type may declare whether future lifecycle controls apply to its instances.

This declaration does not implement lifecycle state or transition logic.

## Versioning policy

Relationship Type metadata is architecture metadata and must itself be version-governed.

Runtime Relationship Instances remain stable while accepted relationship truth is represented through immutable Relationship Versions.

## Implementation mappings

Mappings may identify database schemas, API resources, integration contracts, or application views.

Mappings implement the Relationship Type; they do not redefine its meaning.
