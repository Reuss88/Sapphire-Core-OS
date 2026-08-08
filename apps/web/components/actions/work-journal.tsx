"use client";

import type { ActivityType, ActivityVisibilityScope, WorkJournalEntry } from "@sapphire/core-types";
import { useMemo, useState } from "react";
import { Avatar, Button, ButtonGroup, Dialog, Field, Input, ProvenanceMarker, Select, TabCollection, Textarea } from "../../design-system";

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
      <Button variant="primary" size="compact" className="journal-add" onClick={() => setComposerOpen(true)}>＋ Add activity</Button>
    </div>
    <TabCollection compact label="Filter Work Journal" activeId={filter} onChange={(value) => setFilter(value as typeof filter)} items={[{ id: "all", label: "All", count: entries.length }, { id: "activity", label: "Activity", count: activityCount }, { id: "execution_event", label: "Execution" }, { id: "evidence", label: "Evidence" }]} />
    <div className="journal-stream" aria-live="polite">
      {visible.map((entry) => <article className={`journal-entry ${entry.entryKind}`} key={entry.id}>
        <div className="journal-marker" aria-hidden="true">{entry.entryKind === "activity" ? "✦" : entry.entryKind === "evidence" ? "◇" : "↻"}</div>
        <div className="journal-entry-main">
          <div className="journal-entry-heading"><div><strong>{activityLabels[entry.entryType] ?? entry.entryType.replaceAll("_", " ")}</strong><span className={`entry-kind ${entry.entryKind}`}>{entry.entryKind === "execution_event" ? "execution" : entry.entryKind}</span></div><time dateTime={entry.occurredAt}>{journalTime(entry.occurredAt)}</time></div>
          <p>{entry.body}</p>
          {Object.keys(entry.structuredContent).length > 0 && <dl className="structured-outcome">{Object.entries(entry.structuredContent).map(([key, value]) => <div key={key}><dt>{key.replaceAll("_", " ")}</dt><dd>{String(value)}</dd></div>)}</dl>}
          <div className="journal-meta"><Avatar initials={entry.actor.initials} label={entry.actor.name} /><span>{entry.actor.name}</span><span>· {entry.sourceWorkspace}</span>{entry.visibilityScope && <span className="visibility-chip">◉ {visibilityLabels[entry.visibilityScope]}</span>}{entry.provenanceLabel && <ProvenanceMarker>{entry.provenanceLabel}</ProvenanceMarker>}</div>
          {entry.links.map((link) => <span className="journal-link" key={`${entry.id}-${link.linkedId}`}>◇ {link.label}<small>{link.workspace}</small></span>)}
          {entry.canCreateFollowUp && <Button variant="quiet" size="compact" className="follow-up-command" onClick={() => onCommand(`Create follow-up from ${activityLabels[entry.entryType] ?? entry.entryType}`)}>＋ Create follow-up action</Button>}
        </div>
      </article>)}
      {visible.length === 0 && <div className="journal-empty"><strong>No visible entries in this category.</strong><span>Visibility and authority filters are enforced by the Activity service.</span></div>}
    </div>
    <p className="journal-boundary">Activity supplies collaboration context. Actions remains the source of accountable state; Inbox, Governance and Documents remain the source of their own records.</p>

    <Dialog open={composerOpen} onClose={() => setComposerOpen(false)} eyebrow={`WORK JOURNAL · ${subjectLabel}`} title="Add shared Activity" description="Record collaboration context without changing the governed Action state." className="activity-composer">
      <form className="s-form-stack" onSubmit={(event) => { event.preventDefault(); setComposerOpen(false); onCommand(`Publish ${activityLabels[entryType] ?? entryType} with ${visibilityLabels[visibility]} visibility`); }}>
        <div className="form-row"><Field label="Activity type"><Select value={entryType} onChange={(event) => setEntryType(event.target.value as ActivityType)}>{composerTypes.map((type) => <option value={type.value} key={type.value}>{type.label}</option>)}</Select></Field><Field label="Visible to"><Select value={visibility} onChange={(event) => setVisibility(event.target.value as ActivityVisibilityScope)}>{Object.entries(visibilityLabels).map(([value, label]) => <option value={value} key={value}>{label}</option>)}</Select></Field></div>
        <div className="visibility-explainer"><strong>{visibilityLabels[visibility]}</strong><span>{visibility === "private_actor" ? "Visible only to you; Director role does not override this boundary." : "Applied by server-side Activity visibility policy."}</span></div>
        <Field label="Update" required><Textarea autoFocus required rows={4} placeholder="Record concise, factual collaboration context…" /></Field>
        {(entryType === "call_attempt" || entryType === "call_connected") && <fieldset className="call-fields"><legend>Structured call outcome</legend><div className="form-row"><Field label="Channel"><Select><option>Phone</option><option>Video</option><option>Voice message</option></Select></Field><Field label="Contact reached"><Select><option>{entryType === "call_connected" ? "Yes" : "No"}</option><option>{entryType === "call_connected" ? "No" : "Yes"}</option></Select></Field></div><Field label="Agreed next step" required={entryType === "call_connected"}><Input required={entryType === "call_connected"} placeholder="What happens next, and by when?" /></Field></fieldset>}
        <Field label="Governed record reference" authorityNote="References do not transfer ownership or authority."><Select><option>No additional reference</option><option>Sofia Marin · Profiles</option><option>EU Copper Cathode Mandate · Opportunities</option><option>Buyer qualification thread · Inbox</option><option>Supplier export dossier · Documents</option></Select></Field>
        <ButtonGroup className="dialog-actions"><Button variant="secondary" onClick={() => setComposerOpen(false)}>Cancel</Button><Button type="submit" variant="primary">Publish activity</Button></ButtonGroup>
      </form>
    </Dialog>
  </section>;
}
