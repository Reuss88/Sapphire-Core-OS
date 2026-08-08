"use client";

import { useState } from "react";
import type { ReactNode } from "react";
import {
  Button, ButtonGroup, Card, CardBody, CardHeader, DirectorIdentity, Eyebrow, GlobalSearch,
  LinkButton, SapphireShell, SharedState, StatusBadge, TabCollection, Toast,
} from "../../design-system";
import type { DashboardContract, DashboardRow, DashboardState, HomeDashboardSnapshot } from "./home-fixture";

const stateCopy: Record<Exclude<DashboardState, "ready">, { title: string; detail: string }> = {
  loading: { title: "Preparing Director snapshot", detail: "The stable command-deck geometry remains reserved while governed sources load." },
  empty: { title: "No qualifying Director conditions", detail: "No records meet the current scope. Open a workspace to inspect its full authorised state." },
  stale: { title: "Snapshot requires refresh", detail: "Showing the last successful authorised snapshot with its captured time." },
  partial: { title: "Partial commercial picture", detail: "One or more sources are unavailable or filtered by permission; visible totals exclude hidden records." },
  offline: { title: "Read-only offline snapshot", detail: "Cached data remains visible. High-consequence mutations are unavailable until reconnection." },
  error: { title: "Director snapshot unavailable", detail: "The failure is recoverable and no infrastructure details or hidden record counts are exposed." },
  unauthorised: { title: "Dashboard access unavailable", detail: "Protected commercial details are omitted. Authority is enforced by the server, not this interface." },
};

function ContractNote({ contract }: { contract: DashboardContract }) {
  return <p className="home-contract" title={`${contract.source} · ${contract.permission}`}>{contract.owner} · {contract.freshness} · {contract.evidence}</p>;
}

function CompactRows({ rows, sparklines = false }: { rows: DashboardRow[]; sparklines?: boolean }) {
  return <div className="home-compact-rows">{rows.map((row, index) => <div className="home-compact-row" key={`${row.label}-${row.value}`}><span className={`home-row-marker is-${row.tone ?? "neutral"}`} aria-hidden="true" /><span className="home-row-copy"><strong>{row.label}</strong>{row.detail && <small>{row.detail}</small>}</span><b>{row.value}</b>{sparklines && <span className="home-sparkline" aria-hidden="true">{[2, 4, 3, 6, 5, 8, 6, 9].map((height, point) => <i style={{ height: `${Math.max(2, height + ((index + point) % 3) - 1) * 7}%` }} key={point} />)}</span>}</div>)}</div>;
}

function CardTitle({ eyebrow, title, tone, action }: { eyebrow: string; title: string; tone?: "neutral" | "info" | "success" | "warning" | "critical" | "ai"; action?: ReactNode }) {
  return <CardHeader><div><Eyebrow>{eyebrow}</Eyebrow><h2>{title}</h2></div>{action ?? (tone && <StatusBadge tone={tone}>live</StatusBadge>)}</CardHeader>;
}

