import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../providers/products_providers.dart';
import '../../providers/inventory_advanced_providers.dart';

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

  // معرّف الجرد الحالي (عند البدء يتم حفظه في قاعدة البيانات)
  String? _currentStockTakeId;
  bool _isSaving = false;

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
                Expanded(child: OutlinedButton(onPressed: _isSaving ? null : () => setState(() { _inProgress = false; _currentStockTakeId = null; }), child: const Text('إلغاء'))),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: (counted == _items.length && !_isSaving) ? _completeStockTake : null,
                    icon: _isSaving
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.check),
                    label: Text(_isSaving ? 'جاري الحفظ...' : 'إنهاء الجرد'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startStockTake() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد منتجات لبدء الجرد')),
      );
      return;
    }

    // إنشاء عملية جرد في قاعدة البيانات
    final name = 'جرد ${DateFormat('yyyy/MM/dd HH:mm').format(DateTime.now())}';
    final id = await createStockTake(ref, name);

    if (id != null && mounted) {
      setState(() {
        _inProgress = true;
        _currentStockTakeId = id;
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطأ في إنشاء عملية الجرد'), backgroundColor: Colors.red),
      );
    }
  }

  void _scanBarcode() => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('مسح الباركود')));

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => _StockTakeHistorySheet(scrollController: scrollController),
      ),
    );
  }

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

              if (_currentStockTakeId == null) {
                // الطريقة القديمة - حفظ مباشرة بدون stock_take record
                await _saveLegacyStockTake(messenger);
                return;
              }

              setState(() => _isSaving = true);

              try {
                // تحديث عناصر الجرد أولاً بالقيم المعدودة
                final updatedItems = _items.map((item) => {
                  'productId': item.id,
                  'name': item.name,
                  'sku': item.sku,
                  'expectedQty': item.systemQty,
                  'countedQty': item.countedQty,
                }).toList();

                final itemsJson = jsonEncode(updatedItems);
                final countedCount = _items.where((i) => i.countedQty != null).length;

                await updateStockTakeItems(
                  ref,
                  _currentStockTakeId!,
                  itemsJson: itemsJson,
                  countedItems: countedCount,
                );

                // إكمال الجرد وتحديث المخزون
                final success = await completeStockTake(ref, _currentStockTakeId!);

                if (mounted) {
                  setState(() {
                    _inProgress = false;
                    _isSaving = false;
                    _currentStockTakeId = null;
                  });

                  if (success) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('تم حفظ الجرد وتحديث المخزون بنجاح'), backgroundColor: Colors.green),
                    );
                    // إعادة تحميل البيانات لعرض المخزون المحدّث
                    _loadData();
                  } else {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('خطأ في إكمال الجرد'), backgroundColor: Colors.red),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  setState(() => _isSaving = false);
                  messenger.showSnackBar(
                    SnackBar(content: Text('خطأ في حفظ الجرد: $e'), backgroundColor: Colors.red),
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

  /// الطريقة القديمة - حفظ مباشر بدون سجل جرد (للتوافقية)
  Future<void> _saveLegacyStockTake(ScaffoldMessengerState messenger) async {
    setState(() => _isSaving = true);
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
        setState(() {
          _inProgress = false;
          _isSaving = false;
        });
        messenger.showSnackBar(
          const SnackBar(content: Text('تم حفظ الجرد وتحديث المخزون بنجاح'), backgroundColor: Colors.green),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        messenger.showSnackBar(
          SnackBar(content: Text('خطأ في حفظ الجرد: $e'), backgroundColor: Colors.red),
        );
      }
    }
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

/// ورقة سفلية لعرض سجل الجرد السابق
class _StockTakeHistorySheet extends ConsumerWidget {
  final ScrollController scrollController;
  const _StockTakeHistorySheet({required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stockTakesAsync = ref.watch(stockTakesListProvider);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text('سجل الجرد', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: stockTakesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                  const SizedBox(height: 8),
                  Text('خطأ في تحميل السجل', style: TextStyle(color: Colors.red.shade600)),
                  TextButton(onPressed: () => ref.invalidate(stockTakesListProvider), child: const Text('إعادة المحاولة')),
                ],
              ),
            ),
            data: (stockTakes) {
              if (stockTakes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text('لا يوجد سجل جرد سابق', style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: stockTakes.length,
                itemBuilder: (context, index) {
                  final st = stockTakes[index];
                  final isCompleted = st.status == 'completed';
                  final dateFormat = DateFormat('yyyy/MM/dd HH:mm');

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (isCompleted ? Colors.green : Colors.orange).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isCompleted ? Icons.check_circle : Icons.pending,
                          color: isCompleted ? Colors.green : Colors.orange,
                        ),
                      ),
                      title: Text(st.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(dateFormat.format(st.startedAt), style: const TextStyle(fontSize: 12)),
                          Text(
                            'إجمالي: ${st.totalItems} | معدود: ${st.countedItems} | فروقات: ${st.varianceItems}',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isCompleted ? Colors.green : Colors.orange).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isCompleted ? 'مكتمل' : 'قيد التنفيذ',
                          style: TextStyle(fontSize: 10, color: isCompleted ? Colors.green : Colors.orange),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
