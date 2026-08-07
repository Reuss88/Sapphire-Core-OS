-- Identity / Access / Authority runtime acceptance tests.
-- Execute after all Supabase migrations in an isolated test database.

begin;

insert into auth.users (id, aud, role, email, encrypted_password, raw_app_meta_data, raw_user_meta_data, created_at, updated_at)
values
  ('10000000-0000-4000-8000-000000000001', 'authenticated', 'authenticated', 'identity-a@example.test', '', '{}'::jsonb, '{}'::jsonb, now(), now()),
  ('10000000-0000-4000-8000-000000000002', 'authenticated', 'authenticated', 'identity-b@example.test', '', '{}'::jsonb, '{}'::jsonb, now(), now()),
  ('10000000-0000-4000-8000-000000000003', 'authenticated', 'authenticated', 'identity-suspended@example.test', '', '{}'::jsonb, '{}'::jsonb, now(), now()),
  ('10000000-0000-4000-8000-000000000004', 'authenticated', 'authenticated', 'identity-team-b@example.test', '', '{}'::jsonb, '{}'::jsonb, now(), now());

insert into sca_identity.actor (id, auth_user_id, actor_kind, display_name)
values
  ('20000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'human', 'Actor A'),
  ('20000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000002', 'human', 'Actor B'),
  ('20000000-0000-4000-8000-000000000003', '10000000-0000-4000-8000-000000000003', 'human', 'Suspended Actor'),
  ('20000000-0000-4000-8000-000000000004', '10000000-0000-4000-8000-000000000004', 'human', 'Team B Actor');

insert into sca_identity.organisation (id, organisation_key, display_name)
values
  ('30000000-0000-4000-8000-000000000001', 'identity-test-a', 'Identity Test A'),
  ('30000000-0000-4000-8000-000000000002', 'identity-test-b', 'Identity Test B');

insert into sca_identity.organisation_membership (id, organisation_id, actor_id, status)
values
  ('40000000-0000-4000-8000-000000000001', '30000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000000001', 'active'),
  ('40000000-0000-4000-8000-000000000002', '30000000-0000-4000-8000-000000000002', '20000000-0000-4000-8000-000000000002', 'active'),
  ('40000000-0000-4000-8000-000000000003', '30000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000000003', 'suspended'),
  ('40000000-0000-4000-8000-000000000004', '30000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000000004', 'active');

insert into sca_identity.team (id, organisation_id, team_key, display_name)
values
  ('50000000-0000-4000-8000-000000000001', '30000000-0000-4000-8000-000000000001', 'team-a', 'Team A'),
  ('50000000-0000-4000-8000-000000000002', '30000000-0000-4000-8000-000000000001', 'team-b', 'Team B');

insert into sca_identity.team_membership (organisation_id, team_id, actor_id, status)
values
  ('30000000-0000-4000-8000-000000000001', '50000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000000001', 'active'),
  ('30000000-0000-4000-8000-000000000001', '50000000-0000-4000-8000-000000000002', '20000000-0000-4000-8000-000000000004', 'active');

insert into sca_identity.role_definition (id, organisation_id, role_code, display_name, description)
values (
  '60000000-0000-4000-8000-000000000001',
  '30000000-0000-4000-8000-000000000001',
  'director',
  'Director',
  'Administrative label used to prove that role assignment alone is not authority.'
);

insert into sca_identity.actor_role (organisation_id, actor_id, role_id, status)
values (
  '30000000-0000-4000-8000-000000000001',
  '20000000-0000-4000-8000-000000000001',
  '60000000-0000-4000-8000-000000000001',
  'active'
);

insert into sca_governance.authority_rule (
  id, organisation_id, rule_code, decision_class, display_name,
  scope, jurisdiction, limits, conditions, evidence_requirements,
  governing_policy_reference, status, effective_from
) values (
  '70000000-0000-4000-8000-000000000001',
  '30000000-0000-4000-8000-000000000001',
  'approve-trade',
  'trade.approve',
  'Approve commodity trade',
  '{"commodity":"copper"}',
  '{"region":"eu"}',
  '{"amount":100000}',
  '{"channel":"trade"}',
  '{"evidence":"kyc"}',
  'architecture/decision-authority-approval/PASS-02-AUTHORITY-ARCHITECTURE.md',
  'active',
  now() - interval '1 day'
);

-- 1. Anonymous callers receive no identity table access.
set local role anon;
do $$
begin
  begin
    perform 1 from sca_identity.organisation limit 1;
    raise exception 'Anonymous identity access was unexpectedly allowed';
  exception
    when insufficient_privilege then null;
  end;
end;
$$;
reset role;

-- Authenticate Actor A with Organisation A as a selector.
set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"10000000-0000-4000-8000-000000000001","role":"authenticated","organisation_id":"30000000-0000-4000-8000-000000000001"}',
  true
);

