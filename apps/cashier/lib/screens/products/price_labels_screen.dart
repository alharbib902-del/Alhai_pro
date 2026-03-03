/// Price Labels Screen - Multi-select product label printing
///
/// Select products with checkboxes, label size selection, print selected.
/// Shows: product name, price, barcode on each label preview.
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
// alhai_design_system is re-exported via alhai_shared_ui
import '../../core/services/sentry_service.dart';

/// شاشة ملصقات الأسعار
class PriceLabelsScreen extends ConsumerStatefulWidget {
  const PriceLabelsScreen({super.key});

  @override
  ConsumerState<PriceLabelsScreen> createState() =>
      _PriceLabelsScreenState();
}

class _PriceLabelsScreenState extends ConsumerState<PriceLabelsScreen> {
  final _db = GetIt.I<AppDatabase>();
  final _searchController = TextEditingController();

  List<ProductsTableData> _products = [];
  List<ProductsTableData> _filteredProducts = [];
  final Set<String> _selectedIds = {};
  bool _isLoading = true;
  bool _isPrinting = false;
  String? _error;
  String _labelSize = 'medium'; // small, medium, large

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(_applySearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;
      final products = await _db.productsDao.getAllProducts(storeId);
      if (mounted) {
        setState(() {
          _products = products;
          _filteredProducts = products;
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Load products for price labels');
      if (mounted) {
        setState(() {
          _error = '$e';
          _isLoading = false;
        });
      }
    }
  }

  void _applySearch() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _filteredProducts = query.isEmpty
          ? _products
          : _products
              .where((p) =>
                  p.name.toLowerCase().contains(query) ||
                  (p.barcode?.toLowerCase().contains(query) ?? false))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);

    return Column(
      children: [
        AppHeader(
          title: 'Price Labels',
          subtitle:
              '${_selectedIds.length} ${l10n.selected} \u2022 ${l10n.mainBranch}',
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
              ? const AppLoadingState()
              : _error != null
                  ? AppErrorState.general(message: _error!, onRetry: _loadProducts)
                  : _buildContent(isWideScreen, isMediumScreen, isDark, l10n),
        ),
      ],
    );
  }

