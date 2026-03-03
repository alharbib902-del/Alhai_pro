# Alhai Cashier — Build Helper
# Runs from apps/cashier/

.PHONY: run build-web build-apk test analyze clean

## Run in dev mode (Chrome)
run:
	flutter run -d chrome --dart-define=ENV=dev

## Run in dev mode (Android)
run-android:
	flutter run --dart-define=ENV=dev

## Build web (production)
build-web:
	flutter build web --no-tree-shake-icons --dart-define=ENV=production

## Build web (staging)
build-web-staging:
	flutter build web --no-tree-shake-icons --dart-define=ENV=staging

## Build APK (production)
build-apk:
	flutter build apk --dart-define=ENV=production

## Run tests
test:
	flutter test

## Run analyzer
analyze:
	flutter analyze

## Format code
format:
	dart format .

## Clean build artifacts
clean:
	flutter clean

## Get dependencies
get:
	flutter pub get

## Run code generation (Drift)
codegen:
	dart run build_runner build --delete-conflicting-outputs
