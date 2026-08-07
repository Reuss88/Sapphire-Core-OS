"use client";

import type { ActivityType, ActivityVisibilityScope, WorkJournalEntry } from "@sapphire/core-types";
import { useMemo, useState } from "react";

const activityLabels: Record<string, string> = {
  instruction: "Director instruction", call_attempt: "Call attempt", call_connected: "Call connected",
  research_update: "Research update", outcome: "Outcome", status_update: "Progress update",
  handoff: "Handoff", evidence_added: "Evidence added", ai_summary: "AI summary",
  state_transition: "Execution state", evidence_linked: "Governed evidence",
};

const visibilityLabels: Record<ActivityVisibilityScope, string> = {
  private_actor: "Only me", director_only: "Directors", assigned_users: "Assigned people",
  mission_team: "Mission team", workspace_team: "Actions team", organisation: "Organisation",
};

const composerTypes: Array<{ value: ActivityType; label: string }> = [
  { value: "instruction", label: "Director instruction" }, { value: "status_update", label: "Progress update" },
  { value: "comment", label: "Question or blocker" }, { value: "call_attempt", label: "Call attempt" },
  { value: "call_connected", label: "Connected call" }, { value: "research_update", label: "Research update" },
  { value: "outcome", label: "Final outcome" }, { value: "handoff", label: "Handoff" },
  { value: "evidence_added", label: "Evidence reference" },
];

function journalTime(value: string) {
  return new Intl.DateTimeFormat("en-GB", { day: "numeric", month: "short", hour: "2-digit", minute: "2-digit", hour12: false }).format(new Date(value));
}

