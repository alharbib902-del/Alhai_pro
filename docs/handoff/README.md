# دليل استلام مشاريع Alhai

هذا المجلد يحتوي على prompts صارمة لاستلام كل مشروع في monorepo Alhai. كل ملف مُصمَّم ليُنسخ ويُلصق في **جلسة Claude جديدة** تماماً بدون أي تاريخ سابق.

## كيفية الاستخدام

1. افتح جلسة Claude Code جديدة داخل `C:\Users\basem\OneDrive\Desktop\Alhai`
2. افتح الـ prompt المطلوب من الجدول أدناه
3. انسخ المحتوى كاملاً والصقه كأول رسالة في الجلسة
4. الوكيل سيبدأ بفحص الحالة الفعلية قبل إعلان استلامه

## المشاريع المتاحة

| المشروع | الملف | النطاق |
|---------|------|-------|
| **Cashier** | [HANDOFF_CASHIER.md](HANDOFF_CASHIER.md) | نقطة البيع الرئيسية، الأكثر نضجاً |
| **Admin** | [HANDOFF_ADMIN.md](HANDOFF_ADMIN.md) | لوحة الإدارة الكاملة |
| **Admin Lite** | [HANDOFF_ADMIN_LITE.md](HANDOFF_ADMIN_LITE.md) | نسخة خفيفة للمالكين |
| **Customer App** | [HANDOFF_CUSTOMER_APP.md](HANDOFF_CUSTOMER_APP.md) | تطبيق العميل النهائي |
| **Driver App** | [HANDOFF_DRIVER_APP.md](HANDOFF_DRIVER_APP.md) | تطبيق السائق |
| **Super Admin** | [HANDOFF_SUPER_ADMIN.md](HANDOFF_SUPER_ADMIN.md) | لوحة مدير المنصة (ويب) |
| **Distributor Portal** | [HANDOFF_DISTRIBUTOR_PORTAL.md](HANDOFF_DISTRIBUTOR_PORTAL.md) | بوابة الموزع (ويب) |
| **AI Server** | [HANDOFF_AI_SERVER.md](HANDOFF_AI_SERVER.md) | خادم FastAPI للذكاء الاصطناعي |
| **ZATCA Package** | [HANDOFF_ZATCA_PACKAGE.md](HANDOFF_ZATCA_PACKAGE.md) | حزمة الفوترة السعودية |

## مبادئ مشتركة

كل prompt يفرض على الوكيل المستلم:

1. **لا ثقة بدون فحص** — يجب التحقق من كل ادعاء قبل البناء عليه
2. **لا إضافات خارج النطاق** — ممنوع الـ scope creep
3. **توثيق كل قرار** — كل تغيير يحتاج سبب موثّق
4. **عدم لمس الأمان** — أي تغيير أمني يحتاج موافقة صريحة
5. **الاختبارات أولاً** — لا merge بدون تشغيل الاختبارات

## بيانات مشتركة للاستخدام (مرجع سريع)

- **مسار المشروع**: `C:\Users\basem\OneDrive\Desktop\Alhai`
- **المنصة**: Windows 11 + Git Bash
- **Flutter**: 3.27.4 (CI) — يُفضّل محلياً 3.33+
- **Dart**: SDK 3.x
- **Monorepo tool**: Melos
- **Backend**: Supabase (Postgres + Auth + Edge Functions + Storage)
- **State**: Riverpod
- **Router**: GoRouter
- **Local DB**: Drift (+ sqlcipher)
- **Test framework**: flutter_test + mocktail

## التحديث

آخر تحديث: 2026-04-10

كل prompt يعكس الحالة الفعلية وقت كتابته. قبل استخدام prompt قديم، تحقّق من:
- `git log --oneline -20` — هل حدثت تغييرات جوهرية؟
- `git status` — هل توجد تعديلات غير مُعتمَدة؟
- Migrations جديدة في `supabase/migrations/`
