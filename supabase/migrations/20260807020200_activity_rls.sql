begin;

create or replace function sca_core.activity_subject_organisation_id(
  p_subject_type text,
  p_subject_id uuid
)
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select case
    when p_subject_type = 'mission' then (
      select m.organisation_id from sca_core.action_mission m where m.id = p_subject_id
    )
    when p_subject_type = 'action_item' then (
      select i.organisation_id from sca_core.action_item i where i.id = p_subject_id
    )
    else sca_identity.current_organisation_id()
  end;
$$;

create or replace function sca_core.activity_subject_team_id(
  p_subject_type text,
  p_subject_id uuid
)
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select case
    when p_subject_type = 'mission' then (
      select m.team_id from sca_core.action_mission m where m.id = p_subject_id
    )
    when p_subject_type = 'action_item' then (
      select coalesce(i.team_id, m.team_id)
      from sca_core.action_item i
      left join sca_core.action_mission m on m.id = i.mission_id
      where i.id = p_subject_id
    )
    else null
  end;
$$;

create or replace function sca_core.activity_actor_can_view_subject(
  p_subject_type text,
  p_subject_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select case
    when p_subject_type = 'mission' then sca_core.action_actor_can_view_mission(p_subject_id)
    when p_subject_type = 'action_item' then sca_core.action_actor_can_view_item(p_subject_id)
    else sca_identity.is_org_member(sca_identity.current_organisation_id())
  end;
$$;

create or replace function sca_core.activity_actor_is_subject_assignee(
  p_subject_type text,
  p_subject_id uuid,
  p_actor_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select case
    when p_subject_type = 'mission' then exists (
      select 1
      from sca_core.action_mission m
      where m.id = p_subject_id
        and (
          m.owner_actor_id = p_actor_id
          or m.created_by_actor_id = p_actor_id
          or exists (
            select 1 from sca_core.action_assignment aa
            where aa.mission_id = m.id
              and aa.actor_id = p_actor_id
              and aa.removed_at is null
          )
        )
    )
    when p_subject_type = 'action_item' then exists (
      select 1
      from sca_core.action_item i
      where i.id = p_subject_id
        and (
          i.owner_actor_id = p_actor_id
          or i.created_by_actor_id = p_actor_id
          or exists (
            select 1 from sca_core.action_assignment aa
            where aa.action_item_id = i.id
              and aa.actor_id = p_actor_id
              and aa.removed_at is null
          )
        )
    )
    else false
  end;
$$;

create or replace function sca_core.activity_actor_can_view(p_activity_id uuid)
returns boolean
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_activity sca_core.activity%rowtype;
  v_actor_id uuid := sca_identity.current_actor_id();
  v_subject_team_id uuid;
begin
  if sca_identity.is_service_role() then
    return true;
  end if;

  select * into v_activity from sca_core.activity where id = p_activity_id;
  if not found
     or v_actor_id is null
     or v_activity.organisation_id <> sca_identity.current_organisation_id()
     or not sca_identity.is_org_member(v_activity.organisation_id) then
    return false;
  end if;

  if v_activity.actor_id = v_actor_id then
    return true;
  end if;

  if v_activity.lifecycle_status = 'withdrawn' then
    return sca_identity.has_capability(
      'activity.manage', jsonb_build_object('organisation_id', v_activity.organisation_id)
    );
  end if;

  if v_activity.visibility_scope = 'private_actor' then
    return false;
  elsif v_activity.visibility_scope = 'director_only' then
    return sca_identity.has_capability(
      'activity.director', jsonb_build_object('organisation_id', v_activity.organisation_id)
    );
  elsif v_activity.visibility_scope = 'assigned_users' then
    return sca_core.activity_actor_is_subject_assignee(
      v_activity.primary_subject_type, v_activity.primary_subject_id, v_actor_id
    ) or exists (
      select 1 from sca_core.activity_audience_actor aaa
      where aaa.activity_id = v_activity.id and aaa.actor_id = v_actor_id
    );
  elsif v_activity.visibility_scope = 'mission_team' then
    v_subject_team_id := sca_core.activity_subject_team_id(
      v_activity.primary_subject_type, v_activity.primary_subject_id
    );
    return v_subject_team_id is not null and sca_identity.can_access_team(v_subject_team_id);
  elsif v_activity.visibility_scope = 'workspace_team' then
    return v_activity.workspace_team_id is not null
      and sca_identity.can_access_team(v_activity.workspace_team_id)
      and sca_identity.has_capability(
        'activity.workspace.read',
        jsonb_build_object(
          'organisation_id', v_activity.organisation_id,
          'team_id', v_activity.workspace_team_id
        )
      );
  elsif v_activity.visibility_scope = 'organisation' then
    return true;
  end if;

  return false;
end;
$$;

create policy activity_select_visible
on sca_core.activity for select to authenticated
using (sca_core.activity_actor_can_view(id));

create policy activity_link_select_visible
on sca_core.activity_link for select to authenticated
using (
  organisation_id = sca_identity.current_organisation_id()
  and sca_core.activity_actor_can_view(activity_id)
);

create policy activity_audience_select_visible
on sca_core.activity_audience_actor for select to authenticated
using (
  organisation_id = sca_identity.current_organisation_id()
  and sca_core.activity_actor_can_view(activity_id)
);

create policy activity_event_select_visible
on sca_audit.activity_event for select to authenticated
using (
  organisation_id = sca_identity.current_organisation_id()
  and sca_core.activity_actor_can_view(activity_id)
);

revoke all on table sca_core.activity from public, anon, authenticated, service_role;
revoke all on table sca_core.activity_link from public, anon, authenticated, service_role;
revoke all on table sca_core.activity_audience_actor from public, anon, authenticated, service_role;
revoke all on table sca_audit.activity_event from public, anon, authenticated, service_role;

grant usage on schema sca_core, sca_audit to authenticated, service_role;
grant select on sca_core.activity, sca_core.activity_link, sca_core.activity_audience_actor,
  sca_audit.activity_event to authenticated, service_role;

revoke all on function sca_core.activity_subject_organisation_id(text, uuid) from public;
revoke all on function sca_core.activity_subject_team_id(text, uuid) from public;
revoke all on function sca_core.activity_actor_can_view_subject(text, uuid) from public;
revoke all on function sca_core.activity_actor_is_subject_assignee(text, uuid, uuid) from public;
revoke all on function sca_core.activity_actor_can_view(uuid) from public;
grant execute on function sca_core.activity_actor_can_view(uuid) to authenticated, service_role;
grant execute on function sca_core.activity_actor_can_view_subject(text, uuid) to authenticated, service_role;

comment on function sca_core.activity_actor_can_view(uuid) is
  'Server-side Activity visibility evaluation. Director capability does not override private_actor, assigned_users, mission_team, or workspace_team scope.';

commit;
