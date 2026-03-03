#!/bin/bash
# deploy-staging.sh - Build and deploy all Alhai web apps to Vercel
# Usage: bash scripts/deploy-staging.sh [cashier|admin|admin_lite|all]

set -e

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
AI_SERVER_URL="${AI_SERVER_URL:-https://alhai-ai.up.railway.app}"
ENV="${DEPLOY_ENV:-staging}"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${BLUE}[deploy]${NC} $1"; }
success() { echo -e "${GREEN}[done]${NC} $1"; }
error() { echo -e "${RED}[error]${NC} $1"; exit 1; }

# Build a Flutter web app
build_app() {
  local app_name=$1
  local app_path=$2

  log "Building $app_name..."
  cd "$ROOT_DIR/$app_path"

  flutter build web --release --no-tree-shake-icons \
    --dart-define=ENV=$ENV \
    --dart-define=AI_SERVER_URL=$AI_SERVER_URL

  # Add vercel.json for SPA routing
  cat > build/web/vercel.json << 'EOF'
{
  "rewrites": [{ "source": "/(.*)", "destination": "/index.html" }],
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        { "key": "X-Content-Type-Options", "value": "nosniff" },
        { "key": "X-Frame-Options", "value": "DENY" },
        { "key": "Referrer-Policy", "value": "strict-origin-when-cross-origin" }
      ]
    },
    {
      "source": "/flutter_service_worker.js",
      "headers": [
        { "key": "Cache-Control", "value": "no-cache" }
      ]
    }
  ]
}
EOF

  success "$app_name built successfully"
  cd "$ROOT_DIR"
}

# Deploy to Vercel
deploy_app() {
  local app_name=$1
  local app_path=$2
  local project_name="alhai-$app_name"

  log "Deploying $app_name to Vercel..."
  cd "$ROOT_DIR/$app_path/build/web"

  vercel --prod --yes

  success "$app_name deployed!"
  cd "$ROOT_DIR"
}

# Bootstrap melos first
bootstrap() {
  log "Bootstrapping workspace..."
  cd "$ROOT_DIR"
  dart pub global activate melos 2>/dev/null || true
  melos bootstrap
  success "Workspace bootstrapped"
}

# Main
TARGET="${1:-all}"

log "=== Alhai Staging Deployment ==="
log "Target: $TARGET"
log "ENV: $ENV"
log "AI Server: $AI_SERVER_URL"
echo ""

# Bootstrap workspace
bootstrap

case $TARGET in
  cashier)
    build_app "cashier" "apps/cashier"
    deploy_app "cashier" "apps/cashier"
    ;;
  admin)
    build_app "admin" "apps/admin"
    deploy_app "admin" "apps/admin"
    ;;
  admin_lite)
    build_app "admin_lite" "apps/admin_lite"
    deploy_app "admin_lite" "apps/admin_lite"
    ;;
  all)
    # Build all apps
    build_app "cashier" "apps/cashier"
    build_app "admin" "apps/admin"
    build_app "admin_lite" "apps/admin_lite"

    # Deploy all apps
    deploy_app "cashier" "apps/cashier"
    deploy_app "admin" "apps/admin"
    deploy_app "admin_lite" "apps/admin_lite"
    ;;
  *)
    error "Unknown target: $TARGET. Use: cashier, admin, admin_lite, or all"
    ;;
esac

echo ""
success "=== Deployment Complete ==="
