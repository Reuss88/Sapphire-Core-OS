begin;

create type sca_core.activity_type as enum (
  'note', 'comment', 'instruction', 'call_attempt', 'call_connected',
  'meeting', 'research_update', 'outcome', 'status_update', 'handoff',
  'coaching_note', 'evidence_added', 'document_shared', 'message_summary',
  'system_observation', 'ai_summary', 'escalation_note'
);

create type sca_core.activity_visibility_scope as enum (
  'private_actor', 'director_only', 'assigned_users', 'mission_team',
  'workspace_team', 'organisation'
);

create type sca_core.activity_lifecycle_status as enum (
  'published', 'withdrawn', 'redacted'
);

insert into sca_identity.capability_definition (capability_code, description, authority_sensitive)
values
  ('activity.create', 'Create shared Activity collaboration records.', false),
  ('activity.workspace.read', 'Read Activity for an accessible workspace team.', false),
  ('activity.director', 'Create Director instructions and read Director-only Activity.', true),
  ('activity.manage', 'Withdraw or redact governed Activity records.', true);

create table sca_core.activity (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references sca_identity.organisation(id) on delete restrict,
  actor_id uuid not null references sca_identity.actor(id) on delete restrict,
  activity_type sca_core.activity_type not null,
  occurred_at timestamptz not null default now(),
  body text not null check (nullif(trim(body), '') is not null),
  structured_content jsonb not null default '{}'::jsonb check (jsonb_typeof(structured_content) = 'object'),
  schema_version integer not null default 1 check (schema_version > 0),
  visibility_scope sca_core.activity_visibility_scope not null,
  primary_subject_type text not null check (primary_subject_type in (
    'mission', 'action_item', 'person', 'contact', 'company', 'profile',
    'demand', 'supply', 'opportunity', 'match', 'deal', 'document',
    'inbox_thread', 'inbox_message', 'governance_decision',
    'governance_approval', 'finance_record', 'market_signal', 'other'
  )),
  primary_subject_id uuid not null,
  workspace_team_id uuid,
  source_workspace text not null check (nullif(trim(source_workspace), '') is not null),
  source_record_type text,
  source_record_id uuid,
  outcome_classification text,
  provenance_kind sca_core.provenance_kind not null default 'human_entry',
  provenance_ref text,
  lifecycle_status sca_core.activity_lifecycle_status not null default 'published',
  retired_at timestamptz,
  retired_by_actor_id uuid references sca_identity.actor(id) on delete restrict,
  retirement_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id, organisation_id),
  foreign key (workspace_team_id, organisation_id)
    references sca_identity.team(id, organisation_id) on delete restrict,
  constraint activity_source_pair_chk check ((source_record_type is null) = (source_record_id is null)),
  constraint activity_ai_provenance_chk check (
    provenance_kind <> 'ai_assisted_preparation'
    or nullif(trim(provenance_ref), '') is not null
  ),
  constraint activity_retirement_chk check (
    (lifecycle_status = 'published' and retired_at is null and retired_by_actor_id is null and retirement_reason is null)
    or (
      lifecycle_status in ('withdrawn', 'redacted')
      and retired_at is not null
      and retired_by_actor_id is not null
      and nullif(trim(retirement_reason), '') is not null
    )
  )
);

create table sca_core.activity_link (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references sca_identity.organisation(id) on delete restrict,
  activity_id uuid not null,
  linked_type text not null check (linked_type in (
    'mission', 'action_item', 'person', 'contact', 'company', 'profile',
    'demand', 'supply', 'opportunity', 'match', 'deal', 'document',
    'inbox_thread', 'inbox_message', 'governance_decision',
    'governance_approval', 'finance_record', 'market_signal', 'other'
  )),
  linked_id uuid not null,
  link_role text not null default 'context' check (nullif(trim(link_role), '') is not null),
  source_workspace text not null check (nullif(trim(source_workspace), '') is not null),
  created_by_actor_id uuid not null references sca_identity.actor(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (activity_id, organisation_id)
    references sca_core.activity(id, organisation_id) on delete restrict,
  unique (activity_id, linked_type, linked_id, link_role)
);

create table sca_core.activity_audience_actor (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references sca_identity.organisation(id) on delete restrict,
  activity_id uuid not null,
  actor_id uuid not null references sca_identity.actor(id) on delete restrict,
  audience_role text not null default 'recipient' check (audience_role in ('recipient', 'mentioned', 'reviewer')),
  added_by_actor_id uuid not null references sca_identity.actor(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (activity_id, organisation_id)
    references sca_core.activity(id, organisation_id) on delete restrict,
  unique (activity_id, actor_id, audience_role)
);

create table sca_audit.activity_event (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references sca_identity.organisation(id) on delete restrict,
  activity_id uuid not null,
  event_type text not null,
  actor_id uuid references sca_identity.actor(id) on delete restrict,
  payload jsonb not null default '{}'::jsonb check (jsonb_typeof(payload) = 'object'),
  occurred_at timestamptz not null default now(),
  correlation_id uuid,
  causation_id uuid,
  foreign key (activity_id, organisation_id)
    references sca_core.activity(id, organisation_id) on delete restrict
);

create index activity_org_subject_time_idx
  on sca_core.activity (organisation_id, primary_subject_type, primary_subject_id, occurred_at desc, id desc);
create index activity_org_actor_time_idx
  on sca_core.activity (organisation_id, actor_id, occurred_at desc);
create index activity_org_visibility_time_idx
  on sca_core.activity (organisation_id, visibility_scope, occurred_at desc);
create index activity_workspace_team_idx
  on sca_core.activity (organisation_id, workspace_team_id, occurred_at desc)
  where workspace_team_id is not null;
create index activity_source_idx
  on sca_core.activity (organisation_id, source_workspace, source_record_type, source_record_id);
create index activity_link_subject_idx
  on sca_core.activity_link (organisation_id, linked_type, linked_id, created_at desc);
create index activity_audience_actor_idx
  on sca_core.activity_audience_actor (organisation_id, actor_id, activity_id);
create index activity_event_activity_idx
  on sca_audit.activity_event (activity_id, occurred_at desc);

create or replace function sca_core.touch_activity_record()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

create trigger activity_touch_updated_at before update on sca_core.activity
for each row execute function sca_core.touch_activity_record();

create or replace function sca_core.reject_activity_delete()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  raise exception 'Material Activity uses withdraw or redact semantics and cannot be hard-deleted';
end;
$$;

create trigger activity_no_hard_delete before delete on sca_core.activity
for each row execute function sca_core.reject_activity_delete();

create or replace function sca_audit.reject_activity_event_mutation()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  raise exception 'Activity audit events are append-only';
end;
$$;

create trigger activity_event_immutable before update or delete on sca_audit.activity_event
for each row execute function sca_audit.reject_activity_event_mutation();

alter table sca_core.activity enable row level security;
alter table sca_core.activity_link enable row level security;
alter table sca_core.activity_audience_actor enable row level security;
alter table sca_audit.activity_event enable row level security;

revoke all on function sca_core.touch_activity_record() from public;
revoke all on function sca_core.reject_activity_delete() from public;
revoke all on function sca_audit.reject_activity_event_mutation() from public;

comment on table sca_core.activity is
  'Shared Sapphire collaboration and commercial-memory record. It is not Actions state, Inbox message truth, Governance authority, or immutable audit history.';
comment on table sca_core.activity_link is
  'Typed contextual links only; linked workspaces remain authoritative for their records.';
comment on table sca_audit.activity_event is
  'Immutable audit history for material Activity creation, correction, withdrawal, redaction, and follow-up linkage.';

commit;
