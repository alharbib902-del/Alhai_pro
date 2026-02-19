# Security Configuration Guide

## Environment Variables

يجب تمرير المتغيرات الحساسة عبر `--dart-define` عند البناء.

### متغيرات مطلوبة

```bash
# WhatsApp OTP Service (WaSender)
WASENDER_API_TOKEN=your_api_token_here
WASENDER_DEVICE_ID=your_device_id
WASENDER_PHONE=+966xxxxxxxxx
WASENDER_NAME=اسم المتجر

# Certificate Pinning (اختياري لكن مُوصى به)
SUPABASE_CERT_FINGERPRINT=sha256_fingerprint
WASENDER_CERT_FINGERPRINT=sha256_fingerprint
```

### طريقة الاستخدام

#### التطوير

```bash
flutter run \
  --dart-define=WASENDER_API_TOKEN=xxx \
  --dart-define=WASENDER_DEVICE_ID=xxx \
  --dart-define=WASENDER_PHONE=+966xxxxxxxxx
```

#### الإنتاج (Android)

```bash
flutter build apk --release \
  --dart-define=WASENDER_API_TOKEN=xxx \
  --dart-define=WASENDER_DEVICE_ID=xxx \
  --dart-define=WASENDER_PHONE=+966xxxxxxxxx \
  --dart-define=SUPABASE_CERT_FINGERPRINT=xxx \
  --dart-define=WASENDER_CERT_FINGERPRINT=xxx
```

#### الإنتاج (iOS)

```bash
flutter build ios --release \
  --dart-define=WASENDER_API_TOKEN=xxx \
  --dart-define=WASENDER_DEVICE_ID=xxx \
  --dart-define=WASENDER_PHONE=+966xxxxxxxxx
```

### استخدام ملف env

يمكنك إنشاء ملف `env.json` (لا تضعه في Git!) واستخدامه:

```json
{
  "WASENDER_API_TOKEN": "your_token",
  "WASENDER_DEVICE_ID": "your_id",
  "WASENDER_PHONE": "+966xxxxxxxxx"
}
```

ثم استخدم script للبناء:

```bash
# build.sh
#!/bin/bash
source <(jq -r 'to_entries | .[] | "export \(.key)=\(.value)"' env.json)

flutter build apk --release \
  --dart-define=WASENDER_API_TOKEN=$WASENDER_API_TOKEN \
  --dart-define=WASENDER_DEVICE_ID=$WASENDER_DEVICE_ID \
  --dart-define=WASENDER_PHONE=$WASENDER_PHONE
```

## Certificate Pinning

### كيفية الحصول على Certificate Fingerprint

```bash
# لـ Supabase
openssl s_client -connect your-project.supabase.co:443 2>/dev/null | \
  openssl x509 -fingerprint -sha256 -noout

# لـ WaSender
openssl s_client -connect api.wasenderapi.com:443 2>/dev/null | \
  openssl x509 -fingerprint -sha256 -noout
```

### ملاحظات مهمة

1. **يجب تحديث الـ fingerprints عند تجديد الشهادات**
2. في وضع التطوير (Web + Debug)، يتم تجاوز Certificate Pinning
3. Certificate Pinning يعمل على Native platforms فقط (iOS/Android/Desktop)

## PIN Security

### التشفير المستخدم

- **Algorithm**: PBKDF2 with HMAC-SHA256
- **Salt**: 32 bytes (Random.secure)
- **Iterations**: 100,000
- **Key Length**: 32 bytes

### ترحيل البيانات

عند تسجيل الدخول بـ PIN قديم (SHA256)، يتم ترحيله تلقائياً للإصدار الجديد (PBKDF2).

## Session Security

- **Session Timeout**: 30 دقائق
- **Refresh Buffer**: 5 دقائق قبل انتهاء الصلاحية
- **Check Interval**: كل دقيقة

## OTP Security

- **Expiry**: 5 دقائق
- **Max Attempts**: 3 محاولات
- **Rate Limit**: 5 طلبات/ساعة
- **Cooldown**: 60 ثانية بين الطلبات

## PIN Security

- **Max Attempts**: 5 محاولات
- **Lockout Duration**: 15 دقيقة
- **PIN Length**: 4-6 أرقام

## تحذيرات أمنية

1. **لا تضع API tokens في الكود أبداً**
2. **لا تضع ملفات env في Git**
3. **استخدم Certificate Pinning في الإنتاج**
4. **راجع الـ Security Logs بانتظام**
5. **حدّث الـ fingerprints عند تجديد الشهادات**

## التحقق من الأمان

```dart
// التحقق من إعدادات WhatsApp
if (!WhatsAppConfig.isConfigured) {
  print(WhatsAppConfig.configurationError);
}

// التحقق من Certificate Pinning
if (!CertificateFingerprints.isEnabled) {
  print('Warning: Certificate Pinning is disabled');
}
```
