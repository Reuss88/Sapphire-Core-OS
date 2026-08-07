# Security and Safety Standards

## Core rule

Engineering convenience never outranks commercial authority, data protection, auditability or tenant isolation.

## Secrets and credentials

- Never commit secrets, service-role keys, access tokens or credentials.
- Keep privileged secrets server-side only.
- Do not expose Supabase service-role credentials to browser code.
- Use environment-variable contracts already established by the repository.

## Authority and permissions

- Assignment does not grant permission.
- Visibility does not grant permission.
- Workflow state does not grant permission.
- Protected actions must be checked at the authoritative backend boundary.
- AI may recommend and prepare, but may not silently approve or grant authority.

## Data boundaries

- Preserve organisation/tenant isolation.
- Apply RLS to user-accessible domain data unless a documented architecture exception exists.
- Minimise sensitive data returned to clients.
- Do not broaden access to make development easier.

## Mutations

Material mutations must be explicit, permission-checked and auditable. Irreversible actions require clear intent and confirmation appropriate to risk.

## Database safety

- Prefer additive migrations.
- Never drop or rewrite production data structures without explicit mission authority and migration/backout strategy.
- Never bypass existing audit/event systems.
- Validate foreign keys, state invariants and authority-sensitive transitions.

## External integrations

Treat inbound email, webhooks, bank messages, uploaded documents and third-party payloads as untrusted input. Validate, normalise, authenticate where applicable and preserve provenance.

## Stop conditions

Stop and report before implementation when credentials are missing, authority is genuinely ambiguous, tenant isolation may be weakened, a destructive migration is required but not approved, or implementation would create a second source of truth for protected data.