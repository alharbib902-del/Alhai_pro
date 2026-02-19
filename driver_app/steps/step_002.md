# Driver App - Step 002: Auth + Dashboard

> **المرحلة:** Phase 1-2 | **المدة:** 2 أسبوع | **الأولوية:** P0

---

## 🎯 الهدف

إنشاء:
- شاشات التسجيل (3 شاشات)
- لوحة التحكم الرئيسية
- شاشة الطلب الجديد

---

## 📋 المهام

### AUTH-001: Language Selection (4h)

**Route:** `/language`

```dart
// 6 خيارات لغة
final languages = [
  ('🇸🇦', 'العربية', 'ar'),
  ('🇬🇧', 'English', 'en'),
  ('🇵🇰', 'اردو', 'ur'),
  ('🇮🇳', 'हिंदी', 'hi'),
  ('🇮🇩', 'Indonesia', 'id'),
  ('🇧🇩', 'বাংলা', 'bn'),
];
```

### AUTH-002: Login (8h)

**Route:** `/login`

- Phone input
- OTP verification
- Biometric option (Face ID / Fingerprint)

### AUTH-003: Profile Setup (6h)

**Route:** `/setup`

- Name input
- Photo upload
- Vehicle type selection

### DASH-001: Home Dashboard (12h)

**Route:** `/home`

**العناصر:**
```
┌─────────────────────────────────┐
│ ☰  Driver Dashboard        🔔3 │
├─────────────────────────────────┤
│ Today's Earnings: 270 ر.س     │
│ Active Deliveries: 2           │
│ Next Shift: 2 PM - 8 PM        │
│ [Clock In]                     │
└─────────────────────────────────┘
```

### ORDER-001: New Order Screen (10h)

**Route:** `/orders/new/:id`

**الميزات:**
- تفاصيل الطلب
- Accept/Reject buttons
- Voice reason recording
- 45s auto-reject timer
- Smart tip (AI)

---

## ✅ معايير الإنجاز

- [ ] Language selection يعمل
- [ ] Login → Profile → Home يعمل
- [ ] Dashboard يعرض البيانات
- [ ] New Order notification يعمل
- [ ] Accept/Reject يعمل

---

## 📚 المراجع

- [PROD.json](../PROD.json) - AUTH-001 to DASH-001
- [DRIVER_UX_WIREFRAMES.md](../DRIVER_UX_WIREFRAMES.md)
