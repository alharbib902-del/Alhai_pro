import 'package:flutter/material.dart';

/// شاشة التحويلات بين الفروع
class StockTransferScreen extends StatefulWidget {
  const StockTransferScreen({super.key});

  @override
  State<StockTransferScreen> createState() => _StockTransferScreenState();
}

class _StockTransferScreenState extends State<StockTransferScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _fromBranch, _toBranch;
  final List<_TransferItem> _items = [];

  final List<String> _branches = ['الفرع الرئيسي', 'فرع الروضة', 'فرع السلامة'];
  final List<_Product> _products = [
    _Product(name: 'أرز بسمتي 5 كجم', sku: 'R001', available: 50),
    _Product(name: 'زيت طبخ 1.5 لتر', sku: 'O001', available: 30),
    _Product(name: 'سكر أبيض 1 كجم', sku: 'S001', available: 100),
    _Product(name: 'حليب طازج 1 لتر', sku: 'M001', available: 80),
  ];

  final List<_Transfer> _history = [
    _Transfer(id: 'TR-001', from: 'الفرع الرئيسي', to: 'فرع الروضة', items: 5, status: 'completed', date: DateTime.now().subtract(const Duration(days: 1))),
    _Transfer(id: 'TR-002', from: 'فرع الروضة', to: 'الفرع الرئيسي', items: 3, status: 'pending', date: DateTime.now().subtract(const Duration(hours: 5))),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تحويل المخزون'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'تحويل جديد'), Tab(text: 'السجل')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildNewTransfer(), _buildHistory()],
      ),
    );
  }

  Widget _buildNewTransfer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // اختيار الفرع المصدر
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('من فرع', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _fromBranch,
                    decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.store)),
                    hint: const Text('اختر الفرع المصدر'),
                    items: _branches.where((b) => b != _toBranch).map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                    onChanged: (v) => setState(() => _fromBranch = v),
                  ),
                ],
              ),
            ),
          ),

          // السهم
          const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Icon(Icons.arrow_downward, color: Colors.blue, size: 32))),

          // اختيار الفرع الهدف
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('إلى فرع', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _toBranch,
                    decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.store)),
                    hint: const Text('اختر الفرع الهدف'),
                    items: _branches.where((b) => b != _fromBranch).map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                    onChanged: (v) => setState(() => _toBranch = v),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // المنتجات
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('المنتجات (${_items.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
              TextButton.icon(onPressed: _fromBranch != null ? _addProduct : null, icon: const Icon(Icons.add), label: const Text('إضافة')),
            ],
          ),

          if (_items.isEmpty)
            const Card(child: Padding(padding: EdgeInsets.all(32), child: Center(child: Text('اختر منتجات للتحويل', style: TextStyle(color: Colors.grey)))))
          else
            ...List.generate(_items.length, (index) {
              final item = _items[index];
              return Card(
                child: ListTile(
                  title: Text(item.product.name),
                  subtitle: Text('المتاح: ${item.product.available}', style: const TextStyle(fontSize: 12)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.remove), onPressed: () => _updateQty(index, -1)),
                      Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(icon: const Icon(Icons.add), onPressed: item.quantity < item.product.available ? () => _updateQty(index, 1) : null),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => _items.removeAt(index))),
                    ],
                  ),
                ),
              );
            }),

          const SizedBox(height: 24),

          // زر التحويل
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: (_fromBranch != null && _toBranch != null && _items.isNotEmpty) ? _submitTransfer : null,
              icon: const Icon(Icons.swap_horiz),
              label: const Text('إنشاء طلب التحويل'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistory() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final t = _history[index];
        return Card(
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: (t.status == 'completed' ? Colors.green : Colors.orange).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.swap_horiz, color: t.status == 'completed' ? Colors.green : Colors.orange),
            ),
            title: Text(t.id, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${t.from} → ${t.to}', style: const TextStyle(fontSize: 12)),
                Text('${t.items} منتجات', style: const TextStyle(fontSize: 11)),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: (t.status == 'completed' ? Colors.green : Colors.orange).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(t.status == 'completed' ? 'مكتمل' : 'معلق', style: TextStyle(fontSize: 10, color: t.status == 'completed' ? Colors.green : Colors.orange)),
            ),
          ),
        );
      },
    );
  }

  void _addProduct() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final p = _products[index];
          final added = _items.any((i) => i.product.sku == p.sku);
          return ListTile(
            title: Text(p.name),
            subtitle: Text('المتاح: ${p.available}'),
            trailing: added ? const Icon(Icons.check, color: Colors.green) : null,
            onTap: added ? null : () { setState(() => _items.add(_TransferItem(product: p, quantity: 1))); Navigator.pop(context); },
          );
        },
      ),
    );
  }

  void _updateQty(int index, int delta) => setState(() => _items[index].quantity += delta);

  void _submitTransfer() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إنشاء طلب التحويل بنجاح ✅')));
    setState(() { _items.clear(); _fromBranch = null; _toBranch = null; });
  }
}

class _Product {
  final String name, sku;
  final int available;
  _Product({required this.name, required this.sku, required this.available});
}

class _TransferItem {
  final _Product product;
  int quantity;
  _TransferItem({required this.product, required this.quantity});
}

class _Transfer {
  final String id, from, to, status;
  final int items;
  final DateTime date;
  _Transfer({required this.id, required this.from, required this.to, required this.items, required this.status, required this.date});
}
