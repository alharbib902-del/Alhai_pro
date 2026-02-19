# Admin POS - Step 002: Auth + First Store

> **المرحلة:** Phase 1-2 | **المدة:** 3 أسابيع | **الأولوية:** P0

---

## 🎯 الهدف

إنشاء:
- تسجيل Owner مع رفع الهوية
- عملية الموافقة
- إنشاء أول بقالة (Wizard 4 steps)

---

## 📋 المهام

### AUTH-003: Login (6h)

**Route:** `/login`

- Phone + Password
- أو OTP مباشرة
- Remember me
- إذا PENDING_APPROVAL → `/pending-approval`
- إذا APPROVED → `/dashboard`

### AUTH-004: Sign Up (8h)

**Route:** `/signup`

**الحقول:**
- الاسم الكامل
- رقم الجوال (OTP)
- البريد الإلكتروني
- رقم السجل التجاري (اختياري)
- صورة الهوية (R2)
- Referral Code

**Status:** `PENDING_APPROVAL`

### DASH-003: Create Store Wizard (14h)

**Route:** `/stores/create`

**4 Steps:**
```
Step 1: المعلومات الأساسية
├─ اسم البقالة
├─ الوصف
└─ لوغو (R2)

Step 2: الموقع
├─ GPS
├─ العنوان
└─ خريطة

Step 3: الإعدادات
├─ الضريبة %
├─ العملة
└─ رسوم التوصيل

Step 4: المستودع
├─ اسم المستودع الأساسي
└─ العنوان
```

### DASH-001: Main Dashboard (16h)

**Route:** `/dashboard`

**المحتوى:**
- KPI لكل بقالة (مبيعات، طلبات، ديون)
- Consolidated للكل
- Quick actions
- Live updates (كل دقيقتين)

---

## ✅ معايير الإنجاز

- [ ] Signup → PENDING_APPROVAL
- [ ] Login يعمل
- [ ] Create Store wizard كامل
- [ ] Dashboard يعرض بيانات

---

## 📚 المراجع

- [PROD.json](../PROD.json) - AUTH-003, AUTH-004, DASH-001, DASH-003
- [PRD_FINAL.md](../PRD_FINAL.md) - User Stories
