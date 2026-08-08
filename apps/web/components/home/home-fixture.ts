export type DashboardState = "ready" | "loading" | "empty" | "stale" | "partial" | "offline" | "error" | "unauthorised";
export type SignalTone = "neutral" | "positive" | "warning" | "critical" | "info";

export interface DashboardContract {
  owner: string;
  source: string;
  freshness: string;
  evidence: string;
  permission: string;
  route: string;
}

export interface DashboardMetric {
  label: string;
  value: string;
  delta?: string;
  tone?: SignalTone;
}

export interface DashboardRow {
  label: string;
  value: string;
  detail?: string;
  tone?: SignalTone;
}

export interface HomeDashboardSnapshot {
  adapter: "typed fixture adapter";
  generatedAt: string;
  dataAsOf: string;
  timezone: string;
  actor: { name: string; role: string; initials: string };
  briefing: { greeting: string; framing: string; points: string[]; contract: DashboardContract };
  commercialPosition: { metrics: DashboardMetric[]; contract: DashboardContract };
  radar: { signals: Array<{ id: string; location: string; x: number; y: number; label: string; action: string; tone: SignalTone }>; hot: DashboardRow[]; contract: DashboardContract };
  movement: { rows: DashboardRow[]; contract: DashboardContract };
  attention: { rows: DashboardRow[]; contract: DashboardContract };
  actions: { rows: DashboardRow[]; contract: DashboardContract };
  inbox: { rows: DashboardRow[]; contract: DashboardContract };
  hotNow: { rows: DashboardRow[]; contract: DashboardContract };
  pulse: Array<{ id: string; label: string; route: string; tone: SignalTone }>;
}

const contract = (owner: string, source: string, route: string, evidence = "Verified governed records"): DashboardContract => ({ owner, source, route, evidence, freshness: "07 Aug 2026 · 08:30 BST", permission: "Director-authorised snapshot; record policies apply on drill-down" });

