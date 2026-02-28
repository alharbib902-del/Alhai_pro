/// Edit Price Screen - Update product pricing
///
/// Shows current product name/price, input for new price & cost price,
/// price history list, save button.
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

/// شاشة تعديل السعر
class EditPriceScreen extends ConsumerStatefulWidget {
  final String productId;

  const EditPriceScreen({super.key, required this.productId});

  @override
  ConsumerState<EditPriceScreen> createState() => _EditPriceScreenState();
}

class _EditPriceScreenState extends ConsumerState<EditPriceScreen> {
  final _db = GetIt.I<AppDatabase>();
  final _newPriceController = TextEditingController();
  final _costPriceController = TextEditingController();

  ProductsTableData? _product;
  bool _isLoading = true;
  bool _isSaving = false;
  final List<Map<String, dynamic>> _priceHistory = [];

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  @override
  void dispose() {
    _newPriceController.dispose();
    _costPriceController.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    setState(() => _isLoading = true);
    try {
      final product = await _db.productsDao.getProductById(widget.productId);
      if (mounted && product != null) {
        setState(() {
          _product = product;
          _newPriceController.text = product.price.toStringAsFixed(2);
          _costPriceController.text =
              (product.costPrice ?? 0).toStringAsFixed(2);
          _isLoading = false;
          // Simulate price history from product data
          _priceHistory.addAll([
            {
              'date': product.updatedAt,
              'price': product.price,
              'changedBy': 'system',
            },
          ]);
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
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
          title: 'Edit Price',
          subtitle: _product?.name ?? '',
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
              : _product == null
                  ? _buildNotFound(colorScheme, l10n)
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                      child: _buildContent(
                          isWideScreen, isMediumScreen, colorScheme, l10n),
                    ),
        ),
      ],
    );
  }

  Widget _buildNotFound(ColorScheme colorScheme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(l10n.productNotFound,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded),
            label: Text(l10n.goBack),
          ),
        ],
      ),
    );
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
                _buildProductInfoCard(colorScheme, l10n),
                const SizedBox(height: 24),
                _buildNewPriceCard(colorScheme, l10n),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildPriceComparisonCard(colorScheme, l10n),
                const SizedBox(height: 24),
                _buildPriceHistoryCard(colorScheme, l10n),
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
        _buildProductInfoCard(colorScheme, l10n),
        SizedBox(height: isMediumScreen ? 24 : 16),
        _buildNewPriceCard(colorScheme, l10n),
        SizedBox(height: isMediumScreen ? 24 : 16),
        _buildPriceComparisonCard(colorScheme, l10n),
        SizedBox(height: isMediumScreen ? 24 : 16),
        _buildPriceHistoryCard(colorScheme, l10n),
        const SizedBox(height: 24),
        _buildSaveButton(colorScheme, l10n),
      ],
    );
  }

  Widget _buildProductInfoCard(ColorScheme colorScheme, AppLocalizations l10n) {
    final product = _product!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.inventory_2_rounded,
                color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (product.barcode != null) ...[
                      Icon(Icons.qr_code_rounded,
                          size: 14,
                          color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        product.barcode!,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Icon(Icons.inventory_outlined,
                        size: 14,
                        color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      '${l10n.stock}: ${product.stockQty}',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Current Price',
                style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              Text(
                CurrencyFormatter.format(product.price),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewPriceCard(ColorScheme colorScheme, AppLocalizations l10n) {
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
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.edit_rounded,
                    color: AppColors.success, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.newPrice,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Selling price
          Text(l10n.sellingPrice,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          TextField(
            controller: _newPriceController,
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: '0.00',
              hintStyle: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              suffixText: l10n.sar,
              suffixStyle: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant),
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
              filled: true,
              fillColor: colorScheme.surfaceContainerLow,
            ),
          ),
          const SizedBox(height: 20),
          // Cost price
          Text(l10n.costPrice,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          TextField(
            controller: _costPriceController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: colorScheme.onSurface),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: '0.00',
              hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
              suffixText: l10n.sar,
              suffixStyle: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant),
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
              filled: true,
              fillColor: colorScheme.surfaceContainerLow,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceComparisonCard(ColorScheme colorScheme, AppLocalizations l10n) {
    final oldPrice = _product?.price ?? 0;
    final newPrice = double.tryParse(_newPriceController.text) ?? 0;
    final costPrice = double.tryParse(_costPriceController.text) ?? 0;
    final priceDiff = newPrice - oldPrice;
    final margin = newPrice > 0 && costPrice > 0
        ? ((newPrice - costPrice) / newPrice * 100)
        : 0.0;

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
                child: const Icon(Icons.compare_arrows_rounded,
                    color: AppColors.info, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Price Comparison',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildComparisonRow('Current Price',
              CurrencyFormatter.format(oldPrice), colorScheme),
          _buildComparisonRow(l10n.newPrice,
              CurrencyFormatter.format(newPrice), colorScheme),
          _buildComparisonRow(
            l10n.difference,
            '${priceDiff >= 0 ? '+' : ''}${CurrencyFormatter.format(priceDiff.abs())}',
            colorScheme,
            valueColor:
                priceDiff >= 0 ? AppColors.success : AppColors.error,
          ),
          Divider(height: 24, color: colorScheme.outlineVariant),
          _buildComparisonRow(
            l10n.profitMargin,
            '${margin.toStringAsFixed(1)}%',
            colorScheme,
            valueColor:
                margin > 20 ? AppColors.success : AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String label, String value, ColorScheme colorScheme,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant)),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? colorScheme.onSurface)),
        ],
      ),
    );
  }

  Widget _buildPriceHistoryCard(ColorScheme colorScheme, AppLocalizations l10n) {
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
                child: const Icon(Icons.history_rounded,
                    color: AppColors.warning, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.priceHistory,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_priceHistory.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l10n.noPriceHistory,
                    style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant)),
              ),
            )
          else
            ..._priceHistory.map((entry) {
              final date = entry['date'] as DateTime;
              final price = entry['price'] as double;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.schedule_rounded,
                        size: 16,
                        color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Text(
                      '${date.day}/${date.month}/${date.year}',
                      style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant),
                    ),
                    const Spacer(),
                    Text(
                      CurrencyFormatter.format(price),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildSaveButton(ColorScheme colorScheme, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _isSaving ? null : _savePrice,
        icon: _isSaving
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: colorScheme.onPrimary),
              )
            : const Icon(Icons.save_rounded, size: 20),
        label: Text(l10n.saveChanges,
            style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Future<void> _savePrice() async {
    final newPrice = double.tryParse(_newPriceController.text);
    final costPrice = double.tryParse(_costPriceController.text);
    final l10n = AppLocalizations.of(context)!;

    if (newPrice == null || newPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.enterValidAmount),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final currentProduct = _product!;
      await _db.productsDao.updateProduct(
        currentProduct.copyWith(
          price: newPrice,
          costPrice: Value(costPrice),
          updatedAt: Value(DateTime.now()),
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Price updated'),
          backgroundColor: AppColors.success,
        ),
      );

      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorWithDetails('$e')),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
