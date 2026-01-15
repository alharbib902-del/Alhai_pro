import 'package:flutter/material.dart';

import '../../responsive/context_ext.dart';

/// AlhaiScaffold - Standardized screen layout with consistent padding and keyboard handling
class AlhaiScaffold extends StatelessWidget {
  /// Main body content
  final Widget body;

  /// App bar (use AlhaiAppBar)
  final PreferredSizeWidget? appBar;

  /// Bottom navigation bar
  final Widget? bottomNavigationBar;

  /// Floating action button
  final Widget? floatingActionButton;

  /// FAB location
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// Side drawer
  final Widget? drawer;

  /// End drawer (opposite side)
  final Widget? endDrawer;

  /// Apply standard page padding from context.pagePadding
  final bool applyPagePadding;

  /// Avoid keyboard (add bottom padding when keyboard appears)
  final bool avoidKeyboard;

  /// Custom padding override (replaces pagePadding if provided)
  final EdgeInsetsGeometry? paddingOverride;

  /// Background color (null = theme default)
  final Color? backgroundColor;

  /// Resize to avoid bottom inset (keyboard)
  final bool resizeToAvoidBottomInset;

  /// Extend body behind app bar
  final bool extendBodyBehindAppBar;

  /// Extend body behind bottom bar
  final bool extendBody;

  /// Drawer callback
  final DrawerCallback? onDrawerChanged;

  /// End drawer callback
  final DrawerCallback? onEndDrawerChanged;

  const AlhaiScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.drawer,
    this.endDrawer,
    this.applyPagePadding = true,
    this.avoidKeyboard = true,
    this.paddingOverride,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.extendBodyBehindAppBar = false,
    this.extendBody = false,
    this.onDrawerChanged,
    this.onEndDrawerChanged,
  });

  /// Creates a scaffold without padding (for full-screen content)
  factory AlhaiScaffold.fullScreen({
    Key? key,
    required Widget body,
    PreferredSizeWidget? appBar,
    Widget? bottomNavigationBar,
    Widget? floatingActionButton,
    FloatingActionButtonLocation? floatingActionButtonLocation,
    Widget? drawer,
    Widget? endDrawer,
    Color? backgroundColor,
    bool extendBodyBehindAppBar = false,
    bool extendBody = false,
  }) {
    return AlhaiScaffold(
      key: key,
      body: body,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      drawer: drawer,
      endDrawer: endDrawer,
      applyPagePadding: false,
      avoidKeyboard: false,
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      extendBody: extendBody,
    );
  }

  /// Creates a scaffold with scrollable body
  factory AlhaiScaffold.scrollable({
    Key? key,
    required List<Widget> children,
    PreferredSizeWidget? appBar,
    Widget? bottomNavigationBar,
    Widget? floatingActionButton,
    FloatingActionButtonLocation? floatingActionButtonLocation,
    Widget? drawer,
    Widget? endDrawer,
    bool applyPagePadding = true,
    bool avoidKeyboard = true,
    EdgeInsetsGeometry? paddingOverride,
    Color? backgroundColor,
    ScrollPhysics? physics,
  }) {
    return AlhaiScaffold(
      key: key,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      drawer: drawer,
      endDrawer: endDrawer,
      applyPagePadding: applyPagePadding,
      avoidKeyboard: avoidKeyboard,
      paddingOverride: paddingOverride,
      backgroundColor: backgroundColor,
      body: _ScrollableBody(
        children: children,
        physics: physics,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.scaffoldBackgroundColor;

    // حساب padding الأساسي
    final basePadding = (applyPagePadding || paddingOverride != null)
        ? (paddingOverride ?? context.pagePadding)
        : EdgeInsets.zero;

    // إضافة keyboard inset
    final keyboardBottom = avoidKeyboard ? context.safeKeyboardInsets.bottom : 0.0;

    // دمج padding في Padding واحد
    final effectivePadding = basePadding.add(EdgeInsets.only(bottom: keyboardBottom));

    // Build body with merged padding
    final effectiveBody = Padding(padding: effectivePadding, child: body);

    return Scaffold(
      appBar: appBar,
      body: effectiveBody,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      drawer: drawer,
      endDrawer: endDrawer,
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      extendBody: extendBody,
      onDrawerChanged: onDrawerChanged,
      onEndDrawerChanged: onEndDrawerChanged,
    );
  }
}

/// Internal scrollable body widget
class _ScrollableBody extends StatelessWidget {
  final List<Widget> children;
  final ScrollPhysics? physics;

  const _ScrollableBody({
    required this.children,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final textDirection = Directionality.of(context);
    return SingleChildScrollView(
      physics: physics,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: textDirection,
        children: children,
      ),
    );
  }
}
