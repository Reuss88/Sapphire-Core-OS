begin;

insert into sca_identity.capability_definition (capability_code, description, authority_sensitive)
values
  ('identity.memberships.manage', 'Manage organisation membership lifecycle.', true),
  ('identity.capabilities.manage', 'Manage software capability grants and denials.', true),
  ('identity.teams.read_all', 'Read all teams in the current organisation.', false),
  ('governance.authority.read', 'Read governed Authority Rules, Grants, and Delegations.', true),
  ('governance.authority.manage', 'Manage governed Authority Grants and Delegations.', true),
  ('audit.access.read', 'Read organisation access and authority audit events.', true);

create or replace function sca_identity.touch_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

create or replace function sca_identity.is_service_role()
returns boolean
language sql
stable
set search_path = ''
as $$
  select coalesce(auth.role() = 'service_role', false);
$$;

create or replace function sca_identity.context_uuid(p_context jsonb, p_key text)
returns uuid
language plpgsql
immutable
strict
set search_path = ''
as $$
declare
  value text;
begin
  value := p_context ->> p_key;
  if value is null or value !~* '^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$' then
    return null;
  end if;
  return value::uuid;
end;
$$;

create or replace function sca_identity.current_actor_id()
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select a.id
  from sca_identity.actor a
  where a.auth_user_id = auth.uid()
    and a.is_active
  limit 1;
$$;

create or replace function sca_identity.is_org_member(p_organisation_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from sca_identity.organisation_membership om
    join sca_identity.organisation o on o.id = om.organisation_id
    where om.organisation_id = p_organisation_id
      and om.actor_id = sca_identity.current_actor_id()
      and om.status = 'active'
      and om.effective_from <= now()
      and (om.effective_to is null or om.effective_to > now())
      and o.is_active
  );
$$;

create or replace function sca_identity.current_organisation_id()
returns uuid
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  claimed_id uuid;
  active_count integer;
  resolved_id uuid;
begin
  claimed_id := sca_identity.context_uuid(auth.jwt(), 'organisation_id');

  if claimed_id is not null and sca_identity.is_org_member(claimed_id) then
    return claimed_id;
  end if;

  select count(*), (array_agg(om.organisation_id order by om.organisation_id))[1]
    into active_count, resolved_id
  from sca_identity.organisation_membership om
  join sca_identity.organisation o on o.id = om.organisation_id
  where om.actor_id = sca_identity.current_actor_id()
    and om.status = 'active'
    and om.effective_from <= now()
    and (om.effective_to is null or om.effective_to > now())
    and o.is_active;

  if active_count = 1 then
    return resolved_id;
  end if;

  return null;
end;
$$;

create or replace function sca_core.current_organisation_id()
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select sca_identity.current_organisation_id();
$$;

create or replace function sca_identity.has_capability(
  p_capability_code text,
  p_context jsonb default '{}'::jsonb
)
returns boolean
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_actor_id uuid;
  v_organisation_id uuid;
  v_team_id uuid;
begin
  if sca_identity.is_service_role() then
    return true;
  end if;

  if jsonb_typeof(p_context) <> 'object' then
    return false;
  end if;

  v_actor_id := sca_identity.current_actor_id();
  v_organisation_id := coalesce(
    sca_identity.context_uuid(p_context, 'organisation_id'),
    sca_identity.current_organisation_id()
  );
  v_team_id := sca_identity.context_uuid(p_context, 'team_id');

  if v_actor_id is null
     or v_organisation_id is null
     or not sca_identity.is_org_member(v_organisation_id) then
    return false;
  end if;

  if not exists (
    select 1
    from sca_identity.capability_definition cd
    where cd.capability_code = p_capability_code
      and cd.is_active
  ) then
    return false;
  end if;

  if exists (
    select 1
    from sca_identity.actor_capability ac
    where ac.actor_id = v_actor_id
      and ac.organisation_id = v_organisation_id
      and ac.capability_code = p_capability_code
      and ac.effect = 'deny'
      and ac.status = 'active'
      and ac.effective_from <= now()
      and (ac.effective_to is null or ac.effective_to > now())
      and p_context @> ac.context
  ) then
    return false;
  end if;

  return exists (
    select 1
    from sca_identity.actor_capability ac
    where ac.actor_id = v_actor_id
      and ac.organisation_id = v_organisation_id
      and ac.capability_code = p_capability_code
      and ac.effect = 'allow'
      and ac.status = 'active'
      and ac.effective_from <= now()
      and (ac.effective_to is null or ac.effective_to > now())
      and p_context @> ac.context
  ) or exists (
    select 1
    from sca_identity.actor_role ar
    join sca_identity.role_definition rd
      on rd.id = ar.role_id and rd.organisation_id = ar.organisation_id
    join sca_identity.role_capability rc
      on rc.role_id = ar.role_id and rc.organisation_id = ar.organisation_id
    where ar.actor_id = v_actor_id
      and ar.organisation_id = v_organisation_id
      and ar.status = 'active'
      and ar.effective_from <= now()
      and (ar.effective_to is null or ar.effective_to > now())
      and rd.is_active
      and rc.capability_code = p_capability_code
      and (ar.team_id is null or ar.team_id = v_team_id)
  );
