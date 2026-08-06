# Repository Governance

## Canonical source of truth

The architecture documents and approved registers are the governing source of truth.

Implementation artefacts must conform to them.

## Locked architecture rule

Locked modules may not be changed silently.

A proposed change to locked architecture requires:

1. an Architecture Decision Record;
2. impact analysis;
3. explicit approval;
4. version change;
5. migration guidance;
6. conformance review.

## Precedence

When sources conflict, use this order:

1. Enterprise Constitution
2. Ratified architecture standards
3. Canonical registers
4. Approved Architecture Decision Records
5. Implementation specifications
6. Application behaviour
7. Convenience or local convention

## AI governance

AI-generated content is always draft until reviewed and accepted by an authorised human or deterministic governance process.

AI must not:

- create authority;
- override controls;
- conceal uncertainty;
- fabricate evidence;
- silently modify locked architecture;
- treat application behaviour as canonical truth.

## Approved-image implementation governance

Every web surface commissioned from a Director-approved PNG, JPEG or WebP is governed by
[`CS-UI-001 — Approved Image to Web Parity Constitution`](designers-instinct/constitutional/CS-UI-001-APPROVED-IMAGE-TO-WEB-PARITY-CONSTITUTION.md).

The exact committed image governs visual composition at its canonical viewport. Broker OS doctrine and ratified architecture continue to govern meaning, authority, permissions and business behaviour.

No agent may declare 1:1 parity unless the reference-asset integrity gate, canonical screenshot comparison, binary acceptance gates and Director Approval Lock in CS-UI-001 have all passed. A prose mission, prototype or subjective resemblance is not parity evidence.
