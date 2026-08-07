import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const workspace = new URL("../components/actions/actions-workspace.tsx", import.meta.url);
const fixture = new URL("../components/actions/actions-fixture.ts", import.meta.url);

test("Actions workspace exposes all canonical lenses and creation commands", async () => {
  const source = await readFile(workspace, "utf8");
  for (const label of ["My Actions", "Missions", "Team", "Approvals & Decisions", "Waiting On", "Overdue", "Completed", "Create mission", "Create action"]) {
    assert.match(source, new RegExp(label.replace(/[&]/g, "\\&")));
  }
});

test("fixtures preserve authority, evidence, provenance and commercial consequence", async () => {
  const source = await readFile(fixture, "utf8");
  for (const field of ["authorityRequired", "evidenceRequired", "sourceWorkspace", "rankFactors", "commercialConsequence", "valueExposure"]) {
    assert.match(source, new RegExp(field));
  }
});

test("fixture commands cannot masquerade as authoritative mutations", async () => {
  const source = await readFile(workspace, "utf8");
  assert.match(source, /requires an authoritative Actions RPC/);
  assert.match(source, /No fixture state was changed/);
  assert.match(source, /Backend RPC connection is required/);
});
