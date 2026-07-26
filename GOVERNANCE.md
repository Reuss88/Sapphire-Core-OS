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
