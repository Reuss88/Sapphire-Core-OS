# Module 8 — Pass 2: Authority Architecture

**Status:** Designed; pending final module consolidation.

## Purpose

Define who legitimately possesses the power to make a particular Decision, under which conditions, within which limits, and for how long.

## Core rule

```text
Responsibility performs work.
Authority legitimises decisions.
Access enables interaction.
Workflow coordinates execution.
These concepts are independent.
```

## Authority

Authority is the legitimate organisational permission to make a specified class of Decisions within defined limits.

Authority must answer:

1. Who?
2. May do what?
3. Under which conditions?
4. Within which limits?

## Canonical authority chain

```text
Organisation
→ Governance
→ Policy
→ Authority Rule
→ Authority Grant
→ Authority Evaluation
→ Decision
→ Business Consequence
```

Software records and evaluates authority. Software does not originate it.

## Authority Rule

An Authority Rule defines:

- Decision class;
- eligible actor;
- scope;
- jurisdiction;
- limits;
- conditions;
- effective period;
- governing policy;
- evidence requirements.

## Authority Grant

An Authority Grant records that a specific actor currently possesses authority governed by an Authority Rule.

Rule example:

> Regional Directors may approve contracts up to £250,000.

Grant example:

> Sarah Jones currently holds Regional Director authority.

## Scope and jurisdiction

Authority may be bounded by:

- organisation;
- legal entity;
- division;
- department;
- country;
- region;
- project;
- customer;
- supplier;
- product;
- property;
- regulatory regime.

## Limits

Examples:

- financial threshold;
- risk threshold;
- object type;
- relationship scope;
- time period;
- geography;
- legal entity;
- evidence completeness.

## Conditions

Examples:

- active employment;
- completed training;
- current certification;
- compliance clearance;
- no conflict of interest;
- quorum;
- required evidence;
- independent review.

## Delegation

Delegation extends an Authority Grant; it does not alter the Authority Rule.

A delegation records:

- delegator;
- delegate;
- authority class;
- permitted limits;
- reason;
- start;
- end;
- evidence;
- revocation.

## Shared, sequential, and parallel authority

Shared authority preserves independent authority domains.

Sequential authority exercises separate Decisions in order.

Parallel authority requires multiple independent authority exercises before consequence.

## Escalation

Escalation transfers the Decision to an actor with sufficient authority. It does not increase the authority of the original actor.

## Authority Grant lifecycle

```text
Proposed
→ Granted
→ Active
→ Suspended
→ Expired or Revoked
```

## Authority evidence

Authority may derive from:

- legislation;
- constitution;
- board resolution;
- policy;
- employment appointment;
- contract;
- delegation document;
- regulator;
- court or other competent body.

## Authority failures

- expired authority;
- insufficient authority;
- conflicting authority;
- revoked authority;
- ambiguous authority;
- missing delegation;
- exceeded limit;
- jurisdiction mismatch;
- missing evidence;
- conflict of interest.

## AI

AI possesses capability, not inherent organisational authority.

AI may act only under explicit, deterministic Authority Rules and must retain attribution, evidence, and control boundaries.

## Principles

- AT-01 Authority is organisational.
- AT-02 Software records authority.
- AT-03 Workflow consumes authority.
- AT-04 Access never creates authority.
- AT-05 Responsibility never creates authority.
- AT-06 Authority always has scope.
- AT-07 Authority always has limits.
- AT-08 Authority always has conditions.
- AT-09 Authority always has an effective period.
- AT-10 Authority Rules govern Authority Grants.
- AT-11 Delegation extends grants, not rules.
- AT-12 Revocation affects future Decisions only.
- AT-13 Authority evaluation occurs immediately before consequential Decisions.
- AT-14 Shared authority preserves independent authority.
- AT-15 AI never originates organisational authority.
