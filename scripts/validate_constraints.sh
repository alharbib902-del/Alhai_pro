#!/usr/bin/env bash
# =============================================================================
# validate_constraints.sh
#
# After deploy_migrations.sh runs successfully AND you've reviewed the
# NOTICE output and cleaned any offending rows, flip every NOT VALID
# constraint into a fully validated state.
#
# NOT VALID constraints prevent NEW bad rows but DON'T block the
# deploy on existing legacy data. VALIDATE CONSTRAINT promotes them
# to "also enforced against existing data". If any legacy row violates
# the constraint, VALIDATE fails — that's a signal to go fix the data
# before retrying.
#
# Usage:
#   export SUPABASE_DB_URL="..."
#   ./scripts/validate_constraints.sh [--dry-run]
# =============================================================================

set -euo pipefail

RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'
NC=$'\033[0m'

say()  { echo "${BLUE}[validate]${NC} $*"; }
ok()   { echo "${GREEN}[  ok   ]${NC} $*"; }
warn() { echo "${YELLOW}[ warn  ]${NC} $*"; }
fail() { echo "${RED}[ fail  ]${NC} $*" >&2; exit 1; }

DRY_RUN=0
for arg in "$@"; do
  [[ "$arg" == "--dry-run" ]] && DRY_RUN=1
done

[[ "${SUPABASE_DB_URL:-}" == "" ]] && fail "SUPABASE_DB_URL not set."
command -v psql >/dev/null || fail "psql not found."

# Constraints to validate, in order. (table, constraint_name)
CONSTRAINTS=(
  "invoices invoices_zatca_complete_when_issued"   # v38
  "orders orders_status_valid"                     # v41
  "sales sales_status_valid"                       # v41
  "sales sales_payment_method_valid"               # v41
  "invoices invoices_status_valid"                 # v41
  "shifts shifts_status_valid"                     # v41
  "purchases purchases_status_valid"               # v41
  "stock_transfers stock_transfers_status_valid"   # v41
  "returns returns_status_valid"                   # v41
)

FAILED=()

for entry in "${CONSTRAINTS[@]}"; do
  read -r tbl cnstr <<< "$entry"
  say "Validating $tbl / $cnstr"

  if (( DRY_RUN )); then
    echo "  DRY-RUN: would run ALTER TABLE public.$tbl VALIDATE CONSTRAINT $cnstr;"
    continue
  fi

  # Capture row count before to show what we're validating against.
  cnt=$(psql "$SUPABASE_DB_URL" -Atc "SELECT COUNT(*) FROM public.$tbl;" 2>/dev/null || echo "?")
  echo "  Table $tbl has $cnt rows."

  if psql "$SUPABASE_DB_URL" --set ON_ERROR_STOP=on \
      -c "ALTER TABLE public.$tbl VALIDATE CONSTRAINT $cnstr;" 2>&1 | tee "/tmp/validate_${tbl}_${cnstr}.log"; then
    ok "$tbl / $cnstr — validated"
  else
    warn "$tbl / $cnstr — FAILED (likely offending rows exist)"
    FAILED+=("$tbl/$cnstr")
  fi
done

echo ""
if (( ${#FAILED[@]} == 0 )); then
  ok "All constraints validated."
  exit 0
else
  warn "Some constraints could not be validated:"
  for f in "${FAILED[@]}"; do echo "  - $f"; done
  echo ""
  warn "Fix the offending rows then re-run this script for just the failed ones:"
  echo "  psql \"\$SUPABASE_DB_URL\" -c 'ALTER TABLE public.<t> VALIDATE CONSTRAINT <c>;'"
  exit 1
fi
