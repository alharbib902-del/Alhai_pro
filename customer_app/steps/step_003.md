# Customer App - Step 003: Auth Flow

> **المرحلة:** Phase 1 | **المدة:** 3-4 أيام | **الأولوية:** P0

---

## 🎯 الهدف

إنشاء:
- Onboarding (3 slides)
- Signup with Phone + OTP
- Login with OTP
- Global Customer creation

---

## 📋 المهام

### AUTH-001: Onboarding (6h)

**Route:** `/onboarding`

**المتطلبات:**
- 3 slides with illustrations
- Skip button
- Auto-transition (5 seconds)
- Dots indicator
- Navigate to `/auth/signup`

**Slides content:**
1. اطلب من بقالات الحي بكل سهولة
2. تتبع طلباتك في الوقت الفعلي
3. اكسب نقاط ولاء مع كل طلب

### AUTH-002: Signup (8h)

**Route:** `/auth/signup`

**المتطلبات:**
- Phone input with +966 prefix
- Name input
- Send OTP button
- Link to login
- Validate phone format

### AUTH-003: Login (6h)

**Route:** `/auth/login`

**المتطلبات:**
- Phone input
- Send OTP button
- Link to signup

### AUTH-004: OTP Verification (6h)

**المتطلبات:**
- 6-digit input boxes
- 45s resend timer
- Auto-submit on complete
- Error handling

### AUTH-005: Global Customer (4h)

```dart
// After successful signup
await supabase.from('global_customers').insert({
  'id': user.id,
  'phone': phone,
  'name': name,
  'location': 'POINT($lng $lat)',
});
```

---

## ✅ معايير الإنجاز

- [ ] Onboarding يعرض 3 slides
- [ ] Signup يرسل OTP
- [ ] Login يعمل برقم الجوال
- [ ] OTP verification يتحقق
- [ ] Global customer record يُنشأ
- [ ] Redirect to `/home` after login

---

## 📚 المراجع

- [PROD.json](../PROD.json) - AUTH-001 to AUTH-006
- [PRD_FINAL.md](../PRD_FINAL.md) - Auth screens specs
