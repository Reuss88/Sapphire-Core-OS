begin;

revoke all on schema sca_identity from public, anon;
revoke all on schema sca_governance from public, anon;
revoke all on table sca_identity.actor from public, anon, authenticated, service_role;
revoke all on table sca_identity.organisation from public, anon, authenticated, service_role;
revoke all on table sca_identity.organisation_membership from public, anon, authenticated, service_role;
revoke all on table sca_identity.team from public, anon, authenticated, service_role;
revoke all on table sca_identity.team_membership from public, anon, authenticated, service_role;
revoke all on table sca_identity.role_definition from public, anon, authenticated, service_role;
revoke all on table sca_identity.capability_definition from public, anon, authenticated, service_role;
revoke all on table sca_identity.role_capability from public, anon, authenticated, service_role;
revoke all on table sca_identity.actor_role from public, anon, authenticated, service_role;
revoke all on table sca_identity.actor_capability from public, anon, authenticated, service_role;
revoke all on all tables in schema sca_governance from public, anon, authenticated, service_role;
revoke all on table sca_audit.access_event from public, anon, authenticated, service_role;

grant usage on schema sca_identity, sca_governance, sca_core, sca_audit to authenticated, service_role;

grant select on
  sca_identity.actor,
  sca_identity.organisation,
  sca_identity.organisation_membership,
  sca_identity.team,
  sca_identity.team_membership,
  sca_identity.role_definition,
  sca_identity.capability_definition,
  sca_identity.role_capability,
  sca_identity.actor_role,
  sca_identity.actor_capability,
  sca_governance.authority_rule,
  sca_governance.authority_grant,
  sca_governance.authority_delegation,
  sca_audit.access_event
to authenticated, service_role;

create policy actor_select_self
on sca_identity.actor
for select to authenticated
using (id = sca_identity.current_actor_id());

create policy organisation_select_active_member
on sca_identity.organisation
for select to authenticated
using (sca_identity.is_org_member(id));

create policy organisation_membership_select_scoped
on sca_identity.organisation_membership
for select to authenticated
using (
  actor_id = sca_identity.current_actor_id()
  or sca_identity.has_capability(
    'identity.memberships.manage',
    jsonb_build_object('organisation_id', organisation_id)
  )
);

create policy team_select_scoped
on sca_identity.team
for select to authenticated
using (sca_identity.can_access_team(id));

create policy team_membership_select_scoped
on sca_identity.team_membership
for select to authenticated
using (
  actor_id = sca_identity.current_actor_id()
  or sca_identity.can_access_team(team_id)
);

create policy role_definition_select_org_member
on sca_identity.role_definition
for select to authenticated
using (sca_identity.is_org_member(organisation_id));

create policy capability_definition_select_active
on sca_identity.capability_definition
for select to authenticated
using (is_active);

create policy role_capability_select_org_member
on sca_identity.role_capability
for select to authenticated
using (sca_identity.is_org_member(organisation_id));

create policy actor_role_select_scoped
on sca_identity.actor_role
for select to authenticated
using (
  actor_id = sca_identity.current_actor_id()
  or sca_identity.has_capability(
    'identity.capabilities.manage',
    jsonb_build_object('organisation_id', organisation_id)
  )
);

create policy actor_capability_select_scoped
on sca_identity.actor_capability
for select to authenticated
using (
  actor_id = sca_identity.current_actor_id()
  or sca_identity.has_capability(
    'identity.capabilities.manage',
    jsonb_build_object('organisation_id', organisation_id)
  )
);

create policy authority_rule_select_governed
on sca_governance.authority_rule
for select to authenticated
using (
  sca_identity.has_capability(
    'governance.authority.read',
    jsonb_build_object('organisation_id', organisation_id)
  )
  or exists (
    select 1
    from sca_governance.authority_grant ag
    where ag.authority_rule_id = id
      and ag.actor_id = sca_identity.current_actor_id()
  )
);

create policy authority_grant_select_scoped
on sca_governance.authority_grant
for select to authenticated
using (
  actor_id = sca_identity.current_actor_id()
  or sca_identity.has_capability(
    'governance.authority.read',
    jsonb_build_object('organisation_id', organisation_id)
  )
);

create policy authority_delegation_select_scoped
on sca_governance.authority_delegation
for select to authenticated
using (
  delegate_actor_id = sca_identity.current_actor_id()
  or delegator_actor_id = sca_identity.current_actor_id()
  or sca_identity.has_capability(
    'governance.authority.read',
    jsonb_build_object('organisation_id', organisation_id)
  )
);

create policy access_event_select_scoped
on sca_audit.access_event
for select to authenticated
using (
  actor_id = sca_identity.current_actor_id()
  or sca_identity.has_capability(
    'audit.access.read',
    jsonb_build_object('organisation_id', organisation_id)
  )
);

grant execute on function sca_identity.current_actor_id() to authenticated, service_role;
grant execute on function sca_identity.current_organisation_id() to authenticated, service_role;
grant execute on function sca_core.current_organisation_id() to authenticated, service_role;
grant execute on function sca_identity.is_org_member(uuid) to authenticated, service_role;
grant execute on function sca_identity.can_access_team(uuid) to authenticated, service_role;
grant execute on function sca_identity.has_capability(text, jsonb) to authenticated, service_role;
grant execute on function sca_governance.has_authority(text, jsonb, jsonb, jsonb) to authenticated, service_role;

grant execute on function sca_identity.set_organisation_membership_status(uuid, sca_identity.membership_status)
  to authenticated, service_role;
grant execute on function sca_identity.grant_actor_capability(uuid, uuid, text, sca_identity.grant_effect, jsonb, text, timestamptz, timestamptz)
  to authenticated, service_role;
grant execute on function sca_governance.create_authority_grant(uuid, uuid, jsonb, jsonb, jsonb, timestamptz, timestamptz, text, sca_governance.authority_grant_status)
  to authenticated, service_role;

comment on policy actor_select_self on sca_identity.actor is
  'Authentication resolves only the actor mapped to auth.uid().';
comment on policy authority_grant_select_scoped on sca_governance.authority_grant is
  'Authority records are visible to their holder or to an actor with governed read capability.';

commit;
