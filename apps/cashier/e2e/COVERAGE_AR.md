# تغطية اختبارات الكاشير (Playwright)

## بيانات الدخول المستخدمة
- `URL`: `http://localhost:5000/#/login`
- `الجوال`: `0500000001`
- `رمز الدولة`: `+966`
- `OTP`: `123456`

## طريقة التشغيل
- `npm run test:critical`
- `npm run test:high`
- `npm run test:medium`
- `npm run test:cashier:all`
- PowerShell: `.\scripts\run-cashier-tests.ps1 -Priority all -BaseUrl http://localhost:5000`

## مصفوفة التغطية حسب قائمتك
| المتطلب | الحالة | التغطية الحالية |
|---|---|---|
| 1) تسجيل الدخول | `AUTO` | `CRIT-LOGIN-001..005` |
| 2) شاشة POS | `PARTIAL` | `CRIT-POS-001` + مسارات POS ضمن `high` |
| 3) الدفع | `PARTIAL` | `CRIT-PAY-001..002` |
| 4) فتح/إغلاق الوردية | `PARTIAL` | `CRIT-SHIFT-001..002` |
| 5) خصم المخزون بعد البيع | `PARTIAL` | عبر اختبارات Dart المنطقية: `test/unit/stock_test.dart` |
| 6) الإرجاع والاستبدال | `PARTIAL` | `CRIT-RET-001` + مسارات الإرجاع |
| 7) العمل بدون إنترنت | `PARTIAL` | `CRIT-OFFLINE-001` + `integration_test/offline_sync_test.dart` (هيكل) |
| 8) إدارة العملاء | `PARTIAL` | مسارات `HIGH-CUST` |
| 9) التقارير | `PARTIAL` | مسارات `HIGH-REPORT` |
| 10) الإعدادات | `PARTIAL` | مسارات `HIGH-SETTINGS` |
| 11) RTL/LTR | `PARTIAL` | `MEDIUM-RTL-LTR-001` |
| 12) التصميم المتجاوب | `AUTO` | `HIGH-RWD-001..003` |
| 13) العروض والخصومات | `PARTIAL` | مسارات `MEDIUM-OFFERS` |
| 14) المخزون | `PARTIAL` | مسارات `MEDIUM-INVENTORY` + `stock_test.dart` |
| 15) المنتجات | `PARTIAL` | مسارات `MEDIUM-PRODUCTS` |
| 16) المشتريات | `PARTIAL` | مسارات `MEDIUM-PURCHASES` |
| 17) لوحة المعلومات | `PARTIAL` | مسارات `MEDIUM-DASHBOARD` |

## ملاحظات مهمة
- تغطية `PARTIAL` تعني أن الاختبار الحالي يتحقق من الوصول/التحميل والسلوك الأساسي، وليس كل قواعد العمل التفصيلية.
- للوصول لتغطية كاملة لكل سطر (مثل الطباعة الفعلية، واتساب، أجهزة الدفع، وسيناريوهات مخزون متقدمة) يلزم إضافة `data-testid` ثابتة في الواجهات وتشغيل بيئة بيانات اختبارية ثابتة.

