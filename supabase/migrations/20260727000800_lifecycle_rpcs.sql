begin;

set search_path = pg_catalog, public, sca_meta;

-- RPC: add new lifecycle definition header
create or replace function sca_core.add_lifecycle_definition(
  p_type_key text,
  p_canonical_name text,
  p_description text,
  p_actor_id uuid default null
)
returns uuid
language plpgsql
security definer
as $$
declare v_id uuid;
begin
  if nullif(trim(p_type_key),'') is null then
    raise exception 'type_key is required';
  end if;

  insert into sca_meta.lifecycle_definition (type_key, canonical_name, description, created_by)
  values (lower(trim(p_type_key)), trim(p_canonical_name), trim(p_description), p_actor_id)
  returning id into v_id;

  return v_id;
end;
$$;

-- RPC: add lifecycle definition version
create or replace function sca_core.add_lifecycle_definition_version(
  p_lifecycle_definition_id uuid,
  p_version_no bigint,
  p_name text,
  p_description text,
  p_actor_id uuid default null
)
returns uuid
language plpgsql
security definer
as $$
declare v_id uuid;
begin
  if p_lifecycle_definition_id is null then
    raise exception 'lifecycle_definition_id is required';
  end if;

  insert into sca_meta.lifecycle_definition_version (lifecycle_definition_id, version_no, name, description, recorded_by)
  values (p_lifecycle_definition_id, p_version_no, trim(p_name), trim(p_description), p_actor_id)
  returning id into v_id;

  return v_id;
end;
$$;

-- RPC: add applicability
create or replace function sca_core.add_lifecycle_applicability(
  p_lifecycle_definition_id uuid,
  p_organisation_id uuid default null,
  p_object_family text default null,
  p_object_type text default null,
  p_actor_id uuid default null
)
returns uuid
language plpgsql
security definer
as $$
declare v_id uuid;
begin
  insert into sca_meta.lifecycle_applicability (lifecycle_definition_id, organisation_id, object_family, object_type, created_by)
  values (p_lifecycle_definition_id, p_organisation_id, p_object_family, p_object_type, p_actor_id)
  returning id into v_id;

  return v_id;
end;
$$;

-- RPC: add state definition
create or replace function sca_core.add_lifecycle_state_definition(
  p_lifecycle_definition_version_id uuid,
  p_key text,
  p_name text,
  p_description text default null,
  p_is_terminal boolean default false,
  p_position integer default 0
)
returns uuid
language plpgsql
security definer
as $$
declare v_id uuid;
begin
  insert into sca_meta.lifecycle_state_definition (lifecycle_definition_version_id, key, name, description, is_terminal, position)
  values (p_lifecycle_definition_version_id, lower(trim(p_key)), trim(p_name), p_description, p_is_terminal, p_position)
  returning id into v_id;

  return v_id;
end;
$$;

-- RPC: add transition definition
create or replace function sca_core.add_lifecycle_transition_definition(
  p_lifecycle_definition_version_id uuid,
  p_key text,
  p_from_state_key text,
  p_to_state_key text,
  p_guard_expression text default null,
  p_description text default null,
  p_is_reversible boolean default false,
  p_position integer default 0
)
returns uuid
language plpgsql
security definer
as $$
declare v_id uuid;
begin
  insert into sca_meta.lifecycle_transition_definition (lifecycle_definition_version_id, key, from_state_key, to_state_key, guard_expression, description, is_reversible, position)
  values (p_lifecycle_definition_version_id, lower(trim(p_key)), lower(trim(p_from_state_key)), lower(trim(p_to_state_key)), p_guard_expression, p_description, p_is_reversible, p_position)
  returning id into v_id;

  return v_id;
end;
$$;

-- RPC: publish lifecycle definition version (marks version as published and updates header)
create or replace function sca_core.publish_lifecycle_definition_version(
  p_lifecycle_definition_version_id uuid,
  p_actor_id uuid default null
)
returns void
language plpgsql
security definer
as $$
declare v_def_id uuid;
begin
  select lifecycle_definition_id into v_def_id
  from sca_meta.lifecycle_definition_version
  where id = p_lifecycle_definition_version_id;

  if v_def_id is null then
    raise exception 'lifecycle_definition_version not found';
  end if;

  update sca_meta.lifecycle_definition_version
    set published = true
  where id = p_lifecycle_definition_version_id;

  update sca_meta.lifecycle_definition
    set current_published_version_id = p_lifecycle_definition_version_id,
        updated_at = now(),
        updated_by = p_actor_id
    where id = v_def_id;
