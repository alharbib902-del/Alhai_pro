import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../providers/products_providers.dart';

/// شاشة الجرد
class StockTakeScreen extends ConsumerStatefulWidget {
  const StockTakeScreen({super.key});

  @override
  ConsumerState<StockTakeScreen> createState() => _StockTakeScreenState();
}

class _StockTakeScreenState extends ConsumerState<StockTakeScreen> {
  bool _inProgress = false;
  bool _isLoading = true;
  List<_StockItem> _items = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      final db = getIt<AppDatabase>();
      final products = await db.productsDao.getAllProducts(storeId);
      if (mounted) {
        setState(() {
          _items = products.map((p) => _StockItem(
            id: p.id,
            name: p.name,
            sku: p.sku ?? '',
            systemQty: p.stockQty,
          )).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('الجرد')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final counted = _items.where((i) => i.countedQty != null).length;
    final hasDiscrepancy = _items.any((i) => i.countedQty != null && i.countedQty != i.systemQty);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الجرد'),
        actions: [
          if (_inProgress) IconButton(icon: const Icon(Icons.qr_code_scanner), onPressed: _scanBarcode),
          IconButton(icon: const Icon(Icons.history), onPressed: _showHistory),
        ],
      ),
      floatingActionButton: !_inProgress
          ? FloatingActionButton.extended(onPressed: _startStockTake, icon: const Icon(Icons.play_arrow), label: const Text('بدء الجرد'))
          : null,
      body: Column(
        children: [
          // الإحصائيات
          if (_inProgress) Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _StatCard(icon: Icons.inventory_2, label: 'إجمالي', value: '${_items.length}', color: Colors.blue),
                const SizedBox(width: 12),
                _StatCard(icon: Icons.check_circle, label: 'تم عدها', value: '$counted', color: Colors.green),
                const SizedBox(width: 12),
                _StatCard(icon: Icons.warning, label: 'فروقات', value: hasDiscrepancy ? 'نعم' : 'لا', color: hasDiscrepancy ? Colors.red : Colors.grey),
              ],
            ),
          ),

          // التقدم
          if (_inProgress && _items.isNotEmpty) Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                LinearProgressIndicator(value: counted / _items.length),
                const SizedBox(height: 8),
                Text('$counted من ${_items.length} منتج', style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),

          // قائمة المنتجات أو البداية
          Expanded(
            child: !_inProgress
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inventory, size: 80, color: Colors.blue),
                        const SizedBox(height: 16),
                        const Text('جرد المخزون', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('قم بعد منتجات المخزون ومقارنتها بالنظام', style: TextStyle(color: Colors.grey.shade600)),
                        if (_items.isEmpty) ...[
                          const SizedBox(height: 16),
                          Text('لا توجد منتجات في المخزون', style: TextStyle(color: Colors.orange.shade700)),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      final hasDiff = item.countedQty != null && item.countedQty != item.systemQty;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: hasDiff ? Colors.red.shade50 : (item.countedQty != null ? Colors.green.shade50 : null),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text(item.sku, style: TextStyle(fontSize: 12, fontFamily: 'monospace', color: Colors.grey.shade600)),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Text('النظام: '),
                                        Text('${item.systemQty}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        if (item.countedQty != null) ...[
                                          const Text('  |  العد: '),
                                          Text('${item.countedQty}', style: TextStyle(fontWeight: FontWeight.bold, color: hasDiff ? Colors.red : Colors.green)),
                                          if (hasDiff) Text('  (${item.countedQty! - item.systemQty > 0 ? '+' : ''}${item.countedQty! - item.systemQty})', style: const TextStyle(color: Colors.red)),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 80,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(hintText: 'العدد', border: OutlineInputBorder()),
                                  onChanged: (v) => setState(() => item.countedQty = int.tryParse(v)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // أزرار الإنهاء
          if (_inProgress) Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey.shade100, border: Border(top: BorderSide(color: Colors.grey.shade300))),
            child: Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => setState(() => _inProgress = false), child: const Text('إلغاء'))),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: FilledButton.icon(onPressed: counted == _items.length ? _completeStockTake : null, icon: const Icon(Icons.check), label: const Text('إنهاء الجرد'))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startStockTake() {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد منتجات لبدء الجرد')),
      );
      return;
    }
    setState(() => _inProgress = true);
  }

  void _scanBarcode() => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('مسح الباركود')));
  void _showHistory() => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('سجل الجرد السابق')));

  void _completeStockTake() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إنهاء الجرد'),
        content: const Text('هل تريد حفظ نتائج الجرد وتحديث المخزون؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              try {
                final db = getIt<AppDatabase>();
                final updates = <String, int>{};
                for (final item in _items) {
                  if (item.countedQty != null) {
                    updates[item.id] = item.countedQty!;
                  }
                }
                if (updates.isNotEmpty) {
                  await db.productsDao.batchUpdateStock(updates);
                }
                if (mounted) {
                  setState(() => _inProgress = false);
                  messenger.showSnackBar(
                    const SnackBar(content: Text('تم حفظ الجرد وتحديث المخزون بنجاح')),
                  );
                  // Reload data to reflect updated stock
                  _loadData();
                }
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('خطأ في حفظ الجرد: $e')),
                  );
                }
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}

class _StockItem {
  final String id;
  final String name, sku;
  final int systemQty;
  int? countedQty;
  _StockItem({required this.id, required this.name, required this.sku, required this.systemQty});
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Column(children: [Icon(icon, color: color, size: 20), Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)), Text(label, style: TextStyle(fontSize: 10, color: color))])));
}
