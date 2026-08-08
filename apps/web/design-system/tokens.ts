export const sapphireTokens = {
  color: {
    canvas: "var(--sapphire-color-canvas)",
    surface: "var(--sapphire-color-surface)",
    elevated: "var(--sapphire-color-elevated)",
    border: "var(--sapphire-color-border)",
    primary: "var(--sapphire-color-primary)",
    text: "var(--sapphire-color-text)",
    textSecondary: "var(--sapphire-color-text-secondary)",
    textMuted: "var(--sapphire-color-text-muted)",
  },
  space: {
    1: "var(--sapphire-space-1)",
    2: "var(--sapphire-space-2)",
    3: "var(--sapphire-space-3)",
    4: "var(--sapphire-space-4)",
    6: "var(--sapphire-space-6)",
    8: "var(--sapphire-space-8)",
  },
  radius: {
    compact: "var(--sapphire-radius-compact)",
    control: "var(--sapphire-radius-control)",
    card: "var(--sapphire-radius-card)",
    overlay: "var(--sapphire-radius-overlay)",
  },
  motion: {
    feedback: "var(--sapphire-motion-feedback)",
    compact: "var(--sapphire-motion-compact)",
    panel: "var(--sapphire-motion-panel)",
  },
} as const;

export type SapphireCardVariant =
  | "standard"
  | "focus"
  | "intelligence"
  | "financial"
  | "attention"
  | "opportunity"
  | "summary"
  | "evidence"
  | "timeline"
  | "queue"
  | "visualisation"
  | "form"
  | "calendar";
