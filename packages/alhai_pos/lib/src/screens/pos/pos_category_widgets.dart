import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

// =============================================================================
// CATEGORY COLUMN - Vertical (Desktop Only)
// =============================================================================

class PosCategoryColumn extends StatelessWidget {
  final AsyncValue<List<Category>> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onCategorySelected;

  const PosCategoryColumn({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  IconData _getCategoryIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('مشروبات ساخنة') ||
        lower.contains('hot') ||
        lower.contains('قهوة') ||
        lower.contains('coffee')) {
      return Icons.local_cafe_rounded;
    }
    if (lower.contains('مشروبات باردة') ||
        lower.contains('cold') ||
        lower.contains('عصير') ||
        lower.contains('juice')) {
      return Icons.local_drink_rounded;
    }
    if (lower.contains('مشروبات') ||
        lower.contains('drink') ||
        lower.contains('beverage')) {
      return Icons.local_drink_rounded;
    }
    if (lower.contains('حلويات') ||
        lower.contains('sweet') ||
        lower.contains('سناك') ||
        lower.contains('snack')) {
      return Icons.icecream_rounded;
    }
    if (lower.contains('فواكه') || lower.contains('fruit')) {
      return Icons.apple;
    }
    if (lower.contains('خضروات') || lower.contains('vegetable')) {
      return Icons.eco_rounded;
    }
    if (lower.contains('ألبان') ||
        lower.contains('dairy') ||
        lower.contains('milk')) {
      return Icons.water_drop_rounded;
    }
    if (lower.contains('لحوم') || lower.contains('meat')) {
      return Icons.restaurant_rounded;
    }
    if (lower.contains('مخبوزات') ||
        lower.contains('bakery') ||
        lower.contains('خبز')) {
      return Icons.bakery_dining_rounded;
    }
    if (lower.contains('تنظيف') || lower.contains('cleaning')) {
      return Icons.cleaning_services_rounded;
    }
    if (lower.contains('حبوب') ||
        lower.contains('grain') ||
        lower.contains('بقول')) {
      return Icons.grain_rounded;
    }
    if (lower.contains('مجمد') || lower.contains('frozen')) {
      return Icons.ac_unit_rounded;
    }
    return Icons.category_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: BorderDirectional(
          start: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
        ),
      ),
      child: categories.when(
        data: (cats) {
          final allItems = [
            PosCategoryColumnItem(
              icon: Icons.grid_view_rounded,
              label: l10n.all,
              isActive: selectedCategoryId == null,
              onTap: () => onCategorySelected(null),
              color: AppColors.primary,
            ),
            ...cats.map(
              (cat) => PosCategoryColumnItem(
                icon: _getCategoryIcon(cat.name),
                label: cat.name,
                isActive: selectedCategoryId == cat.id,
                onTap: () => onCategorySelected(cat.id),
                color: AppColors.primary,
              ),
            ),
          ];

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xs),
            itemCount: allItems.length,
            itemBuilder: (context, index) => allItems[index],
          );
        },
        loading: () => const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        error: (e, _) => const Center(
          child: Icon(Icons.error_outline, color: AppColors.error, size: 20),
        ),
      ),
    );
  }
}

// =============================================================================
// CATEGORY COLUMN ITEM
// =============================================================================

class PosCategoryColumnItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color color;

  const PosCategoryColumnItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: AlhaiDurations.standard,
            padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xs),
            decoration: BoxDecoration(
              color: isActive
                  ? color.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: isActive
                  ? Border.all(color: color.withValues(alpha: 0.4), width: 1.5)
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isActive
                        ? color.withValues(alpha: 0.2)
                        : isDark
                        ? colorScheme.surfaceContainerHigh.withValues(
                            alpha: 0.5,
                          )
                        : colorScheme.surfaceContainerLow,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: isActive
                        ? color
                        : isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.xxs),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive
                        ? color
                        : isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// CATEGORY BAR - Pill Style (Mobile Only)
// =============================================================================

class PosCategoryBar extends StatelessWidget {
  final AsyncValue<List<Category>> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onCategorySelected;

  const PosCategoryBar({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  IconData _getCategoryIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('مشروبات ساخنة') ||
        lower.contains('hot') ||
        lower.contains('قهوة') ||
        lower.contains('coffee')) {
      return Icons.local_cafe_rounded;
    }
    if (lower.contains('مشروبات باردة') ||
        lower.contains('cold') ||
        lower.contains('عصير') ||
        lower.contains('juice')) {
      return Icons.local_drink_rounded;
    }
    if (lower.contains('حلويات') ||
        lower.contains('sweet') ||
        lower.contains('كيك') ||
        lower.contains('cake')) {
      return Icons.cake_rounded;
    }
    if (lower.contains('وجبات') ||
        lower.contains('snack') ||
        lower.contains('meal') ||
        lower.contains('burger')) {
      return Icons.fastfood_rounded;
    }
    if (lower.contains('فواكه') || lower.contains('fruit')) {
      return Icons.apple;
    }
    if (lower.contains('خضروات') || lower.contains('vegetable')) {
      return Icons.eco_rounded;
    }
    if (lower.contains('ألبان') ||
        lower.contains('dairy') ||
        lower.contains('milk')) {
      return Icons.water_drop_rounded;
    }
    if (lower.contains('لحوم') || lower.contains('meat')) {
      return Icons.restaurant_rounded;
    }
    if (lower.contains('مخبوزات') ||
        lower.contains('bakery') ||
        lower.contains('خبز')) {
      return Icons.bakery_dining_rounded;
    }
    if (lower.contains('تنظيف') || lower.contains('cleaning')) {
      return Icons.cleaning_services_rounded;
    }
    return Icons.category_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: categories.when(
        data: (cats) => ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.xs),
          children: [
            PosCategoryPill(
              icon: Icons.grid_view_rounded,
              label: l10n.all,
              isActive: selectedCategoryId == null,
              onTap: () => onCategorySelected(null),
            ),
            ...cats.map(
              (cat) => PosCategoryPill(
                icon: _getCategoryIcon(cat.name),
                label: cat.name,
                isActive: selectedCategoryId == cat.id,
                onTap: () => onCategorySelected(cat.id),
              ),
            ),
          ],
        ),
        loading: () => const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        error: (e, _) => Center(
          child: Text(
            '${l10n.error}: $e',
            style: const TextStyle(color: AppColors.error, fontSize: 12),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// CATEGORY PILL
// =============================================================================

class PosCategoryPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const PosCategoryPill({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsetsDirectional.only(end: AlhaiSpacing.xs),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: AnimatedContainer(
            duration: AlhaiDurations.standard,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary
                  : isDark
                  ? AppColors.surfaceVariantDark
                  : colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: isActive
                  ? null
                  : Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : colorScheme.outlineVariant,
                      width: 0.5,
                    ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.white.withValues(alpha: 0.25)
                        : isDark
                        ? colorScheme.surfaceContainerHigh.withValues(
                            alpha: 0.3,
                          )
                        : colorScheme.surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 13,
                    color: isActive
                        ? colorScheme.onPrimary
                        : isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive
                        ? colorScheme.onPrimary
                        : isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
