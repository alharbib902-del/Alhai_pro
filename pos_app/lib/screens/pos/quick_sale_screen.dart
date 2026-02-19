/// شاشة البيع السريع - Quick Sale Screen
///
/// شاشة بيع احترافية مع Split View للويب
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../core/validators/input_sanitizer.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../providers/products_providers.dart';
import '../../widgets/layout/split_view.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_input.dart';
import '../../widgets/common/app_badge.dart';
import '../../widgets/common/app_empty_state.dart';
import '../../widgets/common/app_dialog.dart';
import '../../l10n/generated/app_localizations.dart';

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
        products = products.where((p) => selectedCatIds.contains(p.categoryId)).toList();
      }
    }

    // Filter by search
    final search = _searchController.text.toLowerCase();
    if (search.isNotEmpty) {
      products = products.where((p) =>
        p.name.toLowerCase().contains(search) ||
        (p.barcode?.contains(search) ?? false)
      ).toList();
    }

    return products;
  }

  double get _subtotal => _cartItems.fold(0.0, (sum, item) => sum + item.total);
  double get _vat => _subtotal * 0.15;
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
      final db = getIt<AppDatabase>();
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
    if (product.categoryId == null) return AppLocalizations.of(context)!.otherCategory;
    return _categoryMap[product.categoryId] ?? product.categoryId ?? AppLocalizations.of(context)!.otherCategory;
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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(_error == 'storeNotSet' ? AppLocalizations.of(context)!.storeNotSet : _error!, style: AppTypography.bodyLarge),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() { _isLoading = true; _error = null; });
                  _loadData();
                },
                child: Text(AppLocalizations.of(context)!.retryAction),
              ),
            ],
          ),
        ),
      );
    }

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.f1): _focusBarcode,
        const SingleActivator(LogicalKeyboardKey.f2): _showProductSearch,
        const SingleActivator(LogicalKeyboardKey.f8): _clearCart,
        const SingleActivator(LogicalKeyboardKey.f12): _checkout,
        const SingleActivator(LogicalKeyboardKey.escape): () => setState(() => _showCart = !_showCart),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SplitView(
            primaryContent: _buildProductsSection(),
            secondaryContent: _buildCartSection(),
            showSecondary: _showCart,
            onSecondaryVisibilityChanged: (visible) => setState(() => _showCart = visible),
            minSecondaryWidth: 380,
            maxSecondaryWidth: 450,
          ),
          floatingActionButton: AppBreakpoints.isMobile(context) && _cartItems.isNotEmpty
              ? FloatingActionButton.extended(
                  onPressed: () => setState(() => _showCart = true),
                  backgroundColor: AppColors.primary,
                  icon: const Icon(Icons.shopping_cart),
                  label: Text(AppLocalizations.of(context)!.itemsCountPrice(_itemCount, _total.toStringAsFixed(2))),
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
        Expanded(
          child: _buildProductsGrid(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
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
                border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: AppSpacing.md),
                  const Icon(Icons.qr_code_scanner, color: AppColors.primary, size: 24),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextField(
                      controller: _barcodeController,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.scanBarcodeHint,
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
                    tooltip: AppLocalizations.of(context)!.openCamera,
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
              hint: AppLocalizations.of(context)!.searchProductHint,
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
              icon: _showCart ? Icons.shopping_cart : Icons.shopping_cart_outlined,
              onPressed: () => setState(() => _showCart = !_showCart),
              color: AppColors.primary,
              tooltip: _showCart ? AppLocalizations.of(context)!.hideCart : AppLocalizations.of(context)!.showCart,
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
                ? AppEmptyState.emptyCart()
                : _buildCartItemsList(),
          ),

          // Cart Summary & Checkout
          if (_cartItems.isNotEmpty) _buildCartSummary(),
        ],
      ),
    );
  }

  Widget _buildCartHeader() {
    return SplitPanelHeader(
      title: AppLocalizations.of(context)!.cartTitle,
      icon: Icons.shopping_cart,
      onClose: AppBreakpoints.isMobile(context)
          ? () => setState(() => _showCart = false)
          : null,
      actions: [
        if (_cartItems.isNotEmpty)
          TextButton.icon(
            onPressed: _clearCart,
            icon: const Icon(Icons.delete_outline, size: 18),
            label: Text(AppLocalizations.of(context)!.clearAction),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        children: [
          // Summary Lines
          _buildSummaryLine(AppLocalizations.of(context)!.subtotalLabel, _subtotal),
          const SizedBox(height: AppSpacing.xs),
          _buildSummaryLine(AppLocalizations.of(context)!.vatTax15, _vat),

          const Divider(height: AppSpacing.xl),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.totalGrand,
                style: AppTypography.titleMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                '${_total.toStringAsFixed(2)} ${AppLocalizations.of(context)!.sar}',
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
                  label: AppLocalizations.of(context)!.holdOrder,
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
                  label: AppLocalizations.of(context)!.payActionLabel,
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
            AppLocalizations.of(context)!.f12QuickPay,
            style: AppTypography.labelSmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryLine(String label, double amount) {
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
          '${amount.toStringAsFixed(2)} ${AppLocalizations.of(context)!.sar}',
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
    if (barcode.isEmpty) return;

    // Try to find in already-loaded products first
    final localMatch = _products.where((p) => p.barcode == barcode);

    if (localMatch.isNotEmpty) {
      _addProduct(localMatch.first);
    } else {
      // Fallback: query DB directly
      try {
        final db = getIt<AppDatabase>();
        final storeId = ref.read(currentStoreIdProvider);
        if (storeId != null) {
          final product = await db.productsDao.getProductByBarcode(barcode, storeId);
          if (product != null && mounted) {
            _addProduct(product);
          } else if (mounted) {
            final messenger = ScaffoldMessenger.of(context);
            messenger.showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.productNotFoundBarcode(barcode)),
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
      final existingIndex = _cartItems.indexWhere((e) => e.product.id == product.id);
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
    if (_cartItems.isEmpty) return;

    final confirmed = await AppDialog.confirm(
      context,
      title: AppLocalizations.of(context)!.clearCartTitle,
      message: AppLocalizations.of(context)!.clearCartMessage,
      confirmText: AppLocalizations.of(context)!.clearAction,
      isDangerous: true,
    );

    if (confirmed == true) {
      setState(() => _cartItems.clear());
    }
  }

  void _holdOrder() {
    // TODO: Implement hold order
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.orderOnHold),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  void _checkout() {
    if (_cartItems.isEmpty) return;
    context.push('/pos/payment');
  }
}

// ============================================================================
// Models
// ============================================================================

class CartItem {
  final ProductsTableData product;
  final int quantity;

  const CartItem({
    required this.product,
    required this.quantity,
  });

  double get total => product.price * quantity;

  CartItem copyWith({
    ProductsTableData? product,
    int? quantity,
  }) {
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
            color: _isHovered ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor,
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
                    '${widget.product.price.toStringAsFixed(2)} ${AppLocalizations.of(context)!.sar}',
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
                  '${item.product.price.toStringAsFixed(2)} ${AppLocalizations.of(context)!.sar}',
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
                AppLocalizations.of(context)!.sar,
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
            tooltip: AppLocalizations.of(context)!.deleteItem,
          ),
        ],
      ),
    );
  }
}
