/// Distributor Order Detail Screen
///
/// Shows purchase order details. Distributor can:
/// - View order items and suggested prices
/// - Set their own prices for each item
/// - Accept and send quote or reject the order
/// Data from Supabase via Riverpod providers.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:intl/intl.dart' show NumberFormat;

import '../../core/utils/date_helper.dart';
import 'package:alhai_zatca/alhai_zatca.dart' show VatCalculator;
import '../../data/models.dart';
import '../../providers/distributor_providers.dart';
import '../../ui/shared_widgets.dart' show responsivePadding, kMaxContentWidth;
import '../../ui/skeleton_loading.dart';

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

  /// Track the last known item IDs to detect changes and clean up stale controllers.
  Set<String> _lastKnownItemIds = {};

  @override
  void dispose() {
    _notesController.dispose();
    for (final controller in _priceControllers.values) {
      controller.dispose();
    }
    _priceControllers.clear();
    super.dispose();
  }

  /// Track which items have been auto-filled with tier discount price
  /// to avoid overwriting user edits on rebuild.
  final Set<String> _autoFilledItems = {};

  TextEditingController _getController(String itemId) {
    return _priceControllers.putIfAbsent(itemId, () => TextEditingController());
  }

  /// Pre-fill a controller with the tier-discounted price if not already filled.
  void _autoFillWithDiscount(
    String itemId,
    double suggestedPrice,
    double discountPercent,
  ) {
    if (_autoFilledItems.contains(itemId)) return;
    final controller = _getController(itemId);
    if (controller.text.isNotEmpty) return;
    if (discountPercent <= 0) return;

    final discountedPrice = suggestedPrice * (1 - discountPercent / 100);
    controller.text = discountedPrice.toStringAsFixed(2);
    _autoFilledItems.add(itemId);
  }

  /// Synchronize controllers with the current item list,
  /// disposing controllers for removed items.
  void _syncControllers(List<DistributorOrderItem> items) {
    final currentIds = items.map((i) => i.id).toSet();
    if (!_lastKnownItemIds.containsAll(currentIds) ||
        !currentIds.containsAll(_lastKnownItemIds)) {
      // Dispose controllers for items that no longer exist
      final removed = _lastKnownItemIds.difference(currentIds);
      for (final id in removed) {
        _priceControllers[id]?.dispose();
        _priceControllers.remove(id);
      }
      _lastKnownItemIds = currentIds;
    }
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
      case 'preparing':
        return 'قيد التحضير';
      case 'packed':
        return 'تم التغليف';
      case 'shipped':
        return 'تم الشحن';
      case 'delivered':
        return 'تم التسليم';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status, bool isDark) {
    return AppColors.getStatusColor(status, isDark);
  }

  /// Show a confirmation dialog before performing a destructive action.
  Future<bool> _showConfirmationDialog({
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
  }) async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: confirmColor),
            child: Text(
              confirmLabel,
              style: const TextStyle(color: AppColors.textOnPrimary),
            ),
          ),
        ],
      ),
    );
    return result == true;
  }

  Future<void> _confirmAndUpdateStatus(String newStatus, double total) async {
    final l10n = AppLocalizations.of(context);

    if (newStatus == 'rejected') {
      final confirmed = await _showConfirmationDialog(
        title: l10n.distributorRejectOrder,
        message:
            'Are you sure you want to reject this order? This action cannot be undone.',
        confirmLabel: l10n.distributorRejectOrder,
        confirmColor: AppColors.error,
      );
      if (!confirmed) return;
    } else if (newStatus == 'approved') {
      final confirmed = await _showConfirmationDialog(
        title: l10n.distributorAcceptSendQuote,
        message:
            'Are you sure you want to approve this order with a total of ${NumberFormat('#,##0.00').format(total)} SAR?',
        confirmLabel: l10n.distributorAcceptSendQuote,
        confirmColor: AppColors.success,
      );
      if (!confirmed) return;
    }

    await _updateStatus(newStatus, total);
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

    try {
      await ds.updateOrderStatus(
        widget.orderId,
        newStatus,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        itemPrices: itemPrices.isNotEmpty ? itemPrices : null,
      );

      if (!mounted) return;

      setState(() => _isProcessing = false);

      final l10n = AppLocalizations.of(context);

      // Only invalidate the specific providers for this order.
      // Dashboard and order list will refresh when navigated to.
      ref.invalidate(orderDetailProvider(widget.orderId));
      ref.invalidate(orderItemsProvider(widget.orderId));

      // Show SnackBar with Undo action (revert within 5 seconds)
      const previousStatus = 'sent'; // Orders are 'sent' before action
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus == 'rejected'
                ? l10n.distributorOrderRejected
                : l10n.distributorOrderAccepted(
                    NumberFormat('#,##0.00').format(total),
                  ),
          ),
          backgroundColor: newStatus == 'rejected'
              ? AppColors.error
              : AppColors.success,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: l10n.undo,
            textColor: AppColors.textOnPrimary,
            onPressed: () async {
              // Revert the status back
              try {
                final revertDs = ref.read(distributorDatasourceProvider);
                await revertDs.updateOrderStatus(
                  widget.orderId,
                  previousStatus,
                );
                if (mounted) {
                  ref.invalidate(orderDetailProvider(widget.orderId));
                  ref.invalidate(orderItemsProvider(widget.orderId));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.distributorActionUndone),
                      backgroundColor: AppColors.info,
                    ),
                  );
                }
              } catch (_) {
                // Undo failed silently — original action already applied
              }
            },
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.distributorLoadError),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= AlhaiBreakpoints.desktop;
    final isMedium = size.width >= AlhaiBreakpoints.tablet;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final rPadding = responsivePadding(size.width);

    final orderAsync = ref.watch(orderDetailProvider(widget.orderId));
    final itemsAsync = ref.watch(orderItemsProvider(widget.orderId));

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.escape): () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/orders');
          }
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: AppColors.getBackground(isDark),
          appBar: AppBar(
            title: orderAsync.when(
              data: (order) => Text(
                order != null
                    ? l10n.distributorPurchaseOrder(order.purchaseNumber)
                    : '',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            centerTitle: false,
            leading: Semantics(
              button: true,
              label: l10n.distributorOrders,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () =>
                    context.canPop() ? context.pop() : context.go('/orders'),
              ),
            ),
            actions: [
              if (orderAsync.hasValue && orderAsync.value != null)
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: AlhaiSpacing.sm,
                    vertical: AlhaiSpacing.xs,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AlhaiSpacing.sm,
                    vertical: AlhaiSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      orderAsync.value!.status,
                      isDark,
                    ).withValues(alpha: isDark ? 0.2 : 0.12),
                    borderRadius: BorderRadius.circular(AlhaiRadius.xl),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getStatusColor(
                            orderAsync.value!.status,
                            isDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getStatusLabel(orderAsync.value!.status, l10n),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(
                            orderAsync.value!.status,
                            isDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          body: orderAsync.when(
            loading: () => const TableSkeleton(rows: 6, columns: 4),
            error: (e, _) => Center(child: Text(l10n.distributorLoadError)),
            data: (order) {
              if (order == null) {
                return Center(child: Text(l10n.distributorNoOrders));
              }

              // Watch tier discount for this store (returns 0 if unavailable)
              final discountAsync = ref.watch(
                storeDiscountProvider(order.storeId),
              );
              final discountPercent = discountAsync.valueOrNull ?? 0.0;

              return itemsAsync.when(
                loading: () => const TableSkeleton(rows: 4, columns: 4),
                error: (e, _) => Center(child: Text(l10n.distributorLoadError)),
                data: (items) {
                  // Sync controllers: dispose stale ones, prepare for current items
                  _syncControllers(items);

                  // Auto-fill controllers with tier-discounted prices
                  if (discountPercent > 0) {
                    for (final item in items) {
                      _autoFillWithDiscount(
                        item.id,
                        item.suggestedPrice,
                        discountPercent,
                      );
                    }
                  }

                  final total = _calculatedTotal(items);

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(rPadding),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: kMaxContentWidth,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Breadcrumb navigation
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: AlhaiSpacing.md,
                              ),
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () => context.go('/orders'),
                                    borderRadius: BorderRadius.circular(
                                      AlhaiRadius.xs,
                                    ),
                                    child: Text(
                                      l10n.distributorOrders,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Icon(
                                      Icons.chevron_right,
                                      size: 18,
                                      color: AppColors.getTextMuted(isDark),
                                    ),
                                  ),
                                  Text(
                                    '${l10n.distributorOrderNumber} #${order.purchaseNumber}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.getTextSecondary(isDark),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Order Header
                            _buildOrderHeader(order, isDark, isMedium, l10n),
                            SizedBox(
                              height: isMedium
                                  ? AlhaiSpacing.lg
                                  : AlhaiSpacing.md,
                            ),

                            // Tier discount banner
                            if (discountPercent > 0)
                              _buildTierDiscountBanner(
                                discountPercent,
                                order.storeName,
                                isDark,
                              ),

                            // Items
                            if (isWide)
                              _buildItemsTable(items, isDark, l10n)
                            else
                              _buildItemsCards(items, isDark, l10n),
                            SizedBox(
                              height: isMedium
                                  ? AlhaiSpacing.lg
                                  : AlhaiSpacing.md,
                            ),

                            // Total & Notes
                            if (isWide)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: _buildNotesSection(isDark, l10n),
                                  ),
                                  const SizedBox(width: AlhaiSpacing.lg),
                                  Expanded(
                                    flex: 2,
                                    child: _buildTotalSection(
                                      order,
                                      total,
                                      isDark,
                                      l10n,
                                    ),
                                  ),
                                ],
                              )
                            else ...[
                              _buildTotalSection(order, total, isDark, l10n),
                              const SizedBox(height: AlhaiSpacing.md),
                              _buildNotesSection(isDark, l10n),
                            ],
                            const SizedBox(height: AlhaiSpacing.lg),

                            // Actions
                            if (order.status == 'sent' ||
                                order.status == 'pending')
                              _buildActionButtons(
                                total,
                                isDark,
                                isMedium,
                                l10n,
                              ),

                            // Post-approval workflow timeline
                            if (order.status == 'approved' ||
                                isPostApprovalStatus(order.status))
                              _buildWorkflowTimeline(order, isDark),

                            // Post-approval next action button
                            if (order.status == 'approved' ||
                                isPostApprovalStatus(order.status))
                              _buildWorkflowActionButton(order, isDark),

                            // Invoice action (for approved/received/post-approval orders)
                            if (order.status == 'approved' ||
                                order.status == 'received' ||
                                isPostApprovalStatus(order.status))
                              _buildInvoiceAction(order, isDark),
                            const SizedBox(height: AlhaiSpacing.xl),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOrderHeader(
    DistributorOrder order,
    bool isDark,
    bool isMedium,
    AppLocalizations? l10n,
  ) {
    final dateFormatted = DateHelper.dualWithTime(order.createdAt);

    return Container(
      padding: EdgeInsets.all(isMedium ? AlhaiSpacing.lg : AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(AlhaiRadius.lg),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: isDark ? 0.2 : 0.1,
                  ),
                  borderRadius: BorderRadius.circular(AlhaiRadius.md),
                ),
                child: ExcludeSemantics(
                  child: const Icon(
                    Icons.store_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
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
            padding: const EdgeInsets.all(AlhaiSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: isDark ? 0.15 : 0.05),
              borderRadius: BorderRadius.circular(AlhaiRadius.md),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                ExcludeSemantics(
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: AppColors.info,
                    size: 20,
                  ),
                ),
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

  Widget _buildTierDiscountBanner(
    double discountPercent,
    String storeName,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.md),
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: isDark ? 0.1 : 0.05),
        borderRadius: BorderRadius.circular(AlhaiRadius.md),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.discount_outlined, color: AppColors.success, size: 20),
          const SizedBox(width: AlhaiSpacing.sm),
          Expanded(
            child: Text(
              'فئة سعرية مطبّقة: خصم ${discountPercent.toStringAsFixed(discountPercent.truncateToDouble() == discountPercent ? 0 : 2)}% '
              'على متجر $storeName — الأسعار معبّأة تلقائياً (قابلة للتعديل)',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.getTextSecondary(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTable(
    List<DistributorOrderItem> items,
    bool isDark,
    AppLocalizations? l10n,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(AlhaiRadius.lg),
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
                    color: AppColors.secondary.withValues(
                      alpha: isDark ? 0.2 : 0.1,
                    ),
                    borderRadius: BorderRadius.circular(AlhaiRadius.sm + 2),
                  ),
                  child: ExcludeSemantics(
                    child: const Icon(
                      Icons.list_alt_rounded,
                      color: AppColors.secondary,
                      size: 20,
                    ),
                  ),
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
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(
                      alpha: isDark ? 0.2 : 0.1,
                    ),
                    borderRadius: BorderRadius.circular(AlhaiRadius.sm),
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
              horizontal: AlhaiSpacing.mdl,
              vertical: AlhaiSpacing.sm,
            ),
            color: AppColors.getSurfaceVariant(isDark),
            child: Row(
              children: [
                _colHeader(l10n?.products ?? 'Product', 3, isDark),
                _colHeader(l10n?.quantity ?? 'Qty', 1, isDark),
                _colHeader(
                  l10n?.distributorSuggestedPrice ?? 'Suggested',
                  2,
                  isDark,
                ),
                _colHeader(
                  l10n?.distributorYourPrice ?? 'Your Price',
                  2,
                  isDark,
                ),
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
                horizontal: AlhaiSpacing.mdl,
                vertical: AlhaiSpacing.sm,
              ),
              decoration: BoxDecoration(
                border: index < items.length - 1
                    ? Border(
                        bottom: BorderSide(
                          color: AppColors.getBorder(
                            isDark,
                          ).withValues(alpha: 0.5),
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
                        horizontal: AlhaiSpacing.sm,
                      ),
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
                            color: AppColors.getTextMuted(isDark),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          suffixText: l10n?.distributorRiyal ?? 'SAR',
                          suffixStyle: TextStyle(
                            fontSize: 11,
                            color: AppColors.getTextMuted(isDark),
                          ),
                          filled: true,
                          fillColor: AppColors.getSurfaceVariant(isDark),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AlhaiRadius.sm + 2,
                            ),
                            borderSide: BorderSide(
                              color: AppColors.getBorder(isDark),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AlhaiRadius.sm + 2,
                            ),
                            borderSide: BorderSide(
                              color: AppColors.getBorder(isDark),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AlhaiRadius.sm + 2,
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
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

  Widget _buildItemsCards(
    List<DistributorOrderItem> items,
    bool isDark,
    AppLocalizations? l10n,
  ) {
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
              borderRadius: BorderRadius.circular(AlhaiRadius.md + 2),
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
                    _infoChip(
                      l10n?.quantity ?? 'Qty',
                      '${item.quantity}',
                      AppColors.info,
                      isDark,
                    ),
                    const SizedBox(width: 10),
                    _infoChip(
                      l10n?.distributorSuggestedPrice ?? 'Suggested',
                      '${NumberFormat('#,##0').format(item.suggestedPrice)} ${l10n?.distributorSar ?? 'SAR'}',
                      AppColors.secondary,
                      isDark,
                    ),
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
                            borderRadius: BorderRadius.circular(
                              AlhaiRadius.sm + 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (rowTotal > 0) ...[
                      const SizedBox(width: AlhaiSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(
                            AlhaiRadius.sm + 2,
                          ),
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
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.xs,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.06),
        borderRadius: BorderRadius.circular(AlhaiRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSection(
    DistributorOrder order,
    double total,
    bool isDark,
    AppLocalizations? l10n,
  ) {
    // `total` is treated as net (pre-VAT), matching prior local impl semantics.
    final vatBreakdown = VatCalculator.breakdownFromNet(netAmount: total);
    final fmt = NumberFormat('#,##0.00');
    final riyal = l10n?.distributorRiyal ?? 'SAR';

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
        borderRadius: BorderRadius.circular(AlhaiRadius.lg),
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
                  borderRadius: BorderRadius.circular(AlhaiRadius.sm + 2),
                ),
                child: ExcludeSemantics(
                  child: const Icon(
                    Icons.calculate_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
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
          // Subtotal
          if (total > 0) ...[
            _buildTotalRow(
              'المجموع الفرعي',
              '${fmt.format(vatBreakdown.netAmount)} $riyal',
              isDark,
            ),
            const SizedBox(height: AlhaiSpacing.xs),
            _buildTotalRow(
              'ضريبة القيمة المضافة 15%',
              '${fmt.format(vatBreakdown.vatAmount)} $riyal',
              isDark,
              isVat: true,
            ),
            const Divider(height: AlhaiSpacing.md),
          ],
          // Grand total with VAT
          Text(
            '${fmt.format(vatBreakdown.grossAmount)} $riyal',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: total > 0
                  ? AppColors.primary
                  : AppColors.getTextMuted(isDark),
            ),
          ),
          if (total > 0)
            Text(
              'شامل ضريبة القيمة المضافة 15%',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.getTextMuted(isDark),
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
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (isLower ? AppColors.success : AppColors.warning)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AlhaiRadius.sm),
                  ),
                  child: Text(
                    isLower
                        ? (l10n?.distributorLowerThanProposed(
                                percent.abs().toStringAsFixed(1),
                              ) ??
                              '${percent.abs().toStringAsFixed(1)}% lower')
                        : (l10n?.distributorHigherThanProposed(
                                percent.toStringAsFixed(1),
                              ) ??
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

  Widget _buildTotalRow(
    String label,
    String value,
    bool isDark, {
    bool isVat = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isVat ? AppColors.info : AppColors.getTextSecondary(isDark),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isVat ? AppColors.info : AppColors.getTextPrimary(isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection(bool isDark, AppLocalizations? l10n) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(AlhaiRadius.lg),
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
            maxLength: 500,
            style: TextStyle(color: AppColors.getTextPrimary(isDark)),
            decoration: InputDecoration(
              hintText: l10n?.distributorNotesHint ?? 'Add notes...',
              hintStyle: TextStyle(color: AppColors.getTextMuted(isDark)),
              filled: true,
              fillColor: AppColors.getSurfaceVariant(isDark),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AlhaiRadius.md),
                borderSide: BorderSide(color: AppColors.getBorder(isDark)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AlhaiRadius.md),
                borderSide: BorderSide(color: AppColors.getBorder(isDark)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AlhaiRadius.md),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(AlhaiSpacing.md),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    double total,
    bool isDark,
    bool isMedium,
    AppLocalizations? l10n,
  ) {
    return Row(
      children: [
        Expanded(
          child: Semantics(
            button: true,
            label: l10n?.distributorRejectOrder ?? 'Reject this order',
            child: OutlinedButton.icon(
              onPressed: _isProcessing
                  ? null
                  : () => _confirmAndUpdateStatus('rejected', total),
              icon: _isProcessing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.close_rounded, size: 20),
              label: Text(
                l10n?.distributorRejectOrder ?? 'Reject',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: EdgeInsets.symmetric(vertical: isMedium ? 16 : 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AlhaiRadius.md),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AlhaiSpacing.md),
        Expanded(
          flex: 2,
          child: Semantics(
            button: true,
            label: l10n?.distributorAcceptSendQuote ?? 'Accept and send quote',
            child: FilledButton.icon(
              onPressed: _isProcessing || total <= 0
                  ? null
                  : () => _confirmAndUpdateStatus('approved', total),
              icon: _isProcessing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textOnPrimary,
                      ),
                    )
                  : const Icon(Icons.check_circle_rounded, size: 20),
              label: Text(
                l10n?.distributorAcceptSendQuote ?? 'Accept & Send',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: AppColors.textOnPrimary,
                padding: EdgeInsets.symmetric(vertical: isMedium ? 16 : 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AlhaiRadius.md),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Invoice action for approved/received orders ───────────────

  Widget _buildInvoiceAction(DistributorOrder order, bool isDark) {
    final invoiceAsync = ref.watch(invoiceByOrderProvider(order.id));

    return invoiceAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (existingInvoice) {
        if (existingInvoice != null) {
          // Invoice exists — show "View Invoice" button
          return Padding(
            padding: const EdgeInsets.only(top: AlhaiSpacing.sm),
            child: FilledButton.icon(
              onPressed: () => context.go('/invoices/${existingInvoice.id}'),
              icon: const Icon(Icons.receipt_long, size: 20),
              label: const Text(
                'عرض الفاتورة',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AlhaiRadius.md),
                ),
              ),
            ),
          );
        }

        // No invoice yet — show "Generate Invoice" button
        return Padding(
          padding: const EdgeInsets.only(top: AlhaiSpacing.sm),
          child: FilledButton.icon(
            onPressed: _isProcessing ? null : () => _generateInvoice(order),
            icon: _isProcessing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.textOnPrimary,
                    ),
                  )
                : const Icon(Icons.receipt, size: 20),
            label: const Text(
              'إنشاء فاتورة',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.info,
              foregroundColor: AppColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AlhaiRadius.md),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Post-approval workflow timeline ──────────────────────────

  Widget _buildWorkflowTimeline(DistributorOrder order, bool isDark) {
    const stages = ['approved', 'preparing', 'packed', 'shipped', 'delivered'];
    final currentIndex = stages.indexOf(order.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: AlhaiSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AlhaiSpacing.mdl),
        decoration: BoxDecoration(
          color: AppColors.getSurface(isDark),
          borderRadius: BorderRadius.circular(AlhaiRadius.lg),
          border: Border.all(color: AppColors.getBorder(isDark)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مراحل تنفيذ الطلب',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextPrimary(isDark),
              ),
            ),
            const SizedBox(height: AlhaiSpacing.md),
            Row(
              children: List.generate(stages.length * 2 - 1, (i) {
                if (i.isOdd) {
                  // Connector line
                  final stageIdx = i ~/ 2;
                  final isDone = stageIdx < currentIndex;
                  return Expanded(
                    child: Container(
                      height: 3,
                      color: isDone
                          ? AppColors.success
                          : AppColors.getBorder(isDark),
                    ),
                  );
                }
                final stageIdx = i ~/ 2;
                final isDone = stageIdx <= currentIndex;
                final isCurrent = stageIdx == currentIndex;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: isCurrent ? 28 : 22,
                      height: isCurrent ? 28 : 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone
                            ? AppColors.success
                            : AppColors.getSurfaceVariant(isDark),
                        border: isCurrent
                            ? Border.all(color: AppColors.success, width: 3)
                            : null,
                      ),
                      child: isDone
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      workflowStatusLabel(stages[stageIdx]),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isCurrent
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isDone
                            ? AppColors.success
                            : AppColors.getTextMuted(isDark),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkflowActionButton(DistributorOrder order, bool isDark) {
    final nextStatus = nextWorkflowStatus(order.status);
    if (nextStatus == null) return const SizedBox.shrink();

    final labels = {
      'preparing': 'بدء التحضير',
      'packed': 'تم التغليف',
      'shipped': 'تم الشحن',
      'delivered': 'تم التسليم',
    };
    final icons = {
      'preparing': Icons.kitchen_rounded,
      'packed': Icons.inventory_2_rounded,
      'shipped': Icons.local_shipping_rounded,
      'delivered': Icons.check_circle_rounded,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: AlhaiSpacing.md),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: _isProcessing
              ? null
              : () async {
                  final confirmed = await _showConfirmationDialog(
                    title: labels[nextStatus] ?? nextStatus,
                    message:
                        'هل تريد تحديث حالة الطلب إلى "${workflowStatusLabel(nextStatus)}"؟',
                    confirmLabel: labels[nextStatus] ?? nextStatus,
                    confirmColor: AppColors.primary,
                  );
                  if (!confirmed) return;
                  await _updateStatus(nextStatus, order.total);
                },
          icon: _isProcessing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.textOnPrimary,
                  ),
                )
              : Icon(icons[nextStatus] ?? Icons.arrow_forward, size: 20),
          label: Text(
            labels[nextStatus] ?? nextStatus,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AlhaiRadius.md),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _generateInvoice(DistributorOrder order) async {
    setState(() => _isProcessing = true);
    try {
      final invoiceService = ref.read(invoiceServiceProvider);
      final ds = ref.read(distributorDatasourceProvider);

      // Fetch the items for this order
      final items = await ds.getOrderItems(order.id);
      final orgSettings = await ds.getOrgSettings();
      if (orgSettings == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لم يتم العثور على إعدادات المنشأة'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      final invoice = await invoiceService.generateInvoiceFromOrder(
        order: order,
        items: items,
        orgSettings: orgSettings,
      );

      if (!mounted) return;

      // Invalidate providers so lists refresh
      ref.invalidate(invoicesProvider(null));
      ref.invalidate(invoiceByOrderProvider(order.id));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إنشاء الفاتورة ${invoice.invoiceNumber}'),
          backgroundColor: AppColors.success,
        ),
      );

      // Navigate to the new invoice
      context.go('/invoices/${invoice.id}');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في إنشاء الفاتورة: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}
