"use client";

import type { ActionLens, ActionSummary, ActionWorkspaceSnapshot, MissionSummary, WorkJournalEntry } from "@sapphire/core-types";
import Link from "next/link";
import { useEffect, useMemo, useRef, useState } from "react";
import { WorkJournal } from "./work-journal";

const BRIEF_ID = "actions-brief-2026-08-07-0830-v1";
const BRIEF_STORAGE_KEY = "sapphire.actions.dismissed-brief.v1";
const NAV_PIN_STORAGE_KEY = "sapphire.actions.nav-pinned.v1";

const lenses: Array<{ id: ActionLens; label: string; symbol: string }> = [
  { id: "my_actions", label: "My Actions", symbol: "⌁" },
  { id: "missions", label: "Missions", symbol: "◇" },
  { id: "team", label: "Team", symbol: "◎" },
  { id: "approvals_decisions", label: "Approvals & Decisions", symbol: "△" },
  { id: "waiting_on", label: "Waiting On", symbol: "◷" },
  { id: "overdue", label: "Overdue", symbol: "!" },
  { id: "completed", label: "Completed", symbol: "✓" },
];

function matchesLens(action: ActionSummary, lens: ActionLens, actorId: string) {
  if (lens === "my_actions") return action.owner?.id === actorId;
  if (lens === "team") return true;
  if (lens === "approvals_decisions") return ["approval_request", "decision_request"].includes(action.itemKind);
  if (lens === "waiting_on") return action.status === "waiting";
  if (lens === "overdue") return action.dueState === "overdue";
  if (lens === "completed") return action.status === "completed";
  return true;
}

function shortDate(value: string | null) {
  if (!value) return "No due date";
  return new Intl.DateTimeFormat("en-GB", { day: "numeric", month: "short", hour: "2-digit", minute: "2-digit", hour12: false }).format(new Date(value));
}

function countFor(lens: ActionLens, snapshot: ActionWorkspaceSnapshot) {
  if (lens === "missions") return snapshot.missions.length;
  return snapshot.actions.filter((action) => matchesLens(action, lens, snapshot.actor.id)).length;
}

