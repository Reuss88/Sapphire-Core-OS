begin;

create type sca_meta.relationship_direction as enum (
  'directed',
  'undirected',
  'reciprocal'
);

create type sca_meta.relationship_cardinality as enum (
  'one_to_one',
  'one_to_many',
  'many_to_one',
  'many_to_many'
);

create table sca_meta.relationship_type (
  id uuid primary key default gen_random_uuid(),
  type_key text not null unique,
  canonical_name text not null,
  description text not null,
  relationship_family text not null,
  source_object_type_id uuid not null references sca_meta.business_object_type(id),
  target_object_type_id uuid not null references sca_meta.business_object_type(id),
  directionality sca_meta.relationship_direction not null,
  inverse_name text,
  source_role text not null,
  target_role text not null,
  cardinality sca_meta.relationship_cardinality not null,
  min_source_participation integer not null default 0,
  max_source_participation integer,
  min_target_participation integer not null default 0,
  max_target_participation integer,
  is_exclusive boolean not null default false,
  is_symmetric boolean not null default false,
  is_transitive boolean not null default false,
  allows_self_reference boolean not null default false,
  composition_semantics boolean not null default false,
  aggregation_semantics boolean not null default false,
  dependency_semantics jsonb not null default '{}'::jsonb,
  validity_rules jsonb not null default '{}'::jsonb,
  ownership_model jsonb not null default '{}'::jsonb,
  provenance_requirements jsonb not null default '{}'::jsonb,
  evidence_requirements jsonb not null default '{}'::jsonb,
  lifecycle_policy jsonb not null default '{}'::jsonb,
  versioning_policy jsonb not null default '{}'::jsonb,
  implementation_mappings jsonb not null default '{}'::jsonb,
  architecture_status sca_meta.architecture_status not null default 'draft',
  architecture_version text not null,
  effective_from timestamptz,
  effective_to timestamptz,
  created_at timestamptz not null default now(),
  created_by uuid,
  updated_at timestamptz not null default now(),
  updated_by uuid,
  constraint relationship_type_participation_chk check (
    min_source_participation >= 0
    and min_target_participation >= 0
    and (max_source_participation is null or max_source_participation >= min_source_participation)
    and (max_target_participation is null or max_target_participation >= min_target_participation)
  ),
  constraint relationship_type_effective_period_chk check (
    effective_to is null or effective_from is null or effective_to > effective_from
  ),
  constraint relationship_type_inverse_chk check (
    directionality <> 'reciprocal' or nullif(trim(inverse_name), '') is not null
  )
);

comment on table sca_meta.relationship_type is
  'Canonical architecture metadata for governed Relationship Types.';

create table sca_core.relationship (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null,
  relationship_type_id uuid not null references sca_meta.relationship_type(id),
  source_business_object_id uuid not null references sca_core.business_object(id),
  target_business_object_id uuid not null references sca_core.business_object(id),
  current_version_no bigint not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  created_by uuid,
  retired_at timestamptz,
  retired_by uuid,
  constraint relationship_current_version_nonnegative_chk check (current_version_no >= 0),
  constraint relationship_retirement_chk check (
    (is_active and retired_at is null)
    or (not is_active and retired_at is not null)
  )
);

create index relationship_org_type_idx
  on sca_core.relationship (organisation_id, relationship_type_id);

create index relationship_source_idx
  on sca_core.relationship (organisation_id, source_business_object_id);

create index relationship_target_idx
  on sca_core.relationship (organisation_id, target_business_object_id);

create table sca_core.relationship_version (
  id uuid primary key default gen_random_uuid(),
  relationship_id uuid not null references sca_core.relationship(id),
  version_no bigint not null,
  source_role text not null,
  target_role text not null,
  data jsonb not null default '{}'::jsonb,
  effective_from timestamptz not null,
  effective_to timestamptz,
  recorded_at timestamptz not null default now(),
  recorded_by uuid,
  provenance_kind sca_core.provenance_kind not null,
  provenance_ref text,
  change_reason text,
  supersedes_version_id uuid references sca_core.relationship_version(id),
  content_hash text generated always as (
    encode(digest((source_role || '|' || target_role || '|' || data::text), 'sha256'), 'hex')
  ) stored,
  unique (relationship_id, version_no),
  constraint relationship_version_positive_chk check (version_no > 0),
  constraint relationship_version_effective_period_chk check (
    effective_to is null or effective_to > effective_from
  )
);

create unique index relationship_one_open_version_idx
  on sca_core.relationship_version (relationship_id)
  where effective_to is null;

create index relationship_version_effective_idx
  on sca_core.relationship_version (relationship_id, effective_from desc);

create table sca_core.relationship_participant (
  id uuid primary key default gen_random_uuid(),
  relationship_id uuid not null references sca_core.relationship(id),
  business_object_id uuid not null references sca_core.business_object(id),
  participant_role text not null,
  ordinal integer,
  effective_from timestamptz not null default now(),
  effective_to timestamptz,
  recorded_at timestamptz not null default now(),
  recorded_by uuid,
  provenance_kind sca_core.provenance_kind not null default 'human_entry',
  provenance_ref text,
  constraint relationship_participant_effective_period_chk check (
    effective_to is null or effective_to > effective_from
  ),
  unique (relationship_id, business_object_id, participant_role, effective_from)
);

create table sca_core.relationship_identifier (
  id uuid primary key default gen_random_uuid(),
  relationship_id uuid not null references sca_core.relationship(id),
  namespace text not null,
  identifier_value text not null,
  source_system text,
  is_primary boolean not null default false,
  effective_from timestamptz not null default now(),
  effective_to timestamptz,
  recorded_at timestamptz not null default now(),
  recorded_by uuid,
  unique (namespace, identifier_value),
  constraint relationship_identifier_effective_period_chk check (
    effective_to is null or effective_to > effective_from
  )
);

create unique index relationship_one_primary_identifier_idx
  on sca_core.relationship_identifier (relationship_id)
  where is_primary and effective_to is null;

create table sca_audit.relationship_event (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null,
  relationship_id uuid not null references sca_core.relationship(id),
  event_type text not null,
  actor_id uuid,
  occurred_at timestamptz not null default now(),
  request_id uuid,
  correlation_id uuid,
  event_data jsonb not null default '{}'::jsonb
);

create index relationship_event_relationship_time_idx
  on sca_audit.relationship_event (relationship_id, occurred_at desc);

create or replace function sca_core.touch_relationship_type()
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

create trigger relationship_type_touch_updated_at
before update on sca_meta.relationship_type
for each row execute function sca_core.touch_relationship_type();

alter table sca_meta.relationship_type enable row level security;
alter table sca_core.relationship enable row level security;
alter table sca_core.relationship_version enable row level security;
alter table sca_core.relationship_participant enable row level security;
alter table sca_core.relationship_identifier enable row level security;
alter table sca_audit.relationship_event enable row level security;

comment on table sca_core.relationship is
  'Stable identity for one governed semantic connection between Business Objects.';

comment on table sca_core.relationship_version is
  'Append-only effective-dated versions of accepted Relationship truth.';

comment on table sca_core.relationship_participant is
  'Additional governed participants for relationship patterns that require more than source and target.';

comment on table sca_core.relationship_identifier is
  'Governed identifiers attached to stable Relationship identities.';

comment on table sca_audit.relationship_event is
  'Append-only audit events for Relationship creation, versioning, correction, retirement, and identifiers.';

commit;
