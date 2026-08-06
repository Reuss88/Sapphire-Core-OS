# Navigation Philosophy

## Purpose

Navigation in Sapphire Core OS must reflect commercial intent, not the underlying database schema.

Users should move through Sapphire according to the work they are trying to understand, decide, or execute. The product should not force users to translate their commercial objective into technical objects before they can act.

## Permanent navigation

The top-level product navigation is:

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

This sequence reflects the commercial operating flow while preserving access to cross-cutting institutional capabilities.

## Core principles

### Commercial workspaces over object menus

Top-level navigation represents Commercial Workspaces.

Companies, contacts, RFQs, contracts, inventory, and other records may appear within those workspaces, but they do not automatically become top-level navigation items.

### One destination for ownership

Every record has one primary owning workspace.

The same record may be referenced elsewhere, but navigation must lead users back to the owning workspace for full context, editing, execution, and governance.

### Drill-down over duplication

A summary should lead to detail rather than reproduce it.

The dashboard, performance views, intelligence surfaces, and connected workspaces may surface the same commercial condition, but they must not create parallel operational copies.

### Context must survive movement

When users move between connected workspaces, Sapphire should preserve relevant context such as:

- the originating record;
- the commercial question being investigated;
- active filters;
- relationship context;
- deal or opportunity context;
- the reason for the transition.

Navigation should reduce rework, not force users to reconstruct the path that brought them there.

### Action follows authority

Navigation may reveal an available destination or recommended next step. It must not imply that the user has permission to complete the action.

Visibility, workflow position, recommendation, and authority are separate concepts.

### Predictability over novelty

A user should be able to predict where information lives and where an action will occur.

New features should attach to the workspace that owns their commercial purpose. They should not create new top-level surfaces merely because they introduce a new record type or technology.

## Workspace entry pattern

Each workspace should open with:

1. A clear statement of purpose.
2. The dominant commercial question.
3. A prioritised summary of active work.
4. Exceptions and items requiring attention.
5. A direct route into owned records and actions.

A workspace landing page is not a miniature dashboard for the entire system. It is the command surface for that workspace's commercial responsibility.

## Cross-workspace movement

Cross-workspace links should explain why the destination matters.

Examples include:

- Demand to Matching: find credible supply for a qualified requirement.
- Supply to Matching: identify demand compatible with available product.
- Matching to Opportunities: advance a commercially viable pairing.
- Opportunities to Deals: begin controlled execution.
- Deals to Documents: inspect or complete execution evidence.
- Network to Intelligence: understand trust, history, and commercial context.
- Performance to an owning workspace: investigate the cause behind a metric.

## Navigation test

Before adding or changing navigation, answer:

- What commercial task is the user trying to complete?
- Which workspace owns that task?
- Is this a destination, a drill-down, or a reference?
- Does the change duplicate an existing route?
- Will the user understand where they are, why they arrived, and what happens next?

If those questions cannot be answered clearly, the navigation change is not ready.
