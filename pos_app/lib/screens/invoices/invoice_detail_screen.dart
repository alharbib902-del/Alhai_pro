/// شاشة تفاصيل الفاتورة - Invoice Detail Screen
///
/// تعرض تفاصيل الفاتورة الكاملة مع:
/// - بطاقة الفاتورة (إيصال)
/// - معلومات العميل
/// - إجراءات سريعة
/// - سجل الأحداث
/// - البيانات الفنية
/// - إلغاء الفاتورة (Void)
library;

import 'package:pos_app/widgets/common/adaptive_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';

/// نموذج بيانات تفاصيل الفاتورة
class InvoiceDetailData {
  final String number;
  final String date;
  final String time;
  String status; // paid, pending, voided
  final String cashier;
  final String customerName;
  final String? customerPhone;
  final String customerId;
  final String customerSince;
  final bool isVip;
  final List<InvoiceDetailItem> items;
  final double subtotal;
  final double discount;
  final String discountLabel;
  final double vat;
  final double total;
  final String paymentMethod;
  final String paymentDetails;
  final double amountPaid;
  final String vatNumber;

  InvoiceDetailData({
    required this.number,
    required this.date,
    required this.time,
    required this.status,
    required this.cashier,
    required this.customerName,
    this.customerPhone,
    required this.customerId,
    required this.customerSince,
    this.isVip = false,
    required this.items,
    required this.subtotal,
    required this.discount,
    this.discountLabel = '',
    required this.vat,
    required this.total,
    required this.paymentMethod,
    required this.paymentDetails,
    required this.amountPaid,
    required this.vatNumber,
  });
}

class InvoiceDetailItem {
  final String name;
  final String sku;
  final int quantity;
  final double price;
  final double total;

  const InvoiceDetailItem({
    required this.name,
    required this.sku,
    required this.quantity,
    required this.price,
    required this.total,
  });
}

