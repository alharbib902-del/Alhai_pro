import 'package:flutter/material.dart';

import '../../tokens/alhai_colors.dart';
import '../../tokens/alhai_spacing.dart';

/// AlhaiCheckbox - Checkbox with optional label and subtitle
///
/// Features:
/// - Optional label and subtitle
/// - Tristate support
/// - Full row tappable
/// - RTL-safe layout
/// - Dark mode support
class AlhaiCheckbox extends StatelessWidget {
  /// Checkbox value (null for indeterminate when tristate)
  final bool? value;

  /// Enable indeterminate (null) state
  final bool tristate;

  /// Value change callback
  final ValueChanged<bool?>? onChanged;

  /// Whether checkbox is enabled
  final bool enabled;

  /// Optional label text
  final String? label;

  /// Optional subtitle text
  final String? subtitle;

  /// Custom padding
  final EdgeInsetsGeometry? padding;

  const AlhaiCheckbox({
    super.key,
    required this.value,
    this.tristate = false,
    this.onChanged,
    this.enabled = true,
    this.label,
    this.subtitle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textDirection = Directionality.of(context);
    final isDisabled = !enabled || onChanged == null;

    final effectivePadding =
        padding ??
        const EdgeInsetsDirectional.symmetric(
          horizontal: AlhaiSpacing.md,
          vertical: AlhaiSpacing.sm,
        );

    // Effective value for non-tristate mode
    final effectiveValue = tristate ? value : (value ?? false);

    // Build checkbox
    final checkbox = Checkbox(
      value: effectiveValue,
      tristate: tristate,
      onChanged: isDisabled ? null : onChanged,
      activeColor: colorScheme.primary,
      checkColor: colorScheme.onPrimary,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );

    // No label - just checkbox
    if (label == null && subtitle == null) {
      return Padding(padding: effectivePadding, child: checkbox);
    }

    // With label/subtitle
    return MergeSemantics(
      child: Semantics(
        checked: effectiveValue == true,
        mixed: tristate && value == null,
        enabled: !isDisabled,
        child: Opacity(
          opacity: isDisabled ? AlhaiColors.disabledOpacity : 1.0,
          child: Material(
            color: AlhaiColors.transparent,
            child: InkWell(
              onTap: isDisabled ? null : () => _handleTap(),
              child: Padding(
                padding: effectivePadding,
                child: Row(
                  textDirection: textDirection,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Checkbox
                    checkbox,
                    const SizedBox(width: AlhaiSpacing.sm),
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap() {
    if (onChanged == null) return;

    if (tristate) {
      // null -> true -> false -> null
      if (value == null) {
        onChanged!(true);
      } else if (value == true) {
        onChanged!(false);
      } else {
        onChanged!(null);
      }
    } else {
      onChanged!(!(value ?? false));
    }
  }
}
