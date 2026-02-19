import 'package:flutter/material.dart';

/// شاشة طباعة الباركود
class BarcodePrintScreen extends StatefulWidget {
  const BarcodePrintScreen({super.key});

  @override
  State<BarcodePrintScreen> createState() => _BarcodePrintScreenState();
}

class _BarcodePrintScreenState extends State<BarcodePrintScreen> {
  final List<_ProductLabel> _selectedProducts = [];
  final _searchController = TextEditingController();

  final List<_ProductLabel> _products = [
    _ProductLabel(name: 'أرز بسمتي 5 كجم', sku: 'R001', barcode: '690012345678', price: 45.00),
    _ProductLabel(name: 'زيت طبخ 1.5 لتر', sku: 'O001', barcode: '590012345678', price: 25.50),
    _ProductLabel(name: 'سكر أبيض 1 كجم', sku: 'S001', barcode: '490012345678', price: 8.00),
    _ProductLabel(name: 'حليب طازج 1 لتر', sku: 'M001', barcode: '390012345678', price: 6.50),
    _ProductLabel(name: 'طحين 2 كجم', sku: 'F001', barcode: '290012345678', price: 12.00),
    _ProductLabel(name: 'شاي 200 جم', sku: 'T001', barcode: '190012345678', price: 22.00),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طباعة الباركود'),
        actions: [
          if (_selectedProducts.isNotEmpty)
            Badge(
              label: Text('${_selectedProducts.fold(0, (s, p) => s + p.quantity)}'),
              child: IconButton(icon: const Icon(Icons.print), onPressed: _printLabels),
            ),
        ],
      ),
      body: Row(
        children: [
          // قائمة المنتجات
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'بحث عن منتج...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      final selected = _selectedProducts.any((p) => p.barcode == product.barcode);
                      return Card(
                        color: selected ? Colors.blue.shade50 : null,
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.qr_code_2),
                          ),
                          title: Text(product.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('SKU: ${product.sku}', style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
                              Text('الباركود: ${product.barcode}', style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
                            ],
                          ),
                          trailing: Text('${product.price.toStringAsFixed(2)} ر.س', style: const TextStyle(fontWeight: FontWeight.bold)),
                          onTap: () => _toggleProduct(product),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // المنتجات المحددة
          Container(
            width: 300,
            decoration: BoxDecoration(color: Colors.grey.shade50, border: Border(right: BorderSide(color: Colors.grey.shade300))),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade300))),
                  child: Row(
                    children: [
                      const Icon(Icons.print, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text('قائمة الطباعة', style: TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      if (_selectedProducts.isNotEmpty)
                        TextButton(onPressed: () => setState(() => _selectedProducts.clear()), child: const Text('مسح')),
                    ],
                  ),
                ),
                Expanded(
                  child: _selectedProducts.isEmpty
                      ? const Center(child: Text('اختر منتجات للطباعة', style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          itemCount: _selectedProducts.length,
                          itemBuilder: (context, index) {
                            final product = _selectedProducts[index];
                            return ListTile(
                              title: Text(product.name, style: const TextStyle(fontSize: 13)),
                              subtitle: Text(product.barcode, style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(icon: const Icon(Icons.remove, size: 18), onPressed: () => _updateQuantity(index, -1)),
                                  Text('${product.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  IconButton(icon: const Icon(Icons.add, size: 18), onPressed: () => _updateQuantity(index, 1)),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade300))),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('إجمالي الملصقات'),
                          Text('${_selectedProducts.fold(0, (s, p) => s + p.quantity)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _selectedProducts.isEmpty ? null : _printLabels,
                          icon: const Icon(Icons.print),
                          label: const Text('طباعة الملصقات'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleProduct(_ProductLabel product) {
    setState(() {
      final existing = _selectedProducts.indexWhere((p) => p.barcode == product.barcode);
      if (existing >= 0) {
        _selectedProducts.removeAt(existing);
      } else {
        _selectedProducts.add(_ProductLabel(name: product.name, sku: product.sku, barcode: product.barcode, price: product.price, quantity: 1));
      }
    });
  }

  void _updateQuantity(int index, int delta) {
    setState(() {
      _selectedProducts[index].quantity += delta;
      if (_selectedProducts[index].quantity <= 0) _selectedProducts.removeAt(index);
    });
  }

  void _printLabels() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('طباعة الباركود'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.print, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            Text('سيتم طباعة ${_selectedProducts.fold(0, (s, p) => s + p.quantity)} ملصق'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          FilledButton(onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري الطباعة... ✅')));
          }, child: const Text('طباعة')),
        ],
      ),
    );
  }
}

class _ProductLabel {
  final String name, sku, barcode;
  final double price;
  int quantity;
  _ProductLabel({required this.name, required this.sku, required this.barcode, required this.price, this.quantity = 0});
}
