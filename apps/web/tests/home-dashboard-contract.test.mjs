import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const paths = {
  component: new URL("../components/home/home-dashboard.tsx", import.meta.url),
  fixture: new URL("../components/home/home-fixture.ts", import.meta.url),
  styles: new URL("../components/home/home-dashboard.css", import.meta.url),
  route: new URL("../app/dashboard/page.tsx", import.meta.url),
};

test("HOME preserves the locked commercial widget hierarchy", async () => {
  const source = await readFile(paths.component, "utf8");
  const ordered = ["home-briefing", "home-position", "home-radar", "home-movement", "home-attention", "home-actions", "home-inbox", "home-hot", "home-pulse"];
  let cursor = -1;
  for (const marker of ordered) {
    const next = source.indexOf(marker, cursor + 1);
    assert.ok(next > cursor, `${marker} must appear after the preceding HOME region`);
    cursor = next;
  }
});

test("HOME consumes the shared Sapphire component system", async () => {
  const source = await readFile(paths.component, "utf8");
  for (const component of ["<SapphireShell", "<Card", "<Button", "<LinkButton", "<GlobalSearch", "<StatusBadge", "<TabCollection", "<Toast", "<SharedState"]) assert.match(source, new RegExp(component));
  assert.match(source, /activeWorkspace="Home"/);
});

test("HOME fixture exposes ownership, freshness, evidence, permission and routes", async () => {
  const source = await readFile(paths.fixture, "utf8");
  for (const contract of ["owner", "source", "freshness", "evidence", "permission", "route", "generatedAt", "dataAsOf", "timezone"]) assert.match(source, new RegExp(contract));
  assert.match(source, /dashboard_get_director_snapshot_v1 fixture/);
  assert.match(source, /fixture adapter/i);
});

test("HOME provides all governed snapshot states", async () => {
  const [component, route] = await Promise.all([readFile(paths.component, "utf8"), readFile(paths.route, "utf8")]);
  for (const state of ["loading", "empty", "stale", "partial", "offline", "error", "unauthorised"]) {
    assert.match(component, new RegExp(`${state}:`));
    assert.match(route, new RegExp(`"${state}"`));
  }
});

test("HOME page styles use tokens and preserve the desktop no-scroll command grid", async () => {
  const source = await readFile(paths.styles, "utf8");
  assert.doesNotMatch(source, /#[0-9a-f]{3,8}\b|rgba?\([^)]*\)/gi);
  assert.match(source, /height: 100vh/);
  assert.match(source, /overflow: hidden/);
  assert.match(source, /grid-template-columns: repeat\(12/);
  assert.match(source, /@media \(max-width: 700px\)/);
  assert.match(source, /home-attention \{ order: -2/);
});
