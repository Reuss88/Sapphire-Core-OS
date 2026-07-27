begin;

create or replace function sca_core.current_organisation_id()
returns uuid
language sql
stable
security invoker
set search_path = pg_catalog, public
as $$
  select nullif(auth.jwt() ->> 'organisation_id', '')::uuid;
$$;

create policy business_object_select_same_organisation
on sca_core.business_object
for select
to authenticated
using (organisation_id = sca_core.current_organisation_id());

create policy business_object_version_select_same_organisation
on sca_core.business_object_version
for select
to authenticated
using (
  exists (
    select 1
    from sca_core.business_object bo
    where bo.id = business_object_id
      and bo.organisation_id = sca_core.current_organisation_id()
  )
);

create policy business_object_identifier_select_same_organisation
on sca_core.business_object_identifier
for select
to authenticated
using (
  exists (
    select 1
    from sca_core.business_object bo
    where bo.id = business_object_id
      and bo.organisation_id = sca_core.current_organisation_id()
  )
);

create policy business_object_event_select_same_organisation
on sca_audit.business_object_event
for select
to authenticated
using (organisation_id = sca_core.current_organisation_id());

create policy business_object_type_select_effective
on sca_meta.business_object_type
for select
to authenticated
using (architecture_status in ('approved', 'effective', 'locked'));

comment on function sca_core.current_organisation_id() is
  'Reads the current organisation scope from the authenticated JWT. Production identity architecture may replace this function without changing Business Object semantics.';

commit;