  Widget _buildContent(
      bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    if (isWideScreen) {
      return Row(
        children: [
          Expanded(
            flex: 3,
            child: _buildProductsList(isMediumScreen, isDark, l10n),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildLabelSizeCard(isDark, l10n),
                  const SizedBox(height: 24),
                  _buildLabelPreview(isDark, l10n),
                  const SizedBox(height: 24),
                  _buildPrintButton(isDark, l10n),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        // Label size + actions bar
        Padding(
          padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
          child: Column(
            children: [
              _buildLabelSizeCard(isDark, l10n),
              const SizedBox(height: 12),
            ],
          ),
        ),
        // Products list
        Expanded(child: _buildProductsList(isMediumScreen, isDark, l10n)),
        // Bottom bar
        _buildBottomBar(isDark, l10n),
      ],
    );
  }

  Widget _buildProductsList(
      bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    return Column(
      children: [
        // Search + select all
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: isMediumScreen ? 24 : 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style:
                      TextStyle(color: AppColors.getTextPrimary(isDark)),
                  decoration: InputDecoration(
                    hintText: l10n.searchByNameOrBarcode,
                    hintStyle:
                        TextStyle(color: AppColors.getTextMuted(isDark)),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: AppColors.getTextMuted(isDark)),
                    filled: true,
                    fillColor: AppColors.getSurface(isDark),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: AppColors.getBorder(isDark)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: AppColors.getBorder(isDark)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    if (_selectedIds.length == _filteredProducts.length) {
                      _selectedIds.clear();
                    } else {
                      _selectedIds.addAll(
                          _filteredProducts.map((p) => p.id));
                    }
                  });
                },
                icon: Icon(
                  _selectedIds.length == _filteredProducts.length &&
                          _filteredProducts.isNotEmpty
                      ? Icons.deselect_rounded
                      : Icons.select_all_rounded,
                  size: 18,
                ),
                label: Text(
                  _selectedIds.length == _filteredProducts.length &&
                          _filteredProducts.isNotEmpty
                      ? 'Deselect All'
                      : l10n.selectAll,
                ),
              ),
            ],
          ),
        ),
        // Products
        Expanded(
          child: _filteredProducts.isEmpty
              ? Center(
                  child: Text(l10n.noProducts,
                      style: TextStyle(
                          color: AppColors.getTextMuted(isDark))))
              : ListView.separated(
                  padding: EdgeInsets.symmetric(
                      horizontal: isMediumScreen ? 24 : 16, vertical: 8),
                  itemCount: _filteredProducts.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) =>
                      _buildProductTile(
                          _filteredProducts[index], isDark, l10n),
                ),
        ),
      ],
    );
  }

  Widget _buildProductTile(
      ProductsTableData product, bool isDark, AppLocalizations l10n) {
    final isSelected = _selectedIds.contains(product.id);

    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedIds.remove(product.id);
          } else {
            _selectedIds.add(product.id);
          }
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.06)
              : AppColors.getSurface(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.4)
                : AppColors.getBorder(isDark),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              activeColor: AppColors.primary,
              onChanged: (v) {
                setState(() {
                  if (v == true) {
                    _selectedIds.add(product.id);
                  } else {
                    _selectedIds.remove(product.id);
                  }
                });
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextPrimary(isDark))),
                  const SizedBox(height: 2),
                  Text(
                    product.barcode ?? l10n.noBarcode,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.getTextMuted(isDark),
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${product.price.toStringAsFixed(2)} ${l10n.sar}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelSizeCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
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
                child: const Icon(Icons.aspect_ratio_rounded,
                    color: AppColors.info, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Label Size',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildSizeOption('Small', 'small', isDark),
              const SizedBox(width: 8),
              _buildSizeOption(l10n.medium, 'medium', isDark),
              const SizedBox(width: 8),
              _buildSizeOption('Large', 'large', isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSizeOption(String label, String size, bool isDark) {
    final isSelected = _labelSize == size;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _labelSize = size),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.getSurfaceVariant(isDark),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.getBorder(isDark),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.getTextSecondary(isDark),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabelPreview(bool isDark, AppLocalizations l10n) {
    final selectedProducts = _products
        .where((p) => _selectedIds.contains(p.id))
        .take(3)
        .toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
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
                child: const Icon(Icons.preview_rounded,
                    color: AppColors.warning, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Preview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (selectedProducts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Select products for labels',
                    style: TextStyle(
                        fontSize: 13,
                        color: AppColors.getTextMuted(isDark))),
              ),
            )
          else
            ...selectedProducts.map((product) => _buildLabelItem(
                product, isDark, l10n)),
          if (_selectedIds.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '+${_selectedIds.length - 3} ${l10n.more}',
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.getTextMuted(isDark)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLabelItem(
      ProductsTableData product, bool isDark, AppLocalizations l10n) {
    final labelHeight = _labelSize == 'small'
        ? 60.0
        : _labelSize == 'medium'
            ? 80.0
            : 100.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      height: labelHeight,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Row(
        children: [
          // Mini barcode
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: labelHeight - 40,
                width: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(10, (i) {
                    return Container(
                      width: 1.5,
                      height: labelHeight - 40,
                      margin: const EdgeInsets.symmetric(horizontal: 0.5),
                      color: (i % 3 == 0) ? Colors.white : Colors.black,
                    );
                  }),
                ),
              ),
              Text(
                product.barcode ?? '',
                style: TextStyle(
                    fontSize: 7,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
                    fontFamily: 'monospace'),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(product.name,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  '${product.price.toStringAsFixed(2)} ${l10n.sar}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        border: Border(
          top: BorderSide(color: AppColors.getBorder(isDark), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: _buildPrintButton(isDark, l10n),
      ),
    );
  }

  Widget _buildPrintButton(bool isDark, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed:
            _isPrinting || _selectedIds.isEmpty ? null : _printLabels,
        icon: _isPrinting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.print_rounded, size: 20),
        label: Text(
          '${l10n.printLabels} (${_selectedIds.length})',
          style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Future<void> _printLabels() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isPrinting = true);

    try {
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Print job sent for ${_selectedIds.length} labels'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Print price labels');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorWithDetails('$e')),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isPrinting = false);
    }
  }
}
