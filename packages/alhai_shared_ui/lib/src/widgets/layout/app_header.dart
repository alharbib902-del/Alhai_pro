/// App Header Widget - الهيدر الرئيسي
///
/// الهيدر العلوي للتطبيق مع البحث والإشعارات ومعلومات المستخدم
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:alhai_design_system/alhai_design_system.dart'
    hide ResponsiveBuilder, ResponsiveVisibility;
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/responsive/responsive_utils.dart';
import '../../providers/theme_provider.dart';
import '../common/language_selector.dart';
import '../common/sync_status_indicator.dart';

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
    // نراقب حالة الثيم لإعادة البناء عند التغيير
    ref.watch(themeProvider);
    // نستخدم brightness الفعلي من السياق (يشمل وضع النظام)
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.backgroundDark : Colors.white,
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
            horizontal: getResponsiveValue(
              context,
              mobile: 12.0,
              desktop: 20.0,
            ),
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
                  isDark: isDarkMode,
                  tooltip: AppLocalizations.of(context).menuLabel,
                ),

              // العنوان
              if (title != null) ...[
                SizedBox(width: AlhaiSpacing.md),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title!,
                        style: TextStyle(
                          color: AppColors.getTextPrimary(isDarkMode),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: TextStyle(
                            color: AppColors.getTextSecondary(isDarkMode),
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],

              SizedBox(width: AlhaiSpacing.md),

              // البحث - مخفي على الجوال
              ResponsiveVisibility.hiddenOnMobile(
                child: showSearch
                    ? Expanded(
                        flex: 2,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: _SearchField(
                            hint:
                                searchHint ??
                                AppLocalizations.of(context).searchPlaceholder,
                            onChanged: onSearchChanged,
                            onTap: onSearchTap,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              SizedBox(width: AlhaiSpacing.md),

              // الإجراءات
              if (actions != null) ...actions!,

              // زر ملء الشاشة - سطح المكتب فقط
              ResponsiveVisibility.hiddenOnMobile(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: AlhaiSpacing.xxs),
                    _HeaderIconButton(
                      icon: Icons.fullscreen_rounded,
                      isDark: isDarkMode,
                      tooltip: AppLocalizations.of(context).fullscreen,
                      onTap: () {
                        // يمكن تنفيذ ملء الشاشة لاحقاً
                      },
                    ),
                  ],
                ),
              ),

              // مؤشر حالة المزامنة
              SizedBox(width: AlhaiSpacing.xxs),
              const SyncStatusIndicator(),

              // اختيار اللغة
              SizedBox(width: AlhaiSpacing.xxs),
              const LanguageSelectorButton(showLabel: false, compact: true),

              // زر الوضع الداكن
              SizedBox(width: AlhaiSpacing.xxs),
              _DarkModeToggle(
                isDarkMode: isDarkMode,
                onToggle: () {
                  ref.read(themeProvider.notifier).toggleDarkMode();
                },
              ),

              // الإشعارات
              if (onNotificationsTap != null) ...[
                SizedBox(width: AlhaiSpacing.xs),
                _NotificationButton(
                  count: notificationsCount,
                  onTap: onNotificationsTap,
                  isDark: isDarkMode,
                ),
              ],

              // معلومات المستخدم - مخفي على الموبايل
              if (userName != null)
                ResponsiveVisibility.hiddenOnMobile(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: AlhaiSpacing.md),
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
