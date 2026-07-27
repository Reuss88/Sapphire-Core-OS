begin;

create or replace function sca_core.register_relationship_type(
  p_type_key text,
  p_canonical_name text,
  p_description text,
  p_relationship_family text,
  p_source_object_type_key text,
  p_target_object_type_key text,
  p_directionality sca_meta.relationship_direction,
  p_source_role text,
  p_target_role text,
  p_cardinality sca_meta.relationship_cardinality,
  p_architecture_version text,
  p_inverse_name text default null,
  p_allows_self_reference boolean default false
)
returns uuid
language plpgsql
security definer
set search_path = pg_catalog, public, sca_meta, sca_core
as $$
declare
  v_source_type_id uuid;
  v_target_type_id uuid;
  v_id uuid;
begin
  if nullif(trim(p_type_key), '') is null then
    raise exception 'type_key is required';
  end if;

  select id into v_source_type_id
  from sca_meta.business_object_type
  where type_key = lower(trim(p_source_object_type_key));

  select id into v_target_type_id
  from sca_meta.business_object_type
  where type_key = lower(trim(p_target_object_type_key));

  if v_source_type_id is null or v_target_type_id is null then
    raise exception 'Source and target Business Object Types must exist';
  end if;

  insert into sca_meta.relationship_type (
    type_key,
    canonical_name,
    description,
    relationship_family,
    source_object_type_id,
    target_object_type_id,
    directionality,
    inverse_name,
    source_role,
    target_role,
    cardinality,
    allows_self_reference,
    architecture_version
  ) values (
    lower(trim(p_type_key)),
    trim(p_canonical_name),
    trim(p_description),
    trim(p_relationship_family),
    v_source_type_id,
    v_target_type_id,
    p_directionality,
    p_inverse_name,
    trim(p_source_role),
    trim(p_target_role),
    p_cardinality,
    p_allows_self_reference,
    trim(p_architecture_version)
  )
  returning id into v_id;

  return v_id;
end;
$$;

