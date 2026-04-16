# Admin App -- Android Release Signing Setup

Release builds require a real signing key. Without `android/key.properties`,
the Gradle build will fail with a clear error. Debug builds continue to use the
auto-generated debug keystore and are not affected.

## 1. Generate a keystore

Run from the `apps/admin/` directory:

```bash
keytool -genkey -v \
  -keystore android/keystore/admin-release.keystore \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias admin-release
```

You will be prompted for a store password, key password, and identity fields.
Save the passwords -- you will need them in the next step.

## 2. Create key.properties

Copy the example file (create it if it does not yet exist, mirroring
`apps/cashier/android/key.properties.example`):

```bash
cp android/key.properties.example android/key.properties
```

Edit `android/key.properties` and replace the placeholder values:

```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=admin-release
storeFile=../keystore/admin-release.keystore
```

`storeFile` is resolved relative to `android/app/`. The path above points to
`android/keystore/admin-release.keystore`.

## 3. Verify `android/app/build.gradle.kts`

`build.gradle.kts` should load `key.properties` and wire it into
`signingConfigs.release`. The expected pattern (same as the cashier app):

```kotlin
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
} else {
    throw GradleException(
        "admin: android/key.properties not found. Release builds require a signing key."
    )
}

android {
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

If `key.properties` is missing or malformed the build will fail with:

> admin: android/key.properties not found. Release builds require a signing key.

## 4. Verify signing

Build a release APK and confirm it is signed with your key:

```bash
flutter build apk --release
```

## 5. CI secrets

For CI builds, store the following as encrypted repository secrets and write
them into `android/key.properties` at build time:

- `ADMIN_KEYSTORE_BASE64`   -- base64-encoded `admin-release.keystore`
- `ADMIN_KEYSTORE_PASSWORD` -- value of `storePassword`
- `ADMIN_KEY_PASSWORD`      -- value of `keyPassword`
- `ADMIN_KEY_ALIAS`         -- value of `keyAlias` (e.g. `admin-release`)

A typical GitHub Actions step:

```yaml
- name: Decode keystore
  run: |
    echo "${{ secrets.ADMIN_KEYSTORE_BASE64 }}" | base64 -d \
      > apps/admin/android/keystore/admin-release.keystore

- name: Write key.properties
  run: |
    cat > apps/admin/android/key.properties <<EOF
    storePassword=${{ secrets.ADMIN_KEYSTORE_PASSWORD }}
    keyPassword=${{ secrets.ADMIN_KEY_PASSWORD }}
    keyAlias=${{ secrets.ADMIN_KEY_ALIAS }}
    storeFile=../keystore/admin-release.keystore
    EOF
```

## Security notes

- **Never** commit `key.properties` or `*.keystore` / `*.jks` files.
  Confirm they are listed in `android/.gitignore` (matches the cashier app).
- Store the keystore and passwords in a secure vault (1Password, Bitwarden, etc.)
  and share them with CI only through encrypted secrets.
- The keystore in `android/keystore/` should be gitignored via a `**/*.keystore`
  rule.
