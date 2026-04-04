import 'package:flutter/material.dart';

import '../../tokens/alhai_spacing.dart';

/// Label position for divider with label
enum AlhaiDividerLabelPosition {
  /// Label at start (RTL-aware)
  start,

  /// Label at center
  center,

  /// Label at end (RTL-aware)
  end,
}

/// AlhaiDivider - Unified visual separator
///
/// Features:
/// - Horizontal and vertical variants
/// - Optional label with position
/// - RTL-safe indent
/// - Token-based sizing/colors
/// - Dark mode support
class AlhaiDivider extends StatelessWidget {
  /// Thickness of the divider line
  final double thickness;

  /// Start indent (RTL-aware for horizontal)
  final double indent;

  /// End indent (RTL-aware for horizontal)
  final double endIndent;

  /// Custom color (uses token default if null)
  final Color? color;

  /// Whether this is a vertical divider
  final bool _isVertical;

  /// Height for vertical divider
  final double? _height;

  /// Label for withLabel variant
  final String? _label;

  /// Label position
  final AlhaiDividerLabelPosition? _labelPosition;

  /// Custom text style for label
  final TextStyle? _textStyle;

  /// Default horizontal divider
  const AlhaiDivider({
    super.key,
    this.thickness = AlhaiSpacing.strokeXs,
    this.indent = 0,
    this.endIndent = 0,
    this.color,
  })  : _isVertical = false,
        _height = null,
        _label = null,
        _labelPosition = null,
        _textStyle = null;

  /// Horizontal divider with full control
  const AlhaiDivider.horizontal({
    super.key,
    this.thickness = AlhaiSpacing.strokeXs,
    this.indent = 0,
    this.endIndent = 0,
    this.color,
  })  : _isVertical = false,
        _height = null,
        _label = null,
        _labelPosition = null,
        _textStyle = null;

  /// Vertical divider
  const AlhaiDivider.vertical({
    super.key,
    double height = 24,
    this.thickness = AlhaiSpacing.strokeXs,
    this.indent = 0,
    this.endIndent = 0,
    this.color,
  })  : _isVertical = true,
        _height = height,
        _label = null,
        _labelPosition = null,
        _textStyle = null;

  /// Divider with label (e.g., "or")
  const AlhaiDivider.withLabel({
    super.key,
    required String label,
    AlhaiDividerLabelPosition position = AlhaiDividerLabelPosition.center,
    TextStyle? textStyle,
    this.thickness = AlhaiSpacing.strokeXs,
    this.indent = 0,
    this.endIndent = 0,
    this.color,
  })  : _isVertical = false,
        _height = null,
        _label = label,
        _labelPosition = position,
        _textStyle = textStyle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveColor = color ?? colorScheme.outlineVariant;

    // Vertical divider
    if (_isVertical) {
      return _buildVertical(effectiveColor);
    }

    // With label
    if (_label != null && _label!.trim().isNotEmpty) {
      return _buildWithLabel(context, effectiveColor);
    }

    // Default horizontal
    return _buildHorizontal(effectiveColor);
  }

  Widget _buildHorizontal(Color effectiveColor) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: indent,
        end: endIndent,
      ),
      child: Container(
        height: thickness,
        color: effectiveColor,
      ),
    );
  }

  Widget _buildVertical(Color effectiveColor) {
    return SizedBox(
      height: _height,
      child: Padding(
        padding: EdgeInsets.only(
          top: indent,
          bottom: endIndent,
        ),
        child: Center(
          child: Container(
            width: thickness,
            height: double.infinity,
            color: effectiveColor,
          ),
        ),
      ),
    );
  }

  Widget _buildWithLabel(BuildContext context, Color effectiveColor) {
    final theme = Theme.of(context);
    final textDirection = Directionality.of(context);

    final effectiveTextStyle = _textStyle ??
        theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        );

    final position = _labelPosition ?? AlhaiDividerLabelPosition.center;
    final isRtl = textDirection == TextDirection.rtl;

    // RTL-aware: determine which visual side to hide
    final hideLeftLine =
        (!isRtl && position == AlhaiDividerLabelPosition.start) ||
            (isRtl && position == AlhaiDividerLabelPosition.end);

    final hideRightLine =
        (!isRtl && position == AlhaiDividerLabelPosition.end) ||
            (isRtl && position == AlhaiDividerLabelPosition.start);

    Widget line() => Container(height: thickness, color: effectiveColor);

    return Padding(
      padding: EdgeInsetsDirectional.only(start: indent, end: endIndent),
      child: Row(
        children: [
          if (hideLeftLine)
            const SizedBox.shrink()
          else
            Expanded(child: line()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.sm),
            child: Text(_label!, style: effectiveTextStyle),
          ),
          if (hideRightLine)
            const SizedBox.shrink()
          else
            Expanded(child: line()),
        ],
      ),
    );
  }
}
