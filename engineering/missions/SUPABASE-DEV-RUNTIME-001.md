# ENGINEERING MISSION — Supabase Development Runtime

## Mission ID

`SUPABASE-DEV-RUNTIME-001`

## Status

Approved prerequisite mission.

## Repository

`Reuss88/Sapphire-Core-OS`

## Engineering entrypoint — mandatory

Read and follow:

`engineering/START-HERE-CODEX.md`

before changing repository configuration.

## Objective

Create a safe, repeatable Supabase development and test workflow that Codex can use to apply migrations, execute SQL tests, validate RLS and verify RPC/function behaviour without touching production or committing secrets.

This mission is development infrastructure. It must not invent product doctrine.

## Pre-flight

Inspect and report:

- existing `supabase/` directory and config;
- migration layout and naming conventions;
- package manager and scripts;
- current `.env.example` contract;
- any Supabase project references already documented;
- Docker availability;
- Supabase CLI availability;
- PostgreSQL tooling availability;
- existing CI workflows;
- current SQL/static validation scripts;
- whether an isolated remote development project is already configured.

Do not assume local Docker is available.

## Preferred execution modes

Codex must support one repository-approved path and document fallback where practical.

### Mode A — Local Supabase

Preferred when Docker and Supabase CLI are available.

The workflow should support:

- starting local Supabase;
- resetting/applying migrations deterministically;
- loading safe development seed data if needed;
- running SQL/RLS tests;
- stopping local services cleanly.

### Mode B — Isolated remote development project

Use only when local runtime is unavailable and the Director supplies/configures a dedicated non-production Supabase project.

Requirements:

- no production credentials;
- secrets remain in local environment or CI secret storage;
- clear project-link/unlink instructions;
- migration/test commands documented;
- explicit environment guard preventing accidental production execution where feasible.

## Repository deliverables

Adapt to existing conventions, but provide equivalents for:

- documented environment prerequisites;
- `.env.example` updates using placeholder names only;
- package scripts or task commands for migration apply/reset and tests;
- one canonical `engineering/SUPABASE-DEVELOPMENT-WORKFLOW.md` describing setup and commands;
- development-only seed strategy if required;
- SQL/RLS test runner path;
- CI-friendly command where possible;
- safety guardrails distinguishing local/dev from production.

## Required command contract

At the end of this mission the repository must have clearly documented commands equivalent to:

- install/check Supabase tooling;
- start or connect to approved development runtime;
- apply/reset migrations;
- run SQL/RLS tests;
- run repository static checks;
- cleanly disconnect/stop.

Do not invent command names that conflict with existing package scripts; extend existing conventions.

## Security rules

- Never commit access tokens, database passwords, JWT secrets, service-role keys or project secrets.
- Never use production as a test target.
- Never print secrets into committed logs or fixtures.
- Do not weaken RLS for development convenience.
- Seed data must be synthetic and non-sensitive.
- Remote dev linking must be explicit and reversible.

## Validation

Mission PASS requires either:

### Local path

- approved local runtime starts successfully;
- migrations apply/reset successfully;
- at least one existing SQL or smoke test runs against the runtime;
- documented commands reproduce the result.

or

### Remote dev path

- an isolated development project is configured by authorised local secret/environment values;
- migrations apply to that project;
- SQL/RLS smoke test runs successfully;
- production is demonstrably not the target.

If neither runtime is available because the Director has not supplied tooling or a dev project, repository documentation/scripts may be prepared but mission must report PARTIAL and list the exact one-time setup required from the Director.

## Do not

- create a production Supabase project;
- guess credentials;
- commit secrets;
- run destructive reset against any non-development project;
- change business schema merely to make the runtime easier to configure.

## Definition of done

The mission is complete when another Codex session can enter the repository, follow one documented development-runtime path and independently apply/test migrations and RLS safely.

## Mission Result

Return the exact result format from `engineering/WORKFLOW.md`.

On PASS, explicitly state that the database-runtime prerequisite for `IDENTITY-ACCESS-001` and `ACTIONS-001` is satisfied.