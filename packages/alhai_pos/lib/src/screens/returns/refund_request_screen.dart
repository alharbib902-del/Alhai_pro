import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

// ============================================================================
// PENDING REFUND DATA - holds data between request and reason screens
// ============================================================================

/// بيانات طلب الإرجاع المعلق (تُمرر بين الشاشات عبر Riverpod)
class PendingRefundData {
  final String saleId;
  final String receiptNo;
  final List<SaleItemsTableData> items;
  final double amount;

  const PendingRefundData({
    required this.saleId,
    required this.receiptNo,
    required this.items,
    required this.amount,
  });
}

/// مزود بيانات الإرجاع المعلق
final pendingRefundProvider = StateProvider<PendingRefundData?>((ref) => null);

/// شاشة طلب إرجاع منتج
class RefundRequestScreen extends ConsumerStatefulWidget {
  final String? orderId;
  const RefundRequestScreen({super.key, this.orderId});

  @override
  ConsumerState<RefundRequestScreen> createState() =>
      _RefundRequestScreenState();
}

class _RefundRequestScreenState extends ConsumerState<RefundRequestScreen> {
  final _orderIdController = TextEditingController();
  bool _isSearching = false;
  SalesTableData? _saleData;
  List<SaleItemsTableData> _saleItems = [];

