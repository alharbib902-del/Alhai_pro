# Admin Lite -- App Icons

`flutter_launcher_icons` is configured in `pubspec.yaml` but the source icon
assets are **not** committed to the repo. You must provide them before
generating launcher icons.

## Required files

Place these two PNGs in `apps/admin_lite/assets/icons/`:

| File                        | Size         | Purpose                            |
| --------------------------- | ------------ | ---------------------------------- |
| `app_icon.png`              | 1024x1024 px | Main launcher icon (Android / web) |
| `app_icon_foreground.png`   | 1024x1024 px | Android adaptive icon foreground   |

The adaptive-icon background is set to `#FFFFFF` in `pubspec.yaml`. Change it
there if a different background color is desired.

## Generate the launcher icons

From the `apps/admin_lite/` directory:

```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

Or, on newer SDKs:

```bash
dart run flutter_launcher_icons
```

## iOS

iOS is intentionally disabled (`ios: false`) because the iOS runner is not yet
created for `admin_lite`. To enable iOS icon generation:

1. `flutter create --platforms=ios .`
2. Set `ios: true` in the `flutter_launcher_icons:` block of `pubspec.yaml`
3. Uncomment the `ios_content_mode: "scaleAspectFill"` line
4. Re-run `dart run flutter_launcher_icons`

## Notes

- Mirrors the `apps/admin/` config (see `apps/admin/pubspec.yaml`) except that
  the source PNGs live under `assets/icons/` instead of `assets/branding/`.
- The `assets/icons/` directory exists but is empty; add the PNGs there.
