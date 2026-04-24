/// Cashier Purchase Request Screen - Quick purchase request
///
/// Allows cashier to search products from DB, add them to a request list,
/// specify quantities, add notes, and submit as a draft purchase.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiBreakpoints, AlhaiSnackbar, AlhaiSpacing;
// alhai_design_system is re-exported via alhai_shared_ui
import '../../core/services/sentry_service.dart';
import '../../core/services/audit_service.dart';
import '../../core/services/haptic_shim.dart';
import '../../core/services/sound_service.dart';

const _uuid = Uuid();

// ─── Request Item Model ──────────────────────────────────────────

class _RequestItem {
  final ProductsTableData product;
  final TextEditingController qtyController;

  _RequestItem({required this.product})
    : qtyController = TextEditingController(text: '1');

  int get quantity => int.tryParse(qtyController.text) ?? 0;

  void dispose() {
    qtyController.dispose();
  }
}

// ─── Screen ──────────────────────────────────────────────────────

/// شاشة طلب شراء سريع
class CashierPurchaseRequestScreen extends ConsumerStatefulWidget {
  const CashierPurchaseRequestScreen({super.key});

  @override
  ConsumerState<CashierPurchaseRequestScreen> createState() =>
      _CashierPurchaseRequestScreenState();
}

class _CashierPurchaseRequestScreenState
    extends ConsumerState<CashierPurchaseRequestScreen> {
  final _db = GetIt.I<AppDatabase>();
  final _searchController = TextEditingController();
  final _notesController = TextEditingController();

  List<ProductsTableData> _searchResults = [];
  final List<_RequestItem> _requestItems = [];
  bool _isSearching = false;
  bool _isSending = false;

  @override
  void dispose() {
    _searchController.dispose();
    _notesController.dispose();
    for (final item in _requestItems) {
      item.dispose();
    }
    super.dispose();
  }

  Future<void> _searchProducts(String query) async {
    if (query.length < 2) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;
      final products = await _db.productsDao.searchProducts(query, storeId);
      if (mounted) {
        // Exclude already added products
        final addedIds = _requestItems.map((i) => i.product.id).toSet();
        setState(() {
          _searchResults = products
              .where((p) => !addedIds.contains(p.id))
              .toList();
          _isSearching = false;
        });
      }
    } catch (e, stack) {
      reportError(
        e,
        stackTrace: stack,
        hint: 'Search products for purchase request',
      );
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _addProduct(ProductsTableData product) {
    setState(() {
      _requestItems.add(_RequestItem(product: product));
      _searchResults = [];
      _searchController.clear();
    });
  }

  void _removeProduct(int index) {
    setState(() {
      _requestItems[index].dispose();
      _requestItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width >= AlhaiBreakpoints.desktop;
    final isMediumScreen = size.width >= AlhaiBreakpoints.tablet;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);

    return Column(
      children: [
        AppHeader(
          title: l10n.quickPurchaseRequest,
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
          child: SingleChildScrollView(
            padding: EdgeInsets.all(
              isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md,
            ),
            child: isWideScreen
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            _buildSearchSection(isDark, l10n),
                            const SizedBox(height: AlhaiSpacing.lg),
                            _buildItemsList(isDark, l10n),
                          ],
                        ),
                      ),
                      const SizedBox(width: AlhaiSpacing.lg),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            _buildSummaryCard(isDark, l10n),
                            const SizedBox(height: AlhaiSpacing.lg),
                            _buildNotesSection(isDark, l10n),
                            const SizedBox(height: AlhaiSpacing.lg),
                            _buildSendButton(isDark, l10n),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSearchSection(isDark, l10n),
                      SizedBox(
                        height: isMediumScreen
                            ? AlhaiSpacing.lg
                            : AlhaiSpacing.md,
                      ),
                      _buildItemsList(isDark, l10n),
                      SizedBox(
                        height: isMediumScreen
                            ? AlhaiSpacing.lg
                            : AlhaiSpacing.md,
                      ),
                      _buildSummaryCard(isDark, l10n),
                      const SizedBox(height: AlhaiSpacing.md),
                      _buildNotesSection(isDark, l10n),
                      const SizedBox(height: AlhaiSpacing.lg),
                      _buildSendButton(isDark, l10n),
                      const SizedBox(height: AlhaiSpacing.xl),
                    ],
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

  // ─── Search Section ────────────────────────────────────────────

  Widget _buildSearchSection(bool isDark, AppLocalizations l10n) {
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
                child: const Icon(
                  Icons.search_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n.searchProduct,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          TextField(
            controller: _searchController,
            onChanged: _searchProducts,
            style: TextStyle(color: AppColors.getTextPrimary(isDark)),
            decoration: InputDecoration(
              hintText: l10n.searchByNameOrBarcode,
              hintStyle: TextStyle(color: AppColors.getTextMuted(isDark)),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: AppColors.getTextMuted(isDark),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppColors.getTextMuted(isDark),
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchResults = []);
                      },
                      tooltip: l10n.clearField,
                    )
                  : null,
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
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AlhaiSpacing.md,
                vertical: 14,
              ),
            ),
          ),
          if (_isSearching)
            const Padding(
              padding: EdgeInsetsDirectional.only(top: AlhaiSpacing.sm),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (_searchResults.isNotEmpty)
            Container(
              margin: const EdgeInsetsDirectional.only(top: AlhaiSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.getSurfaceVariant(isDark),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.getBorder(isDark)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: _searchResults.take(5).map((product) {
                  return InkWell(
                    onTap: () => _addProduct(product),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AlhaiSpacing.md,
                        vertical: AlhaiSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.getBorder(
                              isDark,
                            ).withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.inventory_2_outlined,
                              color: AppColors.primary,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: AlhaiSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.getTextPrimary(isDark),
                                  ),
                                ),
                                Text(
                                  '${l10n.stock}: ${product.stockQty}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _getStockColor(product.stockQty),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.add_circle_outline_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Color _getStockColor(double qty) {
    if (qty <= 0) return AppColors.error;
    if (qty < 10) return AppColors.warning;
    return AppColors.success;
  }

  // ─── Items List ────────────────────────────────────────────────

  Widget _buildItemsList(bool isDark, AppLocalizations l10n) {
    if (_requestItems.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AlhaiSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.getSurface(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.getBorder(isDark),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.add_shopping_cart_rounded,
              size: 48,
              color: AppColors.getTextMuted(isDark),
            ),
            const SizedBox(height: AlhaiSpacing.sm),
            Text(
              l10n.searchAndAddProducts,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.getTextSecondary(isDark),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AlhaiSpacing.md),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AlhaiSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.shopping_cart_rounded,
                    color: AppColors.secondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AlhaiSpacing.sm),
                Text(
                  l10n.requestedProducts,
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
                    vertical: AlhaiSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    l10n.productCountItems(_requestItems.length),
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
          ...List.generate(_requestItems.length, (index) {
            final item = _requestItems[index];
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AlhaiSpacing.md,
                vertical: AlhaiSpacing.sm,
              ),
              decoration: BoxDecoration(
                border: index < _requestItems.length - 1
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.getTextPrimary(isDark),
                          ),
                        ),
                        const SizedBox(height: AlhaiSpacing.xxxs),
                        Row(
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 12,
                              color: _getStockColor(item.product.stockQty),
                            ),
                            const SizedBox(width: AlhaiSpacing.xxs),
                            Text(
                              '${l10n.currentStock}: ${item.product.stockQty}',
                              style: TextStyle(
                                fontSize: 12,
                                color: _getStockColor(item.product.stockQty),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AlhaiSpacing.sm),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: item.qtyController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      onChanged: (_) => setState(() {}),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AlhaiSpacing.xs,
                          vertical: 10,
                        ),
                        filled: true,
                        fillColor: AppColors.getSurfaceVariant(isDark),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: AppColors.getBorder(isDark),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: AppColors.getBorder(isDark),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AlhaiSpacing.xs),
                  IconButton(
                    onPressed: () => _removeProduct(index),
                    icon: const Icon(Icons.delete_outline_rounded, size: 20),
                    color: AppColors.error,
                    visualDensity: VisualDensity.compact,
                    tooltip: l10n.delete,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── Summary Card ──────────────────────────────────────────────

  Widget _buildSummaryCard(bool isDark, AppLocalizations l10n) {
    final totalItems = _requestItems.length;
    final totalQty = _requestItems.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: isDark ? 0.1 : 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
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
                child: const Icon(
                  Icons.summarize_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n.orderSummary,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          Row(
            children: [
              Expanded(
                child: _summaryItem(
                  l10n.productCountSummary,
                  '$totalItems',
                  AppColors.info,
                  isDark,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Expanded(
                child: _summaryItem(
                  l10n.totalQuantitySummary,
                  '$totalQty',
                  AppColors.secondary,
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xxs),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Notes Section ─────────────────────────────────────────────

  Widget _buildNotesSection(bool isDark, AppLocalizations l10n) {
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
                child: const Icon(
                  Icons.note_alt_rounded,
                  color: AppColors.info,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n.noteLabel,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          TextField(
            controller: _notesController,
            maxLines: 3,
            style: TextStyle(color: AppColors.getTextPrimary(isDark)),
            decoration: InputDecoration(
              hintText: l10n.addNotesForManager,
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

  // ─── Send Button ───────────────────────────────────────────────

  Widget _buildSendButton(bool isDark, AppLocalizations l10n) {
    final hasItems =
        _requestItems.isNotEmpty &&
        _requestItems.every((item) => item.quantity > 0);

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _isSending || !hasItems ? null : _sendRequest,
        icon: _isSending
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.textOnPrimary,
                ),
              )
            : const Icon(Icons.send_rounded, size: 20),
        label: Text(
          l10n.sendRequestBtn,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ─── Send Request Logic ────────────────────────────────────────

  Future<void> _sendRequest() async {
    final l10n = AppLocalizations.of(context);

    if (_requestItems.isEmpty) return;
    if (_requestItems.any((item) => item.quantity <= 0)) {
      AlhaiSnackbar.warning(context, l10n.validQuantityRequired);
      return;
    }

    setState(() => _isSending = true);

    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;
      final purchaseId = _uuid.v4();
      final purchaseNumber = 'PO-${const Uuid().v4().split('-').first}';
      final now = DateTime.now();

      // C-4 Session 4: purchases.subtotal, total and purchase_items.unit_cost, total are int cents.
      // product.price is already int cents, so price * qty = cents.
      final subtotalCents = _requestItems.fold<double>(
        0,
        (sum, item) => sum + (item.product.price * item.quantity),
      );
      final subtotalCentsInt = subtotalCents.round();

      // 1. Insert purchase
      await _db.purchasesDao.insertPurchase(
        PurchasesTableCompanion.insert(
          id: purchaseId,
          storeId: storeId,
          purchaseNumber: purchaseNumber,
          status: const Value('draft'),
          subtotal: Value(subtotalCentsInt),
          total: Value(subtotalCentsInt),
          notes: Value(
            _notesController.text.isNotEmpty
                ? _notesController.text.trim()
                : null,
          ),
          createdAt: now,
          updatedAt: Value(now),
        ),
      );

      // 2. Insert purchase items
      final purchaseItems = _requestItems.map((item) {
        return PurchaseItemsTableCompanion.insert(
          id: _uuid.v4(),
          purchaseId: purchaseId,
          productId: item.product.id,
          productName: item.product.name,
          productBarcode: Value(item.product.barcode),
          qty: item.quantity.toDouble(),
          // C-4 Session 4: purchase_items.unit_cost, total are int cents.
          // product.price is already int cents.
          unitCost: item.product.price,
          total: (item.product.price * item.quantity.toDouble()).round(),
        );
      }).toList();

      await _db.purchasesDao.insertPurchaseItems(purchaseItems);

      // Audit log
      final user = ref.read(currentUserProvider);
      auditService.logStockReceive(
        storeId: storeId,
        userId: user?.id ?? 'unknown',
        userName: user?.name ?? 'unknown',
        purchaseId: purchaseId,
        purchaseNumber: purchaseNumber,
        itemCount: _requestItems.length,
      );

      if (!mounted) return;

      HapticShim.mediumImpact();
      SoundService.instance.saleSuccess();
      AlhaiSnackbar.success(context, l10n.requestSentToManager);

      // Clear form
      setState(() {
        for (final item in _requestItems) {
          item.dispose();
        }
        _requestItems.clear();
        _notesController.clear();
        _searchController.clear();
        _searchResults = [];
      });
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Submit purchase request');
      if (!mounted) return;
      HapticShim.vibrate();
      SoundService.instance.errorBuzz();
      AlhaiSnackbar.error(context, l10n.errorWithDetails('$e'));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }
}
