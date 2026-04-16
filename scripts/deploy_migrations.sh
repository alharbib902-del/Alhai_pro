#!/usr/bin/env bash
# =============================================================================
# deploy_migrations.sh
#
# Applies the 2026-04-17 Alhai Supabase migrations (v38..v42) in order,
# one at a time, capturing each migration's RAISE NOTICE output so the
# operator can decide whether to run VALIDATE afterward.
#
# Usage:
#   export SUPABASE_DB_URL="postgresql://postgres:PASSWORD@db.PROJECTREF.supabase.co:5432/postgres"
#   ./scripts/deploy_migrations.sh [--dry-run]
#
# Environment:
#   SUPABASE_DB_URL   Full Postgres connection string (Supabase -> Project
#                     Settings -> Database -> Connection string -> URI).
#                     DO NOT commit this. Export it in your shell.
#
# Flags:
#   --dry-run   Print the SQL without executing.
#
# Safety:
#   - Every migration is wrapped in its own transaction BY THE FILE, so
#     a failure mid-migration leaves the DB in the previous-file state.
#   - Fails fast on the first error. Never runs a later migration after
#     an earlier one failed.
#   - Captures psql NOTICEs (the diagnostic row counts from v38/v39/v41)
#     and prints them in a clearly marked block.
# =============================================================================

set -euo pipefail

# ── Colors ─────────────────────────────────────────────────────────────
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'
NC=$'\033[0m'

say()  { echo "${BLUE}[deploy]${NC} $*"; }
ok()   { echo "${GREEN}[ ok  ]${NC} $*"; }
warn() { echo "${YELLOW}[warn ]${NC} $*"; }
fail() { echo "${RED}[fail ]${NC} $*" >&2; exit 1; }

# ── Preconditions ──────────────────────────────────────────────────────
DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    *) fail "Unknown flag: $arg" ;;
  esac
done

if [[ "${SUPABASE_DB_URL:-}" == "" ]]; then
  fail "SUPABASE_DB_URL is not set. Export the Supabase Postgres URI first."
fi

if ! command -v psql >/dev/null 2>&1; then
  fail "psql not found. Install PostgreSQL client: https://www.postgresql.org/download/"
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MIGRATIONS_DIR="$REPO_ROOT/supabase/migrations"

# Ordered list — add new migrations here as they ship.
MIGRATIONS=(
  "20260417_v38_zatca_nullability.sql"
  "20260417_v39_daily_summaries_count_column.sql"
  "20260417_v40_sa_audit_log.sql"
  "20260417_v41_enum_check_constraints.sql"
  "20260417_v42_sync_version_column.sql"
)

# ── Precheck: every file exists ────────────────────────────────────────
for m in "${MIGRATIONS[@]}"; do
  [[ -f "$MIGRATIONS_DIR/$m" ]] || fail "Migration file missing: $m"
done

# ── Precheck: can we reach the DB? ─────────────────────────────────────
if (( DRY_RUN == 0 )); then
  say "Testing connection…"
  if ! psql "$SUPABASE_DB_URL" -c 'SELECT version();' >/dev/null 2>&1; then
    fail "Cannot connect to Supabase. Check SUPABASE_DB_URL and network."
  fi
  ok "Connected."
fi

# ── Run each migration ─────────────────────────────────────────────────
for m in "${MIGRATIONS[@]}"; do
  say "───────────────────────────────────────────────────────────"
  say "Applying: $m"
  say "───────────────────────────────────────────────────────────"

  if (( DRY_RUN == 1 )); then
    echo "--- DRY RUN: would execute $MIGRATIONS_DIR/$m ---"
    head -20 "$MIGRATIONS_DIR/$m"
    echo "..."
    continue
  fi

  # Use ON_ERROR_STOP so psql returns non-zero on the first error.
  # Use -a to echo each statement (audit trail), and 2>&1 so RAISE NOTICE
  # output (which goes to stderr) is captured together with stdout.
  if ! psql "$SUPABASE_DB_URL" \
        --set ON_ERROR_STOP=on \
        --echo-errors \
        -f "$MIGRATIONS_DIR/$m" 2>&1 | tee "/tmp/${m}.log"; then
    fail "Migration $m failed. See /tmp/${m}.log"
  fi

  # Extract any NOTICEs for the summary.
  grep -iE '^NOTICE:' "/tmp/${m}.log" > "/tmp/${m}.notices" || true
  if [[ -s "/tmp/${m}.notices" ]]; then
    warn "Diagnostics from $m (review before VALIDATE):"
    sed 's/^/  /' "/tmp/${m}.notices"
  fi
  ok "Applied: $m"
done

# ── Summary ────────────────────────────────────────────────────────────
say "───────────────────────────────────────────────────────────"
ok "All migrations applied successfully."
say "───────────────────────────────────────────────────────────"
cat <<EOF

Next steps:
  1. Review /tmp/*.notices for any row-count diagnostics
     (v38: ZATCA invoices missing hash/qr/uuid,
      v39: daily_summaries with ambiguous total_refunds,
      v41: rows with out-of-enum status values).
  2. If counts are zero, run:
       ./scripts/validate_constraints.sh
     to flip every NOT VALID constraint into VALIDATED state.
  3. Run:
       ./scripts/post_deploy_check.py
     to smoke-test the schema shape.

EOF
