-- Shared Activity, visibility, Work Journal, and Actions integration acceptance tests.

begin;

insert into auth.users (id, aud, role, email, encrypted_password, raw_app_meta_data, raw_user_meta_data, created_at, updated_at)
values
  ('12000000-0000-4000-8000-000000000001', 'authenticated', 'authenticated', 'activity-director@example.test', '', '{}'::jsonb, '{}'::jsonb, now(), now()),
  ('12000000-0000-4000-8000-000000000002', 'authenticated', 'authenticated', 'activity-closer@example.test', '', '{}'::jsonb, '{}'::jsonb, now(), now()),
  ('12000000-0000-4000-8000-000000000003', 'authenticated', 'authenticated', 'activity-researcher@example.test', '', '{}'::jsonb, '{}'::jsonb, now(), now()),
  ('12000000-0000-4000-8000-000000000004', 'authenticated', 'authenticated', 'activity-unassigned@example.test', '', '{}'::jsonb, '{}'::jsonb, now(), now()),
  ('12000000-0000-4000-8000-000000000005', 'authenticated', 'authenticated', 'activity-other-org@example.test', '', '{}'::jsonb, '{}'::jsonb, now(), now());

insert into sca_identity.actor (id, auth_user_id, actor_kind, display_name)
values
  ('22000000-0000-4000-8000-000000000001', '12000000-0000-4000-8000-000000000001', 'human', 'Activity Director'),
  ('22000000-0000-4000-8000-000000000002', '12000000-0000-4000-8000-000000000002', 'human', 'Activity Closer'),
  ('22000000-0000-4000-8000-000000000003', '12000000-0000-4000-8000-000000000003', 'human', 'Activity Researcher'),
  ('22000000-0000-4000-8000-000000000004', '12000000-0000-4000-8000-000000000004', 'human', 'Unassigned Actor'),
  ('22000000-0000-4000-8000-000000000005', '12000000-0000-4000-8000-000000000005', 'human', 'Other Organisation Actor');

insert into sca_identity.organisation (id, organisation_key, display_name)
values
  ('32000000-0000-4000-8000-000000000001', 'activity-test-a', 'Activity Test A'),
  ('32000000-0000-4000-8000-000000000002', 'activity-test-b', 'Activity Test B');

insert into sca_identity.organisation_membership (organisation_id, actor_id, status)
values
  ('32000000-0000-4000-8000-000000000001', '22000000-0000-4000-8000-000000000001', 'active'),
  ('32000000-0000-4000-8000-000000000001', '22000000-0000-4000-8000-000000000002', 'active'),
  ('32000000-0000-4000-8000-000000000001', '22000000-0000-4000-8000-000000000003', 'active'),
  ('32000000-0000-4000-8000-000000000001', '22000000-0000-4000-8000-000000000004', 'active'),
  ('32000000-0000-4000-8000-000000000002', '22000000-0000-4000-8000-000000000005', 'active');

insert into sca_identity.team (id, organisation_id, team_key, display_name)
values
  ('42000000-0000-4000-8000-000000000001', '32000000-0000-4000-8000-000000000001', 'closers', 'Closers'),
  ('42000000-0000-4000-8000-000000000002', '32000000-0000-4000-8000-000000000001', 'research', 'Research');

insert into sca_identity.team_membership (organisation_id, team_id, actor_id, status)
values
  ('32000000-0000-4000-8000-000000000001', '42000000-0000-4000-8000-000000000001', '22000000-0000-4000-8000-000000000001', 'active'),
  ('32000000-0000-4000-8000-000000000001', '42000000-0000-4000-8000-000000000001', '22000000-0000-4000-8000-000000000002', 'active'),
  ('32000000-0000-4000-8000-000000000001', '42000000-0000-4000-8000-000000000002', '22000000-0000-4000-8000-000000000003', 'active');

