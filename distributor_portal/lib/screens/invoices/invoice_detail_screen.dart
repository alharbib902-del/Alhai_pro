/// Invoice detail screen with full tax invoice layout and print support.
///
/// Shows seller/buyer info, line items (from order), totals, ZATCA QR,
/// and provides browser print dialog via window.print().
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../../core/utils/date_helper.dart';
import '../../core/utils/print_helper.dart';

import '../../data/models.dart';
import '../../providers/distributor_providers.dart';
import '../../ui/shared_widgets.dart';

// ─── Helpers ────────────────────────────────────────────────────

final _currencyFmt = NumberFormat('#,##0.00');

String _formatCurrency(double amount) => '${_currencyFmt.format(amount)} ر.س';

String _formatDate(DateTime? dt) {
  if (dt == null) return '-';
  return DateHelper.dual(dt);
}

String _invoiceTypeLabel(String type) {
  switch (type) {
    case 'simplified_tax':
      return 'فاتورة ضريبية مبسطة';
    case 'standard_tax':
      return 'فاتورة ضريبية';
    case 'credit_note':
      return 'إشعار دائن';
    case 'debit_note':
      return 'إشعار مدين';
    default:
      return 'فاتورة';
  }
}

String _invoiceTypeEnLabel(String type) {
  switch (type) {
    case 'simplified_tax':
      return 'Simplified Tax Invoice';
    case 'standard_tax':
      return 'Tax Invoice';
    case 'credit_note':
      return 'Credit Note';
    case 'debit_note':
      return 'Debit Note';
    default:
      return 'Invoice';
  }
}

String _statusLabel(String status) {
  switch (status) {
    case 'draft':
      return 'مسودة';
    case 'issued':
      return 'صادرة';
    case 'sent':
      return 'مُرسلة';
    case 'paid':
      return 'مدفوعة';
    case 'partially_paid':
      return 'مدفوعة جزئياً';
    case 'overdue':
      return 'متأخرة';
    case 'cancelled':
      return 'ملغاة';
    case 'archived':
      return 'مؤرشفة';
    default:
      return status;
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'draft':
      return Colors.grey;
    case 'issued':
    case 'sent':
      return AppColors.info;
    case 'paid':
      return AppColors.success;
    case 'partially_paid':
      return AppColors.warning;
    case 'overdue':
    case 'cancelled':
      return AppColors.error;
    default:
      return Colors.grey;
  }
}

// ─── Screen ─────────────────────────────────────────────────────