-- 2-6 and 8. Identity, organisation, team, role, and assignment boundaries.
do $$
declare
  visible_actors integer;
  visible_other_orgs integer;
begin
  if sca_identity.current_actor_id() <> '20000000-0000-4000-8000-000000000001'::uuid then
    raise exception 'Actor did not resolve to its own authenticated identity';
  end if;
  select count(*) into visible_actors from sca_identity.actor;
  if visible_actors <> 1 then
    raise exception 'Actor self policy exposed % actors', visible_actors;
  end if;
  select count(*) into visible_other_orgs
  from sca_identity.organisation
  where id = '30000000-0000-4000-8000-000000000002'::uuid;
  if visible_other_orgs <> 0 then
    raise exception 'Organisation A read Organisation B';
  end if;
  if not sca_identity.can_access_team('50000000-0000-4000-8000-000000000001') then
    raise exception 'Direct team membership did not grant team visibility';
  end if;
  if sca_identity.can_access_team('50000000-0000-4000-8000-000000000002') then
    raise exception 'Team-scoped actor gained unrelated team visibility';
  end if;
  if sca_governance.has_authority(
    'trade.approve', '{"commodity":"copper"}', '{"amount":1}',
    '{"organisation_id":"30000000-0000-4000-8000-000000000001","region":"eu","channel":"trade","evidence":"kyc"}'
  ) then
    raise exception 'Role or team assignment incorrectly created authority';
  end if;
end;
$$;
reset role;

-- 4. Suspended membership cannot resolve organisation access.
set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"10000000-0000-4000-8000-000000000003","role":"authenticated","organisation_id":"30000000-0000-4000-8000-000000000001"}',
  true
);
do $$
begin
  if sca_identity.is_org_member('30000000-0000-4000-8000-000000000001') then
    raise exception 'Suspended membership retained organisation access';
  end if;
  if sca_identity.current_organisation_id() is not null then
    raise exception 'Suspended membership retained organisation context';
  end if;
end;
$$;
reset role;

update sca_identity.organisation_membership
set status = 'revoked', effective_to = effective_from + interval '1 microsecond'
where id = '40000000-0000-4000-8000-000000000004';

set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"10000000-0000-4000-8000-000000000004","role":"authenticated","organisation_id":"30000000-0000-4000-8000-000000000001"}',
  true
);
do $$
begin
  if sca_identity.is_org_member('30000000-0000-4000-8000-000000000001') then
    raise exception 'Revoked membership retained organisation access';
  end if;
end;
$$;
reset role;

-- 7 and 11. A privileged capability mutation is effective and audited.
set local role service_role;
select set_config('request.jwt.claims', '{"role":"service_role"}', true);
select sca_identity.grant_actor_capability(
  '30000000-0000-4000-8000-000000000001',
  '20000000-0000-4000-8000-000000000001',
  'identity.teams.read_all',
  'allow',
  '{"organisation_id":"30000000-0000-4000-8000-000000000001"}',
  'Identity runtime acceptance test'
) as capability_grant_id \gset
select set_config('test.capability_grant_id', :'capability_grant_id', true);
reset role;

set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"10000000-0000-4000-8000-000000000001","role":"authenticated","organisation_id":"30000000-0000-4000-8000-000000000001"}',
  true
);
do $$
begin
  if not sca_identity.can_access_team('50000000-0000-4000-8000-000000000002') then
    raise exception 'Capability grant did not change the permitted software action';
  end if;
end;
$$;
reset role;

update sca_identity.actor_capability
set status = 'suspended'
where id = :'capability_grant_id'::uuid;

set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"10000000-0000-4000-8000-000000000001","role":"authenticated","organisation_id":"30000000-0000-4000-8000-000000000001"}',
  true
);
do $$
begin
  if sca_identity.can_access_team('50000000-0000-4000-8000-000000000002') then
    raise exception 'Suspended capability still permits the software action';
  end if;
end;
$$;
reset role;

do $$
declare
  audit_count integer;
begin
  select count(*) into audit_count
  from sca_audit.access_event
  where target_table = 'actor_capability'
    and target_id = current_setting('test.capability_grant_id')::uuid;
  if audit_count < 2 then
    raise exception 'Expected capability insert and update audit events, found %', audit_count;
  end if;
