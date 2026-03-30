/// مزودات المبيعات - Sale Providers
///
/// توفر خدمة المبيعات للتطبيق
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_database/alhai_database.dart';

import '../services/sale_service.dart';
import '../services/invoice_service.dart';
import '../services/whatsapp_receipt_service.dart';
import '../services/whatsapp/wasender_api_client.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';

/// مزود خدمة الفواتير
final invoiceServiceProvider = Provider<InvoiceService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return InvoiceService(db: db);
});

/// مزود خدمة المبيعات
final saleServiceProvider = Provider<SaleService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final syncService = ref.watch(syncServiceProvider);
  final invoiceService = ref.watch(invoiceServiceProvider);

  return SaleService(
    db: db,
    syncService: syncService,
    invoiceService: invoiceService,
  );
});

/// إصلاح عناصر البيع المفقودة في طابور المزامنة (يعمل مرة واحدة عند بدء التشغيل)
final saleItemsSyncRepairProvider = FutureProvider.autoDispose<int>((ref) async {
  final saleService = ref.watch(saleServiceProvider);
  // إصلاح المبيعات الفاشلة بسبب customer_id غير موجود
  await saleService.repairFailedSalesSync();
  // إصلاح عناصر البيع المفقودة
  return saleService.repairMissingSaleItemsSync();
});

/// مزود إجمالي مبيعات اليوم
final todaySalesTotalProvider = FutureProvider.autoDispose.family<double, (String, String)>((ref, params) async {
  final saleService = ref.watch(saleServiceProvider);
  final (storeId, cashierId) = params;
  return saleService.getTodayTotal(storeId, cashierId);
});

/// مزود عدد مبيعات اليوم
final todaySalesCountProvider = FutureProvider.autoDispose.family<int, (String, String)>((ref, params) async {
  final saleService = ref.watch(saleServiceProvider);
  final (storeId, cashierId) = params;
  return saleService.getTodayCount(storeId, cashierId);
});

/// مزود رقم هاتف الإيصال - يُستخدم لتمرير رقم العميل من شاشة الدفع لشاشة الإيصال
final receiptPhoneProvider = StateProvider<String?>((ref) => null);

/// WaSender API Client
final waSenderApiClientProvider = Provider<WaSenderApiClient>((ref) {
  return WaSenderApiClient();
});

/// WhatsApp Messages DAO
final whatsappMessagesDaoProvider = Provider<WhatsAppMessagesDao>((ref) {
  return GetIt.I<AppDatabase>().whatsAppMessagesDao;
});

/// خدمة إرسال الإيصالات عبر واتساب
final whatsappReceiptServiceProvider = Provider<WhatsAppReceiptService>((ref) {
  return WhatsAppReceiptService(
    apiClient: ref.read(waSenderApiClientProvider),
    messagesDao: ref.read(whatsappMessagesDaoProvider),
  );
});
