export type WorkspaceAvailability = "implemented" | "placeholder";

export interface WorkspaceNavigationItem {
  label: string;
  href: string;
  symbol: string;
  slug: string;
  availability: WorkspaceAvailability;
  owner: string;
  description: string;
}

export const workspaceNavigation: WorkspaceNavigationItem[] = [
  { label: "Home", href: "/dashboard", slug: "dashboard", symbol: "◇", availability: "implemented", owner: "Director Command", description: "Commercial position, signals and Director attention." },
  { label: "Actions", href: "/actions", slug: "actions", symbol: "◆", availability: "implemented", owner: "Execution", description: "Ranked execution queue, Action Context and Work Journal." },
  { label: "Inbox", href: "/inbox", slug: "inbox", symbol: "◇", availability: "placeholder", owner: "Communications", description: "Governed conversations, mentions and record-linked updates." },
  { label: "Market Radar", href: "/market-radar", slug: "market-radar", symbol: "◇", availability: "placeholder", owner: "Intelligence", description: "Evidence-backed global commercial signals and monitoring." },
  { label: "Demand", href: "/demand", slug: "demand", symbol: "◇", availability: "placeholder", owner: "Commercial", description: "Qualified mandates and governed buyer demand." },
  { label: "Supply", href: "/supply", slug: "supply", symbol: "◇", availability: "placeholder", owner: "Commercial", description: "Verified supplier capability and availability." },
  { label: "Opportunities", href: "/opportunities", slug: "opportunities", symbol: "◇", availability: "placeholder", owner: "Commercial", description: "Commercial opportunity records and stage governance." },
  { label: "Matching", href: "/matching", slug: "matching", symbol: "◇", availability: "placeholder", owner: "Intelligence", description: "Evidence-led demand and supply matching." },
  { label: "Deals", href: "/deals", slug: "deals", symbol: "◇", availability: "placeholder", owner: "Commercial", description: "Live transaction execution and settlement state." },
  { label: "Network", href: "/network", slug: "network", symbol: "◇", availability: "placeholder", owner: "Network", description: "Governed commercial relationships and introductions." },
  { label: "Profiles", href: "/profiles", slug: "profiles", symbol: "◇", availability: "placeholder", owner: "Network", description: "Verified people, company and counterparty profiles." },
  { label: "Intelligence", href: "/intelligence", slug: "intelligence", symbol: "◇", availability: "placeholder", owner: "Intelligence", description: "Briefings, evidence and labelled analysis." },
  { label: "Documents", href: "/documents", slug: "documents", symbol: "◇", availability: "placeholder", owner: "Evidence", description: "Governed evidence packs and commercial documents." },
  { label: "Finance", href: "/finance", slug: "finance", symbol: "◇", availability: "placeholder", owner: "Finance", description: "Pipeline value, commission, risk and settlement position." },
  { label: "Governance", href: "/governance", slug: "governance", symbol: "◇", availability: "placeholder", owner: "Governance", description: "Authority, approvals and accountable decisions." },
];

export const placeholderWorkspaces = new Map(workspaceNavigation.filter((item) => item.availability === "placeholder").map((item) => [item.slug, item]));
