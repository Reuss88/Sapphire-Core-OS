begin;

create or replace function sca_core.action_actor_can_view_mission(p_mission_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from sca_core.action_mission m
    where m.id = p_mission_id
      and m.organisation_id = sca_identity.current_organisation_id()
      and (
        m.owner_actor_id = sca_identity.current_actor_id()
        or m.created_by_actor_id = sca_identity.current_actor_id()
        or sca_core.action_has_capability('actions.director.view', m.organisation_id, m.team_id)
        or (
          m.team_id is not null
          and sca_identity.can_access_team(m.team_id)
          and sca_core.action_has_capability('actions.team.read', m.organisation_id, m.team_id)
        )
        or exists (
          select 1
          from sca_core.action_assignment a
          where a.mission_id = m.id
            and a.actor_id = sca_identity.current_actor_id()
            and a.removed_at is null
        )
      )
  );
$$;

create or replace function sca_core.action_actor_can_view_item(p_action_item_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from sca_core.action_item i
    where i.id = p_action_item_id
      and i.organisation_id = sca_identity.current_organisation_id()
      and (
        i.owner_actor_id = sca_identity.current_actor_id()
        or i.created_by_actor_id = sca_identity.current_actor_id()
        or sca_core.action_has_capability('actions.director.view', i.organisation_id, i.team_id)
        or (
          i.team_id is not null
          and sca_identity.can_access_team(i.team_id)
          and sca_core.action_has_capability('actions.team.read', i.organisation_id, i.team_id)
        )
        or (i.mission_id is not null and sca_core.action_actor_can_view_mission(i.mission_id))
        or exists (
          select 1
          from sca_core.action_assignment a
          where a.action_item_id = i.id
            and a.actor_id = sca_identity.current_actor_id()
            and a.removed_at is null
        )
      )
  );
$$;

create policy action_mission_select_visible
on sca_core.action_mission for select to authenticated
using (sca_core.action_actor_can_view_mission(id));

create policy action_item_select_visible
on sca_core.action_item for select to authenticated
using (sca_core.action_actor_can_view_item(id));

create policy action_assignment_select_visible
on sca_core.action_assignment for select to authenticated
using (
  organisation_id = sca_identity.current_organisation_id()
  and (
    actor_id = sca_identity.current_actor_id()
    or (mission_id is not null and sca_core.action_actor_can_view_mission(mission_id))
    or (action_item_id is not null and sca_core.action_actor_can_view_item(action_item_id))
  )
);

create policy action_dependency_select_visible
on sca_core.action_dependency for select to authenticated
using (
  organisation_id = sca_identity.current_organisation_id()
  and sca_core.action_actor_can_view_item(predecessor_item_id)
  and sca_core.action_actor_can_view_item(successor_item_id)
);

create policy action_link_select_visible
on sca_core.action_link for select to authenticated
using (
  organisation_id = sca_identity.current_organisation_id()
  and (
    (mission_id is not null and sca_core.action_actor_can_view_mission(mission_id))
    or (action_item_id is not null and sca_core.action_actor_can_view_item(action_item_id))
  )
);

create policy action_evidence_select_visible
on sca_core.action_evidence for select to authenticated
using (
  organisation_id = sca_identity.current_organisation_id()
  and sca_core.action_actor_can_view_item(action_item_id)
);

create policy action_event_select_visible
on sca_audit.action_event for select to authenticated
using (
  organisation_id = sca_identity.current_organisation_id()
  and (
    (mission_id is not null and sca_core.action_actor_can_view_mission(mission_id))
    or (action_item_id is not null and sca_core.action_actor_can_view_item(action_item_id))
  )
);

create policy action_saved_view_select_own
on sca_core.action_saved_view for select to authenticated
using (
  organisation_id = sca_identity.current_organisation_id()
  and actor_id = sca_identity.current_actor_id()
);

create policy action_saved_view_insert_own
on sca_core.action_saved_view for insert to authenticated
with check (
  organisation_id = sca_identity.current_organisation_id()
  and actor_id = sca_identity.current_actor_id()
);

create policy action_saved_view_update_own
on sca_core.action_saved_view for update to authenticated
using (
  organisation_id = sca_identity.current_organisation_id()
  and actor_id = sca_identity.current_actor_id()
)
with check (
  organisation_id = sca_identity.current_organisation_id()
  and actor_id = sca_identity.current_actor_id()
);

create policy action_saved_view_delete_own
on sca_core.action_saved_view for delete to authenticated
using (
  organisation_id = sca_identity.current_organisation_id()
  and actor_id = sca_identity.current_actor_id()
);

revoke all on table sca_core.action_mission from public, anon, authenticated, service_role;
revoke all on table sca_core.action_item from public, anon, authenticated, service_role;
revoke all on table sca_core.action_assignment from public, anon, authenticated, service_role;
revoke all on table sca_core.action_dependency from public, anon, authenticated, service_role;
revoke all on table sca_core.action_link from public, anon, authenticated, service_role;
revoke all on table sca_core.action_evidence from public, anon, authenticated, service_role;
revoke all on table sca_core.action_saved_view from public, anon, authenticated, service_role;
revoke all on table sca_audit.action_event from public, anon, authenticated, service_role;

grant usage on schema sca_core, sca_audit to authenticated, service_role;
grant select on
  sca_core.action_mission,
  sca_core.action_item,
  sca_core.action_assignment,
  sca_core.action_dependency,
  sca_core.action_link,
  sca_core.action_evidence,
  sca_audit.action_event
to authenticated, service_role;
grant select, insert, update, delete on sca_core.action_saved_view to authenticated;
grant select on sca_core.action_saved_view to service_role;

revoke all on function sca_core.action_actor_can_view_mission(uuid) from public;
revoke all on function sca_core.action_actor_can_view_item(uuid) from public;
grant execute on function sca_core.action_actor_can_view_mission(uuid) to authenticated, service_role;
grant execute on function sca_core.action_actor_can_view_item(uuid) to authenticated, service_role;

do $$
declare
  v_table regclass;
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    foreach v_table in array array[
      'sca_core.action_mission'::regclass,
      'sca_core.action_item'::regclass,
      'sca_core.action_assignment'::regclass,
      'sca_core.action_dependency'::regclass,
      'sca_core.action_link'::regclass,
      'sca_core.action_evidence'::regclass,
      'sca_audit.action_event'::regclass
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

comment on function sca_core.action_actor_can_view_item(uuid) is
  'Canonical membership, team, capability, ownership, creation, and assignment visibility. Assignment is never consulted for mutation authority.';
comment on table sca_core.action_item is
  'Clients treat realtime changes as invalidation signals and refetch authoritative RPC snapshots.';

commit;
