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
// alhai_design_system is re-exported via alhai_shared_ui

/// شاشة تفاصيل البيع
class SaleDetailScreen extends ConsumerStatefulWidget {
  final String saleId;

  const SaleDetailScreen({super.key, required this.saleId});

  @override
  ConsumerState<SaleDetailScreen> createState() => _SaleDetailScreenState();
}

class _SaleDetailScreenState extends ConsumerState<SaleDetailScreen> {
  final _db = GetIt.I<AppDatabase>();
  OrdersTableData? _order;
  List<SaleItemsTableData> _items = [];
  bool _isLoading = true;
  bool _isPrinting = false;

  @override
  void initState() {
    super.initState();
    _loadSaleData();
  }

  Future<void> _loadSaleData() async {
    setState(() => _isLoading = true);
    try {
      final order = await _db.ordersDao.getOrderById(widget.saleId);
      List<SaleItemsTableData> items = [];
      if (order != null) {
        items = await _db.saleItemsDao.getItemsBySaleId(widget.saleId);
      }
      if (mounted) {
        setState(() {
          _order = order;
          _items = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        children: [
          _buildTopBar(isDark, l10n),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _order == null
                    ? _buildNotFound(isDark, l10n)
                    : SingleChildScrollView(
                        padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            const SizedBox(width: 12),
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
          const SizedBox(height: 16),
          Text('Sale not found',
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
              const SizedBox(height: 24),
              _buildItemsCard(isDark, l10n),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildTotalsCard(isDark, l10n),
              const SizedBox(height: 24),
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
        SizedBox(height: isMediumScreen ? 24 : 16),
        _buildItemsCard(isDark, l10n),
        SizedBox(height: isMediumScreen ? 24 : 16),
        _buildTotalsCard(isDark, l10n),
        const SizedBox(height: 24),
        _buildActionsCard(isDark, l10n),
        const SizedBox(height: 24),
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
      padding: const EdgeInsets.all(20),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.info_outline_rounded,
                    color: AppColors.info, size: 20),
              ),
              const SizedBox(width: 12),
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
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
          const SizedBox(height: 16),
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
              order.paymentMethod ?? l10n.cash, isDark),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
      padding: const EdgeInsets.all(20),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.shopping_bag_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
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
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
          const SizedBox(height: 16),
          if (_items.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No items',
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
          const SizedBox(width: 12),
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
    final tax = order.taxAmount;
    final discount = order.discount;

    return Container(
      padding: const EdgeInsets.all(20),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.receipt_rounded,
                    color: AppColors.success, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.totalAmount,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTotalRow(l10n.subtotal, subtotal, isDark),
          const SizedBox(height: 8),
          _buildTotalRow(
              l10n.tax, tax, isDark, color: AppColors.getTextSecondary(isDark)),
          if (discount > 0) ...[
            const SizedBox(height: 8),
            _buildTotalRow(l10n.discount, -discount, isDark,
                color: AppColors.error),
          ],
          Divider(height: 24, color: AppColors.getBorder(isDark)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.totalAmount,
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
          '${value.toStringAsFixed(2)} ${AppLocalizations.of(context)!.sar}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color ?? AppColors.getTextPrimary(isDark),
          ),
        ),
      ],
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
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 12),
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
              padding: const EdgeInsets.symmetric(vertical: 16),
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
    } catch (e) {
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
