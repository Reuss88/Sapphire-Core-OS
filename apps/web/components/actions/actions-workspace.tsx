"use client";

import type { ActionLens, ActionSummary, ActionWorkspaceSnapshot, MissionSummary, WorkJournalEntry } from "@sapphire/core-types";
import Link from "next/link";
import { useEffect, useMemo, useRef, useState } from "react";
import { Avatar, Button, ButtonGroup, Card, Dialog, DirectorIdentity, Field, IconButton, Input, SapphireShell, Select, TabCollection, Textarea, Toast } from "../../design-system";
import { WorkJournal } from "./work-journal";

const BRIEF_ID = "actions-brief-2026-08-07-0830-v1";
const BRIEF_STORAGE_KEY = "sapphire.actions.dismissed-brief.v1";

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
  const [contextOpen, setContextOpen] = useState(false);
  const [journalOpen, setJournalOpen] = useState(false);
  const searchRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    const frame = window.requestAnimationFrame(() => {
      try {
        setBriefDismissed(window.localStorage.getItem(BRIEF_STORAGE_KEY) === BRIEF_ID);
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
        setDialog(null); setBriefOpen(false); setContextOpen(false); setJournalOpen(false);
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

  const shellCommands = <><Button variant="primary" size="compact" className="compact-command" onClick={() => setDialog("action")}>＋ Action</Button><Button variant="secondary" size="compact" className="compact-command" onClick={() => setDialog("mission")}>＋ Mission</Button></>;
  const shellFooter = <footer className="workspace-footer"><span><kbd>/</kbd> search</span><span><kbd>J</kbd><kbd>K</kbd> navigate</span><span><kbd>N</kbd> action</span><span><kbd>M</kbd> mission</span><span className="freshness">Fixture · 07 Aug 2026 08:30 · authoritative adapter pending</span></footer>;

  return <SapphireShell className="actions-app" activeWorkspace="Actions" eyebrow="EXECUTION WORKSPACE" title="Actions" commands={shellCommands} identity={<DirectorIdentity />} footer={shellFooter}>

      {!briefDismissed && <Card variant="intelligence" chrome="reverse" className="execution-brief" aria-labelledby="brief-title" data-brief-id={BRIEF_ID}><div className="brief-icon" aria-hidden="true">✦</div><div className="brief-copy"><p className="eyebrow">NEW EXECUTION BRIEF · 08:30</p><h2 id="brief-title">Two conditions need Director attention before midday.</h2><p>Pricing authority is holding the copper buyer offer. Supplier KYC is overdue. Three buyer follow-ups remain on course.</p></div><ButtonGroup className="brief-actions"><Button variant="quiet" size="compact" onClick={() => setBriefOpen(true)}>Open full brief</Button><Button variant="quiet" size="compact" aria-label="Dismiss execution brief" onClick={dismissBrief}>× Dismiss</Button></ButtonGroup></Card>}

      <section className="lens-strip" aria-label="Actions lenses"><TabCollection compact className="lens-buttons" label="Actions lenses" activeId={lens} items={lenses.map((item) => ({ ...item, count: countFor(item.id, initialSnapshot) }))} onChange={(id) => { setLens(id as ActionLens); setContextOpen(false); setJournalOpen(false); }} /><div className="mission-chips" aria-label="Active missions">{initialSnapshot.missions.map((mission) => <Button variant="quiet" size="compact" key={mission.id} onClick={() => { setLens("missions"); selectMission(mission.id); setQuery(""); }}><span className={`health-dot ${mission.health}`} />{mission.title}<b>{mission.progressPercent}%</b></Button>)}</div></section>

      <Card as="div" variant="queue" chrome="forward" className="actions-grid">
        <section className="queue-pane" aria-labelledby="queue-title">
          <div className="queue-toolbar"><div><p className="eyebrow">RANKED QUEUE</p><h2 id="queue-title">{lenses.find((item) => item.id === lens)?.label}</h2></div><div className="queue-controls"><label className="search-control"><span aria-hidden="true">⌕</span><span className="sr-only">Search current view</span><Input ref={searchRef} value={query} onChange={(event) => setQuery(event.target.value)} placeholder={lens === "missions" ? "Search missions…" : "Search actions…"} /></label><label><span className="sr-only">Priority filter</span><Select value={priority} onChange={(event) => setPriority(event.target.value)}><option value="all">All priority</option><option value="critical">Critical</option><option value="high">High</option><option value="normal">Normal</option><option value="low">Low</option></Select></label><label><span className="sr-only">Sort actions</span><Select value={sort} onChange={(event) => setSort(event.target.value)}><option value="rank">Ranked</option><option value="due">Due date</option></Select></label>{lens !== "missions" && <label><span className="sr-only">Group actions</span><Select value={group} onChange={(event) => setGroup(event.target.value)}><option value="none">No grouping</option><option value="mission">By mission</option><option value="priority">By priority</option><option value="owner">By owner</option></Select></label>}</div></div>
          <div className="queue-summary" aria-live="polite"><span>{lens === "missions" ? `${visibleMissions.length} missions` : `${visibleActions.length} actions`}</span><span>Commercial consequence · due state · authority</span></div>
          <div className="queue-list" role="listbox" aria-label={lens === "missions" ? "Missions" : "Ranked actions"}>{lens === "missions" ? visibleMissions.map((mission) => <MissionRow key={mission.id} mission={mission} selected={selectedMission?.id === mission.id} onSelect={() => selectMission(mission.id)} />) : groupedActions.map(([groupLabel, actions]) => <div className="action-group" role="group" aria-label={groupLabel} key={groupLabel}>{group !== "none" && <h3 className="group-heading">{groupLabel}<span>{actions.length}</span></h3>}{actions.map((action) => <ActionRow key={action.id} action={action} selected={selected?.id === action.id} onSelect={() => selectAction(action.id)} />)}</div>)}{(lens === "missions" ? visibleMissions.length : visibleActions.length) === 0 && <div className="empty-state"><strong>No matching {lens === "missions" ? "missions" : "actions"}.</strong><span>Clear search or filters; this does not imply system-wide absence.</span><Button size="compact" onClick={() => { setQuery(""); setPriority("all"); }}>Clear filters</Button></div>}</div>
        </section>

        <Card variant="focus" chrome="reverse" className={`context-canvas ${contextOpen ? "open" : ""}`} aria-label={lens === "missions" ? "Selected mission context" : "Selected action context"}>{lens === "missions" && selectedMission ? <MissionContext mission={selectedMission} entries={journalEntries} onClose={() => setContextOpen(false)} onOpenJournal={() => { setContextOpen(false); setJournalOpen(true); }} onCommand={guardedCommand} /> : selected ? <ActionContext action={selected} entries={journalEntries} onClose={() => setContextOpen(false)} onOpenJournal={() => { setContextOpen(false); setJournalOpen(true); }} onCommand={guardedCommand} /> : <div className="context-empty">Select an item to open its execution context.</div>}</Card>

        <Card as="aside" variant="timeline" chrome="forward" className={`journal-pane ${journalOpen ? "open" : ""}`} aria-label="Work Journal context"><div className="journal-pane-heading"><div><p className="eyebrow">COLLABORATION & EVIDENCE</p><strong>{journalLabel}</strong></div><IconButton label="Close Work Journal" onClick={() => setJournalOpen(false)}>×</IconButton></div><WorkJournal entries={journalEntries} subjectLabel={journalLabel} onCommand={guardedCommand} /></Card>
      </Card>

    {notice && <div className="actions-toast"><Toast title="Fixture boundary" detail={notice} onDismiss={() => setNotice(null)} /></div>}
    {briefOpen && <BriefDialog onClose={() => setBriefOpen(false)} />}
    {dialog && <CreationDialog kind={dialog} onClose={() => setDialog(null)} onValidated={() => { setDialog(null); setNotice(`Create ${dialog} preview validated. Backend RPC connection is required before it becomes execution truth.`); }} />}
  </SapphireShell>;
}

function ActionRow({ action, selected, onSelect }: { action: ActionSummary; selected: boolean; onSelect: () => void }) {
  return <button type="button" role="option" aria-selected={selected} className={`action-row ${selected ? "selected" : ""}`} onClick={onSelect}><span className={`priority-bar ${action.priority}`} /><span className="row-rank"><strong>{action.rankScore}</strong><small>rank</small></span><span className="row-content"><span className="row-title"><strong>{action.title}</strong>{action.authorityRequired && <em className="authority-badge">Director</em>}</span><span className="row-meta">{action.mission?.title ?? "Independent"} · {action.owner?.name ?? "Unowned"}</span><span className="row-consequence">{action.commercialConsequence}</span></span><span className={`due-state ${action.dueState}`}><strong>{action.dueState.replaceAll("_", " ")}</strong><small>{shortDate(action.dueAt)}</small></span></button>;
}

function MissionRow({ mission, selected, onSelect }: { mission: MissionSummary; selected: boolean; onSelect: () => void }) {
  return <button type="button" role="option" aria-selected={selected} className={`mission-row ${selected ? "selected" : ""}`} onClick={onSelect}><span className={`priority-bar ${mission.priority}`} /><span className="mission-row-content"><span className="row-title"><strong>{mission.title}</strong><em className={`mission-health ${mission.health}`}>{mission.health.replaceAll("_", " ")}</em></span><span className="row-consequence">{mission.objective}</span><span className="row-meta">{mission.owner.name} · {mission.openActionCount} open</span><span className="mission-progress"><i style={{ width: `${mission.progressPercent}%` }} /><span>{mission.progressPercent}%</span></span></span><span className="mission-target"><strong>{mission.blockerCount ? `${mission.blockerCount} blockers` : "On course"}</strong><small>{shortDate(mission.targetAt)}</small></span></button>;
}

function ContextHeading({ label, status, onClose }: { label: string; status: string; onClose: () => void }) {
  return <div className="inspector-heading"><div><p className="eyebrow">{label}</p><span className={`status-label ${status}`}>{status.replaceAll("_", " ")}</span></div><div className="inspector-heading-actions"><IconButton className="inspector-close" label={`Close ${label.toLowerCase()}`} onClick={onClose}>×</IconButton><IconButton label="More context commands">•••</IconButton></div></div>;
}

function ActionContext({ action, entries, onClose, onOpenJournal, onCommand }: { action: ActionSummary; entries: WorkJournalEntry[]; onClose: () => void; onOpenJournal: () => void; onCommand: (label: string) => void }) {
  return <><ContextHeading label="ACTION CONTEXT" status={action.status} onClose={onClose} /><h2>{action.title}</h2><p className="required-outcome">{action.requiredOutcome}</p><ButtonGroup className="context-primary-actions"><Button variant="secondary" size="compact" className="journal-open-command" onClick={onOpenJournal}>Work Journal <span>{entries.length}</span></Button><Button variant="quiet" size="compact" aria-label="Open next action command" onClick={() => onCommand("Open next action")}>Next action →</Button></ButtonGroup><div className="consequence-card"><span>COMMERCIAL CONSEQUENCE</span><p>{action.commercialConsequence}</p></div><dl className="facts-grid"><div><dt>Owner</dt><dd><Avatar initials={action.owner?.initials ?? "?"} label={action.owner?.name ?? "Unowned"} />{action.owner?.name ?? "Unowned"}</dd></div><div><dt>Due</dt><dd>{shortDate(action.dueAt)}</dd></div><div><dt>Priority</dt><dd>{action.priority}</dd></div><div><dt>Kind</dt><dd>{action.itemKind.replaceAll("_", " ")}</dd></div></dl>{(action.blockedReason || action.waitingReason) && <section className="condition-panel"><strong>{action.blockedReason ? "Blocked" : "Waiting on"}</strong><p>{action.blockedReason ?? action.waitingReason}</p>{action.expectedResumeAt && <small>Expected {shortDate(action.expectedResumeAt)}</small>}</section>}<div className="context-detail-grid"><section className="inspector-section"><div className="section-title"><h3>Why this ranks here</h3><span>{action.rankScore}/100</span></div><ul>{action.rankFactors.map((factor) => <li key={factor}>{factor}</li>)}</ul></section><section className="inspector-section"><div className="section-title"><h3>Linked records</h3><span>{action.links.length}</span></div>{action.links.map((link) => <Link className="record-link" href={link.href} key={link.id}><span>◇</span><span><strong>{link.label}</strong><small>{link.workspace}</small></span><b>↗</b></Link>)}</section></div><section className="inspector-section evidence"><div className="section-title"><h3>Completion evidence</h3><span>{action.evidenceRequired ? "Required" : "Optional"}</span></div><p>{action.evidenceRequired ? "Completion remains unavailable until governed evidence is attached." : "Evidence is optional unless policy changes."}</p><Button variant="quiet" size="compact" onClick={() => onCommand("Add evidence")}>＋ Link evidence</Button></section><div className="completion-policy"><strong>Completion contract</strong><span>{action.completionOutcomeRequired ? "Published outcome Activity required." : "Outcome Activity optional."} {action.evidenceRequired ? "Governed evidence also required." : "No evidence gate."}</span></div><ButtonGroup className="inspector-actions"><Button variant="secondary" onClick={() => onCommand("Mark waiting")}>Mark waiting</Button><Button variant="primary" onClick={() => onCommand(action.authorityRequired ? "Open Governance approval" : "Complete action")}>{action.authorityRequired ? "Open approval" : "Complete"}</Button></ButtonGroup></>;
}

function MissionContext({ mission, entries, onClose, onOpenJournal, onCommand }: { mission: MissionSummary; entries: WorkJournalEntry[]; onClose: () => void; onOpenJournal: () => void; onCommand: (label: string) => void }) {
  const exposure = mission.valueExposure ? new Intl.NumberFormat("en-GB", { style: "currency", currency: mission.valueExposure.currency, maximumFractionDigits: 0 }).format(mission.valueExposure.amount) : "Not quantified";
  return <><ContextHeading label="MISSION CONTEXT" status={mission.status} onClose={onClose} /><h2>{mission.title}</h2><p className="required-outcome">{mission.objective}</p><ButtonGroup className="context-primary-actions"><Button variant="secondary" size="compact" className="journal-open-command" onClick={onOpenJournal}>Work Journal <span>{entries.length}</span></Button><Button variant="quiet" size="compact" onClick={() => onCommand("Create linked action")}>＋ Linked action</Button></ButtonGroup><div className="consequence-card"><span>COMMERCIAL CONTEXT</span><p>{mission.commercialContext} · {exposure} exposure</p></div><dl className="facts-grid"><div><dt>Owner</dt><dd><Avatar initials={mission.owner.initials} label={mission.owner.name} />{mission.owner.name}</dd></div><div><dt>Target</dt><dd>{shortDate(mission.targetAt)}</dd></div><div><dt>Priority</dt><dd>{mission.priority}</dd></div><div><dt>Health</dt><dd>{mission.health.replaceAll("_", " ")}</dd></div></dl><section className="mission-progress-card"><div><span>Mission progress</span><strong>{mission.progressPercent}%</strong></div><span><i style={{ width: `${mission.progressPercent}%` }} /></span></section><div className="context-detail-grid"><section className="inspector-section"><div className="section-title"><h3>Next milestone</h3><span>{mission.openActionCount} open</span></div><p className="mission-milestone">{mission.nextMilestone}</p></section><section className="inspector-section"><div className="section-title"><h3>Execution conditions</h3><span>{mission.blockerCount} blockers</span></div><ul><li>Progress derives from authoritative Action state.</li><li>Health remains Director-reviewed.</li><li>Governance owns protected authority.</li></ul></section></div><ButtonGroup className="inspector-actions"><Button variant="secondary" onClick={() => onCommand("Open mission plan")}>Open plan</Button><Button variant="primary" onClick={() => onCommand("Create linked action")}>Create action</Button></ButtonGroup></>;
}

function BriefDialog({ onClose }: { onClose: () => void }) {
  return <Dialog open title="Director briefing" eyebrow="SAPPHIRE EXECUTION BRIEF · 08:30" onClose={onClose} className="brief-dialog" footer={<Button variant="secondary" onClick={onClose}>Return to Actions</Button>}><div className="full-brief-content"><article><strong>Pricing authority</strong><p>The copper buyer offer remains held until the protected pricing range is approved in Governance.</p></article><article><strong>Supplier verification</strong><p>Beneficial-owner evidence is overdue and prevents the Zambian supplier entering verified matching.</p></article><article><strong>Buyer movement</strong><p>Three qualified buyer follow-ups remain due today. Sofia Marin requires assay evidence and an indicative range.</p></article></div></Dialog>;
}

function CreationDialog({ kind, onClose, onValidated }: { kind: "action" | "mission"; onClose: () => void; onValidated: () => void }) {
  return <Dialog open title={`Create ${kind}`} eyebrow="STRUCTURED CREATION" description="Review the accountable outcome, owner and context before an authoritative RPC commits work." onClose={onClose}><form className="s-form-stack" onSubmit={(event) => { event.preventDefault(); onValidated(); }}><Field label="Required outcome" required><Input autoFocus required name="title" placeholder={kind === "action" ? "What must happen?" : "What commercial outcome must be achieved?"} /></Field><div className="form-row"><Field label="Owner"><Select name="owner"><option>Reuss · Director</option><option>Maya Chen · Closer</option><option>Idris Cole · Research</option></Select></Field><Field label="Priority"><Select name="priority"><option>Normal</option><option>High</option><option>Critical</option><option>Low</option></Select></Field></div><Field label="Mission or governed context"><Select name="context"><option>Secure copper cathode mandate</option><option>Verify gold supplier network</option><option>Complete transaction banking readiness</option><option>Independent action</option></Select></Field><Field label="Success or completion evidence" authorityNote="Validation does not commit fixture data."><Textarea name="evidence" rows={3} placeholder="What will prove the outcome?" /></Field><ButtonGroup className="dialog-actions"><Button variant="secondary" onClick={onClose}>Cancel</Button><Button type="submit" variant="primary">Validate preview</Button></ButtonGroup></form></Dialog>;
}
