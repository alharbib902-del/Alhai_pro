import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:get_it/get_it.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:alhai_l10n/alhai_l10n.dart';

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

  List<_PriceList> _defaultLists(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      _PriceList(
        id: 'retail',
        name: l10n.retailPrice,
        description: l10n.retailPriceDesc,
        color: Colors.blue,
      ),
      _PriceList(
        id: 'wholesale',
        name: l10n.wholesalePrice,
        description: l10n.wholesalePriceDesc,
        color: Colors.orange,
      ),
      _PriceList(
        id: 'vip',
        name: l10n.vipPrice,
        description: l10n.vipPriceDesc,
        color: Colors.purple,
      ),
      _PriceList(
        id: 'cost',
        name: l10n.costPriceList,
        description: l10n.costPriceDesc,
        color: Colors.red,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    // _priceLists initialized in didChangeDependencies
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() {
      _isLoadingEntries = true;
    });
    try {
      final db = GetIt.I<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) {
        if (mounted) {
          setState(() {
            _isLoadingEntries = false;
          });
        }
        return;
      }

      final currentList = _priceLists[_selectedList];
      String priceColumn;
      switch (currentList.id) {
        case 'retail':
          priceColumn = 'price';
          break;
        case 'wholesale':
          priceColumn = 'COALESCE(wholesale_price, price * 0.85)';
          break;
        case 'vip':
          priceColumn = 'COALESCE(vip_price, price * 0.90)';
          break;
        case 'cost':
          priceColumn = 'COALESCE(cost_price, price * 0.65)';
          break;
        default:
          priceColumn = 'price';
      }

      final result = await db
          .customSelect(
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
          )
          .get();

      if (mounted) {
        setState(() {
          _entries = result
              .map(
                (row) => _PriceEntry(
                  id: row.data['id'] as String,
                  name: row.data['name'] as String,
                  basePrice: _toDouble(row.data['price']),
                  listPrice: _toDouble(row.data['list_price']),
                  costPrice: _toDouble(row.data['cost_price']),
                  stock: _toDouble(row.data['current_stock']),
                ),
              )
              .toList();
          _isLoadingEntries = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingEntries = false;
        });
      }
    }
  }

  double _toDouble(dynamic v) {
    if (v is int) return v.toDouble();
    if (v is double) return v;
    return 0.0;
  }

  void _showEditPriceDialog(_PriceEntry entry) {
    final controller = TextEditingController(
      text: entry.listPrice.toStringAsFixed(2),
    );
    showDialog(
      context: context,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx);
        return AlertDialog(
          title: Text(l10n.editPrice(entry.name)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.basePriceLabel(entry.basePrice.toStringAsFixed(2)),
                style: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontSize: 12,
                ),
              ),
              Text(
                l10n.costPriceLabel(entry.costPrice.toStringAsFixed(2)),
                style: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: AlhaiSpacing.sm),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: l10n.newPriceLabel(
                    _priceLists[_selectedList].name,
                  ),
                  border: const OutlineInputBorder(),
                  suffixText: l10n.sarSuffix,
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                final newPrice = double.tryParse(controller.text);
                if (newPrice != null) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.priceUpdated(
                          entry.name,
                          newPrice.toStringAsFixed(2),
                        ),
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    _priceLists = _defaultLists(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.priceLists),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadEntries,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Price list selector
            Builder(
              builder: (context) {
                final screenWidth = MediaQuery.of(context).size.width;
                final cardWidth = screenWidth >= AlhaiBreakpoints.tablet
                    ? 150.0
                    : 130.0;
                final selectorHeight = screenWidth >= AlhaiBreakpoints.tablet
                    ? 100.0
                    : 85.0;
                return SizedBox(
                  height: selectorHeight,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AlhaiSpacing.sm,
                      vertical: AlhaiSpacing.xs,
                    ),
                    itemCount: _priceLists.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AlhaiSpacing.xs),
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
                          width: cardWidth,
                          padding: const EdgeInsets.all(AlhaiSpacing.sm),
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
                              const SizedBox(height: AlhaiSpacing.xxs),
                              Text(
                                list.description,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isSelected
                                      ? Colors.white70
                                      : Theme.of(context).colorScheme.outline,
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
                );
              },
            ),

            // Active list header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AlhaiSpacing.md,
                vertical: AlhaiSpacing.xs,
              ),
              child: Row(
                children: [
                  Icon(
                    _priceLists[_selectedList].color == Colors.blue
                        ? Icons.storefront_rounded
                        : Icons.business_rounded,
                    color: _priceLists[_selectedList].color,
                    size: 18,
                  ),
                  const SizedBox(width: AlhaiSpacing.xs),
                  Text(
                    '${_priceLists[_selectedList].name} (${l10n.productCount(_entries.length)})',
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
                  ? AppEmptyState.noProducts(context)
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AlhaiSpacing.sm,
                      ),
                      itemCount: _entries.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, thickness: 0),
                      itemBuilder: (ctx, i) {
                        final entry = _entries[i];
                        final diff = entry.listPrice - entry.basePrice;
                        final diffPct = entry.basePrice > 0
                            ? (diff / entry.basePrice) * 100
                            : 0.0;
                        final listColor = _priceLists[_selectedList].color;
                        return ListTile(
                          dense: true,
                          title: Text(
                            entry.name,
                            style: const TextStyle(fontSize: 13),
                          ),
                          subtitle: Text(
                            l10n.baseLabel(entry.basePrice.toStringAsFixed(2)),
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    l10n.amountSar(
                                      entry.listPrice.toStringAsFixed(2),
                                    ),
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
                                        color: diffPct < 0
                                            ? Colors.red
                                            : Colors.green,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: AlhaiSpacing.xxs),
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
