import 'dart:math' show min;

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

// ============================================================================
// Provider - fetches CategoriesTableData directly from DAO
// ============================================================================

final _adminCategoriesProvider =
    FutureProvider.autoDispose<List<CategoriesTableData>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider) ?? kDefaultStoreId;
  final dao = getIt<AppDatabase>().categoriesDao;
  return dao.getAllCategories(storeId);
});

// ============================================================================
// Predefined Colors and Icons
// ============================================================================

const List<Color> _kCategoryColors = [
  Color(0xFF3B82F6), // Blue
  Color(0xFF10B981), // Green
  Color(0xFFF59E0B), // Amber
  Color(0xFFEF4444), // Red
  Color(0xFF8B5CF6), // Purple
  Color(0xFFEC4899), // Pink
  Color(0xFF14B8A6), // Teal
  Color(0xFFF97316), // Orange
  Color(0xFF6366F1), // Indigo
  Color(0xFF64748B), // Slate
];

const List<IconData> _kCategoryIcons = [
  Icons.local_drink_rounded,
  Icons.restaurant_rounded,
  Icons.coffee_rounded,
  Icons.cake_rounded,
  Icons.cleaning_services_rounded,
  Icons.face_rounded,
  Icons.shopping_bag_rounded,
  Icons.kitchen_rounded,
  Icons.icecream_rounded,
  Icons.category_rounded,
];

Color _parseColor(String? hex) {
  if (hex == null || hex.isEmpty) return _kCategoryColors[0];
  try {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  } catch (_) {
    return _kCategoryColors[0];
  }
}

String _colorToHex(Color color) {
  return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
}

IconData _parseIcon(String? iconStr) {
  if (iconStr == null || iconStr.isEmpty) return _kCategoryIcons.last;
  try {
    final code = int.parse(iconStr);
    return IconData(code, fontFamily: 'MaterialIcons');
  } catch (_) {
    return _kCategoryIcons.last;
  }
}

String _iconToString(IconData icon) {
  return icon.codePoint.toString();
}

