# Changelog - Cashier (POS)

All notable changes to the Cashier POS app.

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and [Semantic Versioning](https://semver.org/).

## [1.3.0] - 2026-04-24

### Phase 5 — Perfection (10/10 goal)

#### Added
- **Golden test scaffolding** — `test/goldens/` with `golden_config.dart`
  providing `shouldRunGoldens` (Linux-only gate so Windows/macOS dev runs
  skip automatically), standard surface sizes (desktop 1920×1080, tablet
  1024×768, mobile 375×812), and a `goldenTest` wrapper that calls
  `markTestSkipped` off the canonical platform. Seeded with three POS
  empty-cart goldens (light+ar×desktop, dark+ar×desktop, light+en×tablet).
  Full matrix (20 screens × 2 themes × 2 locales × 3 sizes = 240 PNGs)
  expands on CI.
- **Integration tests — already present** (6 flows, 2618 LOC):
  `critical_flow_test`, `direct_sale_flow_test`, `offline_sync_test`,
  `return_flow_test`, `shift_lifecycle_test`, `tax_and_receipt_test`
  with a shared `buildTestApp` harness that stubs Firebase/Supabase.
- **iOS scaffold** (`apps/cashier/ios/`) — `flutter create
  --platforms=ios .` produces the Runner Xcode project, Info.plist with
  `Al-HAI Cashier` display name, `com.alhai.cashier` bundle id, iOS 13.0
  deployment target. README documents the owner-action checklist:
  Apple Developer account, signing, provisioning profile, TestFlight.
- **Performance monitoring** — `tracePerformance<T>` +
  `tracePerformanceSync<T>` helpers in `sentry_service.dart`. Wrap any
  async DB/network/UI work in a Sentry transaction; automatic status +
  exception linking, no-op when DSN absent. Operation taxonomy:
  `db.query`, `db.write`, `http.client`, `ui.render`, `sync.push/pull`.
  `tracesSampleRate` was already 1.0/0.3 (debug/prod); the helpers
  surface transactions consistently across call sites.

#### Infrastructure
- `pubspec.yaml`: `version: 1.3.0+4`, `golden_toolkit: ^0.15.0` dev dep
- iOS scaffolding files (40) added under `apps/cashier/ios/`

#### Testing
- 552/552 cashier tests pass (0 regression across 5 phases)
- 3 golden tests skip on Windows by design (run on CI Linux)
- Analyzer: 0 errors, 1 pre-existing warning (split_receipt unused param)

## [1.2.0] - 2026-04-24

### Phase 4 — Hardening + Polish

#### Added
- **Certificate Pinning (Supabase)** — `CertificatePinningService` from
  `alhai_core` wired in `main.dart`, consumes SHA-256 fingerprints via
  `--dart-define=SUPABASE_CERT_FINGERPRINT_1..10` (N-pin rotation with
  legacy fallback). Web uses BrowserClient (browser handles TLS);
  Android/iOS get full pinning. Debug mode is no-op to support
  mitmproxy/Charles. Graceful degradation if pins missing (logged to
  Sentry as degraded mode).
- **Web DB Encryption Hardening** — `WebDbKeyService` replaces plain
  base64-in-localStorage with AES-GCM key wrapping. The wrappingKey is
  generated as a `CryptoKey` with `extractable=false` and stored in
  IndexedDB — browsers enforce the non-extractable invariant so an XSS
  attack cannot `exportKey()` it. The raw DB key is ciphertext-only in
  localStorage; wrappedKey-ciphertext + IndexedDB-wrapping-key is the
  pairing needed to decrypt. Automatic migration from legacy plain key.
  Falls back to plain localStorage on non-secure contexts / very old
  browsers (with Sentry WARN).
- **SENTRY_DSN wired into CI** — `build-web.yml`, `release.yml`, and
  `release-android.yml` all forward `SENTRY_DSN` + cert-pin fingerprints
  via `--dart-define`. Per-app DSNs on release-android
  (`SENTRY_DSN_CASHIER` / `_ADMIN` / `_ADMIN_LITE`) for multi-app
  scoping.
- **Page Transitions** — every cashier route now uses
  `CustomTransitionPage` with a subtle 5% slide (RTL-aware) + fade at
  200 ms via `_alhaiTransition` in `cashier_router.dart`. Motion curve
  uses `AlhaiMotion.standardDecelerate` for consistency with the design
  system. User toggle "تأثيرات حركية" on the settings screen collapses
  transitions to `Duration.zero` without tearing down the widget tree
  (flag mirrored into the router via `refreshAnimationsFlag()`).
- **Keyboard-First Navigation** — `_CashierShortcutsScope` wraps the
  shell with `CallbackShortcuts` reserving F3/F4/F5/F6/F7/F8 +
  Ctrl+F/D/P + Ctrl+Del + qty adjust keys. `ShortcutsShim.enabled` toggle
  lets touchscreen-only tills disable all bindings without widget-tree
  churn (empty bindings map). `KeyboardShortcutsScreen` documents all
  three categories (POS / Payment / Navigation) with live RTL + theme
  support.
- **Coverage Reporting** — `flutter_ci.yml` runs `melos run
  test:coverage`, merges lcov across all packages, posts per-package
  summary to `GITHUB_STEP_SUMMARY`, uploads to Codecov (when
  `CODECOV_TOKEN` is set — no-op otherwise), and enforces a 60% floor
  via `lcov --summary | awk`. The 60% floor catches regressions while
  the suite matures toward the 85% Phase 5 target.

#### Infrastructure
- `pubspec.yaml`: `version: 1.2.0+3`
- `alhai_core` exports `CertificatePinningService` +
  `SupabaseConfig`; cashier consumes both via the unified `alhai_core`
  barrel (no cross-app copy).
- CSP `report-uri` injection placeholder (`__SENTRY_CSP_REPORT_URI__`)
  substituted at deploy time via `sed` in `deploy_web.yml` — reporting
  endpoint is rotatable without a rebuild.

#### Fixed
- Supabase initialisation now always passes a non-null `httpClient`
  when pinning is active, preventing the SDK from falling back to a
  default client on native (close the pin-bypass hole).

## [1.1.0] - 2026-04-24

### Phase 1 — Critical P0 Fixes (Data Integrity)

#### Added
- `ZatcaComplianceException` — invoice creation now blocks if ZATCA QR
  generation fails (was silently continuing → non-compliant invoices)
- QR code stored directly on `invoices.zatca_qr` + `zatca_uuid` columns
  (previously regenerated on every receipt display)
- Barcode scanner debounce (500 ms) in POS — double-scans add one item
- Realtime listener `deviceId` + fail-fast when `orgId` empty
- Apply Interest: `hasInterestForPeriod()` idempotency check before applying
- Apply Interest: sync-enqueue for `transactions` + `accounts` rows
- Exchange screen: real sale + return flow using `createReturn()` +
  `SaleService.createSale` (was `Future.delayed(1s)` simulated)
- Split receipt breakdown now reads actual `cashAmount/cardAmount/creditAmount`
  from DB (was fake `_buildSplits()` with `**** 4532` hardcoded)

#### Fixed
- **Critical:** invoice with missing ZATCA QR was silently saved
- Split receipt display bug: `order.total.toStringAsFixed(2)` on raw cents
  rendered SAR values 100× inflated
- Apply Interest could double-charge when clicked twice in same month

### Phase 2 — Critical Gaps (UX + Data Guards)

#### Added
- 8 new l10n keys across 7 languages (customerAccounts, paymentHistory,
  keyboardShortcutsHint, proceedToPayment, searchProducts, splitPayment,
  applyDiscount, holdInvoice)
- `HijriDateFormatter` — offline Julian-day based Hijri date conversion
- `CurrencyFormatter.fromCents` / `fromCentsCompact` / `fromCentsWithContext`
  — convenience int-cents overloads to prevent the 100× display bug class
- `ResponsiveDialog.showAlert<T>` — drop-in for `showDialog + AlertDialog`
  that caps width at 560 dp on desktop/tablet
- `SoundService` singleton with `barcodeBeep / saleSuccess / errorBuzz` and
  volume slider (placeholder MP3s — replace before production)
- `HapticShim` wrapper with enabled toggle + web fallback
- `pos_feedback_providers.dart` — 5 override-able feedback hooks so
  `alhai_pos` stays app-layer agnostic
- Cash drawer mismatch now requires mandatory notes (form validator) when
  `difference != 0` — audit trail
- `_hardQueueLimit = 50_000` on sync_queue with 10 high-priority tables
  bypassed (sales, invoices, stock_deltas, transactions, …)
- `PreSyncValidator` engine — 23 rules across 6 tables, 31 tests
  (ZATCA QR required, total-sums-match, qty positive, etc.)

#### Fixed
- Arabic `outstanding` translation was "متميز" (distinguished) — corrected
  to "مستحق" (due/owed) — user-visible bug in customer_accounts filter
- 19 hardcoded `Colors.white / Colors.black` replaced with
  `Theme.of(context).colorScheme.*` so dark mode works correctly
  (receipt/QR paper-preview cases kept with dark-aware alpha)

### Phase 3 — Architectural Cleanup

#### Changed
- **god-class refactoring** (5061 LOC → ~867 container LOC, -83%):
  - `customer_ledger_screen.dart` 1606 → 184 container + 15 widget/provider files
  - `custom_report_screen.dart` 1251 → 9-line bridge + 224 container + 9 files
  - `sales_history_screen.dart` 1148 → 152 container + 6 files
  - `create_invoice_screen.dart` 1056 → 12 bridge + 286 container + 5 files
- **`setState` reduction**: 155 → 10 across 4 screens (-94%). Moved to
  Riverpod `StateNotifier` + `AsyncNotifier` for shared business state.
- `searchProductsPaginated` now FTS5-first with LIKE fallback (5-10× faster
  on 10k+ products, supports Arabic via unicode61 tokenizer)

#### Added
- `alhai_lints` custom analyzer plugin activated (transitional warnings for
  direct Material widget use)
- `tools/schema_drift_checker.dart` — static money/qty column drift check
- `tools/supabase_schema_check.sql` — live DB drift check via SQL Editor
- Supabase migration `v80`: 7 remaining qty columns migrated to
  `DOUBLE PRECISION` (fractional stock support: 2.5 kg rice, 1.3 kg partial
  receipts, etc.) — deployed 2026-04-24 with trigger drop/recreate handling

#### Fixed
- 6 additional 100× display bugs discovered during sales_history refactor
  (summary stats + payment breakdown + mixed-fallback total)

### Infrastructure
- Drift schema and Supabase schema aligned on money columns (live-verified
  via `tools/supabase_schema_check.sql`: `money_drift_count = 0`)
- All qty columns now DOUBLE PRECISION on both sides

### Testing
- 552/552 cashier tests pass (0 regression across 3 phases)
- 389/389 alhai_sync + 589/589 alhai_pos tests pass
- 31 new tests for `PreSyncValidator`
- Existing tests updated for god-class splits (all bridge files preserve API)

## [Unreleased]

### Added
- E2E test suite with Playwright (56 route tests, full coverage)
- 36 extended route tests covering Reports, AI, and Settings screens
- Settings item in sidebar navigation
- Clear cache button in settings screen
- Custom domain `alhai.store` for all services
- AI server integration on Railway (chat, assistant endpoints)
- ZATCA Phase 2 QR code widget on receipts
- Split payment support (cash + multiple cards + credit in one transaction)
- Hold/recall invoice system for pausing and resuming sales
- Keyboard shortcuts for all major POS actions
- Kiosk mode for self-service operation
- Denomination counter for cash drawer management

### Changed
- Standardized responsive breakpoints across 42 screen files
- Arabic font fallback to prevent tofu characters on splash load
- X-Frame-Options changed from SAMEORIGIN to DENY for security
- Simplified login to 2-step flow (phone -> OTP) with background email auth
- Dashboard redesigned to match new design system

### Fixed
- RTL phone number display in login screen
- Dark mode login screen styling
- Store sync initialization after login
- 8 QA bugs: auth flow, data sync, responsive layouts, UX polish
- Offline-first sync engine hardened with 12 critical fixes

### Infrastructure
- Dockerfile and Railway deployment configuration
- GitHub Actions CI/CD: analyze, test, build web/APK
- SQLCipher encryption for local database

## [1.0.0] - 2026-01-25

### Added
- Initial release: 79 screens
- Offline-first POS with Drift (SQLite/WASM)
- Full product catalog with barcode scanning and FTS5 search
- Sales, returns, exchanges, void transactions
- Customer accounts and credit (debt) management
- Shift open/close with cash counting
- Receipt printing and reprinting
- Inventory management (add, remove, transfer, wastage, stock take)
- Reports: daily sales, payment, custom
- Settings: printer, receipt template, tax, barcode, store info
- Multi-language support (7 languages)
- RTL layout support for Arabic
- Dark mode support
