import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:alhai_core/alhai_core.dart';

class CategoryChips extends StatelessWidget {
  final List<Category> categories;
  final String? selectedId;
  final ValueChanged<String?> onSelected;

  const CategoryChips({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
            horizontal: AlhaiSpacing.sm, vertical: 6),
        itemCount: categories.length + 1, // +1 for "All"
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsetsDirectional.only(end: AlhaiSpacing.xs),
              child: FilterChip(
                label: const Text('الكل'),
                selected: selectedId == null,
                onSelected: (_) => onSelected(null),
              ),
            );
          }

          final category = categories[index - 1];
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: FilterChip(
              label: Text(category.name),
              selected: selectedId == category.id,
              onSelected: (_) => onSelected(
                selectedId == category.id ? null : category.id,
              ),
            ),
          );
        },
      ),
    );
  }
}
