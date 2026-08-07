"use client";

import { useMemo, useState } from "react";
import { navigation, snapshot } from "./home-fixtures";
import type { MarketSignal, MovementRow, SummaryRow } from "./home-types";

function Sparkline({ points }: { points: number[] }) {
  const path = useMemo(() => {
    const max = Math.max(...points);
    const min = Math.min(...points);
    return points.map((point, index) => {
      const x = (index / (points.length - 1)) * 92;
      const y = 24 - ((point - min) / Math.max(1, max - min)) * 19;
      return `${index === 0 ? "M" : "L"}${x.toFixed(1)},${y.toFixed(1)}`;
    }).join(" ");
  }, [points]);

  return <svg className="sparkline" viewBox="0 0 92 28" role="img" aria-label="Seven-day upward trend"><path d={path} /></svg>;
}

function RouteButton({ children, onRoute, className = "" }: { children: React.ReactNode; onRoute: (label: string) => void; className?: string }) {
  return <button className={className} onClick={() => onRoute(String(children))}>{children}<span aria-hidden="true">→</span></button>;
}

function PanelHeader({ icon, title, meta, action, onRoute }: { icon: string; title: string; meta?: string; action?: string; onRoute: (label: string) => void }) {
  return <header className="panel-header"><div><span className="header-icon" aria-hidden="true">{icon}</span><h2>{title}</h2>{meta && <span className="panel-meta">{meta}</span>}</div>{action && <button className="text-action" onClick={() => onRoute(action)}>{action}<span aria-hidden="true">→</span></button>}</header>;
}

function SummaryCard({ className, icon, title, count, rows, onRoute }: { className: string; icon: string; title: string; count?: number; rows: SummaryRow[]; onRoute: (label: string) => void }) {
  return <section className={`panel summary-card ${className}`}>
    <PanelHeader icon={icon} title={title} action="View All" onRoute={onRoute} />
    {count !== undefined && <span className="header-count">{count}</span>}
    <div className="summary-list">{rows.map((row, index) => <button key={row.label} onClick={() => onRoute(row.label)}><span className="row-glyph" aria-hidden="true">{index % 2 ? "◇" : "◎"}</span><span>{row.label}</span><strong className={row.state ? `state-${row.state}` : ""}>{row.value}</strong></button>)}</div>
  </section>;
}

function MarketSignalRow({ signal, compact, onRoute }: { signal: MarketSignal; compact?: boolean; onRoute: (label: string) => void }) {
  return <button className={`signal-row ${compact ? "compact" : ""}`} onClick={() => onRoute(signal.name)}>
    <span className={`signal-glyph state-${signal.state}`} aria-hidden="true">{signal.glyph}</span>
    <span className="signal-copy"><strong>{signal.name}</strong><small>{signal.detail}</small></span>
    {!compact && <span className={`action-chip state-${signal.state}`}>{signal.action}</span>}
  </button>;
}

function WorldMap() {
  return <div className="world-map" aria-label="Global market signals across Europe, Asia, Africa, North America and Australia" role="img">
    <span className="continent north-america" /><span className="continent south-america" /><span className="continent europe" /><span className="continent africa" /><span className="continent asia" /><span className="continent australia" />
    <span className="map-signal s1" /><span className="map-signal s2" /><span className="map-signal s3" /><span className="map-signal s4" /><span className="map-signal s5" />
  </div>;
}

