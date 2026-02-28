/// Breadcrumb & DateTimeDisplay - extracted from app_header.dart
part of 'app_header.dart';

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
          '$day\u060C $date${showTime ? ' - $time' : ''}',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
