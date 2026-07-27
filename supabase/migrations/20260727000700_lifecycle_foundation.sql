begin;

create schema if not exists sca_meta;
create schema if not exists sca_core;
create schema if not exists sca_audit;

-- Metadata: lifecycle definition header
create table sca_meta.lifecycle_definition (
  id uuid primary key default gen_random_uuid(),
  type_key text not null unique,
  canonical_name text not null,
  description text not null,
  current_published_version_id uuid,
  created_at timestamptz not null default now(),
  created_by uuid,
  updated_at timestamptz not null default now(),
  updated_by uuid
);

-- Metadata: versions are immutable records of a lifecycle definition
create table sca_meta.lifecycle_definition_version (
  id uuid primary key default gen_random_uuid(),
  lifecycle_definition_id uuid not null references sca_meta.lifecycle_definition(id) on delete cascade,
  version_no bigint not null,
  name text not null,
  description text not null,
  effective_from timestamptz not null default now(),
  published boolean not null default false,
  recorded_at timestamptz not null default now(),
  recorded_by uuid,
  constraint lifecycle_definition_version_unique_version unique(lifecycle_definition_id, version_no)
);

-- Metadata: applicability (which object types this lifecycle applies to)
create table sca_meta.lifecycle_applicability (
  id uuid primary key default gen_random_uuid(),
  lifecycle_definition_id uuid not null references sca_meta.lifecycle_definition(id) on delete cascade,
  organisation_id uuid,
  object_family text,
  object_type text,
  created_at timestamptz not null default now(),
  created_by uuid
);

-- Metadata: state definitions belong to a lifecycle definition version and are immutable
create table sca_meta.lifecycle_state_definition (
  id uuid primary key default gen_random_uuid(),
  lifecycle_definition_version_id uuid not null references sca_meta.lifecycle_definition_version(id) on delete cascade,
  key text not null,
  name text not null,
  description text,
  is_terminal boolean not null default false,
  position integer not null default 0,
  constraint lifecycle_state_definition_unique_key unique(lifecycle_definition_version_id, key)
);

-- Metadata: transition definitions belong to a lifecycle definition version and are immutable
create table sca_meta.lifecycle_transition_definition (
  id uuid primary key default gen_random_uuid(),
  lifecycle_definition_version_id uuid not null references sca_meta.lifecycle_definition_version(id) on delete cascade,
  key text not null,
  from_state_key text not null,
  to_state_key text not null,
  guard_expression text,
  description text,
  is_reversible boolean not null default false,
  position integer not null default 0,
  constraint lifecycle_transition_definition_unique_key unique(lifecycle_definition_version_id, key)
);

-- Runtime: lifecycle instance binds a subject (object) to a lifecycle definition version
create table sca_core.lifecycle_instance (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null,
  object_type text not null,
  object_id uuid not null,
  lifecycle_definition_version_id uuid not null references sca_meta.lifecycle_definition_version(id),
  current_state_key text not null,
  current_state_instance_id uuid,
  is_retired boolean not null default false,
  created_at timestamptz not null default now(),
  created_by uuid,
  updated_at timestamptz not null default now(),
  updated_by uuid,
  constraint lifecycle_instance_unique_subject unique(organisation_id, object_type, object_id)
);

-- Runtime: state instances are immutable history records showing effective-dated state
create table sca_core.lifecycle_state_instance (
  id uuid primary key default gen_random_uuid(),
  lifecycle_instance_id uuid not null references sca_core.lifecycle_instance(id) on delete cascade,
  state_key text not null,
  effective_from timestamptz not null default now(),
  effective_to timestamptz,
  recorded_at timestamptz not null default now(),
  recorded_by uuid
);

create unique index lifecycle_state_instance_open_idx
  on sca_core.lifecycle_state_instance (lifecycle_instance_id)
  where effective_to is null;

