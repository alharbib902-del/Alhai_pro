#!/bin/bash
# ============================================================
# Alhai POS - iOS Platform Setup Script
# ============================================================
# This script creates iOS platform files for apps that are
# missing them (customer_app, distributor_portal, super_admin).
#
# Prerequisites:
#   - macOS with Xcode installed
#   - Flutter SDK installed
#
# Usage: bash scripts/setup_ios.sh
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
echo -e "${GREEN}  Alhai POS - iOS Platform Setup${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check if we're on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo -e "${RED}Error: This script must run on macOS.${NC}"
    echo -e "${YELLOW}iOS platform files can only be created on macOS with Xcode.${NC}"
    exit 1
fi

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}Error: Flutter not found.${NC}"
    exit 1
fi

# Apps that need iOS folders
APPS_NEEDING_IOS=(
    "customer_app:com.alhai.customer"
    "distributor_portal:com.alhai.distributor"
    "super_admin:com.alhai.superadmin"
)

for APP_ENTRY in "${APPS_NEEDING_IOS[@]}"; do
    APP_NAME="${APP_ENTRY%%:*}"
    BUNDLE_ID="${APP_ENTRY##*:}"
    APP_DIR="$PROJECT_ROOT/$APP_NAME"

    echo -e "${CYAN}--- Setting up iOS for: $APP_NAME ---${NC}"

    if [ -d "$APP_DIR/ios" ]; then
        echo -e "${YELLOW}  iOS folder already exists. Skipping.${NC}"
        continue
    fi

    if [ ! -d "$APP_DIR" ]; then
        echo -e "${RED}  App directory not found: $APP_DIR${NC}"
        continue
    fi

    cd "$APP_DIR"

    # Create iOS platform
    flutter create --platforms=ios .

    # Update bundle ID in project.pbxproj
    if [ -f "ios/Runner.xcodeproj/project.pbxproj" ]; then
        sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = .*;/PRODUCT_BUNDLE_IDENTIFIER = $BUNDLE_ID;/g" \
            "ios/Runner.xcodeproj/project.pbxproj"
        echo -e "${GREEN}  Bundle ID set to: $BUNDLE_ID${NC}"
    fi

    # Add privacy descriptions to Info.plist
    PLIST="ios/Runner/Info.plist"
    if [ -f "$PLIST" ]; then
        # Add NSCameraUsageDescription
        /usr/libexec/PlistBuddy -c "Add :NSCameraUsageDescription string 'Camera access is needed for scanning barcodes and taking product photos'" "$PLIST" 2>/dev/null || true
        /usr/libexec/PlistBuddy -c "Add :NSPhotoLibraryUsageDescription string 'Photo library access is needed for selecting product images'" "$PLIST" 2>/dev/null || true
        /usr/libexec/PlistBuddy -c "Add :NSLocationWhenInUseUsageDescription string 'Location access is needed for delivery tracking'" "$PLIST" 2>/dev/null || true
        echo -e "${GREEN}  Privacy descriptions added to Info.plist${NC}"
    fi

    echo -e "${GREEN}  iOS platform created for $APP_NAME${NC}"
    echo ""
done

cd "$PROJECT_ROOT"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  iOS Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "  Next steps:"
echo "    1. Open each app in Xcode to configure signing"
echo "    2. Set up Apple Developer certificates"
echo "    3. Configure push notification capabilities"
echo ""
