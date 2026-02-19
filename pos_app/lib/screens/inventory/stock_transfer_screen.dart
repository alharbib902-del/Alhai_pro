import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../l10n/generated/app_localizations.dart';
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
  String? _loadError;

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
      if (mounted) setState(() {
        _isLoadingStores = false;
        _loadError = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.stockTransfer),
        bottom: TabBar(
          controller: _tabController,
          tabs: [Tab(text: l10n.newTransfer), Tab(text: l10n.history)],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return _isLoadingStores
              ? const Center(child: CircularProgressIndicator())
              : _loadError != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                          const SizedBox(height: 16),
                          Text(l10n.errorOccurred, style: TextStyle(color: colorScheme.error)),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () {
                              setState(() { _isLoadingStores = true; _loadError = null; });
                              _loadStoresAndProducts();
                            },
                            icon: const Icon(Icons.refresh),
                            label: Text(l10n.retry),
                          ),
                        ],
                      ),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [_buildNewTransfer(l10n, colorScheme, constraints.maxWidth), _buildHistory(l10n, colorScheme, constraints.maxWidth)],
                    );
        },
      ),
    );
  }

  Widget _buildNewTransfer(AppLocalizations l10n, ColorScheme colorScheme, double screenWidth) {
    final isMobile = screenWidth < 600;
    final isDesktop = screenWidth >= 1200;
    final padding = isMobile ? 12.0 : isDesktop ? 24.0 : 16.0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Center(
      child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: isDesktop ? 800 : double.infinity),
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
                  Text(l10n.fromBranch, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _fromStoreId,
                    decoration: InputDecoration(border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.store), hintText: l10n.selectSourceBranch),
                    hint: Text(l10n.selectSourceBranch),
                    items: _stores.where((s) => s.id != _toStoreId).map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                    onChanged: (v) => setState(() => _fromStoreId = v),
                  ),
                ],
              ),
            ),
          ),

          // السهم
          Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Icon(Icons.arrow_downward, color: colorScheme.primary, size: 32))),

          // اختيار الفرع الهدف
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.toBranch, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _toStoreId,
                    decoration: InputDecoration(border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.store), hintText: l10n.selectTargetBranch),
                    hint: Text(l10n.selectTargetBranch),
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
              Text('${l10n.products} (${_items.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
              TextButton.icon(onPressed: _fromStoreId != null ? () => _addProduct(l10n, colorScheme) : null, icon: const Icon(Icons.add), label: Text(l10n.add)),
            ],
          ),

          if (_items.isEmpty)
            Card(child: Padding(padding: const EdgeInsets.all(32), child: Center(child: Text(l10n.selectProductsForTransfer, style: TextStyle(color: colorScheme.onSurfaceVariant)))))
          else
            ...List.generate(_items.length, (index) {
              final item = _items[index];
              return Card(
                child: ListTile(
                  title: Text(item.product.name),
                  subtitle: Text('${l10n.available}: ${item.product.available}', style: const TextStyle(fontSize: 12)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.remove), onPressed: item.quantity > 1 ? () => _updateQty(index, -1) : null),
                      Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(icon: const Icon(Icons.add), onPressed: item.quantity < item.product.available ? () => _updateQty(index, 1) : null),
                      IconButton(icon: Icon(Icons.delete, color: colorScheme.error), onPressed: () => setState(() => _items.removeAt(index))),
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
              icon: _isSubmitting ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.surface)) : const Icon(Icons.swap_horiz),
              label: Text(_isSubmitting ? l10n.creating : l10n.createTransferRequest),
            ),
          ),
        ],
      ),
      ),
      ),
    );
  }

  Widget _buildHistory(AppLocalizations l10n, ColorScheme colorScheme, double screenWidth) {
    final isMobile = screenWidth < 600;
    final isDesktop = screenWidth >= 1200;
    final padding = isMobile ? 12.0 : isDesktop ? 24.0 : 16.0;
    final transfersAsync = ref.watch(stockTransfersListProvider);

    return transfersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(l10n.errorLoadingTransfers, style: TextStyle(color: colorScheme.error, fontSize: 16)),
            const SizedBox(height: 8),
            TextButton(onPressed: () => ref.invalidate(stockTransfersListProvider), child: Text(l10n.retry)),
          ],
        ),
      ),
      data: (transfers) {
        if (transfers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.swap_horiz, size: 64, color: colorScheme.onSurfaceVariant),
                const SizedBox(height: 16),
                Text(
                  l10n.noPreviousTransfers,
                  style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(stockTransfersListProvider),
          child: ListView.builder(
            padding: EdgeInsets.all(padding),
            itemCount: transfers.length,
            itemBuilder: (context, index) {
              final t = transfers[index];
              final itemCount = _getItemCount(t.items);
              final statusColor = t.status == 'completed' ? Colors.green : (t.status == 'cancelled' ? colorScheme.error : Colors.orange);
              final statusText = _getStatusText(t.status, l10n);

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
                      Text('$itemCount ${l10n.products}', style: const TextStyle(fontSize: 11)),
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
                          onTap: () => _onCompleteTransfer(t.id, l10n),
                          child: Text(l10n.complete, style: TextStyle(fontSize: 10, color: colorScheme.primary, fontWeight: FontWeight.bold)),
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

  String _getStatusText(String status, AppLocalizations l10n) {
    switch (status) {
      case 'completed': return l10n.completed;
      case 'cancelled': return l10n.cancelled;
      case 'approved': return l10n.approved;
      case 'in_transit': return l10n.inTransit;
      default: return l10n.pending;
    }
  }

  Future<void> _onCompleteTransfer(String id, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.completeTransfer),
        content: Text(l10n.completeTransferConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.complete)),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await completeTransfer(ref, id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? l10n.transferCompletedSuccess : l10n.errorCompletingTransfer),
            backgroundColor: success ? Colors.green : Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _addProduct(AppLocalizations l10n, ColorScheme colorScheme) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        if (_products.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(l10n.noProducts, style: TextStyle(color: colorScheme.onSurfaceVariant)),
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
              subtitle: Text('${l10n.available}: ${p.available}'),
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
    final l10n = AppLocalizations.of(context)!;

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
          SnackBar(content: Text(l10n.transferCreatedSuccess), backgroundColor: Colors.green),
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
          SnackBar(content: Text(l10n.errorCreatingTransfer), backgroundColor: Theme.of(context).colorScheme.error),
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
