-- Actions execution, identity, authority, and isolation acceptance tests.
-- Execute after applying every Supabase migration in an isolated development database.

begin;

insert into auth.users (id, aud, role, email, encrypted_password, raw_app_meta_data, raw_user_meta_data, created_at, updated_at)
values
  ('11000000-0000-4000-8000-000000000001', 'authenticated', 'authenticated', 'actions-director@example.test', '', '{}'::jsonb, '{}'::jsonb, now(), now()),
  ('11000000-0000-4000-8000-000000000002', 'authenticated', 'authenticated', 'actions-worker@example.test', '', '{}'::jsonb, '{}'::jsonb, now(), now()),
  ('11000000-0000-4000-8000-000000000003', 'authenticated', 'authenticated', 'actions-contributor@example.test', '', '{}'::jsonb, '{}'::jsonb, now(), now()),
  ('11000000-0000-4000-8000-000000000004', 'authenticated', 'authenticated', 'actions-other-org@example.test', '', '{}'::jsonb, '{}'::jsonb, now(), now());

insert into sca_identity.actor (id, auth_user_id, actor_kind, display_name)
values
  ('21000000-0000-4000-8000-000000000001', '11000000-0000-4000-8000-000000000001', 'human', 'Actions Director'),
  ('21000000-0000-4000-8000-000000000002', '11000000-0000-4000-8000-000000000002', 'human', 'Actions Worker'),
  ('21000000-0000-4000-8000-000000000003', '11000000-0000-4000-8000-000000000003', 'human', 'Actions Contributor'),
  ('21000000-0000-4000-8000-000000000004', '11000000-0000-4000-8000-000000000004', 'human', 'Other Organisation Actor');

insert into sca_identity.organisation (id, organisation_key, display_name)
values
  ('31000000-0000-4000-8000-000000000001', 'actions-test-a', 'Actions Test A'),
  ('31000000-0000-4000-8000-000000000002', 'actions-test-b', 'Actions Test B');

insert into sca_identity.organisation_membership (organisation_id, actor_id, status)
values
  ('31000000-0000-4000-8000-000000000001', '21000000-0000-4000-8000-000000000001', 'active'),
  ('31000000-0000-4000-8000-000000000001', '21000000-0000-4000-8000-000000000002', 'active'),
  ('31000000-0000-4000-8000-000000000001', '21000000-0000-4000-8000-000000000003', 'active'),
  ('31000000-0000-4000-8000-000000000002', '21000000-0000-4000-8000-000000000004', 'active');

insert into sca_identity.team (id, organisation_id, team_key, display_name)
values
  ('41000000-0000-4000-8000-000000000001', '31000000-0000-4000-8000-000000000001', 'commercial', 'Commercial'),
  ('41000000-0000-4000-8000-000000000002', '31000000-0000-4000-8000-000000000001', 'compliance', 'Compliance');

insert into sca_identity.team_membership (organisation_id, team_id, actor_id, status)
values
  ('31000000-0000-4000-8000-000000000001', '41000000-0000-4000-8000-000000000001', '21000000-0000-4000-8000-000000000001', 'active'),
  ('31000000-0000-4000-8000-000000000001', '41000000-0000-4000-8000-000000000001', '21000000-0000-4000-8000-000000000002', 'active'),
  ('31000000-0000-4000-8000-000000000001', '41000000-0000-4000-8000-000000000002', '21000000-0000-4000-8000-000000000003', 'active');

