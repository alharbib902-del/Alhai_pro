#!/usr/bin/env bash
# =============================================================================
# Al-HAI Cashier - Comprehensive Test Runner
# =============================================================================
# Usage:
#   ./scripts/run-all-tests.sh                  # Run all tests
#   ./scripts/run-all-tests.sh --unit           # Unit tests only
#   ./scripts/run-all-tests.sh --widget         # Widget tests only
#   ./scripts/run-all-tests.sh --e2e            # E2E tests only
#   ./scripts/run-all-tests.sh --e2e-full       # Full E2E suite (new)
#   ./scripts/run-all-tests.sh --quick          # Quick smoke tests
#   ./scripts/run-all-tests.sh --headed         # E2E with browser visible
#   ./scripts/run-all-tests.sh --report         # Generate HTML report
# =============================================================================

set -euo pipefail

# --- Configuration ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BASE_URL="${E2E_BASE_URL:-http://localhost:5000}"
REPORT_DIR="$PROJECT_DIR/test-reports"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# --- Counters ---
TOTAL_PASSED=0
TOTAL_FAILED=0
TOTAL_SKIPPED=0
SECTION_RESULTS=()

# --- Parse args ---
RUN_UNIT=false
RUN_WIDGET=false
RUN_INTEGRATION=false
RUN_E2E=false
RUN_E2E_FULL=false
RUN_ALL=true
HEADED=false
GENERATE_REPORT=false
QUICK_MODE=false

for arg in "$@"; do
  case $arg in
    --unit)        RUN_UNIT=true;        RUN_ALL=false ;;
    --widget)      RUN_WIDGET=true;      RUN_ALL=false ;;
    --integration) RUN_INTEGRATION=true; RUN_ALL=false ;;
    --e2e)         RUN_E2E=true;         RUN_ALL=false ;;
    --e2e-full)    RUN_E2E_FULL=true;    RUN_ALL=false ;;
    --headed)      HEADED=true ;;
    --report)      GENERATE_REPORT=true ;;
    --quick)       QUICK_MODE=true;      RUN_ALL=false ;;
    --help|-h)
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --unit          Run Dart unit tests only"
      echo "  --widget        Run Flutter widget tests only"
      echo "  --integration   Run integration tests only"
      echo "  --e2e           Run Playwright E2E tests (priority suites)"
      echo "  --e2e-full      Run the full E2E suite (all 20 categories)"
      echo "  --quick         Quick smoke test (unit + critical E2E)"
      echo "  --headed        Run E2E tests with visible browser"
      echo "  --report        Generate HTML test report"
      echo "  --help, -h      Show this help message"
      echo ""
      echo "Environment variables:"
      echo "  E2E_BASE_URL    Base URL for E2E tests (default: http://localhost:5000)"
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown option: $arg${NC}"
      exit 1
      ;;
  esac
done

# --- Helper functions ---
print_header() {
  echo ""
  echo -e "${BOLD}${BLUE}=============================================================================${NC}"
  echo -e "${BOLD}${BLUE}  $1${NC}"
  echo -e "${BOLD}${BLUE}=============================================================================${NC}"
  echo ""
}

print_section() {
  echo ""
  echo -e "${CYAN}--- $1 ---${NC}"
  echo ""
}

print_pass() {
  echo -e "  ${GREEN}PASS${NC} $1"
}

print_fail() {
  echo -e "  ${RED}FAIL${NC} $1"
}

print_skip() {
  echo -e "  ${YELLOW}SKIP${NC} $1"
}

record_result() {
  local section="$1"
  local status="$2" # pass, fail, skip
  case $status in
    pass) TOTAL_PASSED=$((TOTAL_PASSED + 1)) ;;
    fail) TOTAL_FAILED=$((TOTAL_FAILED + 1)) ;;
    skip) TOTAL_SKIPPED=$((TOTAL_SKIPPED + 1)) ;;
  esac
  SECTION_RESULTS+=("$section|$status")
}

