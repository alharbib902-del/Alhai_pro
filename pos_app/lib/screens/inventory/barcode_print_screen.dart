import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../l10n/generated/app_localizations.dart';
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 800;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.barcodePrint),
        actions: [
          if (_selectedProducts.isNotEmpty)
            Badge(
              label: Text('${_selectedProducts.fold(0, (s, p) => s + p.quantity)}'),
              child: IconButton(icon: const Icon(Icons.print), onPressed: () => _printLabels(l10n)),
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
                      Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                      const SizedBox(height: 16),
                      Text(l10n.errorLoadingProducts, style: TextStyle(color: colorScheme.onSurface)),
                      const SizedBox(height: 8),
                      Text(_loadError!, style: TextStyle(color: colorScheme.onSurfaceVariant)),
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
                        label: Text(l10n.retry),
                      ),
                    ],
                  ),
                )
              : _products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code_2, size: 64, color: colorScheme.onSurfaceVariant),
                          const SizedBox(height: 16),
                          Text(l10n.noProductsWithBarcode, style: TextStyle(color: colorScheme.onSurface)),
                          const SizedBox(height: 8),
                          Text(l10n.addBarcodeFirst, style: TextStyle(color: colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    )
                  : isWide
                      ? _buildWideLayout(l10n, colorScheme)
                      : _buildNarrowLayout(l10n, colorScheme),
    );
  }

  Widget _buildWideLayout(AppLocalizations l10n, ColorScheme colorScheme) {
    return Row(
      children: [
        // قائمة المنتجات
        Expanded(
          flex: 2,
          child: _buildProductList(l10n, colorScheme),
        ),
        // المنتجات المحددة
        _buildSelectionPanel(l10n, colorScheme, width: 300),
      ],
    );
  }

  Widget _buildNarrowLayout(AppLocalizations l10n, ColorScheme colorScheme) {
    return Column(
      children: [
        Expanded(child: _buildProductList(l10n, colorScheme)),
        if (_selectedProducts.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${l10n.totalLabels}: ${_selectedProducts.fold(0, (s, p) => s + p.quantity)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    TextButton(onPressed: () => setState(() => _selectedProducts.clear()), child: Text(l10n.clearAll)),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _printLabels(l10n),
                    icon: const Icon(Icons.print),
                    label: Text(l10n.printLabels),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildProductList(AppLocalizations l10n, ColorScheme colorScheme) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n.searchProduct,
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
            ),
            onChanged: _searchProducts,
          ),
        ),
        Expanded(
          child: _filteredProducts.isEmpty
              ? Center(
                  child: Text(l10n.noMatchingProducts, style: TextStyle(color: colorScheme.onSurfaceVariant)),
                )
              : ListView.builder(
                  padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = _filteredProducts[index];
                    final selected = _selectedProducts.any((p) => p.barcode == product.barcode);
                    return Card(
                      color: selected ? colorScheme.primaryContainer : null,
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.qr_code_2),
                        ),
                        title: Text(product.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('SKU: ${product.sku}', style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
                            Text('${l10n.barcode}: ${product.barcode}', style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
                          ],
                        ),
                        trailing: Text('${product.price.toStringAsFixed(2)} ${l10n.sar}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        onTap: () => _toggleProduct(product),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSelectionPanel(AppLocalizations l10n, ColorScheme colorScheme, {double? width}) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: BorderDirectional(start: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colorScheme.outlineVariant))),
            child: Row(
              children: [
                Icon(Icons.print, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(l10n.printList, style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                if (_selectedProducts.isNotEmpty)
                  TextButton(onPressed: () => setState(() => _selectedProducts.clear()), child: Text(l10n.clearAll)),
              ],
            ),
          ),
          Expanded(
            child: _selectedProducts.isEmpty
                ? Center(child: Text(l10n.selectProductsToPrint, style: TextStyle(color: colorScheme.onSurfaceVariant)))
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
            decoration: BoxDecoration(color: colorScheme.surface, border: Border(top: BorderSide(color: colorScheme.outlineVariant))),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.totalLabels),
                    Text('${_selectedProducts.fold(0, (s, p) => s + p.quantity)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _selectedProducts.isEmpty ? null : () => _printLabels(l10n),
                    icon: const Icon(Icons.print),
                    label: Text(l10n.printLabels),
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

  void _printLabels(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.barcodePrint),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.print, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text('${l10n.willPrint} ${_selectedProducts.fold(0, (s, p) => s + p.quantity)} ${l10n.label}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          FilledButton(onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.printing)));
          }, child: Text(l10n.print)),
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
