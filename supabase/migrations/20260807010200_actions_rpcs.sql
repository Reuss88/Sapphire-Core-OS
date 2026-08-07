begin;

create or replace function sca_core.action_has_capability(
  p_capability text,
  p_organisation_id uuid,
  p_team_id uuid default null
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select sca_identity.has_capability(
    p_capability,
    jsonb_strip_nulls(jsonb_build_object(
      'organisation_id', p_organisation_id,
      'team_id', p_team_id
    ))
  );
$$;

create or replace function sca_core.action_actor_is_active_member(
  p_organisation_id uuid,
  p_actor_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from sca_identity.actor a
    join sca_identity.organisation_membership om on om.actor_id = a.id
    join sca_identity.organisation o on o.id = om.organisation_id
    where a.id = p_actor_id
      and a.is_active
      and om.organisation_id = p_organisation_id
      and om.status = 'active'
      and om.effective_from <= now()
      and (om.effective_to is null or om.effective_to > now())
      and o.is_active
  );
$$;

create or replace function sca_core.action_actor_can_manage(
  p_organisation_id uuid,
  p_owner_actor_id uuid,
  p_team_id uuid default null,
  p_protected boolean default false,
  p_decision_class text default null,
  p_subject jsonb default '{}'::jsonb,
  p_limits jsonb default '{}'::jsonb,
  p_context jsonb default '{}'::jsonb
)
returns boolean
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_actor_id uuid := sca_identity.current_actor_id();
  v_context jsonb;
  v_can_manage boolean;
begin
  if v_actor_id is null
     or p_organisation_id <> sca_identity.current_organisation_id()
     or not sca_identity.is_org_member(p_organisation_id) then
    return false;
  end if;

  v_can_manage := p_owner_actor_id = v_actor_id
    or (
      sca_core.action_has_capability('actions.team.manage', p_organisation_id, p_team_id)
      and (p_team_id is null or sca_identity.can_access_team(p_team_id))
    );

  if not v_can_manage then
    return false;
  end if;
  if not p_protected then
    return true;
  end if;
  if nullif(trim(p_decision_class), '') is null then
    return false;
  end if;

  v_context := coalesce(p_context, '{}'::jsonb)
    || jsonb_build_object('organisation_id', p_organisation_id);
  return sca_governance.has_authority(
    p_decision_class,
    coalesce(p_subject, '{}'::jsonb),
    coalesce(p_limits, '{}'::jsonb),
    v_context
  );
end;
$$;

create or replace function sca_core.action_validate_transition(
  p_current sca_core.action_item_status,
  p_next sca_core.action_item_status
)
returns boolean
language sql
immutable
set search_path = ''
as $$
  select case
    when p_current = 'draft' then p_next in ('queued', 'cancelled')
    when p_current = 'queued' then p_next in ('ready', 'cancelled')
    when p_current = 'ready' then p_next in ('in_progress', 'cancelled')
    when p_current = 'in_progress' then p_next in ('waiting', 'blocked', 'completed', 'cancelled')
    when p_current = 'waiting' then p_next in ('ready', 'in_progress', 'cancelled')
    when p_current = 'blocked' then p_next in ('ready', 'in_progress', 'cancelled')
    else false
  end;
$$;

create or replace function sca_core.action_validate_mission_transition(
  p_current sca_core.action_mission_status,
  p_next sca_core.action_mission_status
)
returns boolean
language sql
immutable
set search_path = ''
as $$
  select case
    when p_current = 'planned' then p_next in ('active', 'cancelled')
    when p_current = 'active' then p_next in ('at_risk', 'blocked', 'completed', 'cancelled')
    when p_current = 'at_risk' then p_next in ('active', 'blocked', 'completed', 'cancelled')
    when p_current = 'blocked' then p_next in ('active', 'at_risk', 'cancelled')
    else false
  end;
$$;

create or replace function sca_core.action_compute_due_state(
  p_status sca_core.action_item_status,
  p_due_at timestamptz,
  p_now timestamptz default now()
)
returns text
language sql
stable
set search_path = ''
as $$
  select case
    when p_status = 'completed' then 'completed'
    when p_due_at is null then 'none'
    when p_status = 'cancelled' then 'none'
    when p_due_at < p_now then 'overdue'
    when p_due_at::date = p_now::date then 'due_today'
    else 'upcoming'
  end;
$$;

create or replace function sca_core.action_dependency_would_cycle(
  p_predecessor uuid,
  p_successor uuid
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  with recursive reachable(item_id) as (
    select p_successor
    union
    select d.successor_item_id
    from sca_core.action_dependency d
    join reachable r on r.item_id = d.predecessor_item_id
    where d.resolved_at is null
  )
  select p_predecessor = p_successor
    or exists (select 1 from reachable where item_id = p_predecessor);
$$;

create or replace function sca_core.action_compute_mission_health(p_mission_id uuid)
returns text
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(
    m.health_override,
    case
      when m.status = 'blocked'
        or coalesce(bool_or(i.status = 'blocked' and i.priority = 'critical'), false)
        then 'blocked'
      when m.status = 'at_risk'
        or count(*) filter (where sca_core.action_compute_due_state(i.status, i.due_at) = 'overdue') > 0
        or (
          m.target_at is not null
          and m.target_at < now() + interval '3 days'
          and count(*) filter (where i.status not in ('completed', 'cancelled')) > 0
        ) then 'at_risk'
      when count(*) filter (where i.status in ('waiting', 'blocked')) > 0 then 'attention'
      else 'healthy'
    end
  )
  from sca_core.action_mission m
  left join sca_core.action_item i on i.mission_id = m.id
  where m.id = p_mission_id
  group by m.id, m.health_override, m.status, m.target_at;
$$;

create or replace function sca_core.action_rank_score(
  p_action_item_id uuid,
  p_actor_context jsonb default '{}'::jsonb
)
returns numeric
language sql
stable
security definer
set search_path = ''
as $$
  select least(
    100,
    case i.priority when 'critical' then 45 when 'high' then 30 when 'normal' then 18 else 8 end
    + case sca_core.action_compute_due_state(i.status, i.due_at)
        when 'overdue' then 30 when 'due_today' then 22 when 'upcoming' then 8 else 0 end
    + case when i.status = 'blocked' then 18 when i.status = 'waiting' then 10 else 0 end
    + case when i.authority_required then 12 else 0 end
    + case when i.owner_actor_id is null then 8 else 0 end
    + case when coalesce((p_actor_context ->> 'director_lens')::boolean, false)
        and i.authority_required then 5 else 0 end
  )::numeric
  from sca_core.action_item i
  where i.id = p_action_item_id;
$$;

create or replace function sca_core.action_write_event(
  p_organisation_id uuid,
  p_mission_id uuid,
  p_action_item_id uuid,
  p_event_type text,
  p_payload jsonb default '{}'::jsonb,
  p_correlation_id uuid default null,
  p_causation_id uuid default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor_id uuid := sca_identity.current_actor_id();
  v_id uuid;
begin
  if v_actor_id is null or not sca_identity.is_org_member(p_organisation_id) then
    raise exception 'Authenticated organisation member required for Actions audit';
  end if;
  insert into sca_audit.action_event (
    organisation_id, mission_id, action_item_id, event_type, actor_id,
    payload, correlation_id, causation_id
  ) values (
    p_organisation_id, p_mission_id, p_action_item_id, p_event_type, v_actor_id,
    coalesce(p_payload, '{}'::jsonb), p_correlation_id, p_causation_id
  ) returning id into v_id;
  return v_id;
end;
$$;

create or replace function sca_core.actions_create_mission_v1(
  p_title text,
  p_objective text,
  p_owner_actor_id uuid default null,
  p_priority sca_core.action_priority default 'normal',
  p_target_at timestamptz default null,
  p_success_criteria jsonb default '[]'::jsonb,
  p_source_workspace text default 'actions',
  p_source_record_type text default null,
  p_source_record_id uuid default null,
  p_commercial_context jsonb default '{}'::jsonb,
  p_team_id uuid default null
)
returns sca_core.action_mission
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor_id uuid := sca_identity.current_actor_id();
  v_organisation_id uuid := sca_identity.current_organisation_id();
  v_owner_actor_id uuid := coalesce(p_owner_actor_id, sca_identity.current_actor_id());
  v_record sca_core.action_mission%rowtype;
begin
  if v_actor_id is null or v_organisation_id is null then
    raise exception 'Authenticated actor and organisation are required';
  end if;
  if not sca_core.action_has_capability('actions.create', v_organisation_id, p_team_id) then
    raise exception 'Actions create capability required';
  end if;
  if not sca_core.action_actor_is_active_member(v_organisation_id, v_owner_actor_id) then
    raise exception 'Mission owner must be an active organisation member';
  end if;
  if p_team_id is not null and not sca_identity.can_access_team(p_team_id) then
    raise exception 'Team is outside the actor scope';
  end if;
  if v_owner_actor_id <> v_actor_id
     and not sca_core.action_has_capability('actions.team.manage', v_organisation_id, p_team_id) then
    raise exception 'Cannot assign a mission to another actor';
  end if;
  if jsonb_typeof(coalesce(p_success_criteria, '[]'::jsonb)) <> 'array' then
    raise exception 'success_criteria must be an array';
  end if;

  insert into sca_core.action_mission (
    organisation_id, team_id, title, objective, priority, owner_actor_id, target_at,
    success_criteria, source_workspace, source_record_type, source_record_id,
    commercial_context, created_by_actor_id
  ) values (
    v_organisation_id, p_team_id, trim(p_title), trim(p_objective), p_priority,
    v_owner_actor_id, p_target_at, coalesce(p_success_criteria, '[]'::jsonb),
    lower(trim(p_source_workspace)), p_source_record_type, p_source_record_id,
    coalesce(p_commercial_context, '{}'::jsonb), v_actor_id
  ) returning * into v_record;

  insert into sca_core.action_assignment (
    organisation_id, mission_id, actor_id, assignment_role, assigned_by_actor_id
  ) values (
    v_organisation_id, v_record.id, v_owner_actor_id, 'owner', v_actor_id
  );
  perform sca_core.action_write_event(
    v_organisation_id, v_record.id, null, 'action_mission.created',
    jsonb_build_object('owner_actor_id', v_owner_actor_id, 'team_id', p_team_id)
  );
  return v_record;
end;
$$;

create or replace function sca_core.actions_update_mission_v1(
  p_mission_id uuid,
  p_title text default null,
  p_objective text default null,
  p_priority sca_core.action_priority default null,
  p_target_at timestamptz default null,
  p_success_criteria jsonb default null,
  p_status sca_core.action_mission_status default null
)
returns sca_core.action_mission
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_current sca_core.action_mission%rowtype;
  v_record sca_core.action_mission%rowtype;
begin
  select * into v_current from sca_core.action_mission where id = p_mission_id for update;
  if not found then raise exception 'Mission not found'; end if;
  if not sca_core.action_actor_can_manage(
    v_current.organisation_id, v_current.owner_actor_id, v_current.team_id
  ) then raise exception 'Mission update not permitted'; end if;
  if p_success_criteria is not null and jsonb_typeof(p_success_criteria) <> 'array' then
    raise exception 'success_criteria must be an array';
  end if;
  if p_status is not null and p_status <> v_current.status
     and not sca_core.action_validate_mission_transition(v_current.status, p_status) then
    raise exception 'Illegal mission transition: % -> %', v_current.status, p_status;
  end if;
  if p_status = 'completed' then
    if v_current.success_criteria = '[]'::jsonb then
      raise exception 'Mission success criteria are required for completion';
    end if;
    if exists (
      select 1 from sca_core.action_item i
      where i.mission_id = p_mission_id
        and i.priority = 'critical'
        and i.status not in ('completed', 'cancelled')
    ) then raise exception 'Open critical actions prevent mission completion'; end if;
  end if;

  update sca_core.action_mission set
    title = coalesce(nullif(trim(p_title), ''), title),
    objective = coalesce(nullif(trim(p_objective), ''), objective),
    priority = coalesce(p_priority, priority),
    target_at = coalesce(p_target_at, target_at),
    success_criteria = coalesce(p_success_criteria, success_criteria),
    status = coalesce(p_status, status),
    completed_at = case when p_status = 'completed' then now() else completed_at end,
    cancelled_at = case when p_status = 'cancelled' then now() else cancelled_at end
  where id = p_mission_id returning * into v_record;
  perform sca_core.action_write_event(
    v_record.organisation_id, v_record.id, null, 'action_mission.updated',
    jsonb_build_object('from_status', v_current.status, 'to_status', v_record.status)
  );
  return v_record;
end;
$$;

create or replace function sca_core.actions_create_item_v1(
  p_title text,
  p_required_outcome text,
  p_mission_id uuid default null,
  p_owner_actor_id uuid default null,
  p_item_kind sca_core.action_item_kind default 'task',
  p_priority sca_core.action_priority default 'normal',
  p_due_at timestamptz default null,
  p_description text default '',
  p_source_workspace text default 'actions',
  p_source_record_type text default null,
  p_source_record_id uuid default null,
  p_authority_required boolean default false,
  p_evidence_required boolean default false,
  p_creation_source text default 'user_created',
  p_team_id uuid default null,
  p_governance_reference_type text default null,
  p_governance_reference_id uuid default null,
  p_authority_decision_class text default null,
  p_authority_subject jsonb default '{}'::jsonb,
  p_authority_limits jsonb default '{}'::jsonb,
  p_authority_context jsonb default '{}'::jsonb
)
returns sca_core.action_item
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor_id uuid := sca_identity.current_actor_id();
  v_organisation_id uuid := sca_identity.current_organisation_id();
  v_owner_actor_id uuid := coalesce(p_owner_actor_id, sca_identity.current_actor_id());
  v_mission sca_core.action_mission%rowtype;
  v_team_id uuid := p_team_id;
  v_record sca_core.action_item%rowtype;
begin
  if v_actor_id is null or v_organisation_id is null then
    raise exception 'Authenticated actor and organisation are required';
  end if;
  if not sca_core.action_has_capability('actions.create', v_organisation_id, p_team_id) then
    raise exception 'Actions create capability required';
  end if;
  if not sca_core.action_actor_is_active_member(v_organisation_id, v_owner_actor_id) then
    raise exception 'Action owner must be an active organisation member';
  end if;
  if p_mission_id is not null then
    select * into v_mission from sca_core.action_mission where id = p_mission_id;
    if not found or v_mission.organisation_id <> v_organisation_id then
      raise exception 'Mission does not exist in current organisation';
    end if;
    v_team_id := coalesce(v_team_id, v_mission.team_id);
    if v_mission.team_id is not null and v_team_id is distinct from v_mission.team_id then
      raise exception 'Action team must match its mission team';
    end if;
  end if;
  if v_team_id is not null and not sca_identity.can_access_team(v_team_id) then
    raise exception 'Team is outside the actor scope';
  end if;
  if v_owner_actor_id <> v_actor_id
     and not sca_core.action_has_capability('actions.team.manage', v_organisation_id, v_team_id) then
    raise exception 'Cannot assign an action to another actor';
  end if;
  if p_authority_required and nullif(trim(p_authority_decision_class), '') is null then
    raise exception 'Protected action requires an Authority decision class';
  end if;
  if p_item_kind in ('approval_request', 'decision_request')
     and (p_governance_reference_type is null or p_governance_reference_id is null) then
    raise exception 'Governance-linked item requires an authoritative Governance reference';
  end if;

  insert into sca_core.action_item (
    organisation_id, team_id, mission_id, title, description, required_outcome,
    item_kind, status, priority, owner_actor_id, due_at, source_workspace,
    source_record_type, source_record_id, governance_reference_type,
    governance_reference_id, authority_required, authority_decision_class,
    authority_subject, authority_limits, authority_context, evidence_required,
    created_by_actor_id, creation_source
  ) values (
    v_organisation_id, v_team_id, p_mission_id, trim(p_title), coalesce(p_description, ''),
    trim(p_required_outcome), p_item_kind, 'draft', p_priority, v_owner_actor_id,
    p_due_at, lower(trim(p_source_workspace)), p_source_record_type, p_source_record_id,
    p_governance_reference_type, p_governance_reference_id, p_authority_required,
    p_authority_decision_class, coalesce(p_authority_subject, '{}'::jsonb),
    coalesce(p_authority_limits, '{}'::jsonb), coalesce(p_authority_context, '{}'::jsonb),
    p_evidence_required, v_actor_id, lower(trim(p_creation_source))
  ) returning * into v_record;

  insert into sca_core.action_assignment (
    organisation_id, action_item_id, actor_id, assignment_role, assigned_by_actor_id
  ) values (
    v_organisation_id, v_record.id, v_owner_actor_id, 'owner', v_actor_id
  );
  perform sca_core.action_write_event(
    v_organisation_id, p_mission_id, v_record.id, 'action_item.created',
    jsonb_build_object('owner_actor_id', v_owner_actor_id, 'creation_source', p_creation_source)
  );
  return v_record;
end;
$$;

create or replace function sca_core.actions_transition_item_v1(
  p_action_item_id uuid,
  p_next_status sca_core.action_item_status,
  p_reason text default null
)
returns sca_core.action_item
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_current sca_core.action_item%rowtype;
  v_record sca_core.action_item%rowtype;
begin
  select * into v_current from sca_core.action_item where id = p_action_item_id for update;
  if not found then raise exception 'Action item not found'; end if;
  if not sca_core.action_actor_can_manage(
    v_current.organisation_id, v_current.owner_actor_id, v_current.team_id,
    v_current.authority_required, v_current.authority_decision_class,
    v_current.authority_subject, v_current.authority_limits, v_current.authority_context
  ) then raise exception 'Action transition not permitted'; end if;
  if not sca_core.action_validate_transition(v_current.status, p_next_status) then
    raise exception 'Illegal action transition: % -> %', v_current.status, p_next_status;
  end if;
  if p_next_status in ('waiting', 'blocked', 'completed') then
    raise exception 'Use the dedicated waiting, blocked, or completion command';
  end if;

  update sca_core.action_item set
    status = p_next_status,
    started_at = case when p_next_status = 'in_progress' then coalesce(started_at, now()) else started_at end,
    cancelled_at = case when p_next_status = 'cancelled' then now() else null end,
    completed_at = null,
    waiting_reason = null,
    expected_resume_at = null,
    blocked_reason = null
  where id = p_action_item_id returning * into v_record;
  perform sca_core.action_write_event(
    v_record.organisation_id, v_record.mission_id, v_record.id,
    'action_item.transitioned',
    jsonb_build_object('from', v_current.status, 'to', p_next_status, 'reason', p_reason)
  );
  return v_record;
end;
$$;

create or replace function sca_core.actions_assign_item_v1(
  p_action_item_id uuid,
  p_owner_actor_id uuid
)
returns sca_core.action_item
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_current sca_core.action_item%rowtype;
  v_record sca_core.action_item%rowtype;
  v_actor_id uuid := sca_identity.current_actor_id();
begin
  select * into v_current from sca_core.action_item where id = p_action_item_id for update;
  if not found then raise exception 'Action item not found'; end if;
  if not sca_core.action_has_capability('actions.team.manage', v_current.organisation_id, v_current.team_id)
     or v_current.organisation_id <> sca_identity.current_organisation_id()
     or (v_current.team_id is not null and not sca_identity.can_access_team(v_current.team_id)) then
    raise exception 'Reassignment not permitted';
  end if;
  if not sca_core.action_actor_is_active_member(v_current.organisation_id, p_owner_actor_id) then
    raise exception 'New owner must be an active organisation member';
  end if;
  if v_current.authority_required and not sca_governance.has_authority(
    v_current.authority_decision_class,
    v_current.authority_subject,
    v_current.authority_limits,
    v_current.authority_context || jsonb_build_object('organisation_id', v_current.organisation_id)
  ) then raise exception 'Required governed authority is absent'; end if;

  update sca_core.action_item
  set owner_actor_id = p_owner_actor_id
  where id = p_action_item_id returning * into v_record;
  update sca_core.action_assignment
  set removed_at = now()
  where action_item_id = p_action_item_id
    and assignment_role = 'owner'
    and removed_at is null;
  insert into sca_core.action_assignment (
    organisation_id, action_item_id, actor_id, assignment_role, assigned_by_actor_id
  ) values (
    v_record.organisation_id, v_record.id, p_owner_actor_id, 'owner', v_actor_id
  );
  perform sca_core.action_write_event(
    v_record.organisation_id, v_record.mission_id, v_record.id,
    'action_item.assigned',
    jsonb_build_object('from', v_current.owner_actor_id, 'to', p_owner_actor_id)
  );
  return v_record;
end;
$$;

create or replace function sca_core.actions_set_due_at_v1(
  p_action_item_id uuid,
  p_due_at timestamptz,
  p_reason text default null
)
returns sca_core.action_item
language plpgsql security definer
set search_path = ''
as $$
declare v_current sca_core.action_item%rowtype; v_record sca_core.action_item%rowtype;
begin
  select * into v_current from sca_core.action_item where id = p_action_item_id for update;
  if not found or not sca_core.action_actor_can_manage(
    v_current.organisation_id, v_current.owner_actor_id, v_current.team_id,
    v_current.authority_required, v_current.authority_decision_class,
    v_current.authority_subject, v_current.authority_limits, v_current.authority_context
  ) then raise exception 'Due-date change not permitted'; end if;
  update sca_core.action_item set due_at = p_due_at where id = p_action_item_id returning * into v_record;
  perform sca_core.action_write_event(
    v_record.organisation_id, v_record.mission_id, v_record.id,
    'action_item.due_at_changed', jsonb_build_object('from', v_current.due_at, 'to', p_due_at, 'reason', p_reason)
  );
  return v_record;
end;
$$;

create or replace function sca_core.actions_set_priority_v1(
  p_action_item_id uuid,
  p_priority sca_core.action_priority,
  p_reason text default null
)
returns sca_core.action_item
language plpgsql security definer
set search_path = ''
as $$
declare v_current sca_core.action_item%rowtype; v_record sca_core.action_item%rowtype;
begin
  select * into v_current from sca_core.action_item where id = p_action_item_id for update;
  if not found or not sca_core.action_actor_can_manage(
    v_current.organisation_id, v_current.owner_actor_id, v_current.team_id
  ) then raise exception 'Priority change not permitted'; end if;
  update sca_core.action_item set priority = p_priority where id = p_action_item_id returning * into v_record;
  perform sca_core.action_write_event(
    v_record.organisation_id, v_record.mission_id, v_record.id,
    'action_item.priority_changed', jsonb_build_object('from', v_current.priority, 'to', p_priority, 'reason', p_reason)
  );
  return v_record;
end;
$$;

create or replace function sca_core.actions_set_waiting_v1(
  p_action_item_id uuid,
  p_reason text,
  p_expected_resume_at timestamptz default null
)
returns sca_core.action_item
language plpgsql security definer
set search_path = ''
as $$
declare v_current sca_core.action_item%rowtype; v_record sca_core.action_item%rowtype;
begin
  select * into v_current from sca_core.action_item where id = p_action_item_id for update;
  if not found or not sca_core.action_actor_can_manage(
    v_current.organisation_id, v_current.owner_actor_id, v_current.team_id,
    v_current.authority_required, v_current.authority_decision_class,
    v_current.authority_subject, v_current.authority_limits, v_current.authority_context
  ) then raise exception 'Waiting transition not permitted'; end if;
  if not sca_core.action_validate_transition(v_current.status, 'waiting') then
    raise exception 'Illegal action transition: % -> waiting', v_current.status;
  end if;
  if nullif(trim(p_reason), '') is null then raise exception 'Waiting reason is required'; end if;
  update sca_core.action_item
  set status = 'waiting', waiting_reason = trim(p_reason),
      expected_resume_at = p_expected_resume_at, blocked_reason = null
  where id = p_action_item_id returning * into v_record;
  perform sca_core.action_write_event(
    v_record.organisation_id, v_record.mission_id, v_record.id,
    'action_item.waiting', jsonb_build_object('reason', p_reason, 'expected_resume_at', p_expected_resume_at)
  );
  return v_record;
end;
$$;

create or replace function sca_core.actions_set_blocked_v1(
  p_action_item_id uuid,
  p_reason text
)
returns sca_core.action_item
language plpgsql security definer
set search_path = ''
as $$
declare v_current sca_core.action_item%rowtype; v_record sca_core.action_item%rowtype;
begin
  select * into v_current from sca_core.action_item where id = p_action_item_id for update;
  if not found or not sca_core.action_actor_can_manage(
    v_current.organisation_id, v_current.owner_actor_id, v_current.team_id,
    v_current.authority_required, v_current.authority_decision_class,
    v_current.authority_subject, v_current.authority_limits, v_current.authority_context
  ) then raise exception 'Blocked transition not permitted'; end if;
  if not sca_core.action_validate_transition(v_current.status, 'blocked') then
    raise exception 'Illegal action transition: % -> blocked', v_current.status;
  end if;
  if nullif(trim(p_reason), '') is null then raise exception 'Blocker reason is required'; end if;
  update sca_core.action_item
  set status = 'blocked', blocked_reason = trim(p_reason),
      waiting_reason = null, expected_resume_at = null
  where id = p_action_item_id returning * into v_record;
  perform sca_core.action_write_event(
    v_record.organisation_id, v_record.mission_id, v_record.id,
    'action_item.blocked', jsonb_build_object('reason', p_reason)
  );
  return v_record;
end;
$$;

create or replace function sca_core.actions_add_dependency_v1(
  p_predecessor_item_id uuid,
  p_successor_item_id uuid,
  p_dependency_type text default 'finish_to_start'
)
returns sca_core.action_dependency
language plpgsql security definer
set search_path = ''
as $$
declare
  v_predecessor sca_core.action_item%rowtype;
  v_successor sca_core.action_item%rowtype;
  v_record sca_core.action_dependency%rowtype;
begin
  select * into v_predecessor from sca_core.action_item where id = p_predecessor_item_id;
  select * into v_successor from sca_core.action_item where id = p_successor_item_id for update;
  if v_predecessor.id is null or v_successor.id is null
     or v_predecessor.organisation_id <> v_successor.organisation_id then
    raise exception 'Dependencies require two actions in one organisation';
  end if;
  if not sca_core.action_actor_can_manage(
    v_successor.organisation_id, v_successor.owner_actor_id, v_successor.team_id,
    v_successor.authority_required, v_successor.authority_decision_class,
    v_successor.authority_subject, v_successor.authority_limits, v_successor.authority_context
  ) then raise exception 'Dependency change not permitted'; end if;
  if sca_core.action_dependency_would_cycle(p_predecessor_item_id, p_successor_item_id) then
    raise exception 'Dependency would create a cycle';
  end if;
  insert into sca_core.action_dependency (
    organisation_id, predecessor_item_id, successor_item_id, dependency_type, created_by_actor_id
  ) values (
    v_successor.organisation_id, p_predecessor_item_id, p_successor_item_id,
    p_dependency_type, sca_identity.current_actor_id()
  ) returning * into v_record;
  perform sca_core.action_write_event(
    v_successor.organisation_id, v_successor.mission_id, v_successor.id,
    'action_item.dependency_added', jsonb_build_object('predecessor_item_id', p_predecessor_item_id)
  );
  return v_record;
end;
$$;

create or replace function sca_core.actions_remove_dependency_v1(p_dependency_id uuid)
returns void
language plpgsql security definer
set search_path = ''
as $$
declare
  v_dependency sca_core.action_dependency%rowtype;
  v_item sca_core.action_item%rowtype;
begin
  select * into v_dependency from sca_core.action_dependency where id = p_dependency_id for update;
  if not found then raise exception 'Dependency not found'; end if;
  select * into v_item from sca_core.action_item where id = v_dependency.successor_item_id;
  if not sca_core.action_actor_can_manage(
    v_item.organisation_id, v_item.owner_actor_id, v_item.team_id,
    v_item.authority_required, v_item.authority_decision_class,
    v_item.authority_subject, v_item.authority_limits, v_item.authority_context
  ) then raise exception 'Dependency change not permitted'; end if;
  delete from sca_core.action_dependency where id = p_dependency_id;
  perform sca_core.action_write_event(
    v_item.organisation_id, v_item.mission_id, v_item.id,
    'action_item.dependency_removed', jsonb_build_object('predecessor_item_id', v_dependency.predecessor_item_id)
  );
end;
$$;

create or replace function sca_core.actions_link_record_v1(
  p_action_item_id uuid,
  p_linked_type text,
  p_linked_id uuid,
  p_source_workspace text,
  p_link_role text default 'context'
)
returns sca_core.action_link
language plpgsql security definer
set search_path = ''
as $$
declare v_item sca_core.action_item%rowtype; v_record sca_core.action_link%rowtype;
begin
  select * into v_item from sca_core.action_item where id = p_action_item_id;
  if not found or not sca_core.action_actor_can_manage(
    v_item.organisation_id, v_item.owner_actor_id, v_item.team_id
  ) then raise exception 'Record link not permitted'; end if;
  insert into sca_core.action_link (
    organisation_id, action_item_id, linked_type, linked_id, link_role,
    source_workspace, created_by_actor_id
  ) values (
    v_item.organisation_id, v_item.id, p_linked_type, p_linked_id,
    trim(p_link_role), lower(trim(p_source_workspace)), sca_identity.current_actor_id()
  ) returning * into v_record;
  perform sca_core.action_write_event(
    v_item.organisation_id, v_item.mission_id, v_item.id,
    'action_item.record_linked', jsonb_build_object('linked_type', p_linked_type, 'linked_id', p_linked_id)
  );
  return v_record;
end;
$$;

create or replace function sca_core.actions_add_evidence_v1(
  p_action_item_id uuid,
  p_evidence_type text,
  p_linked_type text default null,
  p_linked_id uuid default null,
  p_note text default null
)
returns sca_core.action_evidence
language plpgsql security definer
set search_path = ''
as $$
declare v_item sca_core.action_item%rowtype; v_record sca_core.action_evidence%rowtype;
begin
  select * into v_item from sca_core.action_item where id = p_action_item_id;
  if not found or not sca_core.action_actor_can_manage(
    v_item.organisation_id, v_item.owner_actor_id, v_item.team_id
  ) then raise exception 'Evidence addition not permitted'; end if;
  insert into sca_core.action_evidence (
    organisation_id, action_item_id, evidence_type, linked_type, linked_id,
    note, supplied_by_actor_id
  ) values (
    v_item.organisation_id, v_item.id, p_evidence_type, p_linked_type,
    p_linked_id, p_note, sca_identity.current_actor_id()
  ) returning * into v_record;
  perform sca_core.action_write_event(
    v_item.organisation_id, v_item.mission_id, v_item.id,
    'action_item.evidence_added', jsonb_build_object('evidence_id', v_record.id, 'evidence_type', p_evidence_type)
  );
  return v_record;
end;
$$;

create or replace function sca_core.actions_complete_item_v1(
  p_action_item_id uuid,
  p_completion_note text default null
)
returns sca_core.action_item
language plpgsql security definer
set search_path = ''
as $$
declare
  v_current sca_core.action_item%rowtype;
  v_record sca_core.action_item%rowtype;
  v_evidence_count integer;
begin
  select * into v_current from sca_core.action_item where id = p_action_item_id for update;
  if not found or not sca_core.action_actor_can_manage(
    v_current.organisation_id, v_current.owner_actor_id, v_current.team_id,
    v_current.authority_required, v_current.authority_decision_class,
    v_current.authority_subject, v_current.authority_limits, v_current.authority_context
  ) then raise exception 'Completion not permitted'; end if;
  if v_current.item_kind in ('approval_request', 'decision_request') then
    raise exception 'Governance-linked approval or decision must be resolved by its authoritative Governance command';
  end if;
  if not sca_core.action_validate_transition(v_current.status, 'completed') then
    raise exception 'Illegal action transition: % -> completed', v_current.status;
  end if;
  select count(*) into v_evidence_count
  from sca_core.action_evidence where action_item_id = p_action_item_id;
  if v_current.evidence_required and v_evidence_count = 0 then
    raise exception 'Completion evidence is required';
  end if;
  if exists (
    select 1 from sca_core.action_dependency
    where successor_item_id = p_action_item_id and resolved_at is null
  ) then raise exception 'Unresolved dependencies prevent completion'; end if;
  update sca_core.action_item
  set status = 'completed', completed_at = now(), cancelled_at = null,
      waiting_reason = null, expected_resume_at = null, blocked_reason = null
  where id = p_action_item_id returning * into v_record;
  update sca_core.action_dependency
  set resolved_at = now()
  where predecessor_item_id = p_action_item_id and resolved_at is null;
  perform sca_core.action_write_event(
    v_record.organisation_id, v_record.mission_id, v_record.id,
    'action_item.completed', jsonb_build_object('completion_note', p_completion_note, 'evidence_count', v_evidence_count)
  );
  return v_record;
end;
$$;

create or replace function sca_core.actions_reopen_item_v1(
  p_action_item_id uuid,
  p_reason text
)
returns sca_core.action_item
language plpgsql security definer
set search_path = ''
as $$
declare v_current sca_core.action_item%rowtype; v_record sca_core.action_item%rowtype;
begin
  select * into v_current from sca_core.action_item where id = p_action_item_id for update;
  if not found or v_current.status <> 'completed' then
    raise exception 'Only a completed action can be reopened';
  end if;
  if nullif(trim(p_reason), '') is null then raise exception 'Reopen reason is required'; end if;
  if not sca_core.action_actor_can_manage(
    v_current.organisation_id, v_current.owner_actor_id, v_current.team_id,
    v_current.authority_required, v_current.authority_decision_class,
    v_current.authority_subject, v_current.authority_limits, v_current.authority_context
  ) then raise exception 'Reopen not permitted'; end if;
  update sca_core.action_item set status = 'in_progress', completed_at = null
  where id = p_action_item_id returning * into v_record;
  perform sca_core.action_write_event(
    v_record.organisation_id, v_record.mission_id, v_record.id,
    'action_item.reopened', jsonb_build_object('reason', p_reason)
  );
  return v_record;
end;
$$;

create or replace function sca_core.actions_cancel_item_v1(
  p_action_item_id uuid,
  p_reason text
)
returns sca_core.action_item
language plpgsql security definer
set search_path = ''
as $$
declare v_current sca_core.action_item%rowtype; v_record sca_core.action_item%rowtype;
begin
  select * into v_current from sca_core.action_item where id = p_action_item_id for update;
  if not found or not sca_core.action_actor_can_manage(
    v_current.organisation_id, v_current.owner_actor_id, v_current.team_id,
    v_current.authority_required, v_current.authority_decision_class,
    v_current.authority_subject, v_current.authority_limits, v_current.authority_context
  ) then raise exception 'Cancellation not permitted'; end if;
  if not sca_core.action_validate_transition(v_current.status, 'cancelled') then
    raise exception 'Illegal cancellation from %', v_current.status;
  end if;
  if nullif(trim(p_reason), '') is null then raise exception 'Cancellation reason is required'; end if;
  update sca_core.action_item
  set status = 'cancelled', cancelled_at = now(), completed_at = null,
      waiting_reason = null, expected_resume_at = null, blocked_reason = null
  where id = p_action_item_id returning * into v_record;
  perform sca_core.action_write_event(
    v_record.organisation_id, v_record.mission_id, v_record.id,
    'action_item.cancelled', jsonb_build_object('reason', p_reason)
  );
  return v_record;
end;
$$;

create or replace function sca_core.actions_get_my_queue_v1(
  p_lens text default 'my_actions',
  p_query text default null,
  p_limit integer default 50,
  p_cursor_score numeric default null,
  p_cursor_id uuid default null
)
returns table (
  id uuid, title text, required_outcome text, item_kind sca_core.action_item_kind,
  status sca_core.action_item_status, priority sca_core.action_priority,
  owner_actor_id uuid, due_at timestamptz, due_state text, mission_id uuid,
  mission_title text, source_workspace text, blocked_reason text, waiting_reason text,
  authority_required boolean, evidence_required boolean, rank_score numeric,
  rank_factors jsonb, updated_at timestamptz
)
language sql stable security invoker
set search_path = ''
as $$
  with ranked as (
    select i.*, m.title as mission_title,
      sca_core.action_compute_due_state(i.status, i.due_at) as due_state,
      sca_core.action_rank_score(
        i.id,
        jsonb_build_object(
          'director_lens',
          sca_core.action_has_capability('actions.director.view', i.organisation_id, i.team_id)
        )
      ) as rank_score
    from sca_core.action_item i
    left join sca_core.action_mission m on m.id = i.mission_id
    where i.organisation_id = sca_identity.current_organisation_id()
      and (
        (p_lens = 'my_actions' and i.owner_actor_id = sca_identity.current_actor_id())
        or (
          p_lens = 'team'
          and (
            sca_core.action_has_capability('actions.team.read', i.organisation_id, i.team_id)
            or sca_core.action_has_capability('actions.director.view', i.organisation_id, i.team_id)
          )
        )
        or (p_lens = 'approvals_decisions' and i.item_kind in ('approval_request', 'decision_request'))
        or (p_lens = 'waiting_on' and i.status = 'waiting')
        or (p_lens = 'overdue' and sca_core.action_compute_due_state(i.status, i.due_at) = 'overdue')
        or (p_lens = 'completed' and i.status = 'completed')
      )
      and (
        p_query is null or i.title ilike '%' || p_query || '%'
        or i.required_outcome ilike '%' || p_query || '%'
        or m.title ilike '%' || p_query || '%'
      )
  )
  select r.id, r.title, r.required_outcome, r.item_kind, r.status, r.priority,
    r.owner_actor_id, r.due_at, r.due_state, r.mission_id, r.mission_title,
    r.source_workspace, r.blocked_reason, r.waiting_reason, r.authority_required,
    r.evidence_required, r.rank_score,
    jsonb_path_query_array(
      jsonb_build_array(
        case when r.priority = 'critical' then 'Critical commercial priority' end,
        case when r.due_state = 'overdue' then 'Overdue' when r.due_state = 'due_today' then 'Due today' end,
        case when r.status = 'blocked' then 'Blocked execution' when r.status = 'waiting' then 'Waiting on external condition' end,
        case when r.authority_required then 'Authority required' end
      ),
      '$[*] ? (@ != null)'
    ),
    r.updated_at
  from ranked r
  where p_cursor_score is null or (r.rank_score, r.id) < (p_cursor_score, p_cursor_id)
  order by r.rank_score desc, r.id
  limit greatest(1, least(coalesce(p_limit, 50), 100));
$$;

create or replace function sca_core.actions_get_director_queue_v1(p_limit integer default 50)
returns setof sca_core.action_item
language plpgsql stable security invoker
set search_path = ''
as $$
begin
  if not sca_core.action_has_capability(
    'actions.director.view', sca_identity.current_organisation_id(), null
  ) then raise exception 'Director queue capability required'; end if;
  return query
  select i.* from sca_core.action_item i
  where i.organisation_id = sca_identity.current_organisation_id()
    and i.status not in ('completed', 'cancelled')
    and (i.priority = 'critical' or i.authority_required or i.owner_actor_id is null or i.status = 'blocked')
  order by sca_core.action_rank_score(i.id, '{"director_lens":true}'::jsonb) desc, i.id
  limit greatest(1, least(coalesce(p_limit, 50), 100));
end;
$$;

create or replace function sca_core.actions_get_missions_v1(p_include_terminal boolean default false)
returns table (
  id uuid, title text, objective text, status sca_core.action_mission_status,
  priority sca_core.action_priority, owner_actor_id uuid, target_at timestamptz,
  health text, progress_percent numeric, open_action_count bigint,
  blocker_count bigint, commercial_context jsonb, updated_at timestamptz
)
language sql stable security invoker
set search_path = ''
as $$
  select m.id, m.title, m.objective, m.status, m.priority, m.owner_actor_id, m.target_at,
    sca_core.action_compute_mission_health(m.id),
    coalesce(round(100.0 * count(i.id) filter (where i.status = 'completed') / nullif(count(i.id), 0)), 0),
    count(i.id) filter (where i.status not in ('completed', 'cancelled')),
    count(i.id) filter (where i.status = 'blocked'),
    m.commercial_context, m.updated_at
  from sca_core.action_mission m
  left join sca_core.action_item i on i.mission_id = m.id
  where m.organisation_id = sca_identity.current_organisation_id()
    and (p_include_terminal or m.status not in ('completed', 'cancelled'))
  group by m.id
  order by m.priority, m.target_at nulls last, m.id;
$$;

create or replace function sca_core.actions_get_mission_detail_v1(p_mission_id uuid)
returns jsonb
language sql stable security invoker
set search_path = ''
as $$
  select jsonb_build_object(
    'mission', to_jsonb(m),
    'health', sca_core.action_compute_mission_health(m.id),
    'actions', coalesce((
      select jsonb_agg(to_jsonb(i) order by i.priority, i.due_at nulls last)
      from sca_core.action_item i where i.mission_id = m.id
    ), '[]'::jsonb),
    'assignments', coalesce((
      select jsonb_agg(to_jsonb(a)) from sca_core.action_assignment a
      where a.mission_id = m.id and a.removed_at is null
    ), '[]'::jsonb),
    'links', coalesce((
      select jsonb_agg(to_jsonb(l)) from sca_core.action_link l where l.mission_id = m.id
    ), '[]'::jsonb),
    'timeline', coalesce((
      select jsonb_agg(to_jsonb(e) order by e.occurred_at desc)
      from (select * from sca_audit.action_event where mission_id = m.id order by occurred_at desc limit 100) e
    ), '[]'::jsonb)
  )
  from sca_core.action_mission m
  where m.id = p_mission_id;
$$;

create or replace function sca_core.actions_get_item_detail_v1(p_action_item_id uuid)
returns jsonb
language sql stable security invoker
set search_path = ''
as $$
  select jsonb_build_object(
    'item', to_jsonb(i),
    'due_state', sca_core.action_compute_due_state(i.status, i.due_at),
    'rank_score', sca_core.action_rank_score(i.id, '{}'::jsonb),
    'assignments', coalesce((
      select jsonb_agg(to_jsonb(a)) from sca_core.action_assignment a
      where a.action_item_id = i.id and a.removed_at is null
    ), '[]'::jsonb),
    'dependencies', coalesce((
      select jsonb_agg(to_jsonb(d)) from sca_core.action_dependency d
      where d.predecessor_item_id = i.id or d.successor_item_id = i.id
    ), '[]'::jsonb),
    'links', coalesce((
      select jsonb_agg(to_jsonb(l)) from sca_core.action_link l where l.action_item_id = i.id
    ), '[]'::jsonb),
    'evidence', coalesce((
      select jsonb_agg(to_jsonb(ev)) from sca_core.action_evidence ev where ev.action_item_id = i.id
    ), '[]'::jsonb),
    'timeline', coalesce((
      select jsonb_agg(to_jsonb(ae) order by ae.occurred_at desc)
      from (select * from sca_audit.action_event where action_item_id = i.id order by occurred_at desc limit 100) ae
    ), '[]'::jsonb)
  )
  from sca_core.action_item i
  where i.id = p_action_item_id;
$$;

create or replace function sca_core.actions_get_team_load_v1()
returns table (
  owner_actor_id uuid, open_count bigint, overdue_count bigint,
  blocked_count bigint, critical_count bigint
)
language plpgsql stable security invoker
set search_path = ''
as $$
begin
  if not (
    sca_core.action_has_capability('actions.team.read', sca_identity.current_organisation_id(), null)
    or sca_core.action_has_capability('actions.director.view', sca_identity.current_organisation_id(), null)
  ) then raise exception 'Team workload capability required'; end if;
  return query
  select i.owner_actor_id,
    count(*) filter (where i.status not in ('completed', 'cancelled')),
    count(*) filter (where sca_core.action_compute_due_state(i.status, i.due_at) = 'overdue'),
    count(*) filter (where i.status = 'blocked'),
    count(*) filter (where i.priority = 'critical' and i.status not in ('completed', 'cancelled'))
  from sca_core.action_item i
  where i.organisation_id = sca_identity.current_organisation_id()
  group by i.owner_actor_id;
end;
$$;

revoke all on function sca_core.action_has_capability(text, uuid, uuid) from public;
revoke all on function sca_core.action_actor_is_active_member(uuid, uuid) from public;
revoke all on function sca_core.action_actor_can_manage(uuid, uuid, uuid, boolean, text, jsonb, jsonb, jsonb) from public;
revoke all on function sca_core.action_validate_transition(sca_core.action_item_status, sca_core.action_item_status) from public;
revoke all on function sca_core.action_validate_mission_transition(sca_core.action_mission_status, sca_core.action_mission_status) from public;
revoke all on function sca_core.action_dependency_would_cycle(uuid, uuid) from public;
revoke all on function sca_core.action_write_event(uuid, uuid, uuid, text, jsonb, uuid, uuid) from public;
revoke all on function sca_core.actions_create_mission_v1(text, text, uuid, sca_core.action_priority, timestamptz, jsonb, text, text, uuid, jsonb, uuid) from public;
revoke all on function sca_core.actions_update_mission_v1(uuid, text, text, sca_core.action_priority, timestamptz, jsonb, sca_core.action_mission_status) from public;
revoke all on function sca_core.actions_create_item_v1(text, text, uuid, uuid, sca_core.action_item_kind, sca_core.action_priority, timestamptz, text, text, text, uuid, boolean, boolean, text, uuid, text, uuid, text, jsonb, jsonb, jsonb) from public;
revoke all on function sca_core.actions_transition_item_v1(uuid, sca_core.action_item_status, text) from public;
revoke all on function sca_core.actions_assign_item_v1(uuid, uuid) from public;
revoke all on function sca_core.actions_set_due_at_v1(uuid, timestamptz, text) from public;
revoke all on function sca_core.actions_set_priority_v1(uuid, sca_core.action_priority, text) from public;
revoke all on function sca_core.actions_set_waiting_v1(uuid, text, timestamptz) from public;
revoke all on function sca_core.actions_set_blocked_v1(uuid, text) from public;
revoke all on function sca_core.actions_add_dependency_v1(uuid, uuid, text) from public;
revoke all on function sca_core.actions_remove_dependency_v1(uuid) from public;
revoke all on function sca_core.actions_link_record_v1(uuid, text, uuid, text, text) from public;
revoke all on function sca_core.actions_add_evidence_v1(uuid, text, text, uuid, text) from public;
revoke all on function sca_core.actions_complete_item_v1(uuid, text) from public;
revoke all on function sca_core.actions_reopen_item_v1(uuid, text) from public;
revoke all on function sca_core.actions_cancel_item_v1(uuid, text) from public;

grant execute on function sca_core.action_has_capability(text, uuid, uuid) to authenticated;
grant execute on function sca_core.actions_get_my_queue_v1(text, text, integer, numeric, uuid) to authenticated;
grant execute on function sca_core.actions_get_director_queue_v1(integer) to authenticated;
grant execute on function sca_core.actions_get_missions_v1(boolean) to authenticated;
grant execute on function sca_core.actions_get_mission_detail_v1(uuid) to authenticated;
grant execute on function sca_core.actions_get_item_detail_v1(uuid) to authenticated;
grant execute on function sca_core.actions_get_team_load_v1() to authenticated;

grant execute on function sca_core.actions_create_mission_v1(text, text, uuid, sca_core.action_priority, timestamptz, jsonb, text, text, uuid, jsonb, uuid) to authenticated;
grant execute on function sca_core.actions_update_mission_v1(uuid, text, text, sca_core.action_priority, timestamptz, jsonb, sca_core.action_mission_status) to authenticated;
grant execute on function sca_core.actions_create_item_v1(text, text, uuid, uuid, sca_core.action_item_kind, sca_core.action_priority, timestamptz, text, text, text, uuid, boolean, boolean, text, uuid, text, uuid, text, jsonb, jsonb, jsonb) to authenticated;
grant execute on function sca_core.actions_transition_item_v1(uuid, sca_core.action_item_status, text) to authenticated;
grant execute on function sca_core.actions_assign_item_v1(uuid, uuid) to authenticated;
grant execute on function sca_core.actions_set_due_at_v1(uuid, timestamptz, text) to authenticated;
grant execute on function sca_core.actions_set_priority_v1(uuid, sca_core.action_priority, text) to authenticated;
grant execute on function sca_core.actions_set_waiting_v1(uuid, text, timestamptz) to authenticated;
grant execute on function sca_core.actions_set_blocked_v1(uuid, text) to authenticated;
grant execute on function sca_core.actions_add_dependency_v1(uuid, uuid, text) to authenticated;
grant execute on function sca_core.actions_remove_dependency_v1(uuid) to authenticated;
grant execute on function sca_core.actions_link_record_v1(uuid, text, uuid, text, text) to authenticated;
grant execute on function sca_core.actions_add_evidence_v1(uuid, text, text, uuid, text) to authenticated;
grant execute on function sca_core.actions_complete_item_v1(uuid, text) to authenticated;
grant execute on function sca_core.actions_reopen_item_v1(uuid, text) to authenticated;
grant execute on function sca_core.actions_cancel_item_v1(uuid, text) to authenticated;

comment on function sca_core.action_actor_can_manage(uuid, uuid, uuid, boolean, text, jsonb, jsonb, jsonb) is
  'Combines canonical membership and software capability with Authority Rule/Grant evaluation for protected work. Assignment is not consulted.';

commit;