run_command() {
  local desc="$1"
  shift
  if "$@" > /dev/null 2>&1; then
    print_pass "$desc"
    record_result "$desc" "pass"
    return 0
  else
    print_fail "$desc"
    record_result "$desc" "fail"
    return 1
  fi
}

# --- Start ---
print_header "Al-HAI Cashier - Comprehensive Test Suite"
echo -e "  ${BOLD}Timestamp:${NC} $(date)"
echo -e "  ${BOLD}Project:${NC}   $PROJECT_DIR"
echo -e "  ${BOLD}Base URL:${NC}  $BASE_URL"
echo -e "  ${BOLD}Mode:${NC}      $(if $RUN_ALL; then echo 'ALL TESTS'; elif $QUICK_MODE; then echo 'QUICK SMOKE'; else echo 'SELECTIVE'; fi)"
echo ""

cd "$PROJECT_DIR"

# Create report directory
mkdir -p "$REPORT_DIR"

SUITE_START=$(date +%s)

# =============================================================================
# PHASE 1: DART UNIT TESTS
# =============================================================================
if $RUN_ALL || $RUN_UNIT || $QUICK_MODE; then
  print_header "Phase 1: Dart Unit Tests"

  print_section "1.1 Cart Logic (cart_test.dart)"
  if flutter test test/unit/cart_test.dart --reporter compact 2>&1 | tee "$REPORT_DIR/unit_cart_$TIMESTAMP.log"; then
    print_pass "Cart unit tests"
    record_result "Cart unit tests" "pass"
  else
    print_fail "Cart unit tests"
    record_result "Cart unit tests" "fail"
  fi

  print_section "1.2 Payment Logic (payment_test.dart)"
  if flutter test test/unit/payment_test.dart --reporter compact 2>&1 | tee "$REPORT_DIR/unit_payment_$TIMESTAMP.log"; then
    print_pass "Payment unit tests"
    record_result "Payment unit tests" "pass"
  else
    print_fail "Payment unit tests"
    record_result "Payment unit tests" "fail"
  fi

  print_section "1.3 VAT Calculator (vat_test.dart)"
  if flutter test test/unit/vat_test.dart --reporter compact 2>&1 | tee "$REPORT_DIR/unit_vat_$TIMESTAMP.log"; then
    print_pass "VAT calculator tests"
    record_result "VAT calculator tests" "pass"
  else
    print_fail "VAT calculator tests"
    record_result "VAT calculator tests" "fail"
  fi

  print_section "1.4 Stock Management (stock_test.dart)"
  if flutter test test/unit/stock_test.dart --reporter compact 2>&1 | tee "$REPORT_DIR/unit_stock_$TIMESTAMP.log"; then
    print_pass "Stock management tests"
    record_result "Stock management tests" "pass"
  else
    print_fail "Stock management tests"
    record_result "Stock management tests" "fail"
  fi

  print_section "1.5 ZATCA TLV Encoding (zatca_tlv_test.dart)"
  if flutter test test/unit/zatca_tlv_test.dart --reporter compact 2>&1 | tee "$REPORT_DIR/unit_zatca_$TIMESTAMP.log"; then
    print_pass "ZATCA TLV tests"
    record_result "ZATCA TLV tests" "pass"
  else
    print_fail "ZATCA TLV tests"
    record_result "ZATCA TLV tests" "fail"
  fi

  print_section "1.6 All Unit Tests (batch)"
  if flutter test test/unit --reporter compact 2>&1 | tee "$REPORT_DIR/unit_all_$TIMESTAMP.log"; then
    print_pass "All unit tests batch"
    record_result "All unit tests batch" "pass"
  else
    print_fail "All unit tests batch"
    record_result "All unit tests batch" "fail"
  fi
fi

