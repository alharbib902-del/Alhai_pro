# Admin App Branding Assets

This directory holds the source images used by `flutter_launcher_icons` to
generate platform-specific launcher icons.

## Required files

| File | Purpose | Spec |
|---|---|---|
| `app_icon.png` | Launcher icon (Android legacy, iOS, Web favicon) | 1024 x 1024 px, PNG, full-bleed logo on opaque background |
| `app_icon_foreground.png` | Adaptive-icon foreground (Android 8+) | 1024 x 1024 px, PNG, logo centered in the inner 66 % safe zone, rest transparent |

## How to add icons

1. Place both PNGs in this directory (`assets/branding/`).
2. Run the generator from the admin app root:

```bash
cd apps/admin
flutter pub get
dart run flutter_launcher_icons
```

## What gets overwritten

- `android/app/src/main/res/mipmap-*/ic_launcher.png` (5 densities)
- `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml` (adaptive)
- `web/favicon.png` and `web/icons/Icon-*.png`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/*` (once iOS is enabled)

## Icon size checklist

For manual inspection, the generator produces these sizes:

| Platform | Sizes (px) |
|---|---|
| Android mdpi | 48 x 48 |
| Android hdpi | 72 x 72 |
| Android xhdpi | 96 x 96 |
| Android xxhdpi | 144 x 144 |
| Android xxxhdpi | 192 x 192 |
| iOS | 20, 29, 40, 58, 60, 76, 80, 87, 120, 152, 167, 180, 1024 |
| Web | 192, 512, favicon 16 x 16 |

## Config

The `flutter_launcher_icons` configuration lives in `pubspec.yaml` under the
`flutter_launcher_icons:` key. iOS generation is currently disabled (`ios: false`)
until the iOS runner project is created -- see `ios/README_IOS_SETUP.md`.

## Verify

After generating, install a debug build and confirm the launcher icon shows
the Alhai logo instead of the default Flutter "f":

```bash
flutter build apk --debug --no-tree-shake-icons
# or
flutter build web --release
```
