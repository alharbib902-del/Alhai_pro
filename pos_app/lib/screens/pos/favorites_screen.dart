/// شاشة المنتجات المفضلة - Favorites Screen
///
/// تعرض المنتجات المفضلة للوصول السريع في POS
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/responsive/responsive_utils.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/app_empty_state.dart';

/// شاشة المنتجات المفضلة
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // قائمة المنتجات المفضلة (بيانات تجريبية)
  final List<FavoriteProduct> _favorites = [
    FavoriteProduct(
      id: '1',
      name: 'حليب المراعي كامل الدسم',
      price: 7.50,
      imageUrl: null,
      barcode: '6281007012345',
      stock: 45,
    ),
    FavoriteProduct(
      id: '2',
      name: 'خبز توست لوزين',
      price: 6.00,
      imageUrl: null,
      barcode: '6281007054321',
      stock: 30,
    ),
    FavoriteProduct(
      id: '3',
      name: 'مياه نوفا 1.5 لتر',
      price: 1.00,
      imageUrl: null,
      barcode: '6281007098765',
      stock: 120,
    ),
    FavoriteProduct(
      id: '4',
      name: 'بيض بلدي 30 حبة',
      price: 22.00,
      imageUrl: null,
      barcode: '6281007011111',
      stock: 15,
    ),
    FavoriteProduct(
      id: '5',
      name: 'زيت عافية 1.5 لتر',
      price: 28.50,
      imageUrl: null,
      barcode: '6281007022222',
      stock: 25,
    ),
    FavoriteProduct(
      id: '6',
      name: 'أرز بسمتي أبو كاس 5 كيلو',
      price: 65.00,
      imageUrl: null,
      barcode: '6281007033333',
      stock: 40,
    ),
  ];

  bool _isEditMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المفضلة'),
        centerTitle: true,
        actions: [
          if (_favorites.isNotEmpty)
            IconButton(
              onPressed: () {
                setState(() {
                  _isEditMode = !_isEditMode;
                });
              },
              icon: Icon(_isEditMode ? Icons.check : Icons.edit_outlined),
              tooltip: _isEditMode ? 'تم' : 'تعديل',
            ),
        ],
      ),
      body: _favorites.isEmpty
          ? const AppEmptyState(
              icon: Icons.favorite_border,
              title: 'لا توجد منتجات مفضلة',
              description: 'أضف منتجات للمفضلة من شاشة المنتجات',
            )
          : Column(
              children: [
                // Header info
                Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  color: AppColors.primarySurface,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Text(
                        'اضغط على المنتج لإضافته للسلة',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(AppSizes.md),
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: getResponsiveGridColumns(context, mobile: 2, desktop: 4),
                      crossAxisSpacing: AppSizes.md,
                      mainAxisSpacing: AppSizes.md,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _favorites.length,
                    itemBuilder: (context, index) {
                      return _buildProductCard(_favorites[index], index);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildProductCard(FavoriteProduct product, int index) {
    final bool isLowStock = product.stock <= 5;

    return Stack(
      children: [
        Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
          child: InkWell(
            onTap: _isEditMode ? null : () => _addToCart(product),
            onLongPress: () => _showProductOptions(product, index),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image
                Expanded(
                  flex: 3,
                  child: Container(
                    color: AppColors.grey100,
                    child: Stack(
                      children: [
                        const Center(
                          child: Icon(
                            Icons.inventory_2_outlined,
                            size: 40,
                            color: AppColors.grey400,
                          ),
                        ),
                        // Stock badge
                        if (isLowStock)
                          Positioned(
                            top: AppSizes.xs,
                            right: AppSizes.xs,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusSm),
                              ),
                              child: Text(
                                '${product.stock}',
                                style: AppTypography.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Info
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product.name,
                          style: AppTypography.labelMedium.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${product.price.toStringAsFixed(2)} ر.س',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Edit mode overlay
        if (_isEditMode)
          Positioned.fill(
            child: Material(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              child: InkWell(
                onTap: () => _removeFromFavorites(index),
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                child: const Center(
                  child: Icon(
                    Icons.remove_circle,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _addToCart(FavoriteProduct product) {
    HapticFeedback.lightImpact();
    // TODO: Add to cart
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تمت إضافة ${product.name} للسلة'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showProductOptions(FavoriteProduct product, int index) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            Text(
              product.name,
              style: AppTypography.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.lg),
            ListTile(
              leading: const Icon(Icons.add_shopping_cart),
              title: const Text('إضافة للسلة'),
              onTap: () {
                Navigator.pop(context);
                _addToCart(product);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text(
                'إزالة من المفضلة',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () {
                Navigator.pop(context);
                _removeFromFavorites(index);
              },
            ),
            const SizedBox(height: AppSizes.lg),
          ],
        ),
      ),
    );
  }

  void _removeFromFavorites(int index) {
    final product = _favorites[index];
    setState(() {
      _favorites.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تمت إزالة ${product.name} من المفضلة'),
        action: SnackBarAction(
          label: 'تراجع',
          onPressed: () {
            setState(() {
              _favorites.insert(index, product);
            });
          },
        ),
      ),
    );
  }
}

/// نموذج المنتج المفضل
class FavoriteProduct {
  final String id;
  final String name;
  final double price;
  final String? imageUrl;
  final String barcode;
  final int stock;

  FavoriteProduct({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    required this.barcode,
    required this.stock,
  });
}
