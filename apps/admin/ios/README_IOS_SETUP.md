# iOS Setup for Alhai Admin

The admin app does not yet have a generated iOS runner project.
Manually crafting `Runner.xcodeproj/project.pbxproj` is fragile, so the
recommended path is to let Flutter generate the scaffolding and then apply
the project-specific settings listed below.

## 1. Generate the iOS project

From the **admin app root** (`apps/admin/`):

```bash
flutter create --platforms=ios .
```

This creates `ios/` with `Runner.xcodeproj`, `Runner/`, `Flutter/`, etc.

## 2. Set bundle identifier

Open `ios/Runner.xcodeproj/project.pbxproj` (or use Xcode) and replace
every occurrence of the auto-generated bundle ID with:

```
com.alhai.admin
```

Alternatively, open the project in Xcode and change it in
**Runner > Signing & Capabilities > Bundle Identifier**.

## 3. Set display name

Edit `ios/Runner/Info.plist` and set:

```xml
<key>CFBundleDisplayName</key>
<string>Alhai Admin</string>

<key>CFBundleName</key>
<string>admin</string>
```

## 4. Orientation support (iPad + iPhone)

The admin dashboard benefits from landscape on iPad. Ensure
`ios/Runner/Info.plist` contains:

```xml
<key>UISupportedInterfaceOrientations</key>
<array>
    <string>UIInterfaceOrientationPortrait</string>
    <string>UIInterfaceOrientationLandscapeLeft</string>
    <string>UIInterfaceOrientationLandscapeRight</string>
</array>
<key>UISupportedInterfaceOrientations~ipad</key>
<array>
    <string>UIInterfaceOrientationPortrait</string>
    <string>UIInterfaceOrientationPortraitUpsideDown</string>
    <string>UIInterfaceOrientationLandscapeLeft</string>
    <string>UIInterfaceOrientationLandscapeRight</string>
</array>
```

## 5. Enable launcher icons for iOS

In `pubspec.yaml`, change the flutter_launcher_icons iOS line from:

```yaml
ios: false
```

to:

```yaml
ios: true
```

Then regenerate icons:

```bash
dart run flutter_launcher_icons
```

## 6. CocoaPods

After generating the iOS project, install pods:

```bash
cd ios
pod install
```

## 7. Verify

```bash
flutter build ios --release --no-codesign
```

If this succeeds without errors, the iOS runner is correctly configured.

## 8. Signing (production)

For App Store distribution you will need:
- An Apple Developer account
- A distribution certificate (`.p12`)
- A provisioning profile matching `com.alhai.admin`

The existing CI workflow at `.github/workflows/build-ios.yml` handles
certificate import; you just need to add `admin` to the matrix once the
iOS directory is committed.
