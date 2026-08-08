import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const workspace = new URL("../components/actions/actions-workspace.tsx", import.meta.url);
const fixture = new URL("../components/actions/actions-fixture.ts", import.meta.url);
const journal = new URL("../components/actions/work-journal.tsx", import.meta.url);

test("Actions workspace exposes all canonical lenses and creation commands", async () => {
  const source = await readFile(workspace, "utf8");
  for (const label of ["My Actions", "Missions", "Team", "Approvals & Decisions", "Waiting On", "Overdue", "Completed", "＋ Mission", "＋ Action"]) {
    assert.match(source, new RegExp(label.replace(/[&]/g, "\\&")));
  }
});

test("execution canvas preserves the Director-approved density and presentation-state contracts", async () => {
  const source = await readFile(workspace, "utf8");
  for (const contract of ["BRIEF_ID", "BRIEF_STORAGE_KEY", "NAV_PIN_STORAGE_KEY", "Open full brief", "Dismiss execution brief", "Pin workspace navigation", "Open workspace navigation", "context-canvas", "journal-pane"]) assert.match(source, new RegExp(contract));
  assert.match(source, /window\.localStorage\.setItem\(BRIEF_STORAGE_KEY, BRIEF_ID\)/);
  assert.match(source, /window\.sessionStorage\.setItem\(NAV_PIN_STORAGE_KEY/);
});

test("Work Journal distinguishes context, execution and evidence with explicit visibility", async () => {
  const [source, fixtureSource] = await Promise.all([readFile(journal, "utf8"), readFile(fixture, "utf8")]);
  for (const phrase of ["SHARED ACTIVITY", "execution_event", "evidence", "Visible to", "Only me", "Create follow-up action", "Structured call outcome"]) assert.match(source, new RegExp(phrase));
  for (const scenario of ["Sofia Marin", "call_attempt", "call_connected", "research_update", "AI-generated · review required", "completionOutcomeRequired"]) assert.match(fixtureSource, new RegExp(scenario));
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
