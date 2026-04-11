import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:alhai_core/alhai_core.dart' show StoreSettings;
import 'package:alhai_database/alhai_database.dart';
import 'zatca_service.dart';

/// Currency symbol used throughout the receipt
const String _currency = StoreSettings.defaultCurrencySymbol;

/// معلومات المتجر للفاتورة
class StoreInfo {
  final String name;
  final String address;
  final String phone;
  final String vatNumber;
  final String? crNumber;

  const StoreInfo({
    required this.name,
    required this.address,
    required this.phone,
    required this.vatNumber,
    this.crNumber,
  });

  /// بيانات المتجر الافتراضية (يمكن تغييرها من الإعدادات لاحقاً)
  static const defaultStore = StoreInfo(
    name: 'Al-HAI Store',
    address: 'الرياض - المملكة العربية السعودية',
    phone: '0500000000',
    vatNumber: '300000000000003',
  );
}

/// مولّد فاتورة PDF للطابعة الحرارية
///
/// ينتج فاتورة ضريبية مبسطة متوافقة مع ZATCA
/// بعرض 80mm أو 58mm مع دعم كامل للعربية RTL
class ReceiptPdfGenerator {
  static pw.Font? _regularFont;
  static pw.Font? _boldFont;

  /// تحميل خطوط Tajawal العربية
  static Future<void> _loadFonts() async {
    if (_regularFont != null && _boldFont != null) return;

    final regularData = await rootBundle.load(
      'packages/alhai_design_system/assets/fonts/Tajawal-Regular.ttf',
    );
    final boldData = await rootBundle.load(
      'packages/alhai_design_system/assets/fonts/Tajawal-Bold.ttf',
    );

    _regularFont = pw.Font.ttf(regularData);
    _boldFont = pw.Font.ttf(boldData);
  }

  /// توليد فاتورة PDF
  static Future<Uint8List> generate({
    required SalesTableData sale,
    required List<SaleItemsTableData> items,
    StoreInfo store = StoreInfo.defaultStore,
    String cashierName = 'كاشير',
    double paperWidth = 80, // mm
    String? note,
  }) async {
    await _loadFonts();

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(base: _regularFont, bold: _boldFont),
    );
    final pageWidth = paperWidth * PdfPageFormat.mm;

    // توليد QR Code بيانات ZATCA
    final qrData = ZatcaService.generateQrData(
      sellerName: store.name,
      vatNumber: store.vatNumber,
      timestamp: sale.createdAt,
      totalWithVat: sale.total,
      vatAmount: sale.tax,
    );

    final dateFormat = DateFormat('yyyy/MM/dd HH:mm', 'ar');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(pageWidth, double.infinity, marginAll: 8),
        theme: pw.ThemeData.withFont(base: _regularFont, bold: _boldFont),
        textDirection: pw.TextDirection.rtl,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // ═══════════════════════════════
              // HEADER - معلومات المتجر
              // ═══════════════════════════════
              _buildHeader(store),
              _divider(),

              // ═══════════════════════════════
              // INVOICE INFO - بيانات الفاتورة
              // ═══════════════════════════════
              _centeredBoldText('فاتورة ضريبية مبسطة', 14),
              pw.SizedBox(height: 4),
              _infoRow('رقم الفاتورة', sale.receiptNo),
              _infoRow('التاريخ', dateFormat.format(sale.createdAt)),
              _infoRow('الكاشير', cashierName),
              if (sale.customerName != null)
                _infoRow('العميل', sale.customerName!),
              _divider(),

              // ═══════════════════════════════
              // ITEMS TABLE - جدول الأصناف
              // ═══════════════════════════════
              _buildItemsHeader(),
              _thinDivider(),
              ...items.map((item) => _buildItemRow(item)),
              _divider(),

              // ═══════════════════════════════
              // TOTALS - المجاميع
              // ═══════════════════════════════
              _buildTotals(sale),
              _divider(),

              // ═══════════════════════════════
              // PAYMENT - الدفع
              // ═══════════════════════════════
              _buildPaymentInfo(sale),
              _divider(),

              // ═══════════════════════════════
              // QR CODE - رمز ZATCA
              // ═══════════════════════════════
              pw.SizedBox(height: 8),
              pw.BarcodeWidget(
                data: qrData,
                barcode: pw.Barcode.qrCode(),
                width: 120,
                height: 120,
              ),
              pw.SizedBox(height: 4),
              _centeredText('يشمل ضريبة القيمة المضافة 15%', 8),
              _divider(),

              // ═══════════════════════════════
              // NOTE - ملاحظة
              // ═══════════════════════════════
              if (note != null && note.isNotEmpty) ...[
                pw.SizedBox(height: 4),
                _centeredBoldText('ملاحظة:', 10),
                pw.SizedBox(height: 2),
                _centeredText(note, 9),
                _divider(),
              ],

              // ═══════════════════════════════
              // FOOTER - التذييل
              // ═══════════════════════════════
              pw.SizedBox(height: 4),
              _centeredText('شكراً لزيارتكم!', 11),
              _centeredText('نتطلع لخدمتكم مجدداً', 9),
              pw.SizedBox(height: 8),
              _centeredText(
                'Powered by Alhai POS',
                7,
                color: PdfColors.grey600,
              ),
              pw.SizedBox(height: 4),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // ─── HEADER ───────────────────────────────────────

