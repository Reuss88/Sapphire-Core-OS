import { Card, SharedState } from "../../design-system";

export default function DashboardLoading() {
  return <main className="catalogue-page"><Card variant="focus"><SharedState state="loading" title="Preparing Director snapshot" detail="Governed commercial sources are loading into a stable command-deck frame." /></Card></main>;
}