// ============================================================================
// Categories Screen
// ============================================================================

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  String? _selectedCategoryId;
  bool _isCreating = false;
  String _searchQuery = '';

  // Cached parsed colors/icons per category id to avoid re-parsing on every build
  final Map<String, Color> _colorCache = {};
  final Map<String, IconData> _iconCache = {};

  // Form
  final _formKey = GlobalKey<FormState>();
  final _nameArController = TextEditingController();
  final _nameEnController = TextEditingController();
  final _sortOrderController = TextEditingController(text: '0');
  Color _selectedColor = _kCategoryColors[0];
  IconData _selectedIcon = _kCategoryIcons.last;
  bool _isActive = true;

  @override
  void dispose() {
    _nameArController.dispose();
    _nameEnController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  // ============================================================================
  // Category CRUD
  // ============================================================================

  void _selectCategory(CategoriesTableData category) {
    setState(() {
      _selectedCategoryId = category.id;
      _isCreating = false;
      _nameArController.text = category.name;
      _nameEnController.text = category.nameEn ?? '';
      _sortOrderController.text = category.sortOrder.toString();
      _selectedColor = _parseColor(category.color);
      _selectedIcon = _parseIcon(category.icon);
      _isActive = category.isActive;
    });
  }

  void _startCreating() {
    setState(() {
      _selectedCategoryId = null;
      _isCreating = true;
      _nameArController.clear();
      _nameEnController.clear();
      _sortOrderController.text = '0';
      _selectedColor = _kCategoryColors[0];
      _selectedIcon = _kCategoryIcons.last;
      _isActive = true;
    });
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    final storeId = ref.read(currentStoreIdProvider) ?? kDefaultStoreId;
    final dao = getIt<AppDatabase>().categoriesDao;
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();

    final sanitizedName =
        InputSanitizer.sanitize(_nameArController.text.trim());
    final sanitizedNameEn =
        InputSanitizer.sanitize(_nameEnController.text.trim());

    try {
      if (_isCreating) {
        final newId = 'cat_${now.millisecondsSinceEpoch}';
        await dao.insertCategory(CategoriesTableCompanion(
          id: drift.Value(newId),
          storeId: drift.Value(storeId),
          name: drift.Value(sanitizedName),
          nameEn: drift.Value(
              sanitizedNameEn.isEmpty ? null : sanitizedNameEn),
          color: drift.Value(_colorToHex(_selectedColor)),
          icon: drift.Value(_iconToString(_selectedIcon)),
          sortOrder:
              drift.Value(int.tryParse(_sortOrderController.text) ?? 0),
          isActive: drift.Value(_isActive),
          createdAt: drift.Value(now),
          updatedAt: drift.Value(now),
        ));
        setState(() {
          _selectedCategoryId = newId;
          _isCreating = false;
        });
      } else if (_selectedCategoryId != null) {
        final existing = await dao.getCategoryById(_selectedCategoryId!);
        if (existing != null) {
          await dao.updateCategory(existing.copyWith(
            name: sanitizedName,
            nameEn: drift.Value(
                sanitizedNameEn.isEmpty ? null : sanitizedNameEn),
            color: drift.Value(_colorToHex(_selectedColor)),
            icon: drift.Value(_iconToString(_selectedIcon)),
            sortOrder:
                int.tryParse(_sortOrderController.text) ?? 0,
            isActive: _isActive,
            updatedAt: drift.Value(now),
          ));
        }
      }

      _colorCache.clear();
      _iconCache.clear();
      ref.invalidate(_adminCategoriesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.categorySavedSuccess),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorWithDetails('$e')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteCategory() async {
    if (_selectedCategoryId == null) return;

    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: min(
            MediaQuery.of(ctx).size.width * 0.9,
            AlhaiBreakpoints.maxDialogWidth,
          ),
        ),
        child: AlertDialog(
          title: Text(l10n.deleteCategory),
          content: Text(l10n.deleteCategoryConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: Text(l10n.deleteCategory),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;

    try {
      final dao = getIt<AppDatabase>().categoriesDao;
      await dao.deleteCategory(_selectedCategoryId!);

      _colorCache.clear();
      _iconCache.clear();
      ref.invalidate(_adminCategoriesProvider);

      setState(() {
        _selectedCategoryId = null;
        _isCreating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.categoryDeletedSuccess),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorWithDetails('$e')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // ============================================================================
  // Build
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width >= AlhaiBreakpoints.desktop;
    final isMediumScreen = size.width >= AlhaiBreakpoints.tablet;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        AppHeader(
          title: l10n.categoriesManagement,
          subtitle: l10n.categories,
          showSearch: false,
          onMenuTap:
              isWideScreen ? null : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 0,
          userName: l10n.defaultUserName,
          userRole: l10n.branchManager,
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
            child: isMediumScreen
                ? _buildSplitView(isDark, l10n)
                : _buildMobileView(isDark, l10n),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // Split View (Desktop/Tablet)
  // ============================================================================

  Widget _buildSplitView(bool isDark, AppLocalizations l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: _buildLeftPanel(isDark, l10n),
        ),
        const SizedBox(width: AlhaiSpacing.lg),
        Expanded(
          flex: 6,
          child: _buildRightPanel(isDark, l10n),
        ),
      ],
    );
  }

  // ============================================================================
  // Mobile View
  // ============================================================================

  Widget _buildMobileView(bool isDark, AppLocalizations l10n) {
    if (_selectedCategoryId != null || _isCreating) {
      return Column(
        children: [
          Row(
            children: [
              TextButton.icon(
                onPressed: () => setState(() {
                  _selectedCategoryId = null;
                  _isCreating = false;
                }),
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: Text(l10n.categories),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          Expanded(child: _buildRightPanel(isDark, l10n)),
        ],
      );
    }
    return Stack(
      children: [
        _buildLeftPanel(isDark, l10n),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: _startCreating,
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // Left Panel - Categories List
  // ============================================================================

  Widget _buildLeftPanel(bool isDark, AppLocalizations l10n) {
    final categoriesAsync = ref.watch(_adminCategoriesProvider);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.border.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AlhaiSpacing.mdl),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      l10n.categories,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: AlhaiSpacing.xs),
                    categoriesAsync.when(
                      data: (cats) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          l10n.categoriesCount(cats.length),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _startCreating,
                      icon: const Icon(
                        Icons.add_rounded,
                        color: AppColors.primary,
                      ),
                      tooltip: l10n.addCategory,
                      style: IconButton.styleFrom(
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AlhaiSpacing.sm),
                // Search
                TextField(
                  maxLength: 100,
                  onChanged: (value) {
                    final sanitized = InputSanitizer.sanitize(value);
                    setState(() => _searchQuery = sanitized);
                  },
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: l10n.searchCategories,
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : AppColors.border.withValues(alpha: 0.15),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 1.5),
                    ),
                  ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          Divider(
            height: 1,
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.border.withValues(alpha: 0.5),
          ),

          // Category list
          Expanded(
            child: categoriesAsync.when(
              data: (categories) {
                final filtered = _searchQuery.isEmpty
                    ? categories
                    : categories
                        .where((c) => c.name
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()))
                        .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 48,
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5).withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: AlhaiSpacing.sm),
                        Text(
                          l10n.noCategories,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final category = filtered[index];
                    final color = _colorCache.putIfAbsent(
                        category.id, () => _parseColor(category.color));
                    final icon = _iconCache.putIfAbsent(
                        category.id, () => _parseIcon(category.icon));
                    final isSelected =
                        _selectedCategoryId == category.id;

                    return _CategoryListItem(
                      category: category,
                      color: color,
                      icon: icon,
                      isSelected: isSelected,
                      isDark: isDark,
                      onTap: () => _selectCategory(category),
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (err, _) => AppErrorState(
                message: '$err',
                onRetry: () => ref.invalidate(_adminCategoriesProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // Right Panel - Detail / Edit
  // ============================================================================

  Widget _buildRightPanel(bool isDark, AppLocalizations l10n) {
    if (_selectedCategoryId == null && !_isCreating) {
      return _buildEmptyState(isDark, l10n);
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.border.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AlhaiSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailHeader(isDark, l10n),
              const SizedBox(height: AlhaiSpacing.mdl),
              Divider(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : AppColors.border.withValues(alpha: 0.5),
              ),
              const SizedBox(height: AlhaiSpacing.mdl),
              _buildIconAndColorRow(isDark, l10n),
              const SizedBox(height: AlhaiSpacing.mdl),
              _buildNameFields(isDark, l10n),
              const SizedBox(height: AlhaiSpacing.md),
              _buildSortOrderField(isDark, l10n),
              const SizedBox(height: AlhaiSpacing.md),
              _buildActiveSwitch(isDark, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.border.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.touch_app_outlined,
              size: 64,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : AppColors.textTertiary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AlhaiSpacing.md),
            Text(
              l10n.noCategorySelected,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.md),
            FilledButton.icon(
              onPressed: _startCreating,
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.addCategory),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // Detail Header
  // ============================================================================

  Widget _buildDetailHeader(bool isDark, AppLocalizations l10n) {
    return Row(
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _isActive
                ? AppColors.success.withValues(alpha: 0.1)
                : AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isActive
                  ? AppColors.success.withValues(alpha: 0.3)
                  : AppColors.error.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            _isActive ? l10n.activeStatus : l10n.inactiveStatus,
            style: TextStyle(
              color: _isActive ? AppColors.success : AppColors.error,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: AlhaiSpacing.sm),
        Expanded(
          child: Text(
            _isCreating
                ? l10n.addCategory
                : (_nameArController.text.isNotEmpty
                    ? _nameArController.text
                    : l10n.editCategory),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (!_isCreating) ...[
          OutlinedButton.icon(
            onPressed: _deleteCategory,
            icon: const Icon(Icons.delete_outline_rounded,
                size: 16, color: AppColors.error),
            label: Text(l10n.deleteCategory,
                style: const TextStyle(color: AppColors.error)),
            style: OutlinedButton.styleFrom(
              side:
                  BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
            ),
          ),
          const SizedBox(width: AlhaiSpacing.xs),
        ],
        FilledButton.icon(
          onPressed: _saveCategory,
          icon: const Icon(Icons.check_rounded, size: 16),
          label: Text(l10n.saveChanges),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // Icon & Color Pickers
  // ============================================================================

  Widget _buildIconAndColorRow(bool isDark, AppLocalizations l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon picker
        Expanded(
          child: _buildPickerSection(
            isDark: isDark,
            title: l10n.categoryIcon,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _kCategoryIcons.map((icon) {
                final isSelected = icon == _selectedIcon;
                return InkWell(
                  onTap: () => setState(() => _selectedIcon = icon),
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _selectedColor.withValues(alpha: 0.15)
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : AppColors.border.withValues(alpha: 0.15)),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? _selectedColor
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: isSelected
                          ? _selectedColor
                          : (Theme.of(context).colorScheme.onSurfaceVariant),
                      size: 20,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: AlhaiSpacing.mdl),
        // Color picker
        Expanded(
          child: _buildPickerSection(
            isDark: isDark,
            title: l10n.categoryColor,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _kCategoryColors.map((color) {
                final isSelected = color == _selectedColor;
                return InkWell(
                  onTap: () => setState(() => _selectedColor = color),
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color:
                            isSelected ? color : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                                size: 14, color: Colors.white)
                            : null,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPickerSection({
    required bool isDark,
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isDark
                ? Colors.white.withValues(alpha: 0.7)
                : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }

  // ============================================================================
  // Name Fields
  // ============================================================================

  Widget _buildNameFields(bool isDark, AppLocalizations l10n) {
    return Column(
      children: [
        _buildTextField(
          isDark: isDark,
          label: l10n.categoryNameAr,
          controller: _nameArController,
          maxLength: 80,
          validator: FormValidators.requiredField(maxLength: 80),
        ),
        const SizedBox(height: AlhaiSpacing.sm),
        _buildTextField(
          isDark: isDark,
          label: l10n.categoryNameEn,
          controller: _nameEnController,
          maxLength: 80,
          validator: FormValidators.notes(maxLength: 80),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required bool isDark,
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 13,
        ),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : AppColors.border.withValues(alpha: 0.15),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.border.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }

  // ============================================================================
  // Sort Order
  // ============================================================================

  Widget _buildSortOrderField(bool isDark, AppLocalizations l10n) {
    return _buildTextField(
      isDark: isDark,
      label: l10n.sortOrder,
      controller: _sortOrderController,
      maxLength: 5,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: FormValidators.numeric(
          isRequired: false, max: 99999, allowZero: true),
    );
  }

  // ============================================================================
  // Active Switch
  // ============================================================================

  Widget _buildActiveSwitch(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md, vertical: AlhaiSpacing.sm),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : AppColors.border.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.border.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isActive
                ? Icons.check_circle_rounded
                : Icons.cancel_rounded,
            color: _isActive ? AppColors.success : AppColors.error,
            size: 20,
          ),
          const SizedBox(width: AlhaiSpacing.sm),
          Expanded(
            child: Text(
              _isActive ? l10n.activeStatus : l10n.inactiveStatus,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: _isActive,
            onChanged: (v) => setState(() => _isActive = v),
            activeThumbColor: AppColors.success,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Category List Item Widget
// ============================================================================

class _CategoryListItem extends StatefulWidget {
  final CategoriesTableData category;
  final Color color;
  final IconData icon;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _CategoryListItem({
    required this.category,
    required this.color,
    required this.icon,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_CategoryListItem> createState() => _CategoryListItemState();
}

class _CategoryListItemState extends State<_CategoryListItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
            margin: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : _isHovered
                      ? (widget.isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : AppColors.border.withValues(alpha: 0.15))
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: widget.isSelected
                  ? const BorderDirectional(
                      end: BorderSide(
                        color: AppColors.primary,
                        width: 3,
                      ),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.color,
                    size: 18,
                  ),
                ),
                const SizedBox(width: AlhaiSpacing.sm),
                Expanded(
                  child: Text(
                    widget.category.name,
                    style: TextStyle(
                      color: widget.isSelected
                          ? AppColors.primary
                          : (Theme.of(context).colorScheme.onSurface),
                      fontSize: 14,
                      fontWeight: widget.isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!widget.category.isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.block_rounded,
                      size: 14,
                      color: AppColors.error,
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
