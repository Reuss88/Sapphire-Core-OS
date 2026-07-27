begin;

create or replace function sca_core.register_business_object_type(
  p_type_key text,
  p_canonical_name text,
  p_description text,
  p_object_family text,
  p_architecture_version text,
  p_attribute_schema jsonb default '{}'::jsonb,
  p_identity_strategy jsonb default '{}'::jsonb,
  p_ownership_model jsonb default '{}'::jsonb
)
returns uuid
language plpgsql
security definer
set search_path = pg_catalog, public, sca_meta, sca_core
as $$
declare
  v_id uuid;
begin
  if nullif(trim(p_type_key), '') is null then
    raise exception 'type_key is required';
  end if;

  insert into sca_meta.business_object_type (
    type_key,
    canonical_name,
    description,
    object_family,
    architecture_version,
    attribute_schema,
    identity_strategy,
    ownership_model
  ) values (
    lower(trim(p_type_key)),
    trim(p_canonical_name),
    trim(p_description),
    trim(p_object_family),
    trim(p_architecture_version),
    coalesce(p_attribute_schema, '{}'::jsonb),
    coalesce(p_identity_strategy, '{}'::jsonb),
    coalesce(p_ownership_model, '{}'::jsonb)
  )
  returning id into v_id;

  return v_id;
end;
$$;

create or replace function sca_core.create_business_object(
  p_organisation_id uuid,
  p_type_key text,
  p_display_label text,
  p_data jsonb,
  p_effective_from timestamptz default now(),
  p_owner_actor_id uuid default null,
  p_classification_key text default null,
  p_provenance_kind sca_core.provenance_kind default 'human_entry',
  p_provenance_ref text default null,
  p_change_reason text default 'Initial creation',
  p_actor_id uuid default null
)
returns uuid
language plpgsql
security definer
set search_path = pg_catalog, public, sca_meta, sca_core, sca_audit
as $$
declare
  v_type_id uuid;
  v_object_id uuid;
begin
  if p_organisation_id is null then
    raise exception 'organisation_id is required';
  end if;

  if nullif(trim(p_display_label), '') is null then
    raise exception 'display_label is required';
  end if;

  if p_data is null or jsonb_typeof(p_data) <> 'object' then
    raise exception 'data must be a JSON object';
  end if;

  select id into v_type_id
  from sca_meta.business_object_type
  where type_key = lower(trim(p_type_key))
    and architecture_status in ('approved', 'effective', 'locked');

  if v_type_id is null then
    raise exception 'No approved, effective, or locked Business Object Type found for %', p_type_key;
  end if;

  insert into sca_core.business_object (
    organisation_id,
    object_type_id,
    display_label,
    owner_actor_id,
    classification_key,
    current_version_no,
    created_by
  ) values (
    p_organisation_id,
    v_type_id,
    trim(p_display_label),
    p_owner_actor_id,
    p_classification_key,
    1,
    p_actor_id
  )
  returning id into v_object_id;

  insert into sca_core.business_object_version (
    business_object_id,
    version_no,
    data,
    effective_from,
    recorded_by,
    provenance_kind,
    provenance_ref,
    change_reason
  ) values (
    v_object_id,
    1,
    p_data,
    coalesce(p_effective_from, now()),
    p_actor_id,
    p_provenance_kind,
    p_provenance_ref,
    p_change_reason
  );

  insert into sca_audit.business_object_event (
    organisation_id,
    business_object_id,
    event_type,
    actor_id,
    event_data
  ) values (
    p_organisation_id,
    v_object_id,
    'business_object.created',
    p_actor_id,
    jsonb_build_object('type_key', lower(trim(p_type_key)), 'version_no', 1)
  );

  return v_object_id;
end;
$$;

create or replace function sca_core.add_business_object_version(
  p_business_object_id uuid,
  p_data jsonb,
  p_effective_from timestamptz default now(),
  p_provenance_kind sca_core.provenance_kind default 'human_entry',
  p_provenance_ref text default null,
  p_change_reason text default null,
  p_actor_id uuid default null
)
returns bigint
language plpgsql
security definer
set search_path = pg_catalog, public, sca_core, sca_audit
as $$
declare
  v_org_id uuid;
  v_current_no bigint;
  v_new_no bigint;
  v_current_version_id uuid;
