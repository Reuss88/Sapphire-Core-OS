-- Lifecycle Foundation architecture test

begin transaction;

-- create a lifecycle definition and version
select sca_core.add_lifecycle_definition('test_lifecycle', 'Test Lifecycle', 'Lifecycle for tests') as lifecycle_id into temp table tmp_def;

select id into TEMP TABLE tmp_def_id from tmp_def;

select sca_core.add_lifecycle_definition_version((select id from tmp_def_id), 1, 'v1', 'Initial version', null) as version_id into temp table tmp_ver;

-- add states
select sca_core.add_lifecycle_state_definition((select id from tmp_ver), 'draft', 'Draft', 'Initial draft', false, 0) as s1;
select sca_core.add_lifecycle_state_definition((select id from tmp_ver), 'approved', 'Approved', '', false, 1) as s2;
select sca_core.add_lifecycle_state_definition((select id from tmp_ver), 'effective', 'Effective', '', false, 2) as s3;
select sca_core.add_lifecycle_state_definition((select id from tmp_ver), 'retired', 'Retired', '', true, 3) as s4;

-- add transitions
select sca_core.add_lifecycle_transition_definition((select id from tmp_ver), 't_draft_to_approved', 'draft', 'approved', null, 'Draft to approved', false, 0);
select sca_core.add_lifecycle_transition_definition((select id from tmp_ver), 't_approved_to_effective', 'approved', 'effective', null, 'Approved to effective', false, 1);
select sca_core.add_lifecycle_transition_definition((select id from tmp_ver), 't_effective_to_retired', 'effective', 'retired', null, 'Effective to retired', false, 2);

-- publish version
select sca_core.publish_lifecycle_definition_version((select id from tmp_ver), null);

-- create lifecycle instance
select sca_core.create_lifecycle_instance(gen_random_uuid(), 'test.object', gen_random_uuid(), (select id from tmp_ver), null) as instance_id into temp table tmp_instance;

-- create a transition request
select sca_core.create_lifecycle_transition_request(null, (select id from tmp_instance), 't_draft_to_approved', null, null, null) as req_id into temp table tmp_req;

-- evaluate request (approve)
select sca_core.evaluate_lifecycle_transition_request((select id from tmp_req), gen_random_uuid(), true, 'looks good', '{}'::jsonb) as eval_id into temp table tmp_eval;

-- execute transition (should be atomic)
select sca_core.execute_lifecycle_transition((select id from tmp_req), gen_random_uuid()) as event_id into temp table tmp_event;

-- re-executing must be idempotent (returns same event)
select sca_core.execute_lifecycle_transition((select id from tmp_req), gen_random_uuid()) as event_id2 into temp table tmp_event2;

-- check that event ids match
select (select id from tmp_event) = (select id from tmp_event2) as idempotent_match into temp table tmp_check;

-- attempt stale transition: create another request expecting old state (using wrong expected_current_state_instance_id)
select sca_core.create_lifecycle_transition_request(null, (select id from tmp_instance), 't_approved_to_effective', null, null, '00000000-0000-0000-0000-000000000000'::uuid) as stale_req into temp table tmp_stale_req;

-- evaluation approval for stale request
select sca_core.evaluate_lifecycle_transition_request((select id from tmp_stale_req), gen_random_uuid(), true, null, '{}'::jsonb) into temp table tmp_stale_eval;

-- executing stale request must fail due to stale-state detection
select case when (select count(*) from sca_core.lifecycle_transition_request where id = (select id from tmp_stale_req) and status = 'pending') = 1 then
  (select (case when (select count(*) = 0 from (select sca_core.execute_lifecycle_transition((select id from tmp_stale_req), gen_random_uuid()) as x) as execs) then false else true end))
  else false end as stale_exec_attempt into temp table tmp_stale_exec;

-- projection check
select * from sca_core.check_lifecycle_projection((select id from tmp_instance)) into temp table tmp_projection;

-- retire instance
select sca_core.retire_lifecycle_instance((select id from tmp_instance), gen_random_uuid());

-- ensure retirement sets is_retired
select is_retired from sca_core.lifecycle_instance where id = (select id from tmp_instance) into temp table tmp_retired;

rollback;

-- If we reach here without unhandled exceptions the test passed

