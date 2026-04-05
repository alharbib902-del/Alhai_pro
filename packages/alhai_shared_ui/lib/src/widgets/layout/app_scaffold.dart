/// الـ Scaffold الرئيسي للتطبيق - App Scaffold
///
/// يوفر هيكل موحد للصفحات مع:
/// - Sidebar للويب والتابلت
/// - Bottom Navigation للموبايل
/// - Responsive Layout
library;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import '../../core/theme/app_sizes.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../common/offline_banner.dart';
import 'sidebar.dart';
import 'top_bar.dart';

/// Navigation Item للتطبيق
class AppNavigationItem {
  final String id;
  final String label;
  final IconData icon;
  final IconData? activeIcon;
  final String? badge;
  final Color? badgeColor;
  final Widget page;

  const AppNavigationItem({
    required this.id,
    required this.label,
    required this.icon,
    this.activeIcon,
    this.badge,
    this.badgeColor,
    required this.page,
  });
}

/// الـ Scaffold الرئيسي
class AppScaffold extends StatefulWidget {
  /// عناصر التنقل
  final List<AppNavigationItem> items;

  /// الصفحة المحددة
  final String selectedId;

  /// عند تغيير الصفحة
  final ValueChanged<String> onNavigate;

  /// عنوان الصفحة الحالية (للـ TopBar)
  final String? currentTitle;

  /// عنوان فرعي
  final String? currentSubtitle;

  /// Actions للـ TopBar
  final List<Widget>? actions;

  /// هل يظهر شريط البحث؟
  final bool showSearch;

  /// ويدجت البحث
  final Widget? searchWidget;

  /// Floating Action Button
  final Widget? floatingActionButton;

  /// موقع FAB
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// هيدر مخصص للـ Sidebar
  final Widget? sidebarHeader;

  /// فوتر مخصص للـ Sidebar
  final Widget? sidebarFooter;

  /// هل الـ Sidebar مطوي افتراضياً؟
  final bool initiallyCollapsed;

  /// Keyboard Shortcuts
  final Map<ShortcutActivator, VoidCallback>? shortcuts;

  /// Widget بديل للمحتوى (بدلاً من page من items)
  final Widget? body;

