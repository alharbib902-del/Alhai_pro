import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import '../../providers/purchases_providers.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import '../../core/providers/unsaved_changes_provider.dart';

/// Purchase Form Screen - شاشة إضافة فاتورة شراء
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
  bool _isSaving = false;
  bool _isDirty = false;

  double get _subtotal => _items.fold(0, (sum, item) => sum + item.total);

  void _setDirty(bool value) {
    if (_isDirty != value) {
      setState(() => _isDirty = value);
      ref.read(unsavedChangesProvider.notifier).state = value;
    }
  }

  @override
  void dispose() {
    ref.read(unsavedChangesProvider.notifier).state = false;
    _invoiceNoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final isWideScreen = AlhaiBreakpoints.isDesktop(size.width) ||
        (isLandscape && size.width >= 600);
    final isMediumScreen = size.width >= AlhaiBreakpoints.tablet;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS):
            const _SaveIntent(),
        LogicalKeySet(LogicalKeyboardKey.escape): const _DismissFormIntent(),
      },
      child: Actions(
        actions: {
          _SaveIntent: CallbackAction<_SaveIntent>(
            onInvoke: (_) {
              if (_items.isNotEmpty && !_isSaving) _savePurchase();
              return null;
            },
          ),
          _DismissFormIntent: CallbackAction<_DismissFormIntent>(
            onInvoke: (_) {
              if (mounted) context.pop();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: Column(
            children: [
              AppHeader(
                title: l10n.newPurchaseInvoice,
                onMenuTap: isWideScreen
                    ? null
                    : () => Scaffold.of(context).openDrawer(),
                onNotificationsTap: () => context.push('/notifications'),
                notificationsCount: 3,
                userName: l10n.cashCustomer,
                userRole: l10n.branchManager,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.assignment_return_rounded),
                    tooltip: l10n.returns,
                    onPressed: () => context.push(AppRoutes.supplierReturns),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                  child:
                      _buildContent(isWideScreen, isMediumScreen, isDark, l10n),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(bool isWideScreen, bool isMediumScreen, bool isDark,
      AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => context.pop(),
              icon: Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.arrow_forward_rounded
                    : Icons.arrow_back_rounded,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              tooltip: l10n.back,
            ),
            const SizedBox(width: AlhaiSpacing.xs),
            Expanded(
              child: Text(
                l10n.newPurchaseInvoice,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
            FilledButton.icon(
              onPressed: _items.isEmpty || _isSaving ? null : _savePurchase,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.textOnPrimary))
                  : const Icon(Icons.save),
              label: Text(_isSaving ? l10n.savingLabel : l10n.saveLabel),
            ),
          ],
        ),
        const SizedBox(height: AlhaiSpacing.lg),
        if (isWideScreen)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  flex: 2,
                  child: Column(children: [
                    _buildSupplierCard(isDark),
                    const SizedBox(height: AlhaiSpacing.md),
                    _buildItemsCard(isDark)
                  ])),
              const SizedBox(width: AlhaiSpacing.lg),
              Expanded(
                  flex: 1,
                  child: Column(children: [
                    _buildPaymentCard(isDark),
                    const SizedBox(height: AlhaiSpacing.md),
                    _buildTotalCard(isDark)
                  ])),
            ],
          )
        else
          Column(children: [
            _buildSupplierCard(isDark),
            const SizedBox(height: AlhaiSpacing.md),
            _buildItemsCard(isDark),
            const SizedBox(height: AlhaiSpacing.md),
            _buildPaymentCard(isDark),
            const SizedBox(height: AlhaiSpacing.md),
            _buildTotalCard(isDark),
          ]),
      ],
    );
  }

  Widget _buildSupplierCard(bool isDark) {
    final l10n = AppLocalizations.of(context);
    final suppliersAsync = ref.watch(activeSuppliersProvider);

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(AlhaiSpacing.xs),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.store_rounded,
                  color: Theme.of(context).colorScheme.primary, size: 20),
            ),
            const SizedBox(width: AlhaiSpacing.sm),
            Text(l10n.supplierData,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface)),
          ]),
          const SizedBox(height: AlhaiSpacing.md),
          suppliersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text(l10n.errorLoadingSuppliers(e)),
            data: (suppliers) => DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: l10n.selectSupplierRequired,
                prefixIcon: const Icon(Icons.store),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              value: _selectedSupplierId,
              items: suppliers
                  .map(
                      (s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedSupplierId = v),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          TextField(
            controller: _invoiceNoController,
            decoration: InputDecoration(
              labelText: l10n.supplierInvoiceNumber,
              prefixIcon: const Icon(Icons.receipt),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard(bool isDark) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(AlhaiSpacing.xs),
                  decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.inventory_2_rounded,
                      color: AppColors.info, size: 20),
                ),
                const SizedBox(width: AlhaiSpacing.sm),
                Text(l10n.productsLabel,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface)),
              ]),
              FilledButton.tonalIcon(
                  onPressed: _addProduct,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l10n.addProduct)),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          Divider(color: Theme.of(context).dividerColor),
          if (_items.isEmpty)
            AppEmptyState.noProducts(context, onAdd: _addProduct)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _items.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: Theme.of(context).dividerColor),
              itemBuilder: (context, index) {
                final item = _items[index];
                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  title: Text(item.productName,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface)),
                  subtitle: Text(
                    '${item.qty} \u00D7 ${item.cost.toStringAsFixed(2)} \u0631.\u0633',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${item.total.toStringAsFixed(2)} \u0631.\u0633',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface)),
                      IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: AppColors.error),
                          onPressed: () =>
                              setState(() => _items.removeAt(index)),
                          tooltip: l10n.delete),
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
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(AlhaiSpacing.xs),
              decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.payment_rounded,
                  color: AppColors.warning, size: 20),
            ),
            const SizedBox(width: AlhaiSpacing.sm),
            Text(l10n.paymentStatus,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface)),
          ]),
          const SizedBox(height: AlhaiSpacing.md),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(
                  value: 'paid',
                  label: Text(l10n.paidStatus),
                  icon: const Icon(Icons.check_circle)),
              ButtonSegment(
                  value: 'credit',
                  label: Text(l10n.deferredPayment),
                  icon: const Icon(Icons.schedule)),
            ],
            selected: {_paymentStatus},
            onSelectionChanged: (s) => setState(() => _paymentStatus = s.first),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard(bool isDark) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        gradient: isDark
            ? AppColors.primaryGradientDark
            : LinearGradient(
                colors: [
                  AppColors.primarySurface,
                  AppColors.primarySurface.withValues(alpha: 0.5)
                ],
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
              ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.primaryBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l10n.totalLabel,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface)),
          Text(
            '${_subtotal.toStringAsFixed(2)} \u0631.\u0633',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.primaryLight : AppColors.primaryDark),
          ),
        ],
      ),
    );
  }

  void _addProduct() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        final qtyController = TextEditingController(text: '1');
        final costController = TextEditingController();

        return AlertDialog(
          title: Text(l10n.addProduct),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameController,
                  decoration:
                      InputDecoration(labelText: l10n.productNameLabel)),
              const SizedBox(height: AlhaiSpacing.sm),
              Row(children: [
                Expanded(
                    child: TextField(
                        controller: qtyController,
                        decoration:
                            InputDecoration(labelText: l10n.quantityLabel),
                        keyboardType: TextInputType.number)),
                const SizedBox(width: AlhaiSpacing.sm),
                Expanded(
                    child: TextField(
                        controller: costController,
                        decoration:
                            InputDecoration(labelText: l10n.purchasePriceLabel),
                        keyboardType: TextInputType.number)),
              ]),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancelLabel)),
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
                        cost: cost));
                  });
                  _setDirty(true);
                }
                Navigator.pop(context);
              },
              child: Text(l10n.addLabel),
            ),
          ],
        );
      },
    );
  }

  Future<void> _savePurchase() async {
    final l10n = AppLocalizations.of(context);
    if (_selectedSupplierId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.selectSupplierRequired)));
      return;
    }

    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final suppliersAsync = ref.read(activeSuppliersProvider);
      final suppliers = suppliersAsync.valueOrNull ?? [];
      final selectedSupplier = suppliers.firstWhere(
          (s) => s.id == _selectedSupplierId,
          orElse: () => suppliers.first);

      const uuid = Uuid();

      final purchaseItems = _items.map((item) {
        return PurchaseItemsTableCompanion(
          id: Value(uuid.v4()),
          purchaseId: const Value(''),
          productId: Value(item.productId),
          productName: Value(item.productName),
          qty: Value(item.qty.toDouble()),
          unitCost: Value(item.cost),
          total: Value(item.total),
        );
      }).toList();

      final purchaseId = await createPurchase(
        ref,
        supplierId: _selectedSupplierId!,
        supplierName: selectedSupplier.name,
        subtotal: _subtotal,
        tax: 0,
        discount: 0,
        total: _subtotal,
        notes: _invoiceNoController.text.isNotEmpty
            ? '\u0631\u0642\u0645 \u0641\u0627\u062A\u0648\u0631\u0629 \u0627\u0644\u0645\u0648\u0631\u062F: ${_invoiceNoController.text}'
            : null,
        items: purchaseItems,
      );

      // Update inventory for non-temporary products
      final db = GetIt.I<AppDatabase>();
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
                qty: item.qty.toDouble(),
                previousQty: previousQty.toDouble(),
                purchaseId: purchaseId,
              );
            }
          } catch (e) {
            debugPrint('Error updating stock for ${item.productId}: $e');
          }
        }
      }

      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(l10n.purchaseInvoiceSaved(_subtotal.toStringAsFixed(2))),
              backgroundColor: AppColors.success),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(l10n.errorSavingPurchase(e)),
              backgroundColor: AppColors.error),
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

  _PurchaseItem(
      {required this.productId,
      required this.productName,
      required this.qty,
      required this.cost});

  double get total => qty * cost;
}

class _SaveIntent extends Intent {
  const _SaveIntent();
}

class _DismissFormIntent extends Intent {
  const _DismissFormIntent();
}
