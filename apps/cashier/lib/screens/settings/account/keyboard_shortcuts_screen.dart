/// Keyboard Shortcuts Screen - Read-only shortcut reference
///
/// List of available keyboard shortcuts grouped by category
/// (POS, Payment, Navigation). Each row shows action name and
/// current shortcut key. Read-only reference screen.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiBreakpoints, AlhaiSpacing;
// alhai_design_system is re-exported via alhai_shared_ui

/// Keyboard shortcuts reference screen
class KeyboardShortcutsScreen extends ConsumerStatefulWidget {
  const KeyboardShortcutsScreen({super.key});

  @override
  ConsumerState<KeyboardShortcutsScreen> createState() =>
      _KeyboardShortcutsScreenState();
}

class _KeyboardShortcutsScreenState
    extends ConsumerState<KeyboardShortcutsScreen> {
  String _selectedCategory = 'all';

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
          title: l10n.keyboardShortcuts,
          subtitle: 'مفاتيح الوصول السريع',
          showSearch: false,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: AppColors.getTextPrimary(isDark),
            ),
            onPressed: () => context.pop(),
            tooltip: l10n.back,
          ),
          onNotificationsTap: () => context.push(AppRoutes.notificationsCenter),
          userName: ref.watch(currentUserProvider)?.name ?? l10n.cashCustomer,
          userRole: l10n.cashier,
          onUserTap: () => context.push(AppRoutes.profile),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(
              isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md,
            ),
            child: _buildContent(isWideScreen, isMediumScreen, isDark, l10n),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(
    bool isWideScreen,
    bool isMediumScreen,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final categories = _buildCategories(l10n);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Info banner
        Container(
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: isDark ? 0.12 : 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.keyboard_rounded,
                color: AppColors.info,
                size: 22,
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Expanded(
                child: Text(
                  l10n.keyboardShortcutsHint,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),

        // Category filter chips
        _buildFilterChips(categories, isDark, l10n),
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),

        // Shortcuts list
        if (isWideScreen)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildCategoryCards(
                  categories.take(2).toList(),
                  isDark,
                  l10n,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.lg),
              Expanded(
                child: _buildCategoryCards(
                  categories.skip(2).toList(),
                  isDark,
                  l10n,
                ),
              ),
            ],
          )
        else
          _buildCategoryCards(categories, isDark, l10n),
      ],
    );
  }

  Widget _buildFilterChips(
    List<_ShortcutCategory> categories,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterChip('all', l10n.all, isDark),
          const SizedBox(width: AlhaiSpacing.xs),
          ...categories.map(
            (cat) => Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: _filterChip(cat.id, cat.name, isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String id, String label, bool isDark) {
    final isSelected = _selectedCategory == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = id),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AlhaiSpacing.md,
          vertical: AlhaiSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.getSurfaceVariant(isDark),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.getBorder(isDark),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? AppColors.primary
                : AppColors.getTextSecondary(isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCards(
    List<_ShortcutCategory> categories,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final filtered = _selectedCategory == 'all'
        ? categories
        : categories.where((c) => c.id == _selectedCategory).toList();

    return Column(
      children: filtered.map((category) {
        return Padding(
          padding: const EdgeInsetsDirectional.only(bottom: AlhaiSpacing.md),
          child: _buildShortcutCard(category, isDark),
        );
      }).toList(),
    );
  }

  Widget _buildShortcutCard(_ShortcutCategory category, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category header
          Container(
            padding: const EdgeInsets.all(AlhaiSpacing.md),
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: isDark ? 0.1 : 0.04),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AlhaiSpacing.xs),
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(category.icon, color: category.color, size: 20),
                ),
                const SizedBox(width: AlhaiSpacing.sm),
                Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: AlhaiSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${category.shortcuts.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: category.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Shortcuts list
          ...List.generate(category.shortcuts.length, (index) {
            final shortcut = category.shortcuts[index];
            return Column(
              children: [
                if (index > 0)
                  Divider(
                    color: AppColors.getBorder(isDark),
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AlhaiSpacing.md,
                    vertical: AlhaiSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          shortcut.action,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.getTextPrimary(isDark),
                          ),
                        ),
                      ),
                      _KeyBadge(keys: shortcut.keys, isDark: isDark),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  List<_ShortcutCategory> _buildCategories(AppLocalizations l10n) {
    return [
      _ShortcutCategory(
        id: 'pos',
        name: l10n.pos,
        icon: Icons.point_of_sale_rounded,
        color: AppColors.primary,
        shortcuts: [
          _ShortcutEntry(action: l10n.newSale, keys: 'F2'),
          _ShortcutEntry(action: l10n.searchProducts, keys: 'Ctrl + F'),
          _ShortcutEntry(action: l10n.addToCart, keys: 'Enter'),
          _ShortcutEntry(action: l10n.increaseQuantity, keys: '+'),
          _ShortcutEntry(action: l10n.decreaseQuantity, keys: '-'),
          _ShortcutEntry(action: l10n.deleteItem, keys: 'Delete'),
          _ShortcutEntry(action: l10n.clearCart, keys: 'Ctrl + Del'),
          _ShortcutEntry(action: l10n.holdInvoice, keys: 'F3'),
          _ShortcutEntry(action: l10n.scanBarcode, keys: 'F4'),
        ],
      ),
      _ShortcutCategory(
        id: 'payment',
        name: l10n.payment,
        icon: Icons.payment_rounded,
        color: AppColors.info,
        shortcuts: [
          _ShortcutEntry(action: l10n.proceedToPayment, keys: 'F5'),
          _ShortcutEntry(action: l10n.cashPayment, keys: 'F6'),
          _ShortcutEntry(action: l10n.cardPayment, keys: 'F7'),
          _ShortcutEntry(action: l10n.splitPayment, keys: 'F8'),
          _ShortcutEntry(action: l10n.applyDiscount, keys: 'Ctrl + D'),
          _ShortcutEntry(action: l10n.printReceipt, keys: 'Ctrl + P'),
        ],
      ),
      _ShortcutCategory(
        id: 'navigation',
        name: 'Navigation',
        icon: Icons.navigation_rounded,
        color: AppColors.secondary,
        shortcuts: [
          _ShortcutEntry(action: l10n.openDrawer, keys: 'F9'),
          _ShortcutEntry(action: l10n.openShift, keys: 'Ctrl + O'),
          _ShortcutEntry(action: l10n.closeShift, keys: 'Ctrl + W'),
          const _ShortcutEntry(action: 'View Reports', keys: 'Ctrl + R'),
          _ShortcutEntry(action: l10n.settings, keys: 'Ctrl + ,'),
          _ShortcutEntry(action: l10n.help, keys: 'F1'),
        ],
      ),
    ];
  }
}

/// Key badge widget
class _KeyBadge extends StatelessWidget {
  final String keys;
  final bool isDark;

  const _KeyBadge({required this.keys, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final parts = keys.split(' + ');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(parts.length * 2 - 1, (index) {
        if (index.isOdd) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.xxs),
            child: Text(
              '+',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.getTextMuted(isDark),
              ),
            ),
          );
        }
        final key = parts[index ~/ 2].trim();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.getSurfaceVariant(isDark),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.getBorder(isDark)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                blurRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            key,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
        );
      }),
    );
  }
}

/// Shortcut category data model
class _ShortcutCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final List<_ShortcutEntry> shortcuts;

  const _ShortcutCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.shortcuts,
  });
}

/// Shortcut entry data model
class _ShortcutEntry {
  final String action;
  final String keys;

  const _ShortcutEntry({required this.action, required this.keys});
}