# =============================================================================
# PHASE 2: FLUTTER WIDGET TESTS
# =============================================================================
if $RUN_ALL || $RUN_WIDGET; then
  print_header "Phase 2: Flutter Widget Tests"

  # DI & Router
  print_section "2.1 Dependency Injection"
  if flutter test test/di/ --reporter compact 2>&1 | tee "$REPORT_DIR/widget_di_$TIMESTAMP.log"; then
    print_pass "DI tests"
    record_result "DI tests" "pass"
  else
    print_fail "DI tests"
    record_result "DI tests" "fail"
  fi

  print_section "2.2 Router"
  if flutter test test/router/ --reporter compact 2>&1 | tee "$REPORT_DIR/widget_router_$TIMESTAMP.log"; then
    print_pass "Router tests"
    record_result "Router tests" "pass"
  else
    print_fail "Router tests"
    record_result "Router tests" "fail"
  fi

  print_section "2.3 Cashier Shell UI"
  if flutter test test/ui/ --reporter compact 2>&1 | tee "$REPORT_DIR/widget_ui_$TIMESTAMP.log"; then
    print_pass "Shell UI tests"
    record_result "Shell UI tests" "pass"
  else
    print_fail "Shell UI tests"
    record_result "Shell UI tests" "fail"
  fi

  # Screen tests by category
  SCREEN_CATEGORIES=(
    "shifts:Shifts"
    "customers:Customers"
    "inventory:Inventory"
    "sales:Sales"
    "payment:Payment"
    "products:Products"
    "offers:Offers"
    "settings:Settings"
    "purchases:Purchases"
    "reports:Reports"
  )

  for category in "${SCREEN_CATEGORIES[@]}"; do
    IFS=':' read -r dir name <<< "$category"
    print_section "2.x Screen: $name"
    if flutter test "test/screens/$dir/" --reporter compact 2>&1 | tee "$REPORT_DIR/widget_${dir}_$TIMESTAMP.log"; then
      print_pass "$name screen tests"
      record_result "$name screen tests" "pass"
    else
      print_fail "$name screen tests"
      record_result "$name screen tests" "fail"
    fi
  done

  print_section "2.99 All Widget Tests (batch)"
  if flutter test test/ --reporter compact 2>&1 | tee "$REPORT_DIR/widget_all_$TIMESTAMP.log"; then
    print_pass "All widget tests batch"
    record_result "All widget tests batch" "pass"
  else
    print_fail "All widget tests batch"
    record_result "All widget tests batch" "fail"
  fi
fi

# =============================================================================
# PHASE 3: INTEGRATION TESTS
# =============================================================================
if $RUN_ALL || $RUN_INTEGRATION; then
  print_header "Phase 3: Integration Tests"

  print_section "3.1 Critical Flow"
  if flutter test integration_test/critical_flow_test.dart --reporter compact 2>&1 | tee "$REPORT_DIR/integration_critical_$TIMESTAMP.log"; then
    print_pass "Critical flow integration"
    record_result "Critical flow integration" "pass"
  else
    print_fail "Critical flow integration"
    record_result "Critical flow integration" "fail"
  fi

  print_section "3.2 Offline Sync"
  if flutter test integration_test/offline_sync_test.dart --reporter compact 2>&1 | tee "$REPORT_DIR/integration_sync_$TIMESTAMP.log"; then
    print_pass "Offline sync integration"
    record_result "Offline sync integration" "pass"
  else
    print_fail "Offline sync integration"
    record_result "Offline sync integration" "fail"
  fi
fi

