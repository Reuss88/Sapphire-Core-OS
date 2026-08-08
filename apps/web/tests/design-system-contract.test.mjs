import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const paths = {
  tokens: new URL("../design-system/tokens.css", import.meta.url),
  components: new URL("../design-system/components.css", import.meta.url),
  primitives: new URL("../design-system/primitives.tsx", import.meta.url),
  tabs: new URL("../design-system/tab-collection.tsx", import.meta.url),
  calendar: new URL("../design-system/calendar.tsx", import.meta.url),
  formControls: new URL("../design-system/form-controls.tsx", import.meta.url),
  overlays: new URL("../design-system/overlays.tsx", import.meta.url),
  catalogue: new URL("../components/design-system/design-system-catalogue.tsx", import.meta.url),
  actions: new URL("../components/actions/actions-workspace.tsx", import.meta.url),
  shell: new URL("../design-system/shell.tsx", import.meta.url),
};

test("design system defines the governed runtime token namespaces", async () => {
  const source = await readFile(paths.tokens, "utf8");
  for (const family of ["--sapphire-color-", "--sapphire-space-", "--sapphire-radius-", "--sapphire-shadow-", "--sapphire-motion-", "--sapphire-font-", "--sapphire-z-"]) assert.match(source, new RegExp(family));
  assert.match(source, /prefers-reduced-motion/);
});

test("card frame owns chrome corners and restrained gradients", async () => {
  const source = await readFile(paths.components, "utf8");
  for (const contract of ["s-card--chrome-forward", "s-card--chrome-reverse", "s-card--header-gradient", "sapphire-gradient-focus", "sapphire-color-chrome-bright"]) assert.match(source, new RegExp(contract));
});

test("tab collections use the approved enclosed segmented contract", async () => {
  const [component, styles] = await Promise.all([readFile(paths.tabs, "utf8"), readFile(paths.components, "utf8")]);
  for (const contract of ["role=\"tablist\"", "aria-selected", "ArrowRight", "ArrowLeft", "Home", "End"]) assert.match(component, new RegExp(contract));
  for (const contract of ["s-tab-collection", "s-tab-collection__item.is-active", "s-tab-collection__count"]) assert.match(styles, new RegExp(contract));
});

test("catalogue exposes cards, forms, calendar, overlays and shared states", async () => {
  const [catalogue, primitives, formControls, calendar, overlays] = await Promise.all([readFile(paths.catalogue, "utf8"), readFile(paths.primitives, "utf8"), readFile(paths.formControls, "utf8"), readFile(paths.calendar, "utf8"), readFile(paths.overlays, "utf8")]);
  for (const variant of ["standard", "focus", "intelligence", "financial", "attention", "opportunity", "summary", "evidence", "timeline", "queue", "visualisation", "form", "calendar"]) assert.match(catalogue, new RegExp(`\"${variant}\"`));
  for (const state of ["loading", "empty", "stale", "partial", "offline", "error", "unauthorised"]) assert.match(catalogue, new RegExp(`\"${state}\"`));
  for (const primitive of ["export const Button", "export function Card", "export function Field", "export const Input", "export function Select", "export function Textarea"]) assert.match(primitives, new RegExp(primitive));
  for (const control of ["export function Checkbox", "export function Radio", "export function Switch", "export function SegmentedControl", "export function DateField", "export function TimeField", "export function DateTimeField"]) assert.match(formControls, new RegExp(control));
  for (const overlay of ["export function Dialog", "export function Drawer", "export function Popover", "export function Tooltip", "export function Toast", "export function CommandPaletteFrame"]) assert.match(overlays, new RegExp(overlay));
  assert.match(calendar, /role="grid"/);
  assert.match(calendar, /Europe\/London/);
  for (const key of ["ArrowLeft", "ArrowRight", "ArrowUp", "ArrowDown", "Home", "End"]) assert.match(calendar, new RegExp(key));
});

test("Actions consumes shared cards, buttons, fields and tab collections", async () => {
  const source = await readFile(paths.actions, "utf8");
  assert.match(source, /from "\.\.\/\.\.\/design-system"/);
  for (const component of ["<TabCollection", "<Card", "<Button", "<Field", "<Input", "<Select", "<Textarea"]) assert.match(source, new RegExp(component));
});

test("Work Journal consumes the shared tab, form and overlay families", async () => {
  const source = await readFile(new URL("../components/actions/work-journal.tsx", import.meta.url), "utf8");
  for (const component of ["<TabCollection", "<Dialog", "<Field", "<Input", "<Select", "<Textarea", "<Button"]) assert.match(source, new RegExp(component));
  assert.doesNotMatch(source, /dialog-backdrop|journal-filters/);
});

test("shared shell owns navigation, command header and presentation persistence", async () => {
  const source = await readFile(paths.shell, "utf8");
  for (const contract of ["SapphireShell", "WorkspaceRail", "NavigationPanel", "CommandHeader", "GlobalSearch", "WorkspaceFooter", "workspaceNavigation", "brand-rail", "command-header", "SAPPHIRE_NAV_PIN_STORAGE_KEY", "sessionStorage.setItem", "DirectorIdentity"]) assert.match(source, new RegExp(contract));
});
