# Alhai Monorepo - Build Helper
# Requires: flutter, melos (dart pub global activate melos)

.PHONY: bootstrap analyze test format clean build-all

## Install dependencies and bootstrap workspace
bootstrap:
	dart pub global activate melos
	melos bootstrap

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

## Run code generation (Drift, Injectable, Freezed)
codegen:
	melos run codegen

## Build all apps
build-all:
	melos run build:all

## Clean all build artifacts
clean:
	melos run clean

## Check outdated dependencies
deps-check:
	melos run deps:check

## Apply dart fix suggestions
fix:
	melos run fix
