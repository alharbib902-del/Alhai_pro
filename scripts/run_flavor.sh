#!/bin/bash
# ============================================================
# Alhai POS - Run with Flavor
# ============================================================
# Usage:
#   bash scripts/run_flavor.sh cashier dev      # Run cashier in dev
#   bash scripts/run_flavor.sh admin staging     # Run admin in staging
#   bash scripts/run_flavor.sh cashier prod      # Run cashier in prod
#   bash scripts/run_flavor.sh cashier dev web   # Run on web
#   bash scripts/run_flavor.sh cashier prod apk  # Build APK
# ============================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

APP_NAME="${1:-cashier}"
FLAVOR="${2:-dev}"
TARGET="${3:-run}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Validate app name
case "$APP_NAME" in
    cashier|admin|admin_lite) ;;
    *)
        echo -e "${RED}Invalid app: $APP_NAME. Use: cashier, admin, admin_lite${NC}"
        exit 1
        ;;
esac

# Validate flavor
case "$FLAVOR" in
    dev|staging|prod) ;;
    *)
        echo -e "${RED}Invalid flavor: $FLAVOR. Use: dev, staging, prod${NC}"
        exit 1
        ;;
esac

# Load env file
ENV_FILE="$PROJECT_ROOT/config/$FLAVOR.env"
if [ ! -f "$ENV_FILE" ]; then
    echo -e "${RED}Env file not found: $ENV_FILE${NC}"
    exit 1
fi

# Parse env file into --dart-define flags
DART_DEFINES=""
while IFS='=' read -r key value; do
    # Skip empty lines and comments
    [[ -z "$key" || "$key" == \#* ]] && continue
    # Trim whitespace
    key=$(echo "$key" | xargs)
    value=$(echo "$value" | xargs)
    if [ -n "$key" ] && [ -n "$value" ]; then
        DART_DEFINES="$DART_DEFINES --dart-define=$key=$value"
    fi
done < "$ENV_FILE"

APP_DIR="$PROJECT_ROOT/apps/$APP_NAME"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  App: $APP_NAME | Flavor: $FLAVOR${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

cd "$APP_DIR"

case "$TARGET" in
    run)
        echo -e "${YELLOW}Running $APP_NAME ($FLAVOR)...${NC}"
        flutter run $DART_DEFINES
        ;;
    web)
        echo -e "${YELLOW}Running $APP_NAME ($FLAVOR) on web...${NC}"
        flutter run -d chrome $DART_DEFINES
        ;;
    apk)
        echo -e "${YELLOW}Building APK for $APP_NAME ($FLAVOR)...${NC}"
        flutter build apk $DART_DEFINES --no-tree-shake-icons
        ;;
    appbundle)
        echo -e "${YELLOW}Building App Bundle for $APP_NAME ($FLAVOR)...${NC}"
        flutter build appbundle $DART_DEFINES --no-tree-shake-icons
        ;;
    web-build)
        echo -e "${YELLOW}Building web for $APP_NAME ($FLAVOR)...${NC}"
        flutter build web $DART_DEFINES --no-tree-shake-icons
        ;;
    *)
        echo -e "${RED}Invalid target: $TARGET. Use: run, web, apk, appbundle, web-build${NC}"
        exit 1
        ;;
esac
