# CI/CD Pipeline - تطبيق نقطة البيع (POS)

هذا المجلد يحتوي على إعدادات GitHub Actions للتكامل والنشر المستمر.

## 📋 الـ Workflows المتوفرة

### 1. Tests (`test.yml`)
**يعمل عند:** push لـ `main`/`develop` أو Pull Request

| Job | الوصف |
|-----|-------|
| `analyze` | فحص الكود وتنسيقه |
| `test` | تشغيل الاختبارات مع تغطية الكود |
| `test-integration` | اختبارات التكامل (PR فقط) |

```bash
# تشغيل محلياً
flutter analyze
flutter test --coverage
```

### 2. Build (`build.yml`)
**يعمل عند:** push لـ `main` أو إنشاء tag أو manually

| Job | المنصة | الشرط |
|-----|--------|-------|
| `build-android` | APK + AAB | دائماً |
| `build-ios` | iOS App | يدوي فقط |
| `build-web` | Web App | دائماً |
| `build-windows` | Windows | tags فقط |

```bash
# تشغيل محلياً
flutter build apk --debug
flutter build web --release
```

### 3. Release (`release.yml`)
**يعمل عند:** إنشاء tag بصيغة `v*`

ينشئ GitHub Release تلقائياً مع:
- Android APK و AAB
- Web build مضغوط
- Windows build مضغوط
- Changelog تلقائي

```bash
# إنشاء إصدار جديد
git tag v1.0.0
git push origin v1.0.0
```

### 4. PR Check (`pr-check.yml`)
**يعمل عند:** فتح أو تحديث Pull Request

| Job | الوصف |
|-----|-------|
| `quality` | فحص جودة الكود |
| `security` | فحص أمني أساسي |
| `test` | الاختبارات والتغطية |
| `build-check` | التحقق من البناء |
| `summary` | ملخص النتائج |

### 5. Dependabot (`dependabot.yml`)
**يعمل:** أسبوعياً (الاثنين 9 صباحاً بتوقيت الرياض)

يفحص ويحدث تلقائياً:
- Flutter/Dart packages
- GitHub Actions

## 🔐 Secrets المطلوبة

للـ builds الكاملة، أضف هذه الـ secrets في GitHub:

### Android Signing
```
ANDROID_KEYSTORE_BASE64    # keystore مشفر بـ base64
ANDROID_KEYSTORE_PASSWORD  # كلمة مرور الـ keystore
ANDROID_KEY_ALIAS          # alias للمفتاح
ANDROID_KEY_PASSWORD       # كلمة مرور المفتاح
```

### Code Coverage
```
CODECOV_TOKEN              # token من codecov.io
```

## 📊 Badges

أضف هذه الـ badges في README الرئيسي:

```markdown
![Tests](https://github.com/USERNAME/pos_app/actions/workflows/test.yml/badge.svg)
![Build](https://github.com/USERNAME/pos_app/actions/workflows/build.yml/badge.svg)
[![codecov](https://codecov.io/gh/USERNAME/pos_app/branch/main/graph/badge.svg)](https://codecov.io/gh/USERNAME/pos_app)
```

## 🚀 إنشاء إصدار جديد

### 1. تحديث الإصدار
```bash
# في pubspec.yaml
version: 1.0.1+2
```

### 2. إنشاء tag
```bash
git add .
git commit -m "chore: bump version to 1.0.1"
git tag v1.0.1
git push origin main --tags
```

### 3. مراقبة البناء
- اذهب لـ Actions tab في GitHub
- راقب workflow الـ Release
- بعد الانتهاء، ستجد الإصدار في Releases

## 🔧 تخصيص الإعدادات

### تغيير إصدار Flutter
في كل workflow، عدّل:
```yaml
env:
  FLUTTER_VERSION: '3.24.0'
```

### إضافة منصات جديدة
1. أضف job جديد في `build.yml`
2. أضف artifact download في `release.yml`

### تعديل جدول Dependabot
عدّل `dependabot.yml`:
```yaml
schedule:
  interval: "daily"  # أو "weekly" أو "monthly"
```

## ⚠️ ملاحظات مهمة

1. **iOS builds** تحتاج macOS runner (مدفوع)
2. **Android signing** يحتاج keystore صحيح للـ release
3. **Codecov** يحتاج حساب وربط Repository
4. **Large files** (>1MB) ستظهر تحذيرات في PR

## 📞 الدعم

للمساعدة:
1. راجع logs الـ workflow
2. تحقق من Secrets
3. تأكد من صحة pubspec.yaml
