import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/products_providers.dart';
import '../../providers/sync_providers.dart';

const _uuid = Uuid();

/// مزود الفئات من قاعدة البيانات
final _categoriesDbProvider = FutureProvider.autoDispose<List<CategoriesTableData>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];
  final db = getIt<AppDatabase>();
  return db.categoriesDao.getAllCategories(storeId);
});

/// شاشة إدارة فئات المنتجات
class ProductCategoriesScreen extends ConsumerStatefulWidget {
  const ProductCategoriesScreen({super.key});

  @override
  ConsumerState<ProductCategoriesScreen> createState() => _ProductCategoriesScreenState();
}

class _ProductCategoriesScreenState extends ConsumerState<ProductCategoriesScreen> {
  /// خريطة عدد المنتجات لكل فئة
  Map<String, int> _productCounts = {};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categoriesAsync = ref.watch(_categoriesDbProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.categories),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCategory,
        icon: const Icon(Icons.add),
        label: Text(l10n.newCategory),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text('حدث خطأ أثناء تحميل الفئات', style: Theme.of(context).textTheme.titleMedium), // TODO: i18n
              const SizedBox(height: 8),
              Text(error.toString(), style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => ref.invalidate(_categoriesDbProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'), // TODO: i18n
              ),
            ],
          ),
        ),
        data: (categories) {
          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category_outlined, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text('لا توجد فئات', style: Theme.of(context).textTheme.titleMedium), // TODO: i18n
                  const SizedBox(height: 8),
                  Text('اضغط على + لإضافة فئة جديدة', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)), // TODO: i18n
                ],
              ),
            );
          }

          // تحميل عدد المنتجات لكل فئة
          _loadProductCounts(categories);

          return ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) newIndex--;
              _reorderCategories(categories, oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final category = categories[index];
              final color = _parseColor(category.color);
              final icon = _parseIcon(category.icon);
              final productCount = _productCounts[category.id] ?? 0;

              return Card(
                key: ValueKey(category.id),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color),
                  ),
                  title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text(l10n.productCountUnit(productCount)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _editCategory(category),
                      ),
                      ReorderableDragStartListener(
                        index: index,
                        child: Icon(Icons.drag_handle, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  onTap: () => _showCategoryProducts(category),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// تحميل عدد المنتجات لكل فئة
  Future<void> _loadProductCounts(List<CategoriesTableData> categories) async {
    final storeId = ref.read(currentStoreIdProvider);
    if (storeId == null) return;
    final db = getIt<AppDatabase>();
    final counts = <String, int>{};
    for (final cat in categories) {
      final products = await db.productsDao.getProductsByCategory(cat.id, storeId);
      counts[cat.id] = products.length;
    }
    if (mounted && counts.toString() != _productCounts.toString()) {
      setState(() {
        _productCounts = counts;
      });
    }
  }

  /// إعادة ترتيب الفئات
  Future<void> _reorderCategories(List<CategoriesTableData> categories, int oldIndex, int newIndex) async {
    final db = getIt<AppDatabase>();
    final item = categories[oldIndex];

    // تحديث الترتيب في قاعدة البيانات
    final updatedItem = item.copyWith(sortOrder: newIndex);
    await db.categoriesDao.updateCategory(updatedItem);

    // إعادة ترتيب العناصر الأخرى
    final reordered = List<CategoriesTableData>.from(categories);
    reordered.removeAt(oldIndex);
    reordered.insert(newIndex, updatedItem);
    for (int i = 0; i < reordered.length; i++) {
      if (reordered[i].sortOrder != i) {
        final updated = reordered[i].copyWith(sortOrder: i);
        await db.categoriesDao.updateCategory(updated);
      }
    }

    // مزامنة
    ref.read(syncServiceProvider).enqueueUpdate(
      tableName: 'categories',
      recordId: item.id,
      changes: {'sort_order': newIndex},
    );

    ref.invalidate(_categoriesDbProvider);
  }

  /// تحويل لون من نص لـ Color
  Color _parseColor(String? colorStr) {
    if (colorStr == null || colorStr.isEmpty) return Colors.blue;
    try {
      if (colorStr.startsWith('#')) {
        return Color(int.parse(colorStr.substring(1), radix: 16) + 0xFF000000);
      }
      if (colorStr.startsWith('0x')) {
        return Color(int.parse(colorStr));
      }
    } catch (_) {}
    // ألوان افتراضية معروفة
    switch (colorStr.toLowerCase()) {
      case 'blue': return Colors.blue;
      case 'orange': return Colors.orange;
      case 'brown': return Colors.brown;
      case 'pink': return Colors.pink;
      case 'teal': return Colors.teal;
      case 'purple': return Colors.purple;
      case 'green': return Colors.green;
      case 'red': return Colors.red;
      default: return Colors.blue;
    }
  }

  /// تحويل اسم أيقونة لـ IconData
  IconData _parseIcon(String? iconStr) {
    if (iconStr == null || iconStr.isEmpty) return Icons.category;
    switch (iconStr) {
      case 'local_drink': return Icons.local_drink;
      case 'restaurant': return Icons.restaurant;
      case 'coffee': return Icons.coffee;
      case 'cake': return Icons.cake;
      case 'cleaning_services': return Icons.cleaning_services;
      case 'face': return Icons.face;
      case 'shopping_bag': return Icons.shopping_bag;
      case 'category': return Icons.category;
      default: return Icons.category;
    }
  }

  /// تحويل Color لنص
  String _colorToString(Color color) {
    if (color == Colors.blue) return 'blue';
    if (color == Colors.orange) return 'orange';
    if (color == Colors.green) return 'green';
    if (color == Colors.purple) return 'purple';
    if (color == Colors.pink) return 'pink';
    if (color == Colors.teal) return 'teal';
    return 'blue';
  }

  /// تحويل IconData لنص
  String _iconToString(IconData icon) {
    if (icon == Icons.local_drink) return 'local_drink';
    if (icon == Icons.restaurant) return 'restaurant';
    if (icon == Icons.coffee) return 'coffee';
    if (icon == Icons.cake) return 'cake';
    if (icon == Icons.shopping_bag) return 'shopping_bag';
    return 'category';
  }

  void _addCategory() {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    IconData selectedIcon = Icons.category;
    Color selectedColor = Colors.blue;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.newCategory),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l10n.categoryName,
                  prefixIcon: const Icon(Icons.label),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(l10n.iconLabel),
                  const SizedBox(width: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final icon in [Icons.local_drink, Icons.restaurant, Icons.coffee, Icons.cake, Icons.shopping_bag])
                        GestureDetector(
                          onTap: () => setDialogState(() => selectedIcon = icon),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: selectedIcon == icon ? selectedColor.withValues(alpha: 0.2) : Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(icon, color: selectedIcon == icon ? selectedColor : Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(l10n.colorLabel),
                  const SizedBox(width: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final color in [Colors.blue, Colors.orange, Colors.green, Colors.purple, Colors.pink, Colors.teal])
                        GestureDetector(
                          onTap: () => setDialogState(() => selectedColor = color),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: selectedColor == color ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 2) : null,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  final storeId = ref.read(currentStoreIdProvider);
                  if (storeId == null) return;
                  final db = getIt<AppDatabase>();
                  final newId = _uuid.v4();
                  final now = DateTime.now();

                  final companion = CategoriesTableCompanion.insert(
                    id: newId,
                    storeId: storeId,
                    name: nameController.text,
                    icon: Value(_iconToString(selectedIcon)),
                    color: Value(_colorToString(selectedColor)),
                    sortOrder: const Value(999),
                    isActive: const Value(true),
                    createdAt: now,
                    updatedAt: Value(now),
                  );

                  await db.categoriesDao.insertCategory(companion);

                  // مزامنة
                  ref.read(syncServiceProvider).enqueueCreate(
                    tableName: 'categories',
                    recordId: newId,
                    data: {
                      'id': newId,
                      'store_id': storeId,
                      'name': nameController.text,
                      'icon': _iconToString(selectedIcon),
                      'color': _colorToString(selectedColor),
                      'sort_order': 999,
                      'is_active': true,
                      'created_at': now.toIso8601String(),
                    },
                  );

                  ref.invalidate(_categoriesDbProvider);
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: Text(l10n.add),
            ),
          ],
        ),
      ),
    );
  }

  void _editCategory(CategoriesTableData category) {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: category.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.editCategory),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: l10n.categoryName,
                prefixIcon: const Icon(Icons.label),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCategory(category);
            },
            child: Text(l10n.delete, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final db = getIt<AppDatabase>();
              final updated = category.copyWith(
                name: nameController.text,
                updatedAt: Value(DateTime.now()),
              );
              await db.categoriesDao.updateCategory(updated);

              // مزامنة
              ref.read(syncServiceProvider).enqueueUpdate(
                tableName: 'categories',
                recordId: category.id,
                changes: {
                  'name': nameController.text,
                  'updated_at': DateTime.now().toIso8601String(),
                },
              );

              ref.invalidate(_categoriesDbProvider);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(CategoriesTableData category) {
    final l10n = AppLocalizations.of(context)!;
    final productCount = _productCounts[category.id] ?? 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteCategory),
        content: Text(l10n.deleteCategoryMessage(category.name, productCount)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final db = getIt<AppDatabase>();
              await db.categoriesDao.deleteCategory(category.id);

              // مزامنة
              ref.read(syncServiceProvider).enqueueDelete(
                tableName: 'categories',
                recordId: category.id,
              );

              ref.invalidate(_categoriesDbProvider);
              if (context.mounted) Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _showCategoryProducts(CategoriesTableData category) {
    final l10n = AppLocalizations.of(context)!;
    final color = _parseColor(category.color);
    final icon = _parseIcon(category.icon);
    final storeId = ref.read(currentStoreIdProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category.name, style: Theme.of(context).textTheme.titleMedium),
                      Text(l10n.productCountUnit(_productCounts[category.id] ?? 0)),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: FutureBuilder<List<ProductsTableData>>(
                future: storeId != null
                    ? getIt<AppDatabase>().productsDao.getProductsByCategory(category.id, storeId)
                    : Future.value([]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('حدث خطأ: ${snapshot.error}')); // TODO: i18n
                  }
                  final products = snapshot.data ?? [];
                  if (products.isEmpty) {
                    return const Center(child: Text('لا توجد منتجات في هذه الفئة')); // TODO: i18n
                  }
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.inventory_2, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                        title: Text(product.name),
                        subtitle: Text(l10n.priceWithCurrency(product.price.toStringAsFixed(2))),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
