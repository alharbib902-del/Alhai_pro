import 'package:flutter/material.dart';

import '../../tokens/alhai_radius.dart';

/// Alhai Badge - Notification badge with count or dot
class AlhaiBadge extends StatelessWidget {
  /// Badge count (0 = hidden, null = dot only)
  final int? count;

  /// Maximum count before showing "99+"
  final int maxCount;

  /// Background color
  final Color? backgroundColor;

  /// Text color
  final Color? textColor;

  /// Size of the badge
  final AlhaiBadgeSize size;

  /// Show badge (false = hidden)
  final bool show;

  /// Child widget to badge
  final Widget? child;

  /// Alignment of badge on child
  final AlignmentGeometry alignment;

  /// Offset from alignment
  final Offset offset;

  const AlhaiBadge({
    super.key,
    this.count,
    this.maxCount = 99,
    this.backgroundColor,
    this.textColor,
    this.size = AlhaiBadgeSize.medium,
    this.show = true,
    this.child,
    this.alignment = AlignmentDirectional.topEnd, // RTL-safe
    this.offset = Offset.zero,
  });

  /// Dot badge factory
  factory AlhaiBadge.dot({
    Key? key,
    Color? backgroundColor,
    bool show = true,
    Widget? child,
    AlignmentGeometry alignment = AlignmentDirectional.topEnd,
    Offset offset = Offset.zero,
  }) {
    return AlhaiBadge(
      key: key,
      count: null,
      backgroundColor: backgroundColor,
      size: AlhaiBadgeSize.small,
      show: show,
      child: child,
      alignment: alignment,
      offset: offset,
    );
  }

  /// Count badge factory
  factory AlhaiBadge.count({
    Key? key,
    required int count,
    int maxCount = 99,
    Color? backgroundColor,
    Color? textColor,
    AlhaiBadgeSize size = AlhaiBadgeSize.medium,
    Widget? child,
    AlignmentGeometry alignment = AlignmentDirectional.topEnd,
    Offset offset = Offset.zero,
  }) {
    return AlhaiBadge(
      key: key,
      count: count,
      maxCount: maxCount,
      backgroundColor: backgroundColor,
      textColor: textColor,
      size: size,
      show: count > 0,
      child: child,
      alignment: alignment,
      offset: offset,
    );
  }

  @override
  Widget build(BuildContext context) {
    // حماية من count <= 0
    if (!show || (count != null && count! <= 0)) {
      return child ?? const SizedBox.shrink();
    }

    final badge = _buildBadge(context);

    if (child == null) {
      return badge;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child!,
        Positioned.fill(
          child: Align(
            alignment: alignment,
            child: Transform.translate(
              offset: offset,
              child: badge,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bgColor = backgroundColor ?? colorScheme.error;
    final fgColor = textColor ?? colorScheme.onError;

    // Dot badge
    if (count == null) {
      return Container(
        width: size.dotSize,
        height: size.dotSize,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
      );
    }

    // Count badge
    final displayText = count! > maxCount ? '$maxCount+' : count.toString();

    return Container(
      constraints: BoxConstraints(
        minWidth: size.minWidth,
        minHeight: size.height,
      ),
      padding: EdgeInsets.symmetric(horizontal: size.horizontalPadding),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AlhaiRadius.full),
      ),
      child: Center(
        child: Text(
          displayText,
          style: TextStyle(
            color: fgColor,
            fontSize: size.fontSize,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
      ),
    );
  }
}

/// Badge size variants
enum AlhaiBadgeSize {
  small,
  medium,
  large;

  double get dotSize {
    switch (this) {
      case AlhaiBadgeSize.small:
        return 6;
      case AlhaiBadgeSize.medium:
        return 8;
      case AlhaiBadgeSize.large:
        return 10;
    }
  }

  double get minWidth {
    switch (this) {
      case AlhaiBadgeSize.small:
        return 14;
      case AlhaiBadgeSize.medium:
        return 18;
      case AlhaiBadgeSize.large:
        return 22;
    }
  }

  double get height {
    switch (this) {
      case AlhaiBadgeSize.small:
        return 14;
      case AlhaiBadgeSize.medium:
        return 18;
      case AlhaiBadgeSize.large:
        return 22;
    }
  }

  double get fontSize {
    switch (this) {
      case AlhaiBadgeSize.small:
        return 9;
      case AlhaiBadgeSize.medium:
        return 11;
      case AlhaiBadgeSize.large:
        return 13;
    }
  }

  double get horizontalPadding {
    switch (this) {
      case AlhaiBadgeSize.small:
        return 3;
      case AlhaiBadgeSize.medium:
        return 4;
      case AlhaiBadgeSize.large:
        return 5;
    }
  }
}