# =============================================================================
# PHASE 4: E2E TESTS (Playwright - Priority Suites)
# =============================================================================
if $RUN_ALL || $RUN_E2E || $QUICK_MODE; then
  print_header "Phase 4: E2E Tests (Playwright)"

  export E2E_BASE_URL="$BASE_URL"

  # Ensure Playwright is installed
  if ! command -v npx &> /dev/null; then
    echo -e "${YELLOW}npx not found. Skipping E2E tests.${NC}"
    record_result "E2E tests" "skip"
  else
    # Install deps if needed
    if [ ! -d "node_modules" ]; then
      print_section "Installing Node dependencies..."
      npm install
    fi

    HEADED_FLAG=""
    if $HEADED; then
      HEADED_FLAG="--headed"
    fi

    if $QUICK_MODE; then
      print_section "4.1 Critical E2E Tests Only (quick mode)"
      if npx playwright test --grep "@critical" $HEADED_FLAG 2>&1 | tee "$REPORT_DIR/e2e_critical_$TIMESTAMP.log"; then
        print_pass "Critical E2E tests"
        record_result "Critical E2E tests" "pass"
      else
        print_fail "Critical E2E tests"
        record_result "Critical E2E tests" "fail"
      fi
    else
      print_section "4.1 Login E2E Tests"
      if npx playwright test e2e/tests/login.spec.ts $HEADED_FLAG 2>&1 | tee "$REPORT_DIR/e2e_login_$TIMESTAMP.log"; then
        print_pass "Login E2E tests"
        record_result "Login E2E tests" "pass"
      else
        print_fail "Login E2E tests"
        record_result "Login E2E tests" "fail"
      fi

      print_section "4.2 POS E2E Tests"
      if npx playwright test e2e/tests/pos.spec.ts $HEADED_FLAG 2>&1 | tee "$REPORT_DIR/e2e_pos_$TIMESTAMP.log"; then
        print_pass "POS E2E tests"
        record_result "POS E2E tests" "pass"
      else
        print_fail "POS E2E tests"
        record_result "POS E2E tests" "fail"
      fi

      print_section "4.3 Navigation E2E Tests"
      if npx playwright test e2e/tests/navigation.spec.ts $HEADED_FLAG 2>&1 | tee "$REPORT_DIR/e2e_nav_$TIMESTAMP.log"; then
        print_pass "Navigation E2E tests"
        record_result "Navigation E2E tests" "pass"
      else
        print_fail "Navigation E2E tests"
        record_result "Navigation E2E tests" "fail"
      fi

      print_section "4.4 Priority - Critical"
      if npx playwright test e2e/tests/priority-critical.spec.ts $HEADED_FLAG 2>&1 | tee "$REPORT_DIR/e2e_pri_critical_$TIMESTAMP.log"; then
        print_pass "Priority Critical E2E tests"
        record_result "Priority Critical E2E tests" "pass"
      else
        print_fail "Priority Critical E2E tests"
        record_result "Priority Critical E2E tests" "fail"
      fi

      print_section "4.5 Priority - High"
      if npx playwright test e2e/tests/priority-high.spec.ts $HEADED_FLAG 2>&1 | tee "$REPORT_DIR/e2e_pri_high_$TIMESTAMP.log"; then
        print_pass "Priority High E2E tests"
        record_result "Priority High E2E tests" "pass"
      else
        print_fail "Priority High E2E tests"
        record_result "Priority High E2E tests" "fail"
      fi

      print_section "4.6 Priority - Medium"
      if npx playwright test e2e/tests/priority-medium.spec.ts $HEADED_FLAG 2>&1 | tee "$REPORT_DIR/e2e_pri_medium_$TIMESTAMP.log"; then
        print_pass "Priority Medium E2E tests"
        record_result "Priority Medium E2E tests" "pass"
      else
        print_fail "Priority Medium E2E tests"
        record_result "Priority Medium E2E tests" "fail"
      fi
    fi
  fi
fi

# =============================================================================
# PHASE 5: FULL E2E SUITE (20 Categories)
# =============================================================================
if $RUN_ALL || $RUN_E2E_FULL; then
  print_header "Phase 5: Full E2E Suite (20 Categories)"

  export E2E_BASE_URL="$BASE_URL"

  HEADED_FLAG=""
  if $HEADED; then
    HEADED_FLAG="--headed"
  fi

  if [ ! -d "node_modules" ]; then
    npm install
  fi

  print_section "5.1 Full Suite - All 20 Test Categories"
  if npx playwright test e2e/tests/full-suite.spec.ts $HEADED_FLAG 2>&1 | tee "$REPORT_DIR/e2e_full_suite_$TIMESTAMP.log"; then
    print_pass "Full E2E suite (20 categories)"
    record_result "Full E2E suite" "pass"
  else
    print_fail "Full E2E suite (20 categories)"
    record_result "Full E2E suite" "fail"
  fi
