import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../providers/products_providers.dart';

/// شاشة طباعة الباركود
class BarcodePrintScreen extends ConsumerStatefulWidget {
  const BarcodePrintScreen({super.key});

  @override
  ConsumerState<BarcodePrintScreen> createState() => _BarcodePrintScreenState();
}

class _BarcodePrintScreenState extends ConsumerState<BarcodePrintScreen> {
  final List<_ProductLabel> _selectedProducts = [];
  final _searchController = TextEditingController();

  /// قائمة المنتجات المحملة من قاعدة البيانات
  List<_ProductLabel> _products = [];
  List<_ProductLabel> _filteredProducts = [];
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  /// تحميل المنتجات من قاعدة البيانات
  Future<void> _loadProducts() async {
    final storeId = ref.read(currentStoreIdProvider);
    if (storeId == null) {
      setState(() {
        _isLoading = false;
        _loadError = 'لم يتم تحديد المتجر';
      });
      return;
    }

    try {
      final db = getIt<AppDatabase>();
      final productsData = await db.productsDao.getAllProducts(storeId);

      if (mounted) {
        final products = productsData
            .where((p) => p.barcode != null && p.barcode!.isNotEmpty)
            .map((p) => _ProductLabel(
                  id: p.id,
                  name: p.name,
                  sku: p.sku ?? '',
                  barcode: p.barcode!,
                  price: p.price,
                ))
            .toList();

        setState(() {
          _products = products;
          _filteredProducts = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadError = e.toString();
        });
      }
    }
  }

  /// البحث في المنتجات
  Future<void> _searchProducts(String query) async {
    if (query.isEmpty) {
      setState(() {
        _filteredProducts = _products;
      });
      return;
    }

    final storeId = ref.read(currentStoreIdProvider);
    if (storeId == null) return;

    try {
      final db = getIt<AppDatabase>();
      final results = await db.productsDao.searchProducts(query, storeId);
      setState(() {
        _filteredProducts = results
            .where((p) => p.barcode != null && p.barcode!.isNotEmpty)
            .map((p) => _ProductLabel(
                  id: p.id,
                  name: p.name,
                  sku: p.sku ?? '',
                  barcode: p.barcode!,
                  price: p.price,
                ))
            .toList();
      });
    } catch (_) {
      // في حال فشل البحث، نرجع للقائمة الكاملة
      setState(() {
        _filteredProducts = _products.where((p) {
          final q = query.toLowerCase();
          return p.name.toLowerCase().contains(q) ||
              p.sku.toLowerCase().contains(q) ||
              p.barcode.contains(q);
        }).toList();
      });
    }
  }

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text('حدث خطأ أثناء تحميل المنتجات'),
                      const SizedBox(height: 8),
                      Text(_loadError!, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _loadError = null;
                          });
                          _loadProducts();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
              : _products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code_2, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          const Text('لا توجد منتجات بباركود'),
                          const SizedBox(height: 8),
                          Text('أضف باركود للمنتجات أولاً', style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
                    )
                  : Row(
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
                                  onChanged: _searchProducts,
                                ),
                              ),
                              Expanded(
                                child: _filteredProducts.isEmpty
                                    ? const Center(
                                        child: Text('لا توجد منتجات مطابقة', style: TextStyle(color: Colors.grey)),
                                      )
                                    : ListView.builder(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        itemCount: _filteredProducts.length,
                                        itemBuilder: (context, index) {
                                          final product = _filteredProducts[index];
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
        _selectedProducts.add(_ProductLabel(
          id: product.id,
          name: product.name,
          sku: product.sku,
          barcode: product.barcode,
          price: product.price,
          quantity: 1,
        ));
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
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري الطباعة...')));
          }, child: const Text('طباعة')),
        ],
      ),
    );
  }
}

class _ProductLabel {
  final String id;
  final String name, sku, barcode;
  final double price;
  int quantity;
  _ProductLabel({required this.id, required this.name, required this.sku, required this.barcode, required this.price, this.quantity = 0});
}
