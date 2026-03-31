/// Wastage Screen - Record product wastage
///
/// Search/scan product, quantity wasted, reason selection,
/// photo placeholder, save and log.
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
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' show Value;
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiBreakpoints;
// alhai_design_system is re-exported via alhai_shared_ui
import '../../core/services/sentry_service.dart';
import '../../core/services/audit_service.dart';

/// شاشة الهدر والتالف
class WastageScreen extends ConsumerStatefulWidget {
  const WastageScreen({super.key});

  @override
  ConsumerState<WastageScreen> createState() => _WastageScreenState();
}

class _WastageScreenState extends ConsumerState<WastageScreen> {
  final _db = GetIt.I<AppDatabase>();
  final _searchController = TextEditingController();
  final _quantityController = TextEditingController();
  final _noteController = TextEditingController();

  List<ProductsTableData> _searchResults = [];
  ProductsTableData? _selectedProduct;
  bool _isSaving = false;
  String _reason = 'expired';
  bool _hasPhoto = false;

  @override
  void dispose() {
    _searchController.dispose();
    _quantityController.dispose();
    _noteController.dispose();
    super.dispose();
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
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Search products in wastage');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width >= AlhaiBreakpoints.desktop;
    final isMediumScreen = size.width >= AlhaiBreakpoints.tablet;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);