insert into sca_identity.actor_capability (
  organisation_id, actor_id, capability_code, effect, context, reason
)
values
  ('31000000-0000-4000-8000-000000000001', '21000000-0000-4000-8000-000000000001', 'actions.create', 'allow', '{"organisation_id":"31000000-0000-4000-8000-000000000001"}', 'Actions acceptance'),
  ('31000000-0000-4000-8000-000000000001', '21000000-0000-4000-8000-000000000001', 'actions.team.read', 'allow', '{"organisation_id":"31000000-0000-4000-8000-000000000001"}', 'Actions acceptance'),
  ('31000000-0000-4000-8000-000000000001', '21000000-0000-4000-8000-000000000001', 'actions.team.manage', 'allow', '{"organisation_id":"31000000-0000-4000-8000-000000000001"}', 'Actions acceptance'),
  ('31000000-0000-4000-8000-000000000001', '21000000-0000-4000-8000-000000000001', 'actions.director.view', 'allow', '{"organisation_id":"31000000-0000-4000-8000-000000000001"}', 'Actions acceptance'),
  ('31000000-0000-4000-8000-000000000001', '21000000-0000-4000-8000-000000000001', 'identity.teams.read_all', 'allow', '{"organisation_id":"31000000-0000-4000-8000-000000000001"}', 'Actions acceptance'),
  ('31000000-0000-4000-8000-000000000001', '21000000-0000-4000-8000-000000000002', 'actions.create', 'allow', '{"organisation_id":"31000000-0000-4000-8000-000000000001"}', 'Actions acceptance'),
  ('31000000-0000-4000-8000-000000000001', '21000000-0000-4000-8000-000000000002', 'actions.team.read', 'allow', '{"organisation_id":"31000000-0000-4000-8000-000000000001"}', 'Actions acceptance');

insert into sca_governance.authority_rule (
  id, organisation_id, rule_code, decision_class, display_name, scope,
  governing_policy_reference, status, effective_from
) values (
  '51000000-0000-4000-8000-000000000001',
  '31000000-0000-4000-8000-000000000001',
  'actions-protected-execution',
  'actions.protected.execute',
  'Protected Actions execution',
  '{"workspace":"actions"}',
  'architecture/actions-execution/MASTER-ACTIONS-ARCHITECTURE-v1.md',
  'active',
  now() - interval '1 day'
);

insert into sca_governance.authority_grant (
  organisation_id, authority_rule_id, actor_id, scope, limits, conditions,
  status, effective_from, effective_to, evidence_reference
) values (
  '31000000-0000-4000-8000-000000000001',
  '51000000-0000-4000-8000-000000000001',
  '21000000-0000-4000-8000-000000000001',
  '{"workspace":"actions"}',
  '{}'::jsonb,
  '{}'::jsonb,
  'active',
  now() - interval '1 hour',
  now() + interval '1 day',
  'actions-acceptance-authority'
);

set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"11000000-0000-4000-8000-000000000001","role":"authenticated","organisation_id":"31000000-0000-4000-8000-000000000001"}',
  true
);

select (sca_core.actions_create_mission_v1(
  'Test commercial mission',
  'Prove Actions execution invariants',
  '21000000-0000-4000-8000-000000000002',
  'critical',
  now() + interval '7 days',
  '[{"criterion":"All critical actions complete"}]',
  'actions', null, null,
  '{"commercial_context":"Copper mandate"}',
  '41000000-0000-4000-8000-000000000001'
)).id as mission_id \gset
select set_config('test.actions_mission_id', :'mission_id', true);

select (sca_core.actions_create_item_v1(
  'Prerequisite', 'Produce verified prerequisite evidence', :'mission_id',
  '21000000-0000-4000-8000-000000000002', 'task', 'high', now() + interval '1 day',
  '', 'actions', null, null, false, false, 'architecture_test',
  '41000000-0000-4000-8000-000000000001'
)).id as predecessor_id \gset
select set_config('test.actions_predecessor_id', :'predecessor_id', true);

select (sca_core.actions_create_item_v1(
  'Evidence-gated action', 'Complete only with evidence', :'mission_id',
  '21000000-0000-4000-8000-000000000002', 'task', 'critical', now() - interval '1 day',
  '', 'actions', null, null, false, true, 'architecture_test',
  '41000000-0000-4000-8000-000000000001'
)).id as successor_id \gset
select set_config('test.actions_successor_id', :'successor_id', true);

