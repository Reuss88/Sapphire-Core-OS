# Master Identity, Access and Authority Runtime Architecture v1

## Status

Foundation architecture for Sapphire Core OS runtime identity and access control.

## Purpose

Provide the reusable implementation layer every workspace can safely depend on for actor identity, organisation membership, team scope, capabilities and authority evaluation.

This architecture implements existing Sapphire doctrine. It does not replace or redefine the Decision / Authority / Approval architecture.

## Canonical distinctions

Identity answers: **Who is the actor?**

Membership answers: **Which organisation and team contexts does the actor belong to?**

Capability answers: **Which classes of software action may the actor attempt?**

Authority answers: **Does the actor legitimately possess organisational authority for this consequential Decision, within scope, limits, conditions and effective period?**

Workflow answers: **What work should happen next?**

These concepts are related but never interchangeable.

## Core rules

1. Supabase Auth authenticates a human or service identity; authentication does not itself grant business authority.
2. A user-facing title such as `Director` is presentation metadata and must never be the sole source of authority.
3. Organisation membership creates tenancy context, not unrestricted access.
4. Team membership creates operational scope, not organisational authority.
5. Roles may bundle capabilities for administration convenience, but authority-sensitive Decisions must evaluate canonical Authority Rules / Grants where doctrine requires them.
6. Assignment, visibility, workflow state and frontend routing never grant permission.
7. All privileged checks must be enforceable server-side and usable from RLS / RPC boundaries.
8. Every material access or authority change is auditable.

## Runtime object model

Codex must adapt names to existing schema conventions after pre-flight, but the runtime must provide equivalents for:

- actor / application profile mapped one-to-one to `auth.users` where human;
- organisation membership;
- team / operating-unit membership;
- role definitions;
- capability definitions;
- role-capability grants;
- actor-specific capability grants or denials where required;
- authority rules and authority grants, preferably by implementing / extending the canonical Governance architecture rather than creating a competing permission table;
- delegations where authorised by doctrine;
- immutable access / authority audit events.

## Required server-side evaluation primitives

The implementation must expose stable helpers or equivalent primitives that downstream RLS and RPCs can reuse. Exact names may follow repository conventions.

Minimum semantic contract:

- `current_actor_id()` — resolves authenticated Sapphire actor identity.
- `current_organisation_id()` — resolves active organisation context without trusting arbitrary client input.
- `is_org_member(org_id)` — verifies active membership.
- `can_access_team(team_id)` — verifies operational team visibility/scope.
- `has_capability(capability_code, context)` — evaluates software capability at the authoritative backend boundary.
- `has_authority(decision_class, subject, amount_or_limits, context)` — evaluates current organisational authority using Authority Rules / Grants.
- `is_org_director(org_id)` may exist only as a convenience derived from governed membership/authority data; it must not be a hard-coded JWT label.

Helpers used by RLS must be deterministic enough for policy evaluation, secure against caller-controlled search paths, and avoid recursive RLS traps.

## Tenancy

Every tenant-owned domain record must have a trustworthy organisation boundary derived from authoritative membership/context.

The interim `organisation_id` JWT claim may be supported during migration only if Codex verifies how it is minted and prevents arbitrary spoofing. It must not become the permanent sole source of membership truth unless explicitly approved by architecture.

Cross-organisation access is denied by default.

## Capability model

Capabilities should express domain intent, for example:

- `actions.read_self`
- `actions.read_team`
- `actions.assign`
- `actions.create_mission`
- `governance.request_approval`
- `documents.read_sensitive`

Do not encode UI component names as capabilities.

Role names are configurable administrative groupings. Downstream code should prefer capability checks over role-name checks for ordinary access.

## Authority model

The authoritative doctrine in `architecture/decision-authority-approval/` remains controlling.

Authority evaluation must preserve:

- decision class;
- actor;
- scope / jurisdiction;
- limits;
- conditions;
- effective period;
- governing policy;
- evidence requirements;
- delegation where applicable.

A capability such as `deal.approve` may permit access to the approval interface, but it must not substitute for an Authority Grant when a consequential Decision requires authority evaluation.

## RLS integration

RLS policies should compose reusable identity/membership/capability helpers instead of reimplementing role logic table by table.

Required properties:

- organisation isolation;
- personal visibility where relevant;
- team visibility where authorised;
- Director / elevated visibility only when server-evaluated grants allow it;
- service-role behaviour explicit and narrow;
- no broad `authenticated` policies used merely to unblock development.

## Audit

Material events include:

- membership created / suspended / revoked;
- team scope changed;
- role assigned / removed;
- capability grant / deny changed;
- authority grant / delegation created, suspended, expired or revoked;
- privileged access evaluation failures where operationally relevant.

Audit should use the existing Sapphire audit/event infrastructure rather than create a competing ledger.

## Migration strategy

1. Inspect current auth, claims, `organisation_id`, existing tables, RLS, RPCs and `sca_audit` conventions.
2. Reuse existing primitives where safe.
3. Add missing identity/access structures additively.
4. Provide compatibility helpers for existing organisation-bound records.
5. Backfill only with deterministic evidence; do not manufacture roles or authority.
6. Add tests before downstream workspaces depend on the runtime.
7. Document any interim compatibility debt.

## Acceptance contract for downstream workspaces

A dependent workspace may proceed with protected RLS only when:

- authenticated actor resolution works;
- organisation isolation is tested;
- team scope can be evaluated where required;
- capability evaluation is server-side;
- authority-sensitive operations can call canonical authority evaluation;
- material grants are audited;
- tests prove assignment / visibility do not imply authority.

## Non-goals

This foundation does not build a full Governance administration UI.

It does not complete the reserved Approval Architecture design pass.

It does not create Actions, Inbox, Deals or Finance-specific permission systems.

It exists so those workspaces can safely reuse one security foundation.