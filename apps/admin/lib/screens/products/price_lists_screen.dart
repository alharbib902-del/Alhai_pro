import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:get_it/get_it.dart';
import 'package:drift/drift.dart' hide Column;

/// شاشة قوائم الأسعار المتعددة
/// تدير أسعار الجملة والتجزئة وأسعار العملاء المميزين
class PriceListsScreen extends ConsumerStatefulWidget {
  const PriceListsScreen({super.key});

  @override
  ConsumerState<PriceListsScreen> createState() => _PriceListsScreenState();
}

class _PriceListsScreenState extends ConsumerState<PriceListsScreen> {
  List<_PriceList> _priceLists = [];
  int _selectedList = 0;
  List<_PriceEntry> _entries = [];
  bool _isLoadingEntries = false;

  final List<_PriceList> _defaultLists = const [
    _PriceList(id: 'retail', name: 'سعر التجزئة', description: 'السعر العادي للعملاء الأفراد', color: Colors.blue),
    _PriceList(id: 'wholesale', name: 'سعر الجملة', description: 'أسعار مخفضة لكميات كبيرة', color: Colors.orange),
    _PriceList(id: 'vip', name: 'أسعار VIP', description: 'أسعار خاصة للعملاء المميزين', color: Colors.purple),
    _PriceList(id: 'cost', name: 'سعر التكلفة', description: 'للاستخدام الداخلي فقط', color: Colors.red),
  ];

  @override
  void initState() {
    super.initState();
    _priceLists = _defaultLists;
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() { _isLoadingEntries = true; });
    try {
      final db = GetIt.I<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) {
        if (mounted) setState(() { _isLoadingEntries = false; });
        return;
      }

      final currentList = _priceLists[_selectedList];
      String priceColumn;
      switch (currentList.id) {
        case 'retail': priceColumn = 'price'; break;
        case 'wholesale': priceColumn = 'COALESCE(wholesale_price, price * 0.85)'; break;
        case 'vip': priceColumn = 'COALESCE(vip_price, price * 0.90)'; break;
        case 'cost': priceColumn = 'COALESCE(cost_price, price * 0.65)'; break;
        default: priceColumn = 'price';
      }

      final result = await db.customSelect(
        '''SELECT
             id,
             name,
             price,
             cost_price,
             $priceColumn as list_price,
             current_stock
           FROM products
           WHERE store_id = ?
             AND is_active = 1
           ORDER BY name
           LIMIT 50''',
        variables: [Variable.withString(storeId)],
      ).get();

      if (mounted) {
        setState(() {
          _entries = result.map((row) => _PriceEntry(
            id: row.data['id'] as String,
            name: row.data['name'] as String,
            basePrice: _toDouble(row.data['price']),
            listPrice: _toDouble(row.data['list_price']),
            costPrice: _toDouble(row.data['cost_price']),
            stock: _toDouble(row.data['current_stock']),
          )).toList();
          _isLoadingEntries = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _isLoadingEntries = false; });
    }
  }

  double _toDouble(dynamic v) {
    if (v is int) return v.toDouble();
    if (v is double) return v;
    return 0.0;
  }

  void _showEditPriceDialog(_PriceEntry entry) {
    final controller = TextEditingController(text: entry.listPrice.toStringAsFixed(2));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('تعديل السعر - ${entry.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('السعر الأساسي: ${entry.basePrice.toStringAsFixed(2)} ر.س',
                style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12)),
            Text('سعر التكلفة: ${entry.costPrice.toStringAsFixed(2)} ر.س',
                style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'السعر الجديد (${_priceLists[_selectedList].name})',
                border: const OutlineInputBorder(),
                suffixText: 'ر.س',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () {
              final newPrice = double.tryParse(controller.text);
              if (newPrice != null) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم تحديث سعر "${entry.name}" إلى ${newPrice.toStringAsFixed(2)} ر.س'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قوائم الأسعار'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadEntries,
          ),
        ],
      ),
      body: Column(
        children: [
          // Price list selector
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _priceLists.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final list = _priceLists[i];
                final isSelected = i == _selectedList;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedList = i);
                    _loadEntries();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 130,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? list.color
                          : list.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: list.color,
                        width: isSelected ? 0 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          list.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isSelected ? Colors.white : list.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          list.description,
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected ? Colors.white70 : Theme.of(context).colorScheme.outline,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Active list header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(_priceLists[_selectedList].color == Colors.blue
                    ? Icons.storefront_rounded
                    : Icons.business_rounded,
                    color: _priceLists[_selectedList].color, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${_priceLists[_selectedList].name} (${_entries.length} منتج)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Products list
          Expanded(
            child: _isLoadingEntries
                ? const Center(child: CircularProgressIndicator())
                : _entries.isEmpty
                    ? Center(child: Text('لا توجد منتجات', style: TextStyle(color: Theme.of(context).hintColor)))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _entries.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (ctx, i) {
                          final entry = _entries[i];
                          final diff = entry.listPrice - entry.basePrice;
                          final diffPct = entry.basePrice > 0
                              ? (diff / entry.basePrice) * 100
                              : 0.0;
                          final listColor = _priceLists[_selectedList].color;
                          return ListTile(
                            dense: true,
                            title: Text(entry.name, style: const TextStyle(fontSize: 13)),
                            subtitle: Text(
                              'أساسي: ${entry.basePrice.toStringAsFixed(2)} ر.س',
                              style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${entry.listPrice.toStringAsFixed(2)} ر.س',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: listColor,
                                        fontSize: 13,
                                      ),
                                    ),
                                    if (diff.abs() > 0.01)
                                      Text(
                                        '${diffPct >= 0 ? '+' : ''}${diffPct.toStringAsFixed(0)}%',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: diffPct < 0 ? Colors.red : Colors.green,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: const Icon(Icons.edit_rounded, size: 18),
                                  onPressed: () => _showEditPriceDialog(entry),
                                  color: Theme.of(context).hintColor,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _PriceList {
  final String id;
  final String name;
  final String description;
  final Color color;
  const _PriceList({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
  });
}

class _PriceEntry {
  final String id;
  final String name;
  final double basePrice;
  final double listPrice;
  final double costPrice;
  final double stock;
  const _PriceEntry({
    required this.id,
    required this.name,
    required this.basePrice,
    required this.listPrice,
    required this.costPrice,
    required this.stock,
  });
}
