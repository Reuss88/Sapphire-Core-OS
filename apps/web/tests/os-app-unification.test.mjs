import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import test from "node:test";

const read = (path) => readFileSync(new URL(`../${path}`, import.meta.url), "utf8");

test("root and home alias resolve to the canonical dashboard", () => {
  assert.match(read("app/page.tsx"), /redirect\("\/dashboard"\)/);
  assert.match(read("app/home/page.tsx"), /redirect\("\/dashboard"\)/);
});

test("one workspace registry classifies implemented and reserved routes", () => {
  const registry = read("design-system/workspace-registry.ts");
  assert.match(registry, /label: "Home"[\s\S]*availability: "implemented"/);
  assert.match(registry, /label: "Actions"[\s\S]*availability: "implemented"/);
  for (const workspace of ["Inbox", "Market Radar", "Demand", "Supply", "Opportunities", "Matching", "Deals", "Network", "Profiles", "Intelligence", "Documents", "Finance", "Governance"]) {
    assert.match(registry, new RegExp(`label: "${workspace}"[^\\n]+availability: "placeholder"`));
  }
});

test("reserved links render an explicit governed placeholder", () => {
  const route = read("app/[workspace]/[[...detail]]/page.tsx");
  const placeholder = read("design-system/workspace-placeholder.tsx");
  assert.match(route, /placeholderWorkspaces\.get/);
  assert.match(route, /notFound\(\)/);
  assert.match(placeholder, /No substitute data, unrelated redirect or false implementation/);
  assert.match(placeholder, /SapphireShell/);
});

test("manifest starts the installed OS at HOME", () => {
  assert.match(read("app/manifest.ts"), /start_url: "\/dashboard"/);
});
