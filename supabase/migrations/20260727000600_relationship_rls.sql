begin;

create policy relationship_select_same_organisation
on sca_core.relationship
for select
to authenticated
using (organisation_id = sca_core.current_organisation_id());

create policy relationship_version_select_same_organisation
on sca_core.relationship_version
for select
to authenticated
using (
  exists (
    select 1
    from sca_core.relationship r
    where r.id = relationship_id
      and r.organisation_id = sca_core.current_organisation_id()
  )
);

create policy relationship_participant_select_same_organisation
on sca_core.relationship_participant
for select
to authenticated
using (
  exists (
    select 1
    from sca_core.relationship r
    where r.id = relationship_id
      and r.organisation_id = sca_core.current_organisation_id()
  )
);

create policy relationship_identifier_select_same_organisation
on sca_core.relationship_identifier
for select
to authenticated
using (
  exists (
    select 1
    from sca_core.relationship r
    where r.id = relationship_id
      and r.organisation_id = sca_core.current_organisation_id()
  )
);

create policy relationship_event_select_same_organisation
on sca_audit.relationship_event
for select
to authenticated
using (organisation_id = sca_core.current_organisation_id());

create policy relationship_type_select_effective
on sca_meta.relationship_type
for select
to authenticated
using (architecture_status in ('approved', 'effective', 'locked'));

comment on table sca_core.relationship is
  'Interim organisation-scoped read access. Future Identity, Access & Security Architecture may replace the JWT organisation mechanism without changing Relationship semantics.';

commit;