export function ActionsWorkspace({ initialSnapshot }: { initialSnapshot: ActionWorkspaceSnapshot }) {
  const [lens, setLens] = useState<ActionLens>("my_actions");
  const [selectedId, setSelectedId] = useState(initialSnapshot.actions[0]?.id ?? "");
  const [selectedMissionId, setSelectedMissionId] = useState(initialSnapshot.missions[0]?.id ?? "");
  const [query, setQuery] = useState("");
  const [priority, setPriority] = useState("all");
  const [sort, setSort] = useState("rank");
  const [group, setGroup] = useState("none");
  const [dialog, setDialog] = useState<"action" | "mission" | null>(null);
  const [notice, setNotice] = useState<string | null>(null);
  const [briefDismissed, setBriefDismissed] = useState(false);
  const [briefOpen, setBriefOpen] = useState(false);
  const [navHovered, setNavHovered] = useState(false);
  const [navPinned, setNavPinned] = useState(false);
  const [mobileNavOpen, setMobileNavOpen] = useState(false);
  const [contextOpen, setContextOpen] = useState(false);
  const [journalOpen, setJournalOpen] = useState(false);
  const searchRef = useRef<HTMLInputElement>(null);
  const navCloseTimer = useRef<ReturnType<typeof setTimeout> | null>(null);

  useEffect(() => {
    const frame = window.requestAnimationFrame(() => {
      try {
        setBriefDismissed(window.localStorage.getItem(BRIEF_STORAGE_KEY) === BRIEF_ID);
        setNavPinned(window.sessionStorage.getItem(NAV_PIN_STORAGE_KEY) === "true");
      } catch { /* presentation persistence is optional */ }
    });
    return () => window.cancelAnimationFrame(frame);
  }, []);

  const visibleActions = useMemo(() => {
    const normalised = query.trim().toLowerCase();
    return initialSnapshot.actions
      .filter((action) => matchesLens(action, lens, initialSnapshot.actor.id))
      .filter((action) => priority === "all" || action.priority === priority)
      .filter((action) => !normalised || [action.title, action.requiredOutcome, action.mission?.title, action.owner?.name, ...action.links.map((link) => link.label)].filter(Boolean).some((value) => value?.toLowerCase().includes(normalised)))
      .sort((a, b) => sort === "due" ? (a.dueAt ?? "9999").localeCompare(b.dueAt ?? "9999") : b.rankScore - a.rankScore);
  }, [initialSnapshot, lens, priority, query, sort]);

  const visibleMissions = useMemo(() => {
    const normalised = query.trim().toLowerCase();
    return initialSnapshot.missions
      .filter((mission) => priority === "all" || mission.priority === priority)
      .filter((mission) => !normalised || [mission.title, mission.objective, mission.owner.name, mission.commercialContext, mission.nextMilestone].some((value) => value.toLowerCase().includes(normalised)))
      .sort((a, b) => sort === "due" ? a.targetAt.localeCompare(b.targetAt) : b.progressPercent - a.progressPercent);
  }, [initialSnapshot.missions, priority, query, sort]);

  const selected = visibleActions.find((action) => action.id === selectedId) ?? visibleActions[0] ?? null;
  const selectedMission = visibleMissions.find((mission) => mission.id === selectedMissionId) ?? visibleMissions[0] ?? null;
  const journalEntries = lens === "missions" ? initialSnapshot.journals[selectedMission?.id ?? ""] ?? [] : initialSnapshot.journals[selected?.id ?? ""] ?? [];
  const journalLabel = lens === "missions" ? selectedMission?.title ?? "Mission" : selected?.title ?? "Action";

  const groupedActions = useMemo(() => {
    const groups = new Map<string, ActionSummary[]>();
    for (const action of visibleActions) {
      const key = group === "mission" ? action.mission?.title ?? "Independent actions" : group === "priority" ? `${action.priority[0]?.toUpperCase()}${action.priority.slice(1)} priority` : group === "owner" ? action.owner?.name ?? "Unowned" : "Ranked actions";
      groups.set(key, [...(groups.get(key) ?? []), action]);
    }
    return Array.from(groups.entries());
  }, [group, visibleActions]);

  useEffect(() => {
    function onKeyDown(event: KeyboardEvent) {
      if (event.key === "Escape") {
        setDialog(null); setBriefOpen(false); setMobileNavOpen(false); setContextOpen(false); setJournalOpen(false);
        return;
      }
      if (event.metaKey || event.ctrlKey || event.altKey || event.target instanceof HTMLInputElement || event.target instanceof HTMLTextAreaElement || event.target instanceof HTMLSelectElement) return;
      if (event.key === "/") { event.preventDefault(); searchRef.current?.focus(); }
      if (event.key.toLowerCase() === "n") setDialog("action");
      if (event.key.toLowerCase() === "m") setDialog("mission");
      if (event.key === "j" || event.key === "k") {
        const current = visibleActions.findIndex((action) => action.id === selectedId);
        const next = event.key === "j" ? Math.min(visibleActions.length - 1, current + 1) : Math.max(0, current - 1);
        if (visibleActions[next]) setSelectedId(visibleActions[next].id);
      }
    }
    window.addEventListener("keydown", onKeyDown);
    return () => window.removeEventListener("keydown", onKeyDown);
  }, [selectedId, visibleActions]);

  function revealNav() {
    if (navCloseTimer.current) clearTimeout(navCloseTimer.current);
    setNavHovered(true);
  }

  function scheduleNavClose() {
    if (navCloseTimer.current) clearTimeout(navCloseTimer.current);
    navCloseTimer.current = setTimeout(() => setNavHovered(false), 180);
  }

  function toggleNavPin() {
    const next = !navPinned;
    setNavPinned(next);
    try { window.sessionStorage.setItem(NAV_PIN_STORAGE_KEY, String(next)); } catch { /* optional */ }
  }

  function dismissBrief() {
    setBriefDismissed(true);
    try { window.localStorage.setItem(BRIEF_STORAGE_KEY, BRIEF_ID); } catch { /* optional */ }
  }

  function guardedCommand(label: string) {
    setNotice(`${label} requires an authoritative Actions RPC. No fixture state was changed.`);
  }

  function selectAction(id: string) {
    setSelectedId(id); setContextOpen(true); setJournalOpen(false);
  }

  function selectMission(id: string) {
    setSelectedMissionId(id); setContextOpen(true); setJournalOpen(false);
  }

  const navExpanded = navHovered || navPinned || mobileNavOpen;

  return <main className="actions-app">
    <aside className="brand-rail" aria-label="Sapphire workspaces" data-expanded={navExpanded} data-mobile-open={mobileNavOpen} onMouseEnter={revealNav} onMouseLeave={scheduleNavClose} onFocus={revealNav} onBlur={(event) => { if (!event.currentTarget.contains(event.relatedTarget)) scheduleNavClose(); }}>
      <div className="nav-brand-row"><Link className="brand" href="/" aria-label="Sapphire Core OS home"><span className="brand-mark">◇</span><span>SAPPHIRE<small>CORE OS</small></span></Link><button type="button" className="nav-pin" aria-label={navPinned ? "Unpin workspace navigation" : "Pin workspace navigation"} aria-pressed={navPinned} onClick={toggleNavPin}>{navPinned ? "●" : "○"}</button><button type="button" className="nav-mobile-close" aria-label="Close workspace navigation" onClick={() => setMobileNavOpen(false)}>×</button></div>
      <nav className="workspace-nav" aria-label="Primary workspaces">{["Home", "Actions", "Inbox", "Market Radar", "Demand", "Supply", "Opportunities", "Matching", "Deals", "Network", "Profiles", "Intelligence", "Documents", "Finance", "Governance"].map((item) => <Link key={item} href={item === "Actions" ? "/actions" : `/${item.toLowerCase().replaceAll(" ", "-")}`} className={item === "Actions" ? "active" : ""}><span aria-hidden="true">{item === "Actions" ? "◆" : "◇"}</span><b>{item}</b></Link>)}</nav>
      <div className="system-state"><span /> <b>All systems operational</b></div>
    </aside>
    {mobileNavOpen && <button type="button" className="nav-scrim" aria-label="Close workspace navigation" onClick={() => setMobileNavOpen(false)} />}

    <section className="workspace-shell">
      <header className="command-header">
        <div className="command-title"><button type="button" className="mobile-menu-button" aria-label="Open workspace navigation" onClick={() => setMobileNavOpen(true)}>☰</button><div><p className="eyebrow">EXECUTION WORKSPACE</p><h1>Actions</h1></div></div>
        <div className="command-actions"><button className="primary-button compact-command" type="button" onClick={() => setDialog("action")}>＋ Action</button><button className="secondary-button compact-command" type="button" onClick={() => setDialog("mission")}>＋ Mission</button><div className="director-chip"><span>R</span><div><strong>Reuss</strong><small>Director</small></div></div></div>
      </header>

      {!briefDismissed && <section className="execution-brief" aria-labelledby="brief-title" data-brief-id={BRIEF_ID}><div className="brief-icon" aria-hidden="true">✦</div><div className="brief-copy"><p className="eyebrow">NEW EXECUTION BRIEF · 08:30</p><h2 id="brief-title">Two conditions need Director attention before midday.</h2><p>Pricing authority is holding the copper buyer offer. Supplier KYC is overdue. Three buyer follow-ups remain on course.</p></div><div className="brief-actions"><button type="button" onClick={() => setBriefOpen(true)}>Open full brief</button><button type="button" aria-label="Dismiss execution brief" onClick={dismissBrief}>× Dismiss</button></div></section>}

      <section className="lens-strip" aria-label="Actions lenses"><div className="lens-buttons">{lenses.map((item) => <button type="button" key={item.id} className={lens === item.id ? "selected" : ""} onClick={() => { setLens(item.id); setContextOpen(false); setJournalOpen(false); }}><span aria-hidden="true">{item.symbol}</span>{item.label}<b>{countFor(item.id, initialSnapshot)}</b></button>)}</div><div className="mission-chips" aria-label="Active missions">{initialSnapshot.missions.map((mission) => <button type="button" key={mission.id} onClick={() => { setLens("missions"); selectMission(mission.id); setQuery(""); }}><span className={`health-dot ${mission.health}`} />{mission.title}<b>{mission.progressPercent}%</b></button>)}</div></section>

      <div className="actions-grid">
        <section className="queue-pane" aria-labelledby="queue-title">
          <div className="queue-toolbar"><div><p className="eyebrow">RANKED QUEUE</p><h2 id="queue-title">{lenses.find((item) => item.id === lens)?.label}</h2></div><div className="queue-controls"><label className="search-control"><span aria-hidden="true">⌕</span><span className="sr-only">Search current view</span><input ref={searchRef} value={query} onChange={(event) => setQuery(event.target.value)} placeholder={lens === "missions" ? "Search missions…" : "Search actions…"} /></label><label><span className="sr-only">Priority filter</span><select value={priority} onChange={(event) => setPriority(event.target.value)}><option value="all">All priority</option><option value="critical">Critical</option><option value="high">High</option><option value="normal">Normal</option><option value="low">Low</option></select></label><label><span className="sr-only">Sort actions</span><select value={sort} onChange={(event) => setSort(event.target.value)}><option value="rank">Ranked</option><option value="due">Due date</option></select></label>{lens !== "missions" && <label><span className="sr-only">Group actions</span><select value={group} onChange={(event) => setGroup(event.target.value)}><option value="none">No grouping</option><option value="mission">By mission</option><option value="priority">By priority</option><option value="owner">By owner</option></select></label>}</div></div>
          <div className="queue-summary" aria-live="polite"><span>{lens === "missions" ? `${visibleMissions.length} missions` : `${visibleActions.length} actions`}</span><span>Commercial consequence · due state · authority</span></div>
          <div className="queue-list" role="listbox" aria-label={lens === "missions" ? "Missions" : "Ranked actions"}>{lens === "missions" ? visibleMissions.map((mission) => <MissionRow key={mission.id} mission={mission} selected={selectedMission?.id === mission.id} onSelect={() => selectMission(mission.id)} />) : groupedActions.map(([groupLabel, actions]) => <div className="action-group" role="group" aria-label={groupLabel} key={groupLabel}>{group !== "none" && <h3 className="group-heading">{groupLabel}<span>{actions.length}</span></h3>}{actions.map((action) => <ActionRow key={action.id} action={action} selected={selected?.id === action.id} onSelect={() => selectAction(action.id)} />)}</div>)}{(lens === "missions" ? visibleMissions.length : visibleActions.length) === 0 && <div className="empty-state"><strong>No matching {lens === "missions" ? "missions" : "actions"}.</strong><span>Clear search or filters; this does not imply system-wide absence.</span><button type="button" onClick={() => { setQuery(""); setPriority("all"); }}>Clear filters</button></div>}</div>
        </section>

        <section className={`context-canvas ${contextOpen ? "open" : ""}`} aria-label={lens === "missions" ? "Selected mission context" : "Selected action context"}>{lens === "missions" && selectedMission ? <MissionContext mission={selectedMission} entries={journalEntries} onClose={() => setContextOpen(false)} onOpenJournal={() => { setContextOpen(false); setJournalOpen(true); }} onCommand={guardedCommand} /> : selected ? <ActionContext action={selected} entries={journalEntries} onClose={() => setContextOpen(false)} onOpenJournal={() => { setContextOpen(false); setJournalOpen(true); }} onCommand={guardedCommand} /> : <div className="context-empty">Select an item to open its execution context.</div>}</section>

        <aside className={`journal-pane ${journalOpen ? "open" : ""}`} aria-label="Work Journal context"><div className="journal-pane-heading"><div><p className="eyebrow">COLLABORATION & EVIDENCE</p><strong>{journalLabel}</strong></div><button type="button" aria-label="Close Work Journal" onClick={() => setJournalOpen(false)}>×</button></div><WorkJournal entries={journalEntries} subjectLabel={journalLabel} onCommand={guardedCommand} /></aside>
      </div>

      <footer className="workspace-footer"><span><kbd>/</kbd> search</span><span><kbd>J</kbd><kbd>K</kbd> navigate</span><span><kbd>N</kbd> action</span><span><kbd>M</kbd> mission</span><span className="freshness">Fixture · 07 Aug 2026 08:30 · authoritative adapter pending</span></footer>
    </section>

    {notice && <div className="toast" role="status"><span>i</span>{notice}<button type="button" aria-label="Dismiss notification" onClick={() => setNotice(null)}>×</button></div>}
    {briefOpen && <BriefDialog onClose={() => setBriefOpen(false)} />}
    {dialog && <CreationDialog kind={dialog} onClose={() => setDialog(null)} onValidated={() => { setDialog(null); setNotice(`Create ${dialog} preview validated. Backend RPC connection is required before it becomes execution truth.`); }} />}
  </main>;
}

