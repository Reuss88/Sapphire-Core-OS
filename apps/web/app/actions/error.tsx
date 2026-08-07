"use client";

export default function ActionsError({ reset }: { error: Error; reset: () => void }) {
  return (
    <main className="error-shell">
      <p className="eyebrow">ACTIONS UNAVAILABLE</p>
      <h1>The execution queue could not be loaded.</h1>
      <p>No work has been changed. Retry to fetch a fresh authoritative snapshot.</p>
      <button type="button" onClick={reset}>Retry</button>
    </main>
  );
}
