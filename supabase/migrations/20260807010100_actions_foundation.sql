begin;

create type sca_core.action_mission_status as enum (
  'planned', 'active', 'at_risk', 'blocked', 'completed', 'cancelled'
);

create type sca_core.action_item_status as enum (
  'draft', 'queued', 'ready', 'in_progress', 'waiting', 'blocked', 'completed', 'cancelled'
);

create type sca_core.action_item_kind as enum (
  'task', 'follow_up', 'review', 'approval_request', 'decision_request', 'reminder', 'coordination'
);

create type sca_core.action_priority as enum ('critical', 'high', 'normal', 'low');

insert into sca_identity.capability_definition (capability_code, description, authority_sensitive)
values
  ('actions.create', 'Create Actions missions and action items.', false),
  ('actions.team.read', 'Read Actions work across accessible teams.', false),
  ('actions.team.manage', 'Coordinate Actions work across accessible teams.', true),
  ('actions.director.view', 'Read the Director cross-team Actions lens.', true);

create table sca_core.action_mission (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references sca_identity.organisation(id) on delete restrict,
  team_id uuid,
  title text not null check (nullif(trim(title), '') is not null),
  objective text not null check (nullif(trim(objective), '') is not null),
  status sca_core.action_mission_status not null default 'planned',
  priority sca_core.action_priority not null default 'normal',
  owner_actor_id uuid references sca_identity.actor(id) on delete restrict,
  target_at timestamptz,
  health_override text check (health_override is null or health_override in ('healthy', 'attention', 'at_risk', 'blocked')),
  success_criteria jsonb not null default '[]'::jsonb check (jsonb_typeof(success_criteria) = 'array'),
  source_workspace text not null default 'actions',
  source_record_type text,
  source_record_id uuid,
  commercial_context jsonb not null default '{}'::jsonb check (jsonb_typeof(commercial_context) = 'object'),
  created_by_actor_id uuid not null references sca_identity.actor(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  completed_at timestamptz,
  cancelled_at timestamptz,
  unique (id, organisation_id),
  foreign key (team_id, organisation_id)
    references sca_identity.team(id, organisation_id) on delete restrict,
  constraint action_mission_source_pair_chk check ((source_record_type is null) = (source_record_id is null)),
  constraint action_mission_terminal_time_chk check (
    (status = 'completed' and completed_at is not null and cancelled_at is null)
    or (status = 'cancelled' and cancelled_at is not null and completed_at is null)
    or (status not in ('completed', 'cancelled') and completed_at is null and cancelled_at is null)
  )
);

create table sca_core.action_item (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references sca_identity.organisation(id) on delete restrict,
  team_id uuid,
  mission_id uuid,
  parent_action_item_id uuid,
  title text not null check (nullif(trim(title), '') is not null),
  description text not null default '',
  required_outcome text not null check (nullif(trim(required_outcome), '') is not null),
  item_kind sca_core.action_item_kind not null default 'task',
  status sca_core.action_item_status not null default 'draft',
  priority sca_core.action_priority not null default 'normal',
  owner_actor_id uuid references sca_identity.actor(id) on delete restrict,
  due_at timestamptz,
  started_at timestamptz,
  completed_at timestamptz,
  cancelled_at timestamptz,
  waiting_reason text,
  expected_resume_at timestamptz,
  blocked_reason text,
  source_workspace text not null default 'actions',
  source_record_type text,
  source_record_id uuid,
  governance_reference_type text,
  governance_reference_id uuid,
  authority_required boolean not null default false,
  authority_decision_class text,
  authority_subject jsonb not null default '{}'::jsonb check (jsonb_typeof(authority_subject) = 'object'),
  authority_limits jsonb not null default '{}'::jsonb check (jsonb_typeof(authority_limits) = 'object'),
  authority_context jsonb not null default '{}'::jsonb check (jsonb_typeof(authority_context) = 'object'),
  evidence_required boolean not null default false,
  commercial_value_exposure jsonb,
  created_by_actor_id uuid not null references sca_identity.actor(id) on delete restrict,
  creation_source text not null default 'user_created',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id, organisation_id),
  foreign key (team_id, organisation_id)
    references sca_identity.team(id, organisation_id) on delete restrict,
  foreign key (mission_id, organisation_id)
    references sca_core.action_mission(id, organisation_id) on delete restrict,
  foreign key (parent_action_item_id, organisation_id)
    references sca_core.action_item(id, organisation_id) on delete restrict,
  constraint action_item_not_self_parent_chk check (parent_action_item_id is null or parent_action_item_id <> id),
  constraint action_item_source_pair_chk check ((source_record_type is null) = (source_record_id is null)),
  constraint action_item_governance_pair_chk check ((governance_reference_type is null) = (governance_reference_id is null)),
  constraint action_item_governance_type_chk check (
    governance_reference_type is null or governance_reference_type in ('approval', 'decision', 'authority_rule', 'authority_grant')
  ),
  constraint action_item_governed_kind_chk check (
    item_kind not in ('approval_request', 'decision_request') or governance_reference_id is not null
  ),
  constraint action_item_authority_contract_chk check (
    not authority_required or nullif(trim(authority_decision_class), '') is not null
  ),
  constraint action_item_value_exposure_chk check (
    commercial_value_exposure is null or jsonb_typeof(commercial_value_exposure) = 'object'
  ),
  constraint action_item_waiting_chk check (
    (status = 'waiting' and nullif(trim(waiting_reason), '') is not null)
    or (status <> 'waiting' and waiting_reason is null and expected_resume_at is null)
  ),
  constraint action_item_blocked_chk check (
    (status = 'blocked' and nullif(trim(blocked_reason), '') is not null)
    or (status <> 'blocked' and blocked_reason is null)
  ),
  constraint action_item_terminal_time_chk check (
    (status = 'completed' and completed_at is not null and cancelled_at is null)
    or (status = 'cancelled' and cancelled_at is not null and completed_at is null)
    or (status not in ('completed', 'cancelled') and completed_at is null and cancelled_at is null)
  )
);

