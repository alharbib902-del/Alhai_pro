/// Exchange Screen - Return items and add new items in one transaction
///
/// Two sections: "Items to Return" and "New Items to Add".
/// Search/scan products for exchange, calculate difference.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_auth/alhai_auth.dart';
import '../../core/services/sentry_service.dart';
import '../../core/services/audit_service.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiBreakpoints, AlhaiSpacing;
// alhai_design_system is re-exported via alhai_shared_ui

/// شاشة الاستبدال
class ExchangeScreen extends ConsumerStatefulWidget {
  const ExchangeScreen({super.key});

  @override
  ConsumerState<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends ConsumerState<ExchangeScreen> {
  final _db = GetIt.I<AppDatabase>();
  final _returnSearchController = TextEditingController();
  final _newSearchController = TextEditingController();

  List<ProductsTableData> _returnSearchResults = [];
  List<ProductsTableData> _newSearchResults = [];

  // Items to return: {productId: {product, qty, price}}
  final List<_ExchangeItem> _returnItems = [];
  // New items to add
  final List<_ExchangeItem> _newItems = [];

  bool _isSubmitting = false;

  @override
  void dispose() {
    _returnSearchController.dispose();
    _newSearchController.dispose();
    super.dispose();
  }

  Future<void> _searchProducts(String query, bool isReturn) async {
    if (query.trim().isEmpty) {
      setState(() {
        if (isReturn) {
          _returnSearchResults = [];
        } else {
          _newSearchResults = [];
        }
      });
      return;
    }
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;
      final results = await _db.productsDao.searchProducts(query, storeId);
      if (mounted) {
        setState(() {
          if (isReturn) {
            _returnSearchResults = results.take(5).toList();
          } else {
            _newSearchResults = results.take(5).toList();
          }
        });
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Exchange search');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _addItem(ProductsTableData product, bool isReturn) {
    final list = isReturn ? _returnItems : _newItems;
    final existing = list.indexWhere((i) => i.productId == product.id);
    setState(() {
      if (existing >= 0) {
        list[existing] = list[existing].copyWithQty(list[existing].qty + 1);
      } else {
        list.add(_ExchangeItem(
          productId: product.id,
          productName: product.name,
          price: product.price,
          qty: 1,
        ));
      }
      if (isReturn) {
        _returnSearchController.clear();
        _returnSearchResults = [];
      } else {
        _newSearchController.clear();
        _newSearchResults = [];
      }
    });
  }

  void _removeItem(int index, bool isReturn) {
    setState(() {
      if (isReturn) {
        _returnItems.removeAt(index);
      } else {
        _newItems.removeAt(index);
      }
    });
  }

  void _updateQty(int index, int qty, bool isReturn) {
    if (qty <= 0) {
      _removeItem(index, isReturn);
      return;
    }
    setState(() {
      final list = isReturn ? _returnItems : _newItems;
      list[index] = list[index].copyWithQty(qty);
    });
  }

  double get _returnTotal =>
      _returnItems.fold<double>(0, (sum, i) => sum + (i.price * i.qty));

  double get _newTotal =>
      _newItems.fold<double>(0, (sum, i) => sum + (i.price * i.qty));

  double get _difference => _newTotal - _returnTotal;

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
          title: 'Exchange',
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
            padding: EdgeInsets.all(isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
            child: isWideScreen
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildReturnSection(isDark, l10n),
                      ),
                      const SizedBox(width: AlhaiSpacing.lg),
                      Expanded(
                        child: _buildNewItemsSection(isDark, l10n),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _buildReturnSection(isDark, l10n),
                      SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
                      _buildNewItemsSection(isDark, l10n),
                    ],
                  ),
          ),
        ),
        _buildBottomBar(isDark, l10n),
      ],
    );
  }

  String _getDateSubtitle(AppLocalizations l10n) {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year} \u2022 ${l10n.mainBranch}';
  }

  Widget _buildReturnSection(bool isDark, AppLocalizations l10n) {
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
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.assignment_return_rounded,
                    color: AppColors.error, size: 20),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                'Items to Return',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          _buildSearchBar(
              _returnSearchController, isDark, l10n, true),
          if (_returnSearchResults.isNotEmpty)
            _buildSearchResults(_returnSearchResults, isDark, true),
          const SizedBox(height: AlhaiSpacing.sm),
          ..._returnItems.asMap().entries.map((e) =>
              _buildExchangeItemCard(e.value, e.key, isDark, l10n, true)),
          if (_returnItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AlhaiSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.subtotal,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextSecondary(isDark))),
                  Text(
                    '${_returnTotal.toStringAsFixed(2)} ${l10n.sar}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.error),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNewItemsSection(bool isDark, AppLocalizations l10n) {
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
                child: const Icon(Icons.add_shopping_cart_rounded,
                    color: AppColors.success, size: 20),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                'New Items to Add',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          _buildSearchBar(
              _newSearchController, isDark, l10n, false),
          if (_newSearchResults.isNotEmpty)
            _buildSearchResults(_newSearchResults, isDark, false),
          const SizedBox(height: AlhaiSpacing.sm),
          ..._newItems.asMap().entries.map((e) =>
              _buildExchangeItemCard(e.value, e.key, isDark, l10n, false)),
          if (_newItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AlhaiSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.subtotal,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextSecondary(isDark))),
                  Text(
                    '${_newTotal.toStringAsFixed(2)} ${l10n.sar}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.success),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(TextEditingController controller, bool isDark,
      AppLocalizations l10n, bool isReturn) {
    return TextField(
      controller: controller,
      style: TextStyle(color: AppColors.getTextPrimary(isDark)),
      onChanged: (v) => _searchProducts(v, isReturn),
      decoration: InputDecoration(
        hintText: l10n.searchPlaceholder,
        hintStyle: TextStyle(color: AppColors.getTextMuted(isDark)),
        prefixIcon: Icon(Icons.search_rounded,
            color: AppColors.getTextMuted(isDark)),
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
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md, vertical: 14),
      ),
    );
  }

  Widget _buildSearchResults(
      List<ProductsTableData> results, bool isDark, bool isReturn) {
    return Container(
      margin: const EdgeInsets.only(top: AlhaiSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getBorder(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: results.map((product) {
          return InkWell(
            onTap: () => _addItem(product, isReturn),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AlhaiSpacing.md, vertical: AlhaiSpacing.sm),
              child: Row(
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 18, color: AppColors.getTextMuted(isDark)),
                  const SizedBox(width: AlhaiSpacing.sm),
                  Expanded(
                    child: Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    product.price.toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExchangeItemCard(_ExchangeItem item, int index, bool isDark,
      AppLocalizations l10n, bool isReturn) {
    final total = item.price * item.qty;
    return Container(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
      padding: const EdgeInsets.all(AlhaiSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceVariant(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.getBorder(isDark).withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
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
                  '${item.price.toStringAsFixed(2)} ${l10n.sar}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () =>
                    _updateQty(index, item.qty - 1, isReturn),
                icon: const Icon(Icons.remove_circle_outline_rounded),
                iconSize: 22,
                color: AppColors.getTextSecondary(isDark),
                constraints: const BoxConstraints(
                    minWidth: 48, minHeight: 48),
                padding: EdgeInsets.zero,
                tooltip: l10n.decreaseQuantity,
              ),
              SizedBox(
                width: 28,
                child: Text(
                  '${item.qty}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
              ),
              IconButton(
                onPressed: () =>
                    _updateQty(index, item.qty + 1, isReturn),
                icon: const Icon(Icons.add_circle_outline_rounded),
                iconSize: 22,
                color: AppColors.primary,
                constraints: const BoxConstraints(
                    minWidth: 48, minHeight: 48),
                padding: EdgeInsets.zero,
                tooltip: l10n.increaseQuantity,
              ),
            ],
          ),
          const SizedBox(width: AlhaiSpacing.xs),
          Text(
            total.toStringAsFixed(2),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          IconButton(
            onPressed: () => _removeItem(index, isReturn),
            icon: const Icon(Icons.close_rounded, size: 18),
            color: AppColors.error,
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            padding: EdgeInsets.zero,
            tooltip: l10n.delete,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(bool isDark, AppLocalizations l10n) {
    final diff = _difference;
    final diffColor = diff == 0
        ? AppColors.success
        : (diff > 0 ? AppColors.warning : AppColors.success);
    final hasItems = _returnItems.isNotEmpty || _newItems.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        border: Border(
            top: BorderSide(color: AppColors.getBorder(isDark), width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Difference',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.getTextSecondary(isDark)),
                  ),
                  Text(
                    '${diff >= 0 ? '+' : ''}${diff.toStringAsFixed(2)} ${l10n.sar}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: diffColor,
                    ),
                  ),
                  if (diff > 0)
                    Text(l10n.customerPaysExtra,
                        style: TextStyle(
                            fontSize: 11,
                            color: AppColors.getTextMuted(isDark)))
                  else if (diff < 0)
                    Text(l10n.refundToCustomer,
                        style: TextStyle(
                            fontSize: 11,
                            color: AppColors.getTextMuted(isDark))),
                ],
              ),
            ),
            const SizedBox(width: AlhaiSpacing.md),
            Expanded(
              child: FilledButton.icon(
                onPressed: _isSubmitting || !hasItems
                    ? null
                    : () => _submitExchange(l10n),
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.textOnPrimary),
                      )
                    : const Icon(Icons.swap_horiz_rounded, size: 20),
                label: Text(l10n.submitExchange,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitExchange(AppLocalizations l10n) async {
    setState(() => _isSubmitting = true);
    try {
      // Simulate exchange processing
      await Future.delayed(const Duration(seconds: 1));

      // Audit log
      final user = ref.read(currentUserProvider);
      final storeId = ref.read(currentStoreIdProvider)!;
      auditService.logExchange(
        storeId: storeId,
        userId: user?.id ?? 'unknown',
        userName: user?.name ?? 'unknown',
        returnCount: _returnItems.length,
        newCount: _newItems.length,
      );

      addBreadcrumb(
        message: 'Exchange completed',
        category: 'sale',
        data: {'returnItems': _returnItems.length, 'newItems': _newItems.length},
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).exchangeSuccessMsg),
          backgroundColor: AppColors.success,
        ),
      );
      setState(() {
        _returnItems.clear();
        _newItems.clear();
      });
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Submit exchange');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorWithDetails('$e')),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}

class _ExchangeItem {
  final String productId;
  final String productName;
  final double price;
  final int qty;

  const _ExchangeItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.qty,
  });

  _ExchangeItem copyWithQty(int newQty) => _ExchangeItem(
        productId: productId,
        productName: productName,
        price: price,
        qty: newQty,
      );
}