-- Runtime: transition requests created by actors and must be evaluated before execution
create table sca_core.lifecycle_transition_request (
  id uuid primary key default gen_random_uuid(),
  request_id uuid, -- optional external id for idempotency
  lifecycle_instance_id uuid not null references sca_core.lifecycle_instance(id) on delete cascade,
  requested_transition_key text not null,
  requested_by uuid,
  requested_at timestamptz not null default now(),
  desired_effective_from timestamptz,
  expected_current_state_instance_id uuid, -- for stale-state detection
  status text not null default 'pending', -- pending, withdrawn, executed, rejected
  result_reason text,
  processed_at timestamptz
);

create unique index lifecycle_transition_request_request_id_uniq on sca_core.lifecycle_transition_request(request_id) where request_id is not null;

-- Runtime: evaluations of requests are separate records (immutable)
create table sca_core.lifecycle_transition_evaluation (
  id uuid primary key default gen_random_uuid(),
  transition_request_id uuid not null references sca_core.lifecycle_transition_request(id) on delete cascade,
  evaluator_id uuid,
  evaluated_at timestamptz not null default now(),
  approved boolean not null,
  reason text,
  evaluation_data jsonb
);

-- Runtime: transition events represent accepted and executed transitions
create table sca_core.lifecycle_transition_event (
  id uuid primary key default gen_random_uuid(),
  transition_request_id uuid not null references sca_core.lifecycle_transition_request(id) on delete cascade,
  lifecycle_instance_id uuid not null references sca_core.lifecycle_instance(id) on delete cascade,
  from_state_key text,
  to_state_key text,
  executed_by uuid,
  executed_at timestamptz not null default now(),
  effective_from timestamptz not null default now(),
  event_data jsonb
);

-- Audit: lifecycle events (append-only ledger)
create table sca_audit.lifecycle_event (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid,
  lifecycle_instance_id uuid,
  event_type text not null,
  actor_id uuid,
  occurred_at timestamptz not null default now(),
  event_data jsonb not null default '{}'::jsonb
);

-- Touch triggers for updated_at fields
create or replace function sca_core.touch_updated_at()
returns trigger
language plpgsql
security invoker
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

create trigger lifecycle_instance_touch_updated_at
before update on sca_core.lifecycle_instance
for each row execute function sca_core.touch_updated_at();

-- Append-only protection triggers: prevent UPDATE/DELETE on audit and immutable history
create or replace function sca_core.prevent_update_delete()
returns trigger
language plpgsql
security definer
as $$
begin
  raise exception 'table % is append-only; updates and deletes are disallowed', TG_TABLE_NAME;
  return null;
end;
$$;

create trigger prevent_update_delete_on_audit
before update or delete on sca_audit.lifecycle_event
for each row execute function sca_core.prevent_update_delete();

create trigger prevent_update_delete_on_state_instance
before update or delete on sca_core.lifecycle_state_instance
for each row execute function sca_core.prevent_update_delete();

create trigger prevent_update_delete_on_transition_evaluation
before update or delete on sca_core.lifecycle_transition_evaluation
for each row execute function sca_core.prevent_update_delete();

-- Comments
comment on table sca_meta.lifecycle_definition is 'Header record for a Lifecycle Definition; versions are immutable separate records.';
comment on table sca_meta.lifecycle_definition_version is 'Immutable published versions of lifecycle definitions (states & transitions are normalized into separate tables).';
comment on table sca_core.lifecycle_instance is 'Runtime binding of a subject to a lifecycle definition version, tracks current state.';
comment on table sca_core.lifecycle_state_instance is 'Immutable effective-dated state instances representing the state history of a lifecycle instance.';
comment on table sca_core.lifecycle_transition_request is 'Transition requests created by actors; must be evaluated and executed server-side to change state.';
comment on table sca_core.lifecycle_transition_event is 'Records of executed transitions; these drive state changes and are append-only.';
comment on table sca_audit.lifecycle_event is 'Append-only audit ledger for lifecycle-related events.';

commit;
