import 'package:flutter/material.dart';

import '../tokens/alhai_breakpoints.dart';

/// Responsive builder widget for adaptive layouts
class ResponsiveBuilder extends StatelessWidget {
  /// Builder for mobile layout
  final Widget Function(BuildContext context) mobile;

  /// Builder for tablet layout (optional, falls back to mobile)
  final Widget Function(BuildContext context)? tablet;

  /// Builder for desktop layout (optional, falls back to tablet or mobile)
  final Widget Function(BuildContext context)? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (AlhaiBreakpoints.isDesktop(width) && desktop != null) {
          return desktop!(context);
        }
        if (AlhaiBreakpoints.isTablet(width) && tablet != null) {
          return tablet!(context);
        }
        return mobile(context);
      },
    );
  }
}

/// Responsive value widget - rebuilds when breakpoint changes
class ResponsiveValue<T> extends StatelessWidget {
  /// Value for mobile
  final T mobile;

  /// Value for tablet (optional)
  final T? tablet;

  /// Value for desktop (optional)
  final T? desktop;

  /// Builder with responsive value
  final Widget Function(BuildContext context, T value) builder;

  const ResponsiveValue({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        T value;

        if (AlhaiBreakpoints.isDesktop(width) && desktop != null) {
          value = desktop!;
        } else if (AlhaiBreakpoints.isTablet(width) && tablet != null) {
          value = tablet!;
        } else {
          value = mobile;
        }

        return builder(context, value);
      },
    );
  }
}

/// Responsive visibility widget - shows/hides based on breakpoint
class ResponsiveVisibility extends StatelessWidget {
  /// Child widget
  final Widget child;

  /// Show on mobile
  final bool visibleOnMobile;

  /// Show on tablet
  final bool visibleOnTablet;

  /// Show on desktop
  final bool visibleOnDesktop;

  /// Widget to show when hidden (optional, defaults to SizedBox.shrink)
  final Widget? replacement;

  const ResponsiveVisibility({
    super.key,
    required this.child,
    this.visibleOnMobile = true,
    this.visibleOnTablet = true,
    this.visibleOnDesktop = true,
    this.replacement,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        bool visible;

        if (AlhaiBreakpoints.isDesktop(width)) {
          visible = visibleOnDesktop;
        } else if (AlhaiBreakpoints.isTablet(width)) {
          visible = visibleOnTablet;
        } else {
          visible = visibleOnMobile;
        }

        return visible ? child : (replacement ?? const SizedBox.shrink());
      },
    );
  }
}

/// Responsive row/column - switches between Row and Column based on width
class ResponsiveRowColumn extends StatelessWidget {
  /// Children widgets
  final List<Widget> children;

  /// Use row on tablet and above
  final bool rowOnTablet;

  /// Use row on desktop only
  final bool rowOnDesktopOnly;

  /// Main axis alignment for row
  final MainAxisAlignment rowMainAxisAlignment;

  /// Cross axis alignment for row
  final CrossAxisAlignment rowCrossAxisAlignment;

  /// Main axis alignment for column
  final MainAxisAlignment columnMainAxisAlignment;

  /// Cross axis alignment for column
  final CrossAxisAlignment columnCrossAxisAlignment;

  /// Spacing between children
  final double spacing;

  const ResponsiveRowColumn({
    super.key,
    required this.children,
    this.rowOnTablet = true,
    this.rowOnDesktopOnly = false,
    this.rowMainAxisAlignment = MainAxisAlignment.start,
    this.rowCrossAxisAlignment = CrossAxisAlignment.center,
    this.columnMainAxisAlignment = MainAxisAlignment.start,
    this.columnCrossAxisAlignment = CrossAxisAlignment.stretch,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final bool useRow;

        if (rowOnDesktopOnly) {
          useRow = AlhaiBreakpoints.isDesktop(width);
        } else if (rowOnTablet) {
          useRow = !AlhaiBreakpoints.isMobile(width);
        } else {
          useRow = false;
        }

        if (useRow) {
          return Row(
            mainAxisAlignment: rowMainAxisAlignment,
            crossAxisAlignment: rowCrossAxisAlignment,
            children: _addSpacing(children, spacing, Axis.horizontal),
          );
        }

        return Column(
          mainAxisAlignment: columnMainAxisAlignment,
          crossAxisAlignment: columnCrossAxisAlignment,
          children: _addSpacing(children, spacing, Axis.vertical),
        );
      },
    );
  }

  List<Widget> _addSpacing(List<Widget> children, double spacing, Axis axis) {
    if (children.isEmpty) return children;

    final spacer = axis == Axis.horizontal
        ? SizedBox(width: spacing)
        : SizedBox(height: spacing);

    final result = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(spacer);
      }
    }
    return result;
  }
}
