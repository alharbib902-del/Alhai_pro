import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../providers/products_providers.dart';
import '../../providers/inventory_advanced_providers.dart';

/// شاشة التحويلات بين الفروع
class StockTransferScreen extends ConsumerStatefulWidget {
  const StockTransferScreen({super.key});

  @override
  ConsumerState<StockTransferScreen> createState() => _StockTransferScreenState();
}

class _StockTransferScreenState extends ConsumerState<StockTransferScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _fromStoreId, _toStoreId;
  final List<_TransferItem> _items = [];
  bool _isSubmitting = false;

  List<StoresTableData> _stores = [];
  List<_Product> _products = [];
  bool _isLoadingStores = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStoresAndProducts();
  }

  Future<void> _loadStoresAndProducts() async {
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) {
        if (mounted) setState(() => _isLoadingStores = false);
        return;
      }
      final db = getIt<AppDatabase>();
      final stores = await db.storesDao.getAllStores();
      final dbProducts = await db.productsDao.getAllProducts(storeId);
      if (mounted) {
        setState(() {
          _stores = stores;
          _products = dbProducts.map((p) => _Product(
            id: p.id,
            name: p.name,
            sku: p.sku ?? '',
            available: p.stockQty,
          )).toList();
          _isLoadingStores = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingStores = false);
    }
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
      body: _isLoadingStores
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
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
                    initialValue: _fromStoreId,
                    decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.store)),
                    hint: const Text('اختر الفرع المصدر'),
                    items: _stores.where((s) => s.id != _toStoreId).map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                    onChanged: (v) => setState(() => _fromStoreId = v),
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
                    initialValue: _toStoreId,
                    decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.store)),
                    hint: const Text('اختر الفرع الهدف'),
                    items: _stores.where((s) => s.id != _fromStoreId).map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                    onChanged: (v) => setState(() => _toStoreId = v),
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
              TextButton.icon(onPressed: _fromStoreId != null ? _addProduct : null, icon: const Icon(Icons.add), label: const Text('إضافة')),
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
                      IconButton(icon: const Icon(Icons.remove), onPressed: item.quantity > 1 ? () => _updateQty(index, -1) : null),
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
              onPressed: (_fromStoreId != null && _toStoreId != null && _items.isNotEmpty && !_isSubmitting) ? _submitTransfer : null,
              icon: _isSubmitting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.swap_horiz),
              label: Text(_isSubmitting ? 'جاري الإنشاء...' : 'إنشاء طلب التحويل'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistory() {
    final transfersAsync = ref.watch(stockTransfersListProvider);

    return transfersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text('خطأ في تحميل التحويلات', style: TextStyle(color: Colors.red.shade600, fontSize: 16)),
            const SizedBox(height: 8),
            TextButton(onPressed: () => ref.invalidate(stockTransfersListProvider), child: const Text('إعادة المحاولة')),
          ],
        ),
      ),
      data: (transfers) {
        if (transfers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.swap_horiz, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'لا توجد تحويلات سابقة',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(stockTransfersListProvider),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: transfers.length,
            itemBuilder: (context, index) {
              final t = transfers[index];
              final itemCount = _getItemCount(t.items);
              final statusColor = t.status == 'completed' ? Colors.green : (t.status == 'cancelled' ? Colors.red : Colors.orange);
              final statusText = _getStatusText(t.status);

              return Card(
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.swap_horiz, color: statusColor),
                  ),
                  title: Text(t.transferNumber, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${_getStoreName(t.fromStoreId)} \u2192 ${_getStoreName(t.toStoreId)}', style: const TextStyle(fontSize: 12)),
                      Text('$itemCount منتجات', style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text(statusText, style: TextStyle(fontSize: 10, color: statusColor)),
                      ),
                      if (t.status == 'pending') ...[
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () => _onCompleteTransfer(t.id),
                          child: const Text('إكمال', style: TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  int _getItemCount(String itemsJson) {
    try {
      final list = jsonDecode(itemsJson) as List<dynamic>;
      return list.length;
    } catch (_) {
      return 0;
    }
  }

  String _getStoreName(String storeId) {
    final store = _stores.where((s) => s.id == storeId);
    return store.isNotEmpty ? store.first.name : storeId;
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed': return 'مكتمل';
      case 'cancelled': return 'ملغي';
      case 'approved': return 'موافق عليه';
      case 'in_transit': return 'قيد النقل';
      default: return 'معلق';
    }
  }

  Future<void> _onCompleteTransfer(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إكمال التحويل'),
        content: const Text('هل تريد إكمال هذا التحويل؟ سيتم خصم الكميات من الفرع المصدر وإضافتها للفرع الهدف.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('إكمال')),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await completeTransfer(ref, id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'تم إكمال التحويل وتحديث المخزون' : 'خطأ في إكمال التحويل'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  void _addProduct() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        if (_products.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text('لا توجد منتجات', style: TextStyle(color: Colors.grey.shade600)),
            ),
          );
        }
        return ListView.builder(
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
        );
      },
    );
  }

  void _updateQty(int index, int delta) => setState(() => _items[index].quantity += delta);

  Future<void> _submitTransfer() async {
    if (_fromStoreId == null || _toStoreId == null || _items.isEmpty) return;

    setState(() => _isSubmitting = true);

    // تحويل عناصر التحويل إلى JSON
    final itemsData = _items.map((item) => {
      'productId': item.product.id,
      'name': item.product.name,
      'sku': item.product.sku,
      'quantity': item.quantity,
    }).toList();

    final result = await createStockTransfer(
      ref,
      fromStoreId: _fromStoreId!,
      toStoreId: _toStoreId!,
      items: itemsData,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إنشاء طلب التحويل بنجاح'), backgroundColor: Colors.green),
        );
        setState(() {
          _items.clear();
          _fromStoreId = null;
          _toStoreId = null;
        });
        // الانتقال لتبويب السجل
        _tabController.animateTo(1);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطأ في إنشاء التحويل'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

class _Product {
  final String id, name, sku;
  final int available;
  _Product({required this.id, required this.name, required this.sku, required this.available});
}

class _TransferItem {
  final _Product product;
  int quantity;
  _TransferItem({required this.product, required this.quantity});
}
