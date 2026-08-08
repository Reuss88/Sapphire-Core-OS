import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";

const [workspace, styles, journal] = await Promise.all([
  readFile("apps/web/components/actions/actions-workspace.tsx", "utf8"),
  readFile("apps/web/app/globals.css", "utf8"),
  readFile("apps/web/components/actions/work-journal.tsx", "utf8"),
]);

for (const required of ["brand-rail", "command-header", "execution-brief", "lens-strip", "queue-pane", "context-canvas", "journal-pane"]) assert.match(workspace, new RegExp(required));
assert.match(styles, /\.command-header \{[^}]*flex: 0 0 60px/s);
assert.match(styles, /\.actions-grid \{[^}]*grid-template-columns:[^;]*\.78fr[^;]*1\.28fr[^;]*\.9fr/s);
assert.match(styles, /\.brand-rail \{[^}]*position: fixed/s);
assert.match(styles, /\.brand-rail\[data-expanded="true"\][^{]*\{[^}]*width: 224px/s);
assert.match(styles, /@media \(max-width: 700px\)[\s\S]*\.mobile-menu-button \{ display: grid/s);
assert.match(styles, /@media \(prefers-reduced-motion: reduce\)/);
assert.match(workspace, /localStorage\.setItem\(BRIEF_STORAGE_KEY, BRIEF_ID\)/);
assert.match(workspace, /sessionStorage\.setItem\(NAV_PIN_STORAGE_KEY/);
assert.match(workspace, /No fixture state was changed/);
for (const distinction of ["activity", "execution_event", "evidence"]) assert.match(journal, new RegExp(distinction));

console.log("Actions execution canvas layout, navigation, briefing and Activity regression contract passed");
