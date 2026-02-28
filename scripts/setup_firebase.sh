#!/bin/bash
# ============================================================
# Alhai POS - Firebase Setup Script
# ============================================================
# This script guides you through setting up Firebase for all apps.
#
# Prerequisites:
#   1. Install Firebase CLI: npm install -g firebase-tools
#   2. Install FlutterFire CLI: dart pub global activate flutterfire_cli
#   3. Login: firebase login
#
# Usage: bash scripts/setup_firebase.sh
# ============================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Alhai POS - Firebase Setup${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check prerequisites
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${RED}Error: $1 not found.${NC}"
        echo -e "${YELLOW}Install with: $2${NC}"
        exit 1
    fi
}

check_command "firebase" "npm install -g firebase-tools"
check_command "flutterfire" "dart pub global activate flutterfire_cli"

echo -e "${CYAN}Step 1: Creating Firebase project...${NC}"
echo ""
echo "  You need to create a Firebase project first:"
echo "  1. Go to https://console.firebase.google.com/"
echo "  2. Click 'Add Project' → Name it 'alhai-pos'"
echo "  3. Enable Google Analytics (optional)"
echo ""
echo -n "  Enter your Firebase project ID (e.g., alhai-pos): "
read FIREBASE_PROJECT_ID

if [ -z "$FIREBASE_PROJECT_ID" ]; then
    echo -e "${RED}  Project ID is required!${NC}"
    exit 1
fi

# Apps to configure
declare -A APPS
APPS[cashier]="com.alhai.cashier"
APPS[admin]="com.alhai.admin"
APPS[admin_lite]="com.alhai.admin_lite"

for APP_NAME in "${!APPS[@]}"; do
    APP_ID="${APPS[$APP_NAME]}"
    APP_DIR="$PROJECT_ROOT/apps/$APP_NAME"

    echo ""
    echo -e "${CYAN}Step 2: Configuring Firebase for $APP_NAME ($APP_ID)...${NC}"

    cd "$APP_DIR"

    # Run flutterfire configure
    flutterfire configure \
        --project="$FIREBASE_PROJECT_ID" \
        --android-package-name="$APP_ID" \
        --ios-bundle-id="$APP_ID" \
        --web-app-id="$APP_ID" \
        --out="lib/firebase_options.dart" \
        --yes

    echo -e "${GREEN}  Firebase configured for $APP_NAME${NC}"
done

cd "$PROJECT_ROOT"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Firebase Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "  Generated files:"
echo "    - apps/cashier/lib/firebase_options.dart"
echo "    - apps/cashier/android/app/google-services.json"
echo "    - apps/admin/lib/firebase_options.dart"
echo "    - apps/admin/android/app/google-services.json"
echo "    - apps/admin_lite/lib/firebase_options.dart"
echo "    - apps/admin_lite/android/app/google-services.json"
echo ""
echo "  Next steps:"
echo "    1. Add firebase_core to each app's pubspec.yaml"
echo "    2. Initialize Firebase in main.dart:"
echo "       await Firebase.initializeApp("
echo "         options: DefaultFirebaseOptions.currentPlatform,"
echo "       );"
echo "    3. Enable needed services in Firebase Console:"
echo "       - Authentication (Email/Phone)"
echo "       - Cloud Messaging (Push notifications)"
echo "       - Crashlytics (Error reporting)"
echo ""
