import type { Metadata } from "next";
import { HomeDashboard } from "../../components/home/home-dashboard";
import { homeDashboardFixture, type DashboardState } from "../../components/home/home-fixture";

export const metadata: Metadata = {
  title: "Home | Sapphire Core OS",
  description: "Director command deck for commercial position, market signals and execution attention.",
};

const states = new Set<DashboardState>(["ready", "loading", "empty", "stale", "partial", "offline", "error", "unauthorised"]);

export default async function DashboardPage({ searchParams }: { searchParams: Promise<{ state?: string }> }) {
  const requested = (await searchParams).state;
  const state = requested && states.has(requested as DashboardState) ? requested as DashboardState : "ready";
  return <HomeDashboard snapshot={homeDashboardFixture} state={state} />;
}
