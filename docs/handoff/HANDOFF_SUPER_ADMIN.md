# استلام مشروع: Alhai Super Admin

## هويتك ودورك

أنت مهندس Flutter Web أول مسؤول عن **Super Admin** — لوحة مدير المنصة للتحكّم بكل tenants (المتاجر، الاشتراكات، المدفوعات، الإحصائيات، صحة النظام). هذا التطبيق **ليس للمتجر الواحد** بل لمن يشغّل منصة Alhai نفسها.

## الفرق الجوهري عن باقي التطبيقات

| الجانب | Admin (app) | Super Admin |
|--------|-------------|-------------|
| الجمهور | موظفو متجر واحد | مشغّل المنصة |
| Scope | `store_id` محدد | كل الـ stores |
| الصلاحيات | RLS محدودة بـ store_member | تجاوز RLS عبر `is_super_admin()` |
| المنصة | Mobile (Android/iOS) + Web | **Web فقط** |
| الخطر الأمني | تسريب بيانات متجر واحد | تسريب بيانات كل المتاجر |

## القواعد الصارمة — صارمة جداً

1. **هذا التطبيق يتجاوز RLS** — خطأ واحد = تسريب عبر كل المتاجر. كل query يحتاج مراجعة
2. **لا Service Role Key في الكود** — حتى لو تطبيق super admin. استخدم `is_super_admin()` RPC
3. **كل action يُعدّل بيانات متجر يُسجَّل** — audit log إلزامي
4. **لا bulk operations بدون confirmation** — "حذف كل X" يحتاج نقرتين + تأكيد نصي
5. **لا webhook secrets مكشوفة في UI** — عرض hash أو masked value فقط
6. **MFA إلزامي لحسابات super admin** — لا تدع super admin يسجّل بـ password فقط

## الحالة الفعلية عند الاستلام (2026-04-10)

### ما هو سليم
- **191 اختبار ناجح** (أعلى من بقية الـ secondary apps)
- **17 شاشة كاملة**: Login, Dashboard, Stores (list/detail/create/settings), Subscriptions (plans/list/billing), Users (list/detail), Analytics (revenue/usage), Platform Settings, SystemHealth, Logs, Reports
- **6,745 سطر كود شاشات** في 40 ملف Dart
- **Sentry مُدمج حديثاً** — DSN: `SENTRY_DSN_SUPER_ADMIN`
- **ShellRoute + sidebar navigation**
- **Auth guard يفرض super_admin role**
- **Deferred imports** للشاشات الثقيلة (revenue analytics, usage analytics, billing, system health)
- **Real Supabase datasources**: stores, subscriptions, users, analytics
- **Parallel data fetching** (Future.wait) — لا N+1 queries
- **Dashboard KPIs حقيقية**: activeStores, activeSubscriptions, MRR, newSignups

### ما هو placeholder مقبول
- `_Placeholder(title: 'Splash')` في `super_admin/lib/router/sa_router.dart` — splash route كـ holder حتى يُصمَّم splash حقيقي
- **ليس بلوكر** — هو scaffold واعي

### البلوكرز

#### 1. لا Android/iOS
`super_admin/` ليس فيه `android/` أو `ios/` — هذا **بالتصميم** (web فقط). لا تُضف mobile targets.

#### 2. أيقونة web الافتراضية
`super_admin/web/favicon.png` قد يكون الافتراضي. افحص.

#### 3. Version: `1.0.0-beta.1+1`

#### 4. لا hosting target في CI
`release.yml` يبني `cashier` فقط — لا يوجد deploy pipeline لـ super admin

#### 5. لا MFA مُفعَّلة
التسجيل حالياً بـ password فقط. قبل نشر إنتاج، يجب:
- تفعيل MFA في Supabase Auth
- تحديث `sa_login_screen.dart` لإضافة خطوة TOTP

## البنية المعمارية

