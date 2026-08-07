# ENGINEERING MISSION — Identity / Access / Authority Runtime

## Mission ID

`IDENTITY-ACCESS-001`

## Status

Approved prerequisite mission.

## Repository

`Reuss88/Sapphire-Core-OS`

## Engineering entrypoint — mandatory

Read and follow:

`engineering/START-HERE-CODEX.md`

before writing code.

## Objective

Implement the reusable Sapphire runtime foundation for actor identity, organisation membership, team scope, capabilities and server-side authority evaluation so downstream workspaces can enforce RLS and privileged mutations without inventing role logic.

This mission implements existing doctrine. It must not redefine Authority or Approval semantics.

## Read first

After loading the Engineering Framework, read:

1. `architecture/identity-access/MASTER-IDENTITY-ACCESS-ARCHITECTURE-v1.md`
2. `architecture/decision-authority-approval/PASS-01-DECISION-FOUNDATIONS.md`
3. `architecture/decision-authority-approval/PASS-02-AUTHORITY-ARCHITECTURE.md`
4. `architecture/decision-authority-approval/PASS-03-APPROVAL-ARCHITECTURE.md`
5. `architecture/LOCKED-ARCHITECTURE-SUMMARY.md`
6. relevant existing Supabase migrations, schemas, RPCs, RLS and audit conventions.

## Pre-flight

Before changes, inspect and report the actual current implementation of:

- Supabase Auth usage;
- JWT claims and how `organisation_id` is minted;
- actor/profile tables if any;
- organisation tables and membership primitives if any;
- team / department / operating-unit structures if any;
- roles, permissions, grants or capability tables if any;
- Governance authority / decision runtime tables and RPCs if any;
- `sca_audit`, event or outbox primitives;
- security-definer function conventions;
- RLS helper conventions;
- migration naming and test conventions.

Reuse before creating. If an equivalent exists, extend it.

## Required implementation outcome

Codex must implement or adapt a coherent runtime that provides equivalents for:

- authenticated Sapphire actor identity mapped to `auth.users`;
- organisation membership and active membership state;
- team scope / membership where needed;
- role definitions as administrative bundles;
- capability definitions;
- role-capability assignments;
- explicit actor capability grants / denials only where required;
- server-side authority evaluation integrated with canonical Authority Rules / Grants rather than replaced by roles;
- audit events for material access / authority changes.

Exact table names must follow established repository conventions.

## Required server-side helpers

Provide tested equivalents for these semantic contracts:

- `current_actor_id()`
- `current_organisation_id()`
- `is_org_member(org_id)`
- `can_access_team(team_id)`
- `has_capability(capability_code, context)`
- `has_authority(decision_class, subject, limits, context)`

An `is_org_director(org_id)` convenience helper is permitted only if derived from governed server-side membership / authority state. It must never trust a frontend label or arbitrary role claim.

## Security rules

- Authentication does not equal authorisation.
- Organisation membership does not equal unrestricted access.
- Team membership does not equal authority.
- Assignment and visibility never create authority.
- Roles may bundle capabilities but cannot replace Authority Rules / Grants for consequential Decisions.
- Do not create permissive `authenticated can access everything` RLS to make tests pass.
- Do not expose service-role credentials to browser code.
- Use safe search paths and avoid recursive RLS helper designs.

## Migration requirements

- additive and reversible where practical;
- preserve compatibility with current `organisation_id`-bound data;
- no invented backfill of Director/role/authority data without deterministic source evidence;
- document interim compatibility debt;
- preserve audit history;
- add constraints and indexes required for safe evaluation.

## RLS / test requirements

Tests must prove at minimum:

1. unauthenticated access denied where expected;
2. actor resolves only to its own authenticated identity;
3. organisation A cannot read organisation B records;
4. suspended/revoked membership loses access;
5. team-scoped actor cannot gain unrelated team visibility;
6. role label alone does not grant authority;
7. capability grant changes affect permitted software actions as expected;
8. assignment does not imply authority;
9. expired/revoked Authority Grant fails authority evaluation;
10. valid Authority Grant succeeds only within scope/limits/effective period;
11. privileged mutations emit the existing audit/event record;
12. service-role or backend bypass behaviour is explicit and tested.

## Do not

- redesign Governance;
- complete the reserved Approval Architecture beyond what is necessary for compatibility;
- create workspace-specific permission systems;
- hard-code `Director` into frontend or JWT checks as the source of truth;
- commit credentials;
- continue if an authority conflict remains genuinely unresolved.

## Definition of done

Mission may report PASS only when:

- schema/migrations apply in the approved development environment;
- server-side identity/membership/capability helpers exist and are tested;
- canonical authority evaluation is reusable by downstream RPC/RLS paths;
- organisation isolation tests pass;
- audit behaviour is verified;
- documentation records actual implemented names and downstream usage;
- Actions can consume the runtime without inventing security logic.

## Mission Result

Return the exact result format from `engineering/WORKFLOW.md`.

On PASS, explicitly state that `ACTIONS-001` security prerequisite is satisfied or list any remaining blocker.