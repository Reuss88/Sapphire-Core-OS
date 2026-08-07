begin;

create schema if not exists sca_identity;
create schema if not exists sca_governance;

create type sca_identity.actor_kind as enum ('human', 'service');
create type sca_identity.membership_status as enum ('invited', 'active', 'suspended', 'revoked');
create type sca_identity.grant_effect as enum ('allow', 'deny');
create type sca_identity.grant_status as enum ('active', 'suspended', 'revoked');
create type sca_governance.authority_rule_status as enum ('draft', 'active', 'suspended', 'retired');
create type sca_governance.authority_grant_status as enum ('proposed', 'active', 'suspended', 'expired', 'revoked');

create table sca_identity.actor (
  id uuid primary key default gen_random_uuid(),
  auth_user_id uuid unique references auth.users(id) on delete restrict,
  actor_kind sca_identity.actor_kind not null,
  display_name text not null,
  is_active boolean not null default true,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint actor_human_auth_user_chk check (
    actor_kind <> 'human' or auth_user_id is not null
  ),
  constraint actor_metadata_object_chk check (jsonb_typeof(metadata) = 'object')
);

create table sca_identity.organisation (
  id uuid primary key default gen_random_uuid(),
  organisation_key text not null unique,
  display_name text not null,
  is_active boolean not null default true,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint organisation_key_chk check (organisation_key = lower(trim(organisation_key))),
  constraint organisation_metadata_object_chk check (jsonb_typeof(metadata) = 'object')
);

create table sca_identity.organisation_membership (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references sca_identity.organisation(id) on delete restrict,
  actor_id uuid not null references sca_identity.actor(id) on delete restrict,
  status sca_identity.membership_status not null default 'invited',
  title text,
  effective_from timestamptz not null default now(),
  effective_to timestamptz,
  created_by uuid references sca_identity.actor(id) on delete restrict,
  updated_by uuid references sca_identity.actor(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organisation_id, actor_id),
  constraint organisation_membership_period_chk check (
    effective_to is null or effective_to > effective_from
  )
);

create index organisation_membership_actor_status_idx
  on sca_identity.organisation_membership (actor_id, status, organisation_id);

create table sca_identity.team (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references sca_identity.organisation(id) on delete restrict,
  team_key text not null,
  display_name text not null,
  is_active boolean not null default true,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organisation_id, team_key),
  unique (id, organisation_id),
  constraint team_key_chk check (team_key = lower(trim(team_key))),
  constraint team_metadata_object_chk check (jsonb_typeof(metadata) = 'object')
);

create table sca_identity.team_membership (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references sca_identity.organisation(id) on delete restrict,
  team_id uuid not null,
  actor_id uuid not null references sca_identity.actor(id) on delete restrict,
  status sca_identity.membership_status not null default 'active',
  responsibility_label text,
  effective_from timestamptz not null default now(),
  effective_to timestamptz,
  created_by uuid references sca_identity.actor(id) on delete restrict,
  updated_by uuid references sca_identity.actor(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  foreign key (team_id, organisation_id)
    references sca_identity.team(id, organisation_id) on delete restrict,
  unique (team_id, actor_id),
  constraint team_membership_period_chk check (
    effective_to is null or effective_to > effective_from
  )
);

create index team_membership_actor_status_idx
  on sca_identity.team_membership (actor_id, status, team_id);

create table sca_identity.role_definition (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references sca_identity.organisation(id) on delete restrict,
  role_code text not null,
  display_name text not null,
  description text not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organisation_id, role_code),
  unique (id, organisation_id),
  constraint role_code_chk check (role_code = lower(trim(role_code)))
);

create table sca_identity.capability_definition (
  capability_code text primary key,
  description text not null,
  authority_sensitive boolean not null default false,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint capability_code_chk check (
    capability_code = lower(trim(capability_code))
    and capability_code ~ '^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$'
  )
);

