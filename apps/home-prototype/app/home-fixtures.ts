import type { DirectorSnapshot, NavItem } from "./home-types";

export const navigation: NavItem[] = [
  { label: "Home", route: "/dashboard", icon: "⌂" },
  { label: "Actions", route: "/actions", icon: "◇", count: 18 },
  { label: "Inbox", route: "/inbox", icon: "□", count: 7 },
  { label: "Market Radar", route: "/market-radar", icon: "◎" },
  { label: "Demand", route: "/demand", icon: "♙" },
  { label: "Supply", route: "/supply", icon: "◈" },
  { label: "Opportunities", route: "/opportunities", icon: "⬡" },
  { label: "Matching", route: "/matching", icon: "⌘" },
  { label: "Deals", route: "/deals", icon: "♧" },
  { label: "Network", route: "/network", icon: "⌬" },
  { label: "Profiles", route: "/profiles", icon: "♙" },
  { label: "Intelligence", route: "/intelligence", icon: "⌁" },
  { label: "Performance", route: "/performance", icon: "▣" },
  { label: "Documents", route: "/documents", icon: "▤" },
  { label: "Finance", route: "/finance", icon: "⬢" },
  { label: "Governance", route: "/governance", icon: "⬡" },
];

export const snapshot: DirectorSnapshot = {
  generatedAt: "14:34 SGT · verified 2 min ago",
  briefing: [
    { text: "Copper demand continues to strengthen across Europe and Asia.", evidence: "Verified" },
    { text: "3 qualified buyers have no verified supplier.", evidence: "Calculated" },
    { text: "New supplier from Zambia passed full verification overnight.", evidence: "Verified" },
    { text: "One SPA awaiting your approval (£42.6k commission opportunity).", evidence: "Calculated" },
    { text: "Gold momentum is cooling after yesterday’s rally — watch for re-entry.", evidence: "AI inference" },
  ],
  movement: [
    { label: "Demand", icon: "♙", value: "12", change: "↑ 20%", points: [3,5,4,7,5,9,6,8,5,7,6,10] },
    { label: "Supply", icon: "◈", value: "5", change: "↑ 7%", points: [2,4,3,5,4,7,4,5,3,6,4,8] },
    { label: "Opportunities", icon: "⬡", value: "9", change: "↑ 16%", points: [3,4,6,5,8,4,7,5,6,4,7,9] },
    { label: "Matching", icon: "⌘", value: "7", change: "↑ 14%", points: [2,5,3,7,4,6,3,5,4,3,6,8] },
    { label: "Deals", icon: "▤", value: "2", change: "↑ 100%", points: [2,3,2,6,3,5,4,3,2,4,3,7] },
    { label: "Finance", icon: "▣", value: "£486k", change: "↑ 12.4%", points: [2,4,3,5,4,7,5,4,3,6,5,8] },
  ],
  attention: [
    { label: "SCO expires in 18h", value: "18h", state: "critical" },
    { label: "Buyer awaiting pricing approval", value: "6h", state: "warning" },
    { label: "Missing KYC from supplier", value: "1d", state: "critical" },
    { label: "Shipment milestone overdue", value: "1d", state: "critical" },
    { label: "SPA awaiting approval", value: "2d", state: "critical" },
  ],
  actions: [
    { label: "Missions", value: "6" }, { label: "Tasks", value: "8" },
    { label: "Waiting On", value: "4" }, { label: "Follow Ups", value: "5" },
    { label: "Approvals", value: "3" },
  ],
  inbox: [
    { label: "Unread Conversations", value: "5" }, { label: "@ Mentions", value: "2" },
    { label: "Deal Updates", value: "3" }, { label: "Supplier Messages", value: "4" },
    { label: "System Notifications", value: "7" },
  ],
  signals: [
    { name: "Gold", detail: "Price ↓ 2.8% today", action: "SELL", state: "critical", glyph: "▰" },
    { name: "Copper Cathodes", detail: "Demand ↑ 14% this week", action: "BUY", state: "positive", glyph: "◉" },
    { name: "Apartments – Manchester", detail: "Prices ↑ 6.7% projected", action: "LIST", state: "info", glyph: "▥" },
    { name: "Lithium Carbonate", detail: "Supply tightening", action: "WATCH", state: "warning", glyph: "▲" },
  ],
  workspaces: [
    { label: "Demand", state: "High" }, { label: "Supply", state: "Medium" },
    { label: "Opportunities", state: "High" }, { label: "Matching", state: "High" },
    { label: "Deals", state: "High" }, { label: "Network", state: "High" },
    { label: "Intelligence", state: "Medium" }, { label: "Documents", state: "High" },
    { label: "Finance", state: "High" },
  ],
};
