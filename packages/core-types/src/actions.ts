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
  rankScore: number;
  rankFactors: string[];
  commercialConsequence: string;
  updatedAt: string;
}

export interface ActionWorkspaceSnapshot {
  generatedAt: string;
  actor: ActorSummary;
  actions: ActionSummary[];
  missions: MissionSummary[];
}

export interface ActionsRepository {
  getQueue(lens: ActionLens, query?: string): Promise<ActionSummary[]>;
  getMissions(): Promise<MissionSummary[]>;
  transitionItem(id: string, nextStatus: ActionStatus, reason?: string): Promise<ActionSummary>;
  addEvidence(id: string, link: GovernedRecordLink, note?: string): Promise<ActionSummary>;
}
