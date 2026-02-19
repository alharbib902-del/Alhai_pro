/// App Header Widget - الهيدر الرئيسي
///
/// الهيدر العلوي للتطبيق مع البحث والإشعارات ومعلومات المستخدم
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/responsive/responsive_utils.dart';
import '../../providers/theme_provider.dart';
import '../common/language_selector.dart';

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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDarkMode ? 26 : 5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
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

/// زر تبديل الوضع الداكن
class _DarkModeToggle extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onToggle;

  const _DarkModeToggle({
    required this.isDarkMode,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDarkMode 
                ? const Color(0xFF374151) 
                : AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(8),
            border: isDarkMode 
                ? Border.all(color: Colors.white12) 
                : null,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return RotationTransition(
                turns: animation,
                child: ScaleTransition(
                  scale: animation,
                  child: child,
                ),
              );
            },
            child: Icon(
              isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              key: ValueKey(isDarkMode),
              color: isDarkMode ? Colors.amber : AppColors.textSecondary,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}

/// حقل البحث
class _SearchField extends StatefulWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;

  const _SearchField({
    required this.hint,
    this.onChanged,
    this.onTap,
  });

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _isFocused
              ? (isDarkMode ? const Color(0xFF1E293B) : Colors.white)
              : (isDarkMode ? const Color(0xFF1E293B) : AppColors.backgroundSecondary),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isFocused
                ? AppColors.primary
                : (isDarkMode ? Colors.white.withAlpha(26) : AppColors.border),
            width: _isFocused ? 2 : 1,
          ),
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(51),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: widget.onChanged,
          style: TextStyle(
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              color: isDarkMode 
                  ? Colors.white.withAlpha(102) 
                  : AppColors.textTertiary,
              fontSize: 14,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsetsDirectional.only(end: 12, start: 16),
              child: Icon(
                Icons.search_rounded,
                color: _isFocused
                    ? AppColors.primary
                    : (isDarkMode 
                        ? Colors.white.withAlpha(102) 
                        : AppColors.textTertiary),
                size: 20,
              ),
            ),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _controller.clear();
                      widget.onChanged?.call('');
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textTertiary,
                      size: 20,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '⌘K',
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }
}

/// زر أيقونة في الهيدر
class _HeaderIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _HeaderIconButton({
    required this.icon,
    this.onTap,
  });

  @override
  State<_HeaderIconButton> createState() => _HeaderIconButtonState();
}

class _HeaderIconButtonState extends State<_HeaderIconButton> {
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
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _isHovered
                  ? AppColors.backgroundSecondary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              widget.icon,
              color: AppColors.textSecondary,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

/// زر الإشعارات
class _NotificationButton extends StatefulWidget {
  final int count;
  final VoidCallback? onTap;

  const _NotificationButton({
    required this.count,
    this.onTap,
  });

  @override
  State<_NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<_NotificationButton> {
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
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _isHovered
                  ? AppColors.backgroundSecondary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.textSecondary,
                  size: 22,
                ),
                if (widget.count > 0)
                  PositionedDirectional(
                    top: -4,
                    end: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        widget.count > 9 ? '9+' : widget.count.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

/// معلومات المستخدم
class _UserInfo extends StatefulWidget {
  final String name;
  final String? role;
  final String? avatarUrl;
  final VoidCallback? onTap;

  const _UserInfo({
    required this.name,
    this.role,
    this.avatarUrl,
    this.onTap,
  });

  @override
  State<_UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<_UserInfo> {
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
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: _isHovered
                  ? AppColors.backgroundSecondary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // الصورة
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withAlpha(26),
                  backgroundImage: widget.avatarUrl != null
                      ? NetworkImage(widget.avatarUrl!)
                      : null,
                  child: widget.avatarUrl == null
                      ? Text(
                          widget.name.isNotEmpty
                              ? widget.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),

                const SizedBox(width: 10),

                // الاسم والدور
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.role != null)
                      Text(
                        widget.role!,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 8),

                // السهم
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textTertiary,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Breadcrumb للتنقل
class AppBreadcrumb extends StatelessWidget {
  final List<AppBreadcrumbItem> items;

  const AppBreadcrumb({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) ...[
            const Icon(
              Icons.chevron_left_rounded,
              color: AppColors.textTertiary,
              size: 18,
            ),
          ],
          _BreadcrumbItemWidget(
            item: items[i],
            isLast: i == items.length - 1,
          ),
        ],
      ],
    );
  }
}

/// عنصر في Breadcrumb
class AppBreadcrumbItem {
  final String title;
  final IconData? icon;
  final VoidCallback? onTap;

  const AppBreadcrumbItem({
    required this.title,
    this.icon,
    this.onTap,
  });
}

class _BreadcrumbItemWidget extends StatefulWidget {
  final AppBreadcrumbItem item;
  final bool isLast;

  const _BreadcrumbItemWidget({
    required this.item,
    required this.isLast,
  });

  @override
  State<_BreadcrumbItemWidget> createState() => _BreadcrumbItemWidgetState();
}

class _BreadcrumbItemWidgetState extends State<_BreadcrumbItemWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.isLast ? null : widget.item.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: _isHovered && !widget.isLast
                ? AppColors.backgroundSecondary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.item.icon != null) ...[
                Icon(
                  widget.item.icon,
                  size: 16,
                  color: widget.isLast
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                widget.item.title,
                style: TextStyle(
                  color: widget.isLast
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: widget.isLast
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// عرض التاريخ والوقت
class DateTimeDisplay extends StatelessWidget {
  final DateTime? dateTime;
  final bool showTime;
  final bool showIcon;

  const DateTimeDisplay({
    super.key,
    this.dateTime,
    this.showTime = true,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final now = dateTime ?? DateTime.now();
    final months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    final days = [
      'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء',
      'الخميس', 'الجمعة', 'السبت',
    ];

    final day = days[now.weekday % 7];
    final date = '${now.day} ${months[now.month - 1]} ${now.year}';
    final time = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showIcon) ...[
          const Icon(
            Icons.calendar_today_rounded,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
        ],
        Text(
          '$day، $date${showTime ? ' - $time' : ''}',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