function ActionRow({ action, selected, onSelect }: { action: ActionSummary; selected: boolean; onSelect: () => void }) {
  return <button type="button" role="option" aria-selected={selected} className={`action-row ${selected ? "selected" : ""}`} onClick={onSelect}><span className={`priority-bar ${action.priority}`} /><span className="row-rank"><strong>{action.rankScore}</strong><small>rank</small></span><span className="row-content"><span className="row-title"><strong>{action.title}</strong>{action.authorityRequired && <em className="authority-badge">Director</em>}</span><span className="row-meta">{action.mission?.title ?? "Independent"} · {action.owner?.name ?? "Unowned"}</span><span className="row-consequence">{action.commercialConsequence}</span></span><span className={`due-state ${action.dueState}`}><strong>{action.dueState.replaceAll("_", " ")}</strong><small>{shortDate(action.dueAt)}</small></span></button>;
}

function MissionRow({ mission, selected, onSelect }: { mission: MissionSummary; selected: boolean; onSelect: () => void }) {
  return <button type="button" role="option" aria-selected={selected} className={`mission-row ${selected ? "selected" : ""}`} onClick={onSelect}><span className={`priority-bar ${mission.priority}`} /><span className="mission-row-content"><span className="row-title"><strong>{mission.title}</strong><em className={`mission-health ${mission.health}`}>{mission.health.replaceAll("_", " ")}</em></span><span className="row-consequence">{mission.objective}</span><span className="row-meta">{mission.owner.name} · {mission.openActionCount} open</span><span className="mission-progress"><i style={{ width: `${mission.progressPercent}%` }} /><span>{mission.progressPercent}%</span></span></span><span className="mission-target"><strong>{mission.blockerCount ? `${mission.blockerCount} blockers` : "On course"}</strong><small>{shortDate(mission.targetAt)}</small></span></button>;
}

