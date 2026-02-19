import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../providers/products_providers.dart';
import '../../providers/sync_providers.dart';

class MediaLibraryScreen extends ConsumerStatefulWidget {
  const MediaLibraryScreen({super.key});

  @override
  ConsumerState<MediaLibraryScreen> createState() => _MediaLibraryScreenState();
}

class _MediaLibraryScreenState extends ConsumerState<MediaLibraryScreen> {
  bool _isLoading = true;
  String? _error;
  List<ProductsTableData> _productsWithImages = [];
  List<ProductsTableData> _productsWithoutImages = [];
  String _filter = 'all'; // all, images, no_images

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final db = getIt<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) {
        setState(() {
          _isLoading = false;
          _error = 'لم يتم تحديد المتجر';
        });
        return;
      }
      final products = await db.productsDao.getAllProducts(storeId);
      if (mounted) {
        setState(() {
          _productsWithImages = products.where((p) => p.imageThumbnail != null && p.imageThumbnail!.isNotEmpty).toList();
          _productsWithoutImages = products.where((p) => p.imageThumbnail == null || p.imageThumbnail!.isEmpty).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'حدث خطأ أثناء تحميل البيانات: $e';
        });
      }
    }
  }

  List<ProductsTableData> get _displayProducts {
    switch (_filter) {
      case 'images':
        return _productsWithImages;
      case 'no_images':
        return _productsWithoutImages;
      default:
        return [..._productsWithImages, ..._productsWithoutImages];
    }
  }

  Future<void> _pickImageForProduct(ProductsTableData product) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (pickedFile == null) return;

      final newUrl = pickedFile.path;
      final db = getIt<AppDatabase>();

      await (db.update(db.productsTable)..where((p) => p.id.equals(product.id)))
          .write(ProductsTableCompanion(
        imageThumbnail: Value(newUrl),
        updatedAt: Value(DateTime.now()),
      ));

      ref.read(syncServiceProvider).enqueueUpdate(
        tableName: 'products',
        recordId: product.id,
        changes: {
          'id': product.id,
          'imageThumbnail': newUrl,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث صورة المنتج بنجاح')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء رفع الصورة: $e')),
        );
      }
    }
  }

  Future<void> _removeImageFromProduct(ProductsTableData product) async {
    try {
      final db = getIt<AppDatabase>();

      await (db.update(db.productsTable)..where((p) => p.id.equals(product.id)))
          .write(ProductsTableCompanion(
        imageThumbnail: const Value(null),
        updatedAt: Value(DateTime.now()),
      ));

      ref.read(syncServiceProvider).enqueueUpdate(
        tableName: 'products',
        recordId: product.id,
        changes: {
          'id': product.id,
          'imageThumbnail': null,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف صورة المنتج')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء حذف الصورة: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUploadDialog(context, isDark),
        icon: const Icon(Icons.cloud_upload),
        label: const Text('رفع صور'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
              border: Border(bottom: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                if (!isWide) IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(context).openDrawer()),
                const Icon(Icons.photo_library, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Text('مكتبة الصور', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                const Spacer(),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'all',
                      icon: const Icon(Icons.grid_view, size: 18),
                      label: Text('الكل (${_productsWithImages.length + _productsWithoutImages.length})'),
                    ),
                    ButtonSegment(
                      value: 'images',
                      icon: const Icon(Icons.image, size: 18),
                      label: Text('بصور (${_productsWithImages.length})'),
                    ),
                    ButtonSegment(
                      value: 'no_images',
                      icon: const Icon(Icons.image_not_supported, size: 18),
                      label: Text('بدون (${_productsWithoutImages.length})'),
                    ),
                  ],
                  selected: {_filter},
                  onSelectionChanged: (val) {
                    setState(() => _filter = val.first);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildBody(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(fontSize: 16, color: isDark ? Colors.white54 : Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    final displayProducts = _displayProducts;

    if (displayProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.cloud_upload_outlined, size: 60, color: isDark ? Colors.white24 : Colors.grey.shade300),
            ),
            const SizedBox(height: 20),
            Text(
              _filter == 'images'
                  ? 'لا توجد منتجات بصور'
                  : _filter == 'no_images'
                      ? 'جميع المنتجات لديها صور'
                      : 'لا توجد منتجات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black54),
            ),
            const SizedBox(height: 8),
            Text(
              'أضف منتجات أولاً ثم ارفع صوراً لها',
              style: TextStyle(fontSize: 13, color: isDark ? Colors.white38 : Colors.grey),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth > 900 ? 5 : (constraints.maxWidth > 600 ? 3 : 2);
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: displayProducts.length,
          itemBuilder: (context, index) {
            final product = displayProducts[index];
            return _buildMediaCard(product, isDark);
          },
        );
      },
    );
  }

  Widget _buildMediaCard(ProductsTableData product, bool isDark) {
    final hasImage = product.imageThumbnail != null && product.imageThumbnail!.isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image area
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: hasImage
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          product.imageThumbnail!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                            child: Icon(Icons.broken_image, size: 40, color: isDark ? Colors.white24 : Colors.grey.shade300),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Material(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => _removeImageFromProduct(product),
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(Icons.delete, color: Colors.white, size: 18),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : InkWell(
                      onTap: () => _pickImageForProduct(product),
                      child: Container(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined, size: 36, color: isDark ? Colors.white24 : Colors.grey.shade300),
                            const SizedBox(height: 4),
                            Text(
                              'إضافة صورة',
                              style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
          // Product name
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${product.price.toStringAsFixed(2)} ر.س',
                  style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showUploadDialog(BuildContext context, bool isDark) {
    // Show a dialog to pick a product then pick an image for it
    final displayProducts = _productsWithoutImages;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(children: [Icon(Icons.cloud_upload, color: AppColors.primary), SizedBox(width: 8), Text('رفع صور جديدة')]),
        content: SizedBox(
          width: 400,
          height: 300,
          child: displayProducts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 48, color: Colors.green.shade300),
                      const SizedBox(height: 12),
                      const Text('جميع المنتجات لديها صور', style: TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('اختر منتج لإضافة صورة له:', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: displayProducts.length,
                        itemBuilder: (context, index) {
                          final product = displayProducts[index];
                          return ListTile(
                            leading: const Icon(Icons.inventory_2_outlined),
                            title: Text(product.name),
                            subtitle: Text('${product.price.toStringAsFixed(2)} ر.س'),
                            trailing: const Icon(Icons.add_photo_alternate, color: AppColors.primary),
                            onTap: () {
                              Navigator.pop(ctx);
                              _pickImageForProduct(product);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
        ],
      ),
    );
  }
}