select sca_core.actions_transition_item_v1(:'predecessor_id', 'queued', 'test');
select sca_core.actions_transition_item_v1(:'predecessor_id', 'ready', 'test');
select sca_core.actions_transition_item_v1(:'predecessor_id', 'in_progress', 'test');
select sca_core.actions_transition_item_v1(:'successor_id', 'queued', 'test');
select sca_core.actions_transition_item_v1(:'successor_id', 'ready', 'test');
select sca_core.actions_transition_item_v1(:'successor_id', 'in_progress', 'test');
select (sca_core.actions_add_dependency_v1(:'predecessor_id', :'successor_id')).id as dependency_id \gset

do $$
begin
  if sca_core.action_compute_due_state('in_progress', now() - interval '1 hour') <> 'overdue' then
    raise exception 'Overdue must be derived from due_at';
  end if;
  begin
    perform sca_core.actions_transition_item_v1(
      current_setting('test.actions_successor_id')::uuid, 'ready', 'illegal backwards transition'
    );
    raise exception 'Expected illegal transition rejection';
  exception when others then
    if position('Illegal action transition' in sqlerrm) = 0 then raise; end if;
  end;
  begin
    perform sca_core.actions_add_dependency_v1(
      current_setting('test.actions_successor_id')::uuid,
      current_setting('test.actions_predecessor_id')::uuid
    );
    raise exception 'Expected dependency cycle rejection';
  exception when others then
    if position('cycle' in sqlerrm) = 0 then raise; end if;
  end;
  begin
    perform sca_core.actions_complete_item_v1(
      current_setting('test.actions_successor_id')::uuid, 'no evidence'
    );
    raise exception 'Expected evidence-required completion rejection';
  exception when others then
    if position('evidence is required' in sqlerrm) = 0
       and position('dependencies' in sqlerrm) = 0 then raise; end if;
  end;
end;
$$;

select sca_core.actions_complete_item_v1(:'predecessor_id', 'Prerequisite satisfied');
select sca_core.actions_add_evidence_v1(
  :'successor_id', 'note', null, null, 'Verified architecture-test evidence'
);
select sca_core.actions_complete_item_v1(:'successor_id', 'Evidence attached');

select (sca_core.actions_create_item_v1(
  'Governance approval',
  'Reference Governance without duplicating approval truth',
  :'mission_id',
  '21000000-0000-4000-8000-000000000002',
  'approval_request', 'critical', now(), '', 'governance', null, null,
  true, false, 'governance_adapter',
  '41000000-0000-4000-8000-000000000001',
  'approval', '61000000-0000-4000-8000-000000000001',
  'actions.protected.execute', '{"workspace":"actions"}', '{}', '{}'
)).id as governed_id \gset
select set_config('test.actions_governed_id', :'governed_id', true);
select sca_core.actions_transition_item_v1(:'governed_id', 'queued', 'test');
select sca_core.actions_transition_item_v1(:'governed_id', 'ready', 'test');
select sca_core.actions_transition_item_v1(:'governed_id', 'in_progress', 'test');

do $$
begin
  begin
    perform sca_core.actions_complete_item_v1(
      current_setting('test.actions_governed_id')::uuid, 'attempt local approval'
    );
    raise exception 'Expected Governance ownership rejection';
  exception when others then
    if position('authoritative Governance command' in sqlerrm) = 0 then raise; end if;
  end;
end;
$$;

select (sca_core.actions_create_item_v1(
  'Compliance review', 'Prepare compliance evidence', null,
  '21000000-0000-4000-8000-000000000003', 'review', 'high', now() + interval '2 days',
  '', 'actions', null, null, false, true, 'architecture_test',
  '41000000-0000-4000-8000-000000000002'
)).id as compliance_id \gset
select set_config('test.actions_compliance_id', :'compliance_id', true);

reset role;

insert into sca_core.action_assignment (
  organisation_id, action_item_id, actor_id, assignment_role, assigned_by_actor_id
) values (
  '31000000-0000-4000-8000-000000000001', :'predecessor_id',
  '21000000-0000-4000-8000-000000000003', 'contributor',
  '21000000-0000-4000-8000-000000000001'
);

