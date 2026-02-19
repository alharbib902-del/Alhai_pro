import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../data/local/app_database.dart';
import '../di/injection.dart';
import 'receipt_pdf_generator.dart';

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
      final db = getIt<AppDatabase>();
      final sale = await db.salesDao.getSaleById(saleId);
      if (sale == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('الفاتورة غير موجودة'),
              backgroundColor: Colors.red,
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
            content: Text('خطأ في الطباعة: $e'),
            backgroundColor: Colors.red,
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
      // توليد PDF
      final pdfBytes = await ReceiptPdfGenerator.generate(
        sale: sale,
        items: items,
        store: store,
        cashierName: cashierName,
      );

      // عرض dialog الطباعة/المعاينة
      await Printing.layoutPdf(
        name: 'فاتورة ${sale.receiptNo}',
        format: const PdfPageFormat(80 * PdfPageFormat.mm, double.infinity),
        onLayout: (_) => pdfBytes,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في الطباعة: $e'),
            backgroundColor: Colors.red,
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
      final db = getIt<AppDatabase>();
      final sale = await db.salesDao.getSaleById(saleId);
      if (sale == null) return;

      final items = await db.saleItemsDao.getItemsBySaleId(saleId);

      final pdfBytes = await ReceiptPdfGenerator.generate(
        sale: sale,
        items: items,
        store: store,
        cashierName: cashierName,
      );

      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'receipt_${sale.receiptNo}.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في المشاركة: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
