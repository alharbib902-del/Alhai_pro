import 'package:pos_app/widgets/common/adaptive_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../providers/products_providers.dart';

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
  ConsumerState<RefundRequestScreen> createState() => _RefundRequestScreenState();
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
        title: const Text('طلب إرجاع'),
      ),
      body: Column(
        children: [
          // Search order
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _orderIdController,
                    decoration: InputDecoration(
                      hintText: 'رقم الفاتورة',
                      prefixIcon: const Icon(Icons.receipt),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _isSearching ? null : _searchOrder,
                  icon: _isSearching
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.search),
                  label: const Text('بحث'),
                ),
              ],
            ),
          ),

          if (_saleData != null) ...[
            // Order info
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('\u0641\u0627\u062a\u0648\u0631\u0629: ${_saleData!.receiptNo}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('${_saleData!.createdAt.toString().split('.').first} - ${_saleData!.total.toStringAsFixed(2)} \u0631.\u0633'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Select items header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('\u0627\u062e\u062a\u0631 \u0627\u0644\u0645\u0646\u062a\u062c\u0627\u062a \u0644\u0644\u0625\u0631\u062c\u0627\u0639', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: _selectAll,
                    child: const Text('\u062a\u062d\u062f\u064a\u062f \u0627\u0644\u0643\u0644'),
                  ),
                ],
              ),
            ),

            // Items list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _saleItems.length,
                itemBuilder: (context, index) {
                  final item = _saleItems[index];
                  final isSelected = _selectedItems.any((e) => e.id == item.id);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: CheckboxListTile(
                      value: isSelected,
                      onChanged: (v) => _toggleItem(item, v ?? false),
                      title: Text(item.productName),
                      subtitle: Text('\u0627\u0644\u0643\u0645\u064a\u0629: ${item.qty} \u00d7 ${item.unitPrice.toStringAsFixed(2)} \u0631.\u0633'),
                      secondary: CircleAvatar(
                        backgroundColor: isSelected ? Colors.green.shade100 : Colors.grey.shade200,
                        child: Icon(
                          isSelected ? Icons.check : Icons.inventory_2,
                          color: isSelected ? Colors.green : Colors.grey,
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${_selectedItems.length} \u0645\u0646\u062a\u062c \u0645\u062d\u062f\u062f'),
                          Text(
                            '\u0627\u0644\u0645\u0628\u0644\u063a: ${_calculateRefundAmount().toStringAsFixed(0)} \u0631.\u0633',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: _proceedToReason,
                      icon: const AdaptiveIcon(Icons.arrow_forward),
                      label: const Text('\u0627\u0644\u062a\u0627\u0644\u064a'),
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
                    Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text('أدخل رقم الفاتورة للبحث', style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _searchOrder() async {
    if (_orderIdController.text.isEmpty) return;

    setState(() => _isSearching = true);

    try {
      final db = getIt<AppDatabase>();
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
            const SnackBar(content: Text('\u0644\u0645 \u064a\u062a\u0645 \u0627\u0644\u0639\u062b\u0648\u0631 \u0639\u0644\u0649 \u0627\u0644\u0641\u0627\u062a\u0648\u0631\u0629')),
          );
        }
        return;
      }

      final items = await db.saleItemsDao.getItemsBySaleId(sale.id);

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
          SnackBar(content: Text(e.toString())),
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
    return _selectedItems.fold(0.0, (sum, item) => sum + item.qty * item.unitPrice);
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