```
super_admin/
├── lib/
│   ├── main.dart                       # Sentry + Supabase
│   ├── core/services/sentry_service.dart
│   ├── features/
│   │   ├── auth/
│   │   │   └── sa_login_screen.dart    # ⚠️ no MFA yet
│   │   ├── dashboard/
│   │   │   └── sa_dashboard_screen.dart
│   │   ├── stores/
│   │   │   ├── stores_list_screen.dart
│   │   │   ├── store_detail_screen.dart
│   │   │   ├── create_store_screen.dart
│   │   │   └── store_settings_screen.dart
│   │   ├── subscriptions/
│   │   │   ├── plans_screen.dart
│   │   │   ├── subscriptions_list_screen.dart
│   │   │   └── billing_screen.dart     # deferred
│   │   ├── users/
│   │   │   ├── users_list_screen.dart
│   │   │   └── user_detail_screen.dart
│   │   ├── analytics/
│   │   │   ├── revenue_analytics_screen.dart  # deferred
│   │   │   └── usage_analytics_screen.dart    # deferred
│   │   ├── platform_settings/
│   │   ├── system_health/              # deferred
│   │   ├── logs/
│   │   └── reports/
│   ├── datasources/
│   │   ├── sa_stores_datasource.dart
│   │   ├── sa_subscriptions_datasource.dart
│   │   ├── sa_users_datasource.dart
│   │   └── sa_analytics_datasource.dart
│   ├── providers/
│   │   ├── sa_dashboard_providers.dart
│   │   ├── sa_stores_providers.dart
│   │   └── ...
│   └── router/
│       └── sa_router.dart              # ShellRoute + auth guard
├── test/                               # strong coverage
└── web/
```

## التبعيات

- `alhai_core`, `alhai_auth`
- `alhai_shared_ui`, `alhai_design_system`, `alhai_l10n`
- `supabase_flutter`
- `fl_chart` للـ analytics
- **لا `alhai_pos`**, **لا `alhai_zatca`**, **لا `alhai_database`** (Drift)
- يعتمد على Supabase queries مباشرة، بدون Drift cache

## الأمان — نقاط حرجة للمراجعة

### 1. صلاحيات `is_super_admin()`
هذه الدالة SQL موجودة في migrations. تأكد أنها:
- تُعيد `true` فقط لـ users في جدول super_admins (إن وُجد)
- ليست خاضعة لـ RLS loop
- مُختبرة في migrations tests

### 2. Audit logging
كل mutation يجب أن يكتب في `audit_log` جدول. افحص:
```bash
grep -r "audit_log" super_admin/lib/
```

### 3. Cross-tenant queries
```bash
grep -r "store_id IN\|org_id IN" super_admin/lib/
```
يجب ألا يظهر `USING(true)` أو `.select('*')` بدون WHERE في أي datasource.

### 4. MRR calculation
`sa_dashboard_providers.dart` يحسب MRR — تحقق أنه يستخدم جدول `subscriptions` الحقيقي وليس mock.

## خطوات الاستلام

### 1. التحقق
```bash
cd C:\Users\basem\OneDrive\Desktop\Alhai\super_admin
flutter pub get
dart analyze 2>&1 | tail -30
```
**توقّع**: ~13 infos. 0 errors.

### 2. الاختبارات
```bash
flutter test 2>&1 | tail -30
```
**توقّع**: 191 passed.

### 3. Web build
```bash
flutter build web --release --no-tree-shake-icons 2>&1 | tail -30
```

### 4. فحص أمني
```bash
# تأكد من عدم استخدام service_role
grep -ri "service_role" super_admin/lib/ && echo "⚠️ DANGER" || echo "OK"

# تأكد من audit logging
grep -r "audit_log\|AuditLog" super_admin/lib/
```

### 5. فحص auth guard
اقرأ `lib/router/sa_router.dart` — تحقق من:
- redirect على `/login` إن لم يكن super_admin
- لا routes خارج الـ guard
- session timeout معقول

## معايير القبول

- [ ] 191+ اختبار ناجح
- [ ] Web build ينجح
- [ ] لا service_role في الكود
- [ ] كل mutation يكتب audit log
- [ ] لا cross-tenant leaks
- [ ] MFA خطة واضحة للإضافة (حتى لو لم تُنفَّذ بعد)
- [ ] Analytics deferred يعمل
- [ ] CHANGELOG محدَّث

## ما هو خارج نطاقك

- ❌ إضافة mobile targets (web فقط بالتصميم)
- ❌ تعديل `is_super_admin()` SQL function
- ❌ إدارة Billing provider (Stripe/Paddle) — يحتاج backend منفصل
- ❌ إعداد hosting (Vercel/Netlify) — قرار DevOps

## البدء

```
استلام Super Admin (web).
- Test: 191 passing؟
- Web build: نجح؟
- grep service_role: لا نتائج؟
- Audit log coverage: [verified]
- MFA status: [not yet]

أولوية اليوم؟
```
