#!/usr/bin/env bash
# =============================================================================
# Alhai — driver_app release build
# =============================================================================
# Produces a signed Android App Bundle (AAB) ready for Google Play upload.
# Runs the pre-flight checks first so you get a clean failure early if any
# required credential is missing.
#
# Usage:
#   bash scripts/build_driver_release.sh
#
# Produces:
#   driver_app/build/app/outputs/bundle/release/app-release.aab
#   dist/driver_app-<versionName>-<buildNumber>.aab (copy for upload)
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
APP_DIR="$REPO_ROOT/driver_app"
DIST_DIR="$REPO_ROOT/dist"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

fail() { echo -e "${RED}✗ $1${NC}"; exit 1; }
ok()   { echo -e "${GREEN}✓ $1${NC}"; }
note() { echo -e "${CYAN}• $1${NC}"; }

echo -e "${GREEN}== driver_app release build ==${NC}"
echo ""

# --- Pre-flight ---------------------------------------------------------------

[ -d "$APP_DIR" ] || fail "driver_app directory missing at $APP_DIR"

[ -f "$APP_DIR/android/key.properties" ] \
    || fail "driver_app/android/key.properties missing — run generate_keystores.sh and fill it"

[ -f "$APP_DIR/android/app/google-services.json" ] \
    || note "driver_app/android/app/google-services.json missing — Firebase/FCM will be DISABLED at runtime. Build will still succeed."

command -v flutter >/dev/null || fail "flutter not in PATH"

ok "pre-flight checks passed"
echo ""

# --- Version stamp ------------------------------------------------------------

VERSION_LINE=$(grep -E '^version:' "$APP_DIR/pubspec.yaml" | head -1)
VERSION_RAW=$(echo "$VERSION_LINE" | sed -E 's/^version:\s*//')
VERSION_NAME="${VERSION_RAW%+*}"
BUILD_NUMBER="${VERSION_RAW#*+}"
note "version: $VERSION_NAME (build $BUILD_NUMBER)"
echo ""

# --- Build --------------------------------------------------------------------

cd "$APP_DIR"

note "flutter clean"
flutter clean

note "flutter pub get"
flutter pub get

note "flutter build appbundle --release --obfuscate --split-debug-info=build/symbols"
mkdir -p build/symbols
flutter build appbundle \
    --release \
    --obfuscate \
    --split-debug-info=build/symbols

# --- Copy to dist/ ------------------------------------------------------------

SOURCE_AAB="$APP_DIR/build/app/outputs/bundle/release/app-release.aab"
[ -f "$SOURCE_AAB" ] || fail "AAB missing at expected path: $SOURCE_AAB"

mkdir -p "$DIST_DIR"
DIST_AAB="$DIST_DIR/driver_app-${VERSION_NAME}-${BUILD_NUMBER}.aab"
cp "$SOURCE_AAB" "$DIST_AAB"

ok "built: $DIST_AAB"
ok "debug symbols: $APP_DIR/build/symbols"
echo ""
echo -e "${YELLOW}Next:${NC}"
echo "  1. Upload $DIST_AAB to Play Console (internal testing track first)."
echo "  2. Upload build/symbols/ as native debug symbols (optional, for crash deobfuscation)."
echo "  3. Keep a SECURE backup of driver_app/android/key.properties and the keystore .jks file."
