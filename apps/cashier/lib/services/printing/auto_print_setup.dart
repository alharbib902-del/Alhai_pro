/// Auto-print setup for ESC/POS thermal printing
///
/// Registers the auto-print callback with alhai_shared_ui providers,
/// bridging the cashier app's ESC/POS service with the POS payment flow.
library;

import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart'
    show autoPrintCallbackProvider, autoPrintEnabledProvider;
import 'package:shared_preferences/shared_preferences.dart';

import 'print_service.dart';
import 'receipt_data.dart';
import 'printing_providers.dart' hide autoPrintEnabledProvider;
import '../../core/services/zatca/zatca_qr_service.dart';

/// Initialize auto-print from a widget context (e.g. CashierShell)
Future<void> initializeAutoPrint(WidgetRef ref) async {
  // Load auto-print preference
  final prefs = await SharedPreferences.getInstance();
  final autoPrintEnabled = prefs.getBool('pref_auto_print') ?? false;
  ref.read(autoPrintEnabledProvider.notifier).state = autoPrintEnabled;

  // Register the auto-print callback
  ref.read(autoPrintCallbackProvider.notifier).state = (String saleId) =>
      _autoPrintReceipt(ref, saleId);

  // Load saved printer configuration
  await ref.read(printServiceProvider.notifier).loadSavedPrinter();
}

/// Auto-print a receipt for the given sale ID
Future<bool> _autoPrintReceipt(WidgetRef ref, String saleId) async {
  final service = ref.read(printServiceProvider);
  if (service == null || service.status != PrinterStatus.connected) {
    if (kDebugMode) debugPrint('Auto-print skipped: no printer connected');
    return false;
  }

  try {
    final db = GetIt.I<AppDatabase>();
    final sale = await db.salesDao.getSaleById(saleId);
    if (sale == null) return false;

    final items = await db.saleItemsDao.getItemsBySaleId(saleId);

    // Resolve cashier name from user record, fall back to cashierId
    final cashierUser = await db.usersDao.getUserById(sale.cashierId);
    final cashierName = cashierUser?.name ?? sale.cashierId;

    // Fetch real store data for receipt header and ZATCA QR
    final store = await db.storesDao.getStoreById(sale.storeId);
    if (store == null) {
      if (kDebugMode) {
        debugPrint(
          'Cannot auto-print: store not found (storeId=${sale.storeId})',
        );
      }
      return false;
    }
    final storeName = store.name;
    final storeAddress = store.address ?? '';
    final storePhone = store.phone ?? '';
    final vatNumber = store.taxNumber ?? '';

    // Generate ZATCA QR data (base64-encoded TLV)
    final zatcaQr = ZatcaQrService.generateQrData(
      sellerName: storeName,
      vatNumber: vatNumber,
      timestamp: sale.createdAt,
      totalWithVat: sale.total,
      vatAmount: sale.tax,
    );

    final receipt = ReceiptData(
      receiptNumber: sale.receiptNo,
      dateTime: sale.createdAt,
      cashierName: cashierName,
      customerName: sale.customerName,
      items: items
          .map(
            (i) => ReceiptItem(
              name: i.productName,
              quantity: i.qty.toDouble(),
              // C-4 Session 2: sale_items money cols are int cents; receipt API takes double SAR.
              unitPrice: i.unitPrice / 100.0,
              total: i.total / 100.0,
            ),
          )
          .toList(),
      subtotal: sale.subtotal,
      discount: sale.discount,
      tax: sale.tax,
      total: sale.total,
      paymentMethod: sale.paymentMethod,
      amountReceived: sale.amountReceived,
      changeAmount: sale.changeAmount,
      store: ReceiptStoreInfo(
        name: storeName,
        address: storeAddress,
        phone: storePhone,
        vatNumber: vatNumber,
      ),
      zatcaQrData: zatcaQr,
    );

    final result = await service.printReceipt(receipt);
    return result.success;
  } catch (e) {
    if (kDebugMode) debugPrint('Auto-print error: $e');
    return false;
  }
}
