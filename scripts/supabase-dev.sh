#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SUPABASE_DIR="$ROOT_DIR/supabase"
TEST_DIR="$ROOT_DIR/tests/architecture"
MODE="${SAPPHIRE_SUPABASE_MODE:-local}"
LOCAL_DB_URL="${SAPPHIRE_SUPABASE_LOCAL_DB_URL:-postgresql://postgres:postgres@127.0.0.1:54322/postgres}"

die() {
  echo "error: $*" >&2
  exit 1
}

usage() {
  cat <<'EOF'
Usage: scripts/supabase-dev.sh <command>

Commands:
  check         Report runtime mode and required tool availability.
  start         Start the local Supabase runtime.
  apply         Apply pending migrations to local or guarded remote development.
  reset         Rebuild the local database from migrations (local only).
  test          Run architecture SQL smoke tests with psql.
  lint          Run Supabase database lint against the selected runtime.
  verify        Apply, test, and lint the selected development runtime.
  static-check  Validate repository runtime files without a database.
  link          Link the repository to a guarded remote development project.
  unlink        Remove the local remote-project link.
  stop          Stop this repository's local Supabase services.
EOF
}

require_mode() {
  case "$MODE" in
    local|remote-dev) ;;
    *) die "SAPPHIRE_SUPABASE_MODE must be 'local' or 'remote-dev' (got '$MODE')." ;;
  esac
}

resolve_supabase() {
  if [[ -n "${SUPABASE_BIN:-}" ]]; then
    [[ -x "$SUPABASE_BIN" ]] || die "SUPABASE_BIN is not executable: $SUPABASE_BIN"
    SUPABASE_CMD=("$SUPABASE_BIN")
  elif command -v supabase >/dev/null 2>&1; then
    SUPABASE_CMD=("$(command -v supabase)")
  else
    die "Supabase CLI is required. Install it using the documented workflow."
  fi
}

require_psql() {
  command -v psql >/dev/null 2>&1 || die "psql is required to run architecture SQL tests."
}

resolve_python() {
  local candidate="${PYTHON_BIN:-python3}"
  command -v "$candidate" >/dev/null 2>&1 || die "Python 3.11+ is required for static TOML validation."
  "$candidate" --version >/dev/null 2>&1 || die "Python is present but not runnable: $candidate"
  PYTHON_CMD="$candidate"
}

require_docker() {
  command -v docker >/dev/null 2>&1 || die "Docker is required for local Supabase."
  docker info >/dev/null 2>&1 || die "Docker is installed but the engine is not running."
}

run_supabase() {
  resolve_supabase
  "${SUPABASE_CMD[@]}" --workdir "$ROOT_DIR" "$@"
}

require_remote_environment() {
  [[ "$MODE" == "remote-dev" ]] || die "This command requires SAPPHIRE_SUPABASE_MODE=remote-dev."
  [[ "${SAPPHIRE_SUPABASE_ENVIRONMENT:-}" == "development" ]] ||
    die "SAPPHIRE_SUPABASE_ENVIRONMENT must equal 'development'."
  [[ "${SAPPHIRE_SUPABASE_REMOTE_CONFIRM:-}" == "isolated-development-project" ]] ||
    die "Set SAPPHIRE_SUPABASE_REMOTE_CONFIRM=isolated-development-project after verifying the target."
  [[ -n "${SAPPHIRE_SUPABASE_PROJECT_REF:-}" ]] || die "SAPPHIRE_SUPABASE_PROJECT_REF is required."
  [[ "$SAPPHIRE_SUPABASE_PROJECT_REF" != replace-* ]] || die "Replace the placeholder project ref."
  [[ -n "${SAPPHIRE_SUPABASE_PRODUCTION_PROJECT_REF:-}" ]] ||
    die "Set SAPPHIRE_SUPABASE_PRODUCTION_PROJECT_REF to the production ref, or 'none' if none exists."
  if [[ "$SAPPHIRE_SUPABASE_PRODUCTION_PROJECT_REF" != "none" &&
        "$SAPPHIRE_SUPABASE_PROJECT_REF" == "$SAPPHIRE_SUPABASE_PRODUCTION_PROJECT_REF" ]]; then
    die "Refusing to target the declared production Supabase project."
  fi
}

require_matching_link() {
  require_remote_environment
  local link_file="$SUPABASE_DIR/.temp/project-ref"
  [[ -f "$link_file" ]] || die "No linked project found. Run 'scripts/supabase-dev.sh link' first."
  local linked_ref
  linked_ref="$(tr -d '[:space:]' < "$link_file")"
  [[ "$linked_ref" == "$SAPPHIRE_SUPABASE_PROJECT_REF" ]] ||
    die "Linked project '$linked_ref' does not match SAPPHIRE_SUPABASE_PROJECT_REF."
}

database_url() {
  if [[ "$MODE" == "local" ]]; then
    printf '%s\n' "$LOCAL_DB_URL"
  else
    require_matching_link
    [[ -n "${SAPPHIRE_SUPABASE_DB_URL:-}" ]] ||
      die "SAPPHIRE_SUPABASE_DB_URL is required for remote SQL tests."
    [[ "$SAPPHIRE_SUPABASE_DB_URL" != replace-* ]] || die "Replace the database URL placeholder."
    printf '%s\n' "$SAPPHIRE_SUPABASE_DB_URL"
  fi
}