  const AppScaffold({
    super.key,
    required this.items,
    required this.selectedId,
    required this.onNavigate,
    this.currentTitle,
    this.currentSubtitle,
    this.actions,
    this.showSearch = false,
    this.searchWidget,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.sidebarHeader,
    this.sidebarFooter,
    this.initiallyCollapsed = false,
    this.shortcuts,
    this.body,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  late bool _isSidebarCollapsed;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _isSidebarCollapsed = widget.initiallyCollapsed;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppBreakpoints.isDesktop(context);
    final isTablet = AppBreakpoints.isTablet(context);
    final isMobile = AppBreakpoints.isMobile(context);

    // Keyboard shortcuts wrapper
    Widget scaffold = _buildScaffold(
      context,
      isDesktop: isDesktop,
      isTablet: isTablet,
      isMobile: isMobile,
    );

    // Add keyboard shortcuts if provided
    if (widget.shortcuts != null && widget.shortcuts!.isNotEmpty) {
      scaffold = CallbackShortcuts(
        bindings: widget.shortcuts!,
        child: Focus(
          autofocus: true,
          child: scaffold,
        ),
      );
    }

    return scaffold;
  }

  Widget _buildScaffold(
    BuildContext context, {
    required bool isDesktop,
    required bool isTablet,
    required bool isMobile,
  }) {
    // Mobile Layout - Bottom Navigation
    if (isMobile) {
      return _buildMobileLayout();
    }

    // Desktop/Tablet Layout - Sidebar
    return _buildDesktopLayout(isTablet: isTablet);
  }

  Widget _buildDesktopLayout({bool isTablet = false}) {
    final sidebarItems = widget.items
        .map((item) => SidebarItem(
              id: item.id,
              label: item.label,
              icon: item.icon,
              activeIcon: item.activeIcon,
              badge: item.badge,
              badgeColor: item.badgeColor,
            ))
        .toList();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      body: Directionality(
        textDirection: Directionality.of(context),
        child: Row(
          children: [
            // Sidebar
            Sidebar(
              items: sidebarItems,
              selectedId: widget.selectedId,
              onItemSelected: widget.onNavigate,
              isCollapsed: isTablet || _isSidebarCollapsed,
              onToggleCollapse: isTablet
                  ? null
                  : () => setState(() {
                        _isSidebarCollapsed = !_isSidebarCollapsed;
                      }),
              header: widget.sidebarHeader,
              footer: widget.sidebarFooter,
            ),

            // Main Content
            Expanded(
              child: Column(
                children: [
                  // Top Bar
                  TopBar(
                    title: widget.currentTitle ?? _getCurrentItem()?.label,
                    subtitle: widget.currentSubtitle,
                    actions: widget.actions,
                    showSearch: widget.showSearch,
                    searchWidget: widget.searchWidget,
                  ),

                  // Offline / Sync Status Banners
                  const StatusBanners(),

                  // Page Content
                  Expanded(
                    child: widget.body ?? _getCurrentPage(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.currentTitle ?? _getCurrentItem()?.label ?? ''),
        centerTitle: true,
        actions: widget.actions,
      ),
      body: Column(
        children: [
          // Offline / Sync Status Banners
          const StatusBanners(),
          // Page Content
          Expanded(child: widget.body ?? _getCurrentPage()),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
      drawer: _buildMobileDrawer(),
    );
  }

  Widget _buildBottomNavigation() {
    // عرض أول 5 عناصر فقط في Bottom Navigation
    final visibleItems = widget.items.take(5).toList();
    final selectedIndex = visibleItems
        .indexWhere((item) => item.id == widget.selectedId)
        .clamp(0, visibleItems.length - 1);

    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        if (index < visibleItems.length) {
          widget.onNavigate(visibleItems[index].id);
        }
      },
      destinations: visibleItems.map((item) {
        return NavigationDestination(
          icon: Icon(item.icon),
          selectedIcon: Icon(item.activeIcon ?? item.icon),
          label: item.label,
        );
      }).toList(),
    );
  }

  Widget _buildMobileDrawer() {
    final l10n = AppLocalizations.of(context);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.white,
                  child: Icon(
                    Icons.storefront,
                    size: 32,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.myGrocery,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  l10n.posSystemLabel,
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          ...widget.items.map((item) {
            final isSelected = item.id == widget.selectedId;
            return ListTile(
              leading: Icon(
                isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              title: Text(
                item.label,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              selected: isSelected,
              selectedTileColor: AppColors.primarySurface,
              onTap: () {
                Navigator.pop(context);
                widget.onNavigate(item.id);
              },
              trailing: item.badge != null
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AlhaiSpacing.xs,
                        vertical: AlhaiSpacing.xxxs,
                      ),
                      decoration: BoxDecoration(
                        color: item.badgeColor ?? AppColors.error,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.badge!,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
            );
          }),
        ],
      ),
    );
  }

  AppNavigationItem? _getCurrentItem() {
    try {
      return widget.items.firstWhere((item) => item.id == widget.selectedId);
    } catch (_) {
      return widget.items.isNotEmpty ? widget.items.first : null;
    }
  }

  Widget _getCurrentPage() {
    final currentItem = _getCurrentItem();
    return currentItem?.page ?? const SizedBox.shrink();
  }
}

/// Scaffold بسيط للصفحات الفرعية (بدون Sidebar)
class SubPageScaffold extends StatelessWidget {
  /// عنوان الصفحة
  final String title;

  /// عنوان فرعي
  final String? subtitle;

  /// محتوى الصفحة
  final Widget body;

  /// Actions للـ TopBar
  final List<Widget>? actions;

  /// Floating Action Button
  final Widget? floatingActionButton;

  /// عند الرجوع
  final VoidCallback? onBack;

  const SubPageScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          TopBar(
            title: title,
            subtitle: subtitle,
            showBackButton: true,
            onBackPressed: onBack ?? () => Navigator.of(context).pop(),
            actions: actions,
          ),
          // Offline / Sync Status Banners
          const StatusBanners(),
          Expanded(child: body),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
