# cashier

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## E2E Test Commands

- `npm run test:critical` - critical cashier flows.
- `npm run test:high` - high-priority modules/routes.
- `npm run test:medium` - medium-priority modules/routes.
- `npm run test:cashier:all` - run all priority groups.
- `npm run test:full` - runs Dart unit tests + all Playwright priority tests.

## PowerShell Runners

- `.\scripts\run-cashier-tests.ps1 -Priority all -BaseUrl http://localhost:5000`
- `.\scripts\run-cashier-full-suite.ps1 -BaseUrl http://localhost:5000`
