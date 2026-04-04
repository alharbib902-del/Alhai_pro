/// Distributor Order Detail Screen
///
/// Shows purchase order details. Distributor can:
/// - View order items and suggested prices
/// - Set their own prices for each item
/// - Accept and send quote or reject the order
/// Data from Supabase via Riverpod providers.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:intl/intl.dart' show NumberFormat, DateFormat;

import '../../data/models.dart';
import '../../providers/distributor_providers.dart';

class DistributorOrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;

  const DistributorOrderDetailScreen({super.key, required this.orderId});

  @override
  ConsumerState<DistributorOrderDetailScreen> createState() =>
      _DistributorOrderDetailScreenState();
}

class _DistributorOrderDetailScreenState
    extends ConsumerState<DistributorOrderDetailScreen> {
  final _notesController = TextEditingController();
  final Map<String, TextEditingController> _priceControllers = {};
  bool _isProcessing = false;

  @override
  void dispose() {
    _notesController.dispose();
    for (final controller in _priceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _getController(String itemId) {
    return _priceControllers.putIfAbsent(
        itemId, () => TextEditingController());
  }

  double _calculatedTotal(List<DistributorOrderItem> items) {
    double total = 0;
    for (final item in items) {
      final controller = _priceControllers[item.id];
      final price = double.tryParse(controller?.text ?? '') ?? 0;
      total += price * item.quantity;
    }
    return total;
  }

  String _getStatusLabel(String status, AppLocalizations? l10n) {
    switch (status) {
      case 'pending':
      case 'sent':
        return l10n?.distributorStatusPending ?? 'Pending';
      case 'approved':
        return l10n?.distributorStatusApproved ?? 'Approved';
      case 'rejected':
        return l10n?.distributorStatusRejected ?? 'Rejected';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
      case 'sent':
        return AppColors.warning;
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.textMuted;
    }
  }

  Future<void> _updateStatus(String newStatus, double total) async {
    setState(() => _isProcessing = true);

    final ds = ref.read(distributorDatasourceProvider);
    final itemPrices = <String, double>{};

    for (final entry in _priceControllers.entries) {
      final price = double.tryParse(entry.value.text);
      if (price != null && price > 0) {
        itemPrices[entry.key] = price;
      }
    }

    final success = await ds.updateOrderStatus(
      widget.orderId,
      newStatus,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      itemPrices: itemPrices.isNotEmpty ? itemPrices : null,
    );

    if (!mounted) return;

    setState(() => _isProcessing = false);

    final l10n = AppLocalizations.of(context);

    if (success) {
      // Invalidate to refresh
      ref.invalidate(orderDetailProvider(widget.orderId));
      ref.invalidate(orderItemsProvider(widget.orderId));
      ref.invalidate(dashboardKpisProvider);
      ref.invalidate(ordersProvider(null));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus == 'rejected'
                ? (l10n?.distributorOrderRejected ?? 'Order rejected')
                : (l10n?.distributorOrderAccepted(
                        NumberFormat('#,##0.00').format(total)) ??
                    'Order accepted'),
          ),
          backgroundColor:
              newStatus == 'rejected' ? AppColors.error : AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.distributorLoadError ?? 'Error'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;
    final isMedium = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    final orderAsync = ref.watch(orderDetailProvider(widget.orderId));
    final itemsAsync = ref.watch(orderItemsProvider(widget.orderId));

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      appBar: AppBar(
        title: orderAsync.when(
          data: (order) => Text(
            order != null
                ? (l10n?.distributorPurchaseOrder(order.purchaseNumber) ??
                    'PO #${order.purchaseNumber}')
                : '',
            style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface),
          ),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/orders'),
        ),
        actions: [
          if (orderAsync.hasValue && orderAsync.value != null)
            Container(
              margin: const EdgeInsets.symmetric(
                  horizontal: AlhaiSpacing.sm, vertical: 10),
              padding: const EdgeInsets.symmetric(
                  horizontal: AlhaiSpacing.sm, vertical: AlhaiSpacing.xxs),
              decoration: BoxDecoration(
                color: _getStatusColor(orderAsync.value!.status)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getStatusColor(orderAsync.value!.status),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _getStatusLabel(orderAsync.value!.status, l10n),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(orderAsync.value!.status),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(l10n?.distributorLoadError ?? 'Error loading data'),
        ),
        data: (order) {
          if (order == null) {
            return Center(
              child: Text(l10n?.distributorNoOrders ?? 'Order not found'),
            );
          }

          return itemsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text(l10n?.distributorLoadError ?? 'Error'),
            ),
            data: (items) {
              final total = _calculatedTotal(items);

              return SingleChildScrollView(
                padding: EdgeInsets.all(
                    isMedium ? AlhaiSpacing.lg : AlhaiSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Order Header
                    _buildOrderHeader(order, isDark, isMedium, l10n),
                    SizedBox(
                        height:
                            isMedium ? AlhaiSpacing.lg : AlhaiSpacing.md),

                    // Items
                    if (isWide)
                      _buildItemsTable(items, isDark, l10n)
                    else
                      _buildItemsCards(items, isDark, l10n),
                    SizedBox(
                        height:
                            isMedium ? AlhaiSpacing.lg : AlhaiSpacing.md),

                    // Total & Notes
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              flex: 3,
                              child: _buildNotesSection(isDark, l10n)),
                          const SizedBox(width: AlhaiSpacing.lg),
                          Expanded(
                              flex: 2,
                              child: _buildTotalSection(
                                  order, total, isDark, l10n)),
                        ],
                      )
                    else ...[
                      _buildTotalSection(order, total, isDark, l10n),
                      const SizedBox(height: AlhaiSpacing.md),
                      _buildNotesSection(isDark, l10n),
                    ],
                    const SizedBox(height: AlhaiSpacing.lg),

                    // Actions
                    if (order.status == 'sent' || order.status == 'pending')
                      _buildActionButtons(total, isDark, isMedium, l10n),
                    const SizedBox(height: AlhaiSpacing.xl),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderHeader(DistributorOrder order, bool isDark, bool isMedium,
      AppLocalizations? l10n) {
    final dateFormatted =
        DateFormat('yyyy/MM/dd - HH:mm', 'ar').format(order.createdAt);

    return Container(
      padding: EdgeInsets.all(isMedium ? AlhaiSpacing.lg : AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.store_rounded,
                    color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.storeName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                    ),
                    const SizedBox(height: AlhaiSpacing.xxs),
                    Text(
                      dateFormatted,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.getTextSecondary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: isDark ? 0.1 : 0.05),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: AppColors.info.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_rounded,
                    color: AppColors.info, size: 20),
                const SizedBox(width: 10),
                Text(
                  l10n?.distributorProposedAmount ?? 'Proposed Amount:',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
                const SizedBox(width: AlhaiSpacing.xs),
                Text(
                  '${NumberFormat('#,##0.00').format(order.total)} ${l10n?.distributorRiyal ?? 'SAR'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTable(List<DistributorOrderItem> items, bool isDark,
      AppLocalizations? l10n) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AlhaiSpacing.mdl),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AlhaiSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.list_alt_rounded,
                      color: AppColors.secondary, size: 20),
                ),
                const SizedBox(width: AlhaiSpacing.sm),
                Text(
                  l10n?.distributorOrderItems ?? 'Order Items',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    l10n?.distributorProductCount(items.length) ??
                        '${items.length} products',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Header
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AlhaiSpacing.mdl, vertical: AlhaiSpacing.sm),
            color: AppColors.getSurfaceVariant(isDark),
            child: Row(
              children: [
                _colHeader(l10n?.products ?? 'Product', 3, isDark),
                _colHeader(l10n?.quantity ?? 'Qty', 1, isDark),
                _colHeader(
                    l10n?.distributorSuggestedPrice ?? 'Suggested', 2, isDark),
                _colHeader(l10n?.distributorYourPrice ?? 'Your Price', 2, isDark),
                _colHeader(l10n?.total ?? 'Total', 2, isDark),
              ],
            ),
          ),
          // Rows
          ...List.generate(items.length, (index) {
            final item = items[index];
            final controller = _getController(item.id);
            final price = double.tryParse(controller.text) ?? 0;
            final rowTotal = price * item.quantity;

            return Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AlhaiSpacing.mdl, vertical: 14),
              decoration: BoxDecoration(
                border: index < items.length - 1
                    ? Border(
                        bottom: BorderSide(
                          color: AppColors.getBorder(isDark)
                              .withValues(alpha: 0.5),
                        ),
                      )
                    : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      item.productName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '${item.quantity}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${NumberFormat('#,##0').format(item.suggestedPrice)} ${l10n?.distributorRiyal ?? 'SAR'}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.getTextSecondary(isDark),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AlhaiSpacing.sm),
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        onChanged: (_) => setState(() {}),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.getTextPrimary(isDark),
                        ),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          hintStyle: TextStyle(
                              color: AppColors.getTextMuted(isDark)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          suffixText: l10n?.distributorRiyal ?? 'SAR',
                          suffixStyle: TextStyle(
                            fontSize: 11,
                            color: AppColors.getTextMuted(isDark),
                          ),
                          filled: true,
                          fillColor: AppColors.getSurfaceVariant(isDark),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: AppColors.getBorder(isDark)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: AppColors.getBorder(isDark)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: AppColors.primary, width: 2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      rowTotal > 0
                          ? '${NumberFormat('#,##0.00').format(rowTotal)} ${l10n?.distributorRiyal ?? 'SAR'}'
                          : '-',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: rowTotal > 0
                            ? AppColors.primary
                            : AppColors.getTextMuted(isDark),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _colHeader(String text, int flex, bool isDark) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.getTextSecondary(isDark),
        ),
      ),
    );
  }

  Widget _buildItemsCards(List<DistributorOrderItem> items, bool isDark,
      AppLocalizations? l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n?.distributorOrderItems ?? 'Order Items',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextPrimary(isDark),
              ),
            ),
            const Spacer(),
            Text(
              l10n?.distributorProductCount(items.length) ??
                  '${items.length} products',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AlhaiSpacing.sm),
        ...List.generate(items.length, (index) {
          final item = items[index];
          final controller = _getController(item.id);
          final price = double.tryParse(controller.text) ?? 0;
          final rowTotal = price * item.quantity;

          return Container(
            margin: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
            padding: const EdgeInsets.all(AlhaiSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.getSurface(isDark),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.getBorder(isDark)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.sm),
                Row(
                  children: [
                    _infoChip(l10n?.quantity ?? 'Qty', '${item.quantity}',
                        AppColors.info, isDark),
                    const SizedBox(width: 10),
                    _infoChip(
                        l10n?.distributorSuggestedPrice ?? 'Suggested',
                        '${NumberFormat('#,##0').format(item.suggestedPrice)} ${l10n?.distributorSar ?? 'SAR'}',
                        AppColors.secondary,
                        isDark),
                  ],
                ),
                const SizedBox(height: AlhaiSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: l10n?.distributorYourPrice ?? 'Your Price',
                          hintText: '0.00',
                          suffixText: l10n?.distributorRiyal ?? 'SAR',
                          filled: true,
                          fillColor: AppColors.getSurfaceVariant(isDark),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    if (rowTotal > 0) ...[
                      const SizedBox(width: AlhaiSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${NumberFormat('#,##0.00').format(rowTotal)} ${l10n?.distributorSar ?? 'SAR'}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _infoChip(String label, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ',
              style: TextStyle(
                  fontSize: 12, color: AppColors.getTextSecondary(isDark))),
          Text(value,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildTotalSection(DistributorOrder order, double total, bool isDark,
      AppLocalizations? l10n) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        gradient: total > 0
            ? LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.06),
                  AppColors.primary.withValues(alpha: isDark ? 0.08 : 0.02),
                ],
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
              )
            : null,
        color: total > 0 ? null : AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: total > 0
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.getBorder(isDark),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.calculate_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n?.distributorYourTotal ?? 'Your Total',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          Text(
            '${NumberFormat('#,##0.00').format(total)} ${l10n?.distributorRiyal ?? 'SAR'}',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color:
                  total > 0 ? AppColors.primary : AppColors.getTextMuted(isDark),
            ),
          ),
          if (total > 0 && order.total > 0) ...[
            const SizedBox(height: AlhaiSpacing.xs),
            Builder(
              builder: (_) {
                final diff = total - order.total;
                final percent = (diff / order.total * 100);
                final isLower = diff < 0;
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isLower ? AppColors.success : AppColors.warning)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isLower
                        ? (l10n?.distributorLowerThanProposed(
                                percent.abs().toStringAsFixed(1)) ??
                            '${percent.abs().toStringAsFixed(1)}% lower')
                        : (l10n?.distributorHigherThanProposed(
                                percent.toStringAsFixed(1)) ??
                            '+${percent.toStringAsFixed(1)}% higher'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isLower ? AppColors.success : AppColors.warning,
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesSection(bool isDark, AppLocalizations? l10n) {
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
          Text(
            l10n?.distributorNotesForStore ?? 'Notes for Store',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          TextField(
            controller: _notesController,
            maxLines: 4,
            style: TextStyle(color: AppColors.getTextPrimary(isDark)),
            decoration: InputDecoration(
              hintText: l10n?.distributorNotesHint ?? 'Add notes...',
              hintStyle: TextStyle(color: AppColors.getTextMuted(isDark)),
              filled: true,
              fillColor: AppColors.getSurfaceVariant(isDark),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.getBorder(isDark)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.getBorder(isDark)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.all(AlhaiSpacing.md),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      double total, bool isDark, bool isMedium, AppLocalizations? l10n) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isProcessing ? null : () => _updateStatus('rejected', total),
            icon: _isProcessing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.close_rounded, size: 20),
            label: Text(l10n?.distributorRejectOrder ?? 'Reject',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              padding:
                  EdgeInsets.symmetric(vertical: isMedium ? 16 : 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: AlhaiSpacing.md),
        Expanded(
          flex: 2,
          child: FilledButton.icon(
            onPressed: _isProcessing || total <= 0
                ? null
                : () => _updateStatus('approved', total),
            icon: _isProcessing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.textOnPrimary),
                  )
                : const Icon(Icons.check_circle_rounded, size: 20),
            label: Text(l10n?.distributorAcceptSendQuote ?? 'Accept & Send',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600)),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: AppColors.textOnPrimary,
              padding:
                  EdgeInsets.symmetric(vertical: isMedium ? 16 : 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}
