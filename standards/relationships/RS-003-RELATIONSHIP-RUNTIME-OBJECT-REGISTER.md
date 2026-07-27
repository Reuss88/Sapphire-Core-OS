# RS-003 — Relationship Runtime Object Register

## Status

Normative Phase 3 runtime object register.

| Runtime object | Purpose | Stable identity | Versioned | Effective time | Audit required |
|---|---|---:|---:|---:|---:|
| Relationship Type | Defines governed semantic relationship metadata | Yes | Architecture-governed | Yes | Yes |
| Relationship Instance | Stable identity for one governed connection | Yes | No | Indirectly through versions | Yes |
| Relationship Version | Immutable accepted relationship truth | Yes | Append-only sequence | Yes | Yes |
| Relationship Participant | Additional governed participant for non-binary patterns | Yes | Append-only/effective-dated | Yes | Yes |
| Relationship Identifier | Governed external or internal identifier | Yes | Effective-dated | Yes | Yes |
| Relationship Event | Append-only audit record | Yes | No | Occurrence time | N/A |

## Relationship Type

Minimum attributes:

- ID;
- type key;
- canonical name;
- description;
- family;
- source Business Object Type;
- target Business Object Type;
- directionality;
- roles;
- cardinality;
- constraints;
- architecture status;
- architecture version;
- effective period.

## Relationship Instance

Minimum attributes:

- relationship ID;
- organisation ID;
- Relationship Type ID;
- source Business Object ID;
- target Business Object ID;
- current version number;
- active flag;
- creation attribution;
- retirement attribution.

## Relationship Version

Minimum attributes:

- version ID;
- relationship ID;
- version number;
- source role;
- target role;
- relationship data;
- effective period;
- recorded time;
- recorded actor;
- provenance kind;
- provenance reference;
- change reason;
- superseded version ID;
- content hash.

## Relationship Participant

Minimum attributes:

- participant ID;
- relationship ID;
- Business Object ID;
- semantic role;
- ordinal;
- effective period;
- recorded time;
- recorded actor.

## Relationship Identifier

Minimum attributes:

- identifier ID;
- relationship ID;
- namespace;
- identifier value;
- source system;
- primary flag;
- effective period;
- recorded attribution.

## Relationship Event

Minimum attributes:

- event ID;
- organisation ID;
- relationship ID;
- event type;
- actor ID;
- occurrence time;
- request ID;
- correlation ID;
- event data.

## Boundary rule

These runtime objects represent relationship truth and evidence. They do not represent lifecycle transitions, workflow routing, access grants, decisions, approvals, or authority grants.