class InvoiceDetailScreen extends ConsumerStatefulWidget {
  final String invoiceId;

  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  ConsumerState<InvoiceDetailScreen> createState() =>
      _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends ConsumerState<InvoiceDetailScreen> {
  bool _isPrinting = false;

  Future<void> _printInvoice() async {
    setState(() => _isPrinting = true);
    // Wait for rebuild to hide non-print elements
    await Future.delayed(const Duration(milliseconds: 150));
    printPage();
    // Restore normal state after print dialog closes
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _isPrinting = false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width >= AlhaiBreakpoints.desktop;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final padding = responsivePadding(size.width);

    final invoiceAsync = ref.watch(invoiceByIdProvider(widget.invoiceId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: invoiceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ErrorStateWidget(
          message: 'حدث خطأ أثناء تحميل الفاتورة',
          onRetry: () =>
              ref.invalidate(invoiceByIdProvider(widget.invoiceId)),
          isDark: isDark,
        ),
        data: (invoice) {
          if (invoice == null) {
            return EmptyStateWidget(
              icon: Icons.receipt_long_outlined,
              message: 'الفاتورة غير موجودة',
              isDark: isDark,
            );
          }
          return _buildContent(invoice, isDark, isWide, padding);
        },
      ),
    );
  }

  Widget _buildContent(
    DistributorInvoice invoice,
    bool isDark,
    bool isWide,
    double padding,
  ) {
    // Fetch line items from the linked order
    final itemsAsync = invoice.saleId != null
        ? ref.watch(orderItemsProvider(invoice.saleId!))
        : null;

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Action bar (hidden during print) ──
              if (!_isPrinting) ...[
                _buildActionBar(invoice, isDark),
                const SizedBox(height: AlhaiSpacing.md),
              ],

              // ── Invoice card ──
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.getSurface(isDark),
                  borderRadius: BorderRadius.circular(AlhaiRadius.lg),
                  border: Border.all(color: AppColors.getBorder(isDark)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Invoice header ──
                    _buildInvoiceHeader(invoice, isDark, isWide),
                    const Divider(height: AlhaiSpacing.xl),

                    // ── Seller + QR ──
                    _buildSellerAndQr(invoice, isDark, isWide),
                    const Divider(height: AlhaiSpacing.xl),

                    // ── Buyer ──
                    _buildBuyerSection(invoice, isDark),
                    const Divider(height: AlhaiSpacing.xl),

                    // ── Invoice meta ──
                    _buildInvoiceMeta(invoice, isDark),
                    const Divider(height: AlhaiSpacing.xl),

                    // ── Line items ──
                    _buildLineItems(itemsAsync, invoice, isDark, isWide),
                    const SizedBox(height: AlhaiSpacing.md),

                    // ── Totals ──
                    _buildTotals(invoice, isDark),

                    // ── Notes ──
                    if (invoice.notes != null &&
                        invoice.notes!.isNotEmpty) ...[
                      const Divider(height: AlhaiSpacing.xl),
                      _buildNotes(invoice, isDark),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Action bar ──────────────────────────────────────────────────

  Widget _buildActionBar(DistributorInvoice invoice, bool isDark) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/invoices');
            }
          },
          tooltip: 'رجوع',
          color: AppColors.getTextPrimary(isDark),
        ),
        const SizedBox(width: AlhaiSpacing.xs),
        Expanded(
          child: Text(
            'فاتورة ${invoice.invoiceNumber}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(isDark),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        FilledButton.icon(
          onPressed: _printInvoice,
          icon: const Icon(Icons.print, size: 18),
          label: const Text('طباعة'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
          ),
        ),
      ],
    );
  }

  // ── Invoice header ──────────────────────────────────────────────

  Widget _buildInvoiceHeader(
    DistributorInvoice invoice,
    bool isDark,
    bool isWide,
  ) {
    return Column(
      children: [
        // Arabic title
        Text(
          _invoiceTypeLabel(invoice.invoiceType),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextPrimary(isDark),
          ),
          textAlign: TextAlign.center,
        ),
        // English title
        Text(
          _invoiceTypeEnLabel(invoice.invoiceType),
          style: TextStyle(
            fontSize: 16,
            color: AppColors.getTextSecondary(isDark),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ── Seller + QR ─────────────────────────────────────────────────

  Widget _buildSellerAndQr(
    DistributorInvoice invoice,
    bool isDark,
    bool isWide,
  ) {
    final sellerWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'البائع / Seller',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.getTextSecondary(isDark),
          ),
        ),
        const SizedBox(height: AlhaiSpacing.xs),
        Text(
          invoice.cashierName ?? 'الموزع',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.getTextPrimary(isDark),
          ),
        ),
        if (invoice.orgId != null)
          Text(
            'رقم المنشأة: ${invoice.orgId}',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
      ],
    );

    final qrWidget = _buildQrCode(invoice, isDark);

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: sellerWidget),
          Expanded(flex: 2, child: Center(child: qrWidget)),
        ],
      );
    }
    return Column(
      children: [
        sellerWidget,
        const SizedBox(height: AlhaiSpacing.md),
        Center(child: qrWidget),
      ],
    );
  }

  Widget _buildQrCode(DistributorInvoice invoice, bool isDark) {
    if (invoice.zatcaQr == null || invoice.zatcaQr!.isEmpty) {
      return Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.getSurfaceVariant(isDark),
          borderRadius: BorderRadius.circular(AlhaiRadius.md),
          border: Border.all(color: AppColors.getBorder(isDark)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_2,
              size: 48,
              color: AppColors.getTextMuted(isDark),
            ),
            const SizedBox(height: AlhaiSpacing.xs),
            Text(
              'في انتظار\nشهادة ZATCA',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.getTextMuted(isDark),
              ),
            ),
          ],
        ),
      );
    }
    return QrImageView(
      data: invoice.zatcaQr!,
      version: QrVersions.auto,
      size: 140,
      backgroundColor: Colors.white,
    );
  }

  // ── Buyer section ───────────────────────────────────────────────

  Widget _buildBuyerSection(DistributorInvoice invoice, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المشتري / Buyer',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.getTextSecondary(isDark),
          ),
        ),
        const SizedBox(height: AlhaiSpacing.xs),
        Text(
          invoice.customerName ?? '-',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.getTextPrimary(isDark),
          ),
        ),
        if (invoice.customerVatNumber != null &&
            invoice.customerVatNumber!.isNotEmpty)
          Text(
            'الرقم الضريبي: ${invoice.customerVatNumber}',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
        if (invoice.customerAddress != null &&
            invoice.customerAddress!.isNotEmpty)
          Text(
            invoice.customerAddress!,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
        if (invoice.customerPhone != null && invoice.customerPhone!.isNotEmpty)
          Text(
            invoice.customerPhone!,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
      ],
    );
  }

  // ── Invoice meta ────────────────────────────────────────────────

  Widget _buildInvoiceMeta(DistributorInvoice invoice, bool isDark) {
    final statusClr = _statusColor(invoice.status);
    return Wrap(
      spacing: AlhaiSpacing.xl,
      runSpacing: AlhaiSpacing.sm,
      children: [
        _metaItem(
          'رقم الفاتورة',
          invoice.invoiceNumber,
          isDark,
        ),
        _metaItem(
          'التاريخ',
          _formatDate(invoice.issuedAt ?? invoice.createdAt),
          isDark,
        ),
        _metaItem(
          'تاريخ الاستحقاق',
          _formatDate(invoice.dueAt),
          isDark,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'الحالة: ',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.getTextSecondary(isDark),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AlhaiSpacing.xs,
                vertical: AlhaiSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: statusClr.withValues(alpha: isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(AlhaiRadius.sm),
              ),
              child: Text(
                _statusLabel(invoice.status),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: statusClr,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _metaItem(String label, String value, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.getTextSecondary(isDark),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.getTextPrimary(isDark),
          ),
        ),
      ],
    );
  }

  // ── Line items ──────────────────────────────────────────────────

  Widget _buildLineItems(
    AsyncValue<List<DistributorOrderItem>>? itemsAsync,
    DistributorInvoice invoice,
    bool isDark,
    bool isWide,
  ) {
    if (itemsAsync == null) {
      return _lineItemsFallback(invoice, isDark);
    }

    return itemsAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(AlhaiSpacing.lg),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, __) => _lineItemsFallback(invoice, isDark),
      data: (items) {
        if (items.isEmpty) return _lineItemsFallback(invoice, isDark);
        return _buildItemsTable(items, invoice, isDark);
      },
    );
  }

  /// Fallback when no line items are available — show summary only.
  Widget _lineItemsFallback(DistributorInvoice invoice, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceVariant(isDark),
        borderRadius: BorderRadius.circular(AlhaiRadius.md),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.getTextMuted(isDark),
            size: 18,
          ),
          const SizedBox(width: AlhaiSpacing.xs),
          Text(
            'تفاصيل البنود غير متاحة',
            style: TextStyle(
              color: AppColors.getTextSecondary(isDark),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTable(
    List<DistributorOrderItem> items,
    DistributorInvoice invoice,
    bool isDark,
  ) {
    final taxRate = invoice.taxRate / 100;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'البنود / Items',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.getTextSecondary(isDark),
          ),
        ),
        const SizedBox(height: AlhaiSpacing.sm),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.getBorder(isDark)),
            borderRadius: BorderRadius.circular(AlhaiRadius.md),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AlhaiRadius.md),
            child: Table(
              columnWidths: const {
                0: FixedColumnWidth(40), // #
                1: FlexColumnWidth(3), // Product
                2: FixedColumnWidth(60), // Qty
                3: FlexColumnWidth(1.5), // Price
                4: FlexColumnWidth(1.5), // VAT
                5: FlexColumnWidth(2), // Total
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                // Header
                TableRow(
                  decoration: BoxDecoration(
                    color: AppColors.getSurfaceVariant(isDark),
                  ),
                  children: [
                    _tableCell('#', isHeader: true, isDark: isDark),
                    _tableCell('المنتج', isHeader: true, isDark: isDark),
                    _tableCell('الكمية', isHeader: true, isDark: isDark),
                    _tableCell('السعر', isHeader: true, isDark: isDark),
                    _tableCell('الضريبة', isHeader: true, isDark: isDark),
                    _tableCell('الإجمالي', isHeader: true, isDark: isDark),
                  ],
                ),
                // Data rows
                ...items.asMap().entries.map((entry) {
                  final i = entry.key;
                  final item = entry.value;
                  final unitPrice =
                      item.distributorPrice ?? item.suggestedPrice;
                  final lineTotal = item.quantity * unitPrice;
                  final lineVat = lineTotal * taxRate;
                  final lineGross = lineTotal + lineVat;

                  return TableRow(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: AppColors.getBorder(isDark),
                        ),
                      ),
                    ),
                    children: [
                      _tableCell('${i + 1}', isDark: isDark),
                      _tableCell(item.productName, isDark: isDark),
                      _tableCell('${item.quantity}', isDark: isDark),
                      _tableCell(
                        _currencyFmt.format(unitPrice),
                        isDark: isDark,
                      ),
                      _tableCell(
                        _currencyFmt.format(lineVat),
                        isDark: isDark,
                      ),
                      _tableCell(
                        _currencyFmt.format(lineGross),
                        isDark: isDark,
                        isBold: true,
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _tableCell(
    String text, {
    bool isHeader = false,
    required bool isDark,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.sm,
        vertical: AlhaiSpacing.xs,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isHeader ? 12 : 13,
          fontWeight: isHeader || isBold ? FontWeight.w600 : FontWeight.w400,
          color: isHeader
              ? AppColors.getTextSecondary(isDark)
              : AppColors.getTextPrimary(isDark),
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // ── Totals ──────────────────────────────────────────────────────

  Widget _buildTotals(DistributorInvoice invoice, bool isDark) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Column(
          children: [
            _totalRow(
              'المجموع الفرعي',
              _formatCurrency(invoice.subtotal),
              isDark,
            ),
            if (invoice.discount > 0)
              _totalRow(
                'الخصم',
                '- ${_formatCurrency(invoice.discount)}',
                isDark,
                color: AppColors.error,
              ),
            _totalRow(
              'ضريبة القيمة المضافة (${invoice.taxRate.toStringAsFixed(0)}%)',
              _formatCurrency(invoice.taxAmount),
              isDark,
            ),
            const Divider(),
            _totalRow(
              'الإجمالي',
              _formatCurrency(invoice.total),
              isDark,
              isBold: true,
              fontSize: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _totalRow(
    String label,
    String value,
    bool isDark, {
    bool isBold = false,
    double fontSize = 14,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: fontSize - 1,
                color: AppColors.getTextSecondary(isDark),
                fontWeight: isBold ? FontWeight.bold : FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AlhaiSpacing.sm),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color ?? AppColors.getTextPrimary(isDark),
            ),
          ),
        ],
      ),
    );
  }

  // ── Notes ───────────────────────────────────────────────────────

  Widget _buildNotes(DistributorInvoice invoice, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ملاحظات',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.getTextSecondary(isDark),
          ),
        ),
        const SizedBox(height: AlhaiSpacing.xs),
        Text(
          invoice.notes!,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.getTextPrimary(isDark),
          ),
        ),
      ],
    );
  }
}
