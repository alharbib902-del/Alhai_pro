# Cashier App -- Android Release Signing Setup

Release builds require a real signing key. Without `android/key.properties`,
the Gradle build will fail with a clear error. Debug builds continue to use the
auto-generated debug keystore and are not affected.

## 1. Generate a keystore

Run from the `apps/cashier/` directory:

```bash
keytool -genkey -v \
  -keystore android/keystore/cashier-release.keystore \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias cashier-release
```

You will be prompted for a store password, key password, and identity fields.
Save the passwords -- you will need them in the next step.

## 2. Create key.properties

Copy the example file:

```bash
cp android/key.properties.example android/key.properties
```

Edit `android/key.properties` and replace the placeholder values:

```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=cashier-release
storeFile=../keystore/cashier-release.keystore
```

`storeFile` is resolved relative to `android/app/`. The path above points to
`android/keystore/cashier-release.keystore`.

## 3. Verify signing

Build a release APK and confirm it is signed with your key:

```bash
flutter build apk --release
```

If `key.properties` is missing or malformed the build will fail with:

> cashier: android/key.properties not found. Release builds require a signing key.

## Security notes

- **Never** commit `key.properties` or `*.keystore` / `*.jks` files.
  They are already listed in `android/.gitignore`.
- Store the keystore and passwords in a secure vault (1Password, Bitwarden, etc.)
  and share them with CI through encrypted secrets.
- The keystore in `android/keystore/` is gitignored via the `**/*.keystore` rule.
