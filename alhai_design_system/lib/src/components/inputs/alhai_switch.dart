import 'package:flutter/material.dart';

import '../../tokens/alhai_colors.dart';
import '../../tokens/alhai_spacing.dart';

/// AlhaiSwitch - Switch with optional label and subtitle
/// 
/// Features:
/// - Optional label and subtitle
/// - Optional leading widget
/// - Full row tappable
/// - RTL-safe layout
/// - Dark mode support
class AlhaiSwitch extends StatelessWidget {
  /// Switch value
  final bool value;

  /// Value change callback
  final ValueChanged<bool>? onChanged;

  /// Whether switch is enabled
  final bool enabled;

  /// Optional label text
  final String? label;

  /// Optional subtitle text
  final String? subtitle;

  /// Optional leading widget (e.g., icon)
  final Widget? leading;

  /// Custom padding
  final EdgeInsetsGeometry? padding;

  const AlhaiSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.enabled = true,
    this.label,
    this.subtitle,
    this.leading,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textDirection = Directionality.of(context);
    final isDisabled = !enabled || onChanged == null;

    final effectivePadding = padding ??
        const EdgeInsetsDirectional.symmetric(
          horizontal: AlhaiSpacing.md,
          vertical: AlhaiSpacing.sm,
        );

    // Build switch
    final switchWidget = Switch(
      value: value,
      onChanged: isDisabled ? null : onChanged,
      activeThumbColor: colorScheme.primary,
      activeTrackColor: colorScheme.primaryContainer,
      inactiveThumbColor: colorScheme.outline,
      inactiveTrackColor: colorScheme.surfaceContainerHighest,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    // No label - just switch
    if (label == null && subtitle == null && leading == null) {
      return Padding(
        padding: effectivePadding,
        child: switchWidget,
      );
    }

    // With label/subtitle
    return MergeSemantics(
      child: Semantics(
        toggled: value,
        enabled: !isDisabled,
        child: Opacity(
          opacity: isDisabled ? AlhaiColors.disabledOpacity : 1.0,
          child: Material(
            color: AlhaiColors.transparent,
            child: InkWell(
              onTap: isDisabled ? null : () => onChanged?.call(!value),
              child: Padding(
                padding: effectivePadding,
                child: Row(
                  textDirection: textDirection,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Leading
                    if (leading != null) ...[
                      IconTheme(
                        data: IconThemeData(
                          color: colorScheme.onSurfaceVariant,
                          size: AlhaiSpacing.lg,
                        ),
                        child: leading!,
                      ),
                      const SizedBox(width: AlhaiSpacing.md),
                    ],
                    // Text content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (label != null)
                            Text(
                              label!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                              textDirection: textDirection,
                            ),
                          if (subtitle != null) ...[
                            const SizedBox(height: AlhaiSpacing.xxxs),
                            Text(
                              subtitle!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              textDirection: textDirection,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: AlhaiSpacing.md),
                    // Switch
                    switchWidget,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
