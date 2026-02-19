/// شاشة البيع السريع - Quick Sale Screen
///
/// شاشة بيع احترافية مع Split View للويب
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/layout/split_view.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_input.dart';
import '../../widgets/common/app_badge.dart';
import '../../widgets/common/app_empty_state.dart';
import '../../widgets/common/app_dialog.dart';

/// شاشة البيع السريع
class QuickSaleScreen extends StatefulWidget {
  const QuickSaleScreen({super.key});

  @override
  State<QuickSaleScreen> createState() => _QuickSaleScreenState();
}

class _QuickSaleScreenState extends State<QuickSaleScreen> {
  final _barcodeController = TextEditingController();
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  final List<CartItem> _cartItems = [];
  bool _showCart = true;
  String _selectedCategory = 'الكل';

  // Mock categories
  final List<String> _categories = [
    'الكل',
    'فواكه',
    'خضروات',
    'ألبان',
    'مشروبات',
    'سناكس',
    'تنظيف',
  ];

  // Mock products
  final List<Product> _products = [
    const Product(id: '1', name: 'تفاح أحمر', price: 12.5, barcode: '123456', category: 'فواكه', quantity: 50),
    const Product(id: '2', name: 'موز', price: 8.0, barcode: '123457', category: 'فواكه', quantity: 30),
    const Product(id: '3', name: 'برتقال', price: 10.0, barcode: '123458', category: 'فواكه', quantity: 45),
    const Product(id: '4', name: 'طماطم', price: 5.5, barcode: '234567', category: 'خضروات', quantity: 100),
    const Product(id: '5', name: 'خيار', price: 4.0, barcode: '234568', category: 'خضروات', quantity: 80),
    const Product(id: '6', name: 'حليب طازج', price: 7.5, barcode: '345678', category: 'ألبان', quantity: 25),
    const Product(id: '7', name: 'لبن', price: 5.0, barcode: '345679', category: 'ألبان', quantity: 40),
    const Product(id: '8', name: 'ماء معدني', price: 1.5, barcode: '456789', category: 'مشروبات', quantity: 200),
    const Product(id: '9', name: 'بيبسي', price: 3.0, barcode: '456790', category: 'مشروبات', quantity: 150),
    const Product(id: '10', name: 'شيبس', price: 4.5, barcode: '567890', category: 'سناكس', quantity: 60),
    const Product(id: '11', name: 'شوكولاتة', price: 6.0, barcode: '567891', category: 'سناكس', quantity: 45),
    const Product(id: '12', name: 'صابون', price: 8.5, barcode: '678901', category: 'تنظيف', quantity: 30),
  ];

  List<Product> get _filteredProducts {
    var products = _products;

    // Filter by category
    if (_selectedCategory != 'الكل') {
      products = products.where((p) => p.category == _selectedCategory).toList();
    }

    // Filter by search
    final search = _searchController.text.toLowerCase();
    if (search.isNotEmpty) {
      products = products.where((p) =>
        p.name.toLowerCase().contains(search) ||
        p.barcode.contains(search)
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
          backgroundColor: AppColors.background,
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
                  label: Text('$_itemCount عنصر - ${_total.toStringAsFixed(2)} ر.س'),
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
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
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
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.primaryBorder),
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
                        hintText: 'امسح الباركود أو أدخله (F1)',
                        hintStyle: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textMuted,
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
                    tooltip: 'فتح الكاميرا',
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
              hint: 'بحث عن منتج (F2)',
              controller: _searchController,
              onChanged: (_) => setState(() {}),
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
              tooltip: _showCart ? 'إخفاء السلة' : 'إظهار السلة',
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
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
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
            color: category == 'الكل'
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
            _selectedCategory = 'الكل';
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
          onTap: () => _addProduct(product),
        );
      },
    );
  }

  /// قسم السلة
  Widget _buildCartSection() {
    return Container(
      color: AppColors.surface,
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
      title: 'السلة',
      icon: Icons.shopping_cart,
      onClose: AppBreakpoints.isMobile(context)
          ? () => setState(() => _showCart = false)
          : null,
      actions: [
        if (_cartItems.isNotEmpty)
          TextButton.icon(
            onPressed: _clearCart,
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('مسح'),
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
        color: AppColors.surface,
        border: const Border(
          top: BorderSide(color: AppColors.border),
        ),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        children: [
          // Summary Lines
          _buildSummaryLine('المجموع الفرعي', _subtotal),
          const SizedBox(height: AppSpacing.xs),
          _buildSummaryLine('ضريبة القيمة المضافة (15%)', _vat),

          const Divider(height: AppSpacing.xl),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الإجمالي',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${_total.toStringAsFixed(2)} ر.س',
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
                  label: 'تعليق',
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
                  label: 'الدفع',
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
            'F12 للدفع السريع',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textMuted,
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
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          '${amount.toStringAsFixed(2)} ر.س',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
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

  void _addByBarcode(String barcode) {
    if (barcode.isEmpty) return;

    final product = _products.firstWhere(
      (p) => p.barcode == barcode,
      orElse: () => Product(
        id: DateTime.now().toString(),
        name: 'منتج #$barcode',
        price: (barcode.hashCode.abs() % 100 + 10).toDouble(),
        barcode: barcode,
        category: 'أخرى',
        quantity: 100,
      ),
    );

    _addProduct(product);
    _barcodeController.clear();
    _focusNode.requestFocus();
  }

  void _addProduct(Product product) {
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
      title: 'مسح السلة',
      message: 'هل تريد مسح جميع المنتجات من السلة؟',
      confirmText: 'مسح',
      isDangerous: true,
    );

    if (confirmed == true) {
      setState(() => _cartItems.clear());
    }
  }

  void _holdOrder() {
    // TODO: Implement hold order
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تعليق الطلب'),
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

class Product {
  final String id;
  final String name;
  final double price;
  final String barcode;
  final String category;
  final int quantity;
  final String? imageUrl;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.barcode,
    required this.category,
    required this.quantity,
    this.imageUrl,
  });
}

class CartItem {
  final Product product;
  final int quantity;

  const CartItem({
    required this.product,
    required this.quantity,
  });

  double get total => product.price * quantity;

  CartItem copyWith({
    Product? product,
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
  final Product product;
  final VoidCallback onTap;

  const _ProductTile({
    required this.product,
    required this.onTap,
  });

  @override
  State<_ProductTile> createState() => _ProductTileState();
}

class _ProductTileState extends State<_ProductTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final categoryColor = AppColors.getCategoryColor(widget.product.category);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: AppDurations.fast,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: _isHovered ? AppColors.primary : AppColors.border,
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
                          widget.product.category,
                          style: AppTypography.labelSmall.copyWith(
                            color: categoryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Stock indicator
                      AppBadge.stock(widget.product.quantity),
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
                        _getCategoryIcon(widget.product.category),
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
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  // Price
                  Text(
                    '${widget.product.price.toStringAsFixed(2)} ر.س',
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
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
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
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${item.product.price.toStringAsFixed(2)} ر.س',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
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
                'ر.س',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),

          // Remove Button
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close),
            iconSize: 18,
            color: AppColors.error,
            tooltip: 'حذف',
          ),
        ],
      ),
    );
  }
}
