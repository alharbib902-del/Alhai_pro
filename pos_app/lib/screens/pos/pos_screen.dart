import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:alhai_core/alhai_core.dart';
import '../../core/router/routes.dart';
import '../../core/constants/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/responsive/responsive_utils.dart';
import '../../core/utils/keyboard_shortcuts.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/products_providers.dart';
import '../../providers/cart_providers.dart';
import '../../widgets/responsive/responsive_builder.dart';
import '../../widgets/common/offline_banner.dart';
import '../../widgets/common/cashier_mode_wrapper.dart';
import '../../widgets/pos/pos_widgets.dart';
import '../../widgets/pos/customer_search_dialog.dart';
import '../../widgets/pos/quantity_input_dialog.dart';
import '../../widgets/pos/barcode_listener.dart';
import '../../widgets/pos/payment_success_dialog.dart';
import '../../widgets/pos/sale_note_dialog.dart';
import '../../providers/sale_providers.dart';
import '../../providers/sync_providers.dart';
import '../../providers/held_invoices_providers.dart';
import 'hold_invoices_screen.dart';
import '../../widgets/orders/orders_widgets.dart';
import '../../widgets/layout/app_header.dart';
import '../../services/manager_approval_service.dart';

/// شاشة نقطة البيع الرئيسية - التصميم الجديد
///
/// تعرض المنتجات وسلة المشتريات في عرض مقسم مع app shell (sidebar + header)
/// متجاوبة: على الهواتف السلة في BottomSheet
class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  String? _selectedCategoryId;
  final _searchFocusNode = FocusNode();
  final _keyboardFocusNode = FocusNode();
  bool _showOrdersPanel = false;
  int _orderCounter = 1;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId != null) {
        ref.read(productsStateProvider.notifier)
            .loadProducts(storeId: storeId, refresh: true);
      }
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  void _addQuickProduct(int number) {
    final products = ref.read(productsStateProvider).products;
    if (number <= products.length) {
      final product = products[number - 1];
      ref.read(cartStateProvider.notifier).addProduct(product);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('➕ ${product.name}'),
          duration: const Duration(milliseconds: 500),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showCartBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Drag handle
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.grey600 : AppColors.grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Cart content
                Expanded(child: _CartPanel(
                  isBottomSheet: true,
                  onHoldInvoice: () {
                    Navigator.pop(context);
                    _holdCurrentInvoice();
                  },
                  onShowHeldInvoices: () {
                    Navigator.pop(context);
                    _showHeldInvoices();
                  },
                )),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showPaymentDialog(double total) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = MediaQuery.of(context).size.width > 900;

    if (isWide) {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: InlinePayment(
              total: total,
              onCancel: () => Navigator.pop(ctx),
              onComplete: (result) {
                Navigator.pop(ctx);
                _handlePaymentComplete(result);
              },
            ),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              InlinePayment(
                total: total,
                onCancel: () => Navigator.pop(ctx),
                onComplete: (result) {
                  Navigator.pop(ctx);
                  _handlePaymentComplete(result);
                },
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<void> _handlePaymentComplete(PaymentResult result) async {
    final cartState = ref.read(cartStateProvider);

    // 1. حفظ البيع في قاعدة البيانات
    String? saleId;
    String receiptNumber = 'ORD-${_orderCounter.toString().padLeft(4, '0')}';
    try {
      final saleService = ref.read(saleServiceProvider);
      final storeId = ref.read(currentStoreIdProvider) ?? 'store_demo_001';
      saleId = await saleService.createSale(
        storeId: storeId,
        cashierId: 'cashier_001',
        items: cartState.items,
        subtotal: cartState.subtotal,
        discount: cartState.discount,
        tax: cartState.subtotal * 0.15,
        total: result.amountPaid - result.change,
        paymentMethod: result.method.name,
        customerId: result.customerId,
        customerName: result.customerName,
      );

      // جلب رقم الإيصال الحقيقي من قاعدة البيانات
      final db = ref.read(appDatabaseProvider);
      final sale = await db.salesDao.getSaleById(saleId);
      if (sale != null) {
        receiptNumber = sale.receiptNo;
      }
    } catch (e) {
      debugPrint('Save sale error: $e');
    }

    // 2. مسح السلة
    ref.read(cartStateProvider.notifier).clear();
    setState(() => _orderCounter++);

    if (!mounted) return;

    // 3. عرض dialog النجاح مع saleId (الطباعة تتم داخل Dialog)
    await PaymentSuccessDialog.show(
      context: context,
      receiptNumber: receiptNumber,
      amount: result.amountPaid,
      paymentMethodLabel: result.method.localizedLabel(AppLocalizations.of(context)!),
      customerPhone: result.customerPhone,
      customerName: result.customerName,
      saleId: saleId,
    );
  }

  Future<void> _handleBarcodeScan(String barcode) async {
    final repository = ref.read(productsRepositoryProvider);
    final product = await repository.getByBarcode(barcode);
    if (!mounted) return;

    if (product != null) {
      ref.read(cartStateProvider.notifier).addProduct(product);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📦 ${product.name}'),
          duration: const Duration(milliseconds: 800),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.productNotFound}: $barcode'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  String _getDateSubtitle(AppLocalizations l10n) {
    final now = DateTime.now();
    final locale = Localizations.localeOf(context).toString();
    final dateStr = DateFormat('d MMMM yyyy', locale).format(now);
    return '$dateStr • ${l10n.mainBranch}';
  }

  @override
  Widget build(BuildContext context) {
    final cartItemCount = ref.watch(cartItemCountProvider);
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final l10n = AppLocalizations.of(context)!;

    return BarcodeListener(
      onBarcodeScanned: _handleBarcodeScan,
      child: PosKeyboardListener(
      onSearch: () => _searchFocusNode.requestFocus(),
      onNewSale: () {
        ref.read(cartStateProvider.notifier).clear();
        setState(() => _orderCounter++);
      },
      onCheckout: () {
        final cartState = ref.read(cartStateProvider);
        if (cartState.items.isNotEmpty) {
          final subtotal = cartState.subtotal;
          final tax = subtotal * 0.15;
          final total = subtotal + tax - cartState.discount;
          _showPaymentDialog(total);
        }
      },
      onUndo: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.undoComingSoon)),
        );
      },
      onCancel: () => context.go(AppRoutes.home),
      onQuickAdd: _addQuickProduct,
      onQuantityChange: (increase) {},
      child: Scaffold(
        // Mobile FAB
        floatingActionButton: context.isMobile
            ? _PosFab(
                itemCount: cartItemCount,
                onTap: _showCartBottomSheet,
              )
            : null,
        body: CashierModeWrapper(
          child: Column(
            children: [
              // Header
              AppHeader(
                title: l10n.pos,
                subtitle: _getDateSubtitle(l10n),
                showSearch: isWideScreen,
                searchHint: l10n.searchPlaceholder,
                onMenuTap: isWideScreen
                    ? null
                    : () => Scaffold.of(context).openDrawer(),
                onNotificationsTap: () {},
                notificationsCount: 0,
                userName: l10n.cashCustomer,
                userRole: l10n.branchManager,
                onUserTap: () {},
              ),

              // Offline banner
              const OfflineBanner(),

              // Orders panel + main content
              Expanded(
                child: Row(
                  children: [
                    if (_showOrdersPanel)
                      OrdersPanel(
                        onClose: () =>
                            setState(() => _showOrdersPanel = false),
                      ),

                    // Main POS content
                    Expanded(
                      child: ResponsiveBuilder(
                        builder: (context, deviceType, screenWidth) {
                          if (deviceType.isMobile) {
                            return _ProductsPanel(
                              selectedCategoryId: _selectedCategoryId,
                              onCategorySelected: _onCategorySelected,
                              columns: 3,
                              showShortcutsBar: false,
                              onHoldInvoice: _holdCurrentInvoice,
                              onShowHeldInvoices: _showHeldInvoices,
                            );
                          }

                          return Row(
                            children: [
                              Expanded(
                                flex: 65,
                                child: _ProductsPanel(
                                  selectedCategoryId:
                                      _selectedCategoryId,
                                  onCategorySelected:
                                      _onCategorySelected,
                                  columns:
                                      deviceType.isTablet ? 4 : 4,
                                  showShortcutsBar: true,
                                  onHoldInvoice: _holdCurrentInvoice,
                                  onShowHeldInvoices: _showHeldInvoices,
                                ),
                              ),
                              Expanded(
                                flex: 35,
                                child: _CartPanel(
                                  orderNumber:
                                      'ORD-${DateTime.now().year}-${_orderCounter.toString().padLeft(3, '0')}',
                                  onPayTap: _showPaymentDialog,
                                  onHoldInvoice: _holdCurrentInvoice,
                                  onShowHeldInvoices: _showHeldInvoices,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }

  /// تعليق الفاتورة الحالية مع ملاحظة اختيارية
  Future<void> _holdCurrentInvoice() async {
    final cartState = ref.read(cartStateProvider);
    if (cartState.isEmpty) return;

    final l10n = AppLocalizations.of(context)!;
    String? note;

    // حوار إدخال ملاحظة
    final controller = TextEditingController();
    note = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final dialogL10n = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(dialogL10n.suspendInvoice),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${dialogL10n.nItems(cartState.itemCount)} • ${cartState.total.toStringAsFixed(2)} ${dialogL10n.sar}',
                style: TextStyle(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: dialogL10n.noteOptional,
                  prefixIcon: const Icon(Icons.note_outlined),
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (value) => Navigator.pop(ctx, value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(dialogL10n.cancel),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(ctx, controller.text),
              icon: const Icon(Icons.pause_rounded, size: 18),
              label: Text(dialogL10n.suspend),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
    controller.dispose();

    // إذا ضغط المستخدم إلغاء
    if (note == null) return;

    // حفظ الفاتورة في قاعدة البيانات
    await holdCurrentInvoice(
      ref,
      name: note.isEmpty ? null : note,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.invoiceSuspended),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.warning,
      ),
    );
  }

  /// عرض شاشة الفواتير المعلقة
  Future<void> _showHeldInvoices() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const HoldInvoicesScreen()),
    );
    // القائمة تتحدث تلقائياً عبر invalidate في held_invoices_providers
  }

  void _onCategorySelected(String? categoryId) {
    setState(() => _selectedCategoryId = categoryId);
    final storeId = ref.read(currentStoreIdProvider);
    if (storeId != null) {
      ref
          .read(productsStateProvider.notifier)
          .filterByCategory(categoryId, storeId: storeId);
    }
  }
}

// =============================================================================
// MOBILE FAB
// =============================================================================

class _PosFab extends StatelessWidget {
  final int itemCount;
  final VoidCallback onTap;

  const _PosFab({required this.itemCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onTap,
      backgroundColor: AppColors.primary,
      elevation: 6,
      child: SizedBox(
        width: 56,
        height: 56,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.shopping_cart_rounded, color: Colors.white, size: 26),
            if (itemCount > 0)
              PositionedDirectional(
                top: 6,
                end: 6,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$itemCount',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// PRODUCTS PANEL
// =============================================================================

class _ProductsPanel extends ConsumerWidget {
  final String? selectedCategoryId;
  final ValueChanged<String?> onCategorySelected;
  final int columns;
  final bool showShortcutsBar;
  final VoidCallback? onHoldInvoice;
  final VoidCallback? onShowHeldInvoices;

  const _ProductsPanel({
    required this.selectedCategoryId,
    required this.onCategorySelected,
    this.columns = 3,
    this.showShortcutsBar = false,
    this.onHoldInvoice,
    this.onShowHeldInvoices,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsState = ref.watch(productsStateProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final isDesktop = showShortcutsBar; // Desktop has shortcuts bar

    return Container(
      color: isDark ? AppColors.backgroundDark : AppColors.background,
      child: Stack(
        children: [
          if (isDesktop)
            // Desktop: عمود تصنيفات جانبي + شبكة منتجات
            Row(
              children: [
                _CategoryColumn(
                  categories: categoriesAsync,
                  selectedCategoryId: selectedCategoryId,
                  onCategorySelected: onCategorySelected,
                ),
                Expanded(
                  child: _buildProductsGrid(context, ref, productsState, l10n),
                ),
              ],
            )
          else
            // Mobile: شريط تصنيفات أفقي + شبكة منتجات
            Column(
              children: [
                _CategoryBar(
                  categories: categoriesAsync,
                  selectedCategoryId: selectedCategoryId,
                  onCategorySelected: onCategorySelected,
                ),
                Expanded(
                  child: _buildProductsGrid(context, ref, productsState, l10n),
                ),
              ],
            ),

          // Desktop shortcuts bar
          if (showShortcutsBar)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(child: _ShortcutsBar(
                onHoldInvoice: onHoldInvoice,
                onShowHeldInvoices: onShowHeldInvoices,
              )),
            ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid(
      BuildContext context, WidgetRef ref, ProductsState state, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (state.isLoading && state.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error.withValues(alpha: 0.6)),
            const SizedBox(height: 16),
            Text('${l10n.error}: ${state.error}',
                style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                final storeId = ref.read(currentStoreIdProvider);
                if (storeId != null) {
                  ref.read(productsStateProvider.notifier)
                      .loadProducts(storeId: storeId, refresh: true);
                }
              },
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (state.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64,
                color: isDark ? AppColors.grey600 : AppColors.grey400),
            const SizedBox(height: 16),
            Text(l10n.noProducts,
                style: TextStyle(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  fontSize: 16,
                )),
            const SizedBox(height: 8),
            Text(l10n.addProductsToStart,
                style: TextStyle(
                  color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                  fontSize: 14,
                )),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final storeId = ref.read(currentStoreIdProvider);
        if (storeId != null) {
          await ref.read(productsStateProvider.notifier)
              .loadProducts(storeId: storeId, refresh: true);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: columns <= 3 ? 0.9 : 1.3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: state.products.length,
          itemBuilder: (context, index) {
            final product = state.products[index];
            return _ProductCard(
              product: product,
              onAddToCart: () {
                ref.read(cartStateProvider.notifier).addProduct(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('➕ ${product.name}'),
                    duration: const Duration(milliseconds: 800),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              onAddWithQuantity: () async {
                final qty = await QuantityInputDialog.show(context, product);
                if (qty != null && qty > 0 && context.mounted) {
                  ref.read(cartStateProvider.notifier).addProduct(product, quantity: qty);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('➕ ${product.name} × $qty'),
                      duration: const Duration(milliseconds: 800),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}

// =============================================================================
// CATEGORY COLUMN - Vertical (Desktop Only)
// =============================================================================

class _CategoryColumn extends StatelessWidget {
  final AsyncValue<List<Category>> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onCategorySelected;

  const _CategoryColumn({
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  IconData _getCategoryIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('مشروبات ساخنة') || lower.contains('hot') || lower.contains('قهوة') || lower.contains('coffee')) {
      return Icons.local_cafe_rounded;
    }
    if (lower.contains('مشروبات باردة') || lower.contains('cold') || lower.contains('عصير') || lower.contains('juice')) {
      return Icons.local_drink_rounded;
    }
    if (lower.contains('مشروبات') || lower.contains('drink') || lower.contains('beverage')) {
      return Icons.local_drink_rounded;
    }
    if (lower.contains('حلويات') || lower.contains('sweet') || lower.contains('سناك') || lower.contains('snack')) {
      return Icons.icecream_rounded;
    }
    if (lower.contains('فواكه') || lower.contains('fruit')) {
      return Icons.apple;
    }
    if (lower.contains('خضروات') || lower.contains('vegetable')) {
      return Icons.eco_rounded;
    }
    if (lower.contains('ألبان') || lower.contains('dairy') || lower.contains('milk')) {
      return Icons.water_drop_rounded;
    }
    if (lower.contains('لحوم') || lower.contains('meat')) {
      return Icons.restaurant_rounded;
    }
    if (lower.contains('مخبوزات') || lower.contains('bakery') || lower.contains('خبز')) {
      return Icons.bakery_dining_rounded;
    }
    if (lower.contains('تنظيف') || lower.contains('cleaning')) {
      return Icons.cleaning_services_rounded;
    }
    if (lower.contains('حبوب') || lower.contains('grain') || lower.contains('بقول')) {
      return Icons.grain_rounded;
    }
    if (lower.contains('مجمد') || lower.contains('frozen')) {
      return Icons.ac_unit_rounded;
    }
    return Icons.category_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          left: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
            width: 0.5,
          ),
        ),
      ),
      child: categories.when(
        data: (cats) {
          final allItems = [
            _CategoryColumnItem(
              icon: Icons.grid_view_rounded,
              label: l10n.all,
              isActive: selectedCategoryId == null,
              onTap: () => onCategorySelected(null),
              color: AppColors.primary,
            ),
            ...cats.map((cat) => _CategoryColumnItem(
                  icon: _getCategoryIcon(cat.name),
                  label: cat.name,
                  isActive: selectedCategoryId == cat.id,
                  onTap: () => onCategorySelected(cat.id),
                  color: AppColors.primary,
                )),
          ];

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: allItems.length,
            itemBuilder: (context, index) => allItems[index],
          );
        },
        loading: () => const Center(
            child: SizedBox(
                width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
        error: (e, _) => const Center(
            child: Icon(Icons.error_outline, color: AppColors.error, size: 20)),
      ),
    );
  }
}

class _CategoryColumnItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color color;

  const _CategoryColumnItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isActive
                  ? color.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: isActive
                  ? Border.all(color: color.withValues(alpha: 0.4), width: 1.5)
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isActive
                        ? color.withValues(alpha: 0.2)
                        : isDark
                            ? AppColors.grey700.withValues(alpha: 0.5)
                            : AppColors.grey100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: isActive
                        ? color
                        : isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive
                        ? color
                        : isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// CATEGORY BAR - Pill Style (Mobile Only)
// =============================================================================

class _CategoryBar extends StatelessWidget {
  final AsyncValue<List<Category>> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onCategorySelected;

  const _CategoryBar({
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  IconData _getCategoryIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('مشروبات ساخنة') || lower.contains('hot') || lower.contains('قهوة') || lower.contains('coffee')) {
      return Icons.local_cafe_rounded;
    }
    if (lower.contains('مشروبات باردة') || lower.contains('cold') || lower.contains('عصير') || lower.contains('juice')) {
      return Icons.local_drink_rounded;
    }
    if (lower.contains('حلويات') || lower.contains('sweet') || lower.contains('كيك') || lower.contains('cake')) {
      return Icons.cake_rounded;
    }
    if (lower.contains('وجبات') || lower.contains('snack') || lower.contains('meal') || lower.contains('burger')) {
      return Icons.fastfood_rounded;
    }
    if (lower.contains('فواكه') || lower.contains('fruit')) {
      return Icons.apple;
    }
    if (lower.contains('خضروات') || lower.contains('vegetable')) {
      return Icons.eco_rounded;
    }
    if (lower.contains('ألبان') || lower.contains('dairy') || lower.contains('milk')) {
      return Icons.water_drop_rounded;
    }
    if (lower.contains('لحوم') || lower.contains('meat')) {
      return Icons.restaurant_rounded;
    }
    if (lower.contains('مخبوزات') || lower.contains('bakery') || lower.contains('خبز')) {
      return Icons.bakery_dining_rounded;
    }
    if (lower.contains('تنظيف') || lower.contains('cleaning')) {
      return Icons.cleaning_services_rounded;
    }
    return Icons.category_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
      ),
      child: categories.when(
        data: (cats) => ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          children: [
            _CategoryPill(
              icon: Icons.grid_view_rounded,
              label: l10n.all,
              isActive: selectedCategoryId == null,
              onTap: () => onCategorySelected(null),
            ),
            ...cats.map((cat) => _CategoryPill(
                  icon: _getCategoryIcon(cat.name),
                  label: cat.name,
                  isActive: selectedCategoryId == cat.id,
                  onTap: () => onCategorySelected(cat.id),
                )),
          ],
        ),
        loading: () => const Center(
            child: SizedBox(
                width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))),
        error: (e, _) => Center(
            child: Text('${l10n.error}: $e',
                style: const TextStyle(color: AppColors.error, fontSize: 12))),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _CategoryPill({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary
                  : isDark
                      ? AppColors.surfaceVariantDark
                      : AppColors.grey100,
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: isActive
                  ? null
                  : Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.grey200,
                      width: 0.5,
                    ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.white.withValues(alpha: 0.25)
                        : isDark
                            ? AppColors.grey600.withValues(alpha: 0.3)
                            : AppColors.grey200,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 13,
                    color: isActive
                        ? Colors.white
                        : isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive
                        ? Colors.white
                        : isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// PRODUCT CARD - Rich Design
// =============================================================================

class _ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onAddToCart;
  final VoidCallback? onAddWithQuantity;

  const _ProductCard({
    required this.product,
    required this.onAddToCart,
    this.onAddWithQuantity,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final isOutOfStock = product.isOutOfStock;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final imageHeight = getResponsiveValue<double>(
      context,
      mobile: 56,
      desktop: 56,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: isOutOfStock ? null : widget.onAddToCart,
        child: AnimatedScale(
        scale: _isHovered && !isOutOfStock ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.grey200,
              width: 0.5,
            ),
            boxShadow: _isHovered ? AppShadows.md : AppShadows.sm,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image area with overlays
              _buildImageArea(product, imageHeight, isOutOfStock, isDark, l10n),

              // Info area - Row with consistent + button position
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(8, 4, 4, 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Product name
                      Expanded(
                        child: Text(
                          product.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Add to cart button (+)
                      if (!isOutOfStock)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(start: 4),
                          child: Material(
                            color: AppColors.primary,
                            shape: const CircleBorder(),
                            elevation: 2,
                            child: InkWell(
                              onTap: widget.onAddWithQuantity ?? widget.onAddToCart,
                              customBorder: const CircleBorder(),
                              child: const SizedBox(
                                width: 28,
                                height: 28,
                                child: Icon(Icons.add_rounded,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildImageArea(
      Product product, double height, bool isOutOfStock, bool isDark, AppLocalizations l10n) {
    Widget imageWidget = Container(
      height: height,
      width: double.infinity,
      color: isDark ? AppColors.surfaceVariantDark : AppColors.grey100,
      child: product.imageThumbnail != null
          ? CachedNetworkImage(
              imageUrl: product.imageThumbnail!,
              fit: BoxFit.cover,
              placeholder: (_, __) => Center(
                child: Icon(Icons.image_rounded,
                    color: isDark ? AppColors.grey600 : AppColors.grey300, size: 32),
              ),
              errorWidget: (_, __, ___) => Center(
                child: Icon(Icons.image_not_supported_outlined,
                    color: isDark ? AppColors.grey600 : AppColors.grey400, size: 32),
              ),
            )
          : Center(
              child: Icon(Icons.image_rounded,
                  color: isDark ? AppColors.grey600 : AppColors.grey300, size: 40),
            ),
    );

    // Grayscale for out of stock
    if (isOutOfStock) {
      imageWidget = ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0, //
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0, 0, 0, 1, 0,
        ]),
        child: imageWidget,
      );
    }

    return Stack(
      children: [
        imageWidget,

        // Price badge (top-right)
        if (!isOutOfStock)
          PositionedDirectional(
            top: 6,
            end: 6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.grey700.withValues(alpha: 0.85)
                        : Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${product.price.toStringAsFixed(0)} ${l10n.sar}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Discount overlay (bottom of image)
        // Note: discount field to be added to Product model in future
        // When available, show: l10n.discountPercent(discount.toStringAsFixed(0))

        // Out of stock badge
        if (isOutOfStock)
          Positioned.fill(
            child: Center(
              child: Transform.rotate(
                angle: -0.3,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    l10n.quantitySoldOut,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Low stock indicator
        if (product.isLowStock && !isOutOfStock)
          PositionedDirectional(
            top: 6,
            start: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Colors.white, size: 12),
                  const SizedBox(width: 3),
                  Text(
                    l10n.lowStock,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// =============================================================================
// CART PANEL
// =============================================================================

class _CartPanel extends ConsumerWidget {
  final bool isBottomSheet;
  final String? orderNumber;
  final Function(double total)? onPayTap;
  final VoidCallback? onHoldInvoice;
  final VoidCallback? onShowHeldInvoices;

  const _CartPanel({
    this.isBottomSheet = false,
    this.orderNumber,
    this.onPayTap,
    this.onHoldInvoice,
    this.onShowHeldInvoices,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartStateProvider);
    final items = cartState.items;
    final subtotal = cartState.subtotal;
    final tax = subtotal * 0.15;
    final total = subtotal + tax - cartState.discount;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: isBottomSheet
            ? null
            : Border(
                left: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.grey200,
                ),
              ),
      ),
      child: Column(
        children: [
          // Cart header
          _buildCartHeader(context, ref, cartState, isDark, l10n),

          // Customer input
          _buildCustomerInput(context, ref, cartState, isDark, l10n),

          // Divider
          Divider(
            height: 1,
            color: isDark ? AppColors.borderDark : AppColors.grey200,
          ),

          // Cart items
          Expanded(
            child: items.isEmpty
                ? _buildEmptyCart(context, isDark, l10n)
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 16,
                      color: isDark ? AppColors.borderDark : AppColors.grey100,
                    ),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _CartItemTile(item: item);
                    },
                  ),
          ),

          // Discount + Coupon links
          if (items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  // زر تطبيق خصم
                  TextButton.icon(
                    onPressed: () => _showDiscountDialog(context, ref, subtotal),
                    icon: const Icon(Icons.percent_rounded, size: 16, color: AppColors.success),
                    label: Text(
                      l10n.discount,
                      style: const TextStyle(
                        color: AppColors.success,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 32),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // كوبون
                  TextButton.icon(
                    onPressed: () {
                      // TODO: coupon dialog
                    },
                    icon: const Text('\uD83C\uDFF7\uFE0F', style: TextStyle(fontSize: 14)),
                    label: Text(
                      l10n.haveCoupon,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 32),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // ملاحظة
                  TextButton.icon(
                    onPressed: () async {
                      final result = await SaleNoteDialog.show(
                        context,
                        initialNote: cartState.notes,
                      );
                      if (result != null) {
                        ref.read(cartStateProvider.notifier).setNotes(
                              result.isEmpty ? null : result,
                            );
                      }
                    },
                    icon: Icon(
                      cartState.notes != null && cartState.notes!.isNotEmpty
                          ? Icons.note_rounded
                          : Icons.note_add_outlined,
                      size: 16,
                      color: cartState.notes != null && cartState.notes!.isNotEmpty
                          ? AppColors.warning
                          : AppColors.info,
                    ),
                    label: Text(
                      cartState.notes != null && cartState.notes!.isNotEmpty
                          ? 'ملاحظة'
                          : 'ملاحظة',
                      style: TextStyle(
                        color: cartState.notes != null && cartState.notes!.isNotEmpty
                            ? AppColors.warning
                            : AppColors.info,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 32),
                    ),
                  ),
                ],
              ),
            ),

          // Note indicator chip
          if (cartState.notes != null && cartState.notes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.note_rounded,
                        size: 16, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        cartState.notes!,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: () => ref
                          .read(cartStateProvider.notifier)
                          .setNotes(null),
                      child: const Icon(Icons.close,
                          size: 16, color: AppColors.warning),
                    ),
                  ],
                ),
              ),
            ),

          // Totals + action buttons
          _buildCartFooter(context, ref, cartState, subtotal, tax, total,
              isDark, l10n, items.isNotEmpty),
        ],
      ),
    );
  }

  Widget _buildCartHeader(BuildContext context, WidgetRef ref,
      CartState cartState, bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.grey100,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.grey200,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.shopping_cart_rounded,
              size: 20,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              l10n.shoppingCart,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
          ),
          if (cartState.items.isNotEmpty) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${cartState.itemCount}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          const Spacer(),
          if (orderNumber != null)
            Flexible(
              child: Text(
                '#$orderNumber',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          if (cartState.items.isNotEmpty) ...[
            const SizedBox(width: 8),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => ref.read(cartStateProvider.notifier).clear(),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(Icons.delete_outline_rounded,
                      size: 20, color: AppColors.error.withValues(alpha: 0.7)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomerInput(BuildContext context, WidgetRef ref,
      CartState cartState, bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final result = await CustomerSearchDialog.show(context);
                if (result != null) {
                  ref.read(cartStateProvider.notifier).setCustomer(
                        result.id,
                        customerName: result.name,
                      );
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.backgroundDark : AppColors.grey50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.grey200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person_outline_rounded,
                        size: 18,
                        color: isDark ? AppColors.textMutedDark : AppColors.grey400),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        cartState.customerName ?? l10n.selectOrSearchCustomer,
                        style: TextStyle(
                          fontSize: 13,
                          color: cartState.customerName != null
                              ? (isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary)
                              : (isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.grey400),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () {
              // TODO: create new customer dialog
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              minimumSize: const Size(0, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('+${l10n.newCustomer}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(
      BuildContext context, bool isDark, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: isDark ? AppColors.grey600 : AppColors.grey300,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.cartEmpty,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.addProductsToStart,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartFooter(
      BuildContext context,
      WidgetRef ref,
      CartState cartState,
      double subtotal,
      double tax,
      double total,
      bool isDark,
      AppLocalizations l10n,
      bool hasItems) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.grey50,
        border: Border(
          top: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.grey200),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Subtotal
          _TotalRow(
            label: l10n.subtotal,
            value: '${subtotal.toStringAsFixed(2)} ${l10n.sar}',
            isDark: isDark,
          ),
          const SizedBox(height: 6),

          // Tax
          _TotalRow(
            label: '${l10n.tax} (15%)',
            value: '${tax.toStringAsFixed(2)} ${l10n.sar}',
            isDark: isDark,
          ),

          // Discount
          if (cartState.discount > 0) ...[
            const SizedBox(height: 6),
            _TotalRow(
              label: l10n.discount,
              value: '-${cartState.discount.toStringAsFixed(2)} ${l10n.sar}',
              isDark: isDark,
              valueColor: AppColors.success,
            ),
          ],

          Divider(
            height: 20,
            color: isDark ? AppColors.borderDark : AppColors.grey300,
          ),

          // Grand total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.grandTotal,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
              Text(
                '${total.toStringAsFixed(2)} ${l10n.sar}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action buttons: Draft + Pay
          Row(
            children: [
              // Draft button with held invoices badge
              Expanded(
                flex: 1,
                child: _DraftButton(
                  hasItems: hasItems,
                  isDark: isDark,
                  label: l10n.draft,
                  onTap: hasItems ? onHoldInvoice : null,
                  onLongPress: onShowHeldInvoices,
                ),
              ),
              const SizedBox(width: 8),

              // Pay button
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: hasItems ? AppColors.primaryGradient : null,
                    color: hasItems ? null : AppColors.grey300,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: hasItems ? AppShadows.primarySm : null,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: hasItems
                          ? () {
                              if (onPayTap != null) {
                                onPayTap!(total);
                              }
                            }
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.pay,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: hasItems
                                    ? Colors.white
                                    : AppColors.grey500,
                              ),
                            ),
                            if (hasItems) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${total.toStringAsFixed(2)} ${l10n.sar}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
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

  /// حوار إدخال خصم مع حماية PIN للخصومات > 20%
  void _showDiscountDialog(BuildContext context, WidgetRef ref, double subtotal) {
    final discountController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.percent_rounded, color: AppColors.success, size: 22),
              const SizedBox(width: 8),
              Text(l10n.discount),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: discountController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.discount,
                  hintText: '0 - 100',
                  suffixText: '%',
                  prefixIcon: const Icon(Icons.percent),
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (_) => _applyDiscount(
                  dialogContext, context, ref, discountController, subtotal,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => _applyDiscount(
                dialogContext, context, ref, discountController, subtotal,
              ),
              child: Text(l10n.confirm),
            ),
          ],
        );
      },
    ).then((_) => discountController.dispose());
  }

  /// تطبيق الخصم مع التحقق من PIN إذا تجاوز 20%
  Future<void> _applyDiscount(
    BuildContext dialogContext,
    BuildContext parentContext,
    WidgetRef ref,
    TextEditingController controller,
    double subtotal,
  ) async {
    final percent = double.tryParse(controller.text);
    if (percent == null || percent < 0 || percent > 100) return;

    Navigator.pop(dialogContext);

    // إذا الخصم أكثر من 20%: طلب موافقة المشرف
    if (percent > 20) {
      if (!parentContext.mounted) return;
      final approved = await ManagerApprovalService.requestPinApproval(
        context: parentContext,
        action: 'discount_over_20',
      );
      if (!approved) return;
    }

    final discountAmount = subtotal * (percent / 100);
    ref.read(cartStateProvider.notifier).setDiscount(discountAmount);
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final Color? valueColor;

  const _TotalRow({
    required this.label,
    required this.value,
    required this.isDark,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: valueColor ??
                (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// CART ITEM TILE - Redesigned
// =============================================================================

class _CartItemTile extends ConsumerWidget {
  final PosCartItem item;

  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Product image
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 56,
            height: 56,
            child: item.product.imageThumbnail != null
                ? CachedNetworkImage(
                    imageUrl: item.product.imageThumbnail!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: isDark ? AppColors.surfaceVariantDark : AppColors.grey100,
                      child: Icon(Icons.image, size: 20,
                          color: isDark ? AppColors.grey600 : AppColors.grey300),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: isDark ? AppColors.surfaceVariantDark : AppColors.grey100,
                      child: Icon(Icons.image, size: 20,
                          color: isDark ? AppColors.grey600 : AppColors.grey300),
                    ),
                  )
                : Container(
                    color: isDark ? AppColors.surfaceVariantDark : AppColors.grey100,
                    child: Icon(Icons.image, size: 20,
                        color: isDark ? AppColors.grey600 : AppColors.grey300),
                  ),
          ),
        ),
        const SizedBox(width: 10),

        // Name + price
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${item.effectivePrice.toStringAsFixed(2)} ${l10n.sar}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),

        // Quantity controls
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Decrease button
            _QtyButton(
              icon: Icons.remove,
              isDark: isDark,
              isPrimary: false,
              onTap: () {
                if (item.quantity > 1) {
                  ref
                      .read(cartStateProvider.notifier)
                      .decrementQuantity(item.product.id);
                } else {
                  ref
                      .read(cartStateProvider.notifier)
                      .removeProduct(item.product.id);
                }
              },
            ),
            SizedBox(
              width: 28,
              child: Text(
                '${item.quantity}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
            ),
            // Increase button
            _QtyButton(
              icon: Icons.add,
              isDark: isDark,
              isPrimary: true,
              onTap: () {
                ref
                    .read(cartStateProvider.notifier)
                    .incrementQuantity(item.product.id);
              },
            ),
          ],
        ),

        const SizedBox(width: 6),

        // Edit button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // TODO: edit item dialog (change price/qty)
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.edit_outlined,
                size: 18,
                color: AppColors.info.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final bool isPrimary;
  final VoidCallback onTap;

  const _QtyButton({
    required this.icon,
    required this.isDark,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary
          ? AppColors.primary
          : isDark
              ? AppColors.surfaceVariantDark
              : AppColors.grey100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: isPrimary
            ? BorderSide.none
            : BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.grey300,
                width: 0.5,
              ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 28,
          height: 28,
          child: Icon(
            icon,
            size: 16,
            color: isPrimary
                ? Colors.white
                : isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// DRAFT BUTTON WITH BADGE
// =============================================================================

class _DraftButton extends ConsumerWidget {
  final bool hasItems;
  final bool isDark;
  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _DraftButton({
    required this.hasItems,
    required this.isDark,
    required this.label,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heldCount = ref.watch(dbHeldInvoicesCountProvider);

    return GestureDetector(
      onLongPress: onLongPress,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          OutlinedButton(
            onPressed: hasItems ? onTap : (heldCount > 0 ? onLongPress : null),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(
                color: heldCount > 0
                    ? AppColors.warning
                    : isDark
                        ? AppColors.grey600
                        : AppColors.grey300,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (heldCount > 0) ...[
                  const Icon(Icons.pause_circle_outline, size: 16, color: AppColors.warning),
                  const SizedBox(width: 4),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: heldCount > 0
                        ? AppColors.warning
                        : isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Badge
          if (heldCount > 0)
            PositionedDirectional(
              top: -6,
              end: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                decoration: const BoxDecoration(
                  color: AppColors.warning,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$heldCount',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// =============================================================================
// SHORTCUTS BAR (Desktop Only)
// =============================================================================

class _ShortcutsBar extends ConsumerWidget {
  final VoidCallback? onHoldInvoice;
  final VoidCallback? onShowHeldInvoices;

  const _ShortcutsBar({
    this.onHoldInvoice,
    this.onShowHeldInvoices,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final heldCount = ref.watch(dbHeldInvoicesCountProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.full),
        boxShadow: AppShadows.lg,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.grey200,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ShortcutButton(
            icon: Icons.point_of_sale_rounded,
            label: l10n.openDrawer,
            color: AppColors.info,
            onTap: () {
              // TODO: open cash drawer
            },
          ),
          const SizedBox(width: 20),
          _ShortcutButton(
            icon: Icons.replay_rounded,
            label: l10n.refund,
            color: const Color(0xFF8B5CF6), // purple
            onTap: () {
              // TODO: navigate to refund
            },
          ),
          const SizedBox(width: 20),
          // زر تعليق: tap = تعليق، long press = عرض المعلقات
          GestureDetector(
            onLongPress: onShowHeldInvoices,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _ShortcutButton(
                  icon: Icons.pause_rounded,
                  label: l10n.suspend,
                  color: AppColors.warning,
                  onTap: onHoldInvoice ?? () {},
                ),
                if (heldCount > 0)
                  PositionedDirectional(
                    top: -4,
                    end: -4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      decoration: const BoxDecoration(
                        color: AppColors.warning,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$heldCount',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortcutButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShortcutButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