end;
$$;

do $$
begin
  begin
    update sca_audit.access_event
    set event_data = event_data || '{"tampered":true}'::jsonb
    where target_table = 'actor_capability';
    raise exception 'Access audit history was unexpectedly mutable';
  exception
    when others then
      if position('append-only' in sqlerrm) = 0 then
        raise;
      end if;
  end;
end;
$$;

-- 9-10. Authority requires an effective Grant and stays inside scope and limits.
insert into sca_governance.authority_grant (
  id, organisation_id, authority_rule_id, actor_id, scope, limits, conditions,
  status, effective_from, effective_to, evidence_reference
) values (
  '80000000-0000-4000-8000-000000000001',
  '30000000-0000-4000-8000-000000000001',
  '70000000-0000-4000-8000-000000000001',
  '20000000-0000-4000-8000-000000000001',
  '{"commodity":"copper"}',
  '{"amount":50000}',
  '{"channel":"trade"}',
  'expired',
  now() - interval '2 days',
  now() - interval '1 day',
  'acceptance-expired'
);

set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"10000000-0000-4000-8000-000000000001","role":"authenticated","organisation_id":"30000000-0000-4000-8000-000000000001"}',
  true
);
do $$
begin
  if sca_governance.has_authority(
    'trade.approve', '{"commodity":"copper"}', '{"amount":40000}',
    '{"organisation_id":"30000000-0000-4000-8000-000000000001","region":"eu","channel":"trade","evidence":"kyc"}'
  ) then
    raise exception 'Expired Authority Grant was accepted';
  end if;
end;
$$;
reset role;

update sca_governance.authority_grant
set status = 'active', effective_from = now() - interval '1 hour', effective_to = now() + interval '1 hour'
where id = '80000000-0000-4000-8000-000000000001';

set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"10000000-0000-4000-8000-000000000001","role":"authenticated","organisation_id":"30000000-0000-4000-8000-000000000001"}',
  true
);
do $$
declare
  context jsonb := '{"organisation_id":"30000000-0000-4000-8000-000000000001","region":"eu","channel":"trade","evidence":"kyc"}';
begin
  if not sca_governance.has_authority(
    'trade.approve', '{"commodity":"copper"}', '{"amount":40000}', context
  ) then
    raise exception 'Valid in-scope Authority Grant was rejected';
  end if;
  if sca_governance.has_authority(
    'trade.approve', '{"commodity":"copper"}', '{"amount":60000}', context
  ) then
    raise exception 'Authority Grant exceeded its granted limit';
  end if;
  if sca_governance.has_authority(
    'trade.approve', '{"commodity":"gold"}', '{"amount":100}', context
  ) then
    raise exception 'Authority Grant escaped its subject scope';
  end if;
end;
$$;
reset role;

update sca_governance.authority_grant
set status = 'revoked'
where id = '80000000-0000-4000-8000-000000000001';

set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"10000000-0000-4000-8000-000000000001","role":"authenticated","organisation_id":"30000000-0000-4000-8000-000000000001"}',
  true
);
do $$
begin
  if sca_governance.has_authority(
    'trade.approve', '{"commodity":"copper"}', '{"amount":1}',
    '{"organisation_id":"30000000-0000-4000-8000-000000000001","region":"eu","channel":"trade","evidence":"kyc"}'
  ) then
    raise exception 'Revoked Authority Grant was accepted';
  end if;
end;
$$;
reset role;

-- 12. Backend bypass is explicit: service_role bypasses RLS and software capability checks,
-- but does not fabricate a human actor or organisational Authority Grant.
set local role service_role;
select set_config('request.jwt.claims', '{"role":"service_role"}', true);
do $$
declare
  org_count integer;
begin
  select count(*) into org_count from sca_identity.organisation;
  if org_count <> 2 then
    raise exception 'service_role did not bypass organisation RLS';
  end if;
  if not sca_identity.has_capability('identity.teams.read_all', '{}'::jsonb) then
    raise exception 'service_role capability bypass was not explicit';
  end if;
  if sca_identity.current_actor_id() is not null then
    raise exception 'service_role unexpectedly fabricated an actor identity';
  end if;
  if sca_governance.has_authority('trade.approve', '{}'::jsonb, '{}'::jsonb, '{}'::jsonb) then
    raise exception 'service_role unexpectedly fabricated organisational authority';
  end if;
end;
$$;
reset role;

rollback;
