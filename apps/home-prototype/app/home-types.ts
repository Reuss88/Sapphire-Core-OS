export type SemanticState = "positive" | "warning" | "critical" | "neutral" | "info";

export interface NavItem {
  label: string;
  route: string;
  icon: string;
  count?: number;
}

export interface BriefingPoint {
  text: string;
  evidence: "Verified" | "Calculated" | "AI inference";
}

export interface MovementRow {
  label: string;
  icon: string;
  value: string;
  change: string;
  points: number[];
}

export interface SummaryRow {
  label: string;
  value: string;
  state?: SemanticState;
  detail?: string;
}

export interface MarketSignal {
  name: string;
  detail: string;
  action: "BUY" | "SELL" | "LIST" | "WATCH";
  state: SemanticState;
  glyph: string;
}

export interface WorkspaceHealth {
  label: string;
  state: "High" | "Medium";
}

export interface DirectorSnapshot {
  generatedAt: string;
  briefing: BriefingPoint[];
  movement: MovementRow[];
  attention: SummaryRow[];
  actions: SummaryRow[];
  inbox: SummaryRow[];
  signals: MarketSignal[];
  workspaces: WorkspaceHealth[];
}
