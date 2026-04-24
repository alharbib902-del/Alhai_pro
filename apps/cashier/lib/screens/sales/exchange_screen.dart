/// Exchange Screen - Return items and add new items in one transaction
///
/// Two sections: "Items to Return" and "New Items to Add".
/// Search/scan products for exchange, calculate difference.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_core/alhai_core.dart' show Product;
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_pos/alhai_pos.dart'
    show PosCartItem, createReturn, saleServiceProvider;
import '../../core/services/sentry_service.dart';
import '../../core/services/audit_service.dart';
import '../../core/services/haptic_shim.dart';
import '../../core/services/sound_service.dart';
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiBreakpoints, AlhaiSnackbar, AlhaiSpacing;
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
        HapticShim.vibrate();
        SoundService.instance.errorBuzz();
        AlhaiSnackbar.error(
          context,
          AppLocalizations.of(context).errorOccurred,
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
        list.add(
          _ExchangeItem(
            productId: product.id,
            productName: product.name,
            // C-4 Stage B: product.price is int cents; exchange item schema is double SAR.
            price: product.price / 100.0,
            qty: 1,
            product: product,
          ),
        );
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
            padding: EdgeInsets.all(
              isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md,
            ),
            child: isWideScreen
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildReturnSection(isDark, l10n)),
                      const SizedBox(width: AlhaiSpacing.lg),
                      Expanded(child: _buildNewItemsSection(isDark, l10n)),
                    ],
                  )
                : Column(
                    children: [
                      _buildReturnSection(isDark, l10n),
                      SizedBox(
                        height: isMediumScreen
                            ? AlhaiSpacing.lg
                            : AlhaiSpacing.md,
                      ),
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
                child: const Icon(
                  Icons.assignment_return_rounded,
                  color: AppColors.error,
                  size: 20,
                ),
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
          _buildSearchBar(_returnSearchController, isDark, l10n, true),
          if (_returnSearchResults.isNotEmpty)
            _buildSearchResults(_returnSearchResults, isDark, true),
          const SizedBox(height: AlhaiSpacing.sm),
          ..._returnItems.asMap().entries.map(
            (e) => _buildExchangeItemCard(e.value, e.key, isDark, l10n, true),
          ),
          if (_returnItems.isNotEmpty)
            Padding(
              padding: const EdgeInsetsDirectional.only(top: AlhaiSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.subtotal,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                  ),
                  Text(
                    '${_returnTotal.toStringAsFixed(2)} ${l10n.sar}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.error,
                    ),
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
                child: const Icon(
                  Icons.add_shopping_cart_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
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
          _buildSearchBar(_newSearchController, isDark, l10n, false),
          if (_newSearchResults.isNotEmpty)
            _buildSearchResults(_newSearchResults, isDark, false),
          const SizedBox(height: AlhaiSpacing.sm),
          ..._newItems.asMap().entries.map(
            (e) => _buildExchangeItemCard(e.value, e.key, isDark, l10n, false),
          ),
          if (_newItems.isNotEmpty)
            Padding(
              padding: const EdgeInsetsDirectional.only(top: AlhaiSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.subtotal,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                  ),
                  Text(
                    '${_newTotal.toStringAsFixed(2)} ${l10n.sar}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(
    TextEditingController controller,
    bool isDark,
    AppLocalizations l10n,
    bool isReturn,
  ) {
    return TextField(
      controller: controller,
      style: TextStyle(color: AppColors.getTextPrimary(isDark)),
      onChanged: (v) => _searchProducts(v, isReturn),
      decoration: InputDecoration(
        hintText: l10n.searchPlaceholder,
        hintStyle: TextStyle(color: AppColors.getTextMuted(isDark)),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: AppColors.getTextMuted(isDark),
        ),
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AlhaiSpacing.md,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildSearchResults(
    List<ProductsTableData> results,
    bool isDark,
    bool isReturn,
  ) {
    return Container(
      margin: const EdgeInsetsDirectional.only(top: AlhaiSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getBorder(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
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
                horizontal: AlhaiSpacing.md,
                vertical: AlhaiSpacing.sm,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 18,
                    color: AppColors.getTextMuted(isDark),
                  ),
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
                    // product.price is int cents; fromCentsWithContext divides
                    // by 100 + localises. Raw toStringAsFixed inflates 100×.
                    CurrencyFormatter.fromCentsWithContext(
                      context,
                      product.price,
                    ),
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

  Widget _buildExchangeItemCard(
    _ExchangeItem item,
    int index,
    bool isDark,
    AppLocalizations l10n,
    bool isReturn,
  ) {
    final total = item.price * item.qty;
    return Container(
      margin: const EdgeInsetsDirectional.only(bottom: AlhaiSpacing.xs),
      padding: const EdgeInsets.all(AlhaiSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceVariant(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.getBorder(isDark).withValues(alpha: 0.5),
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
                onPressed: () => _updateQty(index, item.qty - 1, isReturn),
                icon: const Icon(Icons.remove_circle_outline_rounded),
                iconSize: 22,
                color: AppColors.getTextSecondary(isDark),
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
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
                onPressed: () => _updateQty(index, item.qty + 1, isReturn),
                icon: const Icon(Icons.add_circle_outline_rounded),
                iconSize: 22,
                color: AppColors.primary,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
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
          top: BorderSide(color: AppColors.getBorder(isDark), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
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
                      color: AppColors.getTextSecondary(isDark),
                    ),
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
                    Text(
                      l10n.customerPaysExtra,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.getTextMuted(isDark),
                      ),
                    )
                  else if (diff < 0)
                    Text(
                      l10n.refundToCustomer,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.getTextMuted(isDark),
                      ),
                    ),
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
                          strokeWidth: 2,
                          color: AppColors.textOnPrimary,
                        ),
                      )
                    : const Icon(Icons.swap_horiz_rounded, size: 20),
                label: Text(
                  l10n.submitExchange,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(
                    vertical: AlhaiSpacing.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// تنفيذ عملية الاستبدال الفعلية.
  ///
  /// المنطق:
  /// 1. إذا وُجد [_newItems] → إنشاء بيع جديد عبر [SaleService.createSale]
  ///    (يولّد receipt + stockDeltas + invoice + sync enqueue تلقائياً).
  /// 2. إذا وُجد [_returnItems] → استدعاء [createReturn] على saleId
  ///    الجديد المُنشأ (أو رفض السيناريو إن لم يوجد بيع جديد —
  ///    المرتجع البحت يجب أن يمرّ عبر Returns screen حيث يُختار
  ///    البيع الأصلي، لأن FK returns.sale_id هو ON DELETE RESTRICT
  ///    ولا يقبل IDs مُخترعة).
  /// 3. balanceDiff = newTotal - returnTotal:
  ///    - موجب → العميل دفع الفرق cash (paymentMethod='cash').
  ///    - سالب → نُضيف الفرق إلى totalRefund في createReturn ليُرجع للعميل.
  ///    - صفر → استبدال متوازن (لا فرق).
  Future<void> _submitExchange(AppLocalizations l10n) async {
    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    final user = ref.read(currentUserProvider);
    final storeId = ref.read(currentStoreIdProvider);

    if (storeId == null) {
      setState(() => _isSubmitting = false);
      AlhaiSnackbar.error(context, l10n.errorOccurred);
      return;
    }

    // احسب المبالغ (SAR doubles للـ UI/math).
    final returnTotal = _returnTotal;
    final newTotal = _newTotal;
    final balanceDiff = newTotal - returnTotal;

    // سيناريو مرفوض: لا newItems → ليس استبدالاً. وجّه المستخدم لشاشة
    // Returns المخصصة (التي تربط المرتجع بسجل بيع سابق).
    if (_newItems.isEmpty && _returnItems.isNotEmpty) {
      setState(() => _isSubmitting = false);
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.errorOccurred),
          content: const Text(
            'Exchange requires at least one new item. For a pure refund, '
            'please use the Returns screen (which links the refund to the '
            'original sale).',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.close),
            ),
          ],
        ),
      );
      return;
    }

    // سيناريو رفض: لا newItems ولا returnItems — button معطّل أصلاً بهذا الشرط
    // لكن نحمي ضد race/state stale.
    if (_newItems.isEmpty && _returnItems.isEmpty) {
      setState(() => _isSubmitting = false);
      return;
    }

    String? createdSaleId;

    try {
      // ─── 1. إنشاء البيع الجديد (_newItems غير فارغة بالضرورة هنا) ─────
      final saleService = ref.read(saleServiceProvider);

      // تحويل _ExchangeItem → PosCartItem. نبني Product domain model من
      // ProductsTableData المحفوظة وقت الإضافة. price هنا int cents (product).
      final posItems = _newItems.map((ei) {
        final p = ei.product;
        final productModel = Product(
          id: p.id,
          storeId: p.storeId,
          name: p.name,
          sku: p.sku,
          barcode: p.barcode,
          price: p.price, // int cents (كما هو)
          costPrice: p.costPrice,
          stockQty: p.stockQty,
          minQty: p.minQty,
          unit: p.unit,
          description: p.description,
          imageThumbnail: p.imageThumbnail,
          imageMedium: p.imageMedium,
          imageLarge: p.imageLarge,
          imageHash: p.imageHash,
          categoryId: p.categoryId,
          isActive: p.isActive,
          trackInventory: p.trackInventory,
          createdAt: p.createdAt,
          updatedAt: p.updatedAt,
        );
        return PosCartItem(product: productModel, quantity: ei.qty);
      }).toList();

      // ضريبة القيمة المضافة 15% على إجمالي الـ newItems (نتبع نفس نمط POS).
      const vatRate = 0.15;
      final newSubtotal = newTotal; // SAR double
      final newTax = newSubtotal * vatRate;
      final newGrandTotal = newSubtotal + newTax;

      // paymentMethod: إن كان balanceDiff موجباً فالعميل يدفع cash للفرق
      // (وهو ما ندرجه كمبلغ مستلم للبيع). إن كان سالباً أو صفر فالبيع
      // مدفوع كاملاً من رصيد المرتجع — نضعه cash بنفس قيمة البيع لتجنب
      // تسجيل credit debt.
      final saleResult = await saleService.createSale(
        storeId: storeId,
        cashierId: user?.id ?? '',
        items: posItems,
        subtotal: newSubtotal,
        discount: 0,
        tax: newTax,
        total: newGrandTotal,
        paymentMethod: 'cash',
        amountReceived: newGrandTotal,
        changeAmount: 0,
        cashAmount: newGrandTotal,
        customerId: null,
        customerName: null,
        notes: _returnItems.isNotEmpty
            ? 'Exchange sale — linked to return of '
                  '${_returnItems.length} item(s), offset '
                  '${returnTotal.toStringAsFixed(2)} SAR'
            : null,
      );
      createdSaleId = saleResult.saleId;

      // ─── 2. إنشاء المرتجع (إن وُجدت عناصر مرتجعة) ─────────────────────
      if (_returnItems.isNotEmpty) {
        // totalRefund يمثّل قيمة البضاعة المُرتجعة فعلياً (returnTotal)؛ لا
        // نضيف إليه balanceDiff لأن ذلك سيُدخل double-counting محاسبياً:
        // البيع الجديد يحمل قيمته (newTotal)، والمرتجع يحمل قيمته
        // (returnTotal)، والفرق الصافي بين الطرفين هو ما يدخل/يخرج من
        // الصندوق فعلياً (cash refund إن كان balanceDiff<0، cash in إن
        // كان balanceDiff>0). القيد المزدوج يحافظ على صحة السجل.
        final returnItemCompanions = _returnItems.map((ei) {
          // unitPrice في return_items هو int cents. refundAmount يشمل VAT 15%
          // كما في refund_reason_screen.dart:356.
          final unitPriceCents = (ei.price * 100).round();
          final lineRefundCents = (ei.qty * ei.price * 1.15 * 100).round();
          return ReturnItemsTableCompanion(
            productId: Value(ei.productId),
            productName: Value(ei.productName),
            qty: Value(ei.qty.toDouble()),
            unitPrice: Value(unitPriceCents),
            refundAmount: Value(lineRefundCents),
          );
        }).toList();

        await createReturn(
          ref,
          saleId: createdSaleId,
          reason: 'exchange',
          totalRefund: returnTotal,
          refundMethod: 'cash',
          notes:
              'Exchange transaction — offsetting new items '
              '${newTotal.toStringAsFixed(2)} SAR '
              '(diff=${balanceDiff.toStringAsFixed(2)} SAR)',
          createdBy: user?.id,
          items: returnItemCompanions,
        );
      }

      // ─── 3. Audit log ─────────────────────────────────────────────────
      await auditService.logExchange(
        storeId: storeId,
        userId: user?.id ?? 'unknown',
        userName: user?.name ?? 'unknown',
        returnCount: _returnItems.length,
        newCount: _newItems.length,
      );

      addBreadcrumb(
        message: 'Exchange completed',
        category: 'sale',
        data: {
          'saleId': createdSaleId,
          'returnItems': _returnItems.length,
          'newItems': _newItems.length,
          'returnTotal': returnTotal,
          'newTotal': newTotal,
          'balanceDiff': balanceDiff,
        },
      );

      if (!mounted) return;
      // Phase 2 §2.6 — upgrade to heavy haptic + sale success chime for
      // a completed exchange (treated as a sale event by the user).
      HapticShim.heavyImpact();
      SoundService.instance.saleSuccess();

      // رسالة نجاح مفصّلة تُوضح الفرق المالي.
      final diffMsg = balanceDiff > 0
          ? ' (+${balanceDiff.toStringAsFixed(2)} ${l10n.sar} ${l10n.customerPaysExtra})'
          : balanceDiff < 0
          ? ' (${balanceDiff.toStringAsFixed(2)} ${l10n.sar} ${l10n.refundToCustomer})'
          : '';
      AlhaiSnackbar.success(
        context,
        '${l10n.exchangeSuccessMsg}$diffMsg',
      );
      setState(() {
        _returnItems.clear();
        _newItems.clear();
      });
    } catch (e, stack) {
      // ملاحظة على استراتيجية الأخطاء: لا يمكن لفّ createSale + createReturn
      // في transaction واحد لأن كليهما يُدير transactions داخلية مستقلة +
      // يُضيف لسجل sync_queue. لذلك إن فشل createReturn بعد نجاح createSale،
      // سيبقى البيع محفوظاً محلياً (والعميل استلم بضاعة) لكن المرتجع لن
      // يُسجَّل — وهذا يعني أن مخزون المنتجات المرتجعة لن يُعاد. نبلّغ
      // المستخدم بصراحة عبر الحوار ونمرّر الـ saleId المُنشأ إلى Sentry
      // ليتمكن المسؤول من إعادة المحاولة عبر Returns screen يدوياً.
      reportError(
        e,
        stackTrace: stack,
        hint:
            'Submit exchange (partial-state possible; '
            'createdSaleId=$createdSaleId)',
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.errorOccurred),
          content: Text(
            createdSaleId != null
                ? 'Sale was created (id: $createdSaleId) but the return '
                      'step failed. Please process the return manually '
                      'from the Returns screen.\n\nError: $e'
                : l10n.errorWithDetails('$e'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.close),
            ),
          ],
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
  // السعر بـ SAR double (UI math) — التحويل إلى int cents عند حدود DAO/Service.
  final double price;
  final int qty;
  // Reference للسجل الكامل لإعادة بناء `Product` domain model عند إنشاء البيع
  // الجديد عبر SaleService.createSale. بدون هذا سيلزمنا fetch ثانوي داخل
  // الـ submit، مما يُدخل احتمال race (تعديل المنتج بين الإضافة والاستبدال).
  final ProductsTableData product;

  const _ExchangeItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.qty,
    required this.product,
  });

  _ExchangeItem copyWithQty(int newQty) => _ExchangeItem(
    productId: productId,
    productName: productName,
    price: price,
    qty: newQty,
    product: product,
  );
}
