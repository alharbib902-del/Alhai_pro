import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// Media library screen for managing product images with grid view,
/// filtering, search, and storage usage indicator.
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
  String _searchQuery = '';
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
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
          _error = 'No store selected';
        });
        return;
      }
      final products = await db.productsDao.getAllProducts(storeId);
      if (mounted) {
        setState(() {
          _productsWithImages = products
              .where((p) =>
                  p.imageThumbnail != null && p.imageThumbnail!.isNotEmpty)
              .toList();
          _productsWithoutImages = products
              .where(
                  (p) => p.imageThumbnail == null || p.imageThumbnail!.isEmpty)
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Error loading data: $e';
        });
      }
    }
  }

  List<ProductsTableData> get _displayProducts {
    List<ProductsTableData> base;
    switch (_filter) {
      case 'images':
        base = _productsWithImages;
        break;
      case 'no_images':
        base = _productsWithoutImages;
        break;
      default:
        base = [..._productsWithImages, ..._productsWithoutImages];
    }
    if (_searchQuery.isEmpty) return base;
    return base
        .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        AppHeader(
          title: l10n.mediaLibrary,
          onMenuTap: isWide ? null : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 0,
          userName: l10n.defaultUserName,
          userRole: l10n.branchManager,
          actions: [
            FilledButton.icon(
              onPressed: () => _showUploadDialog(context, isDark, l10n),
              icon: const Icon(Icons.cloud_upload, size: 18),
              label: Text(l10n.add),
            ),
          ],
        ),
        // Search and filter row
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AlhaiSpacing.md, vertical: AlhaiSpacing.xs),
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              // Search bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : AppColors.border.withValues(alpha: 0.3),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: (value) {
                  _searchDebounce?.cancel();
                  _searchDebounce =
                      Timer(const Duration(milliseconds: 300), () {
                    if (mounted) setState(() => _searchQuery = value);
                  });
                },
              ),
              const SizedBox(height: AlhaiSpacing.xs),
              // Filter buttons and storage indicator
              Row(
                children: [
                  Expanded(
                    child: SegmentedButton<String>(
                      segments: [
                        ButtonSegment(
                          value: 'all',
                          icon: const Icon(Icons.grid_view, size: 18),
                          label: Text(
                              '${l10n.all} (${_productsWithImages.length + _productsWithoutImages.length})'),
                        ),
                        ButtonSegment(
                          value: 'images',
                          icon: const Icon(Icons.image, size: 18),
                          label: Text('(${_productsWithImages.length})'),
                        ),
                        ButtonSegment(
                          value: 'no_images',
                          icon: const Icon(Icons.image_not_supported, size: 18),
                          label: Text('(${_productsWithoutImages.length})'),
                        ),
                      ],
                      selected: {_filter},
                      onSelectionChanged: (val) {
                        setState(() => _filter = val.first);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AlhaiSpacing.xs),
              // Storage usage indicator
              _buildStorageIndicator(isDark),
            ],
          ),
        ),
        Expanded(
          child: _buildBody(isDark, l10n),
        ),
      ],
    );
  }

  Widget _buildStorageIndicator(bool isDark) {
    final totalImages = _productsWithImages.length;
    final totalProducts =
        _productsWithImages.length + _productsWithoutImages.length;
    final usagePercent = totalProducts > 0 ? totalImages / totalProducts : 0.0;

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.sm),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : AppColors.border.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.storage,
              size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: AlhaiSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Images: $totalImages / $totalProducts products',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white70 : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.xxs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: usagePercent,
                    backgroundColor: Theme.of(context).dividerColor,
                    color:
                        usagePercent > 0.8 ? Colors.orange : AppColors.primary,
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AlhaiSpacing.xs),
          Text(
            '${(usagePercent * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(bool isDark, AppLocalizations l10n) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 64, color: AppColors.error.withValues(alpha: 0.7)),
            const SizedBox(height: AlhaiSpacing.md),
            Text(
              _error!,
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AlhaiSpacing.md),
            FilledButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    final displayProducts = _displayProducts;

    if (displayProducts.isEmpty) {
      return AppEmptyState(
        icon: Icons.photo_library_outlined,
        title: l10n.noData,
        description: l10n.addProductsToStart,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth > 900
            ? 5
            : (constraints.maxWidth > 600 ? 3 : 2);
        return GridView.builder(
          padding: const EdgeInsets.all(AlhaiSpacing.md),
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
    final hasImage =
        product.imageThumbnail != null && product.imageThumbnail!.isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image area
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: hasImage
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: product.imageThumbnail!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: Theme.of(context)
                                .dividerColor
                                .withValues(alpha: 0.3),
                            child: Icon(Icons.broken_image,
                                size: 40,
                                color: isDark
                                    ? Colors.white24
                                    : AppColors.textTertiary),
                          ),
                        ),
                        PositionedDirectional(
                          top: 4,
                          start: 4,
                          child: Material(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.54),
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Image management placeholder')),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(AlhaiSpacing.xxs),
                                child: Icon(Icons.edit,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onInverseSurface,
                                    size: 18),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Image upload placeholder')),
                        );
                      },
                      child: Container(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : AppColors.border.withValues(alpha: 0.3),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                size: 36,
                                color: isDark
                                    ? Colors.white24
                                    : AppColors.textTertiary),
                            const SizedBox(height: AlhaiSpacing.xxs),
                            Text(
                              'Add image',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? Colors.white38
                                      : AppColors.textTertiary),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
          // Product name
          Padding(
            padding: const EdgeInsets.all(AlhaiSpacing.xs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AlhaiSpacing.xxxs),
                Text(
                  product.price.toStringAsFixed(2),
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showUploadDialog(
      BuildContext context, bool isDark, AppLocalizations l10n) {
    final displayProducts = _productsWithoutImages;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.cloud_upload, color: AppColors.primary),
            const SizedBox(width: AlhaiSpacing.xs),
            Text(l10n.add),
          ],
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width > 600
                ? 400
                : MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          child: displayProducts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 48, color: Colors.green.shade300),
                      const SizedBox(height: AlhaiSpacing.sm),
                      const Text('All products have images',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select a product to add an image:',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: AlhaiSpacing.xs),
                    Expanded(
                      child: ListView.builder(
                        itemCount: displayProducts.length,
                        itemBuilder: (context, index) {
                          final product = displayProducts[index];
                          return ListTile(
                            leading: const Icon(Icons.inventory_2_outlined),
                            title: Text(product.name),
                            subtitle: Text(product.price.toStringAsFixed(2)),
                            trailing: const Icon(Icons.add_photo_alternate,
                                color: AppColors.primary),
                            onTap: () {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Image upload placeholder')),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ],
      ),
    );
  }
}