function ContextHeading({ label, status, onClose }: { label: string; status: string; onClose: () => void }) {
  return <div className="inspector-heading"><div><p className="eyebrow">{label}</p><span className={`status-label ${status}`}>{status.replaceAll("_", " ")}</span></div><div className="inspector-heading-actions"><button className="inspector-close" type="button" aria-label={`Close ${label.toLowerCase()}`} onClick={onClose}>×</button><button type="button" aria-label="More context commands">•••</button></div></div>;
}

function ActionContext({ action, entries, onClose, onOpenJournal, onCommand }: { action: ActionSummary; entries: WorkJournalEntry[]; onClose: () => void; onOpenJournal: () => void; onCommand: (label: string) => void }) {
  return <><ContextHeading label="ACTION CONTEXT" status={action.status} onClose={onClose} /><h2>{action.title}</h2><p className="required-outcome">{action.requiredOutcome}</p><div className="context-primary-actions"><button type="button" className="journal-open-command" onClick={onOpenJournal}>Work Journal <span>{entries.length}</span></button><button type="button" aria-label="Open next action command" onClick={() => onCommand("Open next action")}>Next action →</button></div><div className="consequence-card"><span>COMMERCIAL CONSEQUENCE</span><p>{action.commercialConsequence}</p></div><dl className="facts-grid"><div><dt>Owner</dt><dd><span className="avatar">{action.owner?.initials ?? "?"}</span>{action.owner?.name ?? "Unowned"}</dd></div><div><dt>Due</dt><dd>{shortDate(action.dueAt)}</dd></div><div><dt>Priority</dt><dd>{action.priority}</dd></div><div><dt>Kind</dt><dd>{action.itemKind.replaceAll("_", " ")}</dd></div></dl>{(action.blockedReason || action.waitingReason) && <section className="condition-panel"><strong>{action.blockedReason ? "Blocked" : "Waiting on"}</strong><p>{action.blockedReason ?? action.waitingReason}</p>{action.expectedResumeAt && <small>Expected {shortDate(action.expectedResumeAt)}</small>}</section>}<div className="context-detail-grid"><section className="inspector-section"><div className="section-title"><h3>Why this ranks here</h3><span>{action.rankScore}/100</span></div><ul>{action.rankFactors.map((factor) => <li key={factor}>{factor}</li>)}</ul></section><section className="inspector-section"><div className="section-title"><h3>Linked records</h3><span>{action.links.length}</span></div>{action.links.map((link) => <Link className="record-link" href={link.href} key={link.id}><span>◇</span><span><strong>{link.label}</strong><small>{link.workspace}</small></span><b>↗</b></Link>)}</section></div><section className="inspector-section evidence"><div className="section-title"><h3>Completion evidence</h3><span>{action.evidenceRequired ? "Required" : "Optional"}</span></div><p>{action.evidenceRequired ? "Completion remains unavailable until governed evidence is attached." : "Evidence is optional unless policy changes."}</p><button type="button" onClick={() => onCommand("Add evidence")}>＋ Link evidence</button></section><div className="completion-policy"><strong>Completion contract</strong><span>{action.completionOutcomeRequired ? "Published outcome Activity required." : "Outcome Activity optional."} {action.evidenceRequired ? "Governed evidence also required." : "No evidence gate."}</span></div><div className="inspector-actions"><button type="button" className="secondary-button" onClick={() => onCommand("Mark waiting")}>Mark waiting</button><button type="button" className="primary-button" onClick={() => onCommand(action.authorityRequired ? "Open Governance approval" : "Complete action")}>{action.authorityRequired ? "Open approval" : "Complete"}</button></div></>;
}