insert into sca_identity.actor_capability (
  organisation_id, actor_id, capability_code, effect, context, reason
)
values
  ('32000000-0000-4000-8000-000000000001', '22000000-0000-4000-8000-000000000001', 'actions.create', 'allow', '{"organisation_id":"32000000-0000-4000-8000-000000000001"}', 'Activity acceptance'),
  ('32000000-0000-4000-8000-000000000001', '22000000-0000-4000-8000-000000000001', 'actions.team.read', 'allow', '{"organisation_id":"32000000-0000-4000-8000-000000000001"}', 'Activity acceptance'),
  ('32000000-0000-4000-8000-000000000001', '22000000-0000-4000-8000-000000000001', 'actions.team.manage', 'allow', '{"organisation_id":"32000000-0000-4000-8000-000000000001"}', 'Activity acceptance'),
  ('32000000-0000-4000-8000-000000000001', '22000000-0000-4000-8000-000000000001', 'actions.director.view', 'allow', '{"organisation_id":"32000000-0000-4000-8000-000000000001"}', 'Activity acceptance'),
  ('32000000-0000-4000-8000-000000000001', '22000000-0000-4000-8000-000000000001', 'identity.teams.read_all', 'allow', '{"organisation_id":"32000000-0000-4000-8000-000000000001"}', 'Activity acceptance'),
  ('32000000-0000-4000-8000-000000000001', '22000000-0000-4000-8000-000000000001', 'activity.create', 'allow', '{"organisation_id":"32000000-0000-4000-8000-000000000001"}', 'Activity acceptance'),
  ('32000000-0000-4000-8000-000000000001', '22000000-0000-4000-8000-000000000001', 'activity.workspace.read', 'allow', '{"organisation_id":"32000000-0000-4000-8000-000000000001"}', 'Activity acceptance'),
  ('32000000-0000-4000-8000-000000000001', '22000000-0000-4000-8000-000000000001', 'activity.director', 'allow', '{"organisation_id":"32000000-0000-4000-8000-000000000001"}', 'Activity acceptance'),
  ('32000000-0000-4000-8000-000000000001', '22000000-0000-4000-8000-000000000001', 'activity.manage', 'allow', '{"organisation_id":"32000000-0000-4000-8000-000000000001"}', 'Activity acceptance'),
  ('32000000-0000-4000-8000-000000000001', '22000000-0000-4000-8000-000000000002', 'actions.create', 'allow', '{"organisation_id":"32000000-0000-4000-8000-000000000001"}', 'Activity acceptance'),
  ('32000000-0000-4000-8000-000000000001', '22000000-0000-4000-8000-000000000002', 'activity.create', 'allow', '{"organisation_id":"32000000-0000-4000-8000-000000000001"}', 'Activity acceptance'),
  ('32000000-0000-4000-8000-000000000001', '22000000-0000-4000-8000-000000000002', 'activity.workspace.read', 'allow', '{"organisation_id":"32000000-0000-4000-8000-000000000001"}', 'Activity acceptance'),
  ('32000000-0000-4000-8000-000000000001', '22000000-0000-4000-8000-000000000003', 'activity.create', 'allow', '{"organisation_id":"32000000-0000-4000-8000-000000000001"}', 'Activity acceptance'),
  ('32000000-0000-4000-8000-000000000001', '22000000-0000-4000-8000-000000000003', 'activity.workspace.read', 'allow', '{"organisation_id":"32000000-0000-4000-8000-000000000001"}', 'Activity acceptance');

set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"12000000-0000-4000-8000-000000000001","role":"authenticated","organisation_id":"32000000-0000-4000-8000-000000000001"}',
  true
);

select (sca_core.actions_create_mission_v1(
  'Closer mandate', 'Call the named buyer and capture a commercial outcome',
  '22000000-0000-4000-8000-000000000002', 'critical', now() + interval '7 days',
  '[{"criterion":"Call outcome reviewed"}]', 'actions', null, null,
  '{"commodity":"Copper cathodes"}', '42000000-0000-4000-8000-000000000001'
)).id as mission_id \gset
select set_config('test.activity_mission_id', :'mission_id', true);

