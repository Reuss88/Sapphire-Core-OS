# Project Mission Debrief Bridge

Sapphire project debriefs describe project execution and link to canonical
implementation evidence in this repository. They do not make The Office a
source of Sapphire architecture, code, database state, or business truth.

Cross-agent operational debriefs and specialist method reviews remain canonical
in [The Office](https://github.com/Reuss88/The-Office/tree/main/debriefs).

Every project record under [`missions/`](missions/README.md) must:

- link to its canonical Sapphire completion report, tests, PR, and merge
  evidence where available;
- link to the corresponding Office debrief;
- summarise only enough context to route readers between the two authorities.

Every Office debrief for Sapphire work must link back to the canonical Sapphire
evidence. Do not duplicate entire completion reports between repositories.

Run `python tools/validate_debrief_bridge.py` from the repository root to check
the cross-link rule.
