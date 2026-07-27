-- Phase 2 smoke tests for the Business Object Foundation.
-- Execute after applying Supabase migrations in an isolated test database.

begin;

insert into sca_meta.business_object_type (
  type_key,
  canonical_name,
  description,
  object_family,
  architecture_status,
  architecture_version
) values (
  'test_object',
  'Test Object',
  'Temporary object type used by architecture tests.',
  'test',
  'locked',
  '0.91'
);

select sca_core.create_business_object(
  '00000000-0000-0000-0000-000000000001'::uuid,
  'test_object',
  'Object A',
  '{"name":"Object A"}'::jsonb,
  now(),
  null,
  'internal',
  'migration',
  'phase-2-test',
  'Initial test object',
  null
) as business_object_id \gset

select sca_core.add_business_object_version(
  :'business_object_id'::uuid,
  '{"name":"Object A","status":"updated"}'::jsonb,
  now() + interval '1 second',
  'correction',
  'phase-2-test',
  'Verify append-only versioning',
  null
);

select sca_core.add_business_object_identifier(
  :'business_object_id'::uuid,
  'test',
  'OBJECT-A',
  'architecture-test',
  true,
  null
);

do $$
declare
  v_count integer;
  v_current bigint;
begin
  select count(*) into v_count
  from sca_core.business_object_version
  where business_object_id = :'business_object_id'::uuid;

  if v_count <> 2 then
    raise exception 'Expected 2 Business Object versions, found %', v_count;
  end if;

  select current_version_no into v_current
  from sca_core.business_object
  where id = :'business_object_id'::uuid;

  if v_current <> 2 then
    raise exception 'Expected current_version_no 2, found %', v_current;
  end if;
end;
$$;

rollback;
