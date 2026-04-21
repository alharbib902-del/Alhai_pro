/// شاشة البيع السريع - Quick Sale Screen
///
/// شاشة بيع احترافية مع Split View للويب
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:uuid/uuid.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_zatca/alhai_zatca.dart' show VatCalculator;
import '../../providers/cart_providers.dart';
import '../../providers/customer_display_providers.dart';
import 'phone_entry_dialog.dart';

/// شاشة البيع السريع
class QuickSaleScreen extends ConsumerStatefulWidget {
  const QuickSaleScreen({super.key});

  @override
  ConsumerState<QuickSaleScreen> createState() => _QuickSaleScreenState();
}

class _QuickSaleScreenState extends ConsumerState<QuickSaleScreen> {
  final _barcodeController = TextEditingController();
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  final List<CartItem> _cartItems = [];
  bool _showCart = true;
  String _selectedCategory = 'all';

  // Data loaded from DB
  List<ProductsTableData> _products = [];
  List<String> _categories = ['all'];
  bool _isLoading = true;
  String? _error;

  // Map from categoryId to categoryName for display
  Map<String, String> _categoryMap = {};

  List<ProductsTableData> get _filteredProducts {
    var products = _products;

    // Filter by category
    if (_selectedCategory != 'all') {
      // Find the categoryId(s) for the selected category name
      final selectedCatIds = _categoryMap.entries
          .where((e) => e.value == _selectedCategory)
          .map((e) => e.key)
          .toList();
      if (selectedCatIds.isNotEmpty) {
        products = products
            .where((p) => selectedCatIds.contains(p.categoryId))
            .toList();
      }
    }

    // Filter by search
    final search = _searchController.text.toLowerCase();
    if (search.isNotEmpty) {
      products = products
          .where(
            (p) =>
                p.name.toLowerCase().contains(search) ||
                (p.barcode?.contains(search) ?? false),
          )
          .toList();
    }

    return products;
  }

