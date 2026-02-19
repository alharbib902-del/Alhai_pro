/// شاشة المنتجات المفضلة - Favorites Screen
///
/// تعرض المنتجات المفضلة من قاعدة البيانات المحلية (DB-backed)
/// بدلاً من القائمة المضمنة في الكود، مع دعم:
/// - إضافة المنتج للسلة
/// - إزالة من المفضلة
/// - حالات التحميل والخطأ والفراغ
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_core/alhai_core.dart' hide CartItem;
import '../../core/responsive/responsive_utils.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/cart_providers.dart';
import '../../providers/favorites_providers.dart';
import '../../widgets/common/app_empty_state.dart';

/// شاشة المنتجات المفضلة
class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  bool _isEditMode = false;

  @override
  Widget build(BuildContext context) {
    final favoritesAsync = ref.watch(favoritesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المفضلة'),
        centerTitle: true,
        actions: [
          favoritesAsync.maybeWhen(
            data: (favorites) => favorites.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        _isEditMode = !_isEditMode;
                      });
                    },
                    icon:
                        Icon(_isEditMode ? Icons.check : Icons.edit_outlined),
                    tooltip: _isEditMode ? 'تم' : 'تعديل',
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: favoritesAsync.when(
        // حالة التحميل
        loading: () => const Center(child: CircularProgressIndicator()),
        // حالة الخطأ
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: AppSizes.md),
              const Text(
                'خطأ في تحميل المفضلة',
                style: AppTypography.titleMedium,
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                error.toString(),
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.lg),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(favoritesListProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
        // حالة البيانات
        data: (favorites) => favorites.isEmpty
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
                        crossAxisCount: getResponsiveGridColumns(context,
                            mobile: 2, desktop: 4),
                        crossAxisSpacing: AppSizes.md,
                        mainAxisSpacing: AppSizes.md,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: favorites.length,
                      itemBuilder: (context, index) {
                        return _buildProductCard(favorites[index], index);
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildProductCard(FavoriteProductData favoriteData, int index) {
    final bool isLowStock = favoriteData.stock <= 5;

    return Stack(
      children: [
        Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
          child: InkWell(
            onTap: _isEditMode
                ? null
                : () => _addToCart(favoriteData),
            onLongPress: () => _showProductOptions(favoriteData, index),
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
                          PositionedDirectional(
                            top: AppSizes.xs,
                            end: AppSizes.xs,
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
                                '${favoriteData.stock}',
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
                          favoriteData.name,
                          style: AppTypography.labelMedium.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${favoriteData.price.toStringAsFixed(2)} ر.س',
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
                onTap: () => _removeFromFavorites(favoriteData, index),
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

  /// تحويل بيانات المنتج من الجدول إلى نموذج Product للإضافة للسلة
  Product _toProduct(FavoriteProductData data) {
    return Product(
      id: data.product.id,
      storeId: data.product.storeId,
      name: data.product.name,
      sku: data.product.sku,
      barcode: data.product.barcode,
      price: data.product.price,
      costPrice: data.product.costPrice,
      stockQty: data.product.stockQty,
      minQty: data.product.minQty,
      unit: data.product.unit,
      description: data.product.description,
      imageThumbnail: data.product.imageThumbnail,
      imageMedium: data.product.imageMedium,
      imageLarge: data.product.imageLarge,
      imageHash: data.product.imageHash,
      categoryId: data.product.categoryId,
      isActive: data.product.isActive,
      trackInventory: data.product.trackInventory,
      createdAt: data.product.createdAt,
      updatedAt: data.product.updatedAt,
    );
  }

  void _addToCart(FavoriteProductData favoriteData) {
    HapticFeedback.lightImpact();

    // إضافة المنتج للسلة
    final product = _toProduct(favoriteData);
    ref.read(cartStateProvider.notifier).addProduct(product);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تمت إضافة ${favoriteData.name} للسلة'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showProductOptions(FavoriteProductData favoriteData, int index) {
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
              favoriteData.name,
              style: AppTypography.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.lg),
            ListTile(
              leading: const Icon(Icons.add_shopping_cart),
              title: const Text('إضافة للسلة'),
              onTap: () {
                Navigator.pop(context);
                _addToCart(favoriteData);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text(
                'إزالة من المفضلة',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () {
                Navigator.pop(context);
                _removeFromFavorites(favoriteData, index);
              },
            ),
            const SizedBox(height: AppSizes.lg),
          ],
        ),
      ),
    );
  }

  void _removeFromFavorites(FavoriteProductData favoriteData, int index) async {
    // حذف من قاعدة البيانات
    await removeFavoriteById(ref, favoriteData.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تمت إزالة ${favoriteData.name} من المفضلة'),
        action: SnackBarAction(
          label: 'تراجع',
          onPressed: () async {
            // إعادة الإضافة عند التراجع
            await reAddFavorite(ref, favoriteData);
          },
        ),
      ),
    );
  }
}
