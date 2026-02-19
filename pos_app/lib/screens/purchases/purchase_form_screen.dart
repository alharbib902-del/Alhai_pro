import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../widgets/layout/app_header.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../providers/products_providers.dart';
import '../../providers/purchases_providers.dart';
import '../../providers/suppliers_providers.dart';

/// شاشة إضافة فاتورة شراء
class PurchaseFormScreen extends ConsumerStatefulWidget {
  const PurchaseFormScreen({super.key});

  @override
  ConsumerState<PurchaseFormScreen> createState() => _PurchaseFormScreenState();
}

class _PurchaseFormScreenState extends ConsumerState<PurchaseFormScreen> {

  String? _selectedSupplierId;
  final List<_PurchaseItem> _items = [];
  String _paymentStatus = 'paid';
  final _invoiceNoController = TextEditingController();

  final String _userName = 'المستخدم';
  bool _isSaving = false;

  double get _subtotal => _items.fold(0, (sum, item) => sum + item.total);

  @override
  void dispose() {
    _invoiceNoController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Column(
              children: [
                AppHeader(
                  title: l10n.newPurchaseInvoice,
                  onMenuTap: isWideScreen
                      ? null
                      : () => Scaffold.of(context).openDrawer(),
                  onNotificationsTap: () => context.push('/notifications'),
                  notificationsCount: 3,
                  userName: _userName,
                  userRole: l10n.branchManager,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                    child: _buildContent(
                        isWideScreen, isMediumScreen, isDark, l10n),
                  ),
                ),
              ],
            );
  }
  Widget _buildContent(
      bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Action bar
        Row(
          children: [
            IconButton(
              onPressed: () => context.pop(),
              icon: Icon(Icons.arrow_back_rounded,
                  color: isDark ? Colors.white : AppColors.textPrimary),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.newPurchaseInvoice,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
            FilledButton.icon(
              onPressed: _items.isEmpty || _isSaving ? null : _savePurchase,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(_isSaving ? 'جاري الحفظ...' : 'حفظ'),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Main content - responsive
        if (isWideScreen)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildSupplierCard(isDark),
                    const SizedBox(height: 16),
                    _buildItemsCard(isDark),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _buildPaymentCard(isDark),
                    const SizedBox(height: 16),
                    _buildTotalCard(isDark),
                  ],
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              _buildSupplierCard(isDark),
              const SizedBox(height: 16),
              _buildItemsCard(isDark),
              const SizedBox(height: 16),
              _buildPaymentCard(isDark),
              const SizedBox(height: 16),
              _buildTotalCard(isDark),
            ],
          ),
      ],
    );
  }

  Widget _buildSupplierCard(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    final suppliersAsync = ref.watch(activeSuppliersProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.store_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.supplierData,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          suppliersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('خطأ في تحميل الموردين: $e'),
            data: (suppliers) => DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: l10n.selectSupplierRequired,
                prefixIcon: const Icon(Icons.store),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              initialValue: _selectedSupplierId,
              items: suppliers
                  .map((s) => DropdownMenuItem(
                        value: s.id,
                        child: Text(s.name),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedSupplierId = v),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _invoiceNoController,
            decoration: InputDecoration(
              labelText: l10n.supplierInvoiceNumber,
              prefixIcon: const Icon(Icons.receipt),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.inventory_2_rounded,
                        color: AppColors.info, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '\u0627\u0644\u0645\u0646\u062A\u062C\u0627\u062A', // TODO: localize
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              FilledButton.tonalIcon(
                onPressed: _addProduct,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('\u0625\u0636\u0627\u0641\u0629 \u0645\u0646\u062A\u062C'), // TODO: localize
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : AppColors.border,
          ),
          if (_items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        size: 48,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.3)
                            : AppColors.textTertiary),
                    const SizedBox(height: 12),
                    Text(
                      l10n.noProductsAddedYet,
                      style: TextStyle(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.5)
                              : AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _items.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : AppColors.border,
              ),
              itemBuilder: (context, index) {
                final item = _items[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: 4),
                  title: Text(
                    item.productName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    '${item.qty} \u00D7 ${item.cost.toStringAsFixed(2)} \u0631.\u0633',
                    style: TextStyle(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.6)
                            : AppColors.textSecondary),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${item.total.toStringAsFixed(2)} \u0631.\u0633',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.error),
                        onPressed: () =>
                            setState(() => _items.removeAt(index)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.payment_rounded,
                    color: AppColors.warning, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.paymentStatus,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(
                  value: 'paid',
                  label: Text(AppLocalizations.of(context)!.paidStatus),
                  icon: const Icon(Icons.check_circle)),
              ButtonSegment(
                  value: 'credit',
                  label: Text(AppLocalizations.of(context)!.deferredPayment),
                  icon: const Icon(Icons.schedule)),
            ],
            selected: {_paymentStatus},
            onSelectionChanged: (s) =>
                setState(() => _paymentStatus = s.first),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF065F46), const Color(0xFF064E3B)]
              : [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.primary.withValues(alpha: 0.05)
                ],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.primaryBorder,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '\u0627\u0644\u0625\u062C\u0645\u0627\u0644\u064A', // TODO: localize
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          Text(
            '${_subtotal.toStringAsFixed(2)} \u0631.\u0633',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  void _addProduct() {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        final qtyController = TextEditingController(text: '1');
        final costController = TextEditingController();

        return AlertDialog(
          title: const Text('\u0625\u0636\u0627\u0641\u0629 \u0645\u0646\u062A\u062C'), // TODO: localize
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '\u0627\u0633\u0645 \u0627\u0644\u0645\u0646\u062A\u062C *'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: qtyController,
                      decoration: const InputDecoration(labelText: '\u0627\u0644\u0643\u0645\u064A\u0629'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: costController,
                      decoration: const InputDecoration(labelText: '\u0633\u0639\u0631 \u0627\u0644\u0634\u0631\u0627\u0621'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('\u0625\u0644\u063A\u0627\u0621'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text;
                final qty = int.tryParse(qtyController.text) ?? 1;
                final cost = double.tryParse(costController.text) ?? 0;

                if (name.isNotEmpty && cost > 0) {
                  setState(() {
                    _items.add(_PurchaseItem(
                      productId: 'temp_${_items.length}',
                      productName: name,
                      qty: qty,
                      cost: cost,
                    ));
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('\u0625\u0636\u0627\u0641\u0629'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _savePurchase() async {
    if (_selectedSupplierId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار المورد')),
      );
      return;
    }

    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      // الحصول على اسم المورد المحدد
      final suppliersAsync = ref.read(activeSuppliersProvider);
      final suppliers = suppliersAsync.valueOrNull ?? [];
      final selectedSupplier = suppliers.firstWhere(
        (s) => s.id == _selectedSupplierId,
        orElse: () => suppliers.first,
      );

      const uuid = Uuid();

      // تحويل العناصر لـ PurchaseItemsTableCompanion
      final purchaseItems = _items.map((item) {
        return PurchaseItemsTableCompanion(
          id: Value(uuid.v4()),
          purchaseId: const Value(''), // سيتم ربطه بالمشتريات
          productId: Value(item.productId),
          productName: Value(item.productName),
          qty: Value(item.qty),
          unitCost: Value(item.cost),
          total: Value(item.total),
        );
      }).toList();

      // حفظ المشتريات عبر المزود (يشمل SyncQueue)
      final purchaseId = await createPurchase(
        ref,
        supplierId: _selectedSupplierId!,
        supplierName: selectedSupplier.name,
        subtotal: _subtotal,
        tax: 0, // يمكن إضافة حساب الضريبة لاحقاً
        discount: 0,
        total: _subtotal,
        notes: _invoiceNoController.text.isNotEmpty
            ? 'رقم فاتورة المورد: ${_invoiceNoController.text}'
            : null,
        items: purchaseItems,
      );

      // تحديث المخزون وإنشاء حركات المخزون لكل منتج
      final db = getIt<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);
      for (final item in _items) {
        if (!item.productId.startsWith('temp_')) {
          try {
            final product = await db.productsDao.getProductById(item.productId);
            if (product != null) {
              final previousQty = product.stockQty;
              final newQty = previousQty + item.qty;
              await db.productsDao.updateStock(item.productId, newQty);
              await db.inventoryDao.recordPurchaseMovement(
                id: uuid.v4(),
                productId: item.productId,
                storeId: storeId ?? '',
                qty: item.qty,
                previousQty: previousQty,
                purchaseId: purchaseId,
              );
            }
          } catch (e) {
            debugPrint('خطأ في تحديث المخزون للمنتج ${item.productId}: $e');
          }
        }
      }

      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم حفظ فاتورة الشراء - الإجمالي: ${_subtotal.toStringAsFixed(2)} ر.س',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في حفظ المشتريات: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

class _PurchaseItem {
  final String productId;
  final String productName;
  final int qty;
  final double cost;

  _PurchaseItem({
    required this.productId,
    required this.productName,
    required this.qty,
    required this.cost,
  });

  double get total => qty * cost;
}