class InvoiceDetailScreen extends ConsumerStatefulWidget {
  final String invoiceId;
  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  ConsumerState<InvoiceDetailScreen> createState() =>
      _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends ConsumerState<InvoiceDetailScreen> {

  late InvoiceDetailData _invoice;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _invoice = _getSampleInvoice();
      _initialized = true;
    }
  }

  InvoiceDetailData _getSampleInvoice() {
    final l10n = AppLocalizations.of(context)!;
    return InvoiceDetailData(
      number: 'INV-2024-001',
      date: '09/02/2026',
      time: '14:30',
      status: 'paid',
      cashier: l10n.defaultUserName,
      customerName: 'محمد العلي',
      customerPhone: '0501234567',
      customerId: '99281',
      customerSince: '2022',
      isVip: true,
      items: [
        const InvoiceDetailItem(
            name: 'طماطم عضوية',
            sku: '8901',
            quantity: 2,
            price: 12.50,
            total: 25.00),
        const InvoiceDetailItem(
            name: 'حليب كامل الدسم',
            sku: '2201',
            quantity: 1,
            price: 8.00,
            total: 8.00),
        const InvoiceDetailItem(
            name: 'خبز بريوش',
            sku: '4402',
            quantity: 3,
            price: 5.50,
            total: 16.50),
        const InvoiceDetailItem(
            name: 'شوكولاتة داكنة',
            sku: '9912',
            quantity: 1,
            price: 15.00,
            total: 15.00),
      ],
      subtotal: 64.50,
      discount: 4.50,
      discountLabel: 'VIP',
      vat: 9.00,
      total: 69.00,
      paymentMethod: 'card',
      paymentDetails: '4242',
      amountPaid: 69.00,
      vatNumber: '300000000000003',
    );
  }
  void _copyInvoiceId(String id) {
    Clipboard.setData(ClipboardData(text: id));
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.copiedToClipboard(id)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showVoidDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.block_rounded,
                  color: AppColors.error, size: 24),
            ),
            const SizedBox(width: 12),
            Text(l10n.voidInvoice,
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          l10n.voidInvoiceMsg,
          style: TextStyle(
              color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
              fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel,
                style: TextStyle(
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMuted)),
          ),
          FilledButton(
            onPressed: () {
              setState(() => _invoice.status = 'voided');
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.invoiceVoided),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.confirmVoid),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Column(
              children: [
                _buildHeader(context, isWideScreen, isDark, l10n),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isMediumScreen ? 32 : 16),
                    child:
                        _buildContent(isDark, isWideScreen, isMediumScreen, l10n),
                  ),
                ),
              ],
            );
  }

  Widget _buildHeader(BuildContext context, bool isWideScreen, bool isDark,
      AppLocalizations l10n) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.8),
        border: Border(
            bottom: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : AppColors.border)),
      ),
      child: Row(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: isWideScreen
                    ? null
                    : () => Scaffold.of(context).openDrawer(),
                icon: AdaptiveIcon(Icons.arrow_forward_ios_rounded,
                    size: 20,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textSecondary),
              ),
              const SizedBox(width: 8),
              Text(l10n.invoiceDetails,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color:
                          isDark ? Colors.white : AppColors.textPrimary)),
              if (isWideScreen) ...[
                Container(
                    height: 28,
                    width: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : AppColors.border),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F172A)
                        : AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${l10n.invoiceNumberLabel} ',
                          style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMuted)),
                      Text('#${_invoice.number}',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontFamily: 'Source Code Pro')),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const Spacer(),
          if (isWideScreen) ...[
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'void') _showVoidDialog();
              },
              offset: const Offset(0, 48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'duplicate',
                  child: Row(children: [
                    Icon(Icons.copy_rounded,
                        size: 16,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.grey400),
                    const SizedBox(width: 12),
                    Text(l10n.duplicateInvoice,
                        style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimary)),
                  ]),
                ),
                PopupMenuItem(
                  value: 'return',
                  child: Row(children: [
                    const Icon(Icons.rotate_left_rounded,
                        size: 16, color: AppColors.info),
                    const SizedBox(width: 12),
                    Text(l10n.returnMerchandise,
                        style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimary)),
                  ]),
                ),
                PopupMenuItem(
                  value: 'void',
                  child: Row(children: [
                    const Icon(Icons.block_rounded,
                        size: 16, color: AppColors.error),
                    const SizedBox(width: 12),
                    Text(l10n.voidInvoice,
                        style:
                            const TextStyle(fontSize: 14, color: AppColors.error)),
                  ]),
                ),
              ],
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.transparent),
                ),
                child: Row(children: [
                  const Icon(Icons.more_horiz, color: AppColors.primary, size: 20),
                  const SizedBox(width: 6),
                  Text(l10n.additionalOptions,
                      style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? Colors.white
                              : AppColors.textPrimary)),
                  const SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down,
                      size: 16,
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMuted),
                ]),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.print_rounded, size: 18),
              label: Text(l10n.printBtn),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                shadowColor: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.download_rounded,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textSecondary),
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode,
                  color: isDark
                      ? const Color(0xFFFBBF24)
                      : AppColors.textSecondary),
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ] else ...[
            IconButton(
              onPressed: () => context.pop(),
              icon: Icon(Icons.arrow_back_rounded,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContent(
      bool isDark, bool isWideScreen, bool isMediumScreen, AppLocalizations l10n) {
    if (isWideScreen) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: _buildReceiptCard(isDark, l10n),
              ),
            ),
          ),
          const SizedBox(width: 32),
          SizedBox(
            width: 380,
            child: Column(
              children: [
                _buildCustomerCard(isDark, l10n),
                const SizedBox(height: 24),
                _buildQuickActions(isDark, l10n),
                const SizedBox(height: 24),
                _buildTimeline(isDark),
                const SizedBox(height: 24),
                _buildTechnicalData(isDark),
              ],
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          _buildReceiptCard(isDark, l10n),
          const SizedBox(height: 24),
          _buildCustomerCard(isDark, l10n),
          const SizedBox(height: 24),
          _buildQuickActions(isDark, l10n),
          const SizedBox(height: 24),
          _buildTimeline(isDark),
          const SizedBox(height: 24),
          _buildTechnicalData(isDark),
          const SizedBox(height: 24),
        ],
      );
    }
  }

  // ─── Receipt Card ────────────────────────────────────────────
  Widget _buildReceiptCard(bool isDark, AppLocalizations l10n) {
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor =
        isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border;
    final mutedColor =
        isDark ? AppColors.textMutedDark : AppColors.textMuted;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4))
              ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(Icons.receipt_long_rounded,
                      color: AppColors.primary, size: 22),
                  const SizedBox(width: 8),
                  Text(l10n.simplifiedTaxInvoice,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor)),
                ]),
                _buildStatusBadge(_invoice.status, isDark),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('#${_invoice.number}',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            fontFamily: 'Source Code Pro')),
                    IconButton(
                      onPressed: () => _copyInvoiceId(_invoice.number),
                      icon: Icon(Icons.copy_rounded,
                          size: 16, color: mutedColor),
                      tooltip: l10n.copied,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(children: [
                  Icon(Icons.calendar_today_rounded,
                      size: 14, color: mutedColor),
                  const SizedBox(width: 6),
                  Text(_invoice.date,
                      style: TextStyle(fontSize: 13, color: mutedColor)),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time_rounded,
                      size: 14, color: mutedColor),
                  const SizedBox(width: 6),
                  Text(_invoice.time,
                      style: TextStyle(fontSize: 13, color: mutedColor)),
                  const SizedBox(width: 16),
                  Icon(Icons.person_outline_rounded,
                      size: 14, color: mutedColor),
                  const SizedBox(width: 6),
                  Text(_invoice.cashier,
                      style: TextStyle(fontSize: 13, color: mutedColor)),
                ]),
                const Divider(height: 32),
                ..._invoice.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: textColor)),
                                Text('SKU: ${item.sku}',
                                    style: TextStyle(
                                        fontSize: 11, color: mutedColor)),
                              ],
                            ),
                          ),
                          Text('×${item.quantity}',
                              style: TextStyle(
                                  fontSize: 13, color: mutedColor)),
                          const SizedBox(width: 24),
                          Text(
                              '${item.price.toStringAsFixed(2)} ${l10n.currency}',
                              style: TextStyle(
                                  fontSize: 13, color: mutedColor)),
                          const SizedBox(width: 24),
                          SizedBox(
                            width: 80,
                            child: Text(
                                '${item.total.toStringAsFixed(2)} ${l10n.currency}',
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: textColor)),
                          ),
                        ],
                      ),
                    )),
                const Divider(height: 24),
                _totalRow(l10n.subtotalLabel, _invoice.subtotal, isDark, l10n),
                if (_invoice.discount > 0)
                  _totalRow(
                      l10n.discountVip, -_invoice.discount,
                      isDark, l10n,
                      isDiscount: true),
                _totalRow(l10n.vatLabel, _invoice.vat, isDark,
                    l10n),
                const Divider(height: 16),
                _totalRow(l10n.grandTotalLabel, _invoice.total, isDark, l10n,
                    isBold: true),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F172A)
                        : AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Icon(
                            _invoice.paymentMethod == 'card'
                                ? Icons.credit_card
                                : Icons.payments_rounded,
                            size: 18,
                            color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                            _invoice.paymentMethod == 'card'
                                ? l10n.visaEnding(_invoice.paymentDetails)
                                : l10n.cashPayment,
                            style:
                                TextStyle(fontSize: 13, color: textColor)),
                      ]),
                      Text(
                          '${_invoice.amountPaid.toStringAsFixed(2)} ${l10n.currency}',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _totalRow(String label, double amount, bool isDark,
      AppLocalizations l10n,
      {bool isBold = false, bool isDiscount = false}) {
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.textMutedDark : AppColors.textMuted;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: isBold ? 16 : 13,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: isBold ? textColor : mutedColor)),
          Text(
            '${isDiscount ? "-" : ""}${amount.abs().toStringAsFixed(2)} ${l10n.currency}',
            style: TextStyle(
              fontSize: isBold ? 18 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isDiscount
                  ? AppColors.success
                  : (isBold ? AppColors.primary : textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    Color bgColor;
    Color textColor;
    String label;
    IconData icon;

    switch (status) {
      case 'paid':
        bgColor = AppColors.success.withValues(alpha: 0.1);
        textColor = AppColors.success;
        label = l10n.completedStatus;
        icon = Icons.check_circle_rounded;
        break;
      case 'pending':
        bgColor = AppColors.warning.withValues(alpha: 0.1);
        textColor = AppColors.warning;
        label = l10n.pendingStatus;
        icon = Icons.schedule_rounded;
        break;
      case 'voided':
        bgColor = AppColors.error.withValues(alpha: 0.1);
        textColor = AppColors.error;
        label = l10n.voidedStatus;
        icon = Icons.block_rounded;
        break;
      default:
        bgColor = AppColors.grey200;
        textColor = AppColors.textMuted;
        label = status;
        icon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textColor)),
        ],
      ),
    );
  }

  // ─── Customer Card ────────────────────────────────────────────
  Widget _buildCustomerCard(bool isDark, AppLocalizations l10n) {
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor =
        isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.textMutedDark : AppColors.textMuted;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: borderColor))),
            child: Row(
              children: [
                const Icon(Icons.person_rounded,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(l10n.customerInfo,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor:
                        AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                        _invoice.customerName.isNotEmpty
                            ? _invoice.customerName[0]
                            : '?',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text(_invoice.customerName,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: textColor)),
                          if (_invoice.isVip) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                  color: const Color(0xFFFBBF24)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Text('VIP',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFBBF24))),
                            ),
                          ],
                        ]),
                        Text('${l10n.customer}: ${_invoice.customerId}',
                            style: TextStyle(
                                fontSize: 12, color: mutedColor)),
                      ],
                    ),
                  ),
                ]),
                const Divider(height: 24),
                if (_invoice.customerPhone != null)
                  _infoRow(Icons.phone_rounded, l10n.phone,
                      _invoice.customerPhone!, isDark),
                _infoRow(Icons.calendar_today_rounded, l10n.lastVisit,
                    _invoice.customerSince, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
      IconData icon, String label, String value, bool isDark) {
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.textMutedDark : AppColors.textMuted;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Icon(icon, size: 16, color: mutedColor),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(fontSize: 13, color: mutedColor)),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textColor)),
      ]),
    );
  }

  // ─── Quick Actions ────────────────────────────────────────────
  Widget _buildQuickActions(bool isDark, AppLocalizations l10n) {
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor =
        isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: borderColor))),
            child: Row(
              children: [
                const Icon(Icons.flash_on_rounded,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(l10n.quickActions,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _actionBtn(Icons.print_rounded, l10n.printBtn,
                    l10n.printReceipt, AppColors.primary, isDark, () {}),
                const SizedBox(height: 8),
                _actionBtn(Icons.share_rounded, l10n.sendWhatsappAction,
                    l10n.sendEmailAction, AppColors.info, isDark,
                    () {}),
                const SizedBox(height: 8),
                _actionBtn(Icons.download_rounded, l10n.downloadPdfAction,
                    l10n.downloadBtn, AppColors.success, isDark, () {}),
                const SizedBox(height: 8),
                _actionBtn(Icons.rotate_left_rounded, l10n.returnMerchandise,
                    l10n.shareLinkAction, AppColors.warning, isDark, () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label, String subtitle,
      Color color, bool isDark, VoidCallback onTap) {
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.textMutedDark : AppColors.textMuted;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : AppColors.border),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textColor)),
                Text(subtitle,
                    style: TextStyle(fontSize: 11, color: mutedColor)),
              ],
            ),
          ),
          AdaptiveIcon(Icons.arrow_forward_ios_rounded,
              size: 14, color: mutedColor),
        ]),
      ),
    );
  }

  // ─── Timeline ────────────────────────────────────────────
  Widget _buildTimeline(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor =
        isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.textMutedDark : AppColors.textMuted;

    final events = [
      _TimelineEvent(l10n.invoiceCreated, l10n.todayAt(_invoice.time),
          Icons.receipt_long_rounded, AppColors.primary),
      _TimelineEvent(l10n.paymentCompleted, l10n.minutesAgoDetail(5),
          Icons.credit_card, AppColors.success),
      _TimelineEvent(l10n.printReceipt, l10n.minutesAgoDetail(3),
          Icons.print_rounded, AppColors.info),
    ];

    if (_invoice.status == 'voided') {
      events.add(_TimelineEvent(l10n.invoiceVoided, l10n.today,
          Icons.block_rounded, AppColors.error));
    }

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: borderColor))),
            child: Row(
              children: [
                const Icon(Icons.timeline_rounded,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(l10n.eventLog,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: events.asMap().entries.map((entry) {
                final i = entry.key;
                final event = entry.value;
                final isLast = i == events.length - 1;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                              color: event.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10)),
                          child: Icon(event.icon,
                              size: 16, color: event.color),
                        ),
                        if (!isLast)
                          Container(
                              width: 2, height: 32, color: borderColor),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(event.title,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: textColor)),
                            Text(event.time,
                                style: TextStyle(
                                    fontSize: 11, color: mutedColor)),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Technical Data ────────────────────────────────────────────
  Widget _buildTechnicalData(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor =
        isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.textMutedDark : AppColors.textMuted;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: borderColor))),
            child: Row(
              children: [
                const Icon(Icons.code_rounded,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(l10n.technicalData,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _techRow(
                    l10n.vat, _invoice.vatNumber, mutedColor, textColor),
                const SizedBox(height: 8),
                _techRow(l10n.deviceIdLabel, 'TXN-${_invoice.number}',
                    mutedColor, textColor),
                const SizedBox(height: 8),
                _techRow(l10n.terminalLabel, 'POS-01', mutedColor, textColor),
                const SizedBox(height: 8),
                _techRow(
                    l10n.softwareVersion, 'v2.1.0', mutedColor, textColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _techRow(
      String label, String value, Color labelColor, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: labelColor)),
        Text(value,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: valueColor,
                fontFamily: 'Source Code Pro')),
      ],
    );
  }

}

class _TimelineEvent {
  final String title;
  final String time;
  final IconData icon;
  final Color color;
  _TimelineEvent(this.title, this.time, this.icon, this.color);
}
