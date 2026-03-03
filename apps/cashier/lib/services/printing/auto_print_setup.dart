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

/// Initialize auto-print from a widget context (e.g. CashierShell)
Future<void> initializeAutoPrint(WidgetRef ref) async {
  // Load auto-print preference
  final prefs = await SharedPreferences.getInstance();
  final autoPrintEnabled = prefs.getBool('pref_auto_print') ?? false;
  ref.read(autoPrintEnabledProvider.notifier).state = autoPrintEnabled;

  // Register the auto-print callback
  ref.read(autoPrintCallbackProvider.notifier).state =
      (String saleId) => _autoPrintReceipt(ref, saleId);

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

    final receipt = ReceiptData(
      receiptNumber: sale.receiptNo,
      dateTime: sale.createdAt,
      cashierName: 'كاشير',
      customerName: sale.customerName,
      items: items
          .map((i) => ReceiptItem(
                name: i.productName,
                quantity: i.qty.toDouble(),
                unitPrice: i.unitPrice,
                total: i.total,
              ))
          .toList(),
      subtotal: sale.subtotal,
      discount: sale.discount,
      tax: sale.tax,
      total: sale.total,
      paymentMethod: sale.paymentMethod,
      amountReceived: sale.amountReceived,
      changeAmount: sale.changeAmount,
    );

    final result = await service.printReceipt(receipt);
    return result.success;
  } catch (e) {
    if (kDebugMode) debugPrint('Auto-print error: $e');
    return false;
  }
}