  final List<SaleItemsTableData> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    if (widget.orderId != null) {
      _orderIdController.text = widget.orderId!;
      _searchOrder();
    }
  }

  @override
  void dispose() {
    _orderIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).refundRequestTitle),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Search order
            Padding(
              padding: const EdgeInsets.all(AlhaiSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _orderIdController,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(
                          context,
                        ).invoiceNumberHint,
                        prefixIcon: const Icon(Icons.receipt),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AlhaiSpacing.sm),
                  FilledButton.icon(
                    onPressed: _isSearching ? null : _searchOrder,
                    icon: _isSearching
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.surface,
                            ),
                          )
                        : const Icon(Icons.search),
                    label: Text(AppLocalizations.of(context).searchAction),
                  ),
                ],
              ),
            ),

            if (_saleData != null) ...[
              // Order info
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md),
                padding: const EdgeInsets.all(AlhaiSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.info),
                    const SizedBox(width: AlhaiSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(
                              context,
                            ).invoiceFieldLabel(_saleData!.receiptNo),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${_saleData!.createdAt.toString().split('.').first} - ${_saleData!.total.toStringAsFixed(2)} ${AppLocalizations.of(context).sar}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AlhaiSpacing.md),

              // Select items header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AlhaiSpacing.md,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context).selectProductsForRefund,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: _selectAll,
                      child: Text(AppLocalizations.of(context).selectAll),
                    ),
                  ],
                ),
              ),

              // Items list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AlhaiSpacing.md),
                  itemCount: _saleItems.length,
                  itemBuilder: (context, index) {
                    final item = _saleItems[index];
                    final isSelected = _selectedItems.any(
                      (e) => e.id == item.id,
                    );

                    return Card(
                      margin: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
                      child: CheckboxListTile(
                        value: isSelected,
                        onChanged: (v) => _toggleItem(item, v ?? false),
                        title: Text(item.productName),
                        subtitle: Text(
                          AppLocalizations.of(context).quantityTimesPrice(
                            item.qty.toInt(),
                            // C-4 Session 2: sale_items.unitPrice is int cents.
                            (item.unitPrice / 100.0).toStringAsFixed(2),
                          ),
                        ),
                        secondary: CircleAvatar(
                          backgroundColor: isSelected
                              ? AppColors.success.withValues(alpha: 0.15)
                              : Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                          child: Icon(
                            isSelected ? Icons.check : Icons.inventory_2,
                            color: isSelected
                                ? AppColors.success
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bottom action
              if (_selectedItems.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(AlhaiSpacing.md),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(
                                context,
                              ).productsSelected(_selectedItems.length),
                            ),
                            Text(
                              AppLocalizations.of(context).refundAmountValue(
                                _calculateRefundAmount().toStringAsFixed(0),
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: _proceedToReason,
                        icon: const AdaptiveIcon(Icons.arrow_forward),
                        label: Text(AppLocalizations.of(context).nextAction),
                      ),
                    ],
                  ),
                ),
            ] else if (!_isSearching) ...[
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 64,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: AlhaiSpacing.md),
                      Text(
                        AppLocalizations.of(context).enterInvoiceToSearch,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _searchOrder() async {
    if (_orderIdController.text.isEmpty) return;

    setState(() => _isSearching = true);

    try {
      final db = GetIt.I<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) {
        if (mounted) setState(() => _isSearching = false);
        return;
      }

      final sale = await db.salesDao.getSaleByReceiptNo(
        _orderIdController.text.trim(),
        storeId,
      );

      if (sale == null) {
        if (mounted) {
          setState(() {
            _isSearching = false;
            _saleData = null;
            _saleItems = [];
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).invoiceNotFoundMsg),
            ),
          );
        }
        return;
      }

      // Block refund on voided sales -- a voided sale already reversed money
      if (sale.status == 'voided') {
        if (mounted) {
          setState(() {
            _isSearching = false;
            _saleData = null;
            _saleItems = [];
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).invoiceVoidedCannotRefund,
              ),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      final items = await db.saleItemsDao.getItemsBySaleId(sale.id);

      // BUG FIX: Check for existing returns to prevent double refunds
      final existingReturns = await db.returnsDao.getReturnsBySaleId(
        sale.id,
        storeId,
      );

      if (existingReturns.isNotEmpty) {
        // Gather all previously refunded item quantities
        final refundedQtyByProduct = <String, double>{};
        for (final ret in existingReturns) {
          final returnItems = await db.returnsDao.getReturnItems(ret.id);
          for (final ri in returnItems) {
            refundedQtyByProduct[ri.productId] =
                (refundedQtyByProduct[ri.productId] ?? 0) + ri.qty;
          }
        }

        // Filter out fully refunded items and adjust qty to show remaining only
        final remainingItems = <SaleItemsTableData>[];
        for (final item in items) {
          final refundedQty = refundedQtyByProduct[item.productId] ?? 0;
          if (item.qty > refundedQty) {
            // Show only the remaining refundable quantity, not the original
            remainingItems.add(item.copyWith(qty: item.qty - refundedQty));
          }
        }

        if (remainingItems.isEmpty) {
          // All items already refunded
          if (mounted) {
            setState(() {
              _isSearching = false;
              _saleData = null;
              _saleItems = [];
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context).invoiceAlreadyRefunded,
                ),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 4),
              ),
            );
          }
          return;
        }

        // Some items still available for refund - show warning and continue
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).invoicePartiallyRefunded,
              ),
              backgroundColor: AppColors.warning,
              duration: const Duration(seconds: 3),
            ),
          );
          setState(() {
            _isSearching = false;
            _saleData = sale;
            _saleItems = remainingItems;
            _selectedItems.clear();
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _isSearching = false;
          _saleData = sale;
          _saleItems = items;
          _selectedItems.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).errorOccurred)),
        );
      }
    }
  }

  void _toggleItem(SaleItemsTableData item, bool selected) {
    setState(() {
      if (selected) {
        _selectedItems.add(item);
      } else {
        _selectedItems.removeWhere((e) => e.id == item.id);
      }
    });
  }

  void _selectAll() {
    setState(() {
      _selectedItems.clear();
      _selectedItems.addAll(_saleItems);
    });
  }

  double _calculateRefundAmount() {
    // Include 15% Saudi VAT — customer paid unitPrice * 1.15, so refund must match
    return _selectedItems.fold(
      0.0,
      (sum, item) => sum + item.qty * item.unitPrice * 1.15,
    );
  }

  void _proceedToReason() {
    // Store refund data in provider for the reason screen to consume
    ref.read(pendingRefundProvider.notifier).state = PendingRefundData(
      saleId: _saleData!.id,
      receiptNo: _saleData!.receiptNo,
      items: List.unmodifiable(_selectedItems),
      amount: _calculateRefundAmount(),
    );
    context.push('/returns/reason');
  }
}
