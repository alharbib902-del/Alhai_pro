# Fix 05 — Sentry Crash Reporting Integration
## Date: 2026-03-01

### Summary
Integrated `sentry_flutter` for crash reporting, error tracking, and navigation observability across the entire cashier app. All 80+ catch blocks now report to Sentry. Key business operations have breadcrumbs for debugging context.

### Changes Made

#### 1. Package Added
- `sentry_flutter: ^9.14.0` via `flutter pub add sentry_flutter`

#### 2. New File Created
- `lib/core/services/sentry_service.dart` — Centralized Sentry helper:
  - `initSentry({appRunner})` — Wraps app with `SentryFlutter.init`, DSN from `--dart-define=SENTRY_DSN`
  - `reportError(exception, {stackTrace, hint})` — Reports to Sentry + debugPrint in debug mode
  - `addBreadcrumb({message, category, level, data})` — Adds context breadcrumbs
  - Gracefully skips Sentry when no DSN configured (offline/dev mode)

#### 3. main.dart — Core Error Handlers Rewired
- Removed `runZonedGuarded` wrapper — replaced with `initSentry(appRunner: ...)` which handles zone guarding internally
- `FlutterError.onError` → now calls `reportError()` instead of `debugPrint()`
- `PlatformDispatcher.instance.onError` → now calls `reportError()` instead of `debugPrint()`
- Firebase init catch → `reportError(e, stackTrace: stack, hint: 'Firebase init')`
- Supabase init catch → `reportError(e, stackTrace: stack, hint: 'Supabase init')`
- CSV seeding catch → `reportError(e, stackTrace: stack, hint: 'CSV seeding')`
- Added lifecycle breadcrumb: `'App initialized'`

#### 4. GoRouter — Navigator Observer
- `SentryNavigatorObserver()` added to `GoRouter(observers: [...])` in `cashier_router.dart`
- Automatically tracks screen transitions for Sentry breadcrumbs

#### 5. All Catch Blocks Updated (41 files, ~80+ catch blocks)
Every `catch (e)` and `catch (_)` changed to `catch (e, stack)` with `reportError(e, stackTrace: stack, hint: '...')` added.

| Category | Files Updated | Catch Blocks |
|----------|--------------|--------------|
| Inventory screens | 6 | 13 |
| Customer screens | 5 | 9 |
| Payment screens | 4 | 7 |
| Sales screens | 3 | 6 |
| Products screens | 5 | 11 |
| Offers screens | 3 | 3 |
| Shifts screens | 3 | 3 |
| Settings screens | 7 | 12 |
| Reports screens | 2 | 2 |
| Purchases screens | 2 | 7 |
| Data/repositories | 1 | 1 |
| main.dart | 1 | 5 |
| **Total** | **42** | **~79** |

#### 6. Breadcrumbs Added for Key Operations

| Operation | File | Category |
|-----------|------|----------|
| App initialized | main.dart | lifecycle |
| Database seeding | main.dart | data |
| Shift opened | shift_open_screen.dart | shift |
| Shift closed | shift_close_screen.dart | shift |
| Cash deposit/withdrawal | cash_in_out_screen.dart | shift |
| Invoice created/drafted | create_invoice_screen.dart | sale |
| Exchange completed | exchange_screen.dart | sale |
| Refund processed | split_refund_screen.dart | payment |
| Receipt printed | split_receipt_screen.dart | sale |
| Customer transaction | new_transaction_screen.dart | payment |
| Backup completed | backup_screen.dart | backup |
| Restore completed | backup_screen.dart | backup |

### Configuration
To enable Sentry in production, pass DSN at build time:
```bash
flutter run --dart-define=SENTRY_DSN=https://xxx@xxx.ingest.sentry.io/xxx
flutter build apk --dart-define=SENTRY_DSN=https://xxx@xxx.ingest.sentry.io/xxx
flutter build web --no-tree-shake-icons --dart-define=SENTRY_DSN=https://xxx@xxx.ingest.sentry.io/xxx
```

Without `SENTRY_DSN`, the app runs normally — Sentry is silently skipped.

### Verification
- `flutter analyze`: 0 errors, 0 warnings (64 pre-existing info-level notes unrelated to this change)
- All imports verified across 42 modified files
- No breaking changes to existing functionality
