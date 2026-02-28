# 🔍 تقرير ما قبل التنفيذ - تقييم النواقص وتوزيع المهام

**التاريخ:** 2026-01-22  
**المُعد:** مالك المشروع  
**الحالة:** مراجعة قبل بدء التنفيذ

---

## 📊 الوضع الحالي

### ✅ ما هو جاهز:

| المكون | الحالة | الاختبارات |
|--------|--------|------------|
| `alhai_core` | ✅ جاهز | 147 اختبار ✅ |
| `alhai_services` | ✅ جاهز | 18 اختبار ✅ |
| `alhai_design_system` | ✅ جاهز | 131 اختبار ✅ |
| Database Schema | ✅ موثق | - |
| API Contract | ✅ موثق | - |
| UX Wireframes | ✅ موثقة | - |

### ⚠️ النواقص الحرجة (Critical):

| # | النقص | الأثر | الأولوية |
|---|-------|-------|----------|
| 1 | **لا يوجد ملف `.env`** | لن تعمل الخدمات الخارجية | 🔴 حرج |
| 2 | **لا يوجد `.context/` folders** | لن يعمل Handoff بين الحسابات | 🔴 حرج |
| 3 | **التطبيقات فارغة من Features** | فقط scaffolding | 🟡 متوقع |
| 4 | **لا يوجد Supabase مُعد** | لن يعمل Backend | 🔴 حرج |

---

## 📋 النواقص التفصيلية

### 1️⃣ ملفات Environment Variables

**المشكلة:** لا يوجد أي ملف `.env` في المشروع.

**المطلوب إنشاؤه:**

```
alhai/
├── .env.example          ← قالب للمطورين
├── cashier/
│   └── .env              ← خاص بـ cashier
├── customer_app/
│   └── .env              ← خاص بـ customer_app
└── ...
```

**المتغيرات المطلوبة:**
```env
# Supabase
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=eyJ...

# WhatsApp Business API
WHATSAPP_ACCESS_TOKEN=
WHATSAPP_PHONE_NUMBER_ID=

# Firebase
FIREBASE_PROJECT_ID=

# OpenAI (للمميزات الذكية)
OPENAI_API_KEY=

# SMS Provider
SMS_PROVIDER=unifonic
SMS_API_KEY=
```

---

### 2️⃣ مجلدات Session Context

**المشكلة:** لا توجد مجلدات `.context/` للـ Handoff بين الحسابات.

**المطلوب حسب TEAM_WORKFLOW.md:**

```
cashier/
└── .context/
    ├── A1_SESSION.md
    ├── A2_SESSION.md
    ├── A3_SESSION.md
    └── CURRENT_SESSION.md

customer_app/
└── .context/
    ├── B1_SESSION.md
    ├── B2_SESSION.md
    ├── B3_SESSION.md
    └── CURRENT_SESSION.md
```

---

### 3️⃣ هيكل Features في التطبيقات

**المشكلة:** التطبيقات تحتوي فقط على scaffolding أساسي بدون features.

**الوضع الحالي:**
```
cashier/lib/
├── main.dart
├── core/router/
└── di/

customer_app/lib/
├── main.dart
├── core/
├── di/
├── features/         ← فارغ! فقط .gitkeep
└── shared/
```

**المطلوب (كمثال لـ cashier):**
```
cashier/lib/
├── main.dart
├── core/
│   ├── router/
│   ├── constants/
│   └── utils/
├── di/
├── features/
│   ├── auth/
│   │   ├── presentation/
│   │   └── data/
│   ├── sales/
│   │   ├── presentation/
│   │   └── data/
│   ├── cart/
│   ├── checkout/
│   ├── shift/
│   ├── refund/
│   └── reports/
└── shared/
    ├── widgets/
    └── utils/
```

---

### 4️⃣ إعداد Supabase

**المشكلة:** لا يوجد مشروع Supabase مُنشأ ومُعد.

**المطلوب:**
1. إنشاء مشروع Supabase جديد
2. تنفيذ `DATABASE_SCHEMA.md` (الموجود في docs/)
3. إعداد RLS policies
4. إنشاء Edge Functions للعمليات المعقدة
5. ربط Storage للصور

---

## 🎯 خطة سد النواقص (قبل بدء التنفيذ)

### المرحلة 0: التحضير (اليوم 0 - قبل بدء العد)

