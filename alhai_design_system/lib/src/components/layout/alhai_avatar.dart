import 'package:flutter/material.dart';

import '../../tokens/alhai_colors.dart';
import '../../tokens/alhai_radius.dart';
import '../../tokens/alhai_spacing.dart';
import '../../theme/theme_extensions.dart';

/// Avatar size variants
enum AlhaiAvatarSize {
  /// 24dp
  xs,

  /// 32dp
  sm,

  /// 40dp (default)
  md,

  /// 56dp
  lg,

  /// 80dp
  xl,
}

/// Avatar shape variants
enum AlhaiAvatarShape {
  /// Circle (default)
  circle,

  /// Rounded rectangle
  rounded,
}

/// AlhaiAvatar - Standardized avatar component
class AlhaiAvatar extends StatelessWidget {
  /// Image provider
  final ImageProvider? image;

  /// Initials text (2 chars max)
  final String? initials;

  /// Fallback icon
  final IconData? fallbackIcon;

  /// Avatar size
  final AlhaiAvatarSize size;

  /// Avatar shape
  final AlhaiAvatarShape shape;

  /// Optional badge widget (positioned topEnd, RTL-safe)
  final Widget? badge;

  /// Show online status dot
  final bool showOnlineDot;

  /// Background color override
  final Color? backgroundColorOverride;

  /// Foreground color override
  final Color? foregroundColorOverride;

  const AlhaiAvatar({
    super.key,
    this.image,
    this.initials,
    this.fallbackIcon,
    this.size = AlhaiAvatarSize.md,
    this.shape = AlhaiAvatarShape.circle,
    this.badge,
    this.showOnlineDot = false,
    this.backgroundColorOverride,
    this.foregroundColorOverride,
  });

  /// Image avatar factory
  factory AlhaiAvatar.image({
    Key? key,
    required ImageProvider image,
    AlhaiAvatarSize size = AlhaiAvatarSize.md,
    AlhaiAvatarShape shape = AlhaiAvatarShape.circle,
    Widget? badge,
    bool showOnlineDot = false,
  }) {
    return AlhaiAvatar(
      key: key,
      image: image,
      size: size,
      shape: shape,
      badge: badge,
      showOnlineDot: showOnlineDot,
    );
  }

  /// Initials avatar factory
  factory AlhaiAvatar.initials({
    Key? key,
    required String initials,
    AlhaiAvatarSize size = AlhaiAvatarSize.md,
    AlhaiAvatarShape shape = AlhaiAvatarShape.circle,
    Widget? badge,
    bool showOnlineDot = false,
    Color? backgroundColorOverride,
    Color? foregroundColorOverride,
  }) {
    return AlhaiAvatar(
      key: key,
      initials: initials,
      size: size,
      shape: shape,
      badge: badge,
      showOnlineDot: showOnlineDot,
      backgroundColorOverride: backgroundColorOverride,
      foregroundColorOverride: foregroundColorOverride,
    );
  }

