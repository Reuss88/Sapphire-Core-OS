"use client";

export default function ReservedWorkspaceError({ reset }: { error: Error; reset: () => void }) {
  return <main className="error-shell"><p className="eyebrow">WORKSPACE ROUTE UNAVAILABLE</p><h1>The governed route could not be checked.</h1><p>No record or authoritative state has been changed.</p><button type="button" onClick={reset}>Retry</button></main>;
}
