/// Distributor Products Catalog Screen
///
/// Displays distributor's product catalog with search, filtering,
/// and add/edit buttons (UI only, non-functional for now).
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:intl/intl.dart' show NumberFormat;

// ─── Mock Data ───────────────────────────────────────────────────

class _MockProduct {
  final String id;
  final String name;
  final String barcode;
  final String category;
  final double price;
  final int stock;

  const _MockProduct({
    required this.id,
    required this.name,
    required this.barcode,
    required this.category,
    required this.price,
    required this.stock,
  });
}

const _mockProducts = <_MockProduct>[
  _MockProduct(id: '1', name: 'أرز بسمتي ١٠ كيلو', barcode: '6281001100015', category: 'حبوب', price: 95, stock: 500),
  _MockProduct(id: '2', name: 'زيت زيتون بكر ١ لتر', barcode: '6281001100022', category: 'زيوت', price: 140, stock: 200),
  _MockProduct(id: '3', name: 'سكر أبيض ٥ كيلو', barcode: '6281001100039', category: 'حبوب', price: 18, stock: 800),
  _MockProduct(id: '4', name: 'دقيق أبيض ١٠ كيلو', barcode: '6281001100046', category: 'حبوب', price: 22, stock: 600),
  _MockProduct(id: '5', name: 'شاي أحمر ٢٠٠ جرام', barcode: '6281001100053', category: 'مشروبات', price: 12, stock: 1000),
  _MockProduct(id: '6', name: 'قهوة عربية ٥٠٠ جرام', barcode: '6281001100060', category: 'مشروبات', price: 45, stock: 300),
  _MockProduct(id: '7', name: 'حليب بودرة ٢.٥ كيلو', barcode: '6281001100077', category: 'ألبان', price: 55, stock: 250),
  _MockProduct(id: '8', name: 'معكرونة إسباغيتي ٥٠٠ جرام', barcode: '6281001100084', category: 'حبوب', price: 5, stock: 1500),
  _MockProduct(id: '9', name: 'تونة خفيفة ١٧٠ جرام', barcode: '6281001100091', category: 'معلبات', price: 8, stock: 900),
  _MockProduct(id: '10', name: 'صابون غسيل ٣ كيلو', barcode: '6281001100108', category: 'تنظيف', price: 25, stock: 400),
];

// ─── Screen ──────────────────────────────────────────────────────

/// شاشة كتالوج المنتجات للموزع
class DistributorProductsScreen extends ConsumerStatefulWidget {
  const DistributorProductsScreen({super.key});

  @override
  ConsumerState<DistributorProductsScreen> createState() =>
      _DistributorProductsScreenState();
}