function MissionContext({ mission, entries, onClose, onOpenJournal, onCommand }: { mission: MissionSummary; entries: WorkJournalEntry[]; onClose: () => void; onOpenJournal: () => void; onCommand: (label: string) => void }) {
  const exposure = mission.valueExposure ? new Intl.NumberFormat("en-GB", { style: "currency", currency: mission.valueExposure.currency, maximumFractionDigits: 0 }).format(mission.valueExposure.amount) : "Not quantified";
  return <><ContextHeading label="MISSION CONTEXT" status={mission.status} onClose={onClose} /><h2>{mission.title}</h2><p className="required-outcome">{mission.objective}</p><div className="context-primary-actions"><button type="button" className="journal-open-command" onClick={onOpenJournal}>Work Journal <span>{entries.length}</span></button><button type="button" onClick={() => onCommand("Create linked action")}>＋ Linked action</button></div><div className="consequence-card"><span>COMMERCIAL CONTEXT</span><p>{mission.commercialContext} · {exposure} exposure</p></div><dl className="facts-grid"><div><dt>Owner</dt><dd><span className="avatar">{mission.owner.initials}</span>{mission.owner.name}</dd></div><div><dt>Target</dt><dd>{shortDate(mission.targetAt)}</dd></div><div><dt>Priority</dt><dd>{mission.priority}</dd></div><div><dt>Health</dt><dd>{mission.health.replaceAll("_", " ")}</dd></div></dl><section className="mission-progress-card"><div><span>Mission progress</span><strong>{mission.progressPercent}%</strong></div><span><i style={{ width: `${mission.progressPercent}%` }} /></span></section><div className="context-detail-grid"><section className="inspector-section"><div className="section-title"><h3>Next milestone</h3><span>{mission.openActionCount} open</span></div><p className="mission-milestone">{mission.nextMilestone}</p></section><section className="inspector-section"><div className="section-title"><h3>Execution conditions</h3><span>{mission.blockerCount} blockers</span></div><ul><li>Progress derives from authoritative Action state.</li><li>Health remains Director-reviewed.</li><li>Governance owns protected authority.</li></ul></section></div><div className="inspector-actions"><button type="button" className="secondary-button" onClick={() => onCommand("Open mission plan")}>Open plan</button><button type="button" className="primary-button" onClick={() => onCommand("Create linked action")}>Create action</button></div></>;
}

