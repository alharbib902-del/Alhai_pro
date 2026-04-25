import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:get_it/get_it.dart';
import '../models/receipt_settings.dart';
import 'receipt_pdf_generator.dart';
import 'receipt_settings_repository.dart';

/// خدمة طباعة الإيصالات
///
/// تدير توليد PDF وطباعته أو معاينته أو مشاركته
class ReceiptPrinterService {
  /// طباعة فاتورة عبر saleId
  ///
  /// 1. يجلب بيانات البيع من قاعدة البيانات
  /// 2. يولّد PDF
  /// 3. يفتح dialog الطباعة
  static Future<void> printReceipt(
    BuildContext context,
    String saleId, {
    String cashierName = 'كاشير',
    StoreInfo store = StoreInfo.defaultStore,
  }) async {
    try {
      // جلب بيانات البيع
      final db = GetIt.I<AppDatabase>();
      final sale = await db.salesDao.getSaleById(saleId);
      if (sale == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).invoiceNotFound),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        return;
      }

      final items = await db.saleItemsDao.getItemsBySaleId(saleId);

      // طباعة
      if (!context.mounted) return;
      await printSaleData(
        context,
        sale: sale,
        items: items,
        cashierName: cashierName,
        store: store,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).printError('$e')),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// طباعة مباشرة من بيانات البيع (بدون جلب من DB)
  static Future<void> printSaleData(
    BuildContext context, {
    required SalesTableData sale,
    required List<SaleItemsTableData> items,
    String cashierName = 'كاشير',
    StoreInfo store = StoreInfo.defaultStore,
  }) async {
    try {
      // P0-31: load per-store receipt settings. Falls back to defaults
      // on any read failure — printing must never block on settings.
      final settings = await _loadSettingsOrDefaults(sale.storeId);

      // توليد PDF
      final pdfBytes = await ReceiptPdfGenerator.generate(
        sale: sale,
        items: items,
        store: store,
        cashierName: cashierName,
        settings: settings,
      );

      // عرض dialog الطباعة/المعاينة
      // على الويب: layoutPdf قد يفشل بسبب SecurityError (cross-origin iframe)
      // في هذه الحالة نستخدم sharePdf كبديل (يفتح PDF في تاب جديد)
      try {
        await Printing.layoutPdf(
          name: 'فاتورة ${sale.receiptNo}',
          format: PdfPageFormat(
            settings.paperWidthMm * PdfPageFormat.mm,
            double.infinity,
          ),
          onLayout: (_) => pdfBytes,
        );
      } catch (printError) {
        if (kIsWeb) {
          debugPrint(
            'layoutPdf failed on web, falling back to sharePdf: $printError',
          );
          await Printing.sharePdf(
            bytes: pdfBytes,
            filename: 'receipt_${sale.receiptNo}.pdf',
          );
        } else {
          rethrow;
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).printError('$e')),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// مشاركة الفاتورة كـ PDF (بديل للطباعة في الويب)
  static Future<void> shareReceipt(
    BuildContext context,
    String saleId, {
    String cashierName = 'كاشير',
    StoreInfo store = StoreInfo.defaultStore,
  }) async {
    try {
      final db = GetIt.I<AppDatabase>();
      final sale = await db.salesDao.getSaleById(saleId);
      if (sale == null) return;

      final items = await db.saleItemsDao.getItemsBySaleId(saleId);

      // P0-31: same settings load + fallback as printSaleData.
      final settings = await _loadSettingsOrDefaults(sale.storeId);

      final pdfBytes = await ReceiptPdfGenerator.generate(
        sale: sale,
        items: items,
        store: store,
        cashierName: cashierName,
        settings: settings,
      );

      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'receipt_${sale.receiptNo}.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).shareError('$e')),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// P0-31: load receipt settings for [storeId] with a defensive
  /// fallback. Receipt printing must never abort because the settings
  /// row is missing, malformed, or the DB is in an unexpected state —
  /// the cashier still needs to hand the customer a receipt. On any
  /// failure we log and return [ReceiptSettings.defaults].
  static Future<ReceiptSettings> _loadSettingsOrDefaults(String storeId) async {
    try {
      final db = GetIt.I<AppDatabase>();
      return ReceiptSettingsRepository(db).loadForStore(storeId);
    } catch (e) {
      debugPrint('[ReceiptPrinterService] settings load failed: $e');
      return ReceiptSettings.defaults;
    }
  }
}
