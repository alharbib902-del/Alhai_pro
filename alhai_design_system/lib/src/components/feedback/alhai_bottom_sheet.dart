import 'package:flutter/material.dart';

import '../../tokens/alhai_radius.dart';
import '../../tokens/alhai_spacing.dart';
import '../../responsive/context_ext.dart';

/// Bottom sheet size variants
enum AlhaiBottomSheetSize {
  /// Wrap content up to max height (85%)
  auto,

  /// Approximately 55% of screen height
  half,

  /// Approximately 92% of screen height
  full,
}

/// AlhaiBottomSheet - Unified Bottom Sheet component with standard header and actions
class AlhaiBottomSheet extends StatelessWidget {
  /// Main content
  final Widget child;

  /// Optional title in header
  final String? title;

  /// Optional action buttons at bottom
  final List<Widget>? actions;

  /// Bottom sheet size
  final AlhaiBottomSheetSize size;

  /// Show close button in header
  final bool showCloseButton;

  /// Close button callback
  final VoidCallback? onClose;

  /// Padding override (null = context.pagePadding)
  final EdgeInsetsGeometry? paddingOverride;

  /// Border radius override
  final BorderRadius? borderRadiusOverride;

  /// Close tooltip (null = MaterialLocalizations default)
  final String? closeTooltip;

  const AlhaiBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.size = AlhaiBottomSheetSize.auto,
    this.showCloseButton = true,
    this.onClose,
    this.paddingOverride,
    this.borderRadiusOverride,
    this.closeTooltip,
  });

  /// Show bottom sheet
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    List<Widget>? actions,
    AlhaiBottomSheetSize size = AlhaiBottomSheetSize.auto,
    bool isDismissible = true,
    bool enableDrag = true,
    bool showCloseButton = true,
    EdgeInsetsGeometry? paddingOverride,
    BorderRadius? borderRadiusOverride,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor:
          Colors.transparent, // استثناء تقني: لعرض Container بزوايا
      builder: (sheetContext) => AlhaiBottomSheet(
        title: title,
        actions: actions,
        size: size,
        showCloseButton: showCloseButton,
        onClose: () => Navigator.pop(sheetContext),
        paddingOverride: paddingOverride,
        borderRadiusOverride: borderRadiusOverride,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);

    // حساب الارتفاع حسب الحجم (DS standard heights)
    final screenHeight = mediaQuery.size.height;
    final maxHeight = _getMaxHeight(size, screenHeight);

    // حساب padding من context أو override
    final basePadding = paddingOverride ?? context.pagePadding;
    final keyboardBottom = context.safeKeyboardInsets.bottom;

    // Border radius
    final borderRadius =
        borderRadiusOverride ??
        const BorderRadius.vertical(
          top: Radius.circular(AlhaiRadius.bottomSheet),
        );

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Material(
        color: colorScheme.surface,
        surfaceTintColor: Colors.transparent, // تعطيل Material 3 tint
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            _buildDragHandle(colorScheme),

            // Header
            if (title != null || showCloseButton)
              _buildHeader(context, theme, basePadding),

            // Content
            Flexible(
              child: SingleChildScrollView(padding: basePadding, child: child),
            ),

            // Actions
            if (actions != null && actions!.isNotEmpty)
              _buildActions(basePadding, keyboardBottom),

            // Keyboard spacing (when no actions)
            if ((actions == null || actions!.isEmpty) && keyboardBottom > 0)
              SizedBox(height: keyboardBottom),
          ],
        ),
      ),
    );
  }

  /// DS standard heights
  double _getMaxHeight(AlhaiBottomSheetSize size, double screenHeight) {
    switch (size) {
      case AlhaiBottomSheetSize.auto:
        return screenHeight * 0.85;
      case AlhaiBottomSheetSize.half:
        return screenHeight * 0.55;
      case AlhaiBottomSheetSize.full:
        return screenHeight * 0.92;
    }
  }

  Widget _buildDragHandle(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(top: AlhaiSpacing.sm),
      width: AlhaiSpacing.dragHandleWidth,
      height: AlhaiSpacing.dragHandleHeight,
      decoration: BoxDecoration(
        color: colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(AlhaiRadius.full),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    EdgeInsetsGeometry basePadding,
  ) {
    final tooltip =
        closeTooltip ?? MaterialLocalizations.of(context).closeButtonTooltip;

    // استخدام helper للـ resolve
    final resolved = context.resolvePadding(basePadding);
    final headerPadding = EdgeInsetsDirectional.only(
      start: resolved.left,
      end: resolved.right,
      top: AlhaiSpacing.sm,
      bottom: AlhaiSpacing.xs,
    );

    return Padding(
      padding: headerPadding,
      child: Row(
        children: [
          // Title
          if (title != null)
            Expanded(child: Text(title!, style: theme.textTheme.titleMedium))
          else
            const Spacer(),

          // Close button
          if (showCloseButton)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: onClose,
              tooltip: tooltip,
            ),
        ],
      ),
    );
  }

  Widget _buildActions(EdgeInsetsGeometry basePadding, double keyboardBottom) {
    return Padding(
      padding: basePadding.add(
        EdgeInsets.only(
          top: AlhaiSpacing.sm,
          bottom: keyboardBottom > 0 ? keyboardBottom : AlhaiSpacing.md,
        ),
      ),
      child: Wrap(
        spacing: AlhaiSpacing.sm,
        runSpacing: AlhaiSpacing.sm,
        alignment: WrapAlignment.end,
        children: actions!,
      ),
    );
  }
}
