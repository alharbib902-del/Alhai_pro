import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../providers/products_providers.dart';

/// شاشة ماسح الباركود
class BarcodeScannerScreen extends ConsumerStatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  ConsumerState<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends ConsumerState<BarcodeScannerScreen> {
  bool _isScanning = false;
  final List<_ScannedProduct> _scannedProducts = [];
  final _barcodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ماسح الباركود'),
        actions: [
          IconButton(icon: const Icon(Icons.history), onPressed: _showHistory),
        ],
      ),
      body: Column(
        children: [
          // منطقة المسح
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.blue.shade600, Colors.blue.shade400]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(_isScanning ? Icons.qr_code_scanner : Icons.qr_code, size: 80, color: Colors.white),
                const SizedBox(height: 16),
                Text(_isScanning ? 'جاري المسح...' : 'اضغط للبدء', style: const TextStyle(color: Colors.white, fontSize: 18)),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _toggleScanning,
                  icon: Icon(_isScanning ? Icons.stop : Icons.play_arrow),
                  label: Text(_isScanning ? 'إيقاف' : 'بدء المسح'),
                  style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.blue),
                ),
              ],
            ),
          ),

          // الإدخال اليدوي
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _barcodeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'أدخل الباركود يدوياً', prefixIcon: Icon(Icons.keyboard)),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(icon: const Icon(Icons.search), onPressed: _manualSearch),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // المنتجات الممسوحة
          Expanded(
            child: _scannedProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code_2, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text('لم يتم مسح أي منتج', style: TextStyle(color: Colors.grey.shade600)),
                        const SizedBox(height: 8),
                        const Text('أدخل باركود للبحث في قاعدة البيانات', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _scannedProducts.length,
                    itemBuilder: (context, index) {
                      final product = _scannedProducts[_scannedProducts.length - 1 - index];
                      return Card(
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.inventory_2, color: Colors.blue),
                          ),
                          title: Text(product.name),
                          subtitle: Text('الباركود: ${product.barcode}', style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${product.price.toStringAsFixed(2)} ر.س', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                              Text('المخزون: ${product.stock}', style: TextStyle(fontSize: 11, color: product.stock < 10 ? Colors.red : Colors.grey)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // شريط الإجراءات
          if (_scannedProducts.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.grey.shade100, border: Border(top: BorderSide(color: Colors.grey.shade300))),
              child: Row(
                children: [
                  Text('${_scannedProducts.length} منتج', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  OutlinedButton(onPressed: () => setState(() => _scannedProducts.clear()), child: const Text('مسح الكل')),
                  const SizedBox(width: 8),
                  FilledButton.icon(onPressed: _addToCart, icon: const Icon(Icons.add_shopping_cart), label: const Text('إضافة للسلة')),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _toggleScanning() {
    setState(() => _isScanning = !_isScanning);
    if (_isScanning) {
      // في بيئة حقيقية سيتم استخدام كاميرا الجهاز
      // حالياً نعرض رسالة للمستخدم
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('استخدم الإدخال اليدوي للبحث عن المنتجات')),
      );
      setState(() => _isScanning = false);
    }
  }

  void _manualSearch() {
    if (_barcodeController.text.isNotEmpty) {
      _handleBarcode(_barcodeController.text.trim());
      _barcodeController.clear();
    }
  }

  /// البحث عن المنتج في قاعدة البيانات بالباركود
  Future<void> _handleBarcode(String barcode) async {
    final storeId = ref.read(currentStoreIdProvider);
    if (storeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لم يتم تحديد المتجر')),
      );
      return;
    }

    final db = getIt<AppDatabase>();
    final product = await db.productsDao.getProductByBarcode(barcode, storeId);

    if (product != null) {
      setState(() => _scannedProducts.add(_ScannedProduct(
        id: product.id,
        barcode: product.barcode ?? barcode,
        name: product.name,
        price: product.price,
        stock: product.stockQty,
      )));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم العثور على: ${product.name}')),
        );
      }

      // إرجاع المنتج للشاشة المستدعية إذا لزم الأمر
      // Navigator.pop(context, product);
    } else {
      if (mounted) _showNotFoundDialog(barcode);
    }
  }

  void _showNotFoundDialog(String barcode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.error_outline, color: Colors.orange, size: 48),
        title: const Text('منتج غير موجود'),
        content: Text('لم يتم العثور على المنتج\nالباركود: $barcode'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق')),
          FilledButton(onPressed: () { Navigator.pop(context); _addNewProduct(barcode); }, child: const Text('إضافة منتج جديد')),
        ],
      ),
    );
  }

  void _addNewProduct(String barcode) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('سيتم فتح شاشة إضافة منتج جديد')));
  }

  void _showHistory() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('سجل المسح')));
  }

  void _addToCart() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تمت إضافة ${_scannedProducts.length} منتجات للسلة')));
  }
}

class _ScannedProduct {
  final String id;
  final String barcode, name;
  final double price;
  final int stock;
  _ScannedProduct({required this.id, required this.barcode, required this.name, required this.price, required this.stock});
}
