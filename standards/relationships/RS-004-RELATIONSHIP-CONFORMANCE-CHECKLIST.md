# RS-004 — Relationship Conformance Checklist

Use this checklist for architecture review, implementation review, migration review, and certification.

## Semantic definition

- [ ] The Relationship Type has explicit governed meaning.
- [ ] The relationship is not defined only by a foreign key or join table.
- [ ] Source and target roles are explicit.
- [ ] Directionality is explicit.
- [ ] Inverse meaning is documented where applicable.

## Participant integrity

- [ ] Source Business Object Type is governed.
- [ ] Target Business Object Type is governed.
- [ ] Runtime participants conform to permitted types.
- [ ] Organisation-scope rules are enforced.
- [ ] Self-reference rules are explicit.
- [ ] Additional participants use governed semantic roles.

## Cardinality and constraints

- [ ] Cardinality is declared.
- [ ] Minimum participation is declared where material.
- [ ] Maximum participation is declared where material.
- [ ] Exclusivity is explicit where required.
- [ ] Duplicate concurrent relationships are controlled.
- [ ] Hierarchical cycles are controlled where applicable.

## Identity and time

- [ ] Relationship Instance identity is stable.
- [ ] Effective time is recorded.
- [ ] Recorded time is preserved.
- [ ] Effective-period constraints are valid.
- [ ] At most one open-ended version exists per Relationship Instance.
- [ ] Retirement preserves history.

## History and provenance

- [ ] Accepted changes create immutable versions.
- [ ] Superseded versions remain identifiable.
- [ ] Provenance kind is recorded.
- [ ] Change reason is recorded when required.
- [ ] Evidence requirements are enforced where applicable.
- [ ] Audit events are append-only.

## Ownership and governance

- [ ] Relationship ownership is explicit.
- [ ] Ownership is not confused with responsibility.
- [ ] Access is not treated as authority.
- [ ] Responsibility is not treated as authority.
- [ ] Relationship data does not silently create authority.
- [ ] AI does not originate organisational authority.

## Architectural separation

- [ ] Business Objects remain canonical.
- [ ] Relationships do not redefine Business Objects.
- [ ] Lifecycle state is not encoded as Relationship status.
- [ ] Workflow routing is not encoded as relationship truth.
- [ ] Decisions and approvals are not implemented through relationship rows.
- [ ] Architecture metadata is separated from runtime data.
- [ ] Runtime data is separated from audit data.

## Technical implementation

- [ ] Migration order is deterministic.
- [ ] SQL names align with architecture names.
- [ ] TypeScript contracts align with SQL.
- [ ] RLS is enabled on protected tables.
- [ ] Security-definer functions have explicit search paths.
- [ ] Public execution is revoked where appropriate.
- [ ] Organisation-scoped policies are present.
- [ ] JSON registers parse successfully.
- [ ] Architecture tests cover creation, versioning, snapshots, identifiers, retirement, and invalid inputs.

## Conformance outcome

- [ ] Conformant
- [ ] Conformant with documented exception
- [ ] Non-conformant

Document every exception, owner, remediation action, and target date.