select (sca_core.actions_create_item_v1(
  'Call Sofia Marin', 'Confirm mandate interest, objections, and next request', :'mission_id',
  '22000000-0000-4000-8000-000000000002', 'follow_up', 'critical',
  now() + interval '4 hours', 'Named buyer call', 'actions', null, null,
  false, false, 'director_assignment', '42000000-0000-4000-8000-000000000001'
)).id as call_action_id \gset
select set_config('test.activity_call_action_id', :'call_action_id', true);
select sca_core.actions_transition_item_v1(:'call_action_id', 'queued', 'assigned');
select sca_core.actions_transition_item_v1(:'call_action_id', 'ready', 'brief ready');
select sca_core.actions_transition_item_v1(:'call_action_id', 'in_progress', 'call window open');
select sca_core.actions_set_completion_policy_v1(:'call_action_id', true, false);

select (sca_core.actions_create_item_v1(
  'Research target suppliers', 'Return evidence-backed company candidates', null,
  '22000000-0000-4000-8000-000000000003', 'review', 'high', now() + interval '1 day',
  'Research brief', 'actions', null, null, false, false, 'director_assignment',
  '42000000-0000-4000-8000-000000000002'
)).id as research_action_id \gset
select set_config('test.activity_research_action_id', :'research_action_id', true);

select (sca_core.activity_create_v1(
  'instruction',
  'Call Sofia at 14:30. Confirm destination port and whether revised pricing is required.',
  'assigned_users', 'action_item', :'call_action_id',
  '{"requested_outcome":"interest, objection, requested information, next follow-up"}',
  now(), 'actions', 'action_item', :'call_action_id', null, 'human_entry', null,
  null, array['22000000-0000-4000-8000-000000000003'::uuid],
  jsonb_build_array(jsonb_build_object(
    'linked_type', 'contact', 'linked_id', '62000000-0000-4000-8000-000000000001',
    'link_role', 'call_target', 'source_workspace', 'profiles'
  ))
)).id as instruction_id \gset
select set_config('test.activity_instruction_id', :'instruction_id', true);

select (sca_core.activity_create_v1(
  'coaching_note', 'Director-only coaching context for the review.',
  'director_only', 'mission', :'mission_id'
)).id as director_note_id \gset
select set_config('test.activity_director_note_id', :'director_note_id', true);

select (sca_core.activity_create_v1(
  'note', 'Organisation-visible mandate context.', 'organisation', 'mission', :'mission_id'
)).id as organisation_note_id \gset
select set_config('test.activity_organisation_note_id', :'organisation_note_id', true);

do $$
begin
  begin
    perform sca_core.activity_create_v1(
      'ai_summary', 'AI summary without provenance must fail', 'director_only',
      'mission', current_setting('test.activity_mission_id')::uuid,
      '{}'::jsonb, now(), 'intelligence', null, null, null,
      'ai_assisted_preparation', null
    );
    raise exception 'AI Activity without provenance unexpectedly succeeded';
  exception when others then
    if position('activity_ai_provenance_chk' in sqlerrm) = 0 then raise; end if;
  end;
end;
$$;
reset role;

-- The assigned closer records private context, progress, calls, message reference, and outcome.
set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"12000000-0000-4000-8000-000000000002","role":"authenticated","organisation_id":"32000000-0000-4000-8000-000000000001"}',
  true
);

select (sca_core.activity_create_v1(
  'note', 'Private preparation note.', 'private_actor', 'action_item', :'call_action_id'
)).id as private_note_id \gset
select set_config('test.activity_private_note_id', :'private_note_id', true);

select sca_core.activity_create_v1(
  'status_update', 'Call brief reviewed; contact details verified.',
  'mission_team', 'action_item', :'call_action_id'
);
select sca_core.activity_create_v1(
  'status_update', 'Closer desk is ready for the scheduled call.',
  'workspace_team', 'action_item', :'call_action_id', '{}'::jsonb, now(),
  'actions', null, null, null, 'human_entry', null,
  '42000000-0000-4000-8000-000000000001'
);
select sca_core.activity_create_v1(
  'call_attempt', 'First attempt reached voicemail.', 'assigned_users',
  'action_item', :'call_action_id',
  '{"contact_reached":false,"channel":"phone","attempt_number":1}'
);
select (sca_core.activity_create_v1(
  'call_connected',
  'Sofia confirmed active interest and requested revised pricing plus port documentation.',
  'assigned_users', 'action_item', :'call_action_id',
  '{"contact_reached":true,"person_spoken_to":"Sofia Marin","interest":"active","objection":"pricing range","requested_information":["revised pricing","port documents"],"next_follow_up_at":"2026-08-10T09:30:00Z"}',
  now(), 'actions', null, null, 'interested'
)).id as connected_call_id \gset
select set_config('test.activity_connected_call_id', :'connected_call_id', true);

