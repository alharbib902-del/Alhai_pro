/// Remove Inventory Screen - Remove stock from a product
///
/// Search/scan product, quantity to remove, reason selection, note.
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
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiBreakpoints, AlhaiSpacing;
// alhai_design_system is re-exported via alhai_shared_ui
import '../../core/services/sentry_service.dart';
import '../../core/services/audit_service.dart';

/// شاشة سحب مخزون
class RemoveInventoryScreen extends ConsumerStatefulWidget {
  const RemoveInventoryScreen({super.key});

  @override
  ConsumerState<RemoveInventoryScreen> createState() =>
      _RemoveInventoryScreenState();
}

class _RemoveInventoryScreenState extends ConsumerState<RemoveInventoryScreen> {
  final _db = GetIt.I<AppDatabase>();
  final _searchController = TextEditingController();
  final _quantityController = TextEditingController();
  final _noteController = TextEditingController();

  List<ProductsTableData> _searchResults = [];
  ProductsTableData? _selectedProduct;
  bool _isSearching = false;
  bool _isSaving = false;
  String _reason = 'sold';

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
    setState(() => _isSearching = true);
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;
      final products = await _db.productsDao.searchProducts(query, storeId);
      if (mounted) {
        setState(() {
          _searchResults = products;
          _isSearching = false;
        });
      }
    } catch (e, stack) {
      reportError(e,
          stackTrace: stack, hint: 'Search products in remove inventory');
      if (mounted) {
        setState(() => _isSearching = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context).errorOccurred),
              backgroundColor: AppColors.error),
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
          title: l10n.removeInventory,
          subtitle: _getDateSubtitle(l10n),
          showSearch: false,
          searchHint: l10n.searchPlaceholder,
          onMenuTap:
              isWideScreen ? null : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 3,
          userName: user?.name ?? l10n.cashCustomer,
          userRole: l10n.branchManager,
          onUserTap: () {},
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(
                isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
            child:
                _buildContent(isWideScreen, isMediumScreen, colorScheme, l10n),
          ),
        ),
      ],
    );
  }

  String _getDateSubtitle(AppLocalizations l10n) {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year} \u2022 ${l10n.mainBranch}';
  }

  Widget _buildContent(bool isWideScreen, bool isMediumScreen,
      ColorScheme colorScheme, AppLocalizations l10n) {
    if (isWideScreen) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildSearchCard(colorScheme, l10n),
                if (_searchResults.isNotEmpty && _selectedProduct == null) ...[
                  const SizedBox(height: AlhaiSpacing.md),
                  _buildSearchResults(colorScheme, l10n)
                ],
                if (_selectedProduct != null) ...[
                  const SizedBox(height: AlhaiSpacing.lg),
                  _buildSelectedCard(colorScheme, l10n)
                ],
                const SizedBox(height: AlhaiSpacing.lg),
                _buildQuantityCard(colorScheme, l10n),
              ],
            ),
          ),
          const SizedBox(width: AlhaiSpacing.lg),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildReasonCard(colorScheme, l10n),
                const SizedBox(height: AlhaiSpacing.lg),
                _buildNoteCard(colorScheme, l10n),
                const SizedBox(height: AlhaiSpacing.lg),
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
        if (_searchResults.isNotEmpty && _selectedProduct == null) ...[
          SizedBox(height: isMediumScreen ? AlhaiSpacing.md : AlhaiSpacing.sm),
          _buildSearchResults(colorScheme, l10n)
        ],
        if (_selectedProduct != null) ...[
          SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
          _buildSelectedCard(colorScheme, l10n)
        ],
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        _buildQuantityCard(colorScheme, l10n),
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        _buildReasonCard(colorScheme, l10n),
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        _buildNoteCard(colorScheme, l10n),
        const SizedBox(height: AlhaiSpacing.lg),
        _buildSaveButton(colorScheme, l10n),
      ],
    );
  }

  Widget _buildSearchCard(ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
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
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.search_rounded,
                    color: AppColors.error, size: 20),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(l10n.searchProduct,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface)),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: colorScheme.onSurface),
                  onChanged: _searchProducts,
                  decoration: InputDecoration(
                    hintText: l10n.searchByNameOrBarcode,
                    hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: colorScheme.onSurfaceVariant),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerLow,
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
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: AlhaiSpacing.md, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              SizedBox(
                height: 56,
                child: FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(l10n.scanBarcodeHint),
                          backgroundColor: AppColors.info),
                    );
                  },
                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
                  label: Text(l10n.scanLabel),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.info,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          if (_isSearching)
            const Padding(
                padding: EdgeInsets.only(top: AlhaiSpacing.md),
                child: Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }

  Widget _buildSearchResults(ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
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
              padding: const EdgeInsets.symmetric(
                  horizontal: AlhaiSpacing.mdl, vertical: 14),
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color:
                            colorScheme.outlineVariant.withValues(alpha: 0.5))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(product.name,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface)),
                  ),
                  Text('${l10n.stock}: ${product.stockQty}',
                      style: TextStyle(
                          fontSize: 12, color: colorScheme.onSurfaceVariant)),
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
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(
            alpha:
                Theme.of(context).brightness == Brightness.dark ? 0.1 : 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.remove_circle_rounded,
                color: AppColors.error, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface)),
                Text('${l10n.currentStock}: ${product.stockQty}',
                    style: TextStyle(
                        fontSize: 12, color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => setState(() {
              _selectedProduct = null;
              _searchController.clear();
            }),
            icon:
                Icon(Icons.close_rounded, color: colorScheme.onSurfaceVariant),
            tooltip: l10n.clearField,
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityCard(ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.quantityToRemove,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface)),
          const SizedBox(height: AlhaiSpacing.md),
          TextField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface),
            textAlign: TextAlign.center,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 28,
                  fontWeight: FontWeight.bold),
              prefixIcon: const Padding(
                padding: EdgeInsets.all(AlhaiSpacing.sm),
                child: Icon(Icons.remove_rounded,
                    size: 28, color: AppColors.error),
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
              fillColor: colorScheme.surfaceContainerLow,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonCard(ColorScheme colorScheme, AppLocalizations l10n) {
    final reasons = [
      {
        'value': 'sold',
        'label': l10n.sold,
        'icon': Icons.shopping_cart_rounded,
        'color': AppColors.success
      },
      {
        'value': 'damaged',
        'label': l10n.damaged,
        'icon': Icons.broken_image_rounded,
        'color': AppColors.error
      },
      {
        'value': 'expired',
        'label': l10n.expired,
        'icon': Icons.schedule_rounded,
        'color': AppColors.warning
      },
      {
        'value': 'transferred',
        'label': l10n.transferred,
        'icon': Icons.swap_horiz_rounded,
        'color': AppColors.info
      },
      {
        'value': 'other',
        'label': l10n.other,
        'icon': Icons.more_horiz_rounded,
        'color': Theme.of(context).colorScheme.outline
      },
    ];

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
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
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.list_alt_rounded,
                    color: AppColors.warning, size: 20),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(l10n.reason,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface)),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          ...reasons.map((r) {
            final isSelected = _reason == r['value'];
            final color = r['color'] as Color;
            return Padding(
              padding: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
              child: InkWell(
                onTap: () => setState(() => _reason = r['value'] as String),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: AlhaiSpacing.md, vertical: AlhaiSpacing.sm),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withValues(alpha: 0.1)
                        : colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? color : colorScheme.outlineVariant,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(r['icon'] as IconData,
                          size: 20,
                          color: isSelected
                              ? color
                              : colorScheme.onSurfaceVariant),
                      const SizedBox(width: AlhaiSpacing.sm),
                      Text(r['label'] as String,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? color
                                  : colorScheme.onSurfaceVariant)),
                      const Spacer(),
                      if (isSelected)
                        Icon(Icons.check_circle_rounded,
                            size: 20, color: color),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNoteCard(ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.noteLabel,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface)),
          const SizedBox(height: AlhaiSpacing.sm),
          TextField(
            controller: _noteController,
            maxLines: 3,
            style: TextStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: l10n.optionalNote,
              hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
              filled: true,
              fillColor: colorScheme.surfaceContainerLow,
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
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.all(AlhaiSpacing.md),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(ColorScheme colorScheme, AppLocalizations l10n) {
    final hasData = _selectedProduct != null &&
        _quantityController.text.isNotEmpty &&
        (int.tryParse(_quantityController.text) ?? 0) > 0;

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _isSaving || !hasData ? null : _removeInventory,
        icon: _isSaving
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: colorScheme.onPrimary))
            : const Icon(Icons.remove_circle_rounded, size: 20),
        label: Text(l10n.confirmRemoval,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Future<void> _removeInventory() async {
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
            type: 'subtraction',
            qty: (-quantity).toDouble(),
            previousQty: currentStock.toDouble(),
            newQty: newStock.toDouble(),
            reason: Value(_reason),
            notes: Value(
                _noteController.text.isNotEmpty ? _noteController.text : null),
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
        reason: 'سحب مخزون: $_reason',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(l10n.success), backgroundColor: AppColors.success),
      );

      setState(() {
        _selectedProduct = null;
        _searchController.clear();
        _quantityController.clear();
        _noteController.clear();
        _reason = 'sold';
      });
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Save remove inventory');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(l10n.errorWithDetails('$e')),
            backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
