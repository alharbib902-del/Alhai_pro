/// App Sidebar Widget - القائمة الجانبية
///
/// القائمة الجانبية الرئيسية للتطبيق مع التصميم الجديد
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../core/theme/app_sizes.dart';

part 'app_sidebar_widgets.dart';

/// عنصر في القائمة الجانبية
class AppSidebarItem {
  final String id;
  final String title;
  final IconData icon;
  final IconData? activeIcon;
  final String? badge;
  final Color? badgeColor;
  final bool isNew;

  const AppSidebarItem({
    required this.id,
    required this.title,
    required this.icon,
    this.activeIcon,
    this.badge,
    this.badgeColor,
    this.isNew = false,
  });
}

/// مجموعة عناصر
class SidebarGroup {
  final String? title;
  final List<AppSidebarItem> items;

  const SidebarGroup({
    this.title,
    required this.items,
  });
}

/// القائمة الجانبية
class AppSidebar extends ConsumerStatefulWidget {
  final String? storeName;
  final String? storeLogoUrl;
  final List<SidebarGroup> groups;
  final String? selectedId;
  final ValueChanged<AppSidebarItem>? onItemTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onSupportTap;
  final VoidCallback? onLogoutTap;
  final bool collapsed;
  final String? userName;
  final String? userRole;
  final String? userAvatarUrl;
  final VoidCallback? onUserTap;

  const AppSidebar({
    super.key,
    this.storeName,
    this.storeLogoUrl,
    required this.groups,
    this.selectedId,
    this.onItemTap,
    this.onSettingsTap,
    this.onSupportTap,
    this.onLogoutTap,
    this.collapsed = false,
    this.userName,
    this.userRole,
    this.userAvatarUrl,
    this.onUserTap,
  });

  @override
  ConsumerState<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends ConsumerState<AppSidebar> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// فلترة المجموعات حسب نص البحث
  List<SidebarGroup> _filterGroups(List<SidebarGroup> groups) {
    if (_searchQuery.isEmpty) return groups;

    final query = _searchQuery.toLowerCase();
    final filtered = <SidebarGroup>[];

    for (final group in groups) {
      final matchedItems = group.items
          .where((item) => item.title.toLowerCase().contains(query))
          .toList();
      if (matchedItems.isNotEmpty) {
        filtered.add(SidebarGroup(title: group.title, items: matchedItems));
      }
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final filteredGroups = _filterGroups(widget.groups);

    return AnimatedContainer(
      duration: AlhaiDurations.standard,
      width: widget.collapsed ? 80 : 280,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          left: BorderSide(
            color: isDarkMode
                ? Colors.white.withAlpha(26)
                : AppColors.border,
          ),
        ),
        boxShadow: AppShadows.of(context, size: ShadowSize.md),
      ),
      child: Column(
        children: [
          // الهيدر (اسم المتجر وشعاره)
          _SidebarHeader(
            storeName: widget.storeName,
            storeLogoUrl: widget.storeLogoUrl,
            collapsed: widget.collapsed,
          ),

          // حقل البحث
          if (!widget.collapsed)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 12, 4),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: l10n.search,
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          child: Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        )
                      : null,
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),

          // القائمة
          Expanded(
            child: filteredGroups.isEmpty && _searchQuery.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 36,
                          color: isDarkMode
                              ? Colors.white.withValues(alpha: 0.3)
                              : AppColors.textTertiary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.noResults,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : _buildSidebarList(filteredGroups),
          ),

          // الفاصل
          const Divider(color: AppColors.border, height: 1),

          // بطاقة المستخدم
          if (widget.userName != null)
            _UserProfileCard(
              name: widget.userName!,
              role: widget.userRole,
              avatarUrl: widget.userAvatarUrl,
              collapsed: widget.collapsed,
              onTap: widget.onUserTap,
            ),

          // الفاصل
          if (widget.userName != null)
            const Divider(color: AppColors.border, height: 1),

          // الأزرار السفلية
          _SidebarFooter(
            collapsed: widget.collapsed,
            onSettingsTap: widget.onSettingsTap,
            onSupportTap: widget.onSupportTap,
            onLogoutTap: widget.onLogoutTap,
          ),
        ],
      ),
    );
  }

  /// بناء قائمة العناصر باستخدام ListView.builder للأداء
  Widget _buildSidebarList(List<SidebarGroup> filteredGroups) {
    // Flatten groups into a flat list of widgets for ListView.builder
    final flatItems = <_SidebarFlatEntry>[];
    for (final group in filteredGroups) {
      if (group.title != null && !widget.collapsed) {
        flatItems.add(_SidebarFlatEntry.title(group.title!));
      }
      for (final item in group.items) {
        flatItems.add(_SidebarFlatEntry.item(item));
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: flatItems.length,
      itemBuilder: (context, index) {
        final entry = flatItems[index];
        if (entry.isTitle) {
          return Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 8),
            child: Text(
              entry.title!,
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          );
        }
        final item = entry.sidebarItem!;
        return _SidebarItemWidget(
          item: item,
          isSelected: item.id == widget.selectedId,
          collapsed: widget.collapsed,
          onTap: () => widget.onItemTap?.call(item),
        );
      },
    );
  }
}