select (sca_core.activity_create_v1(
  'message_summary', 'Buyer email confirms the requested pricing pack; message remains in Inbox.',
  'assigned_users', 'action_item', :'call_action_id', '{}'::jsonb, now(),
  'inbox', 'inbox_message', '72000000-0000-4000-8000-000000000001',
  null, 'human_entry', 'inbox:message:72000000-0000-4000-8000-000000000001',
  null, '{}'::uuid[], jsonb_build_array(jsonb_build_object(
    'linked_type', 'inbox_thread', 'linked_id', '72000000-0000-4000-8000-000000000002',
    'link_role', 'message_context', 'source_workspace', 'inbox'
  ))
)).id as message_summary_id \gset
select set_config('test.activity_message_summary_id', :'message_summary_id', true);

do $$
begin
  begin
    perform sca_core.actions_complete_item_v1(
      current_setting('test.activity_call_action_id')::uuid,
      'Attempt completion before a shared outcome'
    );
    raise exception 'Outcome-gated completion unexpectedly succeeded';
  exception when others then
    if position('Completion outcome Activity is required' in sqlerrm) = 0 then raise; end if;
  end;
end;
$$;

select (sca_core.activity_create_v1(
  'outcome',
  'Buyer is interested. Send revised pricing and port documentation before the next call.',
  'assigned_users', 'action_item', :'call_action_id',
  '{"interest":"active","objection":"pricing range","requested_information":["revised pricing","port documents"],"next_follow_up_at":"2026-08-10T09:30:00Z"}',
  now(), 'actions', null, null, 'follow_up_required'
)).id as outcome_id \gset
select set_config('test.activity_outcome_id', :'outcome_id', true);
select sca_core.actions_complete_item_v1(:'call_action_id', 'Commercial outcome recorded');

select (sca_core.activity_create_follow_up_action_v1(
  :'connected_call_id', 'Send Sofia revised pricing pack',
  'Deliver requested pricing and port documents before the next call',
  '22000000-0000-4000-8000-000000000002', now() + interval '2 days', 'high'
)).id as follow_up_id \gset
select set_config('test.activity_follow_up_id', :'follow_up_id', true);
reset role;

-- Research workflow retains findings and document references without creating duplicate profiles.
set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"12000000-0000-4000-8000-000000000003","role":"authenticated","organisation_id":"32000000-0000-4000-8000-000000000001"}',
  true
);
select sca_core.activity_create_v1(
  'research_update',
  'Two Zambian refinery candidates found; ownership evidence still needs verification.',
  'workspace_team', 'action_item', :'research_action_id',
  '{"candidate_count":2,"confidence":"medium","quality_note":"ownership evidence pending"}',
  now(), 'actions', null, null, 'candidates_found', 'human_entry', null,
  '42000000-0000-4000-8000-000000000002', '{}'::uuid[],
  jsonb_build_array(jsonb_build_object(
    'linked_type', 'document', 'linked_id', '82000000-0000-4000-8000-000000000001',
    'link_role', 'research_evidence', 'source_workspace', 'documents'
  ))
);

do $$
declare v_visible integer;
begin
  select count(*) into v_visible from sca_core.activity
  where id = current_setting('test.activity_instruction_id')::uuid;
  if v_visible <> 1 then raise exception 'Explicit assigned-user audience lost visibility'; end if;
  begin
    perform sca_core.actions_set_priority_v1(
      current_setting('test.activity_call_action_id')::uuid,
      'low', 'Activity visibility must not grant Actions authority'
    );
    raise exception 'Activity visibility incorrectly granted domain mutation authority';
  exception when others then
    if position('not permitted' in sqlerrm) = 0 then raise; end if;
  end;
end;
$$;
reset role;

