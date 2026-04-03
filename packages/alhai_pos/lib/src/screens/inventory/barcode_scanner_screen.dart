import 'package:flutter/material.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiColors, AlhaiSpacing;
import 'package:get_it/get_it.dart';
import 'package:alhai_l10n/alhai_l10n.dart';


/// شاشة ماسح الباركود
class BarcodeScannerScreen extends ConsumerStatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  ConsumerState<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends ConsumerState<BarcodeScannerScreen> {
  bool _isScanning = false;
  bool _isSearching = false;
  final List<_ScannedProduct> _scannedProducts = [];
  final _barcodeController = TextEditingController();

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.barcodeScanner),
        actions: [
          IconButton(icon: const Icon(Icons.history), onPressed: () => _showHistory(l10n)),
        ],
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final isDesktop = constraints.maxWidth >= 1200;
          final padding = isMobile ? 12.0 : isDesktop ? 24.0 : 16.0;

          return Column(
        children: [
          // منطقة المسح
          Container(
            margin: EdgeInsets.all(padding),
            padding: EdgeInsets.all(isDesktop ? AlhaiSpacing.xl : AlhaiSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.7)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(_isScanning ? Icons.qr_code_scanner : Icons.qr_code, size: 80, color: colorScheme.surface),
                const SizedBox(height: AlhaiSpacing.md),
                Text(_isScanning ? l10n.scanning : l10n.pressToStart, style: TextStyle(color: colorScheme.surface, fontSize: 18)),
                const SizedBox(height: AlhaiSpacing.md),
                FilledButton.icon(
                  onPressed: _toggleScanning,
                  icon: Icon(_isScanning ? Icons.stop : Icons.play_arrow),
                  label: Text(_isScanning ? l10n.stop : l10n.startScanning),
                  style: FilledButton.styleFrom(backgroundColor: colorScheme.surface, foregroundColor: colorScheme.primary),
                ),
              ],
            ),
          ),

          // الإدخال اليدوي
          Padding(
            padding: EdgeInsetsDirectional.only(start: padding, end: padding),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _barcodeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.enterBarcodeManually, prefixIcon: const Icon(Icons.keyboard)),
                    onSubmitted: (_) => _manualSearch(l10n),
                  ),
                ),
                const SizedBox(width: AlhaiSpacing.xs),
                IconButton.filled(
                  icon: _isSearching
                      ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.surface))
                      : const Icon(Icons.search),
                  onPressed: _isSearching ? null : () => _manualSearch(l10n),
                ),
              ],
            ),
          ),

          const SizedBox(height: AlhaiSpacing.md),

          // المنتجات الممسوحة
          Expanded(
            child: _scannedProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code_2, size: 64, color: colorScheme.onSurfaceVariant),
                        const SizedBox(height: AlhaiSpacing.md),
                        Text(l10n.noScannedProducts, style: TextStyle(color: colorScheme.onSurfaceVariant)),
                        const SizedBox(height: AlhaiSpacing.xs),
                        Text(l10n.enterBarcodeToSearch, style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsetsDirectional.only(start: padding, end: padding),
                    itemCount: _scannedProducts.length,
                    itemBuilder: (context, index) {
                      final product = _scannedProducts[_scannedProducts.length - 1 - index];
                      return Card(
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(AlhaiSpacing.xs),
                            decoration: BoxDecoration(color: colorScheme.primaryContainer, borderRadius: BorderRadius.circular(8)),
                            child: Icon(Icons.inventory_2, color: colorScheme.primary),
                          ),
                          title: Text(product.name),
                          subtitle: Text('${l10n.barcode}: ${product.barcode}', style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${product.price.toStringAsFixed(2)} ${l10n.sar}', style: const TextStyle(fontWeight: FontWeight.bold, color: AlhaiColors.success)),
                              Text('${l10n.stock}: ${product.stock}', style: TextStyle(fontSize: 11, color: product.stock < 10 ? colorScheme.error : colorScheme.onSurfaceVariant)),
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
              padding: EdgeInsets.all(padding),
              decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest, border: Border(top: BorderSide(color: colorScheme.outlineVariant))),
              child: Row(
                children: [
                  Text('${_scannedProducts.length} ${l10n.product}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  OutlinedButton(onPressed: () => setState(() => _scannedProducts.clear()), child: Text(l10n.clearAll)),
                  const SizedBox(width: AlhaiSpacing.xs),
                  FilledButton.icon(onPressed: () => _addToCart(l10n), icon: const Icon(Icons.add_shopping_cart), label: Text(l10n.addToCart)),
                ],
              ),
            ),
        ],
          );
        },
      ),
      ),
    );
  }

  void _toggleScanning() {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isScanning = !_isScanning);
    if (_isScanning) {
      // في بيئة حقيقية سيتم استخدام كاميرا الجهاز
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.useManualInputToSearch)),
      );
      setState(() => _isScanning = false);
    }
  }

  void _manualSearch(AppLocalizations l10n) {
    if (_barcodeController.text.isNotEmpty) {
      _handleBarcode(_barcodeController.text.trim(), l10n);
      _barcodeController.clear();
    }
  }

  /// البحث عن المنتج في قاعدة البيانات بالباركود
  Future<void> _handleBarcode(String barcode, AppLocalizations l10n) async {
    final storeId = ref.read(currentStoreIdProvider);
    if (storeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.storeNotSelected)),
      );
      return;
    }

    setState(() => _isSearching = true);

    try {
      final db = GetIt.I<AppDatabase>();
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
            SnackBar(content: Text('${l10n.found}: ${product.name}')),
          );
        }
      } else {
        if (mounted) _showNotFoundDialog(barcode, l10n);
      }
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _showNotFoundDialog(String barcode, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.error_outline, color: AlhaiColors.warning, size: 48),
        title: Text(l10n.productNotFound),
        content: Text('${l10n.productNotFoundForBarcode}\n${l10n.barcode}: $barcode'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.close)),
          FilledButton(onPressed: () { Navigator.pop(context); _addNewProduct(barcode, l10n); }, child: Text(l10n.addNewProduct)),
        ],
      ),
    );
  }

  void _addNewProduct(String barcode, AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.willOpenAddProductScreen)));
  }

  void _showHistory(AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.scanHistory)));
  }

  void _addToCart(AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.addedToCart} ${_scannedProducts.length} ${l10n.products}')));
  }
}

class _ScannedProduct {
  final String id;
  final String barcode, name;
  final double price;
  final int stock;
  _ScannedProduct({required this.id, required this.barcode, required this.name, required this.price, required this.stock});
}
