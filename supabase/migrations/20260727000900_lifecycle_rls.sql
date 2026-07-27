begin;

-- organisation-scoped RLS and read policies
create or replace function sca_core.current_organisation_id()
returns uuid
language sql
stable
security invoker
set search_path = pg_catalog, public
as $$
  select nullif(auth.jwt() ->> 'organisation_id','')::uuid;
$$;

-- allow authenticated users to read lifecycle definitions metadata
create policy lifecycle_definition_select_all on sca_meta.lifecycle_definition for select to authenticated using (true);

-- allow reads of published lifecycle versions
create policy lifecycle_definition_version_select_published on sca_meta.lifecycle_definition_version for select to authenticated using (published);

-- runtime RLS: restrict lifecycle instances and runtime tables to organisation scope
create policy lifecycle_instance_select_same_organisation on sca_core.lifecycle_instance for select to authenticated using (organisation_id = sca_core.current_organisation_id());
create policy lifecycle_state_instance_select_same_organisation on sca_core.lifecycle_state_instance for select to authenticated using (exists (select 1 from sca_core.lifecycle_instance li where li.id = lifecycle_instance_id and li.organisation_id = sca_core.current_organisation_id()));
create policy lifecycle_transition_request_select_same_organisation on sca_core.lifecycle_transition_request for select to authenticated using (exists (select 1 from sca_core.lifecycle_instance li where li.id = lifecycle_instance_id and li.organisation_id = sca_core.current_organisation_id()));
create policy lifecycle_transition_evaluation_select_same_organisation on sca_core.lifecycle_transition_evaluation for select to authenticated using (exists (select 1 from sca_core.lifecycle_transition_request ltr join sca_core.lifecycle_instance li on ltr.lifecycle_instance_id = li.id where ltr.id = lifecycle_transition_evaluation.transition_request_id and li.organisation_id = sca_core.current_organisation_id()));
create policy lifecycle_transition_event_select_same_organisation on sca_core.lifecycle_transition_event for select to authenticated using (exists (select 1 from sca_core.lifecycle_instance li where li.id = lifecycle_instance_id and li.organisation_id = sca_core.current_organisation_id()));
create policy lifecycle_event_select_same_organisation on sca_audit.lifecycle_event for select to authenticated using (organisation_id = sca_core.current_organisation_id());

-- allow inserts into audit and runtime write paths only via server-side functions (security definer) by revoking public execute on mutating functions above. We rely on functions being SECURITY DEFINER.

commit;
