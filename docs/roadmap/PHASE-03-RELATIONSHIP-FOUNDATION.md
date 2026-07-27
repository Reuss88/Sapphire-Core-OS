# Phase 3 — Relationship Foundation

## Outcome

Phase 3 establishes the governed runtime foundation for semantic Relationships between canonical Business Objects.

## Delivered architecture

- Relationship Foundation
- Relationship Type Architecture
- Relationship Runtime Architecture
- stable Relationship identity
- explicit source and target roles
- directionality and inverse meaning
- cardinality and participation constraints
- effective-time and recorded-time distinction
- immutable Relationship Version history
- provenance, evidence, ownership, correction, supersession, activation, and retirement boundaries

## Delivered standards

- `RS-001 — Relationship Standard`
- `RS-002 — Relationship Pattern Library`
- `RS-003 — Relationship Runtime Object Register`
- `RS-004 — Relationship Conformance Checklist`

## Delivered database implementation

- `sca_meta.relationship_type`
- `sca_core.relationship`
- `sca_core.relationship_version`
- `sca_core.relationship_participant`
- `sca_core.relationship_identifier`
- `sca_audit.relationship_event`
- directionality and cardinality enums
- supporting constraints, indexes, comments, triggers, and RLS activation

## Delivered RPCs

- `sca_core.register_relationship_type`
- `sca_core.create_relationship`
- `sca_core.add_relationship_version`
- `sca_core.retire_relationship`
- `sca_core.add_relationship_identifier`
- `sca_core.get_relationship_snapshot`
- `sca_core.list_relationships_for_business_object`

## Delivered access foundation

- organisation-scoped read policies
- approved, effective, or locked Relationship Type visibility
- reuse of the existing JWT organisation-boundary helper

The Phase 3 policies are interim. The future Identity, Access & Security Architecture may replace the JWT claim mechanism without changing Relationship semantics.

## Delivered developer contracts

- TypeScript Relationship contracts
- Relationship Type register foundation
- SQL architecture smoke test

## Tests covered

- Relationship Type registration
- Relationship creation
- Business Object existence and participant compatibility
- immutable version append
- current version increment
- effective-period closure
- snapshot retrieval
- traversal
- identifier creation
- audit events
- retirement
- invalid Relationship Type rejection
- invalid participant-type rejection

## Deferred items

- approved domain Relationship Types
- cardinality enforcement beyond exact participant-type checks
- exclusivity overlap engine
- symmetric-pair canonicalisation
- hierarchy cycle prevention
- inferred transitive relationships
- evidence attachment implementation
- full recorded-time reconstruction
- authority-aware mutation policies
- generated Supabase database typings
- Edge Functions and public API façade

## Known limitations

- Additional Relationship Participants are structurally supported but no public RPC is included in this phase.
- The SQL test is designed for `psql` because it uses `\gset` variables.
- CI and an isolated PostgreSQL/Supabase validation environment are not yet configured in the repository.
- Relationship Type metadata is governed but full architecture-version lineage for metadata remains a later governance concern.

## Conformance statement

This phase translates the locked Relationship Architecture principles available in the canonical repository context into an implementation foundation. It does not redefine Business Objects, Lifecycle, Workflow, Decisions, Approvals, Authority, or Access.

## Recommended next phase

**Phase 4 — Lifecycle Foundation**
