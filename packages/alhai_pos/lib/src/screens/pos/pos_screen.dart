import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_design_system/alhai_design_system.dart' hide ResponsiveBuilder;
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import '../../core/utils/keyboard_shortcuts.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../providers/cart_providers.dart';
import '../../widgets/pos/pos_widgets.dart';
import '../../widgets/pos/barcode_listener.dart';
import '../../widgets/pos/payment_success_dialog.dart';
import '../../providers/held_invoices_providers.dart';
import '../../providers/sale_providers.dart';
import 'hold_invoices_screen.dart';
import '../../widgets/orders/orders_widgets.dart';
import 'pos_cart_panel.dart';
import 'pos_product_shortcuts.dart';
import 'pos_products_panel.dart';

/// شاشة نقطة البيع الرئيسية - التصميم الجديد
///
/// تعرض المنتجات وسلة المشتريات في عرض مقسم مع app shell (sidebar + header)
/// متجاوبة: على الهواتف السلة في BottomSheet

/// Maximum number of recent searches stored in memory.
const int _kMaxRecentSearches = 5;

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
  late String _dateSubtitle;

  /// Bug 2: يمنع التنقل أثناء حفظ البيع
  bool _isProcessingSale = false;

  /// Bug 3: يمنع مسح الباركود أثناء فتح نافذة الدفع
  bool _isPaymentDialogOpen = false;

  /// L34: In-memory recent search terms (max [_kMaxRecentSearches]).
  final List<String> _recentSearches = [];

  /// L35: Whether the keyboard shortcuts overlay is visible.
  bool _showShortcutsOverlay = false;

  @override
  void initState() {
    super.initState();
    // حساب التاريخ مرة واحدة بدلاً من كل build
    final now = DateTime.now();
    final locale = WidgetsBinding.instance.platformDispatcher.locale.toString();
    _dateSubtitle = DateFormat('d MMMM yyyy', locale).format(now);

    Future.microtask(() {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId != null) {
        ref.read(productsStateProvider.notifier)
            .loadProducts(storeId: storeId, refresh: true);
      }
      // التحقق من وجود مسودة سلة محفوظة واستعادتها مع تأكيد
      _checkPendingDraft();

      // إصلاح عناصر البيع المفقودة في طابور المزامنة (مرة واحدة)
      ref.read(saleItemsSyncRepairProvider);

      // تشغيل المزامنة الأولية (تحميل البيانات من Supabase)
      _triggerInitialSync();

      // تفعيل المستمع الفوري (Realtime) لاستقبال التحديثات من Supabase
      ref.read(realtimeActivationProvider);
    });
  }

  /// تشغيل المزامنة الأولية لتحميل البيانات من Supabase
  Future<void> _triggerInitialSync() async {
    try {
      final initialSync = ref.read(initialSyncProvider);
      if (initialSync == null) return;

      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;

      // التحقق هل تمت المزامنة الأولية؟
      final isComplete = await initialSync.isComplete();
      if (isComplete) {
        debugPrint('[POS] Initial sync already complete');
        return;
      }

      debugPrint('[POS] Starting initial sync...');
      final result = await initialSync.execute(
        orgId: '', // سيتم تجاهله للجداول بدون org_id
        storeId: storeId,
      );
      debugPrint('[POS] Initial sync done: ${result.totalRecords} records, errors: ${result.errors}');
    } catch (e) {
      debugPrint('[POS] Initial sync error: $e');
    }
  }

  /// عرض dialog تأكيد لاستعادة سلة محفوظة من جلسة سابقة
  Future<void> _checkPendingDraft() async {
    final cartNotifier = ref.read(cartStateProvider.notifier);
    if (!cartNotifier.hasPendingDraft) return;

    // انتظر الفريم الأول ليكون السياق جاهزاً
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;
    final itemCount = cartNotifier.pendingDraftItemCount;
    final total = cartNotifier.pendingDraftTotal;

    final restore = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;
        final dialogL10n = AppLocalizations.of(ctx)!;
        return AlertDialog(
          icon: Icon(Icons.shopping_cart_outlined,
              color: colorScheme.primary, size: 36),
          title: Text(dialogL10n.cart),
          content: Text(
            '${dialogL10n.nItems(itemCount)} • ${CurrencyFormatter.formatWithContext(context, total)}\n\n'
            '${dialogL10n.restoreAction}?',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(ctx, false),
              icon: const Icon(Icons.delete_outline, size: 18),
              label: Text(dialogL10n.cancel),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(ctx, true),
              icon: const Icon(Icons.restore, size: 18),
              label: Text(dialogL10n.restoreAction),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    if (restore == true) {
      cartNotifier.acceptDraft();
      _showSnackBar(context, '${l10n.cart} — ${l10n.nItems(itemCount)}',
          isSuccess: true);
    } else {
      cartNotifier.discardDraft();
    }
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // L31: Unified SnackBar helper
  // ---------------------------------------------------------------------------

  /// Show a floating [SnackBar] with consistent styling.
  ///
  /// When [isError] is true the background colour is [AppColors.error],
  /// otherwise [AppColors.success] is used when [isSuccess] is true.
  void _showSnackBar(
    BuildContext ctx,
    String message, {
    bool isError = false,
    bool isSuccess = false,
    Duration duration = const Duration(milliseconds: 1200),
  }) {
    final Color? bg = isError
        ? AppColors.error
        : isSuccess
            ? AppColors.success
            : null;

    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: bg,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // L30: AI Invoice fallback helper – uses l10n instead of hardcoded strings
  // ---------------------------------------------------------------------------

  /// Returns a localized fallback label for AI invoice import.
  /// Uses [AppLocalizations] so strings are never hardcoded.
  String _aiInvoiceFallbackLabel(AppLocalizations l10n) {
    // Uses the existing key "aiInvoiceImport" from all ARB files.
    return l10n.aiInvoiceImport;
  }

  // ---------------------------------------------------------------------------
  // L34: Recent searches helpers
  // ---------------------------------------------------------------------------

  /// Record a search term (keeps the list at [_kMaxRecentSearches]).
  void _addRecentSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    setState(() {
      _recentSearches.remove(trimmed);
      _recentSearches.insert(0, trimmed);
      if (_recentSearches.length > _kMaxRecentSearches) {
        _recentSearches.removeLast();
      }
    });
  }

  /// A read-only view of the current recent searches.
  List<String> get recentSearches => List.unmodifiable(_recentSearches);

  // ---------------------------------------------------------------------------
  // L35: Keyboard shortcuts overlay toggle
  // ---------------------------------------------------------------------------

  void _toggleShortcutsOverlay() {
    setState(() => _showShortcutsOverlay = !_showShortcutsOverlay);
  }

  // ---------------------------------------------------------------------------
  // Quick add product with haptic feedback & unified snack bar (L30 + L31)
  // ---------------------------------------------------------------------------

  void _addQuickProduct(int number) {
    final products = ref.read(productsStateProvider).products;
    if (number <= products.length) {
      final product = products[number - 1];
      ref.read(cartStateProvider.notifier).addProduct(product);
      HapticFeedback.lightImpact();
      final l10n = AppLocalizations.of(context)!;
      _showSnackBar(context, '${l10n.addedToCart}: ${product.name}');
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
          final colorScheme = Theme.of(context).colorScheme;
          return Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
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
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Cart content
                Expanded(child: PosCartPanel(
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
    setState(() => _isPaymentDialogOpen = true);
    final isWide = context.isDesktop;

    if (isWide) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => PopScope(
          canPop: !_isProcessingSale,
          child: Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: InlinePayment(
                total: total,
                storeId: ref.read(currentStoreIdProvider) ?? '',
                onCancel: () {
                  if (!_isProcessingSale) {
                    Navigator.pop(ctx);
                  }
                },
                onComplete: (result) async {
                  // Bug 2: حفظ البيع أولاً ثم إغلاق النافذة
                  await _handlePaymentComplete(result);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
            ),
          ),
        ),
      ).then((_) {
        if (mounted) setState(() => _isPaymentDialogOpen = false);
      });
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          final colorScheme = Theme.of(ctx).colorScheme;
          return PopScope(
            canPop: !_isProcessingSale,
            child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
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
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                InlinePayment(
                  total: total,
                  storeId: ref.read(currentStoreIdProvider) ?? '',
                  onCancel: () {
                    if (!_isProcessingSale) {
                      Navigator.pop(ctx);
                    }
                  },
                  onComplete: (result) async {
                    // Bug 2: حفظ البيع أولاً ثم إغلاق النافذة
                    await _handlePaymentComplete(result);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
          );
        },
      ).then((_) {
        if (mounted) setState(() => _isPaymentDialogOpen = false);
      });
    }
  }

  Future<void> _handlePaymentComplete(PaymentResult result) async {
    setState(() => _isProcessingSale = true);

    try {
      final cartState = ref.read(cartStateProvider);

      // 1. حفظ البيع في قاعدة البيانات
      String? saleId;
      String receiptNumber = 'ORD-${_orderCounter.toString().padLeft(4, '0')}';
      try {
        final saleService = ref.read(saleServiceProvider);
        final storeId = ref.read(currentStoreIdProvider);
        if (storeId == null) {
          throw StateError('No store selected — cannot create sale');
        }
        // حساب المبلغ المستلم فعلياً (cash + card بدون credit)
        double? amountReceived;
        double? changeAmount;
        double? cashAmount;
        double? cardAmount;
        double? creditAmount;
        final saleTotal = result.amountPaid - result.change;

        if (result.method == PaymentMethod.cash) {
          amountReceived = result.amountPaid;
          changeAmount = result.change;
          cashAmount = saleTotal;
        } else if (result.method == PaymentMethod.card) {
          cardAmount = saleTotal;
        } else if (result.method == PaymentMethod.credit) {
          creditAmount = saleTotal;
        } else if (result.method == PaymentMethod.mixed && result.splits != null) {
          // مجموع الدفعات المستلمة فعلاً (نقد + بطاقة) بدون الآجل
          amountReceived = result.splits!
              .where((s) => s.method != PaymentMethod.credit)
              .fold<double>(0.0, (sum, s) => sum + s.amount);
          // تفصيل كل طريقة دفع
          cashAmount = result.splits!
              .where((s) => s.method == PaymentMethod.cash)
              .fold<double>(0.0, (sum, s) => sum + s.amount);
          cardAmount = result.splits!
              .where((s) => s.method == PaymentMethod.card)
              .fold<double>(0.0, (sum, s) => sum + s.amount);
          creditAmount = result.splits!
              .where((s) => s.method == PaymentMethod.credit)
              .fold<double>(0.0, (sum, s) => sum + s.amount);
          // تنظيف: null إذا صفر
          if (cashAmount == 0) cashAmount = null;
          if (cardAmount == 0) cardAmount = null;
          if (creditAmount == 0) creditAmount = null;
        }

        final saleResult = await saleService.createSale(
          storeId: storeId,
          cashierId: ref.read(currentUserProvider)?.id ?? '',
          items: cartState.items,
          subtotal: cartState.subtotal,
          discount: cartState.discount,
          tax: cartState.subtotal * 0.15,
          total: saleTotal,
          paymentMethod: result.method.name,
          customerId: result.customerId,
          customerName: result.customerName,
          customerPhone: result.customerPhone,
          amountReceived: amountReceived,
          changeAmount: changeAmount,
          cashAmount: cashAmount,
          cardAmount: cardAmount,
          creditAmount: creditAmount,
        );
        saleId = saleResult.saleId;

        if (saleResult.hadPriceCorrections) {
          for (final correction in saleResult.priceCorrections) {
            debugPrint('[POS] Price corrected at sale time: $correction');
          }
        }

        // جلب رقم الإيصال الحقيقي من قاعدة البيانات
        final db = ref.read(appDatabaseProvider);
        final sale = await db.salesDao.getSaleById(saleId);
        if (sale != null) {
          receiptNumber = sale.receiptNo;
        }
      } catch (e) {
        // Bug 1: عرض خطأ للمستخدم وعدم مسح السلة
        debugPrint('Save sale error: $e');
        if (!mounted) return;
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            icon: const Icon(Icons.error_outline, color: AppColors.error, size: 40),
            title: const Text('فشل حفظ البيع'),
            content: Text(
              'حدث خطأ أثناء حفظ عملية البيع. السلة لم تُمسح.\n\n$e',
              textDirection: TextDirection.rtl,
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('حسناً'),
              ),
            ],
          ),
        );
        return; // لا نمسح السلة ولا نعرض نافذة النجاح
      }

      // 2. طباعة تلقائية بعد الدفع (ESC/POS)
      if (saleId != null) {
        final autoPrint = ref.read(autoPrintEnabledProvider);
        final autoPrintCallback = ref.read(autoPrintCallbackProvider);
        if (autoPrint && autoPrintCallback != null) {
          try {
            await autoPrintCallback(saleId);
          } catch (e) {
            debugPrint('Auto-print error: $e');
          }
        }
      }

      // 3. مسح السلة (فقط عند نجاح الحفظ)
      ref.read(cartStateProvider.notifier).clear();
      setState(() => _orderCounter++);

      if (!mounted) return;

      // 4. عرض dialog النجاح مع saleId (الطباعة تتم داخل Dialog)
      await PaymentSuccessDialog.show(
        context: context,
        receiptNumber: receiptNumber,
        amount: result.amountPaid,
        paymentMethodLabel: result.method.localizedLabel(AppLocalizations.of(context)!),
        customerPhone: result.customerPhone,
        customerName: result.customerName,
        saleId: saleId,
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessingSale = false);
      }
    }
  }

  Future<void> _handleBarcodeScan(String barcode) async {
    // Bug 3: تجاهل مسح الباركود أثناء فتح نافذة الدفع
    if (_isPaymentDialogOpen) return;

    final repository = ref.read(productsRepositoryProvider);
    final product = await repository.getByBarcode(barcode);
    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;
    if (product != null) {
      ref.read(cartStateProvider.notifier).addProduct(product);
      HapticFeedback.lightImpact();
      _showSnackBar(context, '${l10n.addedToCart}: ${product.name}', isSuccess: true);
    } else {
      _showSnackBar(
        context,
        '${l10n.productNotFound}: $barcode',
        isError: true,
        duration: const Duration(seconds: 2),
      );
    }
  }

  String _getDateSubtitle(AppLocalizations l10n) {
    return '$_dateSubtitle • ${l10n.mainBranch}';
  }

  // L57: AutomaticKeepAliveClientMixin is not applicable here because PosScreen
  // itself is not inside a TabBarView or PageView. The mixin should be applied
  // to individual tab children. PosScreen persists via GoRouter's stateful
  // shell route, so keep-alive is already handled at the router level.

  @override
  Widget build(BuildContext context) {
    // M93: Use .select() to only rebuild when itemCount changes,
    // not on every cart state mutation (e.g. discount, notes, customer)
    final cartItemCount = ref.watch(
      cartStateProvider.select((state) => state.itemCount),
    );
    final isWideScreen = context.isDesktop;
    final l10n = AppLocalizations.of(context)!;

    // L35: Extended keyboard shortcuts via CallbackShortcuts
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        // F1 = toggle keyboard shortcuts help overlay
        const SingleActivator(LogicalKeyboardKey.f1): _toggleShortcutsOverlay,
        // F2 = focus search field
        const SingleActivator(LogicalKeyboardKey.f2): () => _searchFocusNode.requestFocus(),
        // F5 = refresh products list
        const SingleActivator(LogicalKeyboardKey.f5): () {
          final storeId = ref.read(currentStoreIdProvider);
          if (storeId != null) {
            ref.read(productsStateProvider.notifier)
                .loadProducts(storeId: storeId, refresh: true);
            _showSnackBar(context, l10n.refresh, isSuccess: true);
          }
        },
        // Escape = close overlay first, otherwise navigate home
        const SingleActivator(LogicalKeyboardKey.escape): () {
          if (_showShortcutsOverlay) {
            setState(() => _showShortcutsOverlay = false);
          } else {
            context.go(AppRoutes.home);
          }
        },
      },
      child: Focus(
        autofocus: true,
        child: BarcodeListener(
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
        _showSnackBar(context, l10n.undoComingSoon);
      },
      onCancel: () => context.go(AppRoutes.home),
      onQuickAdd: _addQuickProduct,
      onQuantityChange: (increase) {},
      child: Scaffold(
        // Mobile FAB
        floatingActionButton: context.isMobile
            ? PosFab(
                itemCount: cartItemCount,
                onTap: _showCartBottomSheet,
              )
            : null,
        body: SafeArea(
          child: CashierModeWrapper(
          child: Stack(
            children: [
            Column(
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

              // Offline + Sync pending banners
              const StatusBanners(),

              // Orders panel + main content
              Expanded(
                child: Row(
                  children: [
                    if (_showOrdersPanel)
                      OrdersPanel(
                        onClose: () =>
                            setState(() => _showOrdersPanel = false),
                      ),

                    // Main POS content (L56: RepaintBoundary isolates repaints)
                    Expanded(
                      child: ResponsiveBuilder(
                        builder: (context, deviceType, screenWidth) {
                          if (deviceType.isMobile) {
                            // L56: RepaintBoundary isolates product grid
                            // scroll repaints from header/FAB
                            return RepaintBoundary(
                              child: PosProductsPanel(
                                selectedCategoryId: _selectedCategoryId,
                                onCategorySelected: _onCategorySelected,
                                columns: 3,
                                showShortcutsBar: false,
                                onHoldInvoice: _holdCurrentInvoice,
                                onShowHeldInvoices: _showHeldInvoices,
                              ),
                            );
                          }

                          final isTablet = deviceType.isTablet;
                          // In landscape, give more space to products (70/30)
                          final isLandscape = MediaQuery.orientationOf(context) == Orientation.landscape;
                          // Tablet: 55/45 split to give cart enough room; Desktop: 70/30 or 65/35
                          final productsFlex = isTablet
                              ? (isLandscape ? 60 : 55)
                              : (isLandscape ? 70 : 65);
                          final cartFlex = isTablet
                              ? (isLandscape ? 40 : 45)
                              : (isLandscape ? 30 : 35);

                          return Row(
                            children: [
                              // L56: RepaintBoundary on product grid
                              Expanded(
                                flex: productsFlex,
                                child: RepaintBoundary(
                                  child: PosProductsPanel(
                                    selectedCategoryId:
                                        _selectedCategoryId,
                                    onCategorySelected:
                                        _onCategorySelected,
                                    // Tablet: 3 columns + horizontal category bar (no sidebar)
                                    // Desktop: 4 columns + vertical category sidebar
                                    columns: isTablet ? 3 : 4,
                                    showShortcutsBar: !isTablet,
                                    onHoldInvoice: _holdCurrentInvoice,
                                    onShowHeldInvoices: _showHeldInvoices,
                                  ),
                                ),
                              ),
                              // L56: RepaintBoundary on cart panel
                              Expanded(
                                flex: cartFlex,
                                child: RepaintBoundary(
                                  child: PosCartPanel(
                                    orderNumber:
                                        'ORD-${DateTime.now().year}-${_orderCounter.toString().padLeft(3, '0')}',
                                    onPayTap: _showPaymentDialog,
                                    onHoldInvoice: _holdCurrentInvoice,
                                    onShowHeldInvoices: _showHeldInvoices,
                                  ),
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

            // L35: Keyboard shortcuts overlay
            if (_showShortcutsOverlay)
              _PosShortcutsOverlay(onClose: _toggleShortcutsOverlay),
          ],
        ),
        ),
      ),
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
                '${dialogL10n.nItems(cartState.itemCount)} • ${CurrencyFormatter.formatWithContext(context, cartState.total)}',
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
                foregroundColor: Theme.of(ctx).colorScheme.onPrimary,
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
    _showSnackBar(context, l10n.invoiceSuspended, isSuccess: true);
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
// L35: Keyboard Shortcuts Overlay
// =============================================================================

/// Semi-transparent overlay showing available keyboard shortcuts.
class _PosShortcutsOverlay extends StatelessWidget {
  final VoidCallback onClose;

  const _PosShortcutsOverlay({required this.onClose});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    final shortcuts = <_ShortcutEntry>[
      _ShortcutEntry('F1', l10n.help),
      _ShortcutEntry('F2', l10n.search),
      _ShortcutEntry('F5', l10n.refresh),
      _ShortcutEntry('Esc', l10n.cancel),
      _ShortcutEntry('Enter', l10n.confirm),
      _ShortcutEntry('1-9', l10n.addedToCart),
      _ShortcutEntry('+/-', l10n.keyboardShortcuts),
      _ShortcutEntry('Ctrl+Z', l10n.undoComingSoon),
    ];

    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Material(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            elevation: 8,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.keyboardShortcuts,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: onClose,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...shortcuts.map((s) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 72,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: colorScheme.outline.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              s.key,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              s.label,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    )),
                    const SizedBox(height: 12),
                    Text(
                      'F1 ${l10n.help}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShortcutEntry {
  final String key;
  final String label;
  const _ShortcutEntry(this.key, this.label);
}
