# Admin POS Lite - Step 001: Foundation

> **المرحلة:** Phase 0-1 | **المدة:** أسبوع | **الأولوية:** P0

---

## 🎯 الهدف

تجهيز أساس التطبيق الخفيف:
- Flutter Mobile-Only
- Biometric auth
- Push notifications
- تكامل مع الحزم المشتركة

---

## 📋 المهام

### SETUP-001: Project setup (6h)

```bash
cd admin_pos_lite
flutter pub get

flutter pub add flutter_riverpod go_router
flutter pub add local_auth  # Biometric
flutter pub add firebase_messaging
flutter pub add flutter_local_notifications
```

### SETUP-006: Biometric Auth (2h)

```dart
final localAuth = LocalAuthentication();

Future<bool> authenticateWithBiometrics() async {
  return await localAuth.authenticate(
    localizedReason: 'تسجيل الدخول السريع',
    options: AuthenticationOptions(
      biometricOnly: true,
      stickyAuth: true,
    ),
  );
}
```

### AUTH-002: Login (8h)

**Route:** `/login`

- Phone + OTP
- Fingerprint/Face ID
- Remember me
- Auto-login if saved

---

## ✅ معايير الإنجاز

- [ ] `flutter run` على iOS/Android
- [ ] Biometric auth يعمل
- [ ] FCM متصل
- [ ] alhai_core مستخدم

---

## 📚 المراجع

- [PROD.json](../PROD.json) - SETUP-*, AUTH-*
- [ADMIN_LITE_SPEC.md](../ADMIN_LITE_SPEC.md) - Tech Stack
