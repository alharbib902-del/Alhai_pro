/// Cashier Receiving Screen - Receive approved purchases
///
/// Lists approved purchases for the current store.
/// Cashier can view items and confirm receipt, updating stock.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiBreakpoints, AlhaiSnackbar, AlhaiSpacing;
import 'package:uuid/uuid.dart';
// alhai_design_system is re-exported via alhai_shared_ui
import '../../core/services/sentry_service.dart';
import '../../core/services/audit_service.dart';

/// شاشة استلام بضاعة
class CashierReceivingScreen extends ConsumerStatefulWidget {
  const CashierReceivingScreen({super.key});

  @override
  ConsumerState<CashierReceivingScreen> createState() =>
      _CashierReceivingScreenState();
}

class _CashierReceivingScreenState
    extends ConsumerState<CashierReceivingScreen> {
  final _db = GetIt.I<AppDatabase>();

  List<PurchasesTableData> _purchases = [];
  bool _isLoading = true;
  String? _error;
  String? _receivingId; // purchase currently being received

  @override
  void initState() {
    super.initState();
    _loadPurchases();
  }

  Future<void> _loadPurchases() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;

      final purchases = await _db.purchasesDao.getPurchasesByStatus(
        storeId,
        'approved',
      );

      if (mounted) {
        setState(() {
          _purchases = purchases;
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Load purchases for receiving');
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
    final user = ref.watch(currentUserProvider);

    // P2: When the active store changes (e.g. multi-store user switches
    // branches from the shell), refresh the approved-purchases list so
    // the cashier doesn't keep seeing the previous branch's shipments.
    ref.listen<String?>(currentStoreIdProvider, (prev, next) {
      if (prev != next) _loadPurchases();
    });

    return Column(
      children: [
        AppHeader(
          title: l10n.receivingGoods,
          subtitle: _getDateSubtitle(l10n),
          showSearch: false,
          searchHint: l10n.searchPlaceholder,
          onMenuTap: isWideScreen
              ? null
              : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 3,
          userName: user?.name ?? l10n.cashCustomer,
          userRole: l10n.branchManager,
          onUserTap: () {},
        ),
        Expanded(
          child: _isLoading
              ? const AppLoadingState()
              : _error != null
              ? AppErrorState.general(
                  context,
                  message: _error!,
                  onRetry: _loadPurchases,
                )
              : _purchases.isEmpty
              ? _buildEmptyState(isDark, l10n)
              : RefreshIndicator(
                  onRefresh: _loadPurchases,
                  child: ListView.separated(
                    padding: EdgeInsets.all(
                      isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md,
                    ),
                    itemCount: _purchases.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AlhaiSpacing.sm),
                    itemBuilder: (_, index) => _buildPurchaseCard(
                      _purchases[index],
                      isDark,
                      isMediumScreen,
                      l10n,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  String _getDateSubtitle(AppLocalizations l10n) {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year} \u2022 ${l10n.mainBranch}';
  }

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AlhaiSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          Text(
            l10n.noShipmentsToReceive,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          Text(
            l10n.approvedOrdersAppearHere,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.lg),
          OutlinedButton.icon(
            onPressed: _loadPurchases,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(l10n.refresh),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(
                horizontal: AlhaiSpacing.lg,
                vertical: AlhaiSpacing.sm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseCard(
    PurchasesTableData purchase,
    bool isDark,
    bool isMedium,
    AppLocalizations l10n,
  ) {
    final dateStr = purchase.createdAt.day.toString().padLeft(2, '0');
    final monthStr = purchase.createdAt.month.toString().padLeft(2, '0');
    final formattedDate = '$dateStr/$monthStr/${purchase.createdAt.year}';
    final isReceiving = _receivingId == purchase.id;

    return Container(
      padding: EdgeInsets.all(isMedium ? AlhaiSpacing.mdl : AlhaiSpacing.md),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_shipping_rounded,
                  color: AppColors.info,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                // P2: Header shows purchase-number + supplier name (with
                // fallback), and the expected-receive date is already
                // rendered in the info strip below. The `attachments`
                // indicator requested in the brief has no data source —
                // purchases_table has no attachments column — so adding
                // a static icon would mislead the cashier. Wire this up
                // if/when attachments DAO lands.
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      purchase.purchaseNumber,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                    ),
                    const SizedBox(height: AlhaiSpacing.xxxs),
                    Text(
                      purchase.supplierName ?? l10n.unspecifiedSupplier,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.getTextSecondary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: AlhaiSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n.approved,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(AlhaiSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.getSurfaceVariant(isDark),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _infoItem(Icons.calendar_today_rounded, formattedDate, isDark),
                Container(
                  width: 1,
                  height: 24,
                  margin: const EdgeInsets.symmetric(
                    horizontal: AlhaiSpacing.sm,
                  ),
                  color: AppColors.getBorder(isDark),
                ),
                _infoItem(
                  Icons.payments_rounded,
                  // C-4 Session 4: purchases.total is int cents.
                  '${(purchase.total / 100.0).toStringAsFixed(2)} ${l10n.sar}',
                  isDark,
                  valueColor: AppColors.primary,
                ),
                if (purchase.notes != null && purchase.notes!.isNotEmpty) ...[
                  Container(
                    width: 1,
                    height: 24,
                    margin: const EdgeInsets.symmetric(
                      horizontal: AlhaiSpacing.sm,
                    ),
                    color: AppColors.getBorder(isDark),
                  ),
                  Expanded(
                    child: _infoItem(
                      Icons.note_rounded,
                      purchase.notes!,
                      isDark,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _showItemsBottomSheet(purchase, isDark, l10n),
                  icon: const Icon(Icons.list_alt_rounded, size: 18),
                  label: Text(
                    l10n.viewItems,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.info,
                    side: const BorderSide(color: AppColors.info),
                    padding: const EdgeInsets.symmetric(
                      vertical: AlhaiSpacing.sm,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: isReceiving
                      ? null
                      : () => _confirmReceiving(purchase, l10n),
                  icon: isReceiving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textOnPrimary,
                          ),
                        )
                      : const Icon(Icons.check_circle_rounded, size: 18),
                  label: Text(
                    isReceiving
                        ? l10n.receivingInProgress
                        : l10n.confirmReceivingBtn,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(
                      vertical: AlhaiSpacing.sm,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoItem(
    IconData icon,
    String text,
    bool isDark, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.getTextMuted(isDark)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: valueColor ?? AppColors.getTextPrimary(isDark),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showItemsBottomSheet(
    PurchasesTableData purchase,
    bool isDark,
    AppLocalizations l10n,
  ) async {
    List<PurchaseItemsTableData> items = [];
    try {
      items = await _db.purchasesDao.getPurchaseItems(purchase.id);
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Load purchase items for detail');
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsetsDirectional.only(
                      top: AlhaiSpacing.sm,
                    ),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.getBorder(isDark),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Title
                  Padding(
                    padding: const EdgeInsets.all(AlhaiSpacing.mdl),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AlhaiSpacing.xs),
                          decoration: BoxDecoration(
                            color: AppColors.info.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.list_alt_rounded,
                            color: AppColors.info,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AlhaiSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.orderItemsTitle(purchase.purchaseNumber),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.getTextPrimary(isDark),
                                ),
                              ),
                              Text(
                                l10n.productCountItems(items.length),
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
                  ),
                  const Divider(height: 1),
                  // Items list
                  Expanded(
                    child: items.isEmpty
                        ? Center(
                            child: Text(
                              l10n.noOrderItems,
                              style: TextStyle(
                                color: AppColors.getTextMuted(isDark),
                              ),
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.all(AlhaiSpacing.md),
                            itemCount: items.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: AlhaiSpacing.xs),
                            itemBuilder: (_, index) {
                              final item = items[index];
                              return Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.getSurfaceVariant(isDark),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.08,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AlhaiSpacing.sm),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.productName,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.getTextPrimary(
                                                isDark,
                                              ),
                                            ),
                                          ),
                                          if (item.productBarcode != null)
                                            Text(
                                              item.productBarcode!,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontFamily: 'monospace',
                                                color: AppColors.getTextMuted(
                                                  isDark,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${item.qty} ${l10n.unit}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        Text(
                                          // purchase_items.unitCost is int cents.
                                          CurrencyFormatter.fromCentsWithContext(
                                            context,
                                            item.unitCost,
                                          ),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.getTextSecondary(
                                              isDark,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmReceiving(
    PurchasesTableData purchase,
    AppLocalizations l10n,
  ) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(l10n.confirmReceiveGoodsTitle),
          content: Text(l10n.confirmReceiveGoodsBody(purchase.purchaseNumber)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: AppColors.textOnPrimary,
              ),
              child: Text(l10n.confirmReceivingBtn),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _receivingId = purchase.id);

    final user = ref.read(currentUserProvider);
    final storeId = ref.read(currentStoreIdProvider);
    if (storeId == null) {
      setState(() => _receivingId = null);
      return;
    }

    try {
      final receivedItems = await _db.transaction(() async {
        // 1. Mark purchase as received — DAO has an optimistic
        //    `status = 'approved'` predicate, so zero rows affected
        //    means another device already received this PO.
        final affected = await _db.purchasesDao.receivePurchase(purchase.id);
        if (affected == 0) {
          throw StateError(
            'تم استلام هذا الطلب بالفعل — يرجى تحديث القائمة',
          );
        }

        // 2. Update stock + record audit movement for each item.
        //    item.qty is RealColumn (double) — `.toInt()` was truncating
        //    fractional units (e.g. 12.5 kg → 12). Use the double directly.
        //    Also record an inventory_movements row so the receive shows
        //    up in stock-history reports.
        // Wave 7 (P0-19/20/21): canonical 'receive' + WAVG cost roll-up
        // for purchase-order receipts. The PO carries unit cost on each
        // item, so this is the canonical place to seed accurate WAVG —
        // older receivings overwrote `cost_price` with whatever the
        // last PO line said.
        final items = await _db.purchasesDao.getPurchaseItems(purchase.id);
        for (final item in items) {
          final product = await _db.productsDao.getProductById(item.productId);
          if (product == null) continue;
          final previousQty = product.stockQty;
          final unitCostCents = item.unitCost;
          await _db.inventoryDao.recordReceiveMovement(
            id: const Uuid().v4(),
            productId: item.productId,
            storeId: storeId,
            qty: item.qty,
            previousQty: previousQty,
            referenceType: 'purchase_order',
            referenceId: purchase.id,
            unitCostCents: unitCostCents,
            userId: user?.id,
          );
          await _db.productsDao.applyReceiveAndRecomputeCost(
            productId: item.productId,
            qty: item.qty,
            unitCostCents: unitCostCents,
          );
          // P0-27: persist the line-level receivedQty so partial-receive
          // reports + any future re-receive guard can read accurate
          // counts. Pre-fix the column stayed at its 0 default forever.
          await _db.purchasesDao.markItemReceived(
            itemId: item.id,
            receivedQty: item.qty,
          );
        }
        return items;
      });

      // Audit log (outside DB transaction — non-transactional sink).
      auditService.logStockReceive(
        storeId: storeId,
        userId: user?.id ?? 'unknown',
        userName: user?.name ?? 'unknown',
        purchaseId: purchase.id,
        purchaseNumber: purchase.purchaseNumber,
        itemCount: receivedItems.length,
      );

      if (!mounted) return;

      AlhaiSnackbar.success(
        context,
        l10n.orderReceivedSuccess(purchase.purchaseNumber),
      );

      // 3. Refresh the list
      await _loadPurchases();
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Confirm purchase receipt');
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 48,
          ),
          title: Text(l10n.error),
          content: Text(l10n.errorWithDetails('$e')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.close),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _receivingId = null);
    }
  }
}
