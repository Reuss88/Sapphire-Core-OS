# Market Radar and Hot Right Now Doctrine

## Status

Permanent doctrine for opportunity timing and market-action signals in Sapphire Core OS.

## Governing principle

Sapphire must surface commercially relevant change early enough for the user to act.

**Market Radar is a first-class Commercial Workspace.**

**Hot Right Now is the Director-facing summary of the strongest current acquisition, listing, buying, selling, sourcing or monitoring signals.**

Neither is a price ticker, news feed or speculative recommendation engine.

## Dominant commercial question

Where should Sapphire deploy attention now, why, with what evidence, and what action is commercially justified?

## Signal classes

Signals may recommend:

- buy or acquire;
- sell or exit;
- source;
- list now;
- contact buyers;
- contact suppliers;
- negotiate;
- hold;
- monitor;
- avoid;
- investigate further.

Recommendations must remain distinguishable from authorised decisions.

## Signal inputs

Signals may derive from:

- price movement and volatility;
- supply and demand imbalance;
- verified inventory change;
- comparable transaction change;
- geographic or sector trends;
- active buyer and supplier behaviour;
- property listing and absorption evidence;
- macroeconomic, regulatory, political or logistics events;
- profile valuation changes;
- relationship intelligence;
- opportunity, deal and commission potential;
- freshness and confidence of available evidence.

## Required signal contract

Every Hot Right Now signal must declare:

- subject profile;
- proposed action;
- commercial thesis;
- evidence and source links;
- timestamp and valid-until state;
- geographic and market scope;
- expected upside and downside;
- confidence;
- material risks and unknowns;
- action window;
- next valid action;
- owning workspace and drill-down route;
- whether human verification is required.

A colour, arrow or score without this contract is decorative and prohibited.

## Scoring doctrine

Ranking may consider:

- urgency;
- expected commercial value;
- probability;
- evidence quality;
- confidence;
- strategic fit;
- execution readiness;
- liquidity;
- downside exposure;
- time decay;
- Director-defined thresholds.

The scoring model must be versioned, explainable and auditable. It may rank attention but may not grant authority.

## HOME contract

HOME must include a **Hot Right Now** region showing only the strongest decision-relevant signals.

It must answer:

- what is moving;
- why now;
- buy, sell, list, source, hold, avoid or investigate;
- expected value or risk;
- confidence and freshness;
- what the Director can do next.

The region must drill into Market Radar or the subject profile. HOME must not become a general market terminal.

## Action conversion

An authorised user may convert a signal into:

- a mission;
- a research task;
- an acquisition candidate;
- an opportunity;
- a buyer or supplier outreach action;
- a Director decision request;
- a watch condition.

The originating signal, model version and evidence must remain linked.

## AI boundary

AI may synthesise evidence, explain signals, model scenarios and recommend actions.

AI may not:

- guarantee future prices;
- present unverified forecasts as facts;
- execute trades, purchases, listings or binding communications without authority;
- hide conflicting evidence;
- create false precision;
- use restricted data outside permission boundaries.

## Implementation contract

The implementation must support:

- market observations and normalised price series;
- source provenance and freshness;
- profile-linked signals;
- versioned scoring models;
- signal history and expiry;
- scenario and recommendation records;
- thresholds and watch conditions;
- RPCs for Director, workspace and profile-scoped radar views;
- triggers for material changes, stale evidence and threshold crossings;
- idempotent signal generation;
- RLS and source licensing controls;
- audit of score, recommendation and human decision changes.

Market signals must not be calculated only in UI components.
