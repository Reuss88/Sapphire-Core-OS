begin;

alter table sca_core.action_item
  add column completion_outcome_required boolean not null default false;

alter table sca_core.action_link drop constraint action_link_linked_type_check;
alter table sca_core.action_link add constraint action_link_linked_type_check
  check (linked_type in (
    'profile', 'person', 'company', 'demand', 'supply', 'opportunity',
    'match', 'deal', 'document', 'inbox_thread', 'market_signal',
    'finance_record', 'approval', 'decision', 'activity', 'other'
  ));

create or replace function sca_core.activity_write_event(
  p_organisation_id uuid,
  p_activity_id uuid,
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
    raise exception 'Authenticated organisation member required for Activity audit';
  end if;
  insert into sca_audit.activity_event (
    organisation_id, activity_id, event_type, actor_id, payload,
    correlation_id, causation_id
  ) values (
    p_organisation_id, p_activity_id, p_event_type, v_actor_id,
    coalesce(p_payload, '{}'::jsonb), p_correlation_id, p_causation_id
  ) returning id into v_id;
  return v_id;
end;
$$;

create or replace function sca_core.activity_create_v1(
  p_activity_type sca_core.activity_type,
  p_body text,
  p_visibility_scope sca_core.activity_visibility_scope,
  p_primary_subject_type text,
  p_primary_subject_id uuid,
  p_structured_content jsonb default '{}'::jsonb,
  p_occurred_at timestamptz default now(),
  p_source_workspace text default 'activity',
  p_source_record_type text default null,
  p_source_record_id uuid default null,
  p_outcome_classification text default null,
  p_provenance_kind sca_core.provenance_kind default 'human_entry',
  p_provenance_ref text default null,
  p_workspace_team_id uuid default null,
  p_audience_actor_ids uuid[] default '{}'::uuid[],
  p_links jsonb default '[]'::jsonb
)
returns sca_core.activity
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor_id uuid := sca_identity.current_actor_id();
  v_organisation_id uuid := sca_identity.current_organisation_id();
  v_subject_organisation_id uuid;
  v_subject_team_id uuid;
  v_activity sca_core.activity%rowtype;
  v_audience_actor_id uuid;
  v_link jsonb;
begin
  if v_actor_id is null or v_organisation_id is null then
    raise exception 'Authenticated actor and organisation are required';
  end if;
  if not sca_identity.has_capability(
    'activity.create', jsonb_build_object('organisation_id', v_organisation_id)
  ) then raise exception 'Activity create capability required'; end if;
  if nullif(trim(p_body), '') is null then raise exception 'Activity body is required'; end if;
  if jsonb_typeof(coalesce(p_structured_content, '{}'::jsonb)) <> 'object' then
    raise exception 'structured_content must be an object';
  end if;
  if jsonb_typeof(coalesce(p_links, '[]'::jsonb)) <> 'array' then
    raise exception 'Activity links must be an array';
  end if;

  v_subject_organisation_id := sca_core.activity_subject_organisation_id(
    p_primary_subject_type, p_primary_subject_id
  );
  if v_subject_organisation_id is null or v_subject_organisation_id <> v_organisation_id then
    raise exception 'Activity subject must exist in the current organisation';
  end if;
  if not sca_core.activity_actor_can_view_subject(p_primary_subject_type, p_primary_subject_id) then
    raise exception 'Activity subject is not visible to the actor';
  end if;

  if p_activity_type in ('instruction', 'coaching_note')
     or p_visibility_scope = 'director_only' then
    if not sca_identity.has_capability(
      'activity.director', jsonb_build_object('organisation_id', v_organisation_id)
    ) then raise exception 'Director Activity capability required'; end if;
  end if;

  v_subject_team_id := sca_core.activity_subject_team_id(
    p_primary_subject_type, p_primary_subject_id
  );
  if p_visibility_scope = 'mission_team'
     and (v_subject_team_id is null or not sca_identity.can_access_team(v_subject_team_id)) then
    raise exception 'Mission-team visibility requires an accessible mission team';
  end if;
  if p_visibility_scope = 'workspace_team' then
    if p_workspace_team_id is null
       or not sca_identity.can_access_team(p_workspace_team_id)
       or not sca_identity.has_capability(
         'activity.workspace.read',
         jsonb_build_object(
           'organisation_id', v_organisation_id,
           'team_id', p_workspace_team_id
         )
       ) then raise exception 'Workspace-team visibility is not permitted'; end if;
  elsif p_workspace_team_id is not null then
    raise exception 'workspace_team_id is only valid for workspace_team visibility';
  end if;

  insert into sca_core.activity (
    organisation_id, actor_id, activity_type, occurred_at, body,
    structured_content, visibility_scope, primary_subject_type,
    primary_subject_id, workspace_team_id, source_workspace,
    source_record_type, source_record_id, outcome_classification,
    provenance_kind, provenance_ref
  ) values (
    v_organisation_id, v_actor_id, p_activity_type, coalesce(p_occurred_at, now()),
    trim(p_body), coalesce(p_structured_content, '{}'::jsonb), p_visibility_scope,
    p_primary_subject_type, p_primary_subject_id, p_workspace_team_id,
    lower(trim(p_source_workspace)), p_source_record_type, p_source_record_id,
    nullif(trim(p_outcome_classification), ''), p_provenance_kind,
    nullif(trim(p_provenance_ref), '')
  ) returning * into v_activity;

  foreach v_audience_actor_id in array coalesce(p_audience_actor_ids, '{}'::uuid[])
  loop
    if not sca_core.action_actor_is_active_member(v_organisation_id, v_audience_actor_id) then
      raise exception 'Activity audience actor must be an active organisation member';
    end if;
    insert into sca_core.activity_audience_actor (
      organisation_id, activity_id, actor_id, added_by_actor_id
    ) values (
      v_organisation_id, v_activity.id, v_audience_actor_id, v_actor_id
    ) on conflict do nothing;
  end loop;

  for v_link in select value from jsonb_array_elements(coalesce(p_links, '[]'::jsonb))
  loop
    if jsonb_typeof(v_link) <> 'object'
       or nullif(trim(v_link ->> 'linked_type'), '') is null
       or nullif(trim(v_link ->> 'linked_id'), '') is null
       or nullif(trim(v_link ->> 'source_workspace'), '') is null then
      raise exception 'Each Activity link requires linked_type, linked_id, and source_workspace';
    end if;
    insert into sca_core.activity_link (
      organisation_id, activity_id, linked_type, linked_id, link_role,
      source_workspace, created_by_actor_id
    ) values (
      v_organisation_id, v_activity.id, v_link ->> 'linked_type',
      (v_link ->> 'linked_id')::uuid, coalesce(nullif(trim(v_link ->> 'link_role'), ''), 'context'),
      lower(trim(v_link ->> 'source_workspace')), v_actor_id
    );
  end loop;

  perform sca_core.activity_write_event(
    v_organisation_id, v_activity.id, 'activity.created',
    jsonb_build_object(
      'activity_type', p_activity_type,
      'visibility_scope', p_visibility_scope,
      'primary_subject_type', p_primary_subject_type,
      'primary_subject_id', p_primary_subject_id,
      'provenance_kind', p_provenance_kind
    )
  );
  return v_activity;
end;
$$;

create or replace function sca_core.activity_update_v1(
  p_activity_id uuid,
  p_body text,
  p_structured_content jsonb default '{}'::jsonb,
  p_outcome_classification text default null,
  p_reason text default 'clarification'
)
returns sca_core.activity
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor_id uuid := sca_identity.current_actor_id();
  v_current sca_core.activity%rowtype;
  v_record sca_core.activity%rowtype;
  v_can_manage boolean;
begin
  select * into v_current from sca_core.activity where id = p_activity_id for update;
  if not found or v_current.organisation_id <> sca_identity.current_organisation_id() then
    raise exception 'Activity not found';
  end if;
  v_can_manage := sca_identity.has_capability(
    'activity.manage', jsonb_build_object('organisation_id', v_current.organisation_id)
  );
  if v_current.actor_id <> v_actor_id and not v_can_manage then
    raise exception 'Activity correction not permitted';
  end if;
  if not v_can_manage and v_current.created_at < now() - interval '15 minutes' then
    raise exception 'Actor correction window has expired';
  end if;
  if v_current.lifecycle_status <> 'published' then
    raise exception 'Only published Activity can be corrected';
  end if;
  if nullif(trim(p_body), '') is null or nullif(trim(p_reason), '') is null then
    raise exception 'Corrected body and reason are required';
  end if;
  if jsonb_typeof(coalesce(p_structured_content, '{}'::jsonb)) <> 'object' then
    raise exception 'structured_content must be an object';
  end if;

  update sca_core.activity set
    body = trim(p_body),
    structured_content = coalesce(p_structured_content, '{}'::jsonb),
    outcome_classification = nullif(trim(p_outcome_classification), '')
  where id = p_activity_id returning * into v_record;
  perform sca_core.activity_write_event(
    v_record.organisation_id, v_record.id, 'activity.corrected',
    jsonb_build_object(
      'reason', p_reason,
      'before_hash', md5(v_current.body || v_current.structured_content::text),
      'after_hash', md5(v_record.body || v_record.structured_content::text)
    )
  );
  return v_record;
end;
$$;

create or replace function sca_core.activity_withdraw_v1(
  p_activity_id uuid,
  p_reason text
)
returns sca_core.activity
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor_id uuid := sca_identity.current_actor_id();
  v_current sca_core.activity%rowtype;
  v_record sca_core.activity%rowtype;
begin
  select * into v_current from sca_core.activity where id = p_activity_id for update;
  if not found or v_current.organisation_id <> sca_identity.current_organisation_id() then
    raise exception 'Activity not found';
  end if;
  if v_current.actor_id <> v_actor_id and not sca_identity.has_capability(
    'activity.manage', jsonb_build_object('organisation_id', v_current.organisation_id)
  ) then raise exception 'Activity withdrawal not permitted'; end if;
  if v_current.lifecycle_status <> 'published' then
    raise exception 'Only published Activity can be withdrawn';
  end if;
  if nullif(trim(p_reason), '') is null then raise exception 'Withdrawal reason is required'; end if;

  update sca_core.activity set
    lifecycle_status = 'withdrawn', retired_at = now(),
    retired_by_actor_id = v_actor_id, retirement_reason = trim(p_reason)
  where id = p_activity_id returning * into v_record;
  perform sca_core.activity_write_event(
    v_record.organisation_id, v_record.id, 'activity.withdrawn',
    jsonb_build_object('reason', p_reason)
  );
  return v_record;
end;
$$;

create or replace function sca_core.activity_redact_v1(
  p_activity_id uuid,
  p_reason text
)
returns sca_core.activity
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor_id uuid := sca_identity.current_actor_id();
  v_current sca_core.activity%rowtype;
  v_record sca_core.activity%rowtype;
begin
  select * into v_current from sca_core.activity where id = p_activity_id for update;
  if not found or v_current.organisation_id <> sca_identity.current_organisation_id() then
    raise exception 'Activity not found';
  end if;
  if not sca_identity.has_capability(
    'activity.manage', jsonb_build_object('organisation_id', v_current.organisation_id)
  ) then raise exception 'Activity redaction capability required'; end if;
  if v_current.lifecycle_status = 'redacted' then raise exception 'Activity is already redacted'; end if;
  if nullif(trim(p_reason), '') is null then raise exception 'Redaction reason is required'; end if;

  update sca_core.activity set
    body = '[Redacted commercial Activity]', structured_content = '{}'::jsonb,
    outcome_classification = null, lifecycle_status = 'redacted', retired_at = now(),
    retired_by_actor_id = v_actor_id, retirement_reason = trim(p_reason)
  where id = p_activity_id returning * into v_record;
  perform sca_core.activity_write_event(
    v_record.organisation_id, v_record.id, 'activity.redacted',
    jsonb_build_object(
      'reason', p_reason,
      'redacted_content_hash', md5(v_current.body || v_current.structured_content::text)
    )
  );
  return v_record;
end;
$$;

create or replace function sca_core.activity_get_work_journal_v1(
  p_subject_type text,
  p_subject_id uuid,
  p_limit integer default 100,
  p_before_at timestamptz default null,
  p_before_id uuid default null
)
returns table (
  entry_kind text,
  entry_id uuid,
  occurred_at timestamptz,
  actor_id uuid,
  entry_type text,
  visibility_scope text,
  body text,
  structured_content jsonb,
  source_workspace text,
  provenance_kind text,
  links jsonb
)
language plpgsql
stable
security invoker
set search_path = ''
as $$
begin
  if p_subject_type not in ('mission', 'action_item') then
    raise exception 'Work Journal supports mission or action_item subjects';
  end if;
  if not sca_core.activity_actor_can_view_subject(p_subject_type, p_subject_id) then
    raise exception 'Work Journal subject is not visible to the actor';
  end if;

  return query
  with journal as (
    select
      'activity'::text as entry_kind,
      a.id as entry_id,
      a.occurred_at,
      a.actor_id,
      a.activity_type::text as entry_type,
      a.visibility_scope::text as visibility_scope,
      case
        when a.lifecycle_status = 'redacted' then '[Redacted commercial Activity]'
        else a.body
      end as body,
      a.structured_content,
      a.source_workspace,
      a.provenance_kind::text as provenance_kind,
      coalesce((
        select jsonb_agg(jsonb_build_object(
          'linked_type', al.linked_type,
          'linked_id', al.linked_id,
          'link_role', al.link_role,
          'source_workspace', al.source_workspace
        ) order by al.created_at, al.id)
        from sca_core.activity_link al where al.activity_id = a.id
      ), '[]'::jsonb) as links
    from sca_core.activity a
    where a.lifecycle_status <> 'withdrawn'
      and (
        (a.primary_subject_type = p_subject_type and a.primary_subject_id = p_subject_id)
        or exists (
          select 1 from sca_core.activity_link al
          where al.activity_id = a.id
            and al.linked_type = p_subject_type
            and al.linked_id = p_subject_id
        )
      )

    union all

    select
      'execution_event'::text,
      ae.id,
      ae.occurred_at,
      ae.actor_id,
      ae.event_type,
      null::text,
      replace(replace(ae.event_type, 'action_item.', ''), '_', ' '),
      ae.payload,
      'actions'::text,
      'system_calculation'::text,
      '[]'::jsonb
    from sca_audit.action_event ae
    where (p_subject_type = 'mission' and ae.mission_id = p_subject_id)
       or (p_subject_type = 'action_item' and ae.action_item_id = p_subject_id)

    union all

    select
      'evidence'::text,
      ev.id,
      ev.created_at,
      ev.supplied_by_actor_id,
      ev.evidence_type,
      null::text,
      coalesce(ev.note, 'Evidence reference added'),
      jsonb_strip_nulls(jsonb_build_object(
        'linked_type', ev.linked_type,
        'linked_id', ev.linked_id,
        'evidence_type', ev.evidence_type
      )),
      'actions'::text,
      'human_entry'::text,
      case when ev.linked_id is null then '[]'::jsonb else jsonb_build_array(
        jsonb_build_object('linked_type', ev.linked_type, 'linked_id', ev.linked_id, 'link_role', 'evidence')
      ) end
    from sca_core.action_evidence ev
    join sca_core.action_item i on i.id = ev.action_item_id
    where (p_subject_type = 'action_item' and ev.action_item_id = p_subject_id)
       or (p_subject_type = 'mission' and i.mission_id = p_subject_id)
  )
  select j.entry_kind, j.entry_id, j.occurred_at, j.actor_id, j.entry_type,
    j.visibility_scope, j.body, j.structured_content, j.source_workspace,
    j.provenance_kind, j.links
  from journal j
  where p_before_at is null or (j.occurred_at, j.entry_id) < (p_before_at, p_before_id)
  order by j.occurred_at desc, j.entry_id desc
  limit greatest(1, least(coalesce(p_limit, 100), 200));
end;
$$;

create or replace function sca_core.activity_create_follow_up_action_v1(
  p_activity_id uuid,
  p_title text,
  p_required_outcome text,
  p_owner_actor_id uuid default null,
  p_due_at timestamptz default null,
  p_priority sca_core.action_priority default 'normal'
)
returns sca_core.action_item
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_activity sca_core.activity%rowtype;
  v_original_item sca_core.action_item%rowtype;
  v_original_mission sca_core.action_mission%rowtype;
  v_mission_id uuid;
  v_team_id uuid;
  v_follow_up sca_core.action_item%rowtype;
begin
  select * into v_activity from sca_core.activity where id = p_activity_id;
  if not found or not sca_core.activity_actor_can_view(v_activity.id) then
    raise exception 'Activity is not visible to the actor';
  end if;
  if v_activity.activity_type not in (
    'call_attempt', 'call_connected', 'research_update', 'outcome',
    'status_update', 'handoff', 'message_summary', 'escalation_note'
  ) then raise exception 'This Activity type cannot originate a follow-up Action'; end if;

  if v_activity.primary_subject_type = 'action_item' then
    select * into v_original_item
    from sca_core.action_item where id = v_activity.primary_subject_id;
    if not found then raise exception 'Original Action subject not found'; end if;
    v_mission_id := v_original_item.mission_id;
    v_team_id := v_original_item.team_id;
  elsif v_activity.primary_subject_type = 'mission' then
    select * into v_original_mission
    from sca_core.action_mission where id = v_activity.primary_subject_id;
    if not found then raise exception 'Original Mission subject not found'; end if;
    v_mission_id := v_original_mission.id;
    v_team_id := v_original_mission.team_id;
  else
    raise exception 'Follow-up Actions require a Mission or Action Item Activity subject';
  end if;

  v_follow_up := sca_core.actions_create_item_v1(
    p_title, p_required_outcome, v_mission_id, p_owner_actor_id,
    'follow_up', p_priority, p_due_at, '', 'activity', 'activity',
    v_activity.id, false, false, 'activity_follow_up', v_team_id
  );

  insert into sca_core.action_link (
    organisation_id, action_item_id, linked_type, linked_id, link_role,
    source_workspace, created_by_actor_id
  ) values (
    v_follow_up.organisation_id, v_follow_up.id, 'activity', v_activity.id,
    'originating_activity', 'activity', sca_identity.current_actor_id()
  );
  insert into sca_core.activity_link (
    organisation_id, activity_id, linked_type, linked_id, link_role,
    source_workspace, created_by_actor_id
  ) values (
    v_activity.organisation_id, v_activity.id, 'action_item', v_follow_up.id,
    'follow_up_action', 'actions', sca_identity.current_actor_id()
  );
  perform sca_core.activity_write_event(
    v_activity.organisation_id, v_activity.id, 'activity.follow_up_created',
    jsonb_build_object('action_item_id', v_follow_up.id)
  );
  return v_follow_up;
end;
$$;

create or replace function sca_core.actions_set_completion_policy_v1(
  p_action_item_id uuid,
  p_completion_outcome_required boolean,
  p_evidence_required boolean
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
  if not found or not sca_core.action_actor_can_manage(
    v_current.organisation_id, v_current.owner_actor_id, v_current.team_id,
    v_current.authority_required, v_current.authority_decision_class,
    v_current.authority_subject, v_current.authority_limits, v_current.authority_context
  ) then raise exception 'Completion policy change not permitted'; end if;
  if v_current.status in ('completed', 'cancelled') then
    raise exception 'Terminal Action completion policy cannot be changed';
  end if;
  update sca_core.action_item set
    completion_outcome_required = p_completion_outcome_required,
    evidence_required = p_evidence_required
  where id = p_action_item_id returning * into v_record;
  perform sca_core.action_write_event(
    v_record.organisation_id, v_record.mission_id, v_record.id,
    'action_item.completion_policy_changed',
    jsonb_build_object(
      'completion_outcome_required', p_completion_outcome_required,
      'evidence_required', p_evidence_required
    )
  );
  return v_record;
end;
$$;

create or replace function sca_core.actions_complete_item_v1(
  p_action_item_id uuid,
  p_completion_note text default null
)
returns sca_core.action_item
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_current sca_core.action_item%rowtype;
  v_record sca_core.action_item%rowtype;
  v_evidence_count integer;
  v_completion_activity_id uuid;
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
  if v_current.completion_outcome_required then
    select a.id into v_completion_activity_id
    from sca_core.activity a
    where a.organisation_id = v_current.organisation_id
      and a.activity_type = 'outcome'
      and a.lifecycle_status = 'published'
      and a.visibility_scope <> 'private_actor'
      and (
        (a.primary_subject_type = 'action_item' and a.primary_subject_id = p_action_item_id)
        or exists (
          select 1 from sca_core.activity_link al
          where al.activity_id = a.id
            and al.linked_type = 'action_item'
            and al.linked_id = p_action_item_id
        )
      )
    order by a.occurred_at desc, a.id desc
    limit 1;
    if v_completion_activity_id is null then
      raise exception 'Completion outcome Activity is required';
    end if;
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
    'action_item.completed', jsonb_build_object(
      'completion_note', p_completion_note,
      'evidence_count', v_evidence_count,
      'completion_activity_id', v_completion_activity_id
    )
  );
  return v_record;
end;
$$;

revoke all on function sca_core.activity_write_event(uuid, uuid, text, jsonb, uuid, uuid) from public;
revoke all on function sca_core.activity_create_v1(sca_core.activity_type, text, sca_core.activity_visibility_scope, text, uuid, jsonb, timestamptz, text, text, uuid, text, sca_core.provenance_kind, text, uuid, uuid[], jsonb) from public;
revoke all on function sca_core.activity_update_v1(uuid, text, jsonb, text, text) from public;
revoke all on function sca_core.activity_withdraw_v1(uuid, text) from public;
revoke all on function sca_core.activity_redact_v1(uuid, text) from public;
revoke all on function sca_core.activity_get_work_journal_v1(text, uuid, integer, timestamptz, uuid) from public;
revoke all on function sca_core.activity_create_follow_up_action_v1(uuid, text, text, uuid, timestamptz, sca_core.action_priority) from public;
revoke all on function sca_core.actions_set_completion_policy_v1(uuid, boolean, boolean) from public;

grant execute on function sca_core.activity_create_v1(sca_core.activity_type, text, sca_core.activity_visibility_scope, text, uuid, jsonb, timestamptz, text, text, uuid, text, sca_core.provenance_kind, text, uuid, uuid[], jsonb) to authenticated;
grant execute on function sca_core.activity_update_v1(uuid, text, jsonb, text, text) to authenticated;
grant execute on function sca_core.activity_withdraw_v1(uuid, text) to authenticated;
grant execute on function sca_core.activity_redact_v1(uuid, text) to authenticated;
grant execute on function sca_core.activity_get_work_journal_v1(text, uuid, integer, timestamptz, uuid) to authenticated;
grant execute on function sca_core.activity_create_follow_up_action_v1(uuid, text, text, uuid, timestamptz, sca_core.action_priority) to authenticated;
grant execute on function sca_core.actions_set_completion_policy_v1(uuid, boolean, boolean) to authenticated;

do $$
declare
  v_table regclass;
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    foreach v_table in array array[
      'sca_core.activity'::regclass,
      'sca_core.activity_link'::regclass,
      'sca_core.activity_audience_actor'::regclass,
      'sca_audit.activity_event'::regclass
    ] loop
      begin
        execute format('alter publication supabase_realtime add table %s', v_table);
      exception when duplicate_object then
        null;
      end;
    end loop;
  end if;
end;
$$;

comment on function sca_core.activity_get_work_journal_v1(text, uuid, integer, timestamptz, uuid) is
  'Visibility-filtered Work Journal combining contextual Activity, authoritative Actions execution events, and evidence as distinct entry kinds.';
comment on function sca_core.activity_create_follow_up_action_v1(uuid, text, text, uuid, timestamptz, sca_core.action_priority) is
  'Explicitly creates a follow-up Action from an eligible Activity outcome and links both records without silently converting notes into tasks.';

commit;