function BriefDialog({ onClose }: { onClose: () => void }) {
  return <div className="dialog-backdrop" role="presentation" onMouseDown={onClose}><section className="dialog brief-dialog" role="dialog" aria-modal="true" aria-labelledby="full-brief-title" onMouseDown={(event) => event.stopPropagation()}><div className="dialog-heading"><div><p className="eyebrow">SAPPHIRE EXECUTION BRIEF · 08:30</p><h2 id="full-brief-title">Director briefing</h2></div><button type="button" aria-label="Close full execution brief" onClick={onClose}>×</button></div><div className="full-brief-content"><article><strong>Pricing authority</strong><p>The copper buyer offer remains held until the protected pricing range is approved in Governance.</p></article><article><strong>Supplier verification</strong><p>Beneficial-owner evidence is overdue and prevents the Zambian supplier entering verified matching.</p></article><article><strong>Buyer movement</strong><p>Three qualified buyer follow-ups remain due today. Sofia Marin requires assay evidence and an indicative range.</p></article></div><div className="brief-dialog-actions"><button type="button" className="secondary-button" onClick={onClose}>Return to Actions</button></div></section></div>;
}

function CreationDialog({ kind, onClose, onValidated }: { kind: "action" | "mission"; onClose: () => void; onValidated: () => void }) {
  return <div className="dialog-backdrop" role="presentation" onMouseDown={onClose}><section className="dialog" role="dialog" aria-modal="true" aria-labelledby="dialog-title" onMouseDown={(event) => event.stopPropagation()}><div className="dialog-heading"><div><p className="eyebrow">STRUCTURED CREATION</p><h2 id="dialog-title">Create {kind}</h2></div><button type="button" aria-label="Close dialog" onClick={onClose}>×</button></div><p>Review the accountable outcome, owner and context before an authoritative RPC commits work.</p><form onSubmit={(event) => { event.preventDefault(); onValidated(); }}><label>Required outcome<input autoFocus required name="title" placeholder={kind === "action" ? "What must happen?" : "What commercial outcome must be achieved?"} /></label><div className="form-row"><label>Owner<select name="owner"><option>Reuss · Director</option><option>Maya Chen · Closer</option><option>Idris Cole · Research</option></select></label><label>Priority<select name="priority"><option>Normal</option><option>High</option><option>Critical</option><option>Low</option></select></label></div><label>Mission or governed context<select name="context"><option>Secure copper cathode mandate</option><option>Verify gold supplier network</option><option>Complete transaction banking readiness</option><option>Independent action</option></select></label><label>Success or completion evidence<textarea name="evidence" rows={3} placeholder="What will prove the outcome?" /></label><div className="dialog-actions"><button type="button" className="secondary-button" onClick={onClose}>Cancel</button><button type="submit" className="primary-button">Validate preview</button></div></form></section></div>;
}
