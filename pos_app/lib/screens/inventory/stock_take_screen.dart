import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../l10n/generated/app_localizations.dart';
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
  String? _loadError;
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
      if (mounted) setState(() {
        _isLoading = false;
        _loadError = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.stockTake)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.stockTake)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(l10n.errorOccurred, style: TextStyle(color: colorScheme.onSurface)),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  setState(() { _isLoading = true; _loadError = null; });
                  _loadData();
                },
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    final counted = _items.where((i) => i.countedQty != null).length;
    final hasDiscrepancy = _items.any((i) => i.countedQty != null && i.countedQty != i.systemQty);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.stockTake),
        actions: [
          if (_inProgress) IconButton(icon: const Icon(Icons.qr_code_scanner), onPressed: _scanBarcode),
          IconButton(icon: const Icon(Icons.history), onPressed: _showHistory),
        ],
      ),
      floatingActionButton: !_inProgress
          ? FloatingActionButton.extended(onPressed: () => _startStockTake(l10n), icon: const Icon(Icons.play_arrow), label: Text(l10n.startStockTake))
          : null,
      body: Column(
        children: [
          // الإحصائيات
          if (_inProgress) Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _StatCard(icon: Icons.inventory_2, label: l10n.total, value: '${_items.length}', color: colorScheme.primary),
                const SizedBox(width: 12),
                _StatCard(icon: Icons.check_circle, label: l10n.counted, value: '$counted', color: Colors.green),
                const SizedBox(width: 12),
                _StatCard(icon: Icons.warning, label: l10n.variances, value: hasDiscrepancy ? l10n.yes : l10n.no, color: hasDiscrepancy ? colorScheme.error : colorScheme.onSurfaceVariant),
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
                Text('$counted ${l10n.of_} ${_items.length} ${l10n.product}', style: TextStyle(color: colorScheme.onSurfaceVariant)),
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
                        Icon(Icons.inventory, size: 80, color: colorScheme.primary),
                        const SizedBox(height: 16),
                        Text(l10n.stockTake, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(l10n.stockTakeDescription, style: TextStyle(color: colorScheme.onSurfaceVariant)),
                        if (_items.isEmpty) ...[
                          const SizedBox(height: 16),
                          Text(l10n.noProductsInStock, style: TextStyle(color: Colors.orange.shade700)),
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
                        color: hasDiff ? colorScheme.errorContainer : (item.countedQty != null ? Colors.green.withValues(alpha: 0.1) : null),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text(item.sku, style: TextStyle(fontSize: 12, fontFamily: 'monospace', color: colorScheme.onSurfaceVariant)),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text('${l10n.system}: '),
                                        Text('${item.systemQty}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        if (item.countedQty != null) ...[
                                          Text('  |  ${l10n.counted}: '),
                                          Text('${item.countedQty}', style: TextStyle(fontWeight: FontWeight.bold, color: hasDiff ? colorScheme.error : Colors.green)),
                                          if (hasDiff) Text('  (${item.countedQty! - item.systemQty > 0 ? '+' : ''}${item.countedQty! - item.systemQty})', style: TextStyle(color: colorScheme.error)),
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
                                  decoration: InputDecoration(hintText: l10n.count, border: const OutlineInputBorder()),
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
            decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest, border: Border(top: BorderSide(color: colorScheme.outlineVariant))),
            child: Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: _isSaving ? null : () => setState(() { _inProgress = false; _currentStockTakeId = null; }), child: Text(l10n.cancel))),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: (counted == _items.length && !_isSaving) ? () => _completeStockTake(l10n) : null,
                    icon: _isSaving
                        ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.surface))
                        : const Icon(Icons.check),
                    label: Text(_isSaving ? l10n.saving : l10n.finishStockTake),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startStockTake(AppLocalizations l10n) async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noProductsToCount)),
      );
      return;
    }

    // إنشاء عملية جرد في قاعدة البيانات
    final name = '${l10n.stockTake} ${DateFormat('yyyy/MM/dd HH:mm').format(DateTime.now())}';
    final id = await createStockTake(ref, name);

    if (id != null && mounted) {
      setState(() {
        _inProgress = true;
        _currentStockTakeId = id;
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorCreatingStockTake), backgroundColor: Theme.of(context).colorScheme.error),
      );
    }
  }

  void _scanBarcode() => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.scanBarcode)));

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

  void _completeStockTake(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.finishStockTake),
        content: Text(l10n.saveStockTakeConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);

              if (_currentStockTakeId == null) {
                // الطريقة القديمة - حفظ مباشرة بدون stock_take record
                await _saveLegacyStockTake(messenger, l10n);
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
                      SnackBar(content: Text(l10n.stockTakeSavedSuccess), backgroundColor: Colors.green),
                    );
                    // إعادة تحميل البيانات لعرض المخزون المحدّث
                    _loadData();
                  } else {
                    messenger.showSnackBar(
                      SnackBar(content: Text(l10n.errorCompletingStockTake), backgroundColor: Theme.of(context).colorScheme.error),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  setState(() => _isSaving = false);
                  messenger.showSnackBar(
                    SnackBar(content: Text('${l10n.errorSaving}: $e'), backgroundColor: Theme.of(context).colorScheme.error),
                  );
                }
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  /// الطريقة القديمة - حفظ مباشر بدون سجل جرد (للتوافقية)
  Future<void> _saveLegacyStockTake(ScaffoldMessengerState messenger, AppLocalizations l10n) async {
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
          SnackBar(content: Text(l10n.stockTakeSavedSuccess), backgroundColor: Colors.green),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        messenger.showSnackBar(
          SnackBar(content: Text('${l10n.errorSaving}: $e'), backgroundColor: Theme.of(context).colorScheme.error),
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
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(l10n.stockTakeHistory, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                  const SizedBox(height: 8),
                  Text(l10n.errorLoadingHistory, style: TextStyle(color: colorScheme.error)),
                  TextButton(onPressed: () => ref.invalidate(stockTakesListProvider), child: Text(l10n.retry)),
                ],
              ),
            ),
            data: (stockTakes) {
              if (stockTakes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 48, color: colorScheme.onSurfaceVariant),
                      const SizedBox(height: 8),
                      Text(l10n.noStockTakeHistory, style: TextStyle(color: colorScheme.onSurfaceVariant)),
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
                            '${l10n.total}: ${st.totalItems} | ${l10n.counted}: ${st.countedItems} | ${l10n.variances}: ${st.varianceItems}',
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
                          isCompleted ? l10n.completed : l10n.inProgress,
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
