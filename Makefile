# Alhai Monorepo - Build Helper
# Requires: flutter, melos (dart pub global activate melos)

.PHONY: bootstrap analyze test format clean build-all lint \
        build-all-web build-all-mobile \
        build-customer-apk build-driver-apk \
        build-distributor-web build-super-admin-web \
        ai-dev ai-test db-migrate db-reset

# ─── Setup ───────────────────────────────────────────────────────────────────

## Install dependencies and bootstrap workspace
bootstrap:
	dart pub global activate melos
	melos bootstrap

# ─── Quality ─────────────────────────────────────────────────────────────────

## Run static analysis across all packages
analyze:
	melos run analyze

## Run tests across all packages
test:
	melos run test

## Run tests with coverage
test-coverage:
	melos run test:coverage

## Format all Dart code
format:
	melos run format

## Check formatting (CI)
format-check:
	melos run format:check

## Run both format-check and analyze (CI lint gate)
lint: format-check analyze

## Run code generation (Drift, Injectable, Freezed)
codegen:
	melos run codegen

## Apply dart fix suggestions
fix:
	melos run fix

## Check outdated dependencies
deps-check:
	melos run deps:check

# ─── Build: Individual Apps ──────────────────────────────────────────────────

## Build Cashier APK
build-cashier-apk:
	cd apps/cashier && flutter build apk --release

## Build Admin Web
build-admin-web:
	cd apps/admin && flutter build web --release --no-tree-shake-icons

## Build Admin Lite APK
build-lite-apk:
	cd apps/admin_lite && flutter build apk --release

## Build Customer App APK
build-customer-apk:
	cd customer_app && flutter build apk --release

## Build Driver App APK
build-driver-apk:
	cd driver_app && flutter build apk --release

## Build Distributor Portal Web
build-distributor-web:
	cd distributor_portal && flutter build web --release --no-tree-shake-icons

## Build Super Admin Web
build-super-admin-web:
	cd super_admin && flutter build web --release --no-tree-shake-icons

# ─── Build: Aggregate ────────────────────────────────────────────────────────

## Build all web apps (admin, admin_lite, cashier, super_admin, distributor_portal)
build-all-web: build-admin-web build-distributor-web build-super-admin-web
	cd apps/admin_lite && flutter build web --release --no-tree-shake-icons
	cd apps/cashier && flutter build web --release --no-tree-shake-icons

## Build all mobile APKs (cashier, admin_lite, customer_app, driver_app)
build-all-mobile: build-cashier-apk build-lite-apk build-customer-apk build-driver-apk

## Build all apps
build-all: build-all-web build-all-mobile

# ─── AI Server ───────────────────────────────────────────────────────────────

## Run AI server locally
ai-dev:
	cd ai_server && uvicorn main:app --reload

## Run AI server tests
ai-test:
	cd ai_server && pytest

# ─── Database ────────────────────────────────────────────────────────────────

## Run Supabase migrations
db-migrate:
	npx supabase db push

## Reset local database
db-reset:
	npx supabase db reset

# ─── Clean ───────────────────────────────────────────────────────────────────

## Clean all build artifacts
clean:
	melos run clean
