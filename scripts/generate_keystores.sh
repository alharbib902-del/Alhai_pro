#!/bin/bash
# ============================================================
# Alhai POS - Production Keystore Generator
# ============================================================
# This script generates production signing keystores for all
# Android apps in the Alhai project.
#
# Usage: bash scripts/generate_keystores.sh
# ============================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Alhai POS - Keystore Generator${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check if keytool is available
if ! command -v keytool &> /dev/null; then
    echo -e "${RED}Error: keytool not found. Install JDK first.${NC}"
    exit 1
fi

# App configurations.
#
# - APPS map: app name → application ID (for CN metadata).
# - APP_PATHS map: app name → path prefix relative to repo root.
#   Apps under apps/* use `apps/<name>`; customer_app + driver_app live
#   at the repo root (no `apps/` prefix) so they need an explicit entry.
declare -A APPS
APPS[cashier]="com.alhai.cashier"
APPS[admin]="com.alhai.admin"
APPS[admin_lite]="com.alhai.admin_lite"
APPS[customer_app]="com.alhai.customer"
APPS[driver_app]="com.alhai.driver_app"

declare -A APP_PATHS
APP_PATHS[cashier]="apps/cashier"
APP_PATHS[admin]="apps/admin"
APP_PATHS[admin_lite]="apps/admin_lite"
APP_PATHS[customer_app]="customer_app"
APP_PATHS[driver_app]="driver_app"

for APP_NAME in "${!APPS[@]}"; do
    APP_ID="${APPS[$APP_NAME]}"
    APP_DIR="$PROJECT_ROOT/${APP_PATHS[$APP_NAME]}/android"
    KEYSTORE_FILE="$APP_DIR/$APP_NAME-release.keystore"
    KEY_PROPERTIES="$APP_DIR/key.properties"

    echo -e "${YELLOW}--- Generating keystore for: $APP_NAME ---${NC}"

    if [ -f "$KEYSTORE_FILE" ]; then
        echo -e "${YELLOW}  Keystore already exists: $KEYSTORE_FILE${NC}"
        echo -e "${YELLOW}  Skipping... (delete manually to regenerate)${NC}"
        echo ""
        continue
    fi

    # Prompt for passwords
    echo -n "  Enter keystore password for $APP_NAME: "
    read -s STORE_PASS
    echo ""
    echo -n "  Confirm keystore password: "
    read -s STORE_PASS_CONFIRM
    echo ""

    if [ "$STORE_PASS" != "$STORE_PASS_CONFIRM" ]; then
        echo -e "${RED}  Passwords do not match! Skipping $APP_NAME.${NC}"
        continue
    fi

    if [ ${#STORE_PASS} -lt 6 ]; then
        echo -e "${RED}  Password must be at least 6 characters! Skipping $APP_NAME.${NC}"
        continue
    fi

    echo -n "  Enter key alias (default: ${APP_NAME}_key): "
    read KEY_ALIAS
    KEY_ALIAS="${KEY_ALIAS:-${APP_NAME}_key}"

    echo -n "  Enter your name (CN): "
    read CN_NAME
    CN_NAME="${CN_NAME:-Alhai}"

    echo -n "  Enter organization (O): "
    read ORG_NAME
    ORG_NAME="${ORG_NAME:-Alhai}"

    echo -n "  Enter country code (C, e.g., SA): "
    read COUNTRY
    COUNTRY="${COUNTRY:-SA}"

    # Generate keystore
    keytool -genkeypair \
        -v \
        -keystore "$KEYSTORE_FILE" \
        -keyalg RSA \
        -keysize 2048 \
        -validity 10000 \
        -alias "$KEY_ALIAS" \
        -storepass "$STORE_PASS" \
        -keypass "$STORE_PASS" \
        -dname "CN=$CN_NAME, O=$ORG_NAME, C=$COUNTRY"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}  Keystore generated: $KEYSTORE_FILE${NC}"

        # Create key.properties
        cat > "$KEY_PROPERTIES" << EOF
storePassword=$STORE_PASS
keyPassword=$STORE_PASS
keyAlias=$KEY_ALIAS
storeFile=../$APP_NAME-release.keystore
EOF
        echo -e "${GREEN}  key.properties created: $KEY_PROPERTIES${NC}"
    else
        echo -e "${RED}  Failed to generate keystore for $APP_NAME${NC}"
    fi

    echo ""
done

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Done! Next steps:${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "  1. NEVER commit keystore files or key.properties to git"
echo "  2. Store keystores securely (password manager, etc.)"
echo "  3. For CI/CD, encode keystores as base64 secrets:"
echo "     base64 -i apps/cashier/android/cashier-release.keystore"
echo "  4. The build.gradle.kts files are already configured"
echo "     to read from key.properties automatically."
echo ""
