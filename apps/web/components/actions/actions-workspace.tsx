"use client";

import type { ActionLens, ActionSummary, ActionWorkspaceSnapshot, MissionSummary } from "@sapphire/core-types";
import Link from "next/link";
import { useEffect, useMemo, useRef, useState } from "react";
import { WorkJournal } from "./work-journal";

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
  const [query, setQuery] = useState("");
  const [priority, setPriority] = useState("all");
  const [sort, setSort] = useState("rank");
  const [group, setGroup] = useState("none");
  const [selectedMissionId, setSelectedMissionId] = useState(initialSnapshot.missions[0]?.id ?? "");
  const [dialog, setDialog] = useState<"action" | "mission" | null>(null);
  const [notice, setNotice] = useState<string | null>(null);
  const [inspectorOpen, setInspectorOpen] = useState(false);
  const [inspectorTab, setInspectorTab] = useState<"overview" | "journal">("overview");
  const searchRef = useRef<HTMLInputElement>(null);

  const visibleActions = useMemo(() => {
    const normalised = query.trim().toLowerCase();
    return initialSnapshot.actions
      .filter((action) => matchesLens(action, lens, initialSnapshot.actor.id))
      .filter((action) => priority === "all" || action.priority === priority)
      .filter((action) => !normalised || [action.title, action.requiredOutcome, action.mission?.title, action.owner?.name, ...action.links.map((link) => link.label)].filter(Boolean).some((value) => value?.toLowerCase().includes(normalised)))
      .sort((a, b) => sort === "due" ? (a.dueAt ?? "9999").localeCompare(b.dueAt ?? "9999") : b.rankScore - a.rankScore);
  }, [initialSnapshot, lens, priority, query, sort]);

  const selected = visibleActions.find((action) => action.id === selectedId) ?? visibleActions[0] ?? null;

  const visibleMissions = useMemo(() => {
    const normalised = query.trim().toLowerCase();
    return initialSnapshot.missions
      .filter((mission) => priority === "all" || mission.priority === priority)
      .filter((mission) => !normalised || [mission.title, mission.objective, mission.owner.name, mission.commercialContext, mission.nextMilestone].some((value) => value.toLowerCase().includes(normalised)))
      .sort((a, b) => sort === "due" ? a.targetAt.localeCompare(b.targetAt) : b.progressPercent - a.progressPercent);
  }, [initialSnapshot.missions, priority, query, sort]);

  const selectedMission = visibleMissions.find((mission) => mission.id === selectedMissionId) ?? visibleMissions[0] ?? null;

  const groupedActions = useMemo(() => {
    const keyFor = (action: ActionSummary) => {
      if (group === "mission") return action.mission?.title ?? "Independent actions";
      if (group === "priority") return `${action.priority[0]?.toUpperCase()}${action.priority.slice(1)} priority`;
      if (group === "owner") return action.owner?.name ?? "Unowned";
      return "Ranked actions";
    };
    const groups = new Map<string, ActionSummary[]>();
    for (const action of visibleActions) {
      const key = keyFor(action);
      groups.set(key, [...(groups.get(key) ?? []), action]);
    }
    return Array.from(groups.entries());
  }, [group, visibleActions]);

  useEffect(() => {
    function onKeyDown(event: KeyboardEvent) {
      if (event.metaKey || event.ctrlKey || event.altKey || event.target instanceof HTMLInputElement || event.target instanceof HTMLTextAreaElement || event.target instanceof HTMLSelectElement) return;
      if (event.key === "/") { event.preventDefault(); searchRef.current?.focus(); }
      if (event.key.toLowerCase() === "n") setDialog("action");
      if (event.key.toLowerCase() === "m") setDialog("mission");
      if (event.key === "j" || event.key === "k") {
        const current = visibleActions.findIndex((action) => action.id === selectedId);
        const next = event.key === "j" ? Math.min(visibleActions.length - 1, current + 1) : Math.max(0, current - 1);
        if (visibleActions[next]) setSelectedId(visibleActions[next].id);
      }
      if (event.key === "Escape") setDialog(null);
    }
    window.addEventListener("keydown", onKeyDown);
    return () => window.removeEventListener("keydown", onKeyDown);
  }, [selectedId, visibleActions]);

  function guardedCommand(label: string) {
    setNotice(`${label} requires an authoritative Actions RPC. No fixture state was changed.`);
  }

  return (
    <main className="actions-app">
      <aside className="brand-rail" aria-label="Sapphire workspaces">
        <Link className="brand" href="/" aria-label="Sapphire Core OS home"><span className="brand-mark">◇</span><span>SAPPHIRE<small>CORE OS</small></span></Link>
        <nav className="workspace-nav" aria-label="Primary workspaces">
          {["Home", "Actions", "Inbox", "Market Radar", "Demand", "Supply", "Opportunities", "Matching", "Deals", "Network", "Profiles", "Intelligence", "Documents", "Finance", "Governance"].map((item) => (
            <Link key={item} href={item === "Actions" ? "/actions" : `/${item.toLowerCase().replaceAll(" ", "-")}`} className={item === "Actions" ? "active" : ""}><span aria-hidden="true">{item === "Actions" ? "◆" : "◇"}</span>{item}</Link>
          ))}
        </nav>
        <div className="system-state"><span /> All systems operational</div>
      </aside>

      <section className="workspace-shell">
        <header className="command-header">
          <div><p className="eyebrow">EXECUTION WORKSPACE</p><h1>Actions</h1><p>Accountable commercial work, authority and evidence in one place.</p></div>
          <div className="command-actions">
            <button className="secondary-button" type="button" onClick={() => setDialog("mission")}>＋ Create mission</button>
            <button className="primary-button" type="button" onClick={() => setDialog("action")}>＋ Create action</button>
            <div className="director-chip"><span>R</span><div><strong>Reuss</strong><small>Director mode</small></div></div>
          </div>
        </header>

        <section className="execution-brief" aria-labelledby="brief-title">
          <div className="brief-icon" aria-hidden="true">✦</div>
          <div><p className="eyebrow">SAPPHIRE EXECUTION BRIEF · 08:30</p><h2 id="brief-title">Two conditions need Director attention before midday.</h2><p>Pricing authority is holding the copper buyer offer. Supplier KYC is overdue and blocking verified matching. Three buyer follow-ups remain on course for today.</p></div>
          <div className="brief-metrics"><span><strong>2</strong> critical</span><span><strong>1</strong> overdue</span><span><strong>3</strong> missions active</span></div>
        </section>

        <div className="actions-grid">
          <aside className="lens-rail" aria-label="Actions lenses">
            <p className="rail-label">LENSES</p>
            {lenses.map((item) => <button type="button" key={item.id} className={lens === item.id ? "selected" : ""} onClick={() => { setLens(item.id); if (window.matchMedia("(max-width: 980px)").matches) setInspectorOpen(false); }}><span aria-hidden="true">{item.symbol}</span><span>{item.label}</span><b>{countFor(item.id, initialSnapshot)}</b></button>)}
            <div className="rail-separator" />
            <p className="rail-label">ACTIVE MISSIONS</p>
            {initialSnapshot.missions.map((mission) => <button type="button" className="mission-link" key={mission.id} onClick={() => { setLens("missions"); setSelectedMissionId(mission.id); setQuery(""); setInspectorOpen(true); }}><span className={`health-dot ${mission.health}`} /><span>{mission.title}</span><b>{mission.progressPercent}%</b></button>)}
          </aside>

          <section className="queue-pane" aria-labelledby="queue-title">
            <div className="queue-toolbar">
              <div><p className="eyebrow">RANKED QUEUE</p><h2 id="queue-title">{lenses.find((item) => item.id === lens)?.label}</h2></div>
              <div className="queue-controls">
                <label className="search-control"><span aria-hidden="true">⌕</span><span className="sr-only">Search current view</span><input ref={searchRef} value={query} onChange={(event) => setQuery(event.target.value)} placeholder={lens === "missions" ? "Search missions…" : "Search actions…"} /></label>
                <label><span className="sr-only">Priority filter</span><select value={priority} onChange={(event) => setPriority(event.target.value)}><option value="all">All priority</option><option value="critical">Critical</option><option value="high">High</option><option value="normal">Normal</option><option value="low">Low</option></select></label>
                <label><span className="sr-only">Sort actions</span><select value={sort} onChange={(event) => setSort(event.target.value)}><option value="rank">Ranked</option><option value="due">Due date</option></select></label>
                {lens !== "missions" && <label><span className="sr-only">Group actions</span><select value={group} onChange={(event) => setGroup(event.target.value)}><option value="none">No grouping</option><option value="mission">By mission</option><option value="priority">By priority</option><option value="owner">By owner</option></select></label>}
              </div>
            </div>
            <div className="queue-summary" aria-live="polite"><span>{lens === "missions" ? `${visibleMissions.length} visible missions` : `${visibleActions.length} visible actions`}</span><span>{lens === "missions" ? "Health, progress and commercial exposure remain distinct" : "Rank explains commercial consequence, due state and authority"}</span></div>
            <div className="queue-list" role="listbox" aria-label={lens === "missions" ? "Missions" : "Ranked actions"}>
              {lens === "missions" ? visibleMissions.map((mission) => (
                <button type="button" role="option" aria-selected={selectedMission?.id === mission.id} className={`mission-row ${selectedMission?.id === mission.id ? "selected" : ""}`} key={mission.id} onClick={() => { setSelectedMissionId(mission.id); setInspectorOpen(true); }}>
                  <span className={`priority-bar ${mission.priority}`} />
                  <span className="mission-row-content"><span className="row-title"><strong>{mission.title}</strong><em className={`mission-health ${mission.health}`}>{mission.health.replaceAll("_", " ")}</em></span><span className="row-consequence">{mission.objective}</span><span className="row-meta"><span>{mission.commercialContext}</span><span>·</span><span>{mission.owner.name}</span><span>·</span><span>{mission.openActionCount} open</span></span><span className="mission-progress"><i style={{ width: `${mission.progressPercent}%` }} /><span>{mission.progressPercent}%</span></span></span>
                  <span className="mission-target"><strong>{mission.blockerCount ? `${mission.blockerCount} blocker${mission.blockerCount === 1 ? "" : "s"}` : "On course"}</strong><small>Target {shortDate(mission.targetAt)}</small></span>
                  <span className="row-arrow" aria-hidden="true">›</span>
                </button>
              )) : groupedActions.map(([groupLabel, actions]) => (
                <div className="action-group" role="group" aria-label={groupLabel} key={groupLabel}>
                  {group !== "none" && <h3 className="group-heading">{groupLabel}<span>{actions.length}</span></h3>}
                  {actions.map((action) => (
                    <button type="button" role="option" aria-selected={selected?.id === action.id} className={`action-row ${selected?.id === action.id ? "selected" : ""}`} key={action.id} onClick={() => { setSelectedId(action.id); setInspectorOpen(true); }}>
                      <span className={`priority-bar ${action.priority}`} />
                      <span className="row-rank"><strong>{action.rankScore}</strong><small>rank</small></span>
                      <span className="row-content"><span className="row-title"><strong>{action.title}</strong>{action.authorityRequired && <em className="authority-badge">Director authority</em>}</span><span className="row-meta"><span>{action.mission?.title ?? "Independent action"}</span><span>·</span><span>{action.sourceWorkspace}</span><span>·</span><span>{action.owner?.name ?? "Unowned"}</span></span><span className="row-consequence">{action.commercialConsequence}</span></span>
                      <span className={`due-state ${action.dueState}`}><strong>{action.dueState.replaceAll("_", " ")}</strong><small>{shortDate(action.dueAt)}</small></span>
                      <span className="row-arrow" aria-hidden="true">›</span>
                    </button>
                  ))}
                </div>
              ))}
              {(lens === "missions" ? visibleMissions.length : visibleActions.length) === 0 && <div className="empty-state"><strong>No {lens === "missions" ? "missions" : "actions"} match this view.</strong><span>Clear search or filters; this does not imply system-wide absence.</span><button type="button" onClick={() => { setQuery(""); setPriority("all"); }}>Clear filters</button></div>}
            </div>
          </section>

          <aside className={`context-inspector ${inspectorOpen ? "" : "closed"}`} aria-label={lens === "missions" ? "Selected mission context" : "Selected action context"}>
            {lens === "missions" && selectedMission ? <MissionInspector mission={selectedMission} entries={initialSnapshot.journals[selectedMission.id] ?? []} onClose={() => setInspectorOpen(false)} onCommand={guardedCommand} /> : selected ? <>
              <div className="inspector-heading"><div><p className="eyebrow">ACTION CONTEXT</p><span className={`status-label ${selected.status}`}>{selected.status.replaceAll("_", " ")}</span></div><div className="inspector-heading-actions"><button className="inspector-close" type="button" aria-label="Close action inspector" onClick={() => setInspectorOpen(false)}>×</button><button type="button" aria-label="More action commands">•••</button></div></div>
              <h2>{selected.title}</h2><p className="required-outcome">{selected.requiredOutcome}</p>
              <div className="inspector-tabs" role="tablist" aria-label="Action context views"><button type="button" role="tab" aria-selected={inspectorTab === "overview"} onClick={() => setInspectorTab("overview")}>Overview</button><button type="button" role="tab" aria-selected={inspectorTab === "journal"} onClick={() => setInspectorTab("journal")}>Work Journal <span>{(initialSnapshot.journals[selected.id] ?? []).length}</span></button></div>
              {inspectorTab === "overview" ? <>
              <div className="consequence-card"><span>COMMERCIAL CONSEQUENCE</span><p>{selected.commercialConsequence}</p></div>
              <dl className="facts-grid"><div><dt>Owner</dt><dd><span className="avatar">{selected.owner?.initials ?? "?"}</span>{selected.owner?.name ?? "Unowned"}</dd></div><div><dt>Due</dt><dd>{shortDate(selected.dueAt)}</dd></div><div><dt>Priority</dt><dd>{selected.priority}</dd></div><div><dt>Kind</dt><dd>{selected.itemKind.replaceAll("_", " ")}</dd></div></dl>
              {(selected.blockedReason || selected.waitingReason) && <section className="condition-panel"><strong>{selected.blockedReason ? "Blocked" : "Waiting on"}</strong><p>{selected.blockedReason ?? selected.waitingReason}</p>{selected.expectedResumeAt && <small>Expected {shortDate(selected.expectedResumeAt)}</small>}</section>}
              <section className="inspector-section"><div className="section-title"><h3>Why this ranks here</h3><span>{selected.rankScore}/100</span></div><ul>{selected.rankFactors.map((factor) => <li key={factor}>{factor}</li>)}</ul></section>
              <section className="inspector-section"><div className="section-title"><h3>Linked records</h3><span>{selected.links.length}</span></div>{selected.links.map((link) => <Link className="record-link" href={link.href} key={link.id}><span>◇</span><span><strong>{link.label}</strong><small>{link.workspace}</small></span><b>↗</b></Link>)}</section>
              <section className="inspector-section evidence"><div className="section-title"><h3>Evidence</h3><span>{selected.evidenceRequired ? "Required" : "Optional"}</span></div><p>{selected.evidenceRequired ? "Completion remains unavailable until governed evidence is attached." : "A completion note is sufficient unless policy changes."}</p><button type="button" onClick={() => guardedCommand("Add evidence")}>＋ Link evidence</button></section>
              <div className="completion-policy"><strong>Completion contract</strong><span>{selected.completionOutcomeRequired ? "A published outcome Activity is required." : "Outcome Activity is optional."} {selected.evidenceRequired ? "Governed evidence is also required." : "No evidence gate applies."}</span></div>
              <div className="inspector-actions"><button type="button" className="secondary-button" onClick={() => guardedCommand("Mark waiting")}>Mark waiting</button><button type="button" className="primary-button" onClick={() => guardedCommand(selected.authorityRequired ? "Open Governance approval" : "Complete action")}>{selected.authorityRequired ? "Open approval" : "Complete"}</button></div>
              </> : <WorkJournal entries={initialSnapshot.journals[selected.id] ?? []} subjectLabel={selected.title} onCommand={guardedCommand} />}
            </> : <p>Select an action to inspect its authoritative context.</p>}
          </aside>
        </div>

        <footer className="workspace-footer"><span><kbd>/</kbd> search</span><span><kbd>J</kbd><kbd>K</kbd> navigate</span><span><kbd>N</kbd> new action</span><span><kbd>M</kbd> new mission</span><span className="freshness">Fixture snapshot · 07 Aug 2026 08:30 · backend adapter pending</span></footer>
      </section>

      {notice && <div className="toast" role="status"><span>i</span>{notice}<button type="button" aria-label="Dismiss notification" onClick={() => setNotice(null)}>×</button></div>}
      {dialog && <div className="dialog-backdrop" role="presentation" onMouseDown={() => setDialog(null)}><section className="dialog" role="dialog" aria-modal="true" aria-labelledby="dialog-title" onMouseDown={(event) => event.stopPropagation()}><div className="dialog-heading"><div><p className="eyebrow">STRUCTURED CREATION</p><h2 id="dialog-title">Create {dialog}</h2></div><button type="button" aria-label="Close dialog" onClick={() => setDialog(null)}>×</button></div><p>Review the accountable outcome, owner and context before an authoritative RPC commits work.</p><form onSubmit={(event) => { event.preventDefault(); setDialog(null); setNotice(`Create ${dialog} preview validated. Backend RPC connection is required before it becomes execution truth.`); }}><label>Required outcome<input autoFocus required name="title" placeholder={dialog === "action" ? "What must happen?" : "What commercial outcome must be achieved?"} /></label><div className="form-row"><label>Owner<select name="owner"><option>Reuss · Director</option><option>Maya Chen · Closer</option><option>Idris Cole · Research</option></select></label><label>Priority<select name="priority"><option>Normal</option><option>High</option><option>Critical</option><option>Low</option></select></label></div><label>Mission or governed context<select name="context"><option>Secure copper cathode mandate</option><option>Verify gold supplier network</option><option>Complete transaction banking readiness</option><option>Independent action</option></select></label><label>Success or completion evidence<textarea name="evidence" rows={3} placeholder="What will prove the outcome?" /></label><div className="dialog-actions"><button type="button" className="secondary-button" onClick={() => setDialog(null)}>Cancel</button><button type="submit" className="primary-button">Validate preview</button></div></form></section></div>}
    </main>
  );
}

