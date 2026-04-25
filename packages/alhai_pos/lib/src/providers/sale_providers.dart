/// مزودات المبيعات - Sale Providers
///
/// توفر خدمة المبيعات للتطبيق
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_zatca/alhai_zatca.dart' as zatca;

import '../services/sale_service.dart';
import '../services/invoice_service.dart';
import '../services/whatsapp_receipt_service.dart';
import '../services/whatsapp/wasender_api_client.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';

/// Wave 3b-2b: optional ZATCA Phase-2 service. Default: null (Phase-1
/// only). The cashier app overrides this when ZATCA onboarding is
/// complete — see `apps/cashier/lib/core/providers/zatca_overrides.dart`
/// (TODO: separate wave) for the wiring example.
final zatcaInvoiceServiceProvider = Provider<zatca.ZatcaInvoiceService?>((
  ref,
) => null);

/// Wave 3b-2b: per-store Phase-2 enable check. Default: always-false.
/// Override in the host app to read from `SharedPreferences` /
/// `StoreSettings` once the admin toggle ships. Returning `false` for a
/// store keeps the legacy Phase-1 flow even if the service above is
/// wired — useful for staged rollout (sandbox stores opt-in first).
final isZatcaPhase2EnabledForProvider =
    Provider<Future<bool> Function(String storeId)>((ref) => (_) async => false);

/// مزود خدمة الفواتير
final invoiceServiceProvider = Provider<InvoiceService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  // C-4 Session 2 follow-up — Bug B fix: inject SyncService so newly-created
  // invoices are pushed to Supabase. Pre-fix the service only wrote locally,
  // leaving a compliance gap server-side.
  final syncService = ref.watch(syncServiceProvider);
  final clockOffset = ref.watch(clockOffsetProvider);
  // Wave 3b-2b: pull the Phase-2 service + flag from optional providers.
  // Both default to "not configured" so existing apps that haven't
  // overridden them keep Phase-1-only behavior.
  final zatcaService = ref.watch(zatcaInvoiceServiceProvider);
  final phase2Flag = ref.watch(isZatcaPhase2EnabledForProvider);
  return InvoiceService(
    db: db,
    syncService: syncService,
    clockOffsetProvider: clockOffset,
    zatcaInvoiceService: zatcaService,
    isZatcaPhase2EnabledFor: phase2Flag,
  );
});

/// Optional clock offset provider. Override this in the cashier app
/// to supply the measured offset from ClockValidationService.
/// Default: no offset (Duration.zero).
final clockOffsetProvider = Provider<Duration Function()>((ref) {
  return () => Duration.zero;
});

/// مزود خدمة المبيعات
final saleServiceProvider = Provider<SaleService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final syncService = ref.watch(syncServiceProvider);
  final invoiceService = ref.watch(invoiceServiceProvider);
  final clockOffset = ref.watch(clockOffsetProvider);

  return SaleService(
    db: db,
    syncService: syncService,
    invoiceService: invoiceService,
    clockOffsetProvider: clockOffset,
  );
});

/// إصلاح عناصر البيع المفقودة في طابور المزامنة (يعمل مرة واحدة عند بدء التشغيل)
final saleItemsSyncRepairProvider = FutureProvider.autoDispose<int>((
  ref,
) async {
  final saleService = ref.watch(saleServiceProvider);
  // إصلاح المبيعات الفاشلة بسبب customer_id غير موجود
  await saleService.repairFailedSalesSync();
  // إصلاح عناصر البيع المفقودة
  return saleService.repairMissingSaleItemsSync();
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
