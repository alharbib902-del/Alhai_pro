# Changelog

## 0.1.0

- Initial release.
- New rule: `avoid_direct_material_widgets` (WARNING) — flags direct
  construction of `ElevatedButton`, `TextButton`, `OutlinedButton`,
  `IconButton`, `Card`, `TextField`, `TextFormField`, `AlertDialog`,
  `SnackBar`, `Chip`, `ListTile` in app code. Suggests the matching
  `alhai_design_system` wrapper.
- Skips `alhai_design_system` / `alhai_shared_ui` sources, tests,
  generated Dart, and build outputs.
- Opt-in per-app via `custom_lint` plugin registration — no apps are
  enrolled by this package landing.
