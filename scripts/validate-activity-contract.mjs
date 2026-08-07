import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";

const foundation = await readFile("supabase/migrations/20260807020100_activity_foundation.sql", "utf8");
const security = await readFile("supabase/migrations/20260807020200_activity_rls.sql", "utf8");
const integration = await readFile("supabase/migrations/20260807020300_activity_rpcs_actions.sql", "utf8");

for (const table of ["sca_core.activity", "sca_core.activity_link", "sca_core.activity_audience_actor", "sca_audit.activity_event"]) assert.match(foundation, new RegExp(table.replace(".", "\\.")));
for (const scope of ["private_actor", "director_only", "assigned_users", "mission_team", "workspace_team", "organisation"]) assert.match(foundation, new RegExp(scope));
for (const rpc of ["activity_create_v1", "activity_update_v1", "activity_withdraw_v1", "activity_redact_v1", "activity_get_work_journal_v1", "activity_create_follow_up_action_v1", "actions_set_completion_policy_v1"]) assert.match(integration, new RegExp(`create or replace function sca_core\\.${rpc}\\b`), `missing ${rpc}`);

assert.match(foundation, /activity_no_hard_delete/);
assert.match(foundation, /activity_event_immutable/);
assert.match(foundation, /provenance_kind <> 'ai_assisted_preparation'/);
assert.match(security, /activity_actor_can_view/);
assert.match(security, /visibility_scope = 'private_actor'/);
assert.match(integration, /entry_kind/);
assert.match(integration, /'execution_event'/);
assert.match(integration, /'evidence'/);
assert.match(integration, /Completion outcome Activity is required/);
assert.match(integration, /actions_create_item_v1/);

console.log("Shared Activity, visibility, Work Journal and Actions integration validation passed");
