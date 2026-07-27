begin;

create extension if not exists pgcrypto;

create schema if not exists sca_meta;
create schema if not exists sca_core;
create schema if not exists sca_audit;

create type sca_meta.architecture_status as enum (
  'draft',
  'in_review',
  'approved',
  'effective',
  'locked',
  'retired',
  'superseded'
);

create type sca_core.provenance_kind as enum (
  'human_entry',
  'external_integration',
  'dataset_import',
  'document_extraction',
  'system_calculation',
  'ai_assisted_preparation',
  'authorised_automation',
  'migration',
  'correction'
);

create table sca_meta.business_object_type (
  id uuid primary key default gen_random_uuid(),
  type_key text not null unique,
  canonical_name text not null,
  description text not null,
  object_family text not null,
  architecture_status sca_meta.architecture_status not null default 'draft',
  identity_strategy jsonb not null default '{}'::jsonb,
  ownership_model jsonb not null default '{}'::jsonb,
  classification_rules jsonb not null default '{}'::jsonb,
  attribute_schema jsonb not null default '{}'::jsonb,
  lifecycle_policy jsonb not null default '{}'::jsonb,
  relationship_policy jsonb not null default '{}'::jsonb,
  provenance_requirements jsonb not null default '{}'::jsonb,
  retention_policy jsonb not null default '{}'::jsonb,
  versioning_policy jsonb not null default '{}'::jsonb,
  implementation_mappings jsonb not null default '{}'::jsonb,
  architecture_version text not null,
  effective_from timestamptz,
  effective_to timestamptz,
  created_at timestamptz not null default now(),
  created_by uuid,
  updated_at timestamptz not null default now(),
  updated_by uuid,
  constraint business_object_type_effective_period_chk
    check (effective_to is null or effective_from is null or effective_to > effective_from)
);

comment on table sca_meta.business_object_type is
  'Canonical registry of governed Business Object Types. This table defines architecture metadata rather than domain runtime records.';

create table sca_core.business_object (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null,
  object_type_id uuid not null references sca_meta.business_object_type(id),
  display_label text not null,
  owner_actor_id uuid,
  classification_key text,
  current_version_no bigint not null default 0,
  current_lifecycle_state_key text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  created_by uuid,
  retired_at timestamptz,
  retired_by uuid,
  constraint business_object_current_version_nonnegative_chk
    check (current_version_no >= 0)
);

create index business_object_org_type_idx
  on sca_core.business_object (organisation_id, object_type_id);

create index business_object_owner_idx
  on sca_core.business_object (organisation_id, owner_actor_id)
  where owner_actor_id is not null;

create table sca_core.business_object_version (
  id uuid primary key default gen_random_uuid(),
  business_object_id uuid not null references sca_core.business_object(id),
  version_no bigint not null,
  data jsonb not null,
  effective_from timestamptz not null,
  effective_to timestamptz,
  recorded_at timestamptz not null default now(),
  recorded_by uuid,
  provenance_kind sca_core.provenance_kind not null,
  provenance_ref text,
  change_reason text,
  supersedes_version_id uuid references sca_core.business_object_version(id),
  content_hash text generated always as (encode(digest(data::text, 'sha256'), 'hex')) stored,
  unique (business_object_id, version_no),
  constraint business_object_version_positive_chk check (version_no > 0),
  constraint business_object_version_effective_period_chk
    check (effective_to is null or effective_to > effective_from)
);

create unique index business_object_one_open_version_idx
  on sca_core.business_object_version (business_object_id)
  where effective_to is null;

create index business_object_version_effective_idx
  on sca_core.business_object_version (business_object_id, effective_from desc);

create table sca_core.business_object_identifier (
  id uuid primary key default gen_random_uuid(),
  business_object_id uuid not null references sca_core.business_object(id),
  namespace text not null,
  identifier_value text not null,
  source_system text,
  is_primary boolean not null default false,
  effective_from timestamptz not null default now(),
  effective_to timestamptz,
  recorded_at timestamptz not null default now(),
  recorded_by uuid,
  unique (namespace, identifier_value),
  constraint business_object_identifier_effective_period_chk
    check (effective_to is null or effective_to > effective_from)
);

create unique index business_object_one_primary_identifier_idx
  on sca_core.business_object_identifier (business_object_id)
  where is_primary and effective_to is null;

create table sca_audit.business_object_event (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null,
  business_object_id uuid not null references sca_core.business_object(id),
  event_type text not null,
  actor_id uuid,
  occurred_at timestamptz not null default now(),
  request_id uuid,
  correlation_id uuid,
  event_data jsonb not null default '{}'::jsonb
);

create index business_object_event_object_time_idx
  on sca_audit.business_object_event (business_object_id, occurred_at desc);

create or replace function sca_core.touch_business_object_type()
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

create trigger business_object_type_touch_updated_at
before update on sca_meta.business_object_type
for each row execute function sca_core.touch_business_object_type();

alter table sca_meta.business_object_type enable row level security;
alter table sca_core.business_object enable row level security;
alter table sca_core.business_object_version enable row level security;
alter table sca_core.business_object_identifier enable row level security;
alter table sca_audit.business_object_event enable row level security;

comment on schema sca_core is
  'Canonical Sapphire Core runtime schema for governed Business Object identities and versions.';

comment on table sca_core.business_object is
  'Stable identity for a Business Object. Mutable business truth is stored as immutable versions.';

comment on table sca_core.business_object_version is
  'Append-only bitemporal-style version history for Business Object truth.';

comment on table sca_core.business_object_identifier is
  'Governed external or internal identifiers attached to stable Business Object identities.';

comment on table sca_audit.business_object_event is
  'Append-only audit events relating to Business Object creation, versioning, correction, and retirement.';

commit;