static_check() {
  bash -n "$ROOT_DIR/scripts/supabase-dev.sh"
  [[ -f "$SUPABASE_DIR/config.toml" ]] || die "supabase/config.toml is missing."
  [[ -d "$SUPABASE_DIR/migrations" ]] || die "supabase/migrations is missing."
  resolve_python
  "$PYTHON_CMD" - "$SUPABASE_DIR/config.toml" <<'PY'
import sys
import tomllib

with open(sys.argv[1], "rb") as config_file:
    tomllib.load(config_file)
PY

  local migration basename previous=""
  local migrations=("$SUPABASE_DIR"/migrations/*.sql)
  [[ -e "${migrations[0]}" ]] || die "No SQL migrations found."
  for migration in "${migrations[@]}"; do
    basename="$(basename "$migration")"
    [[ "$basename" =~ ^[0-9]{14}_[a-z0-9_]+\.sql$ ]] ||
      die "Invalid migration filename: $basename"
    if [[ -n "$previous" && "$basename" < "$previous" ]]; then
      die "Migration order is not deterministic: $basename follows $previous"
    fi
    previous="$basename"
  done

  if grep -RIEq '(sb_secret_[A-Za-z0-9_-]{20,}|eyJ[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,})' \
      "$SUPABASE_DIR" "$ROOT_DIR/.env.example" \
      "$ROOT_DIR/scripts/supabase-dev.sh" \
      "$ROOT_DIR/engineering/SUPABASE-DEVELOPMENT-WORKFLOW.md"; then
    die "Potential committed database secret detected in Supabase development files."
  fi

  echo "Supabase development runtime static checks passed."
}

run_tests() {
  require_psql
  local db_url test_file
  db_url="$(database_url)"
  local tests=("$TEST_DIR"/*.sql)
  [[ -e "${tests[0]}" ]] || die "No architecture SQL tests found in $TEST_DIR."

  for test_file in "${tests[@]}"; do
    echo "Running $(basename "$test_file")"
    psql "$db_url" -X -v ON_ERROR_STOP=1 -f "$test_file"
  done
}

require_mode
command_name="${1:-help}"

case "$command_name" in
  check)
    echo "mode: $MODE"
    for tool in docker psql; do
      if command -v "$tool" >/dev/null 2>&1; then
        echo "$tool: available ($(command -v "$tool"))"
      else
        echo "$tool: missing"
      fi
    done
    if [[ -n "${PYTHON_BIN:-}" && -x "$PYTHON_BIN" ]]; then
      echo "python: available ($PYTHON_BIN via PYTHON_BIN)"
    elif command -v python3 >/dev/null 2>&1 && python3 --version >/dev/null 2>&1; then
      echo "python: available ($(command -v python3))"
    else
      echo "python: missing or not runnable"
    fi
    if [[ -n "${SUPABASE_BIN:-}" && -x "$SUPABASE_BIN" ]]; then
      echo "supabase: available ($SUPABASE_BIN via SUPABASE_BIN)"
    elif command -v supabase >/dev/null 2>&1; then
      echo "supabase: available ($(command -v supabase))"
    else
      echo "supabase: missing"
    fi
    if [[ "$MODE" == "remote-dev" ]]; then
      require_remote_environment
      echo "remote guard: passed for project $SAPPHIRE_SUPABASE_PROJECT_REF"
    fi
    ;;
  start)
    [[ "$MODE" == "local" ]] || die "Remote development projects are connected with the 'link' command."
    require_docker
    run_supabase start
    ;;
  apply)
    if [[ "$MODE" == "local" ]]; then
      require_docker
      run_supabase db push --local
    else
      require_matching_link
      run_supabase db push --linked
    fi
    ;;
  reset)
    [[ "$MODE" == "local" ]] || die "Remote reset is prohibited. Recreate a disposable dev project instead."
    require_docker
    run_supabase db reset --local --no-seed
    ;;
  test)
    run_tests
    ;;
  lint)
    if [[ "$MODE" == "local" ]]; then
      require_docker
      run_supabase db lint --local --level error --fail-on error
    else
      require_matching_link
      run_supabase db lint --linked --level error --fail-on error
    fi
    ;;
  verify)
    "$0" apply
    "$0" test
    "$0" lint
    ;;
  static-check)
    static_check
    ;;
  link)
    require_remote_environment
    [[ -n "${SUPABASE_ACCESS_TOKEN:-}" ]] || die "SUPABASE_ACCESS_TOKEN must be supplied from local or CI secret storage."
    run_supabase link --project-ref "$SAPPHIRE_SUPABASE_PROJECT_REF"
    require_matching_link
    echo "Linked guarded development project $SAPPHIRE_SUPABASE_PROJECT_REF."
    ;;
  unlink)
    [[ "$MODE" == "remote-dev" ]] || die "Unlink is only valid in remote-dev mode."
    run_supabase unlink
    ;;
  stop)
    [[ "$MODE" == "local" ]] || die "Use 'unlink' to disconnect a remote development project."
    require_docker
    run_supabase stop
    ;;
  help|-h|--help)
    usage
    ;;
  *)
    usage >&2
    die "Unknown command: $command_name"
    ;;
esac