  double get _subtotal => _cartItems.fold(0.0, (sum, item) => sum + item.total);
  double get _vat => VatCalculator.vatFromNet(netAmount: _subtotal);
  double get _total => _subtotal + _vat;
  int get _itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final db = GetIt.I<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) {
        if (mounted) {
          setState(() {
            _error = 'storeNotSet';
            _isLoading = false;
          });
        }
        return;
      }

      // Load products from DB
      final products = await db.productsDao.getAllProducts(storeId);

      // Load categories from DB
      final dbCategories = await db.categoriesDao.getAllCategories(storeId);
      final categoryNames = <String>['all'];
      final categoryMap = <String, String>{};
      for (final cat in dbCategories) {
        categoryNames.add(cat.name);
        categoryMap[cat.id] = cat.name;
      }

      // If there are products with categoryIds not in the DB categories,
      // extract unique categoryIds from products as fallback
      final productCategoryIds = products
          .map((p) => p.categoryId)
          .where((c) => c != null && c.isNotEmpty)
          .toSet();
      for (final catId in productCategoryIds) {
        if (catId != null && !categoryMap.containsKey(catId)) {
          categoryMap[catId] = catId;
          categoryNames.add(catId);
        }
      }

      if (mounted) {
        setState(() {
          _products = products;
          _categories = categoryNames;
          _categoryMap = categoryMap;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  /// Get display name for a product's category
  String _getCategoryDisplayName(ProductsTableData product) {
    final l10n = AppLocalizations.of(context);
    if (product.categoryId == null) return l10n.otherCategory;
    return _categoryMap[product.categoryId] ??
        product.categoryId ??
        l10n.otherCategory;
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: AppErrorState.general(
          context,
          message: _error == 'storeNotSet' ? l10n.storeNotSet : _error,
          onRetry: () {
            setState(() {
              _isLoading = true;
              _error = null;
            });
            _loadData();
          },
        ),
      );
    }

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.f1): _focusBarcode,
        const SingleActivator(LogicalKeyboardKey.f2): _showProductSearch,
        const SingleActivator(LogicalKeyboardKey.f8): _clearCart,
        const SingleActivator(LogicalKeyboardKey.f12): _checkout,
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            setState(() => _showCart = !_showCart),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: SplitView(
              primaryContent: _buildProductsSection(),
              secondaryContent: _buildCartSection(),
              showSecondary: _showCart,
              onSecondaryVisibilityChanged: (visible) =>
                  setState(() => _showCart = visible),
              minSecondaryWidth: 380,
              maxSecondaryWidth: 450,
            ),
          ),
          floatingActionButton:
              AppBreakpoints.isMobile(context) && _cartItems.isNotEmpty
              ? FloatingActionButton.extended(
                  onPressed: () => setState(() => _showCart = true),
                  backgroundColor: AppColors.primary,
                  icon: const Icon(Icons.shopping_cart),
                  label: Text(
                    l10n.itemsCountPrice(_itemCount, _total.toStringAsFixed(2)),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  /// قسم المنتجات
  Widget _buildProductsSection() {
    return Column(
      children: [
        // Search & Barcode Bar
        _buildSearchBar(),

        // Categories
        _buildCategoriesBar(),

        // Products Grid
        Expanded(child: _buildProductsGrid()),
      ],
    );
  }

  Widget _buildSearchBar() {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          // Barcode Input
          Expanded(
            flex: 2,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: AppSpacing.md),
                  const Icon(
                    Icons.qr_code_scanner,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextField(
                      controller: _barcodeController,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: l10n.scanBarcodeHint,
                        hintStyle: AppTypography.bodyMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      onSubmitted: _addByBarcode,
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.push('/inventory/scanner'),
                    icon: const Icon(Icons.camera_alt_outlined),
                    color: AppColors.primary,
                    tooltip: l10n.openCamera,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // Search Input
          Expanded(
            flex: 2,
            child: AppSearchField(
              hint: l10n.searchProductHint,
              controller: _searchController,
              maxLength: 100,
              onChanged: (v) {
                final sanitized = InputSanitizer.sanitize(v);
                if (sanitized != v) {
                  _searchController.text = sanitized;
                  _searchController.selection = TextSelection.fromPosition(
                    TextPosition(offset: sanitized.length),
                  );
                }
                setState(() {});
              },
              fullWidth: true,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // Toggle Cart Button (for tablet)
          if (AppBreakpoints.isTablet(context))
            AppIconButton(
              icon: _showCart
                  ? Icons.shopping_cart
                  : Icons.shopping_cart_outlined,
              onPressed: () => setState(() => _showCart = !_showCart),
              color: AppColors.primary,
              tooltip: _showCart ? l10n.hideCart : l10n.showCart,
              variant: AppButtonVariant.soft,
              size: 48,
            ),
        ],
      ),
    );
  }

  Widget _buildCategoriesBar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;

          return AppCategoryBadge(
            category: category,
            isSelected: isSelected,
            onTap: () => setState(() => _selectedCategory = category),
            color: category == 'all'
                ? AppColors.grey500
                : AppColors.getCategoryColor(category),
          );
        },
      ),
    );
  }

  Widget _buildProductsGrid() {
    final products = _filteredProducts;

    if (products.isEmpty) {
      return AppEmptyState.noSearchResults(
        context,
        onClear: () {
          setState(() {
            _searchController.clear();
            _selectedCategory = 'all';
          });
        },
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.85,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _ProductTile(
          product: product,
          categoryName: _getCategoryDisplayName(product),
          onTap: () => _addProduct(product),
        );
      },
    );
  }

  /// قسم السلة
  Widget _buildCartSection() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Cart Header
          _buildCartHeader(),

          // Cart Items
          Expanded(
            child: _cartItems.isEmpty
                ? AppEmptyState.emptyCart(context)
                : _buildCartItemsList(),
          ),

          // Cart Summary & Checkout
          if (_cartItems.isNotEmpty) _buildCartSummary(),
        ],
      ),
    );
  }

  Widget _buildCartHeader() {
    final l10n = AppLocalizations.of(context);
    return SplitPanelHeader(
      title: l10n.cartTitle,
      icon: Icons.shopping_cart,
      onClose: AppBreakpoints.isMobile(context)
          ? () => setState(() => _showCart = false)
          : null,
      actions: [
        if (_cartItems.isNotEmpty)
          TextButton.icon(
            onPressed: _clearCart,
            icon: const Icon(Icons.delete_outline, size: 18),
            label: Text(l10n.clearAction),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
          ),
      ],
    );
  }

  Widget _buildCartItemsList() {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _cartItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final item = _cartItems[index];
        return _CartItemTile(
          item: item,
          onQuantityChanged: (qty) => _updateQuantity(index, qty),
          onRemove: () => _removeItem(index),
        );
      },
    );
  }

  Widget _buildCartSummary() {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        children: [
          // Summary Lines
          _buildSummaryLine(l10n.subtotalLabel, _subtotal),
          const SizedBox(height: AppSpacing.xs),
          _buildSummaryLine(l10n.vatTax15, _vat),

          const Divider(height: AppSpacing.xl),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.totalGrand,
                style: AppTypography.titleMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                '${_total.toStringAsFixed(2)} ${l10n.sar}',
                style: AppTypography.priceLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Checkout Buttons
          Row(
            children: [
              // Hold Button
              Expanded(
                child: AppButton(
                  label: l10n.holdOrder,
                  icon: Icons.pause_circle_outline,
                  variant: AppButtonVariant.outlined,
                  onPressed: _holdOrder,
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              // Checkout Button
              Expanded(
                flex: 2,
                child: AppButton.success(
                  label: l10n.payActionLabel,
                  icon: Icons.payment,
                  onPressed: _checkout,
                  size: ButtonSize.large,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Shortcut hint
          Text(
            l10n.f12QuickPay,
            style: AppTypography.labelSmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryLine(String label, double amount) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          '${amount.toStringAsFixed(2)} ${l10n.sar}',
          style: AppTypography.bodyMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // Actions
  // ============================================================================

  void _focusBarcode() {
    _focusNode.requestFocus();
  }

  void _showProductSearch() {
    // Focus on search field
  }

  void _addByBarcode(String barcode) async {
    final l10n = AppLocalizations.of(context);
    if (barcode.isEmpty) return;

    // Try to find in already-loaded products first
    final localMatch = _products.where((p) => p.barcode == barcode);

    if (localMatch.isNotEmpty) {
      _addProduct(localMatch.first);
    } else {
      // Fallback: query DB directly
      try {
        final db = GetIt.I<AppDatabase>();
        final storeId = ref.read(currentStoreIdProvider);
        if (storeId != null) {
          final product = await db.productsDao.getProductByBarcode(
            barcode,
            storeId,
          );
          if (product != null && mounted) {
            _addProduct(product);
          } else if (mounted) {
            final messenger = ScaffoldMessenger.of(context);
            messenger.showSnackBar(
              SnackBar(
                content: Text(l10n.productNotFoundBarcode(barcode)),
                backgroundColor: AppColors.warning,
              ),
            );
          }
        }
      } catch (_) {
        // Ignore barcode lookup errors
      }
    }

    _barcodeController.clear();
    _focusNode.requestFocus();
  }

  void _addProduct(ProductsTableData product) {
    setState(() {
      final existingIndex = _cartItems.indexWhere(
        (e) => e.product.id == product.id,
      );
      if (existingIndex >= 0) {
        _cartItems[existingIndex] = _cartItems[existingIndex].copyWith(
          quantity: _cartItems[existingIndex].quantity + 1,
        );
      } else {
        _cartItems.add(CartItem(product: product, quantity: 1));
      }
    });
  }

  void _updateQuantity(int index, int quantity) {
    setState(() {
      if (quantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index] = _cartItems[index].copyWith(quantity: quantity);
      }
    });
  }

  void _removeItem(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
  }

  void _clearCart() async {
    final l10n = AppLocalizations.of(context);
    if (_cartItems.isEmpty) return;

    final confirmed = await AppDialog.confirm(
      context,
      title: l10n.clearCartTitle,
      message: l10n.clearCartMessage,
      confirmText: l10n.clearAction,
      isDangerous: true,
    );

    if (confirmed == true) {
      setState(() => _cartItems.clear());
    }
  }

  Future<void> _holdOrder() async {
    final l10n = AppLocalizations.of(context);
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.orderOnHold),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final now = DateTime.now();
    final defaultName = AppLocalizations.of(context).quickSaleHold(
      '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
    );

    final name = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController(text: defaultName);
        return AlertDialog(
          title: Text(l10n.holdInvoiceTitle),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.holdInvoiceNameLabel,
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (v) =>
                Navigator.pop(ctx, v.trim().isEmpty ? defaultName : v.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                ctx,
                controller.text.trim().isEmpty
                    ? defaultName
                    : controller.text.trim(),
              ),
              child: Text(l10n.holdAction),
            ),
          ],
        );
      },
    );

    if (name == null || !mounted) return;

    try {
      final db = GetIt.I<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider) ?? '';
      final id = const Uuid().v4();
      final subtotal = _cartItems.fold<double>(0.0, (s, i) => s + i.total);
      final itemsJson = jsonEncode(
        _cartItems
            .map(
              (item) => {
                'productId': item.product.id,
                'productName': item.product.name,
                'price': item.product.price,
                'quantity': item.quantity,
                'total': item.total,
              },
            )
            .toList(),
      );

      await db
          .into(db.heldInvoicesTable)
          .insert(
            HeldInvoicesTableCompanion.insert(
              id: id,
              storeId: storeId,
              cashierId: '',
              items: itemsJson,
              subtotal: Value((subtotal * 100).round()),
              discount: const Value(0),
              total: Value((subtotal * 100).round()),
              notes: Value(name),
              createdAt: now,
            ),
          );

      if (mounted) {
        setState(() => _cartItems.clear());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.pause_circle_outline,
                  color: AppColors.textOnPrimary,
                  size: 18,
                ),
                const SizedBox(width: AlhaiSpacing.xs),
                Text(l10n.heldMessage(name)),
              ],
            ),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.holdError(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _checkout() async {
    if (_cartItems.isEmpty) return;

    // عرض نافذة إدخال رقم الجوال إذا كانت الميزة مفعّلة
    final featureSettings = ref
        .read(cashierFeatureSettingsProvider)
        .valueOrNull;
    if (featureSettings?.enablePhoneCollection == true) {
      final storeId = ref.read(currentStoreIdProvider) ?? '';
      final phoneResult = await PhoneEntryDialog.show(
        context,
        storeId: storeId,
      );
      if (!mounted) return;

      if (!phoneResult.wasSkipped) {
        ref
            .read(cartStateProvider.notifier)
            .setCustomerPhone(phoneResult.phone);
        if (phoneResult.hasExistingCustomer) {
          ref
              .read(cartStateProvider.notifier)
              .setCustomer(
                phoneResult.customerId,
                customerName: phoneResult.customerName,
              );
        }
      }
    }

    if (!mounted) return;
    context.push('/pos/payment');
  }
}

// ============================================================================
// Models
// ============================================================================

class CartItem {
  final ProductsTableData product;
  final int quantity;

  const CartItem({required this.product, required this.quantity});

  // C-4 Stage B: product.price is int cents; total stays in double SAR.
  double get total => (product.price * quantity) / 100.0;

  CartItem copyWith({ProductsTableData? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}

// ============================================================================
// Sub Widgets
// ============================================================================

class _ProductTile extends StatefulWidget {
  final ProductsTableData product;
  final String categoryName;
  final VoidCallback onTap;

  const _ProductTile({
    required this.product,
    required this.categoryName,
    required this.onTap,
  });

  @override
  State<_ProductTile> createState() => _ProductTileState();
}

class _ProductTileState extends State<_ProductTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categoryColor = AppColors.getCategoryColor(widget.categoryName);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: AppDurations.fast,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: _isHovered
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor,
            width: _isHovered ? 2 : 1,
          ),
          boxShadow: _isHovered ? AppShadows.md : AppShadows.sm,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          widget.categoryName,
                          style: AppTypography.labelSmall.copyWith(
                            color: categoryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Stock indicator
                      AppBadge.stock(context, widget.product.stockQty),
                    ],
                  ),

                  const Spacer(),

                  // Product Icon
                  Center(
                    child: AnimatedContainer(
                      duration: AppDurations.fast,
                      width: _isHovered ? 56 : 48,
                      height: _isHovered ? 56 : 48,
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Icon(
                        _getCategoryIcon(widget.categoryName),
                        color: categoryColor,
                        size: _isHovered ? 28 : 24,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Name
                  Text(
                    widget.product.name,
                    style: AppTypography.titleSmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  // Price
                  Text(
                    '${widget.product.price.toStringAsFixed(2)} ${l10n.sar}',
                    style: AppTypography.priceMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'فواكه':
        return Icons.apple;
      case 'خضروات':
        return Icons.eco;
      case 'ألبان':
        return Icons.water_drop;
      case 'مشروبات':
        return Icons.local_drink;
      case 'سناكس':
        return Icons.cookie;
      case 'تنظيف':
        return Icons.cleaning_services;
      default:
        return Icons.inventory_2;
    }
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  const _CartItemTile({
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: AppTypography.titleSmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${item.product.price.toStringAsFixed(2)} ${l10n.sar}',
                  style: AppTypography.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Quantity Controls
          AppQuantityField(
            value: item.quantity,
            onChanged: onQuantityChanged,
            min: 0,
            size: 32,
          ),

          const SizedBox(width: AppSpacing.md),

          // Total
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.total.toStringAsFixed(2),
                style: AppTypography.priceSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
              Text(
                l10n.sar,
                style: AppTypography.labelSmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          // Remove Button
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close),
            iconSize: 18,
            color: Theme.of(context).colorScheme.error,
            tooltip: l10n.deleteItem,
          ),
        ],
      ),
    );
  }
}