export function HomeDashboard() {
  const [notice, setNotice] = useState<string | null>(null);
  const [query, setQuery] = useState("");
  const [menuOpen, setMenuOpen] = useState(false);

  const route = (label: string) => {
    setNotice(`${label} is wired as a controlled prototype route. Production workspace integration is deferred.`);
    window.setTimeout(() => setNotice(null), 3200);
  };

  const onSearch = (event: React.FormEvent) => {
    event.preventDefault();
    route(query.trim() ? `Search: ${query.trim()}` : "Global search");
  };

  return <div className="sapphire-app">
    <aside className="sidebar" aria-label="Primary navigation">
      <button className="brand" onClick={() => route("Sapphire Core OS HOME")} aria-label="Sapphire Core OS home">
        <span className="brand-mark" aria-hidden="true"><i /><i /><i /></span>
        <span><strong>SAPPHIRE</strong><small>CORE OS</small></span>
      </button>
      <nav>{navigation.map((item) => <button key={item.label} className={item.label === "Home" ? "active" : ""} onClick={() => route(item.label)}><span className="nav-icon" aria-hidden="true">{item.icon}</span><span>{item.label}</span>{item.count && <em>{item.count}</em>}</button>)}</nav>
      <button className="director-mode" onClick={() => route("Director Mode")}><span className="director-seal" aria-hidden="true">♜</span><span><strong>Director Mode</strong><small>Global Commodities</small></span><span aria-hidden="true">⌄</span></button>
      <div className="systems"><span />All Systems Operational</div>
    </aside>

    <main className="main-canvas">
      <header className="utility-bar">
        <form className="global-search" onSubmit={onSearch}><span aria-hidden="true">⌕</span><input value={query} onChange={(event) => setQuery(event.target.value)} aria-label="Search everything" placeholder="Search everything... (commodities, companies, deals, people)" /><kbd>⌘ K</kbd></form>
        <div className="utility-actions"><span className="date-context">◉ &nbsp; Wed, 21 May 2025 &nbsp;|&nbsp; 14:34 &nbsp;(SGT)</span><i />
          <button className="icon-button" aria-label="Notifications" onClick={() => route("Notifications")}>♧<em>12</em></button>
          <button className="icon-button" aria-label="Inbox messages" onClick={() => route("Inbox")}>▱<em>7</em></button>
          <button className="profile-button" onClick={() => setMenuOpen(!menuOpen)} aria-expanded={menuOpen}><span className="avatar">R</span><span><strong>Reuss</strong><small>Director</small></span><span aria-hidden="true">⌄</span></button>
        </div>
      </header>

      <div className="dashboard-grid">
        <section className="panel briefing-card">
          <div className="briefing-copy"><p className="eyebrow">✥ &nbsp; SAPPHIRE AI <i /> DIRECTOR BRIEFING</p><h1>Good afternoon, <span>Reuss.</span></h1><p className="orientation">Here’s what matters right now.</p>
            <ul>{snapshot.briefing.map((point) => <li key={point.text} title={point.evidence}>{point.text}</li>)}</ul>
            <div className="hero-actions"><RouteButton className="primary-button" onRoute={route}>Review Opportunity</RouteButton><RouteButton className="secondary-button" onRoute={route}>Open Approvals</RouteButton><RouteButton className="secondary-button" onRoute={route}>Show Full Analysis</RouteButton></div>
          </div>
          <div className="globe-scene" aria-hidden="true"><div className="globe"><span className="globe-line longitude a" /><span className="globe-line longitude b" /><span className="globe-line latitude a" /><span className="globe-line latitude b" /><span className="globe-dot d1" /><span className="globe-dot d2" /><span className="globe-dot d3" /><span className="globe-dot d4" /></div></div>
          <span className="freshness">{snapshot.generatedAt}</span>
        </section>

        <section className="panel position-card"><PanelHeader icon="⌁" title="COMMERCIAL POSITION" action="View Finance" onRoute={route} />
          <div className="pipeline"><div><strong>£24.3M</strong><span>Pipeline Value</span><small className="state-positive">↑ 8.6% vs last 7 days</small></div><Sparkline points={[2,4,3,6,5,9,8,12]} /></div>
          <div className="metric-grid"><button onClick={() => route("Expected Commission")}><strong>£486k</strong><span>Expected Commission</span><small className="state-positive">↑ 12.4%</small></button><button onClick={() => route("High Confidence Deals")}><strong>4</strong><span>High Confidence Deals</span><small className="state-positive">↑ 1 new</small></button></div>
          <div className="metric-grid small"><button onClick={() => route("Value at Risk")}><strong>£1.2M</strong><span>Value at Risk</span><small className="state-critical">↓ 4.3%</small></button><button onClick={() => route("Settlement Due")}><strong>£82k</strong><span>Settlement Due (30d)</span></button><button onClick={() => route("Cash Position")}><span>Cash Position</span><strong className="state-positive">Healthy <b>●</b></strong></button></div>
        </section>

        <section className="panel radar-card"><PanelHeader icon="✺" title="MARKET RADAR" meta="Global Signal Overview" action="View Full Radar" onRoute={route} /><div className="radar-body"><WorldMap /><div className="radar-signals"><span>Hot Right Now</span>{snapshot.signals.map((signal) => <MarketSignalRow key={signal.name} signal={signal} compact onRoute={route} />)}</div></div></section>

        <section className="panel movement-card"><PanelHeader icon="⌁" title="COMMERCIAL MOVEMENT" meta="vs last 7 days" onRoute={route} /><div className="movement-list">{snapshot.movement.map((row: MovementRow) => <button key={row.label} onClick={() => route(row.label)}><span className="row-icon" aria-hidden="true">{row.icon}</span><span>{row.label}</span><strong>{row.value}</strong><small>{row.change}</small><Sparkline points={row.points} /></button>)}</div></section>

        <SummaryCard className="attention-card" icon="♟" title="DIRECTOR ATTENTION" count={5} rows={snapshot.attention} onRoute={route} />
        <SummaryCard className="actions-card" icon="▣" title="ACTIONS SUMMARY" count={18} rows={snapshot.actions} onRoute={route} />
        <SummaryCard className="inbox-card" icon="▣" title="INBOX SUMMARY" count={7} rows={snapshot.inbox} onRoute={route} />
        <section className="panel summary-card hot-card"><PanelHeader icon="♨" title="HOT RIGHT NOW" action="View All" onRoute={route} /><div className="signal-list">{snapshot.signals.map((signal) => <MarketSignalRow key={signal.name} signal={signal} onRoute={route} />)}</div></section>

        <section className="panel workspace-pulse"><button className="pulse-title" onClick={() => route("Workspace Pulse")}><span aria-hidden="true">✦</span> WORKSPACE PULSE</button>{snapshot.workspaces.map((workspace) => <button key={workspace.label} onClick={() => route(workspace.label)}><span>{workspace.label}</span><em className={workspace.state === "High" ? "high" : "medium"}>{workspace.state}</em></button>)}<button className="recent" onClick={() => route("Recent Activity")}>Recent Activity →</button></section>
      </div>
    </main>
    {notice && <div className="prototype-notice" role="status"><strong>Prototype route</strong><span>{notice}</span><button onClick={() => setNotice(null)} aria-label="Dismiss notification">×</button></div>}
    {menuOpen && <div className="profile-menu"><strong>Director session</strong><span>Authority-aware prototype</span><button onClick={() => route("Profile")}>Open profile</button></div>}
  </div>;
}