export function WorkJournal({ entries, subjectLabel, onCommand }: { entries: WorkJournalEntry[]; subjectLabel: string; onCommand: (label: string) => void }) {
  const [filter, setFilter] = useState<"all" | WorkJournalEntry["entryKind"]>("all");
  const [composerOpen, setComposerOpen] = useState(false);
  const [entryType, setEntryType] = useState<ActivityType>("status_update");
  const [visibility, setVisibility] = useState<ActivityVisibilityScope>("mission_team");
  const visible = useMemo(() => entries.filter((entry) => filter === "all" || entry.entryKind === filter), [entries, filter]);
  const activityCount = entries.filter((entry) => entry.entryKind === "activity").length;

  return <section className="work-journal" aria-labelledby="work-journal-title">
    <div className="journal-intro">
      <div><p className="eyebrow">SHARED ACTIVITY</p><h3 id="work-journal-title">Work Journal</h3><p>Collaborative context, execution state and evidence remain visibly distinct.</p></div>
      <button type="button" className="primary-button journal-add" onClick={() => setComposerOpen(true)}>＋ Add activity</button>
    </div>
    <div className="journal-filters" aria-label="Filter Work Journal">
      {(["all", "activity", "execution_event", "evidence"] as const).map((value) => <button key={value} type="button" className={filter === value ? "selected" : ""} onClick={() => setFilter(value)}>{value === "all" ? `All ${entries.length}` : value === "activity" ? `Activity ${activityCount}` : value === "execution_event" ? "Execution" : "Evidence"}</button>)}
    </div>
    <div className="journal-stream" aria-live="polite">
      {visible.map((entry) => <article className={`journal-entry ${entry.entryKind}`} key={entry.id}>
        <div className="journal-marker" aria-hidden="true">{entry.entryKind === "activity" ? "✦" : entry.entryKind === "evidence" ? "◇" : "↻"}</div>
        <div className="journal-entry-main">
          <div className="journal-entry-heading"><div><strong>{activityLabels[entry.entryType] ?? entry.entryType.replaceAll("_", " ")}</strong><span className={`entry-kind ${entry.entryKind}`}>{entry.entryKind === "execution_event" ? "execution" : entry.entryKind}</span></div><time dateTime={entry.occurredAt}>{journalTime(entry.occurredAt)}</time></div>
          <p>{entry.body}</p>
          {Object.keys(entry.structuredContent).length > 0 && <dl className="structured-outcome">{Object.entries(entry.structuredContent).map(([key, value]) => <div key={key}><dt>{key.replaceAll("_", " ")}</dt><dd>{String(value)}</dd></div>)}</dl>}
          <div className="journal-meta"><span className="avatar">{entry.actor.initials}</span><span>{entry.actor.name}</span><span>· {entry.sourceWorkspace}</span>{entry.visibilityScope && <span className="visibility-chip">◉ {visibilityLabels[entry.visibilityScope]}</span>}{entry.provenanceLabel && <span className="ai-provenance">✦ {entry.provenanceLabel}</span>}</div>
          {entry.links.map((link) => <span className="journal-link" key={`${entry.id}-${link.linkedId}`}>◇ {link.label}<small>{link.workspace}</small></span>)}
          {entry.canCreateFollowUp && <button type="button" className="follow-up-command" onClick={() => onCommand(`Create follow-up from ${activityLabels[entry.entryType] ?? entry.entryType}`)}>＋ Create follow-up action</button>}
        </div>
      </article>)}
      {visible.length === 0 && <div className="journal-empty"><strong>No visible entries in this category.</strong><span>Visibility and authority filters are enforced by the Activity service.</span></div>}
    </div>
    <p className="journal-boundary">Activity supplies collaboration context. Actions remains the source of accountable state; Inbox, Governance and Documents remain the source of their own records.</p>

    {composerOpen && <div className="dialog-backdrop activity-backdrop" role="presentation" onMouseDown={() => setComposerOpen(false)}><section className="dialog activity-composer" role="dialog" aria-modal="true" aria-labelledby="activity-composer-title" onMouseDown={(event) => event.stopPropagation()}>
      <div className="dialog-heading"><div><p className="eyebrow">WORK JOURNAL · {subjectLabel}</p><h2 id="activity-composer-title">Add shared Activity</h2></div><button type="button" aria-label="Close activity composer" onClick={() => setComposerOpen(false)}>×</button></div>
      <form onSubmit={(event) => { event.preventDefault(); setComposerOpen(false); onCommand(`Publish ${activityLabels[entryType] ?? entryType} with ${visibilityLabels[visibility]} visibility`); }}>
        <div className="form-row"><label>Activity type<select value={entryType} onChange={(event) => setEntryType(event.target.value as ActivityType)}>{composerTypes.map((type) => <option value={type.value} key={type.value}>{type.label}</option>)}</select></label><label>Visible to<select value={visibility} onChange={(event) => setVisibility(event.target.value as ActivityVisibilityScope)}>{Object.entries(visibilityLabels).map(([value, label]) => <option value={value} key={value}>{label}</option>)}</select></label></div>
        <div className="visibility-explainer"><strong>{visibilityLabels[visibility]}</strong><span>{visibility === "private_actor" ? "Visible only to you; Director role does not override this boundary." : "Applied by server-side Activity visibility policy."}</span></div>
        <label>Update<textarea autoFocus required rows={4} placeholder="Record concise, factual collaboration context…" /></label>
        {(entryType === "call_attempt" || entryType === "call_connected") && <fieldset className="call-fields"><legend>Structured call outcome</legend><div className="form-row"><label>Channel<select><option>Phone</option><option>Video</option><option>Voice message</option></select></label><label>Contact reached<select><option>{entryType === "call_connected" ? "Yes" : "No"}</option><option>{entryType === "call_connected" ? "No" : "Yes"}</option></select></label></div><label>Agreed next step<input required={entryType === "call_connected"} placeholder="What happens next, and by when?" /></label></fieldset>}
        <label>Governed record reference<select><option>No additional reference</option><option>Sofia Marin · Profiles</option><option>EU Copper Cathode Mandate · Opportunities</option><option>Buyer qualification thread · Inbox</option><option>Supplier export dossier · Documents</option></select></label>
        <div className="dialog-actions"><button type="button" className="secondary-button" onClick={() => setComposerOpen(false)}>Cancel</button><button type="submit" className="primary-button">Publish activity</button></div>
      </form>
    </section></div>}
  </section>;
}
