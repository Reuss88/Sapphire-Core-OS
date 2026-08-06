# Product Surface Map

## Permanent architecture decision

Sapphire Core OS is organised around **Commercial Workspaces**.

It is **not** organised around database objects.

Database objects support the system internally. Commercial Workspaces organise the product around the work users are trying to understand, decide, and execute.

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

---

## Dashboard

**Purpose**  
Provide a decision-ready commercial command centre across Sapphire.

**Commercial question answered**  
What is happening, what needs attention, what is progressing, and what commercial value is emerging?

**Primary inputs**  
Summaries, exceptions, alerts, milestones, value signals, and performance indicators from all workspaces.

**Primary outputs**  
Prioritised actions, drill-down routes, decision prompts, risk visibility, and commercial orientation.

**Records owned**  
Dashboard configurations, saved views, widget preferences, and alert presentation rules.

**Records referenced**  
Demand records, supply records, opportunities, matches, deals, network entities, intelligence, performance metrics, documents, and governance states.

**Connected workspaces**  
All workspaces.

---

## Demand

**Purpose**  
Capture, qualify, structure, and interpret market demand.

**Commercial question answered**  
What are buyers trying to procure, on what terms, with what credibility, urgency, and commercial potential?

**Primary inputs**  
Buyer enquiries, RFQs, procurement requests, product requirements, volumes, specifications, destinations, timelines, pricing expectations, and buyer intelligence.

**Primary outputs**  
Qualified demand, structured buying requirements, demand signals, matching candidates, opportunity inputs, and demand intelligence.

**Records owned**  
Buyer enquiries, RFQs, procurement requests, and demand intelligence.

**Records referenced**  
Companies, contacts, mandates, KYC/KYB, supply, matches, opportunities, deals, documents, and market intelligence.

**Connected workspaces**  
Network, Supply, Opportunities, Matching, Deals, Intelligence, Documents, and Governance.

---

## Supply

**Purpose**  
Capture, qualify, structure, and monitor the sources capable of fulfilling commercial demand.

**Commercial question answered**  
What product is available, from whom, where, under what conditions, and with what level of reliability?

**Primary inputs**  
Producer data, mine output, refinery capacity, warehouse positions, inventory, specifications, origin, availability, pricing, logistics constraints, and supplier evidence.

**Primary outputs**  
Qualified supply, inventory visibility, supplier readiness, matching candidates, opportunity inputs, and supply intelligence.

**Records owned**  
Producers, mines, refineries, warehouses, and inventory.

**Records referenced**  
Companies, contacts, mandates, KYC/KYB, demand, matches, opportunities, deals, documents, and market intelligence.

**Connected workspaces**  
Network, Demand, Opportunities, Matching, Deals, Intelligence, Documents, and Governance.

---

## Opportunities

**Purpose**  
Convert qualified commercial signals into managed opportunities before formal deal execution.

**Commercial question answered**  
Which commercial possibilities are credible, valuable, actionable, and worth advancing?

**Primary inputs**  
Qualified demand, qualified supply, introductions, mandates, market signals, relationship context, and preliminary commercial terms.

**Primary outputs**  
Opportunity qualification, ownership, stage progression, next actions, value estimates, risks, and deal candidates.

**Records owned**  
Commercial opportunities, opportunity stages, qualification decisions, opportunity value estimates, and opportunity action plans.

**Records referenced**  
Demand, supply, matches, companies, contacts, mandates, intelligence, documents, and governance states.

**Connected workspaces**  
Demand, Supply, Matching, Deals, Network, Intelligence, Performance, Documents, and Governance.

---

## Matching

**Purpose**  
Identify, evaluate, and manage commercial fit between demand and supply.

**Commercial question answered**  
Which supply can credibly satisfy which demand, and why is the match commercially viable?

**Primary inputs**  
Demand specifications, supply specifications, pricing, geography, logistics, timing, mandates, relationship trust, compliance status, and commercial constraints.

**Primary outputs**  
Match candidates, fit scores, mismatch reasons, recommended actions, introduced pairings, and deal conversion routes.

**Records owned**  
Match records, match evaluations, fit rationale, mismatch reasons, and matching recommendations.

**Records referenced**  
Demand, supply, companies, contacts, opportunities, deals, intelligence, documents, and governance rules.

**Connected workspaces**  
Demand, Supply, Opportunities, Deals, Network, Intelligence, Documents, and Governance.

---

## Deals

**Purpose**  
Govern commercial execution from formal offer through settlement and commission.

**Commercial question answered**  
What must happen for this transaction to execute safely, lawfully, and profitably?