class _DistributorProductsScreenState
    extends ConsumerState<DistributorProductsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'الكل';

  final _categories = ['الكل', 'حبوب', 'زيوت', 'مشروبات', 'ألبان', 'معلبات', 'تنظيف'];

  List<_MockProduct> get _filteredProducts {
    var products = _mockProducts.toList();
    if (_searchQuery.isNotEmpty) {
      products = products
          .where((p) =>
              p.name.contains(_searchQuery) ||
              p.barcode.contains(_searchQuery))
          .toList();
    }
    if (_selectedCategory != 'الكل') {
      products = products
          .where((p) => p.category == _selectedCategory)
          .toList();
    }
    return products;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;
    final isMedium = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
        backgroundColor: AppColors.getBackground(isDark),
        appBar: AppBar(
          title: Text(
            'كتالوج المنتجات',
            style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface),
          ),
          centerTitle: false,
          actions: [
            FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('إضافة منتج جديد - قريباً'),
                    backgroundColor: AppColors.info,
                  ),
                );
              },
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('إضافة منتج'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md, vertical: AlhaiSpacing.xs),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(width: AlhaiSpacing.sm),
          ],
        ),
        body: Column(
          children: [
            // ── Search & Filter Bar ──
            _buildSearchBar(isDark, isMedium),

            // ── Products List ──
            Expanded(
              child: _filteredProducts.isEmpty
                  ? _buildEmptyState(isDark)
                  : isWide
                      ? _buildDataTable(isDark)
                      : _buildProductCards(isDark, isMedium),
            ),
          ],
        ),
    );
  }

  Widget _buildSearchBar(bool isDark, bool isMedium) {
    return Container(
      padding: EdgeInsets.all(isMedium ? AlhaiSpacing.mdl : AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        border: Border(
          bottom: BorderSide(color: AppColors.getBorder(isDark)),
        ),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            style: TextStyle(color: AppColors.getTextPrimary(isDark)),
            decoration: InputDecoration(
              hintText: 'ابحث بالاسم أو الباركود...',
              hintStyle: TextStyle(color: AppColors.getTextMuted(isDark)),
              prefixIcon: Icon(Icons.search_rounded,
                  color: AppColors.getTextMuted(isDark)),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.close_rounded,
                          color: AppColors.getTextMuted(isDark)),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.getSurfaceVariant(isDark),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md, vertical: 14),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: AlhaiSpacing.xs),
              itemBuilder: (_, index) {
                final cat = _categories[index];
                final isSelected = cat == _selectedCategory;
                return FilterChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (_) =>
                      setState(() => _selectedCategory = cat),
                  selectedColor: AppColors.primary.withValues(alpha: 0.12),
                  checkmarkColor: AppColors.primary,
                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.getTextSecondary(isDark),
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : AppColors.getBorder(isDark),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  visualDensity: VisualDensity.compact,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── Wide Screen: Data Table ───────────────────────────────────

  Widget _buildDataTable(bool isDark) {
    final products = _filteredProducts;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.getSurface(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.getBorder(isDark)),
        ),
        child: Column(
          children: [
            // Header row
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: AlhaiSpacing.mdl, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.getSurfaceVariant(isDark),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  _tableHeader('المنتج', 4, isDark),
                  _tableHeader('الباركود', 2, isDark),
                  _tableHeader('التصنيف', 2, isDark),
                  _tableHeader('السعر', 2, isDark),
                  _tableHeader('المخزون', 2, isDark),
                  _tableHeader('إجراءات', 1, isDark),
                ],
              ),
            ),
            // Data rows
            ...List.generate(products.length, (index) {
              final product = products[index];
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AlhaiSpacing.mdl, vertical: AlhaiSpacing.sm),
                decoration: BoxDecoration(
                  border: index < products.length - 1
                      ? Border(
                          bottom: BorderSide(
                            color: AppColors.getBorder(isDark)
                                .withValues(alpha: 0.5),
                          ),
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color:
                                  AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.inventory_2_outlined,
                                color: AppColors.primary, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              product.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.getTextPrimary(isDark),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        product.barcode,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: AppColors.getTextSecondary(isDark),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.category,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.info,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${NumberFormat('#,##0.00').format(product.price)} ر.س',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextPrimary(isDark),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: _stockBadge(product.stock, isDark),
                    ),
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('تعديل ${product.name} - قريباً'),
                              backgroundColor: AppColors.info,
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit_rounded, size: 18),
                        color: AppColors.primary,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _tableHeader(String text, int flex, bool isDark) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.getTextSecondary(isDark),
        ),
      ),
    );
  }

  // ─── Mobile: Product Cards ─────────────────────────────────────

  Widget _buildProductCards(bool isDark, bool isMedium) {
    final products = _filteredProducts;
    return ListView.separated(
      padding: EdgeInsets.all(isMedium ? AlhaiSpacing.mdl : AlhaiSpacing.md),
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) {
        final product = products[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.getSurface(isDark),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.getBorder(isDark)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.inventory_2_outlined,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                    ),
                    const SizedBox(height: AlhaiSpacing.xxs),
                    Row(
                      children: [
                        Text(
                          product.barcode,
                          style: TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                            color: AppColors.getTextMuted(isDark),
                          ),
                        ),
                        const SizedBox(width: AlhaiSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.info.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            product.category,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppColors.info,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '${NumberFormat('#,##0.00').format(product.price)} ر.س',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const Spacer(),
                        _stockBadge(product.stock, isDark),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AlhaiSpacing.xs),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تعديل ${product.name} - قريباً'),
                      backgroundColor: AppColors.info,
                    ),
                  );
                },
                icon: const Icon(Icons.edit_rounded, size: 18),
                color: AppColors.primary,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _stockBadge(int stock, bool isDark) {
    final Color color;
    final String label;
    if (stock <= 0) {
      color = AppColors.error;
      label = 'نفذ';
    } else if (stock < 100) {
      color = AppColors.warning;
      label = 'منخفض ($stock)';
    } else {
      color = AppColors.success;
      label = '$stock';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.xs, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 64, color: AppColors.getTextMuted(isDark)),
          const SizedBox(height: AlhaiSpacing.md),
          Text(
            'لا توجد منتجات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          Text(
            'جرب تغيير معايير البحث',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getTextMuted(isDark),
            ),
          ),
        ],
      ),
    );
  }
}