end;
$$;

create or replace function sca_identity.can_access_team(p_team_id uuid)
returns boolean
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_actor_id uuid;
  v_organisation_id uuid;
begin
  if sca_identity.is_service_role() then
    return true;
  end if;

  v_actor_id := sca_identity.current_actor_id();
  select t.organisation_id into v_organisation_id
  from sca_identity.team t
  where t.id = p_team_id and t.is_active;

  if v_actor_id is null
     or v_organisation_id is null
     or not sca_identity.is_org_member(v_organisation_id) then
    return false;
  end if;

  return exists (
    select 1
    from sca_identity.team_membership tm
    where tm.team_id = p_team_id
      and tm.actor_id = v_actor_id
      and tm.status = 'active'
      and tm.effective_from <= now()
      and (tm.effective_to is null or tm.effective_to > now())
  ) or sca_identity.has_capability(
    'identity.teams.read_all',
    jsonb_build_object('organisation_id', v_organisation_id, 'team_id', p_team_id)
  );
end;
$$;

create or replace function sca_governance.limits_within(p_requested jsonb, p_permitted jsonb)
returns boolean
language plpgsql
immutable
set search_path = ''
as $$
declare
  entry record;
  permitted_value jsonb;
begin
  if jsonb_typeof(p_requested) <> 'object' or jsonb_typeof(p_permitted) <> 'object' then
    return false;
  end if;
  if p_permitted = '{}'::jsonb then
    return true;
  end if;

  for entry in select key, value from jsonb_each(p_requested)
  loop
    if not (p_permitted ? entry.key) then
      return false;
    end if;
    permitted_value := p_permitted -> entry.key;
    if jsonb_typeof(entry.value) = 'number' and jsonb_typeof(permitted_value) = 'number' then
      if (entry.value #>> '{}')::numeric > (permitted_value #>> '{}')::numeric then
        return false;
      end if;
    elsif entry.value <> permitted_value then
      return false;
    end if;
  end loop;
  return true;
end;
$$;

create or replace function sca_governance.has_authority(
  p_decision_class text,
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
  v_actor_id uuid;
  v_organisation_id uuid;
begin
  if jsonb_typeof(p_subject) <> 'object'
     or jsonb_typeof(p_limits) <> 'object'
     or jsonb_typeof(p_context) <> 'object' then
    return false;
  end if;

  v_actor_id := sca_identity.current_actor_id();
  v_organisation_id := coalesce(
    sca_identity.context_uuid(p_context, 'organisation_id'),
    sca_identity.current_organisation_id()
  );

  if v_actor_id is null
     or v_organisation_id is null
     or not sca_identity.is_org_member(v_organisation_id) then
    return false;
  end if;

  return exists (
    select 1
    from sca_governance.authority_grant ag
    join sca_governance.authority_rule ar
      on ar.id = ag.authority_rule_id and ar.organisation_id = ag.organisation_id
    where ag.actor_id = v_actor_id
      and ag.organisation_id = v_organisation_id
      and ag.status = 'active'
      and ag.effective_from <= now()
      and (ag.effective_to is null or ag.effective_to > now())
      and ar.status = 'active'
      and ar.decision_class = p_decision_class
      and (ar.effective_from is null or ar.effective_from <= now())
      and (ar.effective_to is null or ar.effective_to > now())
      and p_subject @> ar.scope
      and p_subject @> ag.scope
      and p_context @> ar.jurisdiction
      and p_context @> ar.conditions
      and p_context @> ar.evidence_requirements
      and p_context @> ag.conditions
      and sca_governance.limits_within(p_limits, ar.limits)
      and sca_governance.limits_within(p_limits, ag.limits)
  ) or exists (
    select 1
    from sca_governance.authority_delegation ad
    join sca_governance.authority_grant ag
      on ag.id = ad.source_authority_grant_id and ag.organisation_id = ad.organisation_id
    join sca_governance.authority_rule ar
      on ar.id = ag.authority_rule_id and ar.organisation_id = ag.organisation_id
    where ad.delegate_actor_id = v_actor_id
      and ad.delegator_actor_id = ag.actor_id
      and ad.organisation_id = v_organisation_id
      and ad.status = 'active'
      and ad.effective_from <= now()
      and (ad.effective_to is null or ad.effective_to > now())
      and ag.status = 'active'
      and ag.effective_from <= now()
      and (ag.effective_to is null or ag.effective_to > now())
      and ar.status = 'active'
      and ar.decision_class = p_decision_class
      and (ar.effective_from is null or ar.effective_from <= now())
      and (ar.effective_to is null or ar.effective_to > now())
      and p_subject @> ar.scope
      and p_subject @> ag.scope
      and p_subject @> ad.scope
      and p_context @> ar.jurisdiction
      and p_context @> ar.conditions
      and p_context @> ar.evidence_requirements
      and p_context @> ag.conditions
      and p_context @> ad.conditions
      and sca_governance.limits_within(p_limits, ar.limits)
      and sca_governance.limits_within(p_limits, ag.limits)
      and sca_governance.limits_within(p_limits, ad.limits)
  );
end;
$$;

create or replace function sca_audit.capture_access_change()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  previous_row jsonb;
  current_row jsonb;
  source_row jsonb;
begin
  previous_row := case when tg_op in ('UPDATE', 'DELETE') then to_jsonb(old) else null end;
  current_row := case when tg_op in ('INSERT', 'UPDATE') then to_jsonb(new) else null end;
  source_row := coalesce(current_row, previous_row);

  insert into sca_audit.access_event (
    organisation_id,
    event_type,
    actor_id,
    target_schema,
    target_table,
    target_id,
    request_id,
    correlation_id,
    event_data
  ) values (
    sca_identity.context_uuid(source_row, 'organisation_id'),
    lower(tg_table_schema || '.' || tg_table_name || '.' || tg_op),
    sca_identity.current_actor_id(),
    tg_table_schema,
    tg_table_name,
    sca_identity.context_uuid(source_row, 'id'),
    sca_identity.context_uuid(coalesce(auth.jwt(), '{}'::jsonb), 'request_id'),
    sca_identity.context_uuid(coalesce(auth.jwt(), '{}'::jsonb), 'correlation_id'),
    jsonb_strip_nulls(jsonb_build_object('operation', tg_op, 'before', previous_row, 'after', current_row))
  );

  return coalesce(new, old);
end;
$$;

create or replace function sca_audit.prevent_access_event_mutation()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  raise exception 'sca_audit.access_event is append-only';
end;
$$;

create trigger access_event_immutable
before update or delete on sca_audit.access_event
for each row execute function sca_audit.prevent_access_event_mutation();

do $$
declare
  target_table text;
begin
  foreach target_table in array array[
    'actor', 'organisation', 'organisation_membership', 'team', 'team_membership',
    'role_definition', 'actor_role', 'actor_capability'
  ]
  loop
    execute format(
      'create trigger %I before update on sca_identity.%I for each row execute function sca_identity.touch_updated_at()',
      target_table || '_touch_updated_at', target_table
    );
  end loop;

  foreach target_table in array array['authority_rule', 'authority_grant', 'authority_delegation']
  loop
    execute format(
      'create trigger %I before update on sca_governance.%I for each row execute function sca_identity.touch_updated_at()',
      target_table || '_touch_updated_at', target_table
    );
  end loop;
end;
$$;

do $$
declare
  target_table text;
begin
  foreach target_table in array array[
    'actor', 'organisation', 'organisation_membership', 'team', 'team_membership',
    'role_definition', 'role_capability', 'actor_role', 'actor_capability'
  ]
  loop
    execute format(
      'create trigger %I after insert or update or delete on sca_identity.%I for each row execute function sca_audit.capture_access_change()',
      target_table || '_audit_change', target_table
    );
  end loop;

  foreach target_table in array array['authority_rule', 'authority_grant', 'authority_delegation']
  loop
    execute format(
      'create trigger %I after insert or update or delete on sca_governance.%I for each row execute function sca_audit.capture_access_change()',
      target_table || '_audit_change', target_table
    );
  end loop;
end;
$$;

create or replace function sca_identity.set_organisation_membership_status(
  p_membership_id uuid,
  p_status sca_identity.membership_status
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_organisation_id uuid;
begin
  select om.organisation_id into v_organisation_id
  from sca_identity.organisation_membership om
  where om.id = p_membership_id;

  if v_organisation_id is null then
    raise exception 'organisation membership not found';
  end if;
  if not sca_identity.is_service_role()
     and not sca_identity.has_capability(
       'identity.memberships.manage', jsonb_build_object('organisation_id', v_organisation_id)
     ) then
    raise exception 'membership management capability required';
  end if;

  update sca_identity.organisation_membership
  set status = p_status,
      effective_to = case
        when p_status = 'revoked' then coalesce(
          effective_to,
          greatest(clock_timestamp(), effective_from + interval '1 microsecond')
        )
        when p_status = 'active' then null
        else effective_to
      end,
      updated_by = sca_identity.current_actor_id()
  where id = p_membership_id;
end;
$$;

create or replace function sca_identity.grant_actor_capability(
  p_organisation_id uuid,
  p_actor_id uuid,
  p_capability_code text,
  p_effect sca_identity.grant_effect,
  p_context jsonb,
  p_reason text,
  p_effective_from timestamptz default now(),
  p_effective_to timestamptz default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  result_id uuid;
begin
  if not sca_identity.is_service_role()
     and not sca_identity.has_capability(
       'identity.capabilities.manage', jsonb_build_object('organisation_id', p_organisation_id)
     ) then
    raise exception 'capability management capability required';
  end if;
  if not exists (
    select 1 from sca_identity.organisation_membership om
    where om.organisation_id = p_organisation_id
      and om.actor_id = p_actor_id
      and om.status = 'active'
      and om.effective_from <= now()
      and (om.effective_to is null or om.effective_to > now())
  ) then
    raise exception 'target actor is not an active organisation member';
  end if;

  insert into sca_identity.actor_capability (
    organisation_id, actor_id, capability_code, effect, context,
    effective_from, effective_to, granted_by, reason
  ) values (
    p_organisation_id, p_actor_id, p_capability_code, p_effect, p_context,
    p_effective_from, p_effective_to, sca_identity.current_actor_id(), p_reason
  ) returning id into result_id;
  return result_id;
end;
$$;

create or replace function sca_governance.create_authority_grant(
  p_authority_rule_id uuid,
  p_actor_id uuid,
  p_scope jsonb,
  p_limits jsonb,
  p_conditions jsonb,
  p_effective_from timestamptz,
  p_effective_to timestamptz,
  p_evidence_reference text,
  p_status sca_governance.authority_grant_status default 'proposed'
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_organisation_id uuid;
  result_id uuid;
begin
  select ar.organisation_id into v_organisation_id
  from sca_governance.authority_rule ar
  where ar.id = p_authority_rule_id;
  if v_organisation_id is null then
    raise exception 'authority rule not found';
  end if;
  if not sca_identity.is_service_role()
     and not sca_identity.has_capability(
       'governance.authority.manage', jsonb_build_object('organisation_id', v_organisation_id)
     ) then
    raise exception 'authority management capability required';
  end if;
  if not exists (
    select 1 from sca_identity.organisation_membership om
    where om.organisation_id = v_organisation_id
      and om.actor_id = p_actor_id
      and om.status = 'active'
      and om.effective_from <= now()
      and (om.effective_to is null or om.effective_to > now())
  ) then
    raise exception 'target actor is not an active organisation member';
  end if;

  insert into sca_governance.authority_grant (
    organisation_id, authority_rule_id, actor_id, scope, limits, conditions,
    status, effective_from, effective_to, evidence_reference, granted_by
  ) values (
    v_organisation_id, p_authority_rule_id, p_actor_id, p_scope, p_limits, p_conditions,
    p_status, p_effective_from, p_effective_to, p_evidence_reference,
    sca_identity.current_actor_id()
  ) returning id into result_id;
  return result_id;
end;
$$;

revoke all on function sca_identity.touch_updated_at() from public;
revoke all on function sca_identity.is_service_role() from public;
revoke all on function sca_identity.context_uuid(jsonb, text) from public;
revoke all on function sca_identity.current_actor_id() from public;
revoke all on function sca_identity.is_org_member(uuid) from public;
revoke all on function sca_identity.current_organisation_id() from public;
revoke all on function sca_core.current_organisation_id() from public;
revoke all on function sca_identity.has_capability(text, jsonb) from public;
revoke all on function sca_identity.can_access_team(uuid) from public;
revoke all on function sca_governance.limits_within(jsonb, jsonb) from public;
revoke all on function sca_governance.has_authority(text, jsonb, jsonb, jsonb) from public;
revoke all on function sca_audit.capture_access_change() from public;
revoke all on function sca_audit.prevent_access_event_mutation() from public;
revoke all on function sca_identity.set_organisation_membership_status(uuid, sca_identity.membership_status) from public;
revoke all on function sca_identity.grant_actor_capability(uuid, uuid, text, sca_identity.grant_effect, jsonb, text, timestamptz, timestamptz) from public;
revoke all on function sca_governance.create_authority_grant(uuid, uuid, jsonb, jsonb, jsonb, timestamptz, timestamptz, text, sca_governance.authority_grant_status) from public;

comment on function sca_identity.current_organisation_id() is
  'Resolves a JWT organisation selector only after active membership validation; falls back only for one unambiguous active membership.';
comment on function sca_identity.has_capability(text, jsonb) is
  'Evaluates revocable software capabilities. Explicit matching denials override direct or role-bundled allows.';
comment on function sca_governance.has_authority(text, jsonb, jsonb, jsonb) is
  'Evaluates canonical Authority Rules and effective Grants or Delegations; roles and assignment are never authority.';

commit;
