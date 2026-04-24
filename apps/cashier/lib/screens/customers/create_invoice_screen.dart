/// Bridge file — موقع قديم لـ `CreateInvoiceScreen`.
///
/// المسار الحقيقي بعد تقسيم 3.4:
///   `create_invoice/create_invoice_screen.dart`
///
/// يُبقَى هذا الملف لتجنّب كسر:
/// - `import` في `lib/router/cashier_router.dart`
/// - `import` في `test/screens/customers/create_invoice_screen_test.dart`
/// - أي مراجع خارجية أخرى.
library;

export 'create_invoice/create_invoice_screen.dart' show CreateInvoiceScreen;
