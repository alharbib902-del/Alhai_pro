# P1 Cleanup Report - Pre-Phase-2 Quick Fixes

## Fix A: Backslash Paths in pubspec_overrides.yaml

**Problem:** Windows backslashes (`\`) in path dependencies break cross-platform builds and CI/CD pipelines.

**Scope:** All 15 `pubspec_overrides.yaml` files across the monorepo.

**Before:**
```yaml
alhai_core:
  path: ..\..\alhai_core
```

**After:**
```yaml
alhai_core:
  path: ../../alhai_core
```

**Files fixed (15):**
- `apps/admin/pubspec_overrides.yaml`
- `apps/admin_lite/pubspec_overrides.yaml`
- `apps/cashier/pubspec_overrides.yaml`
- `alhai_services/pubspec_overrides.yaml`
- `customer_app/pubspec_overrides.yaml`
- `distributor_portal/pubspec_overrides.yaml`
- `driver_app/pubspec_overrides.yaml`
- `packages/alhai_ai/pubspec_overrides.yaml`
- `packages/alhai_auth/pubspec_overrides.yaml`
- `packages/alhai_database/pubspec_overrides.yaml`
- `packages/alhai_pos/pubspec_overrides.yaml`
- `packages/alhai_reports/pubspec_overrides.yaml`
- `packages/alhai_shared_ui/pubspec_overrides.yaml`
- `packages/alhai_sync/pubspec_overrides.yaml`
- `super_admin/pubspec_overrides.yaml`

**Verification:** `flutter pub get` succeeded for admin, admin_lite, and cashier apps.

---

## Fix B: Unify intl Version

**Problem:** Mixed `intl` version constraints across pubspec.yaml files.

**Before:**
| Constraint | Count | Files |
|------------|-------|-------|
| `any` | 7 | admin, cashier, admin_lite, etc. |
| `^0.20.2` | 1 | customer_app |
| `>=0.19.0 <1.0.0` | 4 | alhai_pos, alhai_reports, alhai_shared_ui, alhai_zatca |

**After:** All 12 files declare `intl: any`.

**Why `any` instead of `^0.19.0`:**
- The resolved version is **0.20.2** across all packages
- `^0.19.0` in Dart means `>=0.19.0 <0.20.0`, which would **exclude** 0.20.2 and break resolution
- `any` is Flutter's own convention for SDK-coupled packages like intl
- The Flutter SDK constraint controls the actual version — explicit pinning adds friction without benefit

**Verification:**
- `flutter pub get` succeeded for all modified packages
- `flutter test` on alhai_l10n: **124 passed**, 0 failed
- `flutter test` on alhai_reports: **123 passed**, 0 failed

---

## Commits

| Hash | Message |
|------|---------|
| `6d4ca05` | fix: replace backslash paths with forward slashes in all pubspec_overrides.yaml |
| `e57f864` | chore: unify intl version constraint to 'any' across all packages |