export const homeDashboardFixture: HomeDashboardSnapshot = {
  adapter: "typed fixture adapter",
  generatedAt: "2026-08-07T08:30:00+01:00",
  dataAsOf: "2026-08-07T08:28:00+01:00",
  timezone: "Europe/London",
  actor: { name: "Reuss", role: "Director", initials: "R" },
  briefing: {
    greeting: "Good afternoon, Reuss.",
    framing: "Here’s what matters right now.",
    points: [
      "Copper demand continues to strengthen across Europe and Asia.",
      "Three qualified buyers have no verified supplier.",
      "New Zambian supplier evidence passed full verification overnight.",
      "One SPA awaits your approval with £42.6k expected commission exposed.",
      "Gold momentum is cooling after yesterday’s rally; monitor re-entry evidence.",
    ],
    contract: contract("Intelligence", "dashboard_get_director_snapshot_v1 fixture · AI synthesis", "/intelligence", "Four verified records plus one labelled AI inference"),
  },
  commercialPosition: {
    metrics: [
      { label: "Pipeline value", value: "£24.3M", delta: "+8.6% · 7 days", tone: "positive" },
      { label: "Expected commission", value: "£486k", delta: "+12.4%", tone: "positive" },
      { label: "High confidence deals", value: "4", delta: "+1 new", tone: "positive" },
      { label: "Value at risk", value: "£1.2M", delta: "−4.3%", tone: "critical" },
      { label: "Settlement due · 30d", value: "£82k", tone: "neutral" },
      { label: "Cash position", value: "Healthy", tone: "positive" },
    ],
    contract: contract("Finance", "Performance projection fixture", "/finance"),
  },
  radar: {
    signals: [
      { id: "us", location: "North America", x: 22, y: 42, label: "Copper buyer cluster", action: "SOURCE", tone: "warning" },
      { id: "uk", location: "United Kingdom", x: 47, y: 30, label: "Gold cooling", action: "WATCH", tone: "warning" },
      { id: "zm", location: "Zambia", x: 54, y: 66, label: "Verified copper supply", action: "BUY", tone: "positive" },
      { id: "ae", location: "United Arab Emirates", x: 62, y: 47, label: "Qualified mandate", action: "MATCH", tone: "info" },
      { id: "sg", location: "Singapore", x: 82, y: 57, label: "Lithium tight supply", action: "INVESTIGATE", tone: "warning" },
    ],
    hot: [
      { label: "Gold", value: "WATCH", detail: "Cooling after +2.8% rally", tone: "warning" },
      { label: "Copper cathodes", value: "BUY", detail: "Demand +14% this week", tone: "positive" },
      { label: "Prime property · Manchester", value: "LIST", detail: "Projected prices +6.7%", tone: "info" },
      { label: "Lithium carbonate", value: "WATCH", detail: "Verified supply tightening", tone: "warning" },
    ],
    contract: contract("Market Radar", "Evidence-linked signal fixture", "/market-radar"),
  },
  movement: {
    rows: [
      { label: "Demand", value: "12", detail: "+20%", tone: "positive" },
      { label: "Supply", value: "5", detail: "+7%", tone: "positive" },
      { label: "Opportunities", value: "9", detail: "+16%", tone: "positive" },
      { label: "Matching", value: "7", detail: "+14%", tone: "positive" },
      { label: "Deals", value: "2", detail: "+100%", tone: "positive" },
      { label: "Finance", value: "£486k", detail: "+12.4%", tone: "positive" },
    ],
    contract: contract("Opportunities · Matching · Deals", "Material state transitions fixture", "/opportunities"),
  },
  attention: {
    rows: [
      { label: "SCO expires in 18h", value: "18h", detail: "Governance · mandate", tone: "critical" },
      { label: "Buyer awaiting pricing approval", value: "6h", detail: "Governance · £42.6k", tone: "critical" },
      { label: "Missing KYC from supplier", value: "1d", detail: "Supply · verification", tone: "warning" },
      { label: "Shipment milestone overdue", value: "1d", detail: "Deals · evidence", tone: "warning" },
    ],
    contract: contract("Governance and owning workspaces", "Ranked attention fixture", "/governance"),
  },
  actions: {
    rows: [
      { label: "Missions", value: "6", tone: "neutral" },
      { label: "Tasks", value: "8", tone: "warning" },
      { label: "Waiting on", value: "4", tone: "warning" },
      { label: "Follow ups", value: "5", tone: "neutral" },
      { label: "Approvals", value: "3", tone: "critical" },
    ],
    contract: contract("Actions", "Authoritative Actions snapshot fixture", "/actions"),
  },
  inbox: {
    rows: [
      { label: "Unread conversations", value: "5", tone: "neutral" },
      { label: "@ Mentions", value: "2", tone: "neutral" },
      { label: "Deal updates", value: "3", tone: "positive" },
      { label: "Supplier messages", value: "4", tone: "warning" },
      { label: "System notifications", value: "7", tone: "neutral" },
    ],
    contract: contract("Inbox", "Communication summary fixture", "/inbox"),
  },
  hotNow: {
    rows: [
      { label: "Gold", value: "SELL", detail: "Price +2.8% today", tone: "critical" },
      { label: "Copper cathodes", value: "BUY", detail: "Demand +14%", tone: "positive" },
      { label: "Manchester apartments", value: "LIST", detail: "+6.7% projected", tone: "info" },
      { label: "Lithium carbonate", value: "WATCH", detail: "Supply tightening", tone: "warning" },
    ],
    contract: contract("Market Radar", "Ranked evidence-backed signals fixture", "/market-radar"),
  },
  pulse: [
    { id: "demand", label: "Demand · High", route: "/demand", tone: "positive" },
    { id: "supply", label: "Supply · Medium", route: "/supply", tone: "warning" },
    { id: "opportunities", label: "Opportunities · High", route: "/opportunities", tone: "positive" },
    { id: "matching", label: "Matching · High", route: "/matching", tone: "positive" },
    { id: "deals", label: "Deals · High", route: "/deals", tone: "positive" },
    { id: "intelligence", label: "Intelligence · Medium", route: "/intelligence", tone: "warning" },
    { id: "finance", label: "Finance · High", route: "/finance", tone: "positive" },
  ],
};
