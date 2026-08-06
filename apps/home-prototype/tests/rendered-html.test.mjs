import assert from "node:assert/strict";
import test from "node:test";

async function render(pathname = "/dashboard") {
  const workerUrl = new URL("../dist/server/index.js", import.meta.url);
  workerUrl.searchParams.set("test", `${process.pid}-${Date.now()}`);
  const { default: worker } = await import(workerUrl.href);

  return worker.fetch(
    new Request(`http://localhost${pathname}`, {
      headers: { accept: "text/html" },
    }),
    { ASSETS: { fetch: async () => new Response("Not found", { status: 404 }) } },
    { waitUntil() {}, passThroughOnException() {} },
  );
}

test("server-renders the Sapphire HOME command deck", async () => {
  const response = await render();
  assert.equal(response.status, 200);
  assert.match(response.headers.get("content-type") ?? "", /^text\/html\b/i);

  const html = await response.text();
  assert.match(html, /<title>Sapphire Core OS — HOME<\/title>/i);
  assert.match(html, /DIRECTOR BRIEFING/);
  assert.match(html, /COMMERCIAL POSITION/);
  assert.match(html, /MARKET RADAR/);
  assert.match(html, /COMMERCIAL MOVEMENT/);
  assert.match(html, /DIRECTOR ATTENTION/);
  assert.match(html, /WORKSPACE PULSE/);
  assert.doesNotMatch(html, /codex-preview|react-loading-skeleton|Your site is taking shape/i);
});

test("root route provides the same Director prototype", async () => {
  const response = await render("/");
  const html = await response.text();
  assert.equal(response.status, 200);
  assert.match(html, /Good afternoon/);
  assert.match(html, /Review Opportunity/);
});
