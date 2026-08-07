# Identity / Access / Authority Runtime

Mission: `IDENTITY-ACCESS-001`

## Runtime ownership

The canonical runtime is split by doctrine:

- `sca_identity` owns authenticated actors, organisations, active membership, teams, administrative role bundles, and revocable software capabilities.
- `sca_governance` owns consequential Authority Rules, Authority Grants, and Delegations.
- `sca_audit.access_event` is the append-only record of material identity, access, capability, and authority mutations.

A role is only a capability bundle. A role label, team membership, work assignment, or frontend claim never creates authority.

## Server-side contracts

Downstream RLS policies and security-definer RPCs must call these functions instead of reading role labels or trusting client state:

| Contract | Implemented function |
| --- | --- |
| Current authenticated actor | `sca_identity.current_actor_id()` |
| Current validated organisation | `sca_identity.current_organisation_id()` |
| Existing compatibility entrypoint | `sca_core.current_organisation_id()` |
| Active organisation membership | `sca_identity.is_org_member(uuid)` |
| Team visibility | `sca_identity.can_access_team(uuid)` |
| Software action capability | `sca_identity.has_capability(text, jsonb)` |
| Consequential decision authority | `sca_governance.has_authority(text, jsonb, jsonb, jsonb)` |

All evaluation helpers are `SECURITY DEFINER` with an empty fixed search path and schema-qualified references. This avoids helper recursion through RLS.

## Organisation compatibility boundary

Existing Sapphire records remain bound to their current `organisation_id`. The legacy `sca_core.current_organisation_id()` function now delegates to the canonical identity resolver, so existing Business Object and Relationship policies inherit membership validation without schema changes.

The JWT `organisation_id` claim is an interim selector only. The resolver accepts it only when the authenticated actor has an active, effective membership in that organisation. If the claim is absent or invalid, the resolver returns the actor's organisation only when exactly one active membership exists; ambiguous context fails closed.

No migration mints JWT claims and no Director, role, capability, or authority data is inferred or backfilled.

## Capability evaluation

`has_capability` requires an active actor and active organisation membership. It combines:

- an active direct allow grant whose JSON context is contained by the request context; or
- an active role assignment whose role includes the capability, optionally constrained to the requested team.

An active matching direct denial overrides both sources. Suspended, revoked, future, or expired assignments and grants do not evaluate.

The backend `service_role` has an explicit software-capability bypass for trusted server operations. This does not fabricate an actor or consequential organisational authority.

## Authority evaluation

`has_authority` reads only canonical active Authority Rules and effective Authority Grants or Delegations. It validates:

- decision class;
- active organisation membership;
- rule, grant, and delegation effective periods;
- subject scope containment;
- jurisdiction, condition, and evidence context containment;
- requested numeric limits against every applicable maximum.

Authority is never inferred from a role, capability, team, assignment, JWT label, or `service_role`. Callers needing to execute a consequential Decision must first evaluate this function with the actual subject, requested limits, and evidence-bearing context.

## Mutation boundary and audit

Authenticated clients receive read access through restrictive RLS and execute access only to approved helpers. They receive no direct table mutation grants. The initial privileged mutation functions are:

- `sca_identity.set_organisation_membership_status(...)`
- `sca_identity.grant_actor_capability(...)`
- `sca_governance.create_authority_grant(...)`

Each requires the relevant management capability unless called by trusted `service_role`. Table triggers record inserts, updates, and deletes across material identity and governance records in `sca_audit.access_event`. Audit events cannot be updated or deleted, including by a table owner, because an immutability trigger rejects both operations.

## Downstream use

Actions and other workspaces should:

1. bind every protected row to `organisation_id`;
2. use `sca_identity.current_organisation_id()` or `is_org_member(...)` for tenant scope;
3. use `can_access_team(...)` for team visibility;
4. use `has_capability(...)` for software operations;
5. use `has_authority(...)` separately for consequential Decisions;
6. expose mutations only through security-definer RPCs with fixed search paths and explicit grants;
7. allow the access audit triggers to capture material state changes.

Approval semantics remain reserved to the approved Approval Architecture and are not implemented by this runtime.

## Verification

`tests/architecture/identity-access-foundation.sql` covers anonymous denial, self-only identity resolution, organisation isolation, suspended membership, team scope, role/assignment non-authority, capability lifecycle, Authority Grant scope/limits/effective state, audit emission, and explicit backend bypass behaviour.