export function HomeDashboard({ snapshot, state = "ready" }: { snapshot: HomeDashboardSnapshot; state?: DashboardState }) {
  const [notice, setNotice] = useState<string | null>(null);
  const stateIsReady = state === "ready";
  const shellCommands = <><GlobalSearch /><div className="home-session-context"><span>07 Aug 2026</span><b>14:34 · BST</b></div><Button variant="quiet" size="compact" aria-label="Notifications">◇ <span className="home-command-count">12</span></Button><Button variant="quiet" size="compact" aria-label="Inbox">▱ <span className="home-command-count">7</span></Button></>;
  const footer = <footer className="workspace-footer home-footer"><span>Snapshot · {snapshot.dataAsOf}</span><span>Fixture adapter · governed RPC pending</span><span className="freshness">All systems operational</span></footer>;

  return <SapphireShell className="home-app" activeWorkspace="Home" eyebrow="DIRECTOR COMMAND DECK" title="Home" commands={shellCommands} identity={<DirectorIdentity name={snapshot.actor.name} role={snapshot.actor.role} initials={snapshot.actor.initials} />} footer={footer}>
    {!stateIsReady ? <Card variant={state === "error" ? "attention" : state === "stale" || state === "offline" ? "evidence" : "focus"} className="home-state-card"><SharedState state={state} title={stateCopy[state].title} detail={stateCopy[state].detail} action={<LinkButton href="/actions" size="compact">Open Actions</LinkButton>} /></Card> : <section className="home-command-grid" aria-label="Director command deck">
      <Card variant="intelligence" chrome="reverse" headerGradient className="home-briefing" aria-labelledby="home-briefing-title"><div className="home-briefing-copy"><Eyebrow>SAPPHIRE AI · DIRECTOR BRIEFING</Eyebrow><h2 id="home-briefing-title">{snapshot.briefing.greeting}</h2><p className="home-briefing-frame">{snapshot.briefing.framing}</p><ul>{snapshot.briefing.points.map((point, index) => <li key={point}><span>{index === 4 ? "AI" : "VERIFIED"}</span>{point}</li>)}</ul><ButtonGroup className="home-briefing-actions"><Button variant="primary" size="compact" onClick={() => setNotice("Review Opportunity routes through the owning Opportunities workspace; fixture state was not changed.")}>Review Opportunity</Button><LinkButton href="/governance" size="compact">Open Approvals</LinkButton><Button variant="quiet" size="compact" onClick={() => setNotice("Full analysis requires the authorised Intelligence read model.")}>Show Full Analysis →</Button></ButtonGroup><ContractNote contract={snapshot.briefing.contract} /></div><div className="home-signal-globe" role="img" aria-label="Global commercial signal network"><span className="home-globe-grid" /><i className="signal-node node-europe" title="Europe · copper demand" /><i className="signal-node node-africa" title="Zambia · verified supply" /><i className="signal-node node-asia" title="Asia · qualified demand" /><i className="signal-node node-americas" title="North America · buyer cluster" /><div className="home-globe-orbit orbit-one" /><div className="home-globe-orbit orbit-two" /><small>4 verified signal regions · 08:28 BST</small></div></Card>

      <Card variant="financial" chrome="forward" headerGradient className="home-position"><CardTitle eyebrow="FINANCE" title="Commercial Position" action={<LinkButton href="/finance" variant="quiet" size="compact">View Finance →</LinkButton>} /><CardBody><div className="home-primary-metric"><span>{snapshot.commercialPosition.metrics[0].label}</span><strong>{snapshot.commercialPosition.metrics[0].value}</strong><em>↑ {snapshot.commercialPosition.metrics[0].delta}</em><div className="home-position-chart" aria-hidden="true">{[24, 36, 32, 48, 62, 58, 78, 96].map((value) => <i style={{ height: `${value}%` }} key={value} />)}</div></div><div className="home-metric-grid">{snapshot.commercialPosition.metrics.slice(1).map((metric) => <div key={metric.label}><span>{metric.label}</span><strong>{metric.value}</strong>{metric.delta && <small className={`is-${metric.tone}`}>{metric.delta}</small>}</div>)}</div><ContractNote contract={snapshot.commercialPosition.contract} /></CardBody></Card>

      <Card variant="visualisation" chrome="forward" headerGradient className="home-radar"><CardTitle eyebrow="GLOBAL SIGNAL OVERVIEW" title="Market Radar" action={<LinkButton href="/market-radar" variant="quiet" size="compact">View Full Radar →</LinkButton>} /><CardBody><div className="home-radar-layout"><div className="home-world-map" role="img" aria-label="World map with five evidence-linked commercial signals"><span className="landmass land-americas" /><span className="landmass land-europe" /><span className="landmass land-africa" /><span className="landmass land-asia" /><span className="landmass land-australia" />{snapshot.radar.signals.map((signal) => <button type="button" className={`radar-signal is-${signal.tone}`} style={{ left: `${signal.x}%`, top: `${signal.y}%` }} aria-label={`${signal.location}: ${signal.label}, ${signal.action}`} title={`${signal.location} · ${signal.label}`} key={signal.id} onClick={() => setNotice(`${signal.location}: ${signal.label}. Open Market Radar for governed evidence.`)}><i /><span>{signal.action}</span></button>)}</div><div className="home-radar-hot"><Eyebrow>HOT RIGHT NOW</Eyebrow><CompactRows rows={snapshot.radar.hot} /></div></div><ContractNote contract={snapshot.radar.contract} /></CardBody></Card>

      <Card variant="standard" chrome="reverse" headerGradient className="home-movement"><CardTitle eyebrow="VS LAST 7 DAYS" title="Commercial Movement" tone="info" /><CardBody><CompactRows rows={snapshot.movement.rows} sparklines /><ContractNote contract={snapshot.movement.contract} /></CardBody></Card>

      <Card variant="attention" chrome="forward" className="home-operational home-attention"><CardTitle eyebrow="DIRECTOR AUTHORITY" title="Director Attention" tone="critical" /><CardBody><CompactRows rows={snapshot.attention.rows} /><ContractNote contract={snapshot.attention.contract} /></CardBody></Card>
      <Card variant="summary" chrome="reverse" className="home-operational home-actions"><CardTitle eyebrow="EXECUTION" title="Actions Summary" action={<LinkButton href="/actions" variant="quiet" size="compact">Open →</LinkButton>} /><CardBody><CompactRows rows={snapshot.actions.rows} /><ContractNote contract={snapshot.actions.contract} /></CardBody></Card>
      <Card variant="summary" chrome="forward" className="home-operational home-inbox"><CardTitle eyebrow="COMMUNICATIONS" title="Inbox Summary" action={<LinkButton href="/inbox" variant="quiet" size="compact">Open →</LinkButton>} /><CardBody><CompactRows rows={snapshot.inbox.rows} /><ContractNote contract={snapshot.inbox.contract} /></CardBody></Card>
      <Card variant="opportunity" chrome="reverse" className="home-operational home-hot"><CardTitle eyebrow="EVIDENCE-BACKED SIGNALS" title="Hot Right Now" tone="warning" /><CardBody><CompactRows rows={snapshot.hotNow.rows} /><ContractNote contract={snapshot.hotNow.contract} /></CardBody></Card>

      <Card variant="summary" chrome="none" className="home-pulse"><div className="home-pulse-heading"><div><Eyebrow>SYSTEM CONDITION</Eyebrow><strong>Workspace Pulse</strong></div><StatusBadge tone="success">recent · 08:28</StatusBadge></div><TabCollection compact label="Workspace Pulse" activeId="demand" items={snapshot.pulse.map((item) => ({ id: item.id, label: item.label, href: item.route, symbol: item.tone === "positive" ? "●" : "◇" }))} /></Card>
    </section>}
    {notice && <div className="actions-toast"><Toast title="Typed fixture boundary" detail={notice} onDismiss={() => setNotice(null)} /></div>}
  </SapphireShell>;
}
