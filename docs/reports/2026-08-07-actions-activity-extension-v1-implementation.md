# Actions Activity Collaboration Extension v1 — Implementation Report

## Mission

- Mission ID: `ACTIONS-ACTIVITY-001`
- Branch: `agent/actions-activity-extension-001`
- Actions baseline: `3fc7ddf`
- Review URL: `http://127.0.0.1:3000/actions`

## Result

The completed Actions workspace now consumes a shared, organisation-scoped Activity capability. It does not own a second notes, comments, call-log, Inbox, Documents, Governance, or audit system.

## Shared Activity backend

- Canonical `sca_core.activity`, typed links and explicit actor audiences.
- Activity types cover collaboration, calls, meetings, research, outcomes, handoffs, evidence/message summaries, AI summaries and escalations.
- Visibility scopes: private actor, Director only, assigned users, mission team, workspace team and organisation.
- Server-side visibility evaluation and RLS enforce actor, team, assignment and organisation boundaries. Director capability does not override private, assignment or team visibility.
- Security-definer mutation RPCs create, correct, withdraw and redact Activity; direct mutation is revoked.
- Material Activity cannot be hard-deleted. Material mutations emit immutable `sca_audit.activity_event` records.
- AI-assisted Activity requires provenance linkage.
- Work Journal RPC returns visible Activity, authoritative Actions execution events and evidence as distinct entry kinds.
- Follow-up creation is explicit and creates bidirectional Activity/Action links.
- Commercially material Actions can require an outcome Activity and/or governed evidence before completion.
- Realtime publication and client invalidation keys include Activity and subject journals.

## Director review scenarios

### Closer

The Team lens exposes a dated, high-priority Action for Maya Chen to call Sofia Marin. The Action links Sofia's Profile, the copper Opportunity and the authoritative Inbox thread. Work Journal shows the Director instruction, authoritative state transition, call attempt, connected-call structured outcome and final outcome. Relevant entries expose an explicit create-follow-up command.

### Research

The gold supplier Action exposes a research update with candidate count, confidence and quality note; a governed Documents evidence reference; and an AI summary with visible AI provenance. Candidate findings are references and do not create duplicate canonical records.

### Collaboration composer

The Activity composer supports Director instructions, progress, questions/blockers, call attempt or connection, research, final outcome, handoff and evidence reference. Visibility is explicit before publish. The private-actor state explicitly states that Director role does not override the boundary. Connected calls reveal structured channel, contact and agreed-next-step fields.

Fixture UI commands intentionally do not claim authoritative mutation. The backend RPC and RLS contract is implemented and tested for connection by the authenticated application shell.

## Validation

- `scripts/supabase-dev.sh reset` — PASS
- `scripts/supabase-dev.sh test` — PASS, including Activity collaboration architecture scenarios
- `scripts/supabase-dev.sh static-check` — PASS
- `scripts/supabase-dev.sh lint` — PASS, no schema errors
- `pnpm typecheck` — PASS
- `pnpm lint` — PASS
- `pnpm test` — PASS
- `pnpm build` — PASS
- Production browser review — PASS at 1600×1000, 900×900 and 390×844
- Browser console warnings/errors — none

## Director review evidence

- `artifacts/actions-activity-v1/actions-activity-desktop-1600x1000.png`
- `artifacts/actions-activity-v1/actions-activity-tablet-900x900.png`
- `artifacts/actions-activity-v1/actions-activity-mobile-390x844.png`

## Boundaries preserved

- Actions remains authoritative for accountable work and state.
- Inbox remains authoritative for message truth.
- Documents remains authoritative for files and evidence records.
- Governance remains authoritative for protected approvals and decisions.
- Audit remains immutable history rather than collaboration context.
- Activity provides shared contextual collaboration and commercial memory only.
