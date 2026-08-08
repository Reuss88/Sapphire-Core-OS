"use client";

import { useState } from "react";
import { Button, Calendar, Card, CardBody, CardHeader, Eyebrow, Field, Input, Select, SharedState, StatusBadge, TabCollection, Textarea, type SapphireCardVariant } from "../../design-system";

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

  return <main className="catalogue-page">
    <header className="catalogue-header"><div><Eyebrow>SAPPHIRE DESIGN SYSTEM · LIVE CATALOGUE</Eyebrow><h1>Actions-derived instruments for one coherent OS</h1><p>Every example below is the production component, not a visual mock.</p></div><StatusBadge tone="success">Foundation active</StatusBadge></header>

    <section className="catalogue-section" aria-labelledby="tabs-heading"><div className="catalogue-section-heading"><div><Eyebrow>NAVIGATION</Eyebrow><h2 id="tabs-heading">Tab collection</h2></div><p>The one approved HOME-derived visual pattern: enclosed segmented links with inset selection and count badges.</p></div><TabCollection label="Catalogue views" activeId={tab} onChange={setTab} items={[{ id: "overview", label: "Overview" }, { id: "journal", label: "Work Journal", count: 0 }, { id: "evidence", label: "Evidence", count: 3 }]} /></section>

    <section className="catalogue-section" aria-labelledby="cards-heading"><div className="catalogue-section-heading"><div><Eyebrow>SURFACES</Eyebrow><h2 id="cards-heading">Card taxonomy</h2></div><p>Chrome lives in opposite corners and can be patched centrally.</p></div><div className="catalogue-card-grid">{cardVariants.map((item, index) => <Card variant={item.variant} chrome={index % 2 ? "reverse" : "forward"} headerGradient key={item.variant}><CardHeader><div><Eyebrow>{item.variant}</Eyebrow><strong>{item.label}</strong></div><StatusBadge tone={item.variant === "attention" ? "critical" : item.variant === "intelligence" ? "ai" : "neutral"}>ready</StatusBadge></CardHeader><CardBody><p>{item.detail}</p><Button size="compact" variant={item.variant === "focus" ? "primary" : "secondary"}>Open surface</Button></CardBody></Card>)}</div></section>

    <div className="catalogue-two-column">
      <Card variant="form" headerGradient><CardHeader><div><Eyebrow>FORM SYSTEM</Eyebrow><h2>Live governed fields</h2></div></CardHeader><CardBody><form className="catalogue-form"><Field label="Required outcome" required hint="Describe the accountable commercial result."><Input placeholder="What must happen?" /></Field><Field label="Owner"><Select defaultValue="reuss"><option value="reuss">Reuss · Director</option><option value="maya">Maya Chen · Closer</option></Select></Field><Field label="Evidence note"><Textarea placeholder="What will prove completion?" /></Field><div className="catalogue-actions"><Button variant="secondary">Cancel</Button><Button variant="primary">Validate preview</Button></div></form></CardBody></Card>
      <Card variant="calendar" headerGradient><CardHeader><div><Eyebrow>CALENDAR</Eyebrow><h2>Schedule and date selection</h2></div><StatusBadge tone="info">{selectedDate.toLocaleDateString("en-GB")}</StatusBadge></CardHeader><CardBody><Calendar onSelect={setSelectedDate} /></CardBody></Card>
    </div>

    <section className="catalogue-section" aria-labelledby="states-heading"><div className="catalogue-section-heading"><div><Eyebrow>SYSTEM STATES</Eyebrow><h2 id="states-heading">Shared state contract</h2></div></div><div className="catalogue-state-grid">{(["loading", "empty", "stale", "partial", "offline", "error", "unauthorised"] as const).map((state) => <Card variant="summary" chrome="none" key={state}><SharedState state={state} title={state.replaceAll("_", " ")} detail="Meaning, recovery and authority remain explicit." /></Card>)}</div></section>
  </main>;
}
