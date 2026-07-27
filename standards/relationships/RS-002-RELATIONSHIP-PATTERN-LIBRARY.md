# RS-002 — Relationship Pattern Library

## Purpose

Provide reusable canonical relationship patterns. Each implementation must document its adaptation and demonstrate conformance with RS-001 and RS-004.

## 1. Directed Association

- **Intent:** Represent one-way semantic meaning from source to target.
- **Participants:** source, target.
- **Direction:** directed.
- **Cardinality:** any governed form.
- **Constraints:** inverse meaning must not be implied unless defined.
- **Effective time:** required.
- **Implementation notes:** preserve source and target role labels.

## 2. Undirected Association

- **Intent:** Represent a symmetric connection where participant order is immaterial.
- **Participants:** two peers.
- **Direction:** undirected.
- **Cardinality:** commonly many-to-many.
- **Constraints:** duplicate reversed pairs must be prevented.
- **Effective time:** required.
- **Implementation notes:** canonical ordering may be used technically without changing meaning.

## 3. Reciprocal Relationship

- **Intent:** Represent one relationship with governed inverse labels.
- **Participants:** source, target.
- **Direction:** reciprocal.
- **Cardinality:** governed by type.
- **Constraints:** inverse navigation must not create duplicate truth.
- **Effective time:** shared by both semantic views.
- **Implementation notes:** store one stable Relationship Instance.

## 4. Hierarchy

- **Intent:** Represent ordered superior-subordinate structure.
- **Participants:** parent, child.
- **Direction:** directed.
- **Cardinality:** usually one-to-many.
- **Constraints:** cycle prevention where hierarchy must be acyclic.
- **Effective time:** required.
- **Implementation notes:** transitive closure is derived, not silently asserted.

## 5. Parent–Child

- **Intent:** Represent a governed parent and child connection.
- **Participants:** parent, child.
- **Direction:** directed.
- **Cardinality:** type-specific.
- **Constraints:** self-reference normally prohibited.
- **Effective time:** required.
- **Implementation notes:** does not automatically imply ownership or cascade deletion.

## 6. Ownership

- **Intent:** Represent that one Business Object owns another Business Object or governed asset.
- **Participants:** owner, owned object.
- **Direction:** directed.
- **Cardinality:** governed, often one-to-many.
- **Constraints:** exclusivity may apply.
- **Effective time:** mandatory.
- **Implementation notes:** ownership does not automatically grant authority or access.

## 7. Membership

- **Intent:** Represent membership of a person, organisation, or object in a group.
- **Participants:** member, group.
- **Direction:** directed.
- **Cardinality:** many-to-many.
- **Constraints:** duplicate concurrent membership prohibited unless roles differ.
- **Effective time:** mandatory.
- **Implementation notes:** membership status is distinct from workflow assignment.

## 8. Responsibility

- **Intent:** Represent accountability or responsibility for a Business Object.
- **Participants:** responsible actor, subject.
- **Direction:** directed.
- **Cardinality:** one-to-many or many-to-many.
- **Constraints:** responsibility class or role should be explicit.
- **Effective time:** mandatory.
- **Implementation notes:** responsibility never creates authority.

## 9. Representation

- **Intent:** Represent that one actor represents another party or object.
- **Participants:** representative, represented party.
- **Direction:** directed.
- **Cardinality:** governed by scope.
- **Constraints:** mandate scope and evidence may be required.
- **Effective time:** mandatory.
- **Implementation notes:** does not itself prove authority to decide.

## 10. Contractual Relationship

- **Intent:** Represent a relationship arising from a contract.
- **Participants:** contracting parties or party and contract.
- **Direction:** reciprocal or directed by type.
- **Cardinality:** usually many-to-many.
- **Constraints:** evidence reference normally required.
- **Effective time:** aligned to contractual validity where appropriate.
- **Implementation notes:** the contract document is evidence, not the relationship itself.

## 11. Supplier–Customer Relationship

- **Intent:** Represent commercial supply between supplier and customer.
- **Participants:** supplier, customer.
- **Direction:** reciprocal.
- **Cardinality:** many-to-many.
- **Constraints:** may be scoped by product, geography, or legal entity.
- **Effective time:** required.
- **Implementation notes:** does not encode purchase workflow or approval.