  static pw.Widget _buildHeader(StoreInfo store) {
    return pw.Column(
      children: [
        pw.SizedBox(height: 4),
        _centeredBoldText(store.name, 16),
        pw.SizedBox(height: 2),
        _centeredText(store.address, 9),
        _centeredText('هاتف: ${store.phone}', 9),
        _centeredText(
          'الرقم الضريبي: ${ZatcaService.formatVatNumber(store.vatNumber)}',
          9,
        ),
        if (store.crNumber != null)
          _centeredText('سجل تجاري: ${store.crNumber}', 9),
        pw.SizedBox(height: 4),
      ],
    );
  }

  // ─── ITEMS TABLE ──────────────────────────────────

  static pw.Widget _buildItemsHeader() {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 4,
            child: pw.Text(
              'الصنف',
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
              textDirection: pw.TextDirection.rtl,
            ),
          ),
          pw.SizedBox(
            width: 30,
            child: pw.Text(
              'الكمية',
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
              textAlign: pw.TextAlign.center,
              textDirection: pw.TextDirection.rtl,
            ),
          ),
          pw.SizedBox(
            width: 40,
            child: pw.Text(
              'السعر',
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
              textAlign: pw.TextAlign.center,
              textDirection: pw.TextDirection.rtl,
            ),
          ),
          pw.SizedBox(
            width: 45,
            child: pw.Text(
              'المجموع',
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
              textAlign: pw.TextAlign.left,
              textDirection: pw.TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildItemRow(SaleItemsTableData item) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 4,
            child: pw.Text(
              item.productName,
              style: const pw.TextStyle(fontSize: 9),
              textDirection: pw.TextDirection.rtl,
              maxLines: 1,
            ),
          ),
          pw.SizedBox(
            width: 30,
            child: pw.Text(
              '${item.qty}',
              style: const pw.TextStyle(fontSize: 9),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.SizedBox(
            width: 40,
            child: pw.Text(
              item.unitPrice.toStringAsFixed(2),
              style: const pw.TextStyle(fontSize: 9),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.SizedBox(
            width: 45,
            child: pw.Text(
              item.total.toStringAsFixed(2),
              style: const pw.TextStyle(fontSize: 9),
              textAlign: pw.TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  // ─── TOTALS ───────────────────────────────────────

  static pw.Widget _buildTotals(SalesTableData sale) {
    return pw.Column(
      children: [
        _totalRow('المجموع الفرعي', sale.subtotal.toStringAsFixed(2)),
        if (sale.discount > 0)
          _totalRow(
            'الخصم',
            '-${sale.discount.toStringAsFixed(2)}',
            color: PdfColors.green700,
          ),
        _totalRow('ضريبة القيمة المضافة 15%', sale.tax.toStringAsFixed(2)),
        pw.SizedBox(height: 4),
        // خط مزدوج
        pw.Container(
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              top: pw.BorderSide(width: 1.5),
              bottom: pw.BorderSide(width: 1.5),
            ),
          ),
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'الإجمالي',
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                ),
                textDirection: pw.TextDirection.rtl,
              ),
              pw.Text(
                '${sale.total.toStringAsFixed(2)} $_currency',
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                ),
                textDirection: pw.TextDirection.rtl,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── PAYMENT ──────────────────────────────────────

  static pw.Widget _buildPaymentInfo(SalesTableData sale) {
    final methodLabel = _paymentMethodLabel(sale.paymentMethod);
    return pw.Column(
      children: [
        _infoRow('طريقة الدفع', methodLabel),
        if (sale.amountReceived != null && sale.amountReceived! > 0)
          _infoRow(
            'المبلغ المدفوع',
            '${sale.amountReceived!.toStringAsFixed(2)} $_currency',
          ),
        if (sale.changeAmount != null && sale.changeAmount! > 0)
          _infoRow(
            'الباقي',
            '${sale.changeAmount!.toStringAsFixed(2)} $_currency',
          ),
      ],
    );
  }

  static String _paymentMethodLabel(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'نقداً';
      case 'card':
        return 'بطاقة';
      case 'mixed':
        return 'مختلط';
      case 'credit':
        return 'آجل';
      case 'wallet':
        return 'محفظة';
      default:
        return method;
    }
  }

  // ─── HELPERS ──────────────────────────────────────

  static pw.Widget _centeredText(
    String text,
    double size, {
    PdfColor color = PdfColors.black,
  }) {
    return pw.Text(
      text,
      style: pw.TextStyle(fontSize: size, color: color),
      textAlign: pw.TextAlign.center,
      textDirection: pw.TextDirection.rtl,
    );
  }

  static pw.Widget _centeredBoldText(String text, double size) {
    return pw.Text(
      text,
      style: pw.TextStyle(fontSize: size, fontWeight: pw.FontWeight.bold),
      textAlign: pw.TextAlign.center,
      textDirection: pw.TextDirection.rtl,
    );
  }

  static pw.Widget _infoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 9),
            textDirection: pw.TextDirection.rtl,
          ),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
            textDirection: pw.TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  static pw.Widget _totalRow(
    String label,
    String value, {
    PdfColor color = PdfColors.black,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontSize: 10, color: color),
            textDirection: pw.TextDirection.rtl,
          ),
          pw.Text(
            '$value $_currency',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  static pw.Widget _divider() {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Divider(thickness: 0.5),
    );
  }

  static pw.Widget _thinDivider() {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Divider(thickness: 0.3, color: PdfColors.grey400),
    );
  }
}
