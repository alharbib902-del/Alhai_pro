## Admin app branding assets

Drop these two files here, then run the generator:

| File | Purpose | Spec |
|---|---|---|
| `app_icon.png` | Main launcher icon (Android legacy + Web favicon) | 1024x1024, PNG with transparency, full‑bleed logo |
| `app_icon_foreground.png` | Adaptive‑icon foreground (Android 8+) | 1024x1024, PNG, logo centered inside the inner 66% safe zone, rest transparent |

### Generate

```
cd apps/admin
flutter pub get
dart run flutter_launcher_icons
```

This overwrites:
- `android/app/src/main/res/mipmap-*/ic_launcher.png` (5 densities)
- `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml` (adaptive)
- `web/favicon.png` and `web/icons/Icon-*.png`

### Config

Lives in `pubspec.yaml` under the `flutter_launcher_icons:` section. iOS is disabled until the iOS project is created.

### Verify

```
flutter build apk --debug --no-tree-shake-icons
```

Install the APK and check the launcher — the Flutter "f" should be gone.
