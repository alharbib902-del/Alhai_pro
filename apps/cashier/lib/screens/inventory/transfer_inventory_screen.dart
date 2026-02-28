/// Transfer Inventory Screen - Transfer stock between stores
///
/// From store (current, read-only), to store dropdown, product search/scan,
/// quantity, note, submit button.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:drift/drift.dart' show Value;
// alhai_design_system is re-exported via alhai_shared_ui

/// شاشة نقل المخزون
class TransferInventoryScreen extends ConsumerStatefulWidget {
  const TransferInventoryScreen({super.key});

  @override
  ConsumerState<TransferInventoryScreen> createState() =>
      _TransferInventoryScreenState();
}

class _TransferInventoryScreenState
    extends ConsumerState<TransferInventoryScreen> {
  final _db = GetIt.I<AppDatabase>();
  final _searchController = TextEditingController();
  final _quantityController = TextEditingController();
  final _noteController = TextEditingController();

  List<StoresTableData> _stores = [];
  String? _toStoreId;
  List<ProductsTableData> _searchResults = [];
  ProductsTableData? _selectedProduct;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _quantityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadStores() async {
    setState(() => _isLoading = true);
    try {
      final stores = await _db.storesDao.getAllStores();
      final currentStoreId = ref.read(currentStoreIdProvider);
      if (mounted) {
        setState(() {
          _stores = stores.where((s) => s.id != currentStoreId).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _searchProducts(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;
      final products = await _db.productsDao.searchProducts(query, storeId);
      if (mounted) {
        setState(() {
          _searchResults = products;
        });
      }
    } catch (_) {
      // Search failed silently
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);

    return Column(
      children: [
        AppHeader(
          title: 'Transfer Inventory',
          subtitle: _getDateSubtitle(l10n),
          showSearch: false,
          searchHint: l10n.searchPlaceholder,
          onMenuTap: isWideScreen
              ? null
              : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 3,
          userName: user?.name ?? l10n.cashCustomer,
          userRole: l10n.branchManager,
          onUserTap: () {},
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                  child: _buildContent(isWideScreen, isMediumScreen, colorScheme, l10n),
                ),
        ),
      ],
    );
  }

  String _getDateSubtitle(AppLocalizations l10n) {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year} \u2022 ${l10n.mainBranch}';
  }

  Widget _buildContent(
      bool isWideScreen, bool isMediumScreen, ColorScheme colorScheme, AppLocalizations l10n) {
    if (isWideScreen) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildStoreSelectionCard(colorScheme, l10n),
                const SizedBox(height: 24),
                _buildProductSearchCard(colorScheme, l10n),
                if (_searchResults.isNotEmpty && _selectedProduct == null)
                  ...[const SizedBox(height: 16), _buildSearchResults(colorScheme, l10n)],
                if (_selectedProduct != null)
                  ...[const SizedBox(height: 16), _buildSelectedCard(colorScheme, l10n)],
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildQuantityCard(colorScheme, l10n),
                const SizedBox(height: 24),
                _buildNoteCard(colorScheme, l10n),
                const SizedBox(height: 24),
                _buildSubmitButton(colorScheme, l10n),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStoreSelectionCard(colorScheme, l10n),
        SizedBox(height: isMediumScreen ? 24 : 16),
        _buildProductSearchCard(colorScheme, l10n),
        if (_searchResults.isNotEmpty && _selectedProduct == null)
          ...[const SizedBox(height: 12), _buildSearchResults(colorScheme, l10n)],
        if (_selectedProduct != null)
          ...[const SizedBox(height: 12), _buildSelectedCard(colorScheme, l10n)],
        SizedBox(height: isMediumScreen ? 24 : 16),
        _buildQuantityCard(colorScheme, l10n),
        SizedBox(height: isMediumScreen ? 24 : 16),
        _buildNoteCard(colorScheme, l10n),
        const SizedBox(height: 24),
        _buildSubmitButton(colorScheme, l10n),
      ],
    );
  }

  Widget _buildStoreSelectionCard(ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.swap_horiz_rounded,
                    color: AppColors.info, size: 20),
              ),
              const SizedBox(width: 12),
              Text('Transfer Details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface)),
            ],
          ),
          const SizedBox(height: 20),
          // From store (read-only)
          Text('From Store',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                const Icon(Icons.store_rounded, size: 20, color: AppColors.primary),
                const SizedBox(width: 10),
                Text(l10n.mainBranch,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text('Current',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                          color: AppColors.info)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // To store dropdown
          Text('To Store',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _toStoreId,
            style: TextStyle(color: colorScheme.onSurface),
            dropdownColor: colorScheme.surface,
            decoration: InputDecoration(
              hintText: 'Select Store',
              hintStyle: TextStyle(color: colorScheme.outline),
              prefixIcon: Icon(Icons.store_mall_directory_rounded,
                  color: colorScheme.outline),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            items: _stores.map((store) {
              return DropdownMenuItem<String>(
                value: store.id,
                child: Text(store.name),
              );
            }).toList(),
            onChanged: (v) => setState(() => _toStoreId = v),
          ),
        ],
      ),
    );
  }

  Widget _buildProductSearchCard(ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.searchProduct,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: colorScheme.onSurface),
                  onChanged: _searchProducts,
                  decoration: InputDecoration(
                    hintText: l10n.searchByNameOrBarcode,
                    hintStyle: TextStyle(color: colorScheme.outline),
                    prefixIcon: Icon(Icons.search_rounded, color: colorScheme.outline),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.info),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.info.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: _searchResults.take(5).map((product) {
          return InkWell(
            onTap: () => setState(() {
              _selectedProduct = product;
              _searchController.text = product.name;
              _searchResults = [];
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5))),
              ),
              child: Row(
                children: [
                  Expanded(child: Text(product.name,
                      style: TextStyle(fontSize: 14, color: colorScheme.onSurface))),
                  Text('${product.stockQty}',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSelectedCard(ColorScheme colorScheme, AppLocalizations l10n) {
    final product = _selectedProduct!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.1 : 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.info, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface)),
                Text('${l10n.available}: ${product.stockQty}',
                    style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => setState(() { _selectedProduct = null; _searchController.clear(); }),
            icon: Icon(Icons.close_rounded, size: 18, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityCard(ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.quantity,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface)),
          const SizedBox(height: 16),
          TextField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,
                color: colorScheme.onSurface),
            textAlign: TextAlign.center,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(color: colorScheme.outline,
                  fontSize: 24, fontWeight: FontWeight.bold),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.noteLabel,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface)),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            maxLines: 3,
            style: TextStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Optional note',
              hintStyle: TextStyle(color: colorScheme.outline),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(ColorScheme colorScheme, AppLocalizations l10n) {
    final isValid = _selectedProduct != null &&
        _toStoreId != null &&
        (int.tryParse(_quantityController.text) ?? 0) > 0;

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _isSaving || !isValid ? null : _submitTransfer,
        icon: _isSaving
            ? SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onPrimary))
            : const Icon(Icons.send_rounded, size: 20),
        label: const Text('Submit Transfer',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Future<void> _submitTransfer() async {
    final l10n = AppLocalizations.of(context)!;
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    if (quantity <= 0) return;

    setState(() => _isSaving = true);

    try {
      final storeId = ref.read(currentStoreIdProvider) ?? 'demo-store';
      final movementId = 'TRF-${DateTime.now().millisecondsSinceEpoch}';
      final currentStock = _selectedProduct!.stockQty;
      final newStock = currentStock - quantity;

      await _db.inventoryDao.insertMovement(
        InventoryMovementsTableCompanion.insert(
          id: movementId,
          storeId: storeId,
          productId: _selectedProduct!.id,
          type: 'transfer_out',
          qty: (-quantity).toDouble(),
          previousQty: currentStock.toDouble(),
          newQty: newStock.toDouble(),
          reason: Value('transfer_to_$_toStoreId'),
          notes: Value(_noteController.text.isNotEmpty ? _noteController.text : null),
          createdAt: DateTime.now(),
        ),
      );

      await _db.productsDao.updateStock(_selectedProduct!.id, newStock);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.transferCompletedSuccess), backgroundColor: AppColors.success),
      );

      setState(() {
        _selectedProduct = null;
        _toStoreId = null;
        _searchController.clear();
        _quantityController.clear();
        _noteController.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorWithDetails('$e')), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