insert into sca_core.action_mission (
  id, organisation_id, title, objective, owner_actor_id, created_by_actor_id
) values (
  '71000000-0000-4000-8000-000000000001',
  '31000000-0000-4000-8000-000000000002',
  'Other organisation mission', 'Must remain isolated',
  '21000000-0000-4000-8000-000000000004',
  '21000000-0000-4000-8000-000000000004'
);

-- Personal/team scope: the Commercial worker can see Commercial work, never Compliance.
set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"11000000-0000-4000-8000-000000000002","role":"authenticated","organisation_id":"31000000-0000-4000-8000-000000000001"}',
  true
);
do $$
declare
  v_commercial_count integer;
  v_compliance_count integer;
begin
  select count(*) into v_commercial_count
  from sca_core.action_item
  where team_id = '41000000-0000-4000-8000-000000000001';
  select count(*) into v_compliance_count
  from sca_core.action_item
  where team_id = '41000000-0000-4000-8000-000000000002';
  if v_commercial_count < 3 then raise exception 'Expected visible Commercial team actions'; end if;
  if v_compliance_count <> 0 then raise exception 'Commercial actor gained unrelated Compliance visibility'; end if;

  begin
    perform sca_core.actions_set_due_at_v1(
      current_setting('test.actions_governed_id')::uuid,
      now() + interval '1 day',
      'Assignment must not manufacture authority'
    );
    raise exception 'Protected owner mutated an item without Authority Grant';
  exception when others then
    if position('not permitted' in sqlerrm) = 0 then raise; end if;
  end;
end;
$$;
reset role;

-- Assignment grants visibility only; it does not grant mutation permission.
set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"11000000-0000-4000-8000-000000000003","role":"authenticated","organisation_id":"31000000-0000-4000-8000-000000000001"}',
  true
);
do $$
declare
  v_visible integer;
begin
  select count(*) into v_visible
  from sca_core.action_item
  where id = current_setting('test.actions_predecessor_id')::uuid;
  if v_visible <> 1 then raise exception 'Assigned contributor lost explicit visibility'; end if;
  begin
    perform sca_core.actions_set_priority_v1(
      current_setting('test.actions_predecessor_id')::uuid, 'low', 'assignment is not permission'
    );
    raise exception 'Assignment incorrectly granted mutation permission';
  exception when others then
    if position('not permitted' in sqlerrm) = 0 then raise; end if;
  end;
end;
$$;
reset role;

-- Director capability is server-side and allows the cross-team lens, still within one organisation.
set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"11000000-0000-4000-8000-000000000001","role":"authenticated","organisation_id":"31000000-0000-4000-8000-000000000001"}',
  true
);
do $$
declare
  v_team_count integer;
  v_other_org_count integer;
  v_director_count integer;
  v_event_count integer;
begin
  select count(distinct team_id) into v_team_count
  from sca_core.action_item where team_id is not null;
  if v_team_count <> 2 then raise exception 'Director lens did not cover both teams'; end if;
  select count(*) into v_other_org_count
  from sca_core.action_mission
  where organisation_id = '31000000-0000-4000-8000-000000000002';
  if v_other_org_count <> 0 then raise exception 'RLS organisation isolation failed'; end if;
  select count(*) into v_director_count from sca_core.actions_get_director_queue_v1();
  if v_director_count < 1 then raise exception 'Director queue omitted critical cross-team work'; end if;
  select count(*) into v_event_count
  from sca_audit.action_event
  where action_item_id = current_setting('test.actions_successor_id')::uuid;
  if v_event_count < 5 then raise exception 'Expected immutable execution history, found % events', v_event_count; end if;
end;
$$;
reset role;

do $$
begin
  begin
    delete from sca_audit.action_event
    where action_item_id = current_setting('test.actions_successor_id')::uuid;
    raise exception 'Action audit history was unexpectedly mutable';
  exception when others then
    if position('append-only' in sqlerrm) = 0 then raise; end if;
  end;
end;
$$;

rollback;