| المهمة | المسؤول | الوقت المتوقع |
|--------|---------|---------------|
| إنشاء مشروع Supabase | الجهازين معاً | 2 ساعة |
| تنفيذ Database Schema | الجهاز A | 4 ساعات |
| إعداد RLS Policies | الجهاز A | 2 ساعة |
| إنشاء `.env.example` | الجهاز B | 30 دقيقة |
| إنشاء `.context/` folders | الجهازين | 30 دقيقة |
| إعداد Firebase Project | الجهاز B | 1 ساعة |
| اختبار الاتصال | الجهازين | 1 ساعة |
| **المجموع** | | **~8-10 ساعات** |

---

## 📱 توزيع المهام على الأجهزة

### 🖥️ الجهاز A - فريق POS

**التطبيقات المملوكة:**
- `cashier` (تطبيق نقطة البيع) ← **الأولوية القصوى**
- `admin_pos` (لوحة التحكم)
- `super_admin` (المشرف العام)

**الجدول الزمني:**

| الأسبوع | التطبيق | المهام |
|---------|---------|--------|
| 1-2 | cashier | Auth, Sales, Cart, Checkout |
| 3 | cashier | Offline, Sync, PIN |
| 4 | cashier | Refunds, Cash Movement |
| 5 | admin_pos | Dashboard MVP |
| 6-7 | admin_pos | Full Features |
| 8-9 | super_admin | Platform Admin |

**المهارات المطلوبة:**
- BLoC/Cubit للـ State Management
- الوضع Offline + SQLite
- طباعة الإيصالات
- قارئ الباركود

---

### 📱 الجهاز B - فريق Customer

**التطبيقات المملوكة:**
- `customer_app` (تطبيق العملاء) ← **الأولوية القصوى**
- `driver_app` (تطبيق السائقين)
- `distributor_portal` (بوابة الموزعين)

**الجدول الزمني:**

| الأسبوع | التطبيق | المهام |
|---------|---------|--------|
| 1-2 | customer_app | Auth, Catalog, Cart, Checkout |
| 3 | customer_app | Notifications, Profile |
| 4 | customer_app | Loyalty, Chat |
| 5 | driver_app | Auth, Orders, Delivery |
| 6-7 | distributor_portal | B2B Features |
| 8-9 | Integration | Cross-app Testing |

**المهارات المطلوبة:**
- UI/UX جميل
- خرائط Google
- Realtime Updates
- Push Notifications

---

## 🔗 المكونات المشتركة (تنسيق مطلوب!)

| المكون | المالك الأساسي | ملاحظات |
|--------|---------------|---------|
| `alhai_core` | الجهاز A | تنسيق قبل أي تعديل |
| `alhai_services` | الجهاز A | تنسيق قبل أي تعديل |
| `alhai_design_system` | الجهاز B | تنسيق قبل أي تعديل |
| `docs/` | مشترك | يحدث كلاهما |

---

## ✅ Checklist قبل بدء اليوم 1

### Infrastructure:
- [ ] مشروع Supabase مُنشأ ومُعد
- [ ] Database schema مُنفذ
- [ ] RLS policies فعالة
- [ ] مشروع Firebase مُنشأ
- [ ] `.env.example` موجود
- [ ] `.env` لكل تطبيق

### Project Structure:
- [ ] `.context/` folders موجودة
- [ ] `.context/SESSION.md` templates
- [ ] Feature folders scaffolded
- [ ] Git branches set up

### Tools:
- [ ] Supabase CLI مثبت
- [ ] Firebase CLI مثبت
- [ ] VS Code extensions

### Documentation:
- [ ] ROADMAP_90_DAYS.md مقروء ومفهوم
- [ ] TEAM_WORKFLOW.md مقروء ومفهوم
- [ ] POS_SLICES.md مقروء (للجهاز A)
- [ ] API_CONTRACT.md مقروء

---

## 📌 التوصية النهائية

**قبل بدء التنفيذ، يجب:**

1. ✅ **إنشاء Supabase Project** - هذا هو الـ Backend الأساسي
2. ✅ **تنفيذ Database Schema** - من `docs/DATABASE_SCHEMA.md`
3. ✅ **إنشاء `.env` files** - للربط بـ Supabase
4. ✅ **إنشاء `.context/` folders** - للتنسيق بين الحسابات
5. ✅ **Git Setup** - إنشاء branches: `develop`, `pos/main`, `customer/main`

**بعدها يمكن البدء باليوم 1 من `ROADMAP_90_DAYS.md`**

---

*هذا التقرير يجب مراجعته والموافقة عليه قبل بدء التنفيذ*
