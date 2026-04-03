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

import '../../widgets/common/adaptive_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/utils/currency_formatter.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_database/alhai_database.dart';
import '../../providers/invoices_providers.dart';
import '../../providers/sync_providers.dart';

class InvoiceDetailScreen extends ConsumerStatefulWidget {
  final String invoiceId;
  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  ConsumerState<InvoiceDetailScreen> createState() =>
      _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends ConsumerState<InvoiceDetailScreen> {

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

  void _showVoidDialog(SalesTableData sale) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surface,
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
            SizedBox(width: AlhaiSpacing.sm),
            Text(l10n.voidInvoice,
                style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          l10n.voidInvoiceMsg,
          style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel,
                style: TextStyle(
                    color: colorScheme.onSurfaceVariant)),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final db = GetIt.I<AppDatabase>();
                await db.salesDao.voidSale(sale.id);
                // Enqueue to SyncQueue
                try {
                  ref.read(syncServiceProvider).enqueueUpdate(
                    tableName: 'sales',
                    recordId: sale.id,
                    changes: {
                      'id': sale.id,
                      'status': 'voided',
                      'updatedAt': DateTime.now().toIso8601String(),
                    },
                  );
                } catch (_) {}
                // Refresh the provider
                ref.invalidate(invoiceDetailProvider(widget.invoiceId));
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.invoiceVoided),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.cancelInvoiceError),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.error,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: Text(l10n.confirmVoid),
          ),
        ],
      ),
    );
  }

  /// Map status from DB to display status
  String _mapStatus(String dbStatus) {
    switch (dbStatus) {
      case 'completed':
        return 'paid';
      case 'voided':
        return 'voided';
      case 'pending':
        return 'pending';
      default:
        return dbStatus;
    }
  }

  /// Format date from DateTime
  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  /// Format time from DateTime
  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = context.isDesktop;
    final isMediumScreen = !context.isMobile;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final invoiceAsync = ref.watch(invoiceDetailProvider(widget.invoiceId));

    return invoiceAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            SizedBox(height: AlhaiSpacing.md),
            Text(
              l10n.invoiceLoadError,
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: AlhaiSpacing.xs),
            TextButton(
              onPressed: () => ref.invalidate(invoiceDetailProvider(widget.invoiceId)),
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
      data: (data) {
        if (data == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_rounded, size: 48,
                    color: colorScheme.onSurfaceVariant),
                SizedBox(height: AlhaiSpacing.md),
                Text(
                  l10n.invoiceNotFound,
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          );
        }

        final sale = data.sale;
        final items = data.items;

        return Column(
          children: [
            _buildHeader(context, isWideScreen, colorScheme, l10n, sale),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMediumScreen ? AlhaiSpacing.xl : AlhaiSpacing.md),
                child: _buildContent(colorScheme, isWideScreen, isMediumScreen, l10n, sale, items),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isWideScreen, ColorScheme colorScheme,
      AppLocalizations l10n, SalesTableData sale) {
    final isDark = colorScheme.brightness == Brightness.dark;
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.8),
        border: Border(
            bottom: BorderSide(
                color: colorScheme.outlineVariant)),
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
                    color: colorScheme.onSurfaceVariant),
              ),
              SizedBox(width: AlhaiSpacing.xs),
              Text(l10n.invoiceDetails,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface)),
              if (isWideScreen) ...[
                Container(
                    height: 28,
                    width: 1,
                    margin: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md),
                    color: colorScheme.outlineVariant),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: colorScheme.outlineVariant),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${l10n.invoiceNumberLabel} ',
                          style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurfaceVariant)),
                      Text('#${sale.receiptNo}',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
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
                if (value == 'void') _showVoidDialog(sale);
              },
              offset: const Offset(0, 48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              color: colorScheme.surface,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'duplicate',
                  child: Row(children: [
                    Icon(Icons.copy_rounded,
                        size: 16,
                        color: colorScheme.onSurfaceVariant),
                    SizedBox(width: AlhaiSpacing.sm),
                    Text(l10n.duplicateInvoice,
                        style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface)),
                  ]),
                ),
                PopupMenuItem(
                  value: 'return',
                  child: Row(children: [
                    const Icon(Icons.rotate_left_rounded,
                        size: 16, color: AppColors.info),
                    SizedBox(width: AlhaiSpacing.sm),
                    Text(l10n.returnMerchandise,
                        style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface)),
                  ]),
                ),
                PopupMenuItem(
                  value: 'void',
                  child: Row(children: [
                    const Icon(Icons.block_rounded,
                        size: 16, color: AppColors.error),
                    SizedBox(width: AlhaiSpacing.sm),
                    Text(l10n.voidInvoice,
                        style:
                            const TextStyle(fontSize: 14, color: AppColors.error)),
                  ]),
                ),
              ],
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: AlhaiSpacing.xs),
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
                          color: colorScheme.onSurface)),
                  SizedBox(width: AlhaiSpacing.xxs),
                  Icon(Icons.keyboard_arrow_down,
                      size: 16,
                      color: colorScheme.onSurfaceVariant),
                ]),
              ),
            ),
            SizedBox(width: AlhaiSpacing.xs),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.print_rounded, size: 18),
              label: Text(l10n.printBtn),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: colorScheme.onPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: AlhaiSpacing.lg, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                shadowColor: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            SizedBox(width: AlhaiSpacing.xs),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.download_rounded,
                  color: colorScheme.onSurfaceVariant),
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
                  color: colorScheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContent(
      ColorScheme colorScheme, bool isWideScreen, bool isMediumScreen, AppLocalizations l10n,
      SalesTableData sale, List<SaleItemsTableData> items) {
    if (isWideScreen) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: _buildReceiptCard(colorScheme, l10n, sale, items),
              ),
            ),
          ),
          SizedBox(width: AlhaiSpacing.xl),
          SizedBox(
            width: 380,
            child: Column(
              children: [
                _buildCustomerCard(colorScheme, l10n, sale),
                SizedBox(height: AlhaiSpacing.lg),
                _buildQuickActions(colorScheme, l10n),
                SizedBox(height: AlhaiSpacing.lg),
                _buildTimeline(colorScheme, sale),
                SizedBox(height: AlhaiSpacing.lg),
                _buildTechnicalData(colorScheme, sale),
              ],
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          _buildReceiptCard(colorScheme, l10n, sale, items),
          SizedBox(height: AlhaiSpacing.lg),
          _buildCustomerCard(colorScheme, l10n, sale),
          SizedBox(height: AlhaiSpacing.lg),
          _buildQuickActions(colorScheme, l10n),
          SizedBox(height: AlhaiSpacing.lg),
          _buildTimeline(colorScheme, sale),
          SizedBox(height: AlhaiSpacing.lg),
          _buildTechnicalData(colorScheme, sale),
          SizedBox(height: AlhaiSpacing.lg),
        ],
      );
    }
  }

  // ─── Receipt Card ────────────────────────────────────────────
  Widget _buildReceiptCard(ColorScheme colorScheme, AppLocalizations l10n,
      SalesTableData sale, List<SaleItemsTableData> items) {
    final cardBg = colorScheme.surface;
    final borderColor = colorScheme.outlineVariant;
    final mutedColor = colorScheme.onSurfaceVariant;
    final textColor = colorScheme.onSurface;
    final status = _mapStatus(sale.status);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: AppShadows.of(context, size: ShadowSize.xl),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AlhaiSpacing.mdl),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(Icons.receipt_long_rounded,
                      color: AppColors.primary, size: 22),
                  SizedBox(width: AlhaiSpacing.xs),
                  Text(l10n.simplifiedTaxInvoice,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor)),
                ]),
                _buildStatusBadge(status),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AlhaiSpacing.mdl),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('#${sale.receiptNo}',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            fontFamily: 'Source Code Pro')),
                    IconButton(
                      onPressed: () => _copyInvoiceId(sale.receiptNo),
                      icon: Icon(Icons.copy_rounded,
                          size: 16, color: mutedColor),
                      tooltip: l10n.copied,
                    ),
                  ],
                ),
                SizedBox(height: AlhaiSpacing.xs),
                Row(children: [
                  Icon(Icons.calendar_today_rounded,
                      size: 14, color: mutedColor),
                  const SizedBox(width: 6),
                  Text(_formatDate(sale.createdAt),
                      style: TextStyle(fontSize: 13, color: mutedColor)),
                  SizedBox(width: AlhaiSpacing.md),
                  Icon(Icons.access_time_rounded,
                      size: 14, color: mutedColor),
                  const SizedBox(width: 6),
                  Text(_formatTime(sale.createdAt),
                      style: TextStyle(fontSize: 13, color: mutedColor)),
                  SizedBox(width: AlhaiSpacing.md),
                  Icon(Icons.person_outline_rounded,
                      size: 14, color: mutedColor),
                  const SizedBox(width: 6),
                  Text(sale.cashierId,
                      style: TextStyle(fontSize: 13, color: mutedColor)),
                ]),
                const Divider(height: 32),
                ...items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.productName,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: textColor)),
                                Text('SKU: ${item.productSku ?? '-'}',
                                    style: TextStyle(
                                        fontSize: 11, color: mutedColor)),
                              ],
                            ),
                          ),
                          Text('\u00d7${item.qty}',
                              style: TextStyle(
                                  fontSize: 13, color: mutedColor)),
                          SizedBox(width: AlhaiSpacing.lg),
                          Text(
                              CurrencyFormatter.formatWithContext(context, item.unitPrice),
                              style: TextStyle(
                                  fontSize: 13, color: mutedColor)),
                          SizedBox(width: AlhaiSpacing.lg),
                          SizedBox(
                            width: 80,
                            child: Text(
                                CurrencyFormatter.formatWithContext(context, item.total),
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
                _totalRow(l10n.subtotalLabel, sale.subtotal, colorScheme, l10n),
                if (sale.discount > 0)
                  _totalRow(
                      l10n.discountVip, -sale.discount,
                      colorScheme, l10n,
                      isDiscount: true),
                _totalRow(l10n.vatLabel, sale.tax, colorScheme,
                    l10n),
                const Divider(height: 16),
                _totalRow(l10n.grandTotalLabel, sale.total, colorScheme, l10n,
                    isBold: true),
                SizedBox(height: AlhaiSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AlhaiSpacing.sm),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Icon(
                            sale.paymentMethod == 'card'
                                ? Icons.credit_card
                                : Icons.payments_rounded,
                            size: 18,
                            color: AppColors.primary),
                        SizedBox(width: AlhaiSpacing.xs),
                        Text(
                            sale.paymentMethod == 'card'
                                ? l10n.visaEnding('****')
                                : l10n.cashPayment,
                            style:
                                TextStyle(fontSize: 13, color: textColor)),
                      ]),
                      Text(
                          CurrencyFormatter.formatWithContext(context, sale.amountReceived ?? sale.total),
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

  Widget _totalRow(String label, double amount, ColorScheme colorScheme,
      AppLocalizations l10n,
      {bool isBold = false, bool isDiscount = false}) {
    final textColor = colorScheme.onSurface;
    final mutedColor = colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: isBold ? 16 : 13,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: isBold ? textColor : mutedColor)),
          Text(
            '${isDiscount ? "-" : ""}${CurrencyFormatter.formatWithContext(context, amount.abs())}',
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

  Widget _buildStatusBadge(String status) {
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
      padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.sm, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          SizedBox(width: AlhaiSpacing.xxs),
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
  Widget _buildCustomerCard(ColorScheme colorScheme, AppLocalizations l10n, SalesTableData sale) {
    final cardBg = colorScheme.surface;
    final borderColor = colorScheme.outlineVariant;
    final textColor = colorScheme.onSurface;
    final mutedColor = colorScheme.onSurfaceVariant;

    final customerName = sale.customerName ?? l10n.cashCustomer;
    final customerPhone = sale.customerPhone;
    final customerId = sale.customerId ?? '-';

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AlhaiSpacing.md),
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: borderColor))),
            child: Row(
              children: [
                const Icon(Icons.person_rounded,
                    color: AppColors.primary, size: 20),
                SizedBox(width: AlhaiSpacing.xs),
                Text(l10n.customerInfo,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AlhaiSpacing.md),
            child: Column(
              children: [
                Row(children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor:
                        AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                        customerName.isNotEmpty
                            ? customerName[0]
                            : '?',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary)),
                  ),
                  SizedBox(width: AlhaiSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(customerName,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: textColor)),
                        Text('${l10n.customer}: $customerId',
                            style: TextStyle(
                                fontSize: 12, color: mutedColor)),
                      ],
                    ),
                  ),
                ]),
                const Divider(height: 24),
                if (customerPhone != null && customerPhone.isNotEmpty)
                  _infoRow(Icons.phone_rounded, l10n.phone,
                      customerPhone, colorScheme),
                _infoRow(Icons.calendar_today_rounded, l10n.lastVisit,
                    _formatDate(sale.createdAt), colorScheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
      IconData icon, String label, String value, ColorScheme colorScheme) {
    final textColor = colorScheme.onSurface;
    final mutedColor = colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Icon(icon, size: 16, color: mutedColor),
        SizedBox(width: AlhaiSpacing.xs),
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
  Widget _buildQuickActions(ColorScheme colorScheme, AppLocalizations l10n) {
    final cardBg = colorScheme.surface;
    final borderColor = colorScheme.outlineVariant;
    final textColor = colorScheme.onSurface;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AlhaiSpacing.md),
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: borderColor))),
            child: Row(
              children: [
                const Icon(Icons.flash_on_rounded,
                    color: AppColors.primary, size: 20),
                SizedBox(width: AlhaiSpacing.xs),
                Text(l10n.quickActions,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AlhaiSpacing.md),
            child: Column(
              children: [
                _actionBtn(Icons.print_rounded, l10n.printBtn,
                    l10n.printReceipt, AppColors.primary, colorScheme, () {}),
                SizedBox(height: AlhaiSpacing.xs),
                _actionBtn(Icons.share_rounded, l10n.sendWhatsappAction,
                    l10n.sendEmailAction, AppColors.info, colorScheme,
                    () {}),
                SizedBox(height: AlhaiSpacing.xs),
                _actionBtn(Icons.download_rounded, l10n.downloadPdfAction,
                    l10n.downloadBtn, AppColors.success, colorScheme, () {}),
                SizedBox(height: AlhaiSpacing.xs),
                _actionBtn(Icons.rotate_left_rounded, l10n.returnMerchandise,
                    l10n.shareLinkAction, AppColors.warning, colorScheme, () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label, String subtitle,
      Color color, ColorScheme colorScheme, VoidCallback onTap) {
    final textColor = colorScheme.onSurface;
    final mutedColor = colorScheme.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(AlhaiSpacing.sm),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: colorScheme.outlineVariant),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(AlhaiSpacing.xs),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: color),
          ),
          SizedBox(width: AlhaiSpacing.sm),
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
  Widget _buildTimeline(ColorScheme colorScheme, SalesTableData sale) {
    final l10n = AppLocalizations.of(context)!;
    final cardBg = colorScheme.surface;
    final borderColor = colorScheme.outlineVariant;
    final textColor = colorScheme.onSurface;
    final mutedColor = colorScheme.onSurfaceVariant;

    final timeStr = _formatTime(sale.createdAt);
    final events = [
      _TimelineEvent(l10n.invoiceCreated, l10n.todayAt(timeStr),
          Icons.receipt_long_rounded, AppColors.primary),
      if (sale.isPaid)
        _TimelineEvent(l10n.paymentCompleted, l10n.todayAt(timeStr),
            Icons.credit_card, AppColors.success),
    ];

    if (_mapStatus(sale.status) == 'voided') {
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
            padding: const EdgeInsets.all(AlhaiSpacing.md),
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: borderColor))),
            child: Row(
              children: [
                const Icon(Icons.timeline_rounded,
                    color: AppColors.primary, size: 20),
                SizedBox(width: AlhaiSpacing.xs),
                Text(l10n.eventLog,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AlhaiSpacing.md),
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
                    SizedBox(width: AlhaiSpacing.sm),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: AlhaiSpacing.md),
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
  Widget _buildTechnicalData(ColorScheme colorScheme, SalesTableData sale) {
    final l10n = AppLocalizations.of(context)!;
    final cardBg = colorScheme.surface;
    final borderColor = colorScheme.outlineVariant;
    final textColor = colorScheme.onSurface;
    final mutedColor = colorScheme.onSurfaceVariant;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AlhaiSpacing.md),
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: borderColor))),
            child: Row(
              children: [
                const Icon(Icons.code_rounded,
                    color: AppColors.primary, size: 20),
                SizedBox(width: AlhaiSpacing.xs),
                Text(l10n.technicalData,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AlhaiSpacing.md),
            child: Column(
              children: [
                _techRow(
                    l10n.vat, sale.storeId, mutedColor, textColor),
                SizedBox(height: AlhaiSpacing.xs),
                _techRow(l10n.deviceIdLabel, 'TXN-${sale.receiptNo}',
                    mutedColor, textColor),
                SizedBox(height: AlhaiSpacing.xs),
                _techRow(l10n.terminalLabel, sale.terminalId ?? 'POS-01', mutedColor, textColor),
                SizedBox(height: AlhaiSpacing.xs),
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
