# Colour System

## Core palette
- canvas / Midnight Obsidian: `#090C14`
- surface / Graphite Navy: `#121826`
- elevated / Slate Indigo: `#1A2234`
- border / Steel Blue: `#2A3750`
- primary / Royal Sapphire: `#2F6BFF`
- realtime-ai / Electric Cyan: `#45C8FF`
- success / Emerald: `#21C67A`
- warning / Amber Gold: `#D6A53A`
- critical / Ruby: `#D04A4A`
- text-primary: `#F5F7FB`
- text-secondary: `#AAB7CC`
- text-muted: `#70809D`

## Rules
Royal Sapphire marks selection, primary action and brand authority. Cyan marks realtime, AI and active intelligence. Emerald means verified positive progress, not decoration. Amber means attention or uncertainty. Ruby means material risk, failure or blocked execution.

Colours must map to semantic tokens rather than direct hex use in components. Required families: background, surface, border, text, action, status, data-series and focus.

No saturated rainbow dashboards. Charts use a controlled ordered palette, with status colours reserved for actual status meaning. Every semantic colour requires an icon, label or pattern companion where ambiguity is possible.

Contrast must meet WCAG 2.2 AA. Dark mode is the flagship theme. A future light theme may exist but must preserve semantic equivalence, not merely invert colours.
