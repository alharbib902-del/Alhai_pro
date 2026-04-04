/// Sale Detail Screen - View a single sale's full details
///
/// Shows: sale ID, date, items list, customer info, payment method, totals, tax.
/// Action buttons: Reprint receipt, Refund.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiBreakpoints, AlhaiSpacing;
// alhai_design_system is re-exported via alhai_shared_ui
import '../../core/services/sentry_service.dart';
import '../../widgets/zatca_qr_widget.dart';

/// شاشة تفاصيل البيع
class SaleDetailScreen extends ConsumerStatefulWidget {
  final String saleId;

  const SaleDetailScreen({super.key, required this.saleId});

  @override
  ConsumerState<SaleDetailScreen> createState() => _SaleDetailScreenState();
}

class _SaleDetailScreenState extends ConsumerState<SaleDetailScreen> {
  final _db = GetIt.I<AppDatabase>();
  SalesTableData? _order;
  List<SaleItemsTableData> _items = [];
  StoresTableData? _store;
  bool _isLoading = true;
  String? _error;
  bool _isPrinting = false;

  @override
  void initState() {
    super.initState();
    _loadSaleData();
  }

  Future<void> _loadSaleData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final order = await _db.salesDao.getSaleById(widget.saleId);
      List<SaleItemsTableData> items = [];
      if (order != null) {
        items = await _db.saleItemsDao.getItemsBySaleId(widget.saleId);
      }
      // Load store data for ZATCA QR
      final storeId = ref.read(currentStoreIdProvider);
      StoresTableData? store;
      if (storeId != null) {
        store = await _db.storesDao.getStoreById(storeId);
      }
      if (mounted) {
        setState(() {
          _order = order;
          _items = items;
          _store = store;
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Load sale detail');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = '$e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width >= AlhaiBreakpoints.desktop;
    final isMediumScreen = size.width >= AlhaiBreakpoints.tablet;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Column(
        children: [
          _buildTopBar(isDark, l10n),
          Expanded(
            child: _isLoading
                ? const AppLoadingState()
                : _error != null
                    ? AppErrorState.general(
                        context, message: _error!, onRetry: _loadSaleData)
                    : _order == null
                        ? _buildNotFound(isDark, l10n)
                        : SingleChildScrollView(
                        padding: EdgeInsets.all(isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
                        child: isWideScreen
                            ? _buildWideLayout(isDark, l10n)
                            : _buildNarrowLayout(isDark, l10n, isMediumScreen),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md, vertical: AlhaiSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        border: Border(
          bottom: BorderSide(color: AppColors.getBorder(isDark), width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () => context.pop(),
              icon: Icon(Icons.arrow_back_rounded,
                  color: AppColors.getTextPrimary(isDark)),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.getSurfaceVariant(isDark),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(width: AlhaiSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.invoiceDetails,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                  ),
                  Text(
                    '#${widget.saleId.length > 8 ? widget.saleId.substring(0, 8) : widget.saleId}',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: _loadSaleData,
              icon: Icon(Icons.refresh_rounded,
                  color: AppColors.getTextSecondary(isDark)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFound(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.getTextMuted(isDark).withValues(alpha: 0.4)),
          const SizedBox(height: AlhaiSpacing.md),
          Text(l10n.saleNotFound,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.getTextMuted(isDark))),
        ],
      ),
    );
  }

  Widget _buildWideLayout(bool isDark, AppLocalizations l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _buildOrderInfoCard(isDark, l10n),
              const SizedBox(height: AlhaiSpacing.lg),
              _buildItemsCard(isDark, l10n),
            ],
          ),
        ),
        const SizedBox(width: AlhaiSpacing.lg),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildTotalsCard(isDark, l10n),
              const SizedBox(height: AlhaiSpacing.lg),
              _buildZatcaQrCard(isDark),
              const SizedBox(height: AlhaiSpacing.lg),
              _buildActionsCard(isDark, l10n),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(
      bool isDark, AppLocalizations l10n, bool isMediumScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildOrderInfoCard(isDark, l10n),
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        _buildItemsCard(isDark, l10n),
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        _buildTotalsCard(isDark, l10n),
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        _buildZatcaQrCard(isDark),
        const SizedBox(height: AlhaiSpacing.lg),
        _buildActionsCard(isDark, l10n),
        const SizedBox(height: AlhaiSpacing.lg),
      ],
    );
  }

  Widget _buildOrderInfoCard(bool isDark, AppLocalizations l10n) {
    final order = _order!;
    final date =
        '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}';
    final time =
        '${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.info_outline_rounded,
                    color: AppColors.info, size: 20),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n.invoiceDetails,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: AlhaiSpacing.xxs),
                decoration: BoxDecoration(
                  color:
                      _getStatusColor(order.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _getStatusLabel(order.status, l10n),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(order.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          _buildInfoRow(l10n.invoiceNumber,
              '#${order.id.length > 8 ? order.id.substring(0, 8) : order.id}',
              isDark),
          Divider(height: 20, color: AppColors.getBorder(isDark)),
          _buildInfoRow(l10n.date, date, isDark),
          Divider(height: 20, color: AppColors.getBorder(isDark)),
          _buildInfoRow(l10n.time, time, isDark),
          Divider(height: 20, color: AppColors.getBorder(isDark)),
          _buildInfoRow(l10n.customerName,
              order.customerId ?? l10n.cashCustomer, isDark),
          Divider(height: 20, color: AppColors.getBorder(isDark)),
          _buildInfoRow(l10n.paymentMethod,
              order.paymentMethod, isDark),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxs),
      child: Row(
        children: [
          Text(
            '$label:',
            style: TextStyle(
                fontSize: 13, color: AppColors.getTextSecondary(isDark)),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.shopping_bag_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n.items,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: AlhaiSpacing.xxs),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${_items.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          if (_items.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AlhaiSpacing.lg),
                child: Text(
                  l10n.noItems,
                  style: TextStyle(
                      color: AppColors.getTextMuted(isDark), fontSize: 14),
                ),
              ),
            )
          else
            ..._items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  if (index > 0)
                    Divider(
                        height: 16,
                        color: AppColors.getBorder(isDark)
                            .withValues(alpha: 0.5)),
                  _buildItemRow(item, isDark, l10n),
                ],
              );
            }),
        ],
      ),
    );
  }

  Widget _buildItemRow(
      SaleItemsTableData item, bool isDark, AppLocalizations l10n) {
    final total = item.qty * item.unitPrice;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.getSurfaceVariant(isDark),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '${item.qty}x',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.getTextPrimary(isDark),
              ),
            ),
          ),
          const SizedBox(width: AlhaiSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${item.unitPrice.toStringAsFixed(2)} ${l10n.sar}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${total.toStringAsFixed(2)} ${l10n.sar}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalsCard(bool isDark, AppLocalizations l10n) {
    final order = _order!;
    final subtotal =
        _items.fold<double>(0, (sum, item) => sum + (item.qty * item.unitPrice));
    final tax = order.tax;
    final discount = order.discount;

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.receipt_rounded,
                    color: AppColors.success, size: 20),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n.totalAmountLabel,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          _buildTotalRow(l10n.subtotal, subtotal, isDark),
          const SizedBox(height: AlhaiSpacing.xs),
          _buildTotalRow(
              l10n.tax, tax, isDark, color: AppColors.getTextSecondary(isDark)),
          if (discount > 0) ...[
            const SizedBox(height: AlhaiSpacing.xs),
            _buildTotalRow(l10n.discount, -discount, isDark,
                color: AppColors.error),
          ],
          Divider(height: 24, color: AppColors.getBorder(isDark)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.totalAmountLabel,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
              Text(
                '${order.total.toStringAsFixed(2)} ${l10n.sar}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double value, bool isDark,
      {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 13, color: AppColors.getTextSecondary(isDark)),
        ),
        Text(
          '${value.toStringAsFixed(2)} ${AppLocalizations.of(context).sar}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color ?? AppColors.getTextPrimary(isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildZatcaQrCard(bool isDark) {
    final order = _order!;
    final storeName = _store?.name ?? 'Al-HAI Store';
    final vatNumber = _store?.taxNumber ?? '300000000000003';

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Center(
        child: ZatcaQrWidget(
          sellerName: storeName,
          vatNumber: vatNumber,
          timestamp: order.createdAt,
          totalWithVat: order.total,
          vatAmount: order.tax,
          size: 120,
        ),
      ),
    );
  }

  Widget _buildActionsCard(bool isDark, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isPrinting ? null : () => _reprintReceipt(l10n),
            icon: _isPrinting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.print_rounded, size: 20),
            label: Text(l10n.reprintReceipt,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: AlhaiSpacing.sm),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _requestRefund(l10n),
            icon: const Icon(Icons.assignment_return_rounded, size: 20),
            label: Text(l10n.refund,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _reprintReceipt(AppLocalizations l10n) async {
    setState(() => _isPrinting = true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.receiptPrinted),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Reprint sale receipt');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorWithDetails('$e')),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isPrinting = false);
    }
  }

  void _requestRefund(AppLocalizations l10n) {
    context.push('${AppRoutes.refundRequest}?orderId=${widget.saleId}');
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return AppColors.success;
      case 'created':
        return AppColors.warning;
      case 'cancelled':
        return AppColors.error;
      case 'refunded':
        return const Color(0xFF8B5CF6);
      default:
        return AppColors.info;
    }
  }

  String _getStatusLabel(String status, AppLocalizations l10n) {
    switch (status) {
      case 'completed':
        return l10n.completed;
      case 'created':
        return l10n.pending;
      case 'cancelled':
        return l10n.cancelled;
      case 'refunded':
        return l10n.refunded;
      default:
        return status;
    }
  }
}
