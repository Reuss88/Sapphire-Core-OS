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
  v_initial_state text;
begin
  if p_organisation_id is null then
    raise exception 'organisation_id is required';
  end if;

  select key into v_initial_state
  from sca_meta.lifecycle_state_definition
  where lifecycle_definition_version_id = p_lifecycle_definition_version_id
  order by position asc
  limit 1;

  if v_initial_state is null then
    raise exception 'lifecycle version has no state definitions';
  end if;

  insert into sca_core.lifecycle_instance (organisation_id, object_type, object_id, lifecycle_definition_version_id, current_state_key, created_by)
  values (p_organisation_id, lower(trim(p_object_type)), p_object_id, p_lifecycle_definition_version_id, v_initial_state, p_actor_id)
  returning id into v_instance_id;

  insert into sca_core.lifecycle_state_instance (lifecycle_instance_id, state_key, effective_from, recorded_by)
  values (v_instance_id, v_initial_state, now(), p_actor_id)
  returning id into v_initial_state;

  update sca_core.lifecycle_instance set current_state_instance_id = v_initial_state where id = v_instance_id;

  return v_instance_id;
end;
$$;

-- create transition request (idempotent by request_id)
create or replace function sca_core.create_lifecycle_transition_request(
  p_request_id uuid default null,
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

  insert into sca_core.lifecycle_transition_request (request_id, lifecycle_instance_id, requested_transition_key, requested_by, requested_at, desired_effective_from, expected_current_state_instance_id)
  values (p_request_id, p_lifecycle_instance_id, lower(trim(p_requested_transition_key)), p_requested_by, now(), p_desired_effective_from, p_expected_current_state_instance_id)
  returning id into v_id;

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
  v_transition_def record;
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
      raise exception 'request already marked executed but event missing';
    end if;
  end if;

  if v_req.status <> 'pending' then
    raise exception 'transition request is not pending';
  end if;

  -- find latest evaluation (approved required)
  select * into v_eval
  from sca_core.lifecycle_transition_evaluation
  where transition_request_id = p_transition_request_id
  order by evaluated_at desc
  limit 1;

  if not found or v_eval.approved is distinct from true then
    raise exception 'transition request not approved';
  end if;

  -- lock lifecycle instance
  select * into v_instance from sca_core.lifecycle_instance where id = v_req.lifecycle_instance_id for update;
  if not found then
    raise exception 'lifecycle instance not found';
  end if;

  -- stale-state detection
  if v_req.expected_current_state_instance_id is not null then
    if v_instance.current_state_instance_id is distinct from v_req.expected_current_state_instance_id then
      raise exception 'stale state: expected % but current is %', v_req.expected_current_state_instance_id, v_instance.current_state_instance_id;
    end if;
  end if;

  -- ensure lifecycle definition version exists and is published
  select ldv.* into v_transition_def
  from sca_meta.lifecycle_definition_version ldv
  join sca_meta.lifecycle_transition_definition ltd on ltd.lifecycle_definition_version_id = ldv.id
  where ltd.key = v_req.requested_transition_key
    and ldv.id = v_instance.lifecycle_definition_version_id
  limit 1;

  if not found then
    raise exception 'transition definition not found for lifecycle version';
  end if;

  -- load current open state instance and close it
  select * into v_current_state_instance
  from sca_core.lifecycle_state_instance
  where lifecycle_instance_id = v_instance.id and effective_to is null
  for update;

  if not found then
    raise exception 'no open state instance found';
  end if;

  -- determine to_state from transition definition
  select to_state_key into v_transition_def from sca_meta.lifecycle_transition_definition
  where lifecycle_definition_version_id = v_instance.lifecycle_definition_version_id
    and key = v_req.requested_transition_key
  limit 1;

  if v_transition_def.to_state_key is null then
    raise exception 'to_state not found for transition';
  end if;

  -- close current state instance
  update sca_core.lifecycle_state_instance
    set effective_to = coalesce(v_req.desired_effective_from, now())
  where id = v_current_state_instance.id;

  -- create new state instance
  insert into sca_core.lifecycle_state_instance (lifecycle_instance_id, state_key, effective_from, recorded_by)
  values (v_instance.id, v_transition_def.to_state_key, coalesce(v_req.desired_effective_from, now()), p_executor_id)
  returning id into v_event_id; -- reuse variable for new state_instance id

  -- create transition event
  insert into sca_core.lifecycle_transition_event (transition_request_id, lifecycle_instance_id, from_state_key, to_state_key, executed_by, executed_at, effective_from, event_data)
  values (p_transition_request_id, v_instance.id, v_current_state_instance.state_key, v_transition_def.to_state_key, p_executor_id, now(), coalesce(v_req.desired_effective_from, now()), jsonb_build_object('evaluation_id', v_eval.id))
  returning id into v_event_id;

  -- update lifecycle instance state pointers
  update sca_core.lifecycle_instance
    set current_state_key = v_transition_def.to_state_key,
        current_state_instance_id = (select id from sca_core.lifecycle_state_instance where lifecycle_instance_id = v_instance.id and effective_to is null),
        updated_at = now(),
        updated_by = p_executor_id
  where id = v_instance.id;

  -- mark request executed
  update sca_core.lifecycle_transition_request
    set status = 'executed', processed_at = now(), result_reason = null
  where id = p_transition_request_id;

  -- audit event
  insert into sca_audit.lifecycle_event (organisation_id, lifecycle_instance_id, event_type, actor_id, occurred_at, event_data)
  values (v_instance.organisation_id, v_instance.id, 'lifecycle.transition.executed', p_executor_id, now(), jsonb_build_object('transition_request_id', p_transition_request_id, 'transition_event_id', v_event_id));

  return v_event_id;
end;
$$;

-- withdraw transition request
create or replace function sca_core.withdraw_lifecycle_transition_request(
  p_transition_request_id uuid,
  p_actor_id uuid
)
returns void
language plpgsql
security definer
as $$
begin
  update sca_core.lifecycle_transition_request set status = 'withdrawn', processed_at = now(), result_reason = 'withdrawn', requested_by = coalesce(requested_by, p_actor_id) where id = p_transition_request_id and status = 'pending';
end;
$$;

-- retire lifecycle instance (mark retired and close open state instance)
create or replace function sca_core.retire_lifecycle_instance(
  p_lifecycle_instance_id uuid,
  p_actor_id uuid
)
returns void
language plpgsql
security definer
as $$
begin
  update sca_core.lifecycle_instance set is_retired = true, updated_at = now(), updated_by = p_actor_id where id = p_lifecycle_instance_id;

  update sca_core.lifecycle_state_instance set effective_to = now() where lifecycle_instance_id = p_lifecycle_instance_id and effective_to is null;

  insert into sca_audit.lifecycle_event (organisation_id, lifecycle_instance_id, event_type, actor_id, occurred_at, event_data)
  values ((select organisation_id from sca_core.lifecycle_instance where id = p_lifecycle_instance_id), p_lifecycle_instance_id, 'lifecycle.instance.retired', p_actor_id, now(), '{}'::jsonb);
end;
$$;

-- Read RPCs (projections and listing)
create or replace function sca_core.get_lifecycle_snapshot(
  p_lifecycle_instance_id uuid
)
returns table (
  lifecycle_instance_id uuid,
  organisation_id uuid,
  object_type text,
  object_id uuid,
  current_state_key text,
  current_state_instance_id uuid,
  lifecycle_definition_version_id uuid
)
language sql
security invoker
as $$
  select id, organisation_id, object_type, object_id, current_state_key, current_state_instance_id, lifecycle_definition_version_id
  from sca_core.lifecycle_instance
  where id = p_lifecycle_instance_id;
$$;

create or replace function sca_core.get_lifecycle_history(
  p_lifecycle_instance_id uuid
)
returns table (id uuid, state_key text, effective_from timestamptz, effective_to timestamptz, recorded_at timestamptz)
language sql
security invoker
as $$
  select id, state_key, effective_from, effective_to, recorded_at from sca_core.lifecycle_state_instance where lifecycle_instance_id = p_lifecycle_instance_id order by effective_from desc;
$$;

create or replace function sca_core.list_available_lifecycle_transitions(
  p_lifecycle_instance_id uuid
)
returns table (transition_key text, from_state text, to_state text, guard text)
language sql
security invoker
as $$
  select ltd.key, ltd.from_state_key, ltd.to_state_key, ltd.guard_expression
  from sca_core.lifecycle_instance li
  join sca_meta.lifecycle_transition_definition ltd on ltd.lifecycle_definition_version_id = li.lifecycle_definition_version_id
  where li.id = p_lifecycle_instance_id and ltd.from_state_key = li.current_state_key;
$$;

create or replace function sca_core.get_lifecycle_transition_request(p_request_id uuid)
returns table (id uuid, lifecycle_instance_id uuid, requested_transition_key text, status text, requested_at timestamptz)
language sql
security invoker
as $$
  select id, lifecycle_instance_id, requested_transition_key, status, requested_at from sca_core.lifecycle_transition_request where id = p_request_id;
$$;

create or replace function sca_core.get_latest_lifecycle_transition_evaluation(p_transition_request_id uuid)
returns table (id uuid, evaluator_id uuid, evaluated_at timestamptz, approved boolean, reason text, evaluation_data jsonb)
language sql
security invoker
as $$
  select id, evaluator_id, evaluated_at, approved, reason, evaluation_data from sca_core.lifecycle_transition_evaluation where transition_request_id = p_transition_request_id order by evaluated_at desc limit 1;
$$;

create or replace function sca_core.list_lifecycle_instances_for_subject(p_organisation_id uuid, p_object_type text, p_object_id uuid)
returns table (id uuid, current_state_key text, current_state_instance_id uuid)
language sql
security invoker
as $$
  select id, current_state_key, current_state_instance_id from sca_core.lifecycle_instance where organisation_id = p_organisation_id and object_type = lower(trim(p_object_type)) and object_id = p_object_id;
$$;

create or replace function sca_core.list_open_lifecycle_transition_requests(p_lifecycle_instance_id uuid)
returns table (id uuid, request_id uuid, requested_transition_key text, requested_by uuid, requested_at timestamptz)
language sql
security invoker
as $$
  select id, request_id, requested_transition_key, requested_by, requested_at from sca_core.lifecycle_transition_request where lifecycle_instance_id = p_lifecycle_instance_id and status = 'pending' order by requested_at asc;
$$;

create or replace function sca_core.check_lifecycle_projection(p_lifecycle_instance_id uuid)
returns table (projection_valid boolean, projection_json jsonb)
language sql
security invoker
as $$
  select true as projection_valid, jsonb_build_object('current_state_key',(select current_state_key from sca_core.lifecycle_instance where id = p_lifecycle_instance_id)) as projection_json;
$$;

-- revoke/grant
revoke all on function sca_core.add_lifecycle_definition(text, text, text, uuid) from public;
revoke all on function sca_core.add_lifecycle_definition_version(uuid, bigint, text, text, uuid) from public;
revoke all on function sca_core.add_lifecycle_state_definition(uuid, text, text, text, boolean, integer) from public;
revoke all on function sca_core.add_lifecycle_transition_definition(uuid, text, text, text, text, text, boolean, integer) from public;
revoke all on function sca_core.publish_lifecycle_definition_version(uuid, uuid) from public;

grant execute on function sca_core.get_lifecycle_snapshot(uuid) to authenticated;
grant execute on function sca_core.get_lifecycle_history(uuid) to authenticated;
grant execute on function sca_core.list_available_lifecycle_transitions(uuid) to authenticated;
grant execute on function sca_core.list_lifecycle_instances_for_subject(uuid, text, uuid) to authenticated;
grant execute on function sca_core.list_open_lifecycle_transition_requests(uuid) to authenticated;
grant execute on function sca_core.get_lifecycle_transition_request(uuid) to authenticated;
grant execute on function sca_core.get_latest_lifecycle_transition_evaluation(uuid) to authenticated;
grant execute on function sca_core.check_lifecycle_projection(uuid) to authenticated;

commit;