-- An unassigned same-organisation actor sees organisation scope only.
set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"12000000-0000-4000-8000-000000000004","role":"authenticated","organisation_id":"32000000-0000-4000-8000-000000000001"}',
  true
);
do $$
declare v_org integer; v_private integer; v_director integer; v_call integer;
begin
  select count(*) into v_org from sca_core.activity
  where id = current_setting('test.activity_organisation_note_id')::uuid;
  select count(*) into v_private from sca_core.activity
  where id = current_setting('test.activity_private_note_id')::uuid;
  select count(*) into v_director from sca_core.activity
  where id = current_setting('test.activity_director_note_id')::uuid;
  select count(*) into v_call from sca_core.activity
  where primary_subject_type = 'action_item'
    and primary_subject_id = current_setting('test.activity_call_action_id')::uuid;
  if v_org <> 1 then raise exception 'Organisation Activity was not visible to an active member'; end if;
  if v_private <> 0 or v_director <> 0 or v_call <> 0 then
    raise exception 'Unassigned actor crossed Activity visibility scope';
  end if;
end;
$$;
reset role;

-- Director can review shared outcomes but does not override private notes.
set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"12000000-0000-4000-8000-000000000001","role":"authenticated","organisation_id":"32000000-0000-4000-8000-000000000001"}',
  true
);
do $$
declare
  v_private integer;
  v_outcome integer;
  v_activity_entries integer;
  v_execution_entries integer;
  v_inbox_summary integer;
  v_follow_up_links integer;
begin
  select count(*) into v_private from sca_core.activity
  where id = current_setting('test.activity_private_note_id')::uuid;
  select count(*) into v_outcome from sca_core.activity
  where id = current_setting('test.activity_outcome_id')::uuid;
  if v_private <> 0 then raise exception 'Director capability overrode private_actor visibility'; end if;
  if v_outcome <> 1 then raise exception 'Director could not review assignee outcome'; end if;

  select count(*) filter (where entry_kind = 'activity'),
         count(*) filter (where entry_kind = 'execution_event')
    into v_activity_entries, v_execution_entries
  from sca_core.activity_get_work_journal_v1(
    'action_item', current_setting('test.activity_call_action_id')::uuid
  );
  if v_activity_entries < 7 then raise exception 'Work Journal omitted visible contextual Activity'; end if;
  if v_execution_entries < 5 then raise exception 'Work Journal omitted authoritative execution events'; end if;

  select count(*) into v_inbox_summary from sca_core.activity
  where id = current_setting('test.activity_message_summary_id')::uuid
    and source_workspace = 'inbox'
    and source_record_type = 'inbox_message'
    and source_record_id = '72000000-0000-4000-8000-000000000001';
  if v_inbox_summary <> 1 then raise exception 'Inbox reference was not preserved as a summary/link'; end if;

  select count(*) into v_follow_up_links
  from sca_core.action_item i
  join sca_core.action_link al on al.action_item_id = i.id
  where i.id = current_setting('test.activity_follow_up_id')::uuid
    and i.source_record_type = 'activity'
    and i.source_record_id = current_setting('test.activity_connected_call_id')::uuid
    and al.linked_type = 'activity'
    and al.linked_id = current_setting('test.activity_connected_call_id')::uuid;
  if v_follow_up_links <> 1 then raise exception 'Explicit follow-up Action lost Activity linkage'; end if;
end;
$$;
reset role;

-- Other organisations see no Activity from the first organisation.
set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"12000000-0000-4000-8000-000000000005","role":"authenticated","organisation_id":"32000000-0000-4000-8000-000000000002"}',
  true
);
do $$
declare v_count integer;
begin
  select count(*) into v_count from sca_core.activity;
  if v_count <> 0 then raise exception 'Activity organisation isolation failed'; end if;
end;
$$;
reset role;

-- Material Activity cannot be hard-deleted, even through a privileged direct path.
do $$
begin
  begin
    delete from sca_core.activity
    where id = current_setting('test.activity_outcome_id')::uuid;
    raise exception 'Protected Activity was unexpectedly hard-deleted';
  exception when others then
    if position('cannot be hard-deleted' in sqlerrm) = 0 then raise; end if;
  end;
end;
$$;

rollback;