create table sca_identity.role_capability (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references sca_identity.organisation(id) on delete restrict,
  role_id uuid not null,
  capability_code text not null references sca_identity.capability_definition(capability_code) on delete restrict,
  created_by uuid references sca_identity.actor(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (role_id, organisation_id)
    references sca_identity.role_definition(id, organisation_id) on delete restrict,
  unique (role_id, capability_code)
);

create table sca_identity.actor_role (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references sca_identity.organisation(id) on delete restrict,
  actor_id uuid not null references sca_identity.actor(id) on delete restrict,
  role_id uuid not null,
  team_id uuid,
  status sca_identity.grant_status not null default 'active',
  effective_from timestamptz not null default now(),
  effective_to timestamptz,
  assigned_by uuid references sca_identity.actor(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  foreign key (role_id, organisation_id)
    references sca_identity.role_definition(id, organisation_id) on delete restrict,
  foreign key (team_id, organisation_id)
    references sca_identity.team(id, organisation_id) on delete restrict,
  unique nulls not distinct (organisation_id, actor_id, role_id, team_id),
  constraint actor_role_period_chk check (effective_to is null or effective_to > effective_from)
);

create index actor_role_actor_status_idx
  on sca_identity.actor_role (actor_id, status, organisation_id);

create table sca_identity.actor_capability (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references sca_identity.organisation(id) on delete restrict,
  actor_id uuid not null references sca_identity.actor(id) on delete restrict,
  capability_code text not null references sca_identity.capability_definition(capability_code) on delete restrict,
  effect sca_identity.grant_effect not null,
  context jsonb not null default '{}'::jsonb,
  status sca_identity.grant_status not null default 'active',
  effective_from timestamptz not null default now(),
  effective_to timestamptz,
  granted_by uuid references sca_identity.actor(id) on delete restrict,
  reason text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint actor_capability_context_object_chk check (jsonb_typeof(context) = 'object'),
  constraint actor_capability_period_chk check (effective_to is null or effective_to > effective_from)
);

create index actor_capability_evaluation_idx
  on sca_identity.actor_capability (actor_id, organisation_id, capability_code, status, effect);

create table sca_governance.authority_rule (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references sca_identity.organisation(id) on delete restrict,
  rule_code text not null,
  decision_class text not null,
  display_name text not null,
  eligibility jsonb not null default '{}'::jsonb,
  scope jsonb not null default '{}'::jsonb,
  jurisdiction jsonb not null default '{}'::jsonb,
  limits jsonb not null default '{}'::jsonb,
  conditions jsonb not null default '{}'::jsonb,
  evidence_requirements jsonb not null default '{}'::jsonb,
  governing_policy_reference text not null,
  status sca_governance.authority_rule_status not null default 'draft',
  effective_from timestamptz,
  effective_to timestamptz,
  created_by uuid references sca_identity.actor(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organisation_id, rule_code),
  unique (id, organisation_id),
  constraint authority_rule_code_chk check (rule_code = lower(trim(rule_code))),
  constraint authority_rule_json_objects_chk check (
    jsonb_typeof(eligibility) = 'object'
    and jsonb_typeof(scope) = 'object'
    and jsonb_typeof(jurisdiction) = 'object'
    and jsonb_typeof(limits) = 'object'
    and jsonb_typeof(conditions) = 'object'
    and jsonb_typeof(evidence_requirements) = 'object'
  ),
  constraint authority_rule_period_chk check (effective_to is null or effective_from is null or effective_to > effective_from)
);

create index authority_rule_evaluation_idx
  on sca_governance.authority_rule (organisation_id, decision_class, status);

create table sca_governance.authority_grant (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references sca_identity.organisation(id) on delete restrict,
  authority_rule_id uuid not null,
  actor_id uuid not null references sca_identity.actor(id) on delete restrict,
  scope jsonb not null default '{}'::jsonb,
  limits jsonb not null default '{}'::jsonb,
  conditions jsonb not null default '{}'::jsonb,
  status sca_governance.authority_grant_status not null default 'proposed',
  effective_from timestamptz not null,
  effective_to timestamptz,
  evidence_reference text not null,
  granted_by uuid references sca_identity.actor(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  foreign key (authority_rule_id, organisation_id)
    references sca_governance.authority_rule(id, organisation_id) on delete restrict,
  unique (id, organisation_id),
  constraint authority_grant_json_objects_chk check (
    jsonb_typeof(scope) = 'object'
    and jsonb_typeof(limits) = 'object'
    and jsonb_typeof(conditions) = 'object'
  ),
  constraint authority_grant_period_chk check (effective_to is null or effective_to > effective_from)
);

create index authority_grant_evaluation_idx
  on sca_governance.authority_grant (actor_id, organisation_id, status, effective_from, effective_to);

create table sca_governance.authority_delegation (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references sca_identity.organisation(id) on delete restrict,
  source_authority_grant_id uuid not null,
  delegator_actor_id uuid not null references sca_identity.actor(id) on delete restrict,
  delegate_actor_id uuid not null references sca_identity.actor(id) on delete restrict,
  scope jsonb not null default '{}'::jsonb,
  limits jsonb not null default '{}'::jsonb,
  conditions jsonb not null default '{}'::jsonb,
  status sca_governance.authority_grant_status not null default 'proposed',
  effective_from timestamptz not null,
  effective_to timestamptz,
  evidence_reference text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  foreign key (source_authority_grant_id, organisation_id)
    references sca_governance.authority_grant(id, organisation_id) on delete restrict,
  constraint authority_delegation_distinct_actors_chk check (delegator_actor_id <> delegate_actor_id),
  constraint authority_delegation_json_objects_chk check (
    jsonb_typeof(scope) = 'object'
    and jsonb_typeof(limits) = 'object'
    and jsonb_typeof(conditions) = 'object'
  ),
  constraint authority_delegation_period_chk check (effective_to is null or effective_to > effective_from)
);

create index authority_delegation_evaluation_idx
  on sca_governance.authority_delegation (delegate_actor_id, organisation_id, status, effective_from, effective_to);

create table sca_audit.access_event (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid references sca_identity.organisation(id) on delete restrict,
  event_type text not null,
  actor_id uuid references sca_identity.actor(id) on delete restrict,
  target_schema text not null,
  target_table text not null,
  target_id uuid,
  occurred_at timestamptz not null default now(),
  request_id uuid,
  correlation_id uuid,
  event_data jsonb not null default '{}'::jsonb,
  constraint access_event_data_object_chk check (jsonb_typeof(event_data) = 'object')
);

create index access_event_org_time_idx
  on sca_audit.access_event (organisation_id, occurred_at desc);

create index access_event_target_time_idx
  on sca_audit.access_event (target_schema, target_table, target_id, occurred_at desc);

alter table sca_identity.actor enable row level security;
alter table sca_identity.organisation enable row level security;
alter table sca_identity.organisation_membership enable row level security;
alter table sca_identity.team enable row level security;
alter table sca_identity.team_membership enable row level security;
alter table sca_identity.role_definition enable row level security;
alter table sca_identity.capability_definition enable row level security;
alter table sca_identity.role_capability enable row level security;
alter table sca_identity.actor_role enable row level security;
alter table sca_identity.actor_capability enable row level security;
alter table sca_governance.authority_rule enable row level security;
alter table sca_governance.authority_grant enable row level security;
alter table sca_governance.authority_delegation enable row level security;
alter table sca_audit.access_event enable row level security;

comment on schema sca_identity is
  'Canonical Sapphire runtime identity, membership, team, role, and software capability model.';

comment on schema sca_governance is
  'Canonical runtime implementation of governed Authority Rules, Grants, and Delegations.';

comment on table sca_identity.role_definition is
  'Administrative capability bundle. A role never substitutes for an Authority Grant.';

comment on table sca_governance.authority_grant is
  'Evidence-backed organisational authority held by an actor under a canonical Authority Rule.';

comment on table sca_audit.access_event is
  'Append-only audit stream for material identity, access, capability, and authority changes.';

commit;