end;
$$;

-- Runtime RPCs
set search_path = pg_catalog, public, sca_core;

-- create lifecycle instance for a subject. Initializes state instance using the lifecycle version's first state (by position)
create or replace function sca_core.create_lifecycle_instance(
  p_organisation_id uuid,
  p_object_type text,
  p_object_id uuid,
  p_lifecycle_definition_version_id uuid,
  p_actor_id uuid default null
)
returns uuid
language plpgsql
security definer
as $$
declare
  v_instance_id uuid;
  v_initial_state_key text;
  v_initial_state_id uuid;
begin
  if p_organisation_id is null then
    raise exception 'organisation_id is required';
  end if;

  select key into v_initial_state_key
  from sca_meta.lifecycle_state_definition
  where lifecycle_definition_version_id = p_lifecycle_definition_version_id
  order by position asc
  limit 1;

  if v_initial_state_key is null then
    raise exception 'lifecycle version has no state definitions';
  end if;

  insert into sca_core.lifecycle_instance (organisation_id, object_type, object_id, lifecycle_definition_version_id, current_state_key, created_by)
  values (p_organisation_id, lower(trim(p_object_type)), p_object_id, p_lifecycle_definition_version_id, v_initial_state_key, p_actor_id)
  returning id into v_instance_id;

  insert into sca_core.lifecycle_state_instance (lifecycle_instance_id, state_key, effective_from, recorded_by)
  values (v_instance_id, v_initial_state_key, now(), p_actor_id)
  returning id into v_initial_state_id;

  update sca_core.lifecycle_instance set current_state_instance_id = v_initial_state_id where id = v_instance_id;

  return v_instance_id;
end;
$$;

-- create transition request (idempotent by request_id)
create or replace function sca_core.create_lifecycle_transition_request(
  p_request_id uuid,
  p_lifecycle_instance_id uuid,
  p_requested_transition_key text,
  p_requested_by uuid default null,
  p_desired_effective_from timestamptz default null,
  p_expected_current_state_instance_id uuid default null
)
returns uuid
language plpgsql
security definer
as $$
declare v_id uuid;
begin
  if p_request_id is not null then
    select id into v_id from sca_core.lifecycle_transition_request where request_id = p_request_id;
    if v_id is not null then
      return v_id; -- idempotent
    end if;
  end if;

  insert into sca_core.lifecycle_transition_request (
    request_id,
    lifecycle_instance_id,
    requested_transition_key,
    requested_by,
    requested_at,
    desired_effective_from,
    expected_current_state_instance_id
  ) values (
    p_request_id,
    p_lifecycle_instance_id,
    lower(trim(p_requested_transition_key)),
    p_requested_by,
    now(),
    p_desired_effective_from,
    p_expected_current_state_instance_id
  ) returning id into v_id;

  return v_id;
end;
$$;

-- evaluate transition request (records an evaluation)
create or replace function sca_core.evaluate_lifecycle_transition_request(
  p_transition_request_id uuid,
  p_evaluator_id uuid,
  p_approved boolean,
  p_reason text default null,
  p_evaluation_data jsonb default '{}'::jsonb
)
returns uuid
language plpgsql
security definer
as $$
declare v_id uuid;
begin
  insert into sca_core.lifecycle_transition_evaluation (transition_request_id, evaluator_id, approved, reason, evaluation_data)
  values (p_transition_request_id, p_evaluator_id, p_approved, p_reason, p_evaluation_data)
  returning id into v_id;

  return v_id;
end;
$$;

-- execute transition: atomic; idempotent by transition_request; enforces published lifecycle, evaluation approval, stale-state protection
create or replace function sca_core.execute_lifecycle_transition(
  p_transition_request_id uuid,
  p_executor_id uuid
)
returns uuid
language plpgsql
security definer
as $$
declare
  v_req record;
  v_eval record;
  v_instance record;
  v_current_state_instance record;
  v_transition_ldv record;
  v_to_state_key text;
  v_new_state_instance_id uuid;
  v_event_id uuid;
begin
  -- lock request
  select * into v_req from sca_core.lifecycle_transition_request where id = p_transition_request_id for update;
  if not found then
    raise exception 'transition request not found';
  end if;

  if v_req.status = 'executed' then
    -- idempotent: return existing event if exists
    select id into v_event_id from sca_core.lifecycle_transition_event where transition_request_id = p_transition_request_id limit 1;
    if v_event_id is not null then
      return v_event_id;
    else
{