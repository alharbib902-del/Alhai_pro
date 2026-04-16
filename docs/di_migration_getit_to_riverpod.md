# DI Migration Plan: GetIt → Riverpod

**Status:** PLAN ONLY — no code changes yet.
**Author:** Architecture
**Date:** 2026-04-17
**Scope:** Consolidate dual DI (GetIt + Riverpod) down to Riverpod-only across the Alhai monorepo.

---

## 1. Why migrate

Today the monorepo uses **both** dependency-injection systems:

- `alhai_core/lib/src/di/providers.dart` maintains ~16 **GetIt** registrations plus a **Riverpod** bridge.
- Newer packages (`alhai_sync`, `alhai_ai`, `super_admin`, `driver_app`, `distributor_portal`) are **Riverpod-native**.
- Some legacy packages (`alhai_auth`, `alhai_database`, `alhai_reports`) reach into GetIt via `getIt<T>()`.

Pain points:

1. **Test isolation** — GetIt is a global singleton; overriding a type in one test leaks into the next unless `GetIt.I.reset()` is called explicitly. Riverpod's `ProviderContainer` gives clean per-test isolation.
2. **Startup order** — GetIt requires `registerSingleton<X>()` to run before any consumer calls `getIt<X>()`. Miss the order and you get a stringly-typed runtime error. Riverpod gives a lazy graph: a provider is instantiated only when first `watch`ed.
3. **Override surface** — production vs test wiring with GetIt means `registerFactory` + conditional `reset` + environment flags. With Riverpod, `ProviderScope(overrides: [...])` is one line.
4. **Code duplication** — every new dependency today needs to be declared in both worlds (register in GetIt + expose via a `Provider`). That's the root cause of `alhai_core/lib/src/di/providers.dart` being the widest single file.

## 2. Inventory — what uses GetIt today

Grep target: `\bgetIt\s*<` and `GetIt.I` and `locator<`.

| File | Consumer | Type accessed |
|------|----------|---------------|
| `alhai_core/lib/src/di/providers.dart` | — | Registers 16 types |
| `alhai_auth/lib/src/providers/auth_providers.dart` | auth | `SupabaseClient`, `SecureStorageService` |
| `alhai_auth/lib/src/services/whatsapp_otp_service.dart` | auth | `Dio` |
| `alhai_database/lib/src/daos/*` | various | `AppDatabase` (singleton) |
| `alhai_reports/lib/src/services/reports_service.dart` | reports | `AppDatabase`, `SupabaseClient` |
| `alhai_services/**` | — | DELETED in 2026-04-17 session |

**Exact list** — regenerate with:
```
grep -rn "getIt<\|GetIt.I\|locator<" --include="*.dart" .
```

## 3. Target architecture

Every dependency lives behind a **Riverpod `Provider`** in one of three tiers:

1. **Foundation providers** (in `alhai_core/lib/src/di/foundation_providers.dart`, new):
   - `supabaseClientProvider` — the one Supabase client per app flavor
   - `appDatabaseProvider` — lazy-opened Drift database
   - `sharedPrefsProvider` — `SharedPreferences` instance
   - `secureStorageProvider` — `FlutterSecureStorage`
   - `dioProvider` — HTTP client (pre-wired with auth interceptor)

2. **Service providers** (co-located with each service):
   - e.g. `alhai_auth/lib/src/providers/whatsapp_otp_service_provider.dart`
   - Pattern: `final fooServiceProvider = Provider<FooService>((ref) => FooService(ref.watch(depA), ref.watch(depB)));`

3. **Feature providers** (per app): unchanged — they already use Riverpod.

## 4. Migration strategy — strangler fig

**Do NOT** delete `alhai_core/di/providers.dart` in one go. Strangle gradually:

### Phase A — foundation first (1 PR)
Introduce `foundation_providers.dart` with the 5 root providers. Keep GetIt registrations alive and have them read FROM Riverpod on first call:

```dart
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// In the GetIt shim (transitional):
GetIt.I.registerLazySingleton<SupabaseClient>(
  () => ProviderContainer().read(supabaseClientProvider),
);
```

Now both DI systems resolve to the same instance. No consumer changes needed.

### Phase B — migrate one service per PR (5-10 PRs)
For each GetIt-consuming file:
1. Find the `getIt<X>()` call.
2. Convert the enclosing function/widget to consume `ref.watch(xProvider)`.
3. If the function isn't in a Riverpod-aware context (e.g. a legacy service constructor), accept `Ref` as a parameter and delete the GetIt call.
4. Run analyzer + touched tests.

Order (least to most dependent):
1. `whatsapp_otp_service.dart` (Dio only)
2. `secure_storage` consumers in `alhai_auth`
3. `alhai_reports` services
4. `alhai_database` DAO `AppDatabase` accessor (largest blast radius)

### Phase C — remove the shim (final PR)
Once every `grep getIt<` in the monorepo returns zero:
1. Delete the `GetIt.I.registerLazySingleton(...)` shims.
2. Delete `get_it` from `pubspec.yaml` of every package that no longer needs it.
3. Delete `alhai_core/lib/src/di/providers.dart` or shrink it to Riverpod-only helpers.
4. Update the dependency_map memory note.

## 5. Testing strategy

- **Foundation provider tests** (Phase A) — write one `test/di_foundation_test.dart` that verifies every foundation provider returns a singleton within one container.
- **Per-service migration PRs** (Phase B) — each PR adds or updates a ProviderScope-based widget test covering the new wiring. Also runs the package's existing test suite to catch regressions.
- **Analyzer gate** — every PR must leave `flutter analyze` clean on the packages it touches.

## 6. Risk register

| # | Risk | Severity | Mitigation |
|---|------|----------|------------|
| 1 | Mid-migration: a service is registered in BOTH GetIt and Riverpod but they resolve to different instances (e.g. different `SupabaseClient` init paths). | **High** | Foundation providers always delegate to the existing GetIt-created instance in Phase A. Only remove the GetIt instance once the Riverpod provider is the sole source. |
| 2 | Tests that call `GetIt.I.reset()` in `setUp` will no longer isolate state once the Riverpod shim replaces GetIt. | Medium | Each migrated test file converts to `ProviderScope(overrides: [...])`. Track this per-package as Phase B lands. |
| 3 | A consumer imports `package:get_it/get_it.dart` purely for the type (not the singleton). | Low | Grep `import.*get_it` — expect zero after Phase C. |
| 4 | `alhai_ai` uses GetIt optionally under a flag. | Low | Confirmed not the case (grep clean). |

## 7. Estimated cost

- Phase A: ~1 day (one small PR).
- Phase B: ~5-8 PRs, each 0.5-1 day. Spread across sprints so review stays manageable.
- Phase C: ~0.5 day cleanup + docs.

Total: ~5-10 eng days, but parallelizable by package. No forced-upgrade release needed — every phase is backward-compatible.

## 8. Out of scope

- Replacing Riverpod with a different DI framework.
- Migrating widget tree `Provider` / `ChangeNotifierProvider` patterns — they already coexist with Riverpod and are independent.
- Rewriting `GetIt.I.reset()`-heavy test fixtures before their consumers migrate.