function MissionInspector({ mission, entries, onClose, onCommand }: { mission: MissionSummary; entries: import("@sapphire/core-types").WorkJournalEntry[]; onClose: () => void; onCommand: (label: string) => void }) {
  const [tab, setTab] = useState<"overview" | "journal">("overview");
  const exposure = mission.valueExposure ? new Intl.NumberFormat("en-GB", { style: "currency", currency: mission.valueExposure.currency, maximumFractionDigits: 0 }).format(mission.valueExposure.amount) : "Not quantified";
  return <>
    <div className="inspector-heading"><div><p className="eyebrow">MISSION CONTEXT</p><span className={`status-label ${mission.status}`}>{mission.status.replaceAll("_", " ")}</span></div><div className="inspector-heading-actions"><button className="inspector-close" type="button" aria-label="Close mission inspector" onClick={onClose}>×</button><button type="button" aria-label="More mission commands">•••</button></div></div>
    <h2>{mission.title}</h2><p className="required-outcome">{mission.objective}</p>
    <div className="inspector-tabs" role="tablist" aria-label="Mission context views"><button type="button" role="tab" aria-selected={tab === "overview"} onClick={() => setTab("overview")}>Overview</button><button type="button" role="tab" aria-selected={tab === "journal"} onClick={() => setTab("journal")}>Work Journal <span>{entries.length}</span></button></div>
    {tab === "overview" ? <>
    <div className="consequence-card"><span>COMMERCIAL CONTEXT</span><p>{mission.commercialContext} · {exposure} exposure</p></div>
    <dl className="facts-grid"><div><dt>Owner</dt><dd><span className="avatar">{mission.owner.initials}</span>{mission.owner.name}</dd></div><div><dt>Target</dt><dd>{shortDate(mission.targetAt)}</dd></div><div><dt>Priority</dt><dd>{mission.priority}</dd></div><div><dt>Health</dt><dd>{mission.health.replaceAll("_", " ")}</dd></div></dl>
    <section className="mission-progress-card"><div><span>Mission progress</span><strong>{mission.progressPercent}%</strong></div><span><i style={{ width: `${mission.progressPercent}%` }} /></span></section>
    <section className="inspector-section"><div className="section-title"><h3>Next milestone</h3><span>{mission.openActionCount} open actions</span></div><p className="mission-milestone">{mission.nextMilestone}</p></section>
    <section className="inspector-section"><div className="section-title"><h3>Execution conditions</h3><span>{mission.blockerCount} blockers</span></div><ul><li>Progress is derived from authoritative action state.</li><li>Health remains a distinct Director-reviewed assessment.</li><li>Authority stays with Governance for protected decisions.</li></ul></section>
    <div className="inspector-actions"><button type="button" className="secondary-button" onClick={() => onCommand("Open mission plan")}>Open plan</button><button type="button" className="primary-button" onClick={() => onCommand("Create linked action")}>Create action</button></div>
    </> : <WorkJournal entries={entries} subjectLabel={mission.title} onCommand={onCommand} />}
  </>;
}
