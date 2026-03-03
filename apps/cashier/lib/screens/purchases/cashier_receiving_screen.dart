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
  String? _receivingId; // purchase currently being received

  @override
  void initState() {
    super.initState();
    _loadPurchases();
  }

  Future<void> _loadPurchases() async {
    setState(() => _isLoading = true);
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;

      final purchases =
          await _db.purchasesDao.getPurchasesByStatus(storeId, 'approved');

      if (mounted) {
        setState(() {
          _purchases = purchases;
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Load purchases for receiving');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);

    return Column(
      children: [
        AppHeader(
          title: 'استلام بضاعة',
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
              ? const Center(child: CircularProgressIndicator())
              : _purchases.isEmpty
                  ? _buildEmptyState(isDark, l10n)
                  : RefreshIndicator(
                      onRefresh: _loadPurchases,
                      child: ListView.separated(
                        padding:
                            EdgeInsets.all(isMediumScreen ? 24 : 16),
                        itemCount: _purchases.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (_, index) => _buildPurchaseCard(
                            _purchases[index], isDark, isMediumScreen, l10n),
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
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_shipping_outlined,
                size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          Text(
            'لا توجد شحنات للاستلام',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ستظهر هنا الطلبات المعتمدة الجاهزة للاستلام',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _loadPurchases,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('تحديث'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseCard(PurchasesTableData purchase, bool isDark,
      bool isMedium, AppLocalizations l10n) {
    final dateStr = purchase.createdAt.day.toString().padLeft(2, '0');
    final monthStr = purchase.createdAt.month.toString().padLeft(2, '0');
    final formattedDate = '$dateStr/$monthStr/${purchase.createdAt.year}';
    final isReceiving = _receivingId == purchase.id;

    return Container(
      padding: EdgeInsets.all(isMedium ? 20 : 16),
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
                child: const Icon(Icons.local_shipping_rounded,
                    color: AppColors.info, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
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
                    const SizedBox(height: 2),
                    Text(
                      purchase.supplierName ?? 'مورد غير محدد',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.getTextSecondary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'معتمد',
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.getSurfaceVariant(isDark),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _infoItem(
                  Icons.calendar_today_rounded,
                  formattedDate,
                  isDark,
                ),
                Container(
                  width: 1,
                  height: 24,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  color: AppColors.getBorder(isDark),
                ),
                _infoItem(
                  Icons.payments_rounded,
                  '${purchase.total.toStringAsFixed(2)} ${l10n.sar}',
                  isDark,
                  valueColor: AppColors.primary,
                ),
                if (purchase.notes != null && purchase.notes!.isNotEmpty) ...[
                  Container(
                    width: 1,
                    height: 24,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
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
                  onPressed: () => _showItemsBottomSheet(purchase, isDark, l10n),
                  icon: const Icon(Icons.list_alt_rounded, size: 18),
                  label: const Text('عرض البنود',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.info,
                    side: const BorderSide(color: AppColors.info),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
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
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check_circle_rounded, size: 18),
                  label: Text(
                    isReceiving ? 'جارٍ الاستلام...' : 'تأكيد الاستلام',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String text, bool isDark,
      {Color? valueColor}) {
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
      PurchasesTableData purchase, bool isDark, AppLocalizations l10n) async {
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
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.getBorder(isDark),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Title
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.info.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.list_alt_rounded,
                              color: AppColors.info, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'بنود الطلب ${purchase.purchaseNumber}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.getTextPrimary(isDark),
                                ),
                              ),
                              Text(
                                '${items.length} منتج',
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
                              'لا توجد بنود',
                              style: TextStyle(
                                color: AppColors.getTextMuted(isDark),
                              ),
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: items.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
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
                                        color: AppColors.primary
                                            .withValues(alpha: 0.08),
                                        borderRadius:
                                            BorderRadius.circular(8),
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
                                    const SizedBox(width: 12),
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
                                                  isDark),
                                            ),
                                          ),
                                          if (item.productBarcode != null)
                                            Text(
                                              item.productBarcode!,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontFamily: 'monospace',
                                                color:
                                                    AppColors.getTextMuted(
                                                        isDark),
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
                                          '${item.unitCost.toStringAsFixed(2)} ${l10n.sar}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color:
                                                AppColors.getTextSecondary(
                                                    isDark),
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
      PurchasesTableData purchase, AppLocalizations l10n) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تأكيد استلام البضاعة'),
          content: Text(
            'هل أنت متأكد من استلام الطلب ${purchase.purchaseNumber}؟\n'
            'سيتم تحديث المخزون تلقائياً.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
              ),
              child: const Text('تأكيد الاستلام'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _receivingId = purchase.id);

    try {
      await _db.transaction(() async {
        // 1. Mark purchase as received
        await _db.purchasesDao.receivePurchase(purchase.id);

        // 2. Update stock for each item
        final items = await _db.purchasesDao.getPurchaseItems(purchase.id);
        for (final item in items) {
          final product = await _db.productsDao.getProductById(item.productId);
          if (product != null) {
            final newStock = product.stockQty + item.qty.toInt();
            await _db.productsDao.updateStock(item.productId, newStock);
          }
        }
      });

      // Audit log
      final user = ref.read(currentUserProvider);
      final storeId = ref.read(currentStoreIdProvider)!;
      final receivedItems = await _db.purchasesDao.getPurchaseItems(purchase.id);
      auditService.logStockReceive(
        storeId: storeId,
        userId: user?.id ?? 'unknown',
        userName: user?.name ?? 'unknown',
        purchaseId: purchase.id,
        purchaseNumber: purchase.purchaseNumber,
        itemCount: receivedItems.length,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم استلام الطلب ${purchase.purchaseNumber} بنجاح'),
          backgroundColor: AppColors.success,
        ),
      );

      // 3. Refresh the list
      await _loadPurchases();
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Confirm purchase receipt');
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.error_outline, color: AppColors.error, size: 48),
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
