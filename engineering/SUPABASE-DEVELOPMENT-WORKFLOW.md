# Supabase Development Workflow

This is the canonical development and SQL-test workflow for Sapphire Core OS. It supports a local Supabase stack by default and an explicitly guarded, isolated remote development project when Docker is unavailable.

Production is never an acceptable target for these commands.

## Command contract

Run commands from the repository root:

```bash
scripts/supabase-dev.sh check
scripts/supabase-dev.sh start
scripts/supabase-dev.sh apply
scripts/supabase-dev.sh reset
scripts/supabase-dev.sh test
scripts/supabase-dev.sh lint
scripts/supabase-dev.sh verify
scripts/supabase-dev.sh static-check
scripts/supabase-dev.sh stop
```

`verify` applies pending migrations, runs every `tests/architecture/*.sql` file with `ON_ERROR_STOP`, and performs database linting. `static-check` does not require a database and is suitable for CI.

## Prerequisites

Both execution modes require:

- Bash;
- Python 3.11 or newer for static TOML validation;
- Supabase CLI;
- PostgreSQL `psql` for SQL/RLS smoke tests.

Local mode also requires Docker Desktop or another Docker-compatible engine. On macOS with Homebrew, install the CLI with:

```bash
brew install supabase/tap/supabase
```

If Homebrew is unavailable, install a supported Supabase CLI binary using the [official installation instructions](https://supabase.com/docs/guides/local-development/cli/getting-started). Do not use an unpinned global npm installation. Then confirm:

```bash
supabase --version
psql --version
docker --version
scripts/supabase-dev.sh check
```

The script also accepts an explicit executable path through `SUPABASE_BIN`.
If the correct Python executable is not named `python3`, set `PYTHON_BIN` to its path.

## Mode A — local Supabase

Local mode is the default and requires no project credentials:

```bash
export SAPPHIRE_SUPABASE_MODE=local
scripts/supabase-dev.sh start
scripts/supabase-dev.sh reset
scripts/supabase-dev.sh test
scripts/supabase-dev.sh lint
```

Use `apply` instead of `reset` when preserving existing local development data matters. Use `verify` for the normal pre-handoff check.

The default local PostgreSQL URL is:

```text
postgresql://postgres:postgres@127.0.0.1:54322/postgres
```

Override it only for another local disposable runtime:

```bash
export SAPPHIRE_SUPABASE_LOCAL_DB_URL='postgresql://postgres:postgres@127.0.0.1:54322/postgres'
```

Stop only this repository's local services:

```bash
scripts/supabase-dev.sh stop
```

## Mode B — isolated remote development project

Use this fallback only when an authorised Director has supplied a dedicated, non-production Supabase project. Put real values in the shell environment or CI secrets, never in committed files.

```bash
export SAPPHIRE_SUPABASE_MODE=remote-dev
export SAPPHIRE_SUPABASE_ENVIRONMENT=development
export SAPPHIRE_SUPABASE_REMOTE_CONFIRM=isolated-development-project
export SAPPHIRE_SUPABASE_PROJECT_REF='the-development-project-ref'
export SAPPHIRE_SUPABASE_PRODUCTION_PROJECT_REF='the-production-project-ref'
export SUPABASE_ACCESS_TOKEN='local-secret'
export SUPABASE_DB_PASSWORD='local-secret'
export SAPPHIRE_SUPABASE_DB_URL='postgresql://...percent-encoded-development-url...'
```

If no production project exists, use the explicit value `none` for `SAPPHIRE_SUPABASE_PRODUCTION_PROJECT_REF`. This is an attestation, not automatic discovery.

Connect, verify, and disconnect:

```bash
scripts/supabase-dev.sh link
scripts/supabase-dev.sh check
scripts/supabase-dev.sh verify
scripts/supabase-dev.sh unlink
```

Remote commands enforce all of the following before mutation:

- mode is `remote-dev`;
- environment is exactly `development`;
- the isolation confirmation sentinel is present;
- a production project reference (or explicit `none`) is declared;
- the target does not equal the declared production reference;
- the locally linked project exactly matches the requested development reference.

Remote reset is intentionally unsupported. If deterministic reset is required, recreate or restore the disposable development project through authorised Supabase administration, then link and apply again.

## Migration and test behaviour

- Migrations remain ordered under `supabase/migrations/` using the existing 14-digit timestamp convention.
- `supabase/config.toml` disables seed execution until a separate mission introduces reviewed synthetic fixtures.
- SQL smoke tests run inside transactions and are responsible for rollback, as the existing architecture tests do.
- RLS is never disabled by this workflow.
- Local `reset` is destructive only to the repository's disposable local database.
- Remote `apply` uses migration history and never requests a reset.

## CI

The repository workflow runs:

```bash
scripts/supabase-dev.sh static-check
```

This validates the command script, configuration presence, migration filenames/order, and obvious committed database credentials without requiring Docker or secrets. A future database-enabled CI environment can run `verify` after supplying an isolated development database and protected secrets.

## Troubleshooting

- `Docker is required`: install/start Docker, or use the authorised remote development mode.
- `Supabase CLI is required`: install the CLI and ensure `supabase` is on `PATH`, or set `SUPABASE_BIN` to its executable path.
- `psql is required`: install PostgreSQL client tools and ensure `psql` is on `PATH`.
- `No linked project found`: run `link` after exporting the guarded remote-development variables.
- `Linked project does not match`: run `unlink`, verify the intended project ref, and link again.

Never paste secrets into issues, logs, commits, screenshots, or mission reports.
