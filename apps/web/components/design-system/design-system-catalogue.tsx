"use client";

import { useRef, useState } from "react";
import {
  Agenda, Button, ButtonGroup, Calendar, Card, CardBody, CardHeader, Checkbox, CommandPaletteFrame,
  DateField, DateTimeField, Dialog, Drawer, Eyebrow, Field, IconButton, Input, Popover,
  GlobalSearch, Radio, SegmentedControl, Select, SharedState, StatusBadge, Switch, TabCollection,
  Textarea, TimeField, Toast, Tooltip, type SapphireCardVariant,
} from "../../design-system";

const cardVariants: Array<{ variant: SapphireCardVariant; label: string; detail: string }> = [
  { variant: "standard", label: "Standard", detail: "Default governed surface." },
  { variant: "focus", label: "Command focus", detail: "Primary working context with restrained focus gradient." },
  { variant: "intelligence", label: "Intelligence", detail: "Evidence-linked Sapphire Intelligence." },
  { variant: "financial", label: "Financial", detail: "Currency, period and definition remain explicit." },
  { variant: "attention", label: "Attention", detail: "Material condition requiring review." },
  { variant: "opportunity", label: "Opportunity", detail: "Evidence-backed upside requiring evaluation." },
  { variant: "summary", label: "Summary", detail: "Compact workspace status." },
  { variant: "evidence", label: "Evidence", detail: "Governed provenance and verification state." },
  { variant: "timeline", label: "Timeline", detail: "Activity and execution history." },
  { variant: "queue", label: "Queue", detail: "Ranked records and accountable state." },
  { variant: "visualisation", label: "Visualisation", detail: "Chart and map frame with question-led context." },
  { variant: "form", label: "Form", detail: "Structured, authority-aware data entry." },
  { variant: "calendar", label: "Calendar", detail: "Timezone-explicit scheduling surface." },
];

export function DesignSystemCatalogue() {
  const [tab, setTab] = useState("overview");
  const [selectedDate, setSelectedDate] = useState(new Date(2026, 7, 8));
  const [density, setDensity] = useState("compact");
  const [notifications, setNotifications] = useState(true);
  const [dialogOpen, setDialogOpen] = useState(false);
  const [drawerOpen, setDrawerOpen] = useState(false);
  const [popoverOpen, setPopoverOpen] = useState(false);
  const [toastVisible, setToastVisible] = useState(true);
  const dialogTriggerRef = useRef<HTMLButtonElement>(null);

  return <main className="catalogue-page">
    <header className="catalogue-header"><div><Eyebrow>SAPPHIRE DESIGN SYSTEM · LIVE CATALOGUE</Eyebrow><h1>Actions-derived instruments for one coherent OS</h1><p>Every example below is the production component, not a visual mock.</p></div><StatusBadge tone="success">Foundation active</StatusBadge></header>

    <section className="catalogue-section" aria-labelledby="tabs-heading"><div className="catalogue-section-heading"><div><Eyebrow>NAVIGATION</Eyebrow><h2 id="tabs-heading">Tab collection</h2></div><p>The one approved HOME-derived visual pattern: enclosed segmented links with inset selection and count badges.</p></div><TabCollection label="Catalogue views" activeId={tab} onChange={setTab} items={[{ id: "overview", label: "Overview" }, { id: "journal", label: "Work Journal", count: 0 }, { id: "evidence", label: "Evidence", count: 3 }]} /></section>

    <section className="catalogue-section" aria-labelledby="cards-heading"><div className="catalogue-section-heading"><div><Eyebrow>SURFACES</Eyebrow><h2 id="cards-heading">Card taxonomy</h2></div><p>Chrome lives in opposite corners and can be patched centrally.</p></div><div className="catalogue-card-grid">{cardVariants.map((item, index) => <Card variant={item.variant} chrome={index % 2 ? "reverse" : "forward"} headerGradient key={item.variant}><CardHeader><div><Eyebrow>{item.variant}</Eyebrow><strong>{item.label}</strong></div><StatusBadge tone={item.variant === "attention" ? "critical" : item.variant === "intelligence" ? "ai" : "neutral"}>ready</StatusBadge></CardHeader><CardBody><p>{item.detail}</p><Button size="compact" variant={item.variant === "focus" ? "primary" : "secondary"}>Open surface</Button></CardBody></Card>)}</div></section>

    <section className="catalogue-section" aria-labelledby="forms-heading"><div className="catalogue-section-heading"><div><Eyebrow>CONTROL SYSTEM</Eyebrow><h2 id="forms-heading">Forms, choices and governed states</h2></div><p>Native semantics, visible authority notes and one shared focus treatment.</p></div><div className="catalogue-two-column">
      <Card variant="form" headerGradient><CardHeader><div><Eyebrow>FORM SYSTEM</Eyebrow><h2>Live governed fields</h2></div></CardHeader><CardBody><form className="catalogue-form" onSubmit={(event) => event.preventDefault()}><Field label="Required outcome" required hint="Describe the accountable commercial result."><Input placeholder="What must happen?" /></Field><Field label="Owner"><Select defaultValue="reuss"><option value="reuss">Reuss · Director</option><option value="maya">Maya Chen · Closer</option></Select></Field><Field label="Evidence note" optional authorityNote="Evidence stays owned by its source workspace."><Textarea placeholder="What will prove completion?" /></Field><div className="catalogue-choice-grid"><Checkbox defaultChecked label="Notify assigned people" description="Notification does not grant record access." /><Checkbox disabled label="Auto-approve governed change" description="Unavailable by authority policy." /><Radio name="priority" defaultChecked label="High priority" /><Radio name="priority" label="Normal priority" /><Switch checked={notifications} onChange={(event) => setNotifications(event.target.checked)} label="Live notifications" description="Uses current session preference." /></div><SegmentedControl label="Density" value={density} onChange={setDensity} options={[{ value: "compact", label: "Compact" }, { value: "comfortable", label: "Comfortable" }, { value: "expanded", label: "Expanded" }]} /><ButtonGroup className="catalogue-actions"><Button variant="secondary">Cancel</Button><Button variant="primary">Validate preview</Button></ButtonGroup></form></CardBody></Card>
      <Card variant="calendar" headerGradient><CardHeader><div><Eyebrow>DATE AND TIME</Eyebrow><h2>Scheduling controls</h2></div><StatusBadge tone="info">Europe/London</StatusBadge></CardHeader><CardBody><div className="catalogue-form"><div className="catalogue-date-grid"><Field label="Date"><DateField defaultValue="2026-08-08" /></Field><Field label="Time"><TimeField defaultValue="14:30" /></Field></div><Field label="Date and time"><DateTimeField defaultValue="2026-08-08T14:30" /></Field><Calendar onSelect={setSelectedDate} /><p className="catalogue-selected-date">Selected: {selectedDate.toLocaleDateString("en-GB")}</p><Agenda items={[{ id: "brief", at: "2026-08-08T08:30:00+01:00", title: "Director briefing", context: "Actions · evidence-linked" }, { id: "approval", at: "2026-08-08T12:00:00+01:00", title: "Pricing authority due", context: "Governance owns approval", tone: "critical" }]} /></div></CardBody></Card>
    </div></section>

    <section className="catalogue-section" aria-labelledby="overlay-heading"><div className="catalogue-section-heading"><div><Eyebrow>OVERLAYS & FEEDBACK</Eyebrow><h2 id="overlay-heading">Layered command surfaces</h2></div><p>Dialogs, drawers, popovers, tooltips and notifications share governed depth and focus rules.</p></div><Card variant="focus" headerGradient><CardBody><div className="catalogue-overlay-demo"><Button ref={dialogTriggerRef} onClick={() => setDialogOpen(true)}>Open dialog</Button><Button onClick={() => setDrawerOpen(true)}>Open drawer</Button><div className="catalogue-popover-anchor"><Button aria-expanded={popoverOpen} onClick={() => setPopoverOpen((open) => !open)}>Toggle popover</Button><Popover open={popoverOpen} label="Record commands"><strong>Record commands</strong><p>Open provenance or copy a governed reference.</p></Popover></div><Tooltip label="Quiet explanatory text"><IconButton label="Show tooltip">?</IconButton></Tooltip></div><GlobalSearch /><CommandPaletteFrame><span aria-hidden="true">⌕</span><Input aria-label="Command palette search" placeholder="Search commands and workspaces…" /><kbd>⌘ K</kbd></CommandPaletteFrame>{toastVisible && <Toast tone="success" title="Shared component update active" detail="Changes propagate across every consuming workspace." onDismiss={() => setToastVisible(false)} />}</CardBody></Card></section>

    <section className="catalogue-section" aria-labelledby="states-heading"><div className="catalogue-section-heading"><div><Eyebrow>SYSTEM STATES</Eyebrow><h2 id="states-heading">Shared state contract</h2></div></div><div className="catalogue-state-grid">{(["loading", "empty", "stale", "partial", "offline", "error", "unauthorised"] as const).map((state) => <Card variant="summary" chrome="none" key={state}><SharedState state={state} title={state.replaceAll("_", " ")} detail="Meaning, recovery and authority remain explicit." /></Card>)}</div></section>

    <Dialog open={dialogOpen} onClose={() => setDialogOpen(false)} returnFocusRef={dialogTriggerRef} eyebrow="AUTHORITY CHECK" title="Confirm governed instruction" description="This demonstration uses the production modal, focus trap and Escape behaviour." footer={<ButtonGroup><Button onClick={() => setDialogOpen(false)}>Cancel</Button><Button variant="primary" onClick={() => setDialogOpen(false)}>Confirm preview</Button></ButtonGroup>}><Field label="Instruction" required><Textarea autoFocus defaultValue="Validate the counterparty evidence before approval." /></Field></Dialog>
    <Drawer open={drawerOpen} onClose={() => setDrawerOpen(false)} title="Evidence drawer"><SharedState state="partial" title="2 of 3 sources verified" detail="One supplier certificate remains pending independent validation." /></Drawer>
  </main>;
}
