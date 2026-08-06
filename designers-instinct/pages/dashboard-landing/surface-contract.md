# Dashboard Landing Surface Contract

## Route

Canonical web route: `/dashboard`

The installed PWA and future Capacitor wrapper must open to the same authenticated route and commercial meaning.

## Widget catalogue

### 1. Director Attention Queue

**Question:** What requires intervention now?

**Owner:** Governance for approval/authority items; otherwise the workspace owning the underlying record.

**Minimum fields:** item type, severity, title, commercial reason, value exposure when applicable, due/expiry time, confidence, owning workspace, record ID, allowed action, drill-down route.

**Primary action:** open the owning record or authorised decision surface.

**Never:** approve or mutate merely by displaying the item.

### 2. Commercial Movement

**Question:** What materially progressed, stalled or regressed?

**Owner:** Opportunities, Matching and Deals.

**Minimum fields:** transition type, from/to state, materiality, timestamp, responsible owner, record reference and route.

### 3. Emerging Value

**Question:** What commercial value is forming, changing or at risk?

**Owner:** Performance, calculated from Opportunities and Deals.

**Minimum fields:** metric definition, amount, currency, period, comparison, confidence/probability method, source count and drill-down.

### 4. Workspace Pulse

**Question:** What is the current condition of each commercial workspace?

**Required summaries:** Demand, Supply, Opportunities, Matching, Deals, Network and Intelligence.

Each summary is limited to one status, up to three key signals and one drill-down action.

### 5. Performance Context

**Question:** Which performance signal changes a current decision?

Only decision-relevant metrics appear. Historical analytics without a current consequence belong in Performance.

### 6. AI Briefing

**Question:** What should the Director understand or investigate next?

Every statement must carry evidence references, confidence and a route to source records. Recommendations must be visually distinct from verified facts.

## Shared states

Every widget must implement:

- `loading` — stable skeleton preserving layout;
- `ready` — fresh, authorised data;
- `empty` — no qualifying records, with an explanatory route where useful;
- `stale` — last successful data timestamp and refresh option;
- `partial` — some sources unavailable or filtered by permission;
- `error` — recoverable explanation without exposing infrastructure details;
- `offline` — cached snapshot labelled with captured time and disabled server mutations;
- `unauthorised` — omit protected detail and never infer hidden counts.

## Interaction laws

- Every metric, alert and movement item leads somewhere meaningful.
- Drill-down preserves current scope, period and filters when relevant.
- Back navigation returns the Director to the same dashboard state.
- Destructive or authority-bearing actions never occur directly inside summary cards.
- Optimistic UI is prohibited for approvals, settlement, commission release, KYC/KYB status and other high-consequence states.
- Keyboard, screen-reader and touch interaction must expose the same meaning and actions.

## Responsive behaviour

### Wide desktop

Use a command-centre layout with the attention queue and commercial state visible without scrolling through decorative content. Maximum three visual emphasis levels.

### Tablet and narrow desktop

Preserve priority order. Secondary context may collapse, but critical alerts and commercial movement may not be hidden behind optional personalisation.

### Mobile PWA and Capacitor

- single-column priority stack;
- Director Attention first;
- minimum 44px touch targets;
- no hover-dependent information;
- safe-area-aware header and bottom navigation;
- sheets or full-screen routes for detail, not cramped modal replicas;
- cached read-only snapshot when offline;
- explicit confirmation before leaving an unfinished authorised action.

## Refresh and realtime

The initial page load uses one server-side snapshot contract. Realtime events invalidate or patch only affected widgets. The UI must show the last successful snapshot time and must not imply realtime freshness when subscriptions are disconnected.

## Route expectations

Drill-down targets must use stable workspace routes such as:

- `/demand/...`
- `/supply/...`
- `/opportunities/...`
- `/matching/...`
- `/deals/...`
- `/network/...`
- `/intelligence/...`
- `/performance/...`
- `/documents/...`
- `/governance/...`

Exact record route patterns must be defined by the owning workspace before implementation is locked.