fi

# =============================================================================
# RESULTS SUMMARY
# =============================================================================
SUITE_END=$(date +%s)
SUITE_DURATION=$((SUITE_END - SUITE_START))
SUITE_MINUTES=$((SUITE_DURATION / 60))
SUITE_SECONDS=$((SUITE_DURATION % 60))

print_header "Test Results Summary"

echo -e "  ${BOLD}Duration:${NC}  ${SUITE_MINUTES}m ${SUITE_SECONDS}s"
echo -e "  ${BOLD}Passed:${NC}   ${GREEN}${TOTAL_PASSED}${NC}"
echo -e "  ${BOLD}Failed:${NC}   ${RED}${TOTAL_FAILED}${NC}"
echo -e "  ${BOLD}Skipped:${NC}  ${YELLOW}${TOTAL_SKIPPED}${NC}"
echo ""

TOTAL=$((TOTAL_PASSED + TOTAL_FAILED + TOTAL_SKIPPED))
if [ $TOTAL -gt 0 ]; then
  PASS_RATE=$((TOTAL_PASSED * 100 / TOTAL))
  echo -e "  ${BOLD}Pass Rate:${NC} ${PASS_RATE}% ($TOTAL_PASSED/$TOTAL)"
fi
echo ""

# Print detailed results
echo -e "${BOLD}Detailed Results:${NC}"
echo "  ---------------------------------------------------------------"
for result in "${SECTION_RESULTS[@]}"; do
  IFS='|' read -r name status <<< "$result"
  case $status in
    pass) echo -e "  ${GREEN}PASS${NC}  $name" ;;
    fail) echo -e "  ${RED}FAIL${NC}  $name" ;;
    skip) echo -e "  ${YELLOW}SKIP${NC}  $name" ;;
  esac
done
echo "  ---------------------------------------------------------------"
echo ""

# --- Generate report ---
if $GENERATE_REPORT; then
  REPORT_FILE="$REPORT_DIR/test-report_$TIMESTAMP.md"
  {
    echo "# Al-HAI Cashier - Test Report"
    echo ""
    echo "**Date:** $(date)"
    echo "**Duration:** ${SUITE_MINUTES}m ${SUITE_SECONDS}s"
    echo "**Base URL:** $BASE_URL"
    echo ""
    echo "## Summary"
    echo ""
    echo "| Metric | Count |"
    echo "|--------|-------|"
    echo "| Passed | $TOTAL_PASSED |"
    echo "| Failed | $TOTAL_FAILED |"
    echo "| Skipped | $TOTAL_SKIPPED |"
    echo "| Total | $TOTAL |"
    echo "| Pass Rate | ${PASS_RATE:-0}% |"
    echo ""
    echo "## Detailed Results"
    echo ""
    echo "| Status | Test |"
    echo "|--------|------|"
    for result in "${SECTION_RESULTS[@]}"; do
      IFS='|' read -r name status <<< "$result"
      echo "| $status | $name |"
    done
    echo ""
    echo "## Log Files"
    echo ""
    echo "Logs saved to: \`$REPORT_DIR/\`"
    echo ""
    ls -la "$REPORT_DIR"/*_$TIMESTAMP.log 2>/dev/null | while read -r line; do
      echo "- $(basename "$(echo "$line" | awk '{print $NF}')")"
    done
  } > "$REPORT_FILE"

  echo -e "${GREEN}Report saved to: $REPORT_FILE${NC}"
fi

# --- Exit code ---
if [ $TOTAL_FAILED -gt 0 ]; then
  echo -e "${RED}${BOLD}Some tests failed! Review the logs above.${NC}"
  exit 1
else
  echo -e "${GREEN}${BOLD}All tests passed!${NC}"
  exit 0
fi
