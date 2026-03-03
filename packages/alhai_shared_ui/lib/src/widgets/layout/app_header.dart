/// App Header Widget - الهيدر الرئيسي
///
/// الهيدر العلوي للتطبيق مع البحث والإشعارات ومعلومات المستخدم
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:alhai_design_system/alhai_design_system.dart' hide ResponsiveBuilder, ResponsiveVisibility;
import '../../core/theme/app_sizes.dart';
import '../../core/responsive/responsive_utils.dart';
import '../../providers/theme_provider.dart';
import '../common/language_selector.dart';

part 'app_header_widgets.dart';
part 'app_breadcrumb.dart';

/// الهيدر الرئيسي للتطبيق
class AppHeader extends ConsumerWidget {
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showSearch;
  final String? searchHint;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchTap;
  final VoidCallback? onMenuTap;
  final VoidCallback? onNotificationsTap;
  final int notificationsCount;
  final String? userName;
  final String? userRole;
  final String? userAvatarUrl;
  final VoidCallback? onUserTap;
  final bool showDivider;

  const AppHeader({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.showSearch = true,
    this.searchHint,
    this.onSearchChanged,
    this.onSearchTap,
    this.onMenuTap,
    this.onNotificationsTap,
    this.notificationsCount = 0,
    this.userName,
    this.userRole,
    this.userAvatarUrl,
    this.onUserTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final isDarkMode = themeState.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0F172A) : Colors.white,
        border: showDivider
            ? Border(
                bottom: BorderSide(
                  color: isDarkMode
                      ? Colors.white.withAlpha(26)
                      : AppColors.border,
                ),
              )
            : null,
        boxShadow: AppShadows.of(context, size: ShadowSize.sm),
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: getResponsiveValue(context, mobile: 56.0, desktop: 72.0),
          padding: EdgeInsets.symmetric(
            horizontal: getResponsiveValue(context, mobile: 12.0, desktop: 20.0),
          ),
          child: Row(
            children: [
              // زر القائمة أو العنصر الأيسر
              if (leading != null)
                leading!
              else if (onMenuTap != null)
                _HeaderIconButton(
                  icon: Icons.menu_rounded,
                  onTap: onMenuTap,
                ),

              // العنوان
              if (title != null) ...[
                const SizedBox(width: 16),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title!,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],

              const SizedBox(width: 16),

              // البحث - مخفي على الجوال
              ResponsiveVisibility.hiddenOnMobile(
                child: showSearch
                    ? Expanded(
                        flex: 2,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: _SearchField(
                            hint: searchHint ?? 'ابحث عن منتج، عميل، أو فاتورة...',
                            onChanged: onSearchChanged,
                            onTap: onSearchTap,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(width: 16),

              // الإجراءات
              if (actions != null) ...actions!,

              // زر ملء الشاشة - سطح المكتب فقط
              ResponsiveVisibility.hiddenOnMobile(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 4),
                    _HeaderIconButton(
                      icon: Icons.fullscreen_rounded,
                      onTap: () {
                        // يمكن تنفيذ ملء الشاشة لاحقاً
                      },
                    ),
                  ],
                ),
              ),

              // اختيار اللغة
              const SizedBox(width: 4),
              const LanguageSelectorButton(
                showLabel: false,
                compact: true,
              ),

              // زر الوضع الداكن
              const SizedBox(width: 4),
              _DarkModeToggle(
                isDarkMode: isDarkMode,
                onToggle: () {
                  ref.read(themeProvider.notifier).toggleDarkMode();
                },
              ),

              // الإشعارات
              if (onNotificationsTap != null) ...[
                const SizedBox(width: 8),
                _NotificationButton(
                  count: notificationsCount,
                  onTap: onNotificationsTap,
                ),
              ],

              // معلومات المستخدم - مخفي على الموبايل
              if (userName != null)
                ResponsiveVisibility.hiddenOnMobile(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 16),
                      _UserInfo(
                        name: userName!,
                        role: userRole,
                        avatarUrl: userAvatarUrl,
                        onTap: onUserTap,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