create or replace function sca_core.create_relationship(
  p_organisation_id uuid,
  p_relationship_type_key text,
  p_source_business_object_id uuid,
  p_target_business_object_id uuid,
  p_data jsonb default '{}'::jsonb,
  p_effective_from timestamptz default now(),
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
  v_type sca_meta.relationship_type%rowtype;
  v_source_org uuid;
  v_target_org uuid;
  v_source_type uuid;
  v_target_type uuid;
  v_relationship_id uuid;
begin
  if p_organisation_id is null then
    raise exception 'organisation_id is required';
  end if;

  if p_data is null or jsonb_typeof(p_data) <> 'object' then
    raise exception 'data must be a JSON object';
  end if;

  select * into v_type
  from sca_meta.relationship_type
  where type_key = lower(trim(p_relationship_type_key))
    and architecture_status in ('approved', 'effective', 'locked')
    and (effective_from is null or effective_from <= p_effective_from)
    and (effective_to is null or effective_to > p_effective_from);

  if not found then
    raise exception 'No approved, effective, or locked Relationship Type found for %', p_relationship_type_key;
  end if;

  select organisation_id, object_type_id
    into v_source_org, v_source_type
  from sca_core.business_object
  where id = p_source_business_object_id
    and is_active;

  if not found then
    raise exception 'Source Business Object % not found or inactive', p_source_business_object_id;
  end if;

  select organisation_id, object_type_id
    into v_target_org, v_target_type
  from sca_core.business_object
  where id = p_target_business_object_id
    and is_active;

  if not found then
    raise exception 'Target Business Object % not found or inactive', p_target_business_object_id;
  end if;

  if v_source_org <> p_organisation_id or v_target_org <> p_organisation_id then
    raise exception 'Relationship participants must belong to organisation %', p_organisation_id;
  end if;

  if v_source_type <> v_type.source_object_type_id then
    raise exception 'Source Business Object Type is incompatible with Relationship Type %', v_type.type_key;
  end if;

  if v_target_type <> v_type.target_object_type_id then
    raise exception 'Target Business Object Type is incompatible with Relationship Type %', v_type.type_key;
  end if;

  if not v_type.allows_self_reference and p_source_business_object_id = p_target_business_object_id then
    raise exception 'Relationship Type % does not allow self-reference', v_type.type_key;
  end if;

  insert into sca_core.relationship (
    organisation_id,
    relationship_type_id,
    source_business_object_id,
    target_business_object_id,
    current_version_no,
    created_by
  ) values (
    p_organisation_id,
    v_type.id,
    p_source_business_object_id,
    p_target_business_object_id,
    1,
    p_actor_id
  )
  returning id into v_relationship_id;

  insert into sca_core.relationship_version (
    relationship_id,
    version_no,
    source_role,
    target_role,
    data,
    effective_from,
    recorded_by,
    provenance_kind,
    provenance_ref,
    change_reason
  ) values (
    v_relationship_id,
    1,
    v_type.source_role,
    v_type.target_role,
    p_data,
    coalesce(p_effective_from, now()),
    p_actor_id,
    p_provenance_kind,
    p_provenance_ref,
    p_change_reason
  );

  insert into sca_audit.relationship_event (
    organisation_id,
    relationship_id,
    event_type,
    actor_id,
    event_data
  ) values (
    p_organisation_id,
    v_relationship_id,
    'relationship.created',
    p_actor_id,
    jsonb_build_object('type_key', v_type.type_key, 'version_no', 1)
  );

  return v_relationship_id;
end;
$$;

create or replace function sca_core.add_relationship_version(
  p_relationship_id uuid,
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
  v_current_version sca_core.relationship_version%rowtype;
  v_new_no bigint;
begin
  if p_data is null or jsonb_typeof(p_data) <> 'object' then
    raise exception 'data must be a JSON object';
  end if;

  select organisation_id, current_version_no
    into v_org_id, v_current_no
  from sca_core.relationship
  where id = p_relationship_id
    and is_active
  for update;

  if not found then
    raise exception 'Active Relationship % not found', p_relationship_id;
  end if;

  select * into v_current_version
  from sca_core.relationship_version
  where relationship_id = p_relationship_id
    and effective_to is null
  order by version_no desc
  limit 1;

  if found then
    if coalesce(p_effective_from, now()) <= v_current_version.effective_from then
      raise exception 'New effective_from must be later than the current open version effective_from';
    end if;

    update sca_core.relationship_version
      set effective_to = coalesce(p_effective_from, now())
    where id = v_current_version.id;
  end if;

  v_new_no := v_current_no + 1;

  insert into sca_core.relationship_version (
    relationship_id,
    version_no,
    source_role,
    target_role,
    data,
    effective_from,
    recorded_by,
    provenance_kind,
    provenance_ref,
    change_reason,
    supersedes_version_id
  ) values (
    p_relationship_id,
    v_new_no,
    v_current_version.source_role,
    v_current_version.target_role,
    p_data,
    coalesce(p_effective_from, now()),
    p_actor_id,
    p_provenance_kind,
    p_provenance_ref,
    p_change_reason,
    v_current_version.id
  );

  update sca_core.relationship
    set current_version_no = v_new_no
  where id = p_relationship_id;

  insert into sca_audit.relationship_event (
    organisation_id,
    relationship_id,
    event_type,
    actor_id,
    event_data
  ) values (
    v_org_id,
    p_relationship_id,
    'relationship.version_added',
    p_actor_id,
    jsonb_build_object('version_no', v_new_no)
  );

  return v_new_no;
end;
$$;

create or replace function sca_core.retire_relationship(
  p_relationship_id uuid,
  p_retired_at timestamptz default now(),
  p_reason text default null,
  p_actor_id uuid default null
)
returns void
language plpgsql
security definer
set search_path = pg_catalog, public, sca_core, sca_audit
as $$
declare
  v_org_id uuid;
begin
  select organisation_id into v_org_id
  from sca_core.relationship
  where id = p_relationship_id
    and is_active
  for update;

  if not found then
    raise exception 'Active Relationship % not found', p_relationship_id;
  end if;

  update sca_core.relationship_version
    set effective_to = coalesce(p_retired_at, now())
  where relationship_id = p_relationship_id
    and effective_to is null
    and effective_from < coalesce(p_retired_at, now());

  update sca_core.relationship
    set is_active = false,
        retired_at = coalesce(p_retired_at, now()),
        retired_by = p_actor_id
  where id = p_relationship_id;

  insert into sca_audit.relationship_event (
    organisation_id,
    relationship_id,
    event_type,
    actor_id,
    event_data
  ) values (
    v_org_id,
    p_relationship_id,
    'relationship.retired',
    p_actor_id,
    jsonb_build_object('reason', p_reason, 'retired_at', coalesce(p_retired_at, now()))
  );
end;
$$;

create or replace function sca_core.add_relationship_identifier(
  p_relationship_id uuid,
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
  if nullif(trim(p_namespace), '') is null or nullif(trim(p_identifier_value), '') is null then
    raise exception 'namespace and identifier_value are required';
  end if;

  select organisation_id into v_org_id
  from sca_core.relationship
  where id = p_relationship_id;

  if not found then
    raise exception 'Relationship % not found', p_relationship_id;
  end if;

  if p_is_primary then
    update sca_core.relationship_identifier
      set is_primary = false
    where relationship_id = p_relationship_id
      and is_primary
      and effective_to is null;
  end if;

  insert into sca_core.relationship_identifier (
    relationship_id,
    namespace,
    identifier_value,
    source_system,
    is_primary,
    recorded_by
  ) values (
    p_relationship_id,
    lower(trim(p_namespace)),
    trim(p_identifier_value),
    p_source_system,
    p_is_primary,
    p_actor_id
  ) returning id into v_id;

  insert into sca_audit.relationship_event (
    organisation_id,
    relationship_id,
    event_type,
    actor_id,
    event_data
  ) values (
    v_org_id,
    p_relationship_id,
    'relationship.identifier_added',
    p_actor_id,
    jsonb_build_object('identifier_id', v_id, 'namespace', lower(trim(p_namespace)))
  );

  return v_id;
end;
$$;

create or replace function sca_core.get_relationship_snapshot(
  p_relationship_id uuid,
  p_effective_at timestamptz default now()
)
returns table (
  relationship_id uuid,
  organisation_id uuid,
  type_key text,
  source_business_object_id uuid,
  target_business_object_id uuid,
  source_role text,
  target_role text,
  version_no bigint,
  data jsonb,
  effective_from timestamptz,
  effective_to timestamptz,
  recorded_at timestamptz,
  provenance_kind sca_core.provenance_kind,
  provenance_ref text,
  is_active boolean
)
language sql
security invoker
set search_path = pg_catalog, public, sca_meta, sca_core
as $$
  select
    r.id,
    r.organisation_id,
    rt.type_key,
    r.source_business_object_id,
    r.target_business_object_id,
    rv.source_role,
    rv.target_role,
    rv.version_no,
    rv.data,
    rv.effective_from,
    rv.effective_to,
    rv.recorded_at,
    rv.provenance_kind,
    rv.provenance_ref,
    r.is_active
  from sca_core.relationship r
  join sca_meta.relationship_type rt on rt.id = r.relationship_type_id
  join lateral (
    select v.*
    from sca_core.relationship_version v
    where v.relationship_id = r.id
      and v.effective_from <= p_effective_at
      and (v.effective_to is null or v.effective_to > p_effective_at)
    order by v.version_no desc
    limit 1
  ) rv on true
  where r.id = p_relationship_id;
$$;

create or replace function sca_core.list_relationships_for_business_object(
  p_business_object_id uuid,
  p_effective_at timestamptz default now(),
  p_direction text default 'either'
)
returns table (
  relationship_id uuid,
  type_key text,
  traversal_direction text,
  related_business_object_id uuid,
  role_at_subject text,
  role_at_related text,
  effective_from timestamptz,
  effective_to timestamptz,
  data jsonb
)
language sql
security invoker
set search_path = pg_catalog, public, sca_meta, sca_core
as $$
  select
    r.id,
    rt.type_key,
    case when r.source_business_object_id = p_business_object_id then 'outgoing' else 'incoming' end,
    case when r.source_business_object_id = p_business_object_id then r.target_business_object_id else r.source_business_object_id end,
    case when r.source_business_object_id = p_business_object_id then rv.source_role else rv.target_role end,
    case when r.source_business_object_id = p_business_object_id then rv.target_role else rv.source_role end,
    rv.effective_from,
    rv.effective_to,
    rv.data
  from sca_core.relationship r
  join sca_meta.relationship_type rt on rt.id = r.relationship_type_id
  join lateral (
    select v.*
    from sca_core.relationship_version v
    where v.relationship_id = r.id
      and v.effective_from <= p_effective_at
      and (v.effective_to is null or v.effective_to > p_effective_at)
    order by v.version_no desc
    limit 1
  ) rv on true
  where (
    (p_direction in ('either', 'outgoing') and r.source_business_object_id = p_business_object_id)
    or
    (p_direction in ('either', 'incoming') and r.target_business_object_id = p_business_object_id)
  );
$$;

revoke all on function sca_core.register_relationship_type(text, text, text, text, text, text, sca_meta.relationship_direction, text, text, sca_meta.relationship_cardinality, text, text, boolean) from public;
revoke all on function sca_core.create_relationship(uuid, text, uuid, uuid, jsonb, timestamptz, sca_core.provenance_kind, text, text, uuid) from public;
revoke all on function sca_core.add_relationship_version(uuid, jsonb, timestamptz, sca_core.provenance_kind, text, text, uuid) from public;
revoke all on function sca_core.retire_relationship(uuid, timestamptz, text, uuid) from public;
revoke all on function sca_core.add_relationship_identifier(uuid, text, text, text, boolean, uuid) from public;

grant execute on function sca_core.get_relationship_snapshot(uuid, timestamptz) to authenticated;
grant execute on function sca_core.list_relationships_for_business_object(uuid, timestamptz, text) to authenticated;

commit;
