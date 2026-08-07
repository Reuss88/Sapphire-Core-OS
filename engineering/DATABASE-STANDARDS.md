# Database and Supabase Standards

## Source-of-truth rule

Supabase is not permitted to become a second business architecture. Database objects must implement the canonical Sapphire architecture.

## Before migrations

Codex must inspect existing:

- tables, columns, enums and constraints;
- views/materialized views;
- SQL functions and RPCs;
- triggers;
- RLS policies;
- grants;
- audit/event tables;
- identity and tenancy models;
- migrations and naming conventions.

## DDL

- Migrations must be forward-safe and reviewable.
- Prefer additive changes over destructive changes.
- Destructive migrations require explicit mission approval and migration plan.
- Use foreign keys and constraints where they protect business truth.
- Do not encode mutually conflicting state in multiple columns/tables.
- Preserve timestamps, provenance and actor identity for material commercial changes.

## RPCs and functions

- Use RPCs for transactional operations, permission-aware workflows, complex atomic state transitions and aggregation contracts that should not be reconstructed in clients.
- RPC names must express domain intent, not UI implementation detail.
- Validate authority in the database for privileged operations.
- Functions must be deterministic where possible and clearly classified as read or mutation paths.

## Triggers

Triggers may enforce invariants, emit audit/outbox events, maintain derived state or prevent illegal transitions. They must not hide broad business workflows that should be explicit and testable.

## RLS

- RLS is mandatory for user-accessible domain data unless a documented architecture exception exists.
- Visibility does not imply authority.
- Workflow state does not imply permission.
- Director, team, external and service roles must be explicit.

## Realtime

Realtime is for invalidation and live state where operationally valuable. Do not rely on realtime delivery as the only source of truth.

## Audit

Material actions must record actor, action, target, timestamp, source, relevant before/after state or event payload, and correlation identifiers where applicable.

## Idempotency

Automations, webhook/event consumers, notification generation and mission/task creation from system events must be idempotent.
