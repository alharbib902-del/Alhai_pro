/// جسر (bridge) للتوافق الخلفي مع cashier_router
///
/// تم تقسيم شاشة [CustomerLedgerScreen] إلى مجلد فرعي
/// `customer_ledger/` (container + widgets + providers) تقليلاً
/// للـ god-class. الـ router يستورد من هذا المسار، لذلك نُبقي الملف
/// كـ re-export فقط.
library;

export 'customer_ledger/customer_ledger_screen.dart';