## 12. Employment

- **Intent:** Represent employment between person and employing organisation.
- **Participants:** employee, employer.
- **Direction:** reciprocal.
- **Cardinality:** many-to-many over time; concurrent limits may apply.
- **Constraints:** evidence and jurisdiction may be required.
- **Effective time:** mandatory.
- **Implementation notes:** employment may support later authority evaluation but never creates authority by itself.

## 13. Organisational Structure

- **Intent:** Represent placement of organisational units within an organisation.
- **Participants:** containing unit, contained unit.
- **Direction:** directed.
- **Cardinality:** usually one-to-many.
- **Constraints:** cycle prevention normally required.
- **Effective time:** mandatory.
- **Implementation notes:** structural placement is separate from reporting workflow.

## 14. Composition

- **Intent:** Represent strong whole-part semantic dependency.
- **Participants:** whole, part.
- **Direction:** directed.
- **Cardinality:** one-to-many.
- **Constraints:** part participation may be exclusive.
- **Effective time:** required.
- **Implementation notes:** no deletion cascade or lifecycle consequence is implied until governed elsewhere.

## 15. Aggregation

- **Intent:** Represent weak whole-part association.
- **Participants:** aggregate, member part.
- **Direction:** directed.
- **Cardinality:** one-to-many or many-to-many.
- **Constraints:** parts retain independent identity.
- **Effective time:** required.
- **Implementation notes:** weaker than composition.

## 16. Dependency

- **Intent:** Represent that one Business Object depends on another.
- **Participants:** dependent, dependency.
- **Direction:** directed.
- **Cardinality:** many-to-many.
- **Constraints:** dependency class should be explicit.
- **Effective time:** required.
- **Implementation notes:** does not automatically block workflow or lifecycle.

## 17. Succession

- **Intent:** Represent temporal succession from predecessor to successor.
- **Participants:** predecessor, successor.
- **Direction:** directed.
- **Cardinality:** normally one-to-one or one-to-many.
- **Constraints:** predecessor and successor must be distinct.
- **Effective time:** succession time required.
- **Implementation notes:** historical identity remains preserved.

## 18. Replacement

- **Intent:** Represent that one object replaces another for a defined purpose.
- **Participants:** replacement, replaced object.
- **Direction:** directed.
- **Cardinality:** governed by type.
- **Constraints:** replacement scope and reason required.
- **Effective time:** required.
- **Implementation notes:** replacement does not erase or mutate the replaced object.

## 19. Delegation Reference

- **Intent:** Link an actor or object to a governed delegation record.
- **Participants:** delegator or delegate, delegation subject.
- **Direction:** directed.
- **Cardinality:** governed by delegation scope.
- **Constraints:** this relationship is referential only.
- **Effective time:** required.
- **Implementation notes:** authority derives from Authority Rules and Grants, not from this relationship alone.

## 20. Temporal Relationship

- **Intent:** Represent a connection whose meaning is inherently time-bounded.
- **Participants:** type-specific.
- **Direction:** type-specific.
- **Cardinality:** type-specific.
- **Constraints:** effective period mandatory and non-overlapping where required.
- **Effective time:** central to meaning.
- **Implementation notes:** historical versions remain queryable.

## 21. Exclusive Relationship

- **Intent:** Restrict concurrent effective participation to a defined maximum.
- **Participants:** type-specific.
- **Direction:** usually directed.
- **Cardinality:** commonly one-to-one or many-to-one.
- **Constraints:** overlap checks mandatory.
- **Effective time:** mandatory.
- **Implementation notes:** exclusivity is evaluated over effective periods.

## 22. Many-to-Many Association

- **Intent:** Represent independently governed connections among many source and target objects.
- **Participants:** source set, target set.
- **Direction:** directed, undirected, or reciprocal.
- **Cardinality:** many-to-many.
- **Constraints:** each Relationship Instance remains individually identifiable.
- **Effective time:** required.
- **Implementation notes:** do not collapse semantic data into an ungoverned join table.