    return Column(
      children: [
        AppHeader(
          title: 'Wastage',
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
          child: SingleChildScrollView(
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
                _buildSearchCard(colorScheme, l10n),
                if (_searchResults.isNotEmpty && _selectedProduct == null)
                  ...[const SizedBox(height: 16), _buildSearchResults(colorScheme, l10n)],
                if (_selectedProduct != null)
                  ...[const SizedBox(height: 16), _buildSelectedCard(colorScheme, l10n)],
                const SizedBox(height: 24),
                _buildQuantityCard(colorScheme, l10n),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildReasonCard(colorScheme, l10n),
                const SizedBox(height: 24),
                _buildPhotoCard(colorScheme, l10n),
                const SizedBox(height: 24),
                _buildNoteCard(colorScheme, l10n),
                const SizedBox(height: 24),
                _buildSaveButton(colorScheme, l10n),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSearchCard(colorScheme, l10n),
        if (_searchResults.isNotEmpty && _selectedProduct == null)
          ...[const SizedBox(height: 12), _buildSearchResults(colorScheme, l10n)],
        if (_selectedProduct != null)
          ...[const SizedBox(height: 12), _buildSelectedCard(colorScheme, l10n)],
        SizedBox(height: isMediumScreen ? 24 : 16),
        _buildQuantityCard(colorScheme, l10n),
        SizedBox(height: isMediumScreen ? 24 : 16),
        _buildReasonCard(colorScheme, l10n),
        SizedBox(height: isMediumScreen ? 24 : 16),
        _buildPhotoCard(colorScheme, l10n),
        SizedBox(height: isMediumScreen ? 24 : 16),
        _buildNoteCard(colorScheme, l10n),
        const SizedBox(height: 24),
        _buildSaveButton(colorScheme, l10n),
      ],
    );
  }

  Widget _buildSearchCard(ColorScheme colorScheme, AppLocalizations l10n) {
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
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.error, size: 20),
              ),
              const SizedBox(width: 12),
              Text(l10n.searchProduct,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface)),
            ],
          ),
          const SizedBox(height: 20),
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
                    prefixIcon: Icon(Icons.search_rounded,
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
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 56,
                child: FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.scanBarcodeHint),
                          backgroundColor: AppColors.info),
                    );
                  },
                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
                  label: const Text('Scan'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.info,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
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
                  Text('${l10n.stock}: ${product.stockQty}',
                      style: TextStyle(fontSize: 12, color: colorScheme.outline)),
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
        color: AppColors.error.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.1 : 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface)),
                Text('${l10n.currentStock}: ${product.stockQty}',
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
          Text('Quantity Wasted',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface)),
          const SizedBox(height: 16),
          TextField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,
                color: colorScheme.onSurface),
            textAlign: TextAlign.center,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(color: colorScheme.outline,
                  fontSize: 28, fontWeight: FontWeight.bold),
              prefixIcon: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.delete_rounded, size: 28, color: AppColors.error),
              ),
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
                borderSide: const BorderSide(color: AppColors.error, width: 2),
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonCard(ColorScheme colorScheme, AppLocalizations l10n) {
    final reasons = [
      {'value': 'expired', 'label': l10n.expired, 'icon': Icons.schedule_rounded},
      {'value': 'damaged', 'label': l10n.damaged, 'icon': Icons.broken_image_rounded},
      {'value': 'spillage', 'label': 'Spillage', 'icon': Icons.water_drop_rounded},
      {'value': 'other', 'label': l10n.other, 'icon': Icons.more_horiz_rounded},
    ];

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
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.list_alt_rounded,
                    color: AppColors.warning, size: 20),
              ),
              const SizedBox(width: 12),
              Text(l10n.reason,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface)),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: reasons.map((r) {
              final isSelected = _reason == r['value'];
              return InkWell(
                onTap: () => setState(() => _reason = r['value'] as String),
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : colorScheme.outlineVariant,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(r['icon'] as IconData, size: 16,
                          color: isSelected
                              ? AppColors.primary
                              : colorScheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text(r['label'] as String,
                          style: TextStyle(fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.primary
                                  : colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard(ColorScheme colorScheme, AppLocalizations l10n) {
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
          Text('Photo',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface)),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              setState(() => _hasPhoto = !_hasPhoto);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _hasPhoto
                      ? AppColors.success
                      : colorScheme.outlineVariant,
                  style: _hasPhoto ? BorderStyle.solid : BorderStyle.none,
                ),
              ),
              child: _hasPhoto
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_rounded,
                              color: AppColors.success, size: 32),
                          SizedBox(height: 8),
                          Text('Photo attached',
                              style: TextStyle(fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.success)),
                        ],
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_outlined, size: 32,
                              color: colorScheme.outline),
                          const SizedBox(height: 8),
                          Text('Tap to take photo',
                              style: TextStyle(fontSize: 13,
                                  color: colorScheme.outline)),
                        ],
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text('Optional',
              style: TextStyle(fontSize: 11, color: colorScheme.outline)),
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

  Widget _buildSaveButton(ColorScheme colorScheme, AppLocalizations l10n) {
    final hasData = _selectedProduct != null &&
        (int.tryParse(_quantityController.text) ?? 0) > 0;

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _isSaving || !hasData ? null : _saveWastage,
        icon: _isSaving
            ? SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onPrimary))
            : const Icon(Icons.save_rounded, size: 20),
        label: const Text('Record Wastage',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Future<void> _saveWastage() async {
    final l10n = AppLocalizations.of(context);
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    if (quantity <= 0 || _selectedProduct == null) return;

    setState(() => _isSaving = true);

    try {
      final storeId = ref.read(currentStoreIdProvider)!;
      final movementId = const Uuid().v4();
      final currentStock = _selectedProduct!.stockQty;
      final newStock = currentStock - quantity;

      await _db.transaction(() async {
        await _db.inventoryDao.insertMovement(
          InventoryMovementsTableCompanion.insert(
            id: movementId,
            storeId: storeId,
            productId: _selectedProduct!.id,
            type: 'wastage',
            qty: (-quantity).toDouble(),
            previousQty: currentStock.toDouble(),
            newQty: newStock.toDouble(),
            reason: Value(_reason),
            notes: Value(_noteController.text.isNotEmpty ? _noteController.text : null),
            createdAt: DateTime.now(),
          ),
        );
        await _db.productsDao.updateStock(_selectedProduct!.id, newStock);
      });

      // Audit log
      final user = ref.read(currentUserProvider);
      auditService.logStockAdjust(
        storeId: storeId,
        userId: user?.id ?? 'unknown',
        userName: user?.name ?? 'unknown',
        productId: _selectedProduct!.id,
        productName: _selectedProduct!.name,
        oldQty: currentStock.toDouble(),
        newQty: newStock.toDouble(),
        reason: 'هدر: $_reason',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.success), backgroundColor: AppColors.success),
      );

      setState(() {
        _selectedProduct = null;
        _searchController.clear();
        _quantityController.clear();
        _noteController.clear();
        _reason = 'expired';
        _hasPhoto = false;
      });
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Save wastage record');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorWithDetails('$e')), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
