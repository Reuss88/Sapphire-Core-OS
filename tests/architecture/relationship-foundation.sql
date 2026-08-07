-- Phase 3 smoke tests for the Relationship Foundation.
-- Execute after applying Phase 2 and Phase 3 migrations in an isolated test database.

begin;

insert into sca_meta.business_object_type (
  type_key,
  canonical_name,
  description,
  object_family,
  architecture_status,
  architecture_version
) values
  ('test_source', 'Test Source', 'Temporary source type.', 'test', 'locked', '0.91'),
  ('test_target', 'Test Target', 'Temporary target type.', 'test', 'locked', '0.91');

select sca_core.create_business_object(
  '00000000-0000-0000-0000-000000000001'::uuid,
  'test_source',
  'Source A',
  '{"name":"Source A"}'::jsonb,
  now(),
  null,
  'internal',
  'migration',
  'phase-3-test',
  'Create source object',
  null
) as source_object_id \gset

select sca_core.create_business_object(
  '00000000-0000-0000-0000-000000000001'::uuid,
  'test_target',
  'Target A',
  '{"name":"Target A"}'::jsonb,
  now(),
  null,
  'internal',
  'migration',
  'phase-3-test',
  'Create target object',
  null
) as target_object_id \gset

select sca_core.register_relationship_type(
  'test_relationship',
  'Test Relationship',
  'Temporary relationship type used by architecture tests.',
  'test',
  'test_source',
  'test_target',
  'directed',
  'source',
  'target',
  'one_to_many',
  '0.91',
  null,
  false
) as relationship_type_id \gset

update sca_meta.relationship_type
set architecture_status = 'locked', effective_from = now() - interval '1 minute'
where id = :'relationship_type_id'::uuid;

select sca_core.create_relationship(
  '00000000-0000-0000-0000-000000000001'::uuid,
  'test_relationship',
  :'source_object_id'::uuid,
  :'target_object_id'::uuid,
  '{"strength":"initial"}'::jsonb,
  now(),
  'migration',
  'phase-3-test',
  'Initial test relationship',
  null
) as relationship_id \gset

select sca_core.add_relationship_version(
  :'relationship_id'::uuid,
  '{"strength":"updated"}'::jsonb,
  now() + interval '1 second',
  'correction',
  'phase-3-test',
  'Verify append-only versioning',
  null
);

select sca_core.add_relationship_identifier(
  :'relationship_id'::uuid,
  'test',
  'REL-A',
  'architecture-test',
  true,
  null
);

select set_config('test.source_object_id', :'source_object_id', true);
select set_config('test.target_object_id', :'target_object_id', true);
select set_config('test.relationship_id', :'relationship_id', true);

do $$
declare
  v_relationship_id uuid := current_setting('test.relationship_id')::uuid;
  v_count integer;
  v_current bigint;
  v_open_count integer;
  v_event_count integer;
begin
  select count(*) into v_count
  from sca_core.relationship_version
  where relationship_id = v_relationship_id;

  if v_count <> 2 then
    raise exception 'Expected 2 Relationship versions, found %', v_count;
  end if;

  select current_version_no into v_current
  from sca_core.relationship
  where id = v_relationship_id;

  if v_current <> 2 then
    raise exception 'Expected current_version_no 2, found %', v_current;
  end if;

  select count(*) into v_open_count
  from sca_core.relationship_version
  where relationship_id = v_relationship_id
    and effective_to is null;

  if v_open_count <> 1 then
    raise exception 'Expected exactly one open Relationship version, found %', v_open_count;
  end if;

  select count(*) into v_event_count
  from sca_audit.relationship_event
  where relationship_id = v_relationship_id;

  if v_event_count < 3 then
    raise exception 'Expected at least 3 Relationship events, found %', v_event_count;
  end if;
end;
$$;

select *
from sca_core.get_relationship_snapshot(
  :'relationship_id'::uuid,
  now() + interval '2 seconds'
);

select *
from sca_core.list_relationships_for_business_object(
  :'source_object_id'::uuid,
  now() + interval '2 seconds',
  'outgoing'
);

do $$
begin
  begin
    perform sca_core.create_relationship(
      '00000000-0000-0000-0000-000000000001'::uuid,
      'missing_relationship_type',
      current_setting('test.source_object_id')::uuid,
      current_setting('test.target_object_id')::uuid,
      '{}'::jsonb,
      now(),
      'migration',
      'phase-3-test',
      'Expected failure',
      null
    );
    raise exception 'Expected invalid Relationship Type rejection';
  exception
    when others then
      if position('No approved, effective, or locked Relationship Type' in sqlerrm) = 0 then
        raise;
      end if;
  end;
end;
$$;

do $$
begin
  begin
    perform sca_core.create_relationship(
      '00000000-0000-0000-0000-000000000001'::uuid,
      'test_relationship',
      current_setting('test.target_object_id')::uuid,
      current_setting('test.source_object_id')::uuid,
      '{}'::jsonb,
      now(),
      'migration',
      'phase-3-test',
      'Expected participant type failure',
      null
    );
    raise exception 'Expected invalid participant type rejection';
  exception
    when others then
      if position('incompatible' in sqlerrm) = 0 then
        raise;
      end if;
  end;
end;
$$;

select sca_core.retire_relationship(
  :'relationship_id'::uuid,
  now() + interval '3 seconds',
  'Complete test',
  null
);

do $$
declare
  v_relationship_id uuid := current_setting('test.relationship_id')::uuid;
  v_active boolean;
  v_retired_at timestamptz;
begin
  select is_active, retired_at
    into v_active, v_retired_at
  from sca_core.relationship
  where id = v_relationship_id;

  if v_active or v_retired_at is null then
    raise exception 'Relationship retirement behaviour failed';
  end if;
end;
$$;

rollback;
