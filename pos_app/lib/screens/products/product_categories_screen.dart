import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';

/// شاشة إدارة فئات المنتجات
class ProductCategoriesScreen extends StatefulWidget {
  const ProductCategoriesScreen({super.key});

  @override
  State<ProductCategoriesScreen> createState() => _ProductCategoriesScreenState();
}

class _ProductCategoriesScreenState extends State<ProductCategoriesScreen> {
  final List<_Category> _categories = [
    _Category(id: '1', name: 'ألبان ومشتقاتها', icon: Icons.local_drink, color: Colors.blue, productCount: 45),
    _Category(id: '2', name: 'مواد غذائية', icon: Icons.restaurant, color: Colors.orange, productCount: 120),
    _Category(id: '3', name: 'مشروبات', icon: Icons.coffee, color: Colors.brown, productCount: 65),
    _Category(id: '4', name: 'حلويات وسكاكر', icon: Icons.cake, color: Colors.pink, productCount: 38),
    _Category(id: '5', name: 'منظفات', icon: Icons.cleaning_services, color: Colors.teal, productCount: 52),
    _Category(id: '6', name: 'عناية شخصية', icon: Icons.face, color: Colors.purple, productCount: 28),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
      body: ReorderableListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _categories.length,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) newIndex--;
            final item = _categories.removeAt(oldIndex);
            _categories.insert(newIndex, item);
          });
        },
        itemBuilder: (context, index) {
          final category = _categories[index];
          return Card(
            key: ValueKey(category.id),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(category.icon, color: category.color),
              ),
              title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text(l10n.productCountUnit(category.productCount)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _editCategory(category),
                  ),
                  ReorderableDragStartListener(
                    index: index,
                    child: const Icon(Icons.drag_handle, color: Colors.grey),
                  ),
                ],
              ),
              onTap: () => _showCategoryProducts(category),
            ),
          );
        },
      ),
    );
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
                              color: selectedIcon == icon ? selectedColor.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(icon, color: selectedIcon == icon ? selectedColor : Colors.grey),
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
                              border: selectedColor == color ? Border.all(color: Colors.black, width: 2) : null,
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
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  setState(() {
                    _categories.add(_Category(
                      id: 'new_${_categories.length}',
                      name: nameController.text,
                      icon: selectedIcon,
                      color: selectedColor,
                      productCount: 0,
                    ));
                  });
                }
                Navigator.pop(context);
              },
              child: Text(l10n.add),
            ),
          ],
        ),
      ),
    );
  }
  
  void _editCategory(_Category category) {
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
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                final index = _categories.indexOf(category);
                _categories[index] = _Category(
                  id: category.id,
                  name: nameController.text,
                  icon: category.icon,
                  color: category.color,
                  productCount: category.productCount,
                );
              });
              Navigator.pop(context);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
  
  void _deleteCategory(_Category category) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteCategory),
        content: Text(l10n.deleteCategoryMessage(category.name, category.productCount)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              setState(() => _categories.remove(category));
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
  
  void _showCategoryProducts(_Category category) {
    final l10n = AppLocalizations.of(context)!;
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
                      color: category.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(category.icon, color: category.color),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category.name, style: Theme.of(context).textTheme.titleMedium),
                      Text(l10n.productCountUnit(category.productCount)),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: 10,
                itemBuilder: (context, index) => ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.inventory_2, color: Colors.grey),
                  ),
                  title: Text(l10n.productNumber(index + 1)),
                  subtitle: Text(l10n.priceWithCurrency('${(index + 1) * 15}')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final int productCount;
  
  _Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.productCount,
  });
}
