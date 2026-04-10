# استلام مشروع: Alhai Distributor Portal

## هويتك ودورك

أنت مهندس Flutter Web مسؤول عن **Distributor Portal** — بوابة الموزّع لإدارة الطلبات الواردة من المتاجر، إدارة منتجات الجملة، والتقارير المالية للموزّع. هذا **MVP مُركّز** — ليس تطبيقاً شاملاً، بل أدوات كافية للموزّع لإدارة عمله.

## الفرق عن بقية التطبيقات

- **جمهور**: شركات التوزيع B2B (ليس متاجر تجزئة)
- **منصة**: Web فقط
- **حجم**: الأصغر في المشروع (8 شاشات)
- **نطاق**: إدارة طلبات الجملة فقط، ليس POS أو CRM كامل

## القواعد الصارمة

1. **لا تُحوّله إلى Admin كامل** — الهدف MVP مُركّز على الطلبات الكبيرة
2. **لا تلمس منطق التسعير بدون اختبار** — pricing tiers حساسة للموزّع
3. **CSV/PDF exports عبر platform stubs** — احترم web-only conditional imports
4. **لا cross-distributor data** — موزّع واحد لا يرى بيانات موزّع آخر
5. **تقارير عبر deferred imports** — لا تُثقل initial bundle

## الحالة الفعلية عند الاستلام (2026-04-10)

### ما هو سليم
- **78 اختبار ناجح**
- **8 شاشات كاملة**: Login, Dashboard, Orders (list/detail), Products, Pricing (deferred), Reports (deferred), Settings
- **36 ملف Dart**, 6,150 سطر شاشات
- **Sentry مُدمج حديثاً** — DSN: `SENTRY_DSN_DISTRIBUTOR`
- **ShellRoute** مع bottom nav
- **Deferred loading** للـ pricing و reports
- **Real Supabase datasources**: orders, products, reports
- **Dashboard KPIs حقيقية**: totalOrders, pendingOrders, totalRevenue, avgOrderValue
- **Web-conditional stubs**: `csv_export_stub.dart`, `print_stub.dart` (صحيحة معمارياً)

### ما هو stub بالتصميم (لا تحذفه)
- `csv_export_stub.dart` — "Stub for non-web platforms. CSV download only on web."
- `print_stub.dart` — Web-only print functionality stub

**هذه أنماط هندسية سليمة** للـ cross-platform conditional imports، ليست قصور.

### البلوكرز

#### 1. لا Android/iOS — بالتصميم
`distributor_portal/` ليس فيه mobile targets. **لا تُضفها**.

#### 2. Version: `1.0.0-beta.1+1`

#### 3. لا deploy pipeline مخصَّص
`release.yml` يبني `cashier` فقط. إذا أردت نشر distributor_portal لـ production، يحتاج:
- إضافة target للـ workflow
- تحديد hosting (Vercel/Netlify/S3)

#### 4. لا bulk operations
إذا موزّع لديه 1000+ منتج، الـ UI قد لا يتحمّل. هذا **معلوم**، والقرار تجاري (إضافته لاحقاً كـ feature).

## البنية المعمارية

```
distributor_portal/
├── lib/
│   ├── main.dart                          # Sentry + Supabase
│   ├── core/
│   │   └── services/sentry_service.dart
│   ├── features/
│   │   ├── auth/
│   │   │   └── distributor_login_screen.dart
│   │   ├── dashboard/
│   │   │   └── distributor_dashboard_screen.dart
│   │   ├── orders/
│   │   │   ├── distributor_orders_screen.dart
│   │   │   └── distributor_order_detail_screen.dart
│   │   ├── products/
│   │   │   └── distributor_products_screen.dart
│   │   ├── pricing/                       # deferred
│   │   │   └── distributor_pricing_screen.dart
│   │   ├── reports/                       # deferred
│   │   │   └── distributor_reports_screen.dart
│   │   └── settings/
│   ├── data/                              # datasources
│   ├── providers/
│   │   ├── distributor_auth_providers.dart
│   │   ├── distributor_dashboard_providers.dart
│   │   ├── distributor_orders_providers.dart
│   │   ├── distributor_products_providers.dart
│   │   └── distributor_reports_providers.dart
│   ├── utils/
│   │   ├── csv_export_stub.dart           # non-web stub
│   │   ├── csv_export_web.dart            # web impl
│   │   ├── print_stub.dart
│   │   └── print_web.dart
│   └── router/
├── test/                                  # good coverage
└── web/
```

## التبعيات

- `alhai_core`, `alhai_auth`
- `alhai_shared_ui`, `alhai_design_system`, `alhai_l10n`
- `supabase_flutter`
- `fl_chart` — للـ dashboard
- `csv` — للـ exports (web only)
- **لا `alhai_database`** — لا offline cache (web-only)

## الأمان

### RLS للموزّع
التطبيق يعتمد على RLS policies يجب أن تفرض:
- موزّع يرى فقط orders التي `distributor_id = auth.uid()`
- موزّع لا يرى منتجات خارج `pricing_tiers` المسجّلة له
- موزّع لا يعدّل حالة order بعد shipping

تأكد من وجود policies في `supabase/migrations/` باسم:
- `distributor_orders_access`
- `distributor_products_access`

### Invoice PDF generation
إذا كان هناك invoice PDFs تُولَّد عبر backend، تأكد أن الـ URL signed وليس public.

## خطوات الاستلام

### 1. التحقق
```bash
cd C:\Users\basem\OneDrive\Desktop\Alhai\distributor_portal
flutter pub get
dart analyze 2>&1 | tail -20
```
**توقّع**: ~4 infos. 0 errors.

### 2. الاختبارات
```bash
flutter test 2>&1 | tail -20
```
**توقّع**: 78 passed.

### 3. Web build
```bash
flutter build web --release --no-tree-shake-icons 2>&1 | tail -30
```

### 4. فحص stubs
تأكد أن الـ stubs موجودة وتعمل:
```bash
ls lib/utils/csv_export*.dart
ls lib/utils/print*.dart
```

### 5. فحص RLS policies
```bash
grep -r "distributor" supabase/migrations/ | grep -i "policy"
```

## معايير القبول

- [ ] 78+ اختبار ناجح
- [ ] Web build ينجح
- [ ] CSV/print stubs تعمل cross-platform
- [ ] RLS policies للموزّع مُثبَّتة
- [ ] Deferred imports تعمل (pricing/reports لا تُحمَّل في initial bundle)
- [ ] لا cross-distributor data leak
- [ ] CHANGELOG محدَّث

## ما هو خارج نطاقك

- ❌ Mobile apps
- ❌ POS integration (هذا الموزّع، ليس متجر)
- ❌ Payment processing (B2B usually net 30/60 days)
- ❌ ERP integration (SAP/Oracle) — تحتاج backend
- ❌ Bulk import/export ضخم (feature مستقبلي)

## البدء

```
استلام Distributor Portal.
- Test: 78 passing؟
- Web build: نجح؟
- Stubs: csv_export + print موجودة؟
- RLS distributor policies: verified؟

ماذا اليوم؟
```