create table sca_core.action_assignment (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references sca_identity.organisation(id) on delete restrict,
  mission_id uuid,
  action_item_id uuid,
  actor_id uuid references sca_identity.actor(id) on delete restrict,
  external_contact_reference text,
  assignment_role text not null check (assignment_role in ('owner', 'contributor', 'reviewer', 'external_contributor')),
  assigned_by_actor_id uuid not null references sca_identity.actor(id) on delete restrict,
  assigned_at timestamptz not null default now(),
  removed_at timestamptz,
  foreign key (mission_id, organisation_id)
    references sca_core.action_mission(id, organisation_id) on delete restrict,
  foreign key (action_item_id, organisation_id)
    references sca_core.action_item(id, organisation_id) on delete restrict,
  constraint action_assignment_one_execution_target_chk check (
    (mission_id is not null)::integer + (action_item_id is not null)::integer = 1
  ),
  constraint action_assignment_one_assignee_chk check (
    (actor_id is not null)::integer + (external_contact_reference is not null)::integer = 1
  )
);

create unique index action_assignment_active_actor_idx
  on sca_core.action_assignment (coalesce(mission_id, action_item_id), actor_id, assignment_role)
  where removed_at is null and actor_id is not null;

create table sca_core.action_dependency (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references sca_identity.organisation(id) on delete restrict,
  predecessor_item_id uuid not null,
  successor_item_id uuid not null,
  dependency_type text not null default 'finish_to_start' check (dependency_type in ('finish_to_start', 'external_condition')),
  created_by_actor_id uuid not null references sca_identity.actor(id) on delete restrict,
  created_at timestamptz not null default now(),
  resolved_at timestamptz,
  foreign key (predecessor_item_id, organisation_id)
    references sca_core.action_item(id, organisation_id) on delete restrict,
  foreign key (successor_item_id, organisation_id)
    references sca_core.action_item(id, organisation_id) on delete restrict,
  unique (predecessor_item_id, successor_item_id),
  constraint action_dependency_not_self_chk check (predecessor_item_id <> successor_item_id)
);

