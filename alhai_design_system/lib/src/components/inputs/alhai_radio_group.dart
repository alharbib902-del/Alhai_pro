import 'package:flutter/material.dart';

import '../../tokens/alhai_colors.dart';
import '../../tokens/alhai_spacing.dart';

/// Radio option data model
class AlhaiRadioOption<T> {
  /// Option value
  final T value;

  /// Label text
  final String label;

  /// Optional subtitle text
  final String? subtitle;

  /// Whether this option is enabled
  final bool enabled;

  /// Optional leading widget
  final Widget? leading;

  const AlhaiRadioOption({
    required this.value,
    required this.label,
    this.subtitle,
    this.enabled = true,
    this.leading,
  });
}

/// AlhaiRadioGroup - Radio button group with options
/// 
/// Features:
/// - Vertical and horizontal layouts
/// - Optional subtitle per option
/// - Optional leading widget per option
/// - Full row tappable
/// - RTL-safe layout
/// - Dark mode support
class AlhaiRadioGroup<T> extends StatelessWidget {
  /// Currently selected value
  final T? value;

  /// Available options
  final List<AlhaiRadioOption<T>> options;

  /// Value change callback
  final ValueChanged<T>? onChanged;

  /// Layout direction
  final Axis direction;

  /// Whether entire group is enabled
  final bool enabled;

  /// Custom padding for each option
  final EdgeInsetsGeometry? padding;

  /// Spacing between options
  final double? spacing;

  const AlhaiRadioGroup({
    super.key,
    required this.value,
    required this.options,
    this.onChanged,
    this.direction = Axis.vertical,
    this.enabled = true,
    this.padding,
    this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSpacing = spacing ?? AlhaiSpacing.xs;

    final content = direction == Axis.horizontal
        ? Wrap(
            spacing: effectiveSpacing,
            runSpacing: effectiveSpacing,
            children: [
              for (final option in options)
                _RadioOptionWidget<T>(
                  option: option,
                  groupValue: value,
                  isGroupEnabled: enabled,
                  onTap: onChanged,
                  padding: padding,
                ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < options.length; i++) ...[
                if (i > 0) SizedBox(height: effectiveSpacing),
                _RadioOptionWidget<T>(
                  option: options[i],
                  groupValue: value,
                  isGroupEnabled: enabled,
                  onTap: onChanged,
                  padding: padding,
                ),
              ],
            ],
          );

    return RadioGroup<T>(
      groupValue: value,
      onChanged: (T? newValue) {
        if (newValue != null && onChanged != null && enabled) {
          onChanged!(newValue);
        }
      },
      child: content,
    );
  }
}

/// Internal radio option widget
class _RadioOptionWidget<T> extends StatelessWidget {
  final AlhaiRadioOption<T> option;
  final T? groupValue;
  final bool isGroupEnabled;
  final ValueChanged<T>? onTap;
  final EdgeInsetsGeometry? padding;

  const _RadioOptionWidget({
    required this.option,
    required this.groupValue,
    required this.isGroupEnabled,
    required this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = groupValue == option.value;
    final isDisabled = !isGroupEnabled || !option.enabled || onTap == null;

    final effectivePadding = padding ??
        const EdgeInsetsDirectional.symmetric(
          horizontal: AlhaiSpacing.md,
          vertical: AlhaiSpacing.sm,
        );

    // Build radio - groupValue and onChanged managed by RadioGroup ancestor
    final radio = Radio<T>(
      value: option.value,
      activeColor: colorScheme.primary,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );

    return MergeSemantics(
      child: Semantics(
        selected: isSelected,
        enabled: !isDisabled,
        inMutuallyExclusiveGroup: true,
        child: Opacity(
          opacity: isDisabled ? AlhaiColors.disabledOpacity : 1.0,
          child: Material(
            color: AlhaiColors.transparent,
            child: InkWell(
              onTap: isDisabled ? null : () => onTap?.call(option.value),
              child: Padding(
                padding: effectivePadding,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Radio
                    radio,
                    const SizedBox(width: AlhaiSpacing.sm),
                    // Leading
                    if (option.leading != null) ...[
                      IconTheme(
                        data: IconThemeData(
                          color: colorScheme.onSurfaceVariant,
                          size: AlhaiSpacing.lg,
                        ),
                        child: option.leading!,
                      ),
                      const SizedBox(width: AlhaiSpacing.sm),
                    ],
                    // Text content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            option.label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                          if (option.subtitle != null) ...[
                            const SizedBox(height: AlhaiSpacing.xxxs),
                            Text(
                              option.subtitle!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
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
}
