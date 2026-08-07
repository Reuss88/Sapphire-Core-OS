import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";

const foundation = await readFile("supabase/migrations/20260807010100_actions_foundation.sql", "utf8");
const rpcs = await readFile("supabase/migrations/20260807010200_actions_rpcs.sql", "utf8");
const security = await readFile("supabase/migrations/20260807010300_actions_rls_realtime.sql", "utf8");

for (const table of [
  "action_mission", "action_item", "action_assignment", "action_dependency",
  "action_link", "action_evidence", "action_event", "action_saved_view",
]) {
  assert.match(`${foundation}\n${security}`, new RegExp(`\\b${table}\\b`), `missing ${table}`);
}

for (const rpc of [
  "actions_create_mission_v1", "actions_update_mission_v1", "actions_create_item_v1",
  "actions_transition_item_v1", "actions_assign_item_v1", "actions_set_due_at_v1",
  "actions_set_priority_v1", "actions_set_waiting_v1", "actions_set_blocked_v1",
  "actions_add_dependency_v1", "actions_remove_dependency_v1", "actions_link_record_v1",
  "actions_add_evidence_v1", "actions_complete_item_v1", "actions_reopen_item_v1",
  "actions_cancel_item_v1", "actions_get_my_queue_v1", "actions_get_director_queue_v1",
  "actions_get_missions_v1", "actions_get_mission_detail_v1", "actions_get_item_detail_v1",
  "actions_get_team_load_v1",
]) {
  assert.match(rpcs, new RegExp(`create or replace function sca_core\\.${rpc}\\b`), `missing ${rpc}`);
}

assert.doesNotMatch(foundation, /action_item_status[^;]*'overdue'/s, "overdue must not be stored as action status");
assert.match(rpcs, /action_dependency_would_cycle/);
assert.match(rpcs, /Completion evidence is required/);
assert.match(rpcs, /authoritative Governance command/);
assert.match(rpcs, /sca_identity\.current_actor_id/);
assert.match(rpcs, /sca_governance\.has_authority/);
assert.doesNotMatch(rpcs, /sapphire_role|permissions['"]/);
assert.match(foundation, /action_event_immutable/);
assert.match(security, /action_mission_select_visible/);
assert.match(security, /action_item_select_visible/);
assert.match(security, /supabase_realtime/);

console.log("Actions schema/RPC/RLS contract validation passed");
