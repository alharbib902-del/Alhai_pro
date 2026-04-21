/// Create Invoice Screen - Create a new invoice for a customer
///
/// Form: customer, items (product search), quantities, prices.
/// Tax calculation, discount. Save as draft or finalize.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'dart:async';
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiBreakpoints, AlhaiSnackbar, AlhaiSpacing;

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
// alhai_design_system is re-exported via alhai_shared_ui

/// شاشة إنشاء فاتورة
class CreateInvoiceScreen extends ConsumerStatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  ConsumerState<CreateInvoiceScreen> createState() =>
      _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends ConsumerState<CreateInvoiceScreen> {
  final _db = GetIt.I<AppDatabase>();
  final _productSearchController = TextEditingController();
  final _customerSearchController = TextEditingController();
  final _discountController = TextEditingController(text: '0');

  List<ProductsTableData> _searchResults = [];
  List<CustomersTableData> _customerResults = [];
  CustomersTableData? _selectedCustomer;
  bool _showCustomerSearch = false;

  final List<_InvoiceItem> _items = [];
  bool _isSubmitting = false;
  Timer? _productSearchDebounce;
  Timer? _customerSearchDebounce;

  static const double _taxRate = 0.15; // 15% VAT

  @override
  void dispose() {
    _productSearchDebounce?.cancel();
    _customerSearchDebounce?.cancel();
    _productSearchController.dispose();
    _customerSearchController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _onProductSearchChanged(String query) {
    _productSearchDebounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    _productSearchDebounce = Timer(const Duration(milliseconds: 300), () {
      _searchProducts(query);
    });
  }

  void _onCustomerSearchChanged(String query) {
    _customerSearchDebounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() => _customerResults = []);
      return;
    }
    _customerSearchDebounce = Timer(const Duration(milliseconds: 300), () {
      _searchCustomers(query);
    });
  }

  Future<void> _searchProducts(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;
      final results = await _db.productsDao.searchProducts(query, storeId);
      if (mounted) {
        setState(() => _searchResults = results.take(5).toList());
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Product search');
      if (mounted) {
        AlhaiSnackbar.error(
          context,
          AppLocalizations.of(context).productSearchFailed('$e'),
        );
      }
    }
  }

  Future<void> _searchCustomers(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _customerResults = []);
      return;
    }
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;
      final results = await _db.customersDao.searchCustomers(query, storeId);
      if (mounted) {
        setState(() => _customerResults = results.take(5).toList());
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Customer search');
      if (mounted) {
        AlhaiSnackbar.error(
          context,
          AppLocalizations.of(context).customerSearchFailed('$e'),
        );
      }
    }
  }

  void _addProduct(ProductsTableData product) {
    final existing = _items.indexWhere((i) => i.productId == product.id);
    setState(() {
      if (existing >= 0) {
        _items[existing] = _items[existing].copyWithQty(
          _items[existing].qty + 1,
        );
      } else {
        _items.add(
          _InvoiceItem(
            productId: product.id,
            productName: product.name,
            // C-4 Stage B: product.price is int cents; invoice in double SAR.
            price: product.price / 100.0,
            qty: 1,
          ),
        );
      }
      _productSearchController.clear();
      _searchResults = [];
    });
  }

  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
  }

  void _updateQty(int index, int qty) {
    if (qty <= 0) {
      _removeItem(index);
      return;
    }
    setState(() => _items[index] = _items[index].copyWithQty(qty));
  }

  double get _subtotal =>
      _items.fold<double>(0, (sum, i) => sum + (i.price * i.qty));

  double get _discount => double.tryParse(_discountController.text) ?? 0;

  double get _taxableAmount => _subtotal - _discount;

  double get _tax => _taxableAmount > 0 ? _taxableAmount * _taxRate : 0;

  double get _total => _taxableAmount + _tax;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width >= AlhaiBreakpoints.desktop;
    final isMediumScreen = size.width >= AlhaiBreakpoints.tablet;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);

    return Column(
      children: [
        AppHeader(
          title: 'Create Invoice',
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
                            _buildCustomerCard(colorScheme, l10n),
                            const SizedBox(height: AlhaiSpacing.lg),
                            _buildItemsCard(colorScheme, l10n),
                          ],
                        ),
                      ),
                      const SizedBox(width: AlhaiSpacing.lg),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            _buildTotalsCard(colorScheme, l10n),
                            const SizedBox(height: AlhaiSpacing.lg),
                            _buildActionsCard(colorScheme, l10n),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildCustomerCard(colorScheme, l10n),
                      SizedBox(
                        height: isMediumScreen
                            ? AlhaiSpacing.lg
                            : AlhaiSpacing.md,
                      ),
                      _buildItemsCard(colorScheme, l10n),
                      SizedBox(
                        height: isMediumScreen
                            ? AlhaiSpacing.lg
                            : AlhaiSpacing.md,
                      ),
                      _buildTotalsCard(colorScheme, l10n),
                      const SizedBox(height: AlhaiSpacing.lg),
                      _buildActionsCard(colorScheme, l10n),
                      const SizedBox(height: AlhaiSpacing.lg),
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

  Widget _buildCustomerCard(ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
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
                  Icons.person_rounded,
                  color: AppColors.info,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n.customerName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          if (_selectedCustomer != null && !_showCustomerSearch)
            _buildSelectedCustomerChip(colorScheme, l10n)
          else
            _buildCustomerSearch(colorScheme, l10n),
        ],
      ),
    );
  }

  Widget _buildSelectedCustomerChip(
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    final customer = _selectedCustomer!;
    return InkWell(
      onTap: () => setState(() => _showCustomerSearch = true),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(
            alpha: Theme.of(context).brightness == Brightness.dark
                ? 0.12
                : 0.06,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.4),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppColors.avatarGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                _getInitials(customer.name),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(width: AlhaiSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      customer.phone ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit_rounded, size: 18, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerSearch(ColorScheme colorScheme, AppLocalizations l10n) {
    return Column(
      children: [
        TextField(
          controller: _customerSearchController,
          style: TextStyle(color: colorScheme.onSurface),
          onChanged: _onCustomerSearchChanged,
          decoration: InputDecoration(
            hintText: l10n.searchPlaceholder,
            hintStyle: TextStyle(color: colorScheme.outline),
            prefixIcon: Icon(Icons.search_rounded, color: colorScheme.outline),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AlhaiSpacing.md,
              vertical: 14,
            ),
          ),
        ),
        if (_customerResults.isNotEmpty)
          Container(
            margin: const EdgeInsetsDirectional.only(top: AlhaiSpacing.xs),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: _customerResults.map((customer) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedCustomer = customer;
                      _showCustomerSearch = false;
                      _customerSearchController.clear();
                      _customerResults = [];
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AlhaiSpacing.md,
                      vertical: AlhaiSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 18,
                          color: colorScheme.outline,
                        ),
                        const SizedBox(width: AlhaiSpacing.sm),
                        Expanded(
                          child: Text(
                            customer.name,
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            customer.phone ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildItemsCard(ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
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
                  Icons.shopping_bag_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n.items,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              if (_items.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: AlhaiSpacing.xxs,
                  ),
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
          // Product search
          TextField(
            controller: _productSearchController,
            style: TextStyle(color: colorScheme.onSurface),
            onChanged: _onProductSearchChanged,
            decoration: InputDecoration(
              hintText: l10n.searchPlaceholder,
              hintStyle: TextStyle(color: colorScheme.outline),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: colorScheme.outline,
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
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
          if (_searchResults.isNotEmpty)
            Container(
              margin: const EdgeInsetsDirectional.only(top: AlhaiSpacing.xs),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: _searchResults.map((product) {
                  return InkWell(
                    onTap: () => _addProduct(product),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AlhaiSpacing.md,
                        vertical: AlhaiSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 18,
                            color: colorScheme.outline,
                          ),
                          const SizedBox(width: AlhaiSpacing.sm),
                          Expanded(
                            child: Text(
                              product.name,
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${product.price.toStringAsFixed(2)} ${l10n.sar}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: AlhaiSpacing.sm),
          // Items list
          ..._items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final total = item.price * item.qty;
            return Container(
              margin: const EdgeInsetsDirectional.only(bottom: AlhaiSpacing.xs),
              padding: const EdgeInsets.all(AlhaiSpacing.sm),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
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
                            color: colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${item.price.toStringAsFixed(2)} ${l10n.sar}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _updateQty(index, item.qty - 1),
                        icon: const Icon(Icons.remove_circle_outline_rounded),
                        iconSize: 22,
                        color: colorScheme.onSurfaceVariant,
                        constraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 48,
                        ),
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
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _updateQty(index, item.qty + 1),
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        iconSize: 22,
                        color: AppColors.primary,
                        constraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 48,
                        ),
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
                      color: colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _removeItem(index),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    color: AppColors.error,
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    padding: EdgeInsets.zero,
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

  Widget _buildTotalsCard(ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
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
                child: const Icon(
                  Icons.calculate_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n.totalAmountLabel,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          _buildTotalRow(
            l10n.subtotal,
            '${_subtotal.toStringAsFixed(2)} ${l10n.sar}',
            colorScheme,
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          // Discount input
          Row(
            children: [
              Text(
                l10n.discount,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 120,
                child: TextField(
                  controller: _discountController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: '0',
                    suffixText: l10n.sar,
                    suffixStyle: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AlhaiSpacing.sm,
                      vertical: AlhaiSpacing.xs,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          _buildTotalRow(
            '${l10n.tax} (15%)',
            '${_tax.toStringAsFixed(2)} ${l10n.sar}',
            colorScheme,
          ),
          Divider(height: 24, color: colorScheme.outlineVariant),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.totalAmountLabel,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                '${_total.toStringAsFixed(2)} ${l10n.sar}',
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

  Widget _buildTotalRow(String label, String value, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildActionsCard(ColorScheme colorScheme, AppLocalizations l10n) {
    final canSubmit = _items.isNotEmpty && _selectedCustomer != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isSubmitting || !canSubmit
                ? null
                : () => _saveInvoice(false, l10n),
            icon: _isSubmitting
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : const Icon(Icons.check_circle_rounded, size: 20),
            label: Text(
              l10n.finalizeInvoice,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: AlhaiSpacing.sm),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isSubmitting || !canSubmit
                ? null
                : () => _saveInvoice(true, l10n),
            icon: const Icon(Icons.save_outlined, size: 20),
            label: Text(
              l10n.saveAsDraft,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.onSurfaceVariant,
              side: BorderSide(color: colorScheme.outlineVariant),
              padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveInvoice(bool isDraft, AppLocalizations l10n) async {
    if (_items.isEmpty || _selectedCustomer == null) return;

    setState(() => _isSubmitting = true);

    try {
      // Simulate saving invoice
      await Future.delayed(const Duration(seconds: 1));

      // Audit log (only for finalized invoices)
      if (!isDraft) {
        final user = ref.read(currentUserProvider);
        final storeId = ref.read(currentStoreIdProvider);
        if (storeId == null) return;
        final total = _items.fold<double>(0, (sum, i) => sum + i.price * i.qty);
        auditService.logSaleCreate(
          storeId: storeId,
          userId: user?.id ?? 'unknown',
          userName: user?.name ?? 'unknown',
          saleId: 'invoice-${DateTime.now().millisecondsSinceEpoch}',
          total: total,
          paymentMethod: 'credit',
        );
      }

      addBreadcrumb(
        message: isDraft ? 'Invoice saved as draft' : 'Invoice finalized',
        category: 'sale',
        data: {'items': _items.length, 'customer': _selectedCustomer?.name},
      );

      if (!mounted) return;
      AlhaiSnackbar.success(
        context,
        isDraft ? 'Invoice saved as draft' : 'Invoice finalized successfully',
      );

      if (!isDraft) {
        // Reset form
        setState(() {
          _items.clear();
          _selectedCustomer = null;
          _discountController.text = '0';
        });
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Save invoice');
      if (!mounted) return;
      AlhaiSnackbar.error(context, l10n.errorWithDetails('$e'));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

class _InvoiceItem {
  final String productId;
  final String productName;
  final double price;
  final int qty;

  const _InvoiceItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.qty,
  });

  _InvoiceItem copyWithQty(int newQty) => _InvoiceItem(
    productId: productId,
    productName: productName,
    price: price,
    qty: newQty,
  );

  _InvoiceItem copyWithPrice(double newPrice) => _InvoiceItem(
    productId: productId,
    productName: productName,
    price: newPrice,
    qty: qty,
  );
}