begin
  if p_data is null or jsonb_typeof(p_data) <> 'object' then
    raise exception 'data must be a JSON object';
  end if;

  select organisation_id, current_version_no
    into v_org_id, v_current_no
  from sca_core.business_object
  where id = p_business_object_id
  for update;

  if not found then
    raise exception 'Business Object % not found', p_business_object_id;
  end if;

  select id into v_current_version_id
  from sca_core.business_object_version
  where business_object_id = p_business_object_id
    and effective_to is null
  order by version_no desc
  limit 1;

  if v_current_version_id is not null then
    update sca_core.business_object_version
      set effective_to = coalesce(p_effective_from, now())
    where id = v_current_version_id;
  end if;

  v_new_no := v_current_no + 1;

  insert into sca_core.business_object_version (
    business_object_id,
    version_no,
    data,
    effective_from,
    recorded_by,
    provenance_kind,
    provenance_ref,
    change_reason,
    supersedes_version_id
  ) values (
    p_business_object_id,
    v_new_no,
    p_data,
    coalesce(p_effective_from, now()),
    p_actor_id,
    p_provenance_kind,
    p_provenance_ref,
    p_change_reason,
    v_current_version_id
  );

  update sca_core.business_object
    set current_version_no = v_new_no
  where id = p_business_object_id;

  insert into sca_audit.business_object_event (
    organisation_id,
    business_object_id,
    event_type,
    actor_id,
    event_data
  ) values (
    v_org_id,
    p_business_object_id,
    'business_object.version_added',
    p_actor_id,
    jsonb_build_object('version_no', v_new_no)
  );

  return v_new_no;
end;
$$;

create or replace function sca_core.add_business_object_identifier(
  p_business_object_id uuid,
  p_namespace text,
  p_identifier_value text,
  p_source_system text default null,
  p_is_primary boolean default false,
  p_actor_id uuid default null
)
returns uuid
language plpgsql
security definer
set search_path = pg_catalog, public, sca_core, sca_audit
as $$
declare
  v_id uuid;
  v_org_id uuid;
begin
  select organisation_id into v_org_id
  from sca_core.business_object
  where id = p_business_object_id;

  if not found then
    raise exception 'Business Object % not found', p_business_object_id;
  end if;

  if p_is_primary then
    update sca_core.business_object_identifier
      set is_primary = false
    where business_object_id = p_business_object_id
      and is_primary
      and effective_to is null;
  end if;

  insert into sca_core.business_object_identifier (
    business_object_id,
    namespace,
    identifier_value,
    source_system,
    is_primary,
    recorded_by
  ) values (
    p_business_object_id,
    lower(trim(p_namespace)),
    trim(p_identifier_value),
    p_source_system,
    p_is_primary,
    p_actor_id
  ) returning id into v_id;

  insert into sca_audit.business_object_event (
    organisation_id,
    business_object_id,
    event_type,
    actor_id,
    event_data
  ) values (
    v_org_id,
    p_business_object_id,
    'business_object.identifier_added',
    p_actor_id,
    jsonb_build_object('identifier_id', v_id, 'namespace', lower(trim(p_namespace)))
  );

  return v_id;
end;
$$;

create or replace function sca_core.get_business_object_snapshot(
  p_business_object_id uuid,
  p_effective_at timestamptz default now()
)
returns table (
  business_object_id uuid,
  organisation_id uuid,
  type_key text,
  display_label text,
  version_no bigint,
  data jsonb,
  effective_from timestamptz,
  effective_to timestamptz,
  recorded_at timestamptz,
  provenance_kind sca_core.provenance_kind,
  provenance_ref text
)
language sql
security invoker
set search_path = pg_catalog, public, sca_meta, sca_core
as $$
  select
    bo.id,
    bo.organisation_id,
    bot.type_key,
    bo.display_label,
    bov.version_no,
    bov.data,
    bov.effective_from,
    bov.effective_to,
    bov.recorded_at,
    bov.provenance_kind,
    bov.provenance_ref
  from sca_core.business_object bo
  join sca_meta.business_object_type bot on bot.id = bo.object_type_id
  join lateral (
    select v.*
    from sca_core.business_object_version v
    where v.business_object_id = bo.id
      and v.effective_from <= p_effective_at
      and (v.effective_to is null or v.effective_to > p_effective_at)
    order by v.version_no desc
    limit 1
  ) bov on true
  where bo.id = p_business_object_id;
$$;

revoke all on function sca_core.register_business_object_type(text, text, text, text, text, jsonb, jsonb, jsonb) from public;
revoke all on function sca_core.create_business_object(uuid, text, text, jsonb, timestamptz, uuid, text, sca_core.provenance_kind, text, text, uuid) from public;
revoke all on function sca_core.add_business_object_version(uuid, jsonb, timestamptz, sca_core.provenance_kind, text, text, uuid) from public;
revoke all on function sca_core.add_business_object_identifier(uuid, text, text, text, boolean, uuid) from public;

grant execute on function sca_core.get_business_object_snapshot(uuid, timestamptz) to authenticated;

commit;
