# =============================================================================
# Distributor Portal – Multi-stage Docker build
# =============================================================================
# Stage 1: Build Flutter web app
# Stage 2: Serve with nginx:alpine
#
# Build:
#   docker build -t alhai-distributor \
#     --build-arg SUPABASE_ANON_KEY=<key> \
#     --build-arg SENTRY_DSN_DISTRIBUTOR=<dsn> \
#     -f distributor_portal/Dockerfile .
#
# Run:
#   docker run -p 8080:8080 alhai-distributor
#   docker run -p 3000:3000 -e PORT=3000 alhai-distributor   # Railway / custom port
# =============================================================================

# ---- Stage 1: Build ----
FROM debian:bookworm-slim AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git unzip xz-utils zip ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter SDK
ENV FLUTTER_VERSION=3.38.7
ENV FLUTTER_HOME=/opt/flutter
ENV PATH="${FLUTTER_HOME}/bin:${PATH}"

RUN git clone --depth 1 --branch ${FLUTTER_VERSION} https://github.com/flutter/flutter.git ${FLUTTER_HOME} \
    && flutter precache --web \
    && flutter config --no-analytics \
    && dart --disable-analytics

WORKDIR /app

# Copy entire monorepo (needed for path dependencies: alhai_core, alhai_design_system, etc.)
COPY . .

# Fix Windows backslash paths in pubspec_overrides.yaml for Linux builds
RUN find /app -name "pubspec_overrides.yaml" -exec sed -i 's|\\\\|/|g' {} + 2>/dev/null; \
    find /app -name "pubspec_overrides.yaml" -exec sed -i 's|\\|/|g' {} + 2>/dev/null; \
    true

# Get dependencies
WORKDIR /app/distributor_portal
RUN flutter pub get

# Build web — environment variables baked in via ARG
# NOTE: variable names MUST match what the Dart code reads via String.fromEnvironment.
#   - SENTRY_DSN_DISTRIBUTOR → lib/core/services/sentry_service.dart
#   - FLAVOR (dev|staging|prod) → matches .env.example
ARG SUPABASE_URL=https://jtgwboqushihwvvsdtud.supabase.co
ARG SUPABASE_ANON_KEY
ARG SENTRY_DSN_DISTRIBUTOR=
ARG FLAVOR=prod

# Obfuscate Dart identifiers, split debug symbols, disable source maps.
# Symbols are discarded after the build since this image ships to end users;
# use the CI workflow if you need to retain them for Sentry symbolication.
RUN flutter build web --release --no-tree-shake-icons \
    --obfuscate \
    --split-debug-info=/tmp/symbols \
    --no-source-maps \
    --dart-define=SUPABASE_URL=${SUPABASE_URL} \
    --dart-define=SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY} \
    --dart-define=SENTRY_DSN_DISTRIBUTOR=${SENTRY_DSN_DISTRIBUTOR} \
    --dart-define=FLAVOR=${FLAVOR}

# ---- Stage 2: Serve ----
FROM nginx:alpine AS runner

# Install curl for healthcheck
RUN apk add --no-cache curl

# Copy custom nginx config
COPY distributor_portal/nginx.conf /etc/nginx/conf.d/default.conf

# Copy built web app from builder
COPY --from=builder /app/distributor_portal/build/web /usr/share/nginx/html

# ── Run as non-root (UID 101 = nginx user from nginx:alpine) ──
# nginx:alpine already has the `nginx` user. We adjust ownership of
# directories nginx writes to and switch to that user.
RUN chown -R nginx:nginx /usr/share/nginx/html /var/cache/nginx /var/log/nginx /etc/nginx/conf.d \
    && touch /var/run/nginx.pid \
    && chown nginx:nginx /var/run/nginx.pid
USER nginx

# Default port (Railway, Render, etc. set PORT at runtime)
EXPOSE 8080

# Healthcheck — Docker/k8s/Cloud Run will mark unhealthy if this fails
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -fsS "http://localhost:${PORT:-8080}/healthz" || exit 1

# Replace port at runtime to support platforms that inject PORT env var
CMD sh -c "sed -i 's/listen 8080/listen '\"${PORT:-8080}\"'/' /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"
