/// Quick Action Grid Widget - شبكة الإجراءات السريعة
///
/// أزرار الإجراءات السريعة في لوحة التحكم
library;

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';

/// إجراء سريع
class QuickAction {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool isPrimary;
  final String? badge;

  const QuickAction({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    this.onTap,
    this.isPrimary = false,
    this.badge,
  });
}

/// زر إجراء سريع
class QuickActionButton extends StatefulWidget {
  final QuickAction action;
  final bool compact;

  const QuickActionButton({
    super.key,
    required this.action,
    this.compact = false,
  });

  @override
  State<QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<QuickActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final action = widget.action;

    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
      },
      onTapUp: (_) {
        _controller.reverse();
        action.onTap?.call();
      },
      onTapCancel: () {
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          padding: EdgeInsets.all(widget.compact ? 16 : 20),
          decoration: BoxDecoration(
            color: action.isPrimary
                ? action.color
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: action.isPrimary
                ? null
                : Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: action.isPrimary
                    ? action.color.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.02),
                blurRadius: action.isPrimary ? 12 : 8,
                offset: Offset(0, action.isPrimary ? 4 : 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // الأيقونة مع الشارة
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: EdgeInsets.all(widget.compact ? 10 : 12),
                    decoration: BoxDecoration(
                      color: action.isPrimary
                          ? Colors.white.withValues(alpha: 0.2)
                          : action.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      action.icon,
                      color: action.isPrimary
                          ? Colors.white
                          : action.color,
                      size: widget.compact ? 22 : 26,
                    ),
                  ),
                  if (action.badge != null)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
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
                          action.badge!,
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

              SizedBox(height: widget.compact ? 10 : 12),

              // العنوان
              Text(
                action.title,
                style: TextStyle(
                  color: action.isPrimary
                      ? Colors.white
                      : AppColors.textPrimary,
                  fontSize: widget.compact ? 12 : 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// شبكة الإجراءات السريعة
class QuickActionGrid extends StatelessWidget {
  final List<QuickAction> actions;
  final int crossAxisCount;
  final double spacing;
  final bool compact;

  const QuickActionGrid({
    super.key,
    required this.actions,
    this.crossAxisCount = 4,
    this.spacing = 12,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 1.0,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) => QuickActionButton(
        action: actions[index],
        compact: compact,
      ),
    );
  }
}

/// صف الإجراءات السريعة (أفقي)
class QuickActionRow extends StatelessWidget {
  final List<QuickAction> actions;
  final double spacing;
  final bool compact;

  const QuickActionRow({
    super.key,
    required this.actions,
    this.spacing = 12,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < actions.length; i++) ...[
          if (i > 0) SizedBox(width: spacing),
          Expanded(
            child: QuickActionButton(
              action: actions[i],
              compact: compact,
            ),
          ),
        ],
      ],
    );
  }
}

/// الإجراءات السريعة الافتراضية
class DefaultQuickActions {
  static QuickAction newSale({VoidCallback? onTap}) {
    return QuickAction(
      id: 'new_sale',
      title: 'بيع جديد',
      icon: Icons.point_of_sale_rounded,
      color: AppColors.primary,
      isPrimary: true,
      onTap: onTap,
    );
  }

  static QuickAction addProduct({VoidCallback? onTap}) {
    return QuickAction(
      id: 'add_product',
      title: 'إضافة منتج',
      icon: Icons.add_box_rounded,
      color: const Color(0xFF8B5CF6), // Purple
      onTap: onTap,
    );
  }

  static QuickAction refund({required BuildContext context, VoidCallback? onTap}) {
    final l10n = AppLocalizations.of(context)!;
    return QuickAction(
      id: 'refund',
      title: l10n.returnLabel,
      icon: Icons.replay_rounded,
      color: const Color(0xFFF59E0B), // Amber
      onTap: onTap,
    );
  }

  static QuickAction dailyReport({VoidCallback? onTap}) {
    return QuickAction(
      id: 'daily_report',
      title: 'تقرير يومي',
      icon: Icons.summarize_rounded,
      color: const Color(0xFF3B82F6), // Blue
      onTap: onTap,
    );
  }

  static QuickAction inventory({required BuildContext context, VoidCallback? onTap, String? badge}) {
    final l10n = AppLocalizations.of(context)!;
    return QuickAction(
      id: 'inventory',
      title: l10n.inventory,
      icon: Icons.inventory_2_rounded,
      color: const Color(0xFF06B6D4), // Cyan
      badge: badge,
      onTap: onTap,
    );
  }

  static QuickAction customers({required BuildContext context, VoidCallback? onTap}) {
    final l10n = AppLocalizations.of(context)!;
    return QuickAction(
      id: 'customers',
      title: l10n.customers,
      icon: Icons.people_alt_rounded,
      color: const Color(0xFFEC4899), // Pink
      onTap: onTap,
    );
  }

  static QuickAction settings({required BuildContext context, VoidCallback? onTap}) {
    final l10n = AppLocalizations.of(context)!;
    return QuickAction(
      id: 'settings',
      title: l10n.settings,
      icon: Icons.settings_rounded,
      color: AppColors.textSecondary,
      onTap: onTap,
    );
  }

  static QuickAction closeDay({VoidCallback? onTap}) {
    return QuickAction(
      id: 'close_day',
      title: 'إغلاق اليوم',
      icon: Icons.nightlight_round,
      color: const Color(0xFF6366F1), // Indigo
      onTap: onTap,
    );
  }

  static List<QuickAction> defaultActions(BuildContext context) => [
        newSale(),
        addProduct(),
        refund(context: context),
        dailyReport(),
      ];
}

/// قسم الإجراءات السريعة مع العنوان
class QuickActionsSection extends StatelessWidget {
  final String title;
  final List<QuickAction> actions;
  final VoidCallback? onSeeAll;
  final int crossAxisCount;

  const QuickActionsSection({
    super.key,
    this.title = 'إجراءات سريعة',
    required this.actions,
    this.onSeeAll,
    this.crossAxisCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // الهيدر
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (onSeeAll != null)
              TextButton(
                onPressed: onSeeAll,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'عرض الكل',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_back_ios_rounded,
                      color: AppColors.primary,
                      size: 14,
                    ),
                  ],
                ),
              ),
          ],
        ),

        const SizedBox(height: 16),

        // الشبكة
        QuickActionGrid(
          actions: actions,
          crossAxisCount: crossAxisCount,
        ),
      ],
    );
  }
}
