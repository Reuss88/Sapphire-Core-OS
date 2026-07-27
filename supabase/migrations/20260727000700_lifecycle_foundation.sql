begin;

create schema if not exists sca_lifecycle;

create table sca_meta.lifecycle_definition (
  id uuid primary key default gen_random_uuid(),
  type_key text not null unique,
  canonical_name text not null,
  description text not null,
  states jsonb not null default '[]'::jsonb,
  transitions jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table sca_meta.lifecycle_definition is
  'Canonical registry of lifecycle definitions (states and transitions) used by runtime objects.';

create or replace function sca_lifecycle.touch_lifecycle_definition()
returns trigger
language plpgsql
security invoker
set search_path = pg_catalog, public, sca_meta
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

create trigger lifecycle_definition_touch_updated_at
before update on sca_meta.lifecycle_definition
for each row execute function sca_lifecycle.touch_lifecycle_definition();

alter table sca_meta.lifecycle_definition enable row level security;

commit;