  /// Icon avatar factory
  factory AlhaiAvatar.icon({
    Key? key,
    IconData icon = Icons.person,
    AlhaiAvatarSize size = AlhaiAvatarSize.md,
    AlhaiAvatarShape shape = AlhaiAvatarShape.circle,
    Widget? badge,
    bool showOnlineDot = false,
    Color? backgroundColorOverride,
    Color? foregroundColorOverride,
  }) {
    return AlhaiAvatar(
      key: key,
      fallbackIcon: icon,
      size: size,
      shape: shape,
      badge: badge,
      showOnlineDot: showOnlineDot,
      backgroundColorOverride: backgroundColorOverride,
      foregroundColorOverride: foregroundColorOverride,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColors = theme.extension<AlhaiStatusColors>();

    // Get dimensions
    final diameter = _getDiameter();
    final fontSize = _getFontSize();
    final iconSize = _getIconSize();

    // Get colors
    final backgroundColor =
        backgroundColorOverride ?? colorScheme.secondaryContainer;
    final foregroundColor =
        foregroundColorOverride ?? colorScheme.onSecondaryContainer;

    // Get border radius
    final borderRadius = shape == AlhaiAvatarShape.circle
        ? BorderRadius.circular(AlhaiRadius.full)
        : BorderRadius.circular(AlhaiRadius.md);

    // Build avatar content
    Widget avatarContent;

    if (image != null) {
      // Image avatar
      avatarContent = Image(
        image: image!,
        fit: BoxFit.cover,
        width: diameter,
        height: diameter,
        errorBuilder: (context, error, stackTrace) {
          // Fallback on error
          return _buildFallbackContent(
            theme,
            foregroundColor,
            fontSize,
            iconSize,
          );
        },
      );
    } else {
      // Initials or icon
      avatarContent = _buildFallbackContent(
        theme,
        foregroundColor,
        fontSize,
        iconSize,
      );
    }

    // Build avatar container
    Widget avatar = Material(
      color: backgroundColor,
      surfaceTintColor: AlhaiColors.transparent,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: Center(child: avatarContent),
      ),
    );

    // Add badge or online dot
    if (badge != null || showOnlineDot) {
      avatar = Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,

          // Badge (topEnd, RTL-safe)
          if (badge != null)
            PositionedDirectional(top: 0, end: 0, child: badge!),

          // Online dot
          if (showOnlineDot && badge == null)
            PositionedDirectional(
              bottom: 0,
              end: 0,
              child: Container(
                width: AlhaiSpacing.onlineDotSize,
                height: AlhaiSpacing.onlineDotSize,
                decoration: BoxDecoration(
                  color: statusColors?.success ?? colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.surface,
                    width: AlhaiSpacing.strokeSm,
                  ),
                ),
              ),
            ),
        ],
      );
    }

    return avatar;
  }

  Widget _buildFallbackContent(
    ThemeData theme,
    Color foregroundColor,
    double fontSize,
    double iconSize,
  ) {
    if (initials != null && initials!.isNotEmpty) {
      // Take first 2 characters (no toUpperCase for Arabic support)
      final displayInitials = initials!.length > 2
          ? initials!.substring(0, 2)
          : initials!;

      return Text(
        displayInitials,
        style: theme.textTheme.labelLarge?.copyWith(
          color: foregroundColor,
          fontSize: fontSize,
        ),
      );
    }

    // Icon fallback
    return Icon(
      fallbackIcon ?? Icons.person,
      size: iconSize,
      color: foregroundColor,
    );
  }

  double _getDiameter() {
    switch (size) {
      case AlhaiAvatarSize.xs:
        return AlhaiSpacing.avatarXs;
      case AlhaiAvatarSize.sm:
        return AlhaiSpacing.avatarSm;
      case AlhaiAvatarSize.md:
        return AlhaiSpacing.avatarMd;
      case AlhaiAvatarSize.lg:
        return AlhaiSpacing.avatarLg;
      case AlhaiAvatarSize.xl:
        return AlhaiSpacing.avatarXl;
    }
  }

  double _getFontSize() {
    switch (size) {
      case AlhaiAvatarSize.xs:
        return AlhaiSpacing.avatarFontXs;
      case AlhaiAvatarSize.sm:
        return AlhaiSpacing.avatarFontSm;
      case AlhaiAvatarSize.md:
        return AlhaiSpacing.avatarFontMd;
      case AlhaiAvatarSize.lg:
        return AlhaiSpacing.avatarFontLg;
      case AlhaiAvatarSize.xl:
        return AlhaiSpacing.avatarFontXl;
    }
  }

  double _getIconSize() {
    switch (size) {
      case AlhaiAvatarSize.xs:
        return AlhaiSpacing.avatarIconXs;
      case AlhaiAvatarSize.sm:
        return AlhaiSpacing.avatarIconSm;
      case AlhaiAvatarSize.md:
        return AlhaiSpacing.avatarIconMd;
      case AlhaiAvatarSize.lg:
        return AlhaiSpacing.avatarIconLg;
      case AlhaiAvatarSize.xl:
        return AlhaiSpacing.avatarIconXl;
    }
  }
}