**Primary inputs**  
Qualified opportunities, approved matches, counterparties, mandates, commercial terms, compliance evidence, logistics information, and execution documents.

**Primary outputs**  
Executed agreements, controlled milestones, shipping progress, settlement status, commission outcomes, and transaction history.

**Records owned**  
SCO, FCO, SPA, contracts, shipping, settlement, commission, and execution documents.

**Records referenced**  
Demand, supply, matches, opportunities, companies, contacts, mandates, KYC/KYB, intelligence, performance, documents, and governance rules.

**Connected workspaces**  
Opportunities, Matching, Demand, Supply, Network, Intelligence, Performance, Documents, and Governance.

---

## Network

**Purpose**  
Maintain the commercial relationship graph, identity context, authority evidence, and trust history of the ecosystem.

**Commercial question answered**  
Who is involved, what role do they hold, what authority do they possess, and how much trust has been earned?

**Primary inputs**  
Company data, contact data, introductions, mandates, broker roles, relationship events, KYC, KYB, references, and trust evidence.

**Primary outputs**  
Verified entities, relationship context, authority visibility, trust history, compliance status, and network intelligence.

**Records owned**  
Companies, contacts, introducers, mandates, brokers, relationships, KYC, KYB, and trust history.

**Records referenced**  
Demand, supply, opportunities, matches, deals, intelligence, documents, and governance policies.

**Connected workspaces**  
Demand, Supply, Opportunities, Matching, Deals, Intelligence, Documents, and Governance.

---

## Intelligence

**Purpose**  
Preserve and apply commercial understanding across people, markets, transactions, and time.

**Commercial question answered**  
What does Sapphire know that should improve the next commercial decision?

**Primary inputs**  
CRI profiles, market information, transaction outcomes, relationship observations, lessons learned, analyst findings, and AI-supported synthesis.

**Primary outputs**  
Commercial memory, risk signals, recommendations, contextual briefings, lessons, and market intelligence.

**Records owned**  
CRI, market intelligence, lessons learned, and commercial memory.

**Records referenced**  
Demand, supply, opportunities, matches, deals, network records, performance data, documents, and governance rules.

**Connected workspaces**  
All commercial workspaces, especially Network, Opportunities, Matching, Deals, and Performance.

---

## Performance

**Purpose**  
Measure whether Sapphire is creating commercial value efficiently, reliably, and repeatably.

**Commercial question answered**  
Where is value being created, lost, delayed, or improved?

**Primary inputs**  
Revenue, commission, stage movement, conversion events, lead quality, supplier outcomes, closer activity, deal execution, and time-based performance data.

**Primary outputs**  
Performance scorecards, conversion insight, revenue visibility, quality indicators, trend analysis, and improvement priorities.

**Records owned**  
Revenue, commission, conversion, lead quality, supplier performance, and closer performance metrics.

**Records referenced**  
Demand, supply, opportunities, matches, deals, network, intelligence, documents, and governance configurations.

**Connected workspaces**  
Dashboard, Demand, Supply, Opportunities, Matching, Deals, Network, Intelligence, and Governance.

---

## Documents

**Purpose**  
Provide a controlled surface for commercial evidence, working documents, execution documents, and institutional records.

**Commercial question answered**  
What evidence or document supports this commercial action, obligation, authority, or decision?

**Primary inputs**  
Uploaded files, generated documents, signed agreements, compliance evidence, correspondence, templates, and linked records.

**Primary outputs**  
Versioned documents, approved templates, linked evidence, signature state, access-controlled records, and document history.

**Records owned**  
Document files, versions, templates, document metadata, signatures, approvals, and retention states.

**Records referenced**  
All records that documents evidence, govern, or support.

**Connected workspaces**  
All workspaces.

---

## Governance

**Purpose**  
Control authority, policy, workflow behaviour, AI boundaries, and system accountability.

**Commercial question answered**  
Who may do what, under which rule, with what evidence, and with what audit trail?

**Primary inputs**  
Organisational roles, permission models, policies, workflow definitions, AI settings, approval rules, and system events.

**Primary outputs**  
Permissions, enforced policies, workflow controls, AI configuration, approvals, exceptions, and audit records.

**Records owned**  
Permissions, policies, workflow rules, AI configuration, and audit.

**Records referenced**  
Every record and action subject to authority, policy, workflow, AI, or audit control.

**Connected workspaces**  
All workspaces.

---

## Surface ownership rule

A record has one primary owning workspace even when it is visible elsewhere.

Other workspaces may reference, summarise, filter, or drill into that record, but they must not silently create competing ownership models.

Navigation follows the user's commercial intent. Data architecture remains an implementation concern beneath the workspace layer.
