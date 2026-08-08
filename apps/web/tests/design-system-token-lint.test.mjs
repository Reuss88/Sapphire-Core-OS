import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const governedStyles = [
  new URL("../design-system/components.css", import.meta.url),
  new URL("../app/globals.css", import.meta.url),
];

test("shared component styles consume semantic tokens instead of raw colours", async () => {
  for (const path of governedStyles) {
    const source = await readFile(path, "utf8");
    const rawColours = source.match(/#[0-9a-f]{3,8}\b|rgba?\([^)]*\)/gi) ?? [];
    assert.deepEqual(rawColours, [], `${path.pathname} contains raw colours: ${rawColours.join(", ")}`);
  }
});

test("shared component CSS is rooted in the Sapphire namespace", async () => {
  for (const path of governedStyles) {
    const source = await readFile(path, "utf8");
    assert.match(source, /var\(--sapphire-/);
    assert.doesNotMatch(source, /var\(--(?!sapphire-|s-card-)[^)]+\)/, `${path.pathname} references an ungoverned custom property`);
  }
});
