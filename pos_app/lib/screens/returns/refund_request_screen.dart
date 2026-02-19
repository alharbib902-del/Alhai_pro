import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// شاشة طلب إرجاع منتج
class RefundRequestScreen extends StatefulWidget {
  final String? orderId;
  const RefundRequestScreen({super.key, this.orderId});

  @override
  State<RefundRequestScreen> createState() => _RefundRequestScreenState();
}

class _RefundRequestScreenState extends State<RefundRequestScreen> {
  final _orderIdController = TextEditingController();
  bool _isSearching = false;
  Map<String, dynamic>? _orderData;

  // Mock order items
  final List<Map<String, dynamic>> _selectedItems = [];

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

          if (_orderData != null) ...[
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
                        Text('فاتورة: ${_orderData!['id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('${_orderData!['date']} - ${_orderData!['total']} ر.س'),
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
                  const Text('اختر المنتجات للإرجاع', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: _selectAll,
                    child: const Text('تحديد الكل'),
                  ),
                ],
              ),
            ),

            // Items list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: (_orderData!['items'] as List).length,
                itemBuilder: (context, index) {
                  final item = (_orderData!['items'] as List)[index];
                  final isSelected = _selectedItems.any((e) => e['id'] == item['id']);
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: CheckboxListTile(
                      value: isSelected,
                      onChanged: (v) => _toggleItem(item, v ?? false),
                      title: Text(item['name'] as String),
                      subtitle: Text('الكمية: ${item['qty']} × ${item['price']} ر.س'),
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
                          Text('${_selectedItems.length} منتج محدد'),
                          Text(
                            'المبلغ: ${_calculateRefundAmount().toStringAsFixed(0)} ر.س',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: _proceedToReason,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('التالي'),
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
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isSearching = false;
      _orderData = {
        'id': _orderIdController.text.isNotEmpty ? _orderIdController.text : 'INV-2024-001',
        'date': '2024-01-15 14:30',
        'total': 250.0,
        'items': [
          {'id': '1', 'name': 'منتج 1', 'qty': 2, 'price': 50.0},
          {'id': '2', 'name': 'منتج 2', 'qty': 1, 'price': 75.0},
          {'id': '3', 'name': 'منتج 3', 'qty': 3, 'price': 25.0},
        ],
      };
      _selectedItems.clear();
    });
  }

  void _toggleItem(Map<String, dynamic> item, bool selected) {
    setState(() {
      if (selected) {
        _selectedItems.add(item);
      } else {
        _selectedItems.removeWhere((e) => e['id'] == item['id']);
      }
    });
  }

  void _selectAll() {
    setState(() {
      _selectedItems.clear();
      _selectedItems.addAll((_orderData!['items'] as List).cast<Map<String, dynamic>>());
    });
  }

  double _calculateRefundAmount() {
    return _selectedItems.fold(0.0, (sum, item) => sum + (item['qty'] as int) * (item['price'] as double));
  }

  void _proceedToReason() {
    context.push('/returns/reason');
  }
}
