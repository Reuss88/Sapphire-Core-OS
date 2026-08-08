"use client";

import { Button, Card, SharedState } from "../../design-system";

export default function DashboardError({ reset }: { error: Error & { digest?: string }; reset: () => void }) {
  return <main className="catalogue-page"><Card variant="attention"><SharedState state="error" title="Director snapshot unavailable" detail="The dashboard could not load. Protected data and infrastructure details remain concealed." action={<Button variant="primary" onClick={reset}>Retry snapshot</Button>} /></Card></main>;
}
