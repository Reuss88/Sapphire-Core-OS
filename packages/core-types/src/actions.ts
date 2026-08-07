export type MissionStatus =
  | "planned"
  | "active"
  | "at_risk"
  | "blocked"
  | "completed"
  | "cancelled";

export type ActionStatus =
  | "draft"
  | "queued"
  | "ready"
  | "in_progress"
  | "waiting"
  | "blocked"
  | "completed"
  | "cancelled";

export type ActionKind =
  | "task"
  | "follow_up"
  | "review"
  | "approval_request"
  | "decision_request"
  | "reminder"
  | "coordination";

export type ActionPriority = "critical" | "high" | "normal" | "low";
export type ActivityType =
  | "note" | "comment" | "instruction" | "call_attempt" | "call_connected"
  | "meeting" | "research_update" | "outcome" | "status_update" | "handoff"
  | "coaching_note" | "evidence_added" | "message_summary" | "ai_summary"
  | "escalation_note" | "document_shared" | "system_observation";
export type ActivityVisibilityScope =
  | "private_actor" | "director_only" | "assigned_users" | "mission_team"
  | "workspace_team" | "organisation";
export type ActionLens =
  | "my_actions"
  | "missions"
  | "team"
  | "approvals_decisions"
  | "waiting_on"
  | "overdue"
  | "completed";

export interface ActorSummary {
  id: string;
  name: string;
  role: string;
  initials: string;
}

export interface GovernedRecordLink {
  id: string;
  type: "profile" | "company" | "demand" | "supply" | "opportunity" | "deal" | "document" | "inbox_thread" | "market_signal" | "finance_record" | "approval" | "decision" | "other";
  label: string;
  workspace: string;
  href: string;
}

export interface MissionSummary {
  id: string;
  title: string;
  objective: string;
  status: MissionStatus;
  priority: ActionPriority;
  health: "healthy" | "attention" | "at_risk" | "blocked";
  owner: ActorSummary;
  progressPercent: number;
  targetAt: string;
  nextMilestone: string;
  openActionCount: number;
  blockerCount: number;
  commercialContext: string;
  valueExposure?: { amount: number; currency: string; basis: string; asOf: string };
}

export interface ActionSummary {
  id: string;
  title: string;
  requiredOutcome: string;
  itemKind: ActionKind;
  status: ActionStatus;
  priority: ActionPriority;
  owner: ActorSummary | null;
  contributors: ActorSummary[];
  dueAt: string | null;
  dueState: "none" | "upcoming" | "due_today" | "overdue" | "completed";
  mission: Pick<MissionSummary, "id" | "title" | "health"> | null;
  sourceWorkspace: string;
  links: GovernedRecordLink[];
  blockedReason: string | null;
  waitingReason: string | null;
  expectedResumeAt: string | null;
  authorityRequired: boolean;
  evidenceRequired: boolean;
  completionOutcomeRequired: boolean;
  rankScore: number;
  rankFactors: string[];
  commercialConsequence: string;
  updatedAt: string;
}

export interface WorkJournalLink {
  linkedType: GovernedRecordLink["type"] | "action_item" | "mission" | "activity";
  linkedId: string;
  label: string;
  workspace: string;
}

export interface WorkJournalEntry {
  id: string;
  entryKind: "activity" | "execution_event" | "evidence";
  occurredAt: string;
  actor: ActorSummary;
  entryType: ActivityType | "state_transition" | "evidence_linked";
  visibilityScope: ActivityVisibilityScope | null;
  body: string;
  structuredContent: Record<string, string | number | boolean | null>;
  sourceWorkspace: string;
  provenanceKind: "human_entry" | "external_integration" | "dataset_import" | "document_extraction" | "system_calculation" | "ai_assisted_preparation" | "authorised_automation" | "migration" | "correction";
  provenanceLabel?: string;
  links: WorkJournalLink[];
  canCreateFollowUp: boolean;
}

export interface ActionWorkspaceSnapshot {
  generatedAt: string;
  actor: ActorSummary;
  actions: ActionSummary[];
  missions: MissionSummary[];
  journals: Record<string, WorkJournalEntry[]>;
}

export interface ActionsRepository {
  getQueue(lens: ActionLens, query?: string): Promise<ActionSummary[]>;
  getMissions(): Promise<MissionSummary[]>;
  transitionItem(id: string, nextStatus: ActionStatus, reason?: string): Promise<ActionSummary>;
  addEvidence(id: string, link: GovernedRecordLink, note?: string): Promise<ActionSummary>;
  getWorkJournal(subjectType: "mission" | "action_item", subjectId: string): Promise<WorkJournalEntry[]>;
}
