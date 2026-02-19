/// Split View للشاشات المقسمة - Split View
///
/// يوفر تقسيم الشاشة بين قسمين (مثل شاشة البيع)
/// - القسم الأيسر: المنتجات
/// - القسم الأيمن: السلة
library;

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';

/// Split View Widget
class SplitView extends StatefulWidget {
  /// المحتوى الأساسي (الأكبر)
  final Widget primaryContent;

  /// المحتوى الثانوي (السلة مثلاً)
  final Widget secondaryContent;

  /// نسبة العرض للمحتوى الأساسي (0.0 - 1.0)
  final double primaryRatio;

  /// أقل عرض للمحتوى الثانوي
  final double minSecondaryWidth;

  /// أقصى عرض للمحتوى الثانوي
  final double maxSecondaryWidth;

  /// هل يمكن سحب الفاصل؟
  final bool resizable;

  /// هل يظهر المحتوى الثانوي؟
  final bool showSecondary;

  /// عند تغيير حالة العرض
  final ValueChanged<bool>? onSecondaryVisibilityChanged;

  /// اتجاه التقسيم
  final SplitViewDirection direction;

  /// عرض الفاصل
  final double dividerWidth;

  const SplitView({
    super.key,
    required this.primaryContent,
    required this.secondaryContent,
    this.primaryRatio = 0.6,
    this.minSecondaryWidth = 320,
    this.maxSecondaryWidth = 480,
    this.resizable = false,
    this.showSecondary = true,
    this.onSecondaryVisibilityChanged,
    this.direction = SplitViewDirection.horizontal,
    this.dividerWidth = 1,
  });

  @override
  State<SplitView> createState() => _SplitViewState();
}

class _SplitViewState extends State<SplitView>
    with SingleTickerProviderStateMixin {
  late double _currentRatio;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _currentRatio = widget.primaryRatio;
    _animationController = AnimationController(
      vsync: this,
      duration: AppDurations.normal,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppCurves.defaultCurve,
      ),
    );

    if (widget.showSecondary) {
      _animationController.value = 1;
    }
  }

  @override
  void didUpdateWidget(SplitView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showSecondary != oldWidget.showSecondary) {
      if (widget.showSecondary) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppBreakpoints.isDesktop(context);
    final isTablet = AppBreakpoints.isTablet(context);
    final isMobile = AppBreakpoints.isMobile(context);

    // Mobile: Stack with overlay
    if (isMobile) {
      return _buildMobileLayout();
    }

    // Tablet/Desktop: Side by side
    return _buildDesktopLayout(isTablet: isTablet, isDesktop: isDesktop);
  }

  Widget _buildDesktopLayout({
    required bool isTablet,
    required bool isDesktop,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final secondaryWidth = _calculateSecondaryWidth(totalWidth);

        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final animatedSecondaryWidth = secondaryWidth * _animation.value;

            return Row(
              children: [
                // Primary Content
                Expanded(
                  child: widget.primaryContent,
                ),

                // Divider (Resizable handle)
                if (_animation.value > 0) ...[
                  _buildDivider(),
                ],

                // Secondary Content
                if (_animation.value > 0)
                  SizedBox(
                    width: animatedSecondaryWidth,
                    child: ClipRect(
                      child: Opacity(
                        opacity: _animation.value,
                        child: widget.secondaryContent,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMobileLayout() {
    return Stack(
      children: [
        // Primary Content (always visible)
        widget.primaryContent,

        // Secondary Content (overlay)
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            if (_animation.value == 0) {
              return const SizedBox.shrink();
            }

            return Stack(
              children: [
                // Backdrop
                GestureDetector(
                  onTap: () => widget.onSecondaryVisibilityChanged?.call(false),
                  child: Container(
                    color: AppColors.overlay
                        .withValues(alpha: 0.5 * _animation.value),
                  ),
                ),

                // Secondary Panel (slide from left)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: Transform.translate(
                    offset: Offset(
                      (1 - _animation.value) *
                          MediaQuery.of(context).size.width *
                          0.85,
                      0,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        boxShadow: AppShadows.xl,
                      ),
                      child: widget.secondaryContent,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildDivider() {
    if (!widget.resizable) {
      return Container(
        width: widget.dividerWidth,
        color: AppColors.border,
      );
    }

    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        onHorizontalDragUpdate: (details) {
          setState(() {
            final totalWidth = context.size?.width ?? 0;
            final delta = details.delta.dx / totalWidth;
            _currentRatio = (_currentRatio + delta).clamp(0.3, 0.8);
          });
        },
        child: Container(
          width: 8,
          color: Colors.transparent,
          child: Center(
            child: Container(
              width: widget.dividerWidth,
              color: AppColors.border,
            ),
          ),
        ),
      ),
    );
  }

  double _calculateSecondaryWidth(double totalWidth) {
    final calculatedWidth = totalWidth * (1 - _currentRatio);
    return calculatedWidth.clamp(
      widget.minSecondaryWidth,
      widget.maxSecondaryWidth,
    );
  }
}

/// اتجاه التقسيم
enum SplitViewDirection {
  horizontal,
  vertical,
}

/// Panel Header للـ Split View
class SplitPanelHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final List<Widget>? actions;
  final VoidCallback? onClose;

  const SplitPanelHeader({
    super.key,
    required this.title,
    this.icon,
    this.actions,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Icon
          if (icon != null) ...[
            Icon(
              icon,
              size: AppIconSize.md,
              color: AppColors.primary,
            ),
            const SizedBox(width: AppSpacing.sm),
          ],

          // Title
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),

          // Actions
          if (actions != null) ...actions!,

          // Close Button (for mobile)
          if (onClose != null)
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close),
              iconSize: AppIconSize.md,
              color: AppColors.textSecondary,
            ),
        ],
      ),
    );
  }
}
