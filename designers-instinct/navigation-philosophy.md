# Navigation Philosophy

## Purpose

Navigation in Sapphire Core OS must reflect commercial work, not database structure.

The product is organised around Commercial Workspaces because users enter Sapphire to understand, decide, and act. They should not need to understand the underlying data model to move through the system.

## Permanent doctrine

- Navigation follows the user's commercial intent.
- Workspaces own outcomes, not merely records.
- Database objects remain implementation detail.
- The same record may be referenced across several workspaces, but it has one owning workspace.
- Movement through Sapphire should preserve context, authority, and commercial continuity.
- Drill-down is preferred over copying the same detail into several screens.
- Global navigation exposes stable workspaces; local navigation exposes the stages and views needed inside that workspace.

## Navigation hierarchy

### Level 1 — Commercial Workspaces

The permanent top-level navigation is:

1. Dashboard
2. Demand
3. Supply
4. Opportunities
5. Matching
6. Deals
7. Network
8. Intelligence
9. Performance
10. Documents
11. Governance

Top-level navigation must remain stable. New database entities do not automatically justify new workspaces.

### Level 2 — Workspace views

Each workspace may contain views such as queues, stages, exceptions, saved views, and role-specific surfaces. These views must support the workspace's primary commercial question.

### Level 3 — Record and decision surfaces

Record pages, decision panels, timelines, evidence, and execution actions appear only after the user has entered the relevant workspace or followed a contextual drill-down.

## Context preservation

When a user moves between connected workspaces, Sapphire should preserve:

- the originating record or commercial context;
- the reason for the transition;
- the relevant permissions and authority state;
- the next meaningful action;
- a clear route back to the originating surface.

## Ownership and references

Every material record must have one owning workspace.

Other workspaces may reference that record, summarise it, or provide a contextual route to it. They must not create competing versions of the same commercial truth.

## Navigation tests

A navigation decision is valid only when it can answer:

1. What commercial intention brought the user here?
2. Which workspace owns the outcome?
3. What information is necessary now?
4. What is the next meaningful action?
5. Where does the user go for full detail?

## Anti-patterns

Sapphire must not:

- expose a menu item for every database table;
- duplicate full records across workspaces;
- use navigation as a substitute for workflow design;
- hide authority boundaries behind interface convenience;
- create dead-end dashboards or reports;
- add top-level navigation solely because a feature exists.

## Governing principle

Navigation must make the commercial operating model easier to understand without altering the operating model itself.
