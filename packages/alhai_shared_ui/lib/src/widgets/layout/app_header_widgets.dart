/// Header sub-widgets extracted from app_header.dart
part of 'app_header.dart';

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
                ? AppColors.surfaceVariantDark
                : AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(8),
            border: isDarkMode
                ? Border.all(color: Colors.white12)
                : null,
          ),
          child: AnimatedSwitcher(
            duration: AlhaiDurations.slow,
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
        duration: AlhaiDurations.standard,
        decoration: BoxDecoration(
          color: _isFocused
              ? (Theme.of(context).colorScheme.surface)
              : (isDarkMode ? AppColors.surfaceDark : AppColors.backgroundSecondary),
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
            color: Theme.of(context).colorScheme.onSurface,
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
                          '\u2318K',
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
  final bool isDark;

  const _HeaderIconButton({
    required this.icon,
    this.onTap,
    this.isDark = false,
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
                  ? (widget.isDark ? Colors.white.withAlpha(26) : AppColors.backgroundSecondary)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              widget.icon,
              color: AppColors.getTextSecondary(widget.isDark),
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
  final bool isDark;

  const _NotificationButton({
    required this.count,
    this.onTap,
    this.isDark = false,
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
                  ? (widget.isDark ? Colors.white.withAlpha(26) : AppColors.backgroundSecondary)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: AppColors.getTextSecondary(widget.isDark),
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
                          color: widget.isDark ? AppColors.backgroundDark : Colors.white,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                  ? (isDark ? Colors.white.withAlpha(26) : AppColors.backgroundSecondary)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // الصورة (uses CachedNetworkImage for offline support)
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withAlpha(26),
                  backgroundImage: widget.avatarUrl != null
                      ? CachedNetworkImageProvider(widget.avatarUrl!)
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
                Builder(builder: (context) {
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: TextStyle(
                          color: AppColors.getTextPrimary(isDark),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (widget.role != null)
                        Text(
                          widget.role!,
                          style: TextStyle(
                            color: AppColors.getTextSecondary(isDark),
                            fontSize: 11,
                          ),
                        ),
                    ],
                  );
                }),

                const SizedBox(width: 8),

                // السهم
                Builder(builder: (context) {
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  return Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.getTextMuted(isDark),
                    size: 18,
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
