begin;

create or replace function sca_core.register_lifecycle_definition(
  p_type_key text,
  p_canonical_name text,
  p_description text,
  p_states jsonb default '[]'::jsonb,
  p_transitions jsonb default '[]'::jsonb
)
returns uuid
language plpgsql
security definer
set search_path = pg_catalog, public, sca_meta
as $$
declare
  v_id uuid;
begin
  if nullif(trim(p_type_key), '') is null then
    raise exception 'type_key is required';
  end if;

  insert into sca_meta.lifecycle_definition (
    type_key,
    canonical_name,
    description,
    states,
    transitions
  ) values (
    lower(trim(p_type_key)),
    trim(p_canonical_name),
    trim(p_description),
    coalesce(p_states, '[]'::jsonb),
    coalesce(p_transitions, '[]'::jsonb)
  ) returning id into v_id;

  return v_id;
end;
$$;

create or replace function sca_core.get_lifecycle_definition(
  p_type_key text
)
returns table (
  id uuid,
  type_key text,
  canonical_name text,
  description text,
  states jsonb,
  transitions jsonb,
  created_at timestamptz,
  updated_at timestamptz
)
language sql
security invoker
set search_path = pg_catalog, public, sca_meta
as $$
  select id, type_key, canonical_name, description, states, transitions, created_at, updated_at
  from sca_meta.lifecycle_definition
  where type_key = lower(trim(p_type_key));
$$;

revoke all on function sca_core.register_lifecycle_definition(text, text, text, jsonb, jsonb) from public;
grant execute on function sca_core.get_lifecycle_definition(text) to authenticated;

commit;