create table sca_core.action_link (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references sca_identity.organisation(id) on delete restrict,
  mission_id uuid,
  action_item_id uuid,
  linked_type text not null check (linked_type in ('profile', 'person', 'company', 'demand', 'supply', 'opportunity', 'match', 'deal', 'document', 'inbox_thread', 'market_signal', 'finance_record', 'approval', 'decision', 'other')),
  linked_id uuid not null,
  link_role text not null default 'context',
  source_workspace text not null,
  created_by_actor_id uuid not null references sca_identity.actor(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (mission_id, organisation_id)
    references sca_core.action_mission(id, organisation_id) on delete restrict,
  foreign key (action_item_id, organisation_id)
    references sca_core.action_item(id, organisation_id) on delete restrict,
  constraint action_link_one_execution_target_chk check (
    (mission_id is not null)::integer + (action_item_id is not null)::integer = 1
  ),
  unique nulls not distinct (mission_id, action_item_id, linked_type, linked_id, link_role)
);

create table sca_core.action_evidence (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references sca_identity.organisation(id) on delete restrict,
  action_item_id uuid not null,
  evidence_type text not null check (evidence_type in ('document', 'message', 'note', 'structured_result', 'external_confirmation', 'system_event')),
  linked_type text,
  linked_id uuid,
  note text,
  supplied_by_actor_id uuid not null references sca_identity.actor(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (action_item_id, organisation_id)
    references sca_core.action_item(id, organisation_id) on delete restrict,
  constraint action_evidence_content_chk check (linked_id is not null or nullif(trim(note), '') is not null),
  constraint action_evidence_link_pair_chk check ((linked_type is null) = (linked_id is null))
);

create table sca_audit.action_event (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references sca_identity.organisation(id) on delete restrict,
  mission_id uuid,
  action_item_id uuid,
  event_type text not null,
  actor_id uuid references sca_identity.actor(id) on delete restrict,
  payload jsonb not null default '{}'::jsonb check (jsonb_typeof(payload) = 'object'),
  occurred_at timestamptz not null default now(),
  correlation_id uuid,
  causation_id uuid,
  foreign key (mission_id, organisation_id)
    references sca_core.action_mission(id, organisation_id) on delete restrict,
  foreign key (action_item_id, organisation_id)
    references sca_core.action_item(id, organisation_id) on delete restrict,
  constraint action_event_target_chk check (mission_id is not null or action_item_id is not null)
);

create table sca_core.action_saved_view (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references sca_identity.organisation(id) on delete restrict,
  actor_id uuid not null references sca_identity.actor(id) on delete restrict,
  name text not null check (nullif(trim(name), '') is not null),
  lens text not null check (lens in ('my_actions', 'missions', 'team', 'approvals_decisions', 'waiting_on', 'overdue', 'completed')),
  filters jsonb not null default '{}'::jsonb check (jsonb_typeof(filters) = 'object'),
  sort jsonb not null default '{}'::jsonb check (jsonb_typeof(sort) = 'object'),
  grouping jsonb not null default '{}'::jsonb check (jsonb_typeof(grouping) = 'object'),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organisation_id, actor_id, name)
);

create index action_mission_org_status_idx on sca_core.action_mission (organisation_id, status, target_at);
create index action_mission_owner_idx on sca_core.action_mission (organisation_id, owner_actor_id, status);
create index action_mission_team_idx on sca_core.action_mission (organisation_id, team_id, status);
create index action_item_org_status_idx on sca_core.action_item (organisation_id, status);
create index action_item_owner_due_idx on sca_core.action_item (organisation_id, owner_actor_id, status, due_at);
create index action_item_team_idx on sca_core.action_item (organisation_id, team_id, status, due_at);
create index action_item_mission_idx on sca_core.action_item (organisation_id, mission_id, status);
create index action_item_priority_idx on sca_core.action_item (organisation_id, priority, status);
create index action_item_source_idx on sca_core.action_item (organisation_id, source_workspace, source_record_type, source_record_id);
create index action_dependency_predecessor_idx on sca_core.action_dependency (predecessor_item_id, resolved_at);
create index action_dependency_successor_idx on sca_core.action_dependency (successor_item_id, resolved_at);
create index action_link_record_idx on sca_core.action_link (organisation_id, linked_type, linked_id);
create index action_evidence_item_idx on sca_core.action_evidence (action_item_id, created_at desc);
create index action_event_item_idx on sca_audit.action_event (action_item_id, occurred_at desc);
create index action_event_mission_idx on sca_audit.action_event (mission_id, occurred_at desc);

create or replace function sca_core.touch_action_record()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

create trigger action_mission_touch_updated_at before update on sca_core.action_mission
for each row execute function sca_core.touch_action_record();
create trigger action_item_touch_updated_at before update on sca_core.action_item
for each row execute function sca_core.touch_action_record();
create trigger action_saved_view_touch_updated_at before update on sca_core.action_saved_view
for each row execute function sca_core.touch_action_record();

create or replace function sca_audit.reject_action_event_mutation()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  raise exception 'Action execution events are append-only';
end;
$$;

create trigger action_event_immutable before update or delete on sca_audit.action_event
for each row execute function sca_audit.reject_action_event_mutation();

alter table sca_core.action_mission enable row level security;
alter table sca_core.action_item enable row level security;
alter table sca_core.action_assignment enable row level security;
alter table sca_core.action_dependency enable row level security;
alter table sca_core.action_link enable row level security;
alter table sca_core.action_evidence enable row level security;
alter table sca_audit.action_event enable row level security;
alter table sca_core.action_saved_view enable row level security;

revoke all on function sca_core.touch_action_record() from public;
revoke all on function sca_audit.reject_action_event_mutation() from public;

comment on table sca_core.action_mission is 'Outcome-bound body of accountable commercial work scoped to canonical organisation and optional team identity.';
comment on table sca_core.action_item is 'Authoritative executable work. Overdue is derived from due_at; assignment never creates authority.';
comment on table sca_core.action_link is 'Typed reference to a record owned by another governed workspace; it never duplicates that record truth.';
comment on table sca_audit.action_event is 'Immutable Actions execution history. Ordinary application roles cannot update or delete events.';

commit;
