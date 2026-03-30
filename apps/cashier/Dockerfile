# ---- Build stage: Flutter Web ----
FROM debian:bookworm-slim AS builder

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git unzip xz-utils zip ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter SDK
ENV FLUTTER_VERSION=3.27.4
ENV FLUTTER_HOME=/opt/flutter
ENV PATH="${FLUTTER_HOME}/bin:${PATH}"

RUN git clone --depth 1 --branch ${FLUTTER_VERSION} https://github.com/flutter/flutter.git ${FLUTTER_HOME} \
    && flutter precache --web \
    && flutter config --no-analytics \
    && dart --disable-analytics

WORKDIR /app

# Copy entire monorepo (needed for path dependencies)
COPY . .

# Fix Windows backslash paths in pubspec_overrides.yaml files for Linux
RUN find /app -name "pubspec_overrides.yaml" -exec sed -i 's|\\\\|/|g' {} + 2>/dev/null; \
    find /app -name "pubspec_overrides.yaml" -exec sed -i 's|\\|/|g' {} + 2>/dev/null; \
    true

# Get dependencies
WORKDIR /app/apps/cashier
RUN flutter pub get

# Build web — environment variables baked in via ARG
ARG SUPABASE_URL=https://jtgwboqushihwvvsdtud.supabase.co
ARG SUPABASE_ANON_KEY
ARG SENTRY_DSN=
ARG WASENDER_API_TOKEN=
ARG WASENDER_DEVICE_ID=
ARG WASENDER_PHONE=
ARG WASENDER_NAME=بقالة الحي
ARG WASENDER_WEBHOOK_SECRET=
ARG ENV=production

RUN flutter build web --release --no-tree-shake-icons \
    --dart-define=SUPABASE_URL=${SUPABASE_URL} \
    --dart-define=SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY} \
    --dart-define=SENTRY_DSN=${SENTRY_DSN} \
    --dart-define=WASENDER_API_TOKEN=${WASENDER_API_TOKEN} \
    --dart-define=WASENDER_DEVICE_ID=${WASENDER_DEVICE_ID} \
    --dart-define=WASENDER_PHONE=${WASENDER_PHONE} \
    --dart-define=WASENDER_NAME=${WASENDER_NAME} \
    --dart-define=WASENDER_WEBHOOK_SECRET=${WASENDER_WEBHOOK_SECRET} \
    --dart-define=ENV=${ENV}

# ---- Serve stage: Nginx ----
FROM nginx:alpine AS runner

# Copy custom nginx config
COPY apps/cashier/nginx.conf /etc/nginx/conf.d/default.conf

# Copy built web app
COPY --from=builder /app/apps/cashier/build/web /usr/share/nginx/html

# Railway uses $PORT env variable
EXPOSE 8080

# Use envsubst to replace PORT at runtime
CMD sh -c "sed -i 's/listen 8080/listen '\"${PORT:-8080}\"'/' /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"
