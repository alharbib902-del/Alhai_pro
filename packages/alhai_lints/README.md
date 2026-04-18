# alhai_lints

Custom `analyzer`/`custom_lint` rules for the Alhai monorepo.

These lints exist so the Alhai design system (`alhai_design_system`,
`alhai_shared_ui`) stays the single source of truth for UI primitives. A
cross-app audit found **832 direct uses of raw Material widgets**
(`ElevatedButton`, `Card`, `TextField`, ...) scattered across the apps.
This package stops that bleeding: new violations are flagged at analysis
time; existing ones are migrated gradually per-app.

## Rules

### `avoid_direct_material_widgets`  _(severity: WARNING — transitional)_

Flags any direct construction of the following Material widgets in app
`lib/` code and recommends the Alhai wrapper instead:

| Banned widget        | Suggested replacement              |
| -------------------- | ---------------------------------- |
| `ElevatedButton`     | `AlhaiButton` (primary)            |
| `TextButton`         | `AlhaiButton` (text variant)       |
| `OutlinedButton`     | `AlhaiButton` (outlined variant)   |
| `IconButton`         | `AlhaiIconButton`                  |
| `Card`               | `AlhaiCard`                        |
| `TextField`          | `AlhaiTextField`                   |
| `TextFormField`      | `AlhaiTextField` (form variant)    |
| `AlertDialog`        | `AlhaiDialog`                      |
| `SnackBar`           | `AlhaiSnackBar` / `AlhaiToast`     |
| `Chip`               | `AlhaiChip`                        |
| `ListTile`           | `AlhaiListTile`                    |

**Detection strategy**: AST-based `InstanceCreationExpression` visitor. A
user class that happens to share a name (e.g. a locally-defined `Card`
class) is NOT flagged because the rule confirms the resolved type lives in
`package:flutter/src/material/...`.

**Exemptions (auto-skipped by path):**
- `packages/alhai_design_system/**` — the wrapper layer itself.
- `packages/alhai_shared_ui/**` — second-level wrappers that sometimes need
  raw primitives.
- `**/test/**`, `**/test_driver/**`, `**/integration_test/**` — tests may
  need to pump raw widgets.
- `**/*.g.dart`, `**/*.freezed.dart`, `**/*.generated.dart`
- `**/.dart_tool/**`, `**/build/**`

## Apps currently using

_(None yet — opt-in is per-app and not part of this package's landing.)_

## How to enable in an app

1. **Add the dev dependency.** From `apps/<app>/pubspec.yaml`:

   ```yaml
   dev_dependencies:
     alhai_lints:
       path: ../../packages/alhai_lints
     custom_lint: ^0.7.0
   ```

   From a root-level app (`customer_app`, `driver_app`, `super_admin`,
   `distributor_portal`):

   ```yaml
   dev_dependencies:
     alhai_lints:
       path: ../packages/alhai_lints
     custom_lint: ^0.7.0
   ```

2. **Register the plugin in `analysis_options.yaml`.** See
   `analysis_options.yaml.template` in this package, or add directly:

   ```yaml
   analyzer:
     plugins:
       - custom_lint

   custom_lint:
     rules:
       - avoid_direct_material_widgets
   ```

3. `flutter pub get`, then (once) `dart run custom_lint` to verify the
   plugin loads. IDE support is automatic — the Dart analyzer server
   picks up the plugin on the next analysis cycle.

## Suppressing a specific occurrence

During migration you can silence individual call-sites with the standard
custom_lint ignore comment:

```dart
// ignore: avoid_direct_material_widgets
ElevatedButton(onPressed: save, child: const Text('Save')),
```

Prefer migrating to `AlhaiButton` over suppressing.

## Development

Run the rule against the example:

```bash
cd packages/alhai_lints/example
flutter pub get
dart run custom_lint
```

Lint the plugin package itself:

```bash
cd packages/alhai_lints
dart pub get
dart analyze
```

## Roadmap (out of scope for this package's initial landing)

The following rules are good candidates for follow-ups — each is a
separate tightening step:

1. **`enforce_design_system_imports`** — warn on `import
   'package:flutter/material.dart'` in app code, steering everything
   through the `alhai_design_system` / `alhai_shared_ui` barrel exports.
2. **`ban_hardcoded_hex_colors`** — flag `Color(0x...)` and `Colors.*`
   uses outside the theme layer, enforcing `AlhaiColors.*` tokens.
3. **`require_localized_strings`** — flag `Text('literal')` where the
   literal isn't an `l10n.*` / `context.l10n.*` / `AppLocalizations.of(...)`
   call (matches the TODO already noted in `apps/cashier/analysis_options.yaml`).

## Versions

Pinned to match the monorepo's existing transitive resolution:
- `analyzer: >=6.0.0 <9.0.0`
- `analyzer_plugin: >=0.11.0 <0.15.0`
- `custom_lint_builder: ^0.7.0`
- `custom_lint: ^0.7.0`
