import 'package:flutter/material.dart';

import '../../tokens/alhai_spacing.dart';

/// AlhaiAppBar - Custom AppBar with RTL support and search mode
class AlhaiAppBar extends StatefulWidget implements PreferredSizeWidget {
  /// Main title text
  final String title;

  /// Optional subtitle below title
  final String? subtitle;

  /// Action widgets on the end side
  final List<Widget>? actions;

  /// Show automatic back button
  final bool showBackButton;

  /// Custom back button callback (null = Navigator.pop)
  final VoidCallback? onBackPressed;

  /// Enable search functionality
  final bool enableSearch;

  /// Start with search mode open
  final bool startInSearchMode;

  /// Search hint text (null = default from theme)
  final String? searchHint;

  /// Search tooltip text (null = default)
  final String? searchTooltip;

  /// Close search tooltip text (null = default)
  final String? closeSearchTooltip;

  /// Search callback
  final ValueChanged<String>? onSearch;

  /// Search submit callback
  final ValueChanged<String>? onSearchSubmit;

  /// Called when search is closed
  final VoidCallback? onSearchClosed;

  /// Search controller
  final TextEditingController? searchController;

  /// Custom search icon (null = Icons.search)
  final IconData? searchIcon;

  /// Custom close icon (null = Icons.close)
  final IconData? closeIcon;

  /// Background color (null = theme default)
  final Color? backgroundColor;

  /// Foreground color for title and icons (null = theme default)
  final Color? foregroundColor;

  /// Whether the app bar is elevated
  final bool elevated;

  /// Center the title
  final bool centerTitle;

  /// Leading widget (replaces back button if provided)
  final Widget? leading;

  /// Bottom widget (e.g., TabBar)
  final PreferredSizeWidget? bottom;

  const AlhaiAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.enableSearch = false,
    this.startInSearchMode = false,
    this.searchHint,
    this.searchTooltip,
    this.closeSearchTooltip,
    this.onSearch,
    this.onSearchSubmit,
    this.onSearchClosed,
    this.searchController,
    this.searchIcon,
    this.closeIcon,
    this.backgroundColor,
    this.foregroundColor,
    this.elevated = false,
    this.centerTitle = false,
    this.leading,
    this.bottom,
  });

  /// Creates an AppBar with search functionality
  factory AlhaiAppBar.search({
    Key? key,
    required String title,
    required ValueChanged<String> onSearch,
    ValueChanged<String>? onSearchSubmit,
    VoidCallback? onSearchClosed,
    TextEditingController? searchController,
    String? searchHint,
    String? searchTooltip,
    String? closeSearchTooltip,
    IconData? searchIcon,
    IconData? closeIcon,
    bool startInSearchMode = false,
    List<Widget>? actions,
    bool showBackButton = true,
    VoidCallback? onBackPressed,
    Color? backgroundColor,
    Color? foregroundColor,
    PreferredSizeWidget? bottom,
  }) {
    return AlhaiAppBar(
      key: key,
      title: title,
      enableSearch: true,
      startInSearchMode: startInSearchMode,
      onSearch: onSearch,
      onSearchSubmit: onSearchSubmit,
      onSearchClosed: onSearchClosed,
      searchController: searchController,
      searchHint: searchHint,
      searchTooltip: searchTooltip,
      closeSearchTooltip: closeSearchTooltip,
      searchIcon: searchIcon,
      closeIcon: closeIcon,
      actions: actions,
      showBackButton: showBackButton,
      onBackPressed: onBackPressed,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      bottom: bottom,
    );
  }

  /// Creates a simple AppBar with just title
  factory AlhaiAppBar.simple({
    Key? key,
    required String title,
    String? subtitle,
    bool showBackButton = true,
    VoidCallback? onBackPressed,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return AlhaiAppBar(
      key: key,
      title: title,
      subtitle: subtitle,
      showBackButton: showBackButton,
      onBackPressed: onBackPressed,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
    );
  }

  @override
  Size get preferredSize {
    double height = kToolbarHeight;
    if (bottom != null) {
      height += bottom!.preferredSize.height;
    }
    return Size.fromHeight(height);
  }

  @override
  State<AlhaiAppBar> createState() => _AlhaiAppBarState();
}

class _AlhaiAppBarState extends State<AlhaiAppBar> {
  late TextEditingController _searchController;
  late bool _isSearching;

  @override
  void initState() {
    super.initState();
    _searchController = widget.searchController ?? TextEditingController();
    _isSearching = widget.startInSearchMode;
  }

  @override
  void dispose() {
    if (widget.searchController == null) {
      _searchController.dispose();
    }
    super.dispose();
  }

  void _handleBackPress() {
    if (widget.onBackPressed != null) {
      widget.onBackPressed!();
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        widget.onSearch?.call('');
        widget.onSearchClosed?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appBarTheme = theme.appBarTheme;
    final canPop = Navigator.canPop(context);
    final textDirection = Directionality.of(context);

    final bgColor = widget.backgroundColor ?? colorScheme.surface;
    final fgColor = widget.foregroundColor ?? colorScheme.onSurface;

    // Elevation from theme
    final baseElevation = appBarTheme.elevation ?? 0;
    final scrolledElevation = appBarTheme.scrolledUnderElevation ?? baseElevation;

    // Build leading widget
    Widget? leadingWidget;
    if (widget.leading != null) {
      leadingWidget = widget.leading;
    } else if (widget.showBackButton && canPop) {
      // استخدام BackButtonIcon للـ RTL التلقائي
      leadingWidget = IconButton(
        icon: const BackButtonIcon(),
        onPressed: _handleBackPress,
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      );
    }

    // Build title widget
    Widget titleWidget;
    if (_isSearching && widget.enableSearch) {
      titleWidget = _buildSearchField(theme, textDirection);
    } else {
      titleWidget = _buildTitleContent(theme, textDirection);
    }

    // Build actions
    List<Widget>? effectiveActions = [...?widget.actions];

    // Add search toggle if search is enabled
    if (widget.enableSearch && widget.onSearch != null) {
      final searchTooltip = widget.searchTooltip ??
          MaterialLocalizations.of(context).searchFieldLabel;
      final closeTooltip = widget.closeSearchTooltip ??
          MaterialLocalizations.of(context).closeButtonLabel;

      effectiveActions.insert(
        0,
        IconButton(
          icon: Icon(_isSearching 
              ? (widget.closeIcon ?? Icons.close) 
              : (widget.searchIcon ?? Icons.search)),
          onPressed: _toggleSearch,
          tooltip: _isSearching ? closeTooltip : searchTooltip,
        ),
      );
    }

    return AppBar(
      leading: leadingWidget,
      title: titleWidget,
      actions: effectiveActions.isEmpty ? null : effectiveActions,
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      surfaceTintColor: Colors.transparent, // تعطيل Material 3 tint
      elevation: widget.elevated ? baseElevation : 0,
      scrolledUnderElevation: widget.elevated ? scrolledElevation : 0,
      centerTitle: widget.centerTitle,
      bottom: widget.bottom,
    );
  }

  Widget _buildTitleContent(ThemeData theme, TextDirection textDirection) {
    if (widget.subtitle == null) {
      return Text(
        widget.title,
        style: theme.textTheme.titleLarge,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      textDirection: textDirection,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.title,
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.start,
        ),
        Text(
          widget.subtitle!,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.start,
        ),
      ],
    );
  }

  Widget _buildSearchField(ThemeData theme, TextDirection textDirection) {
    final searchHint = widget.searchHint ??
        MaterialLocalizations.of(context).searchFieldLabel;

    return TextField(
      controller: _searchController,
      autofocus: true,
      textInputAction: TextInputAction.search,
      textDirection: textDirection,
      textAlignVertical: TextAlignVertical.center,
      style: theme.textTheme.titleMedium,
      cursorColor: theme.colorScheme.primary,
      decoration: InputDecoration(
        hintText: searchHint,
        hintStyle: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: AlhaiSpacing.sm,
          vertical: AlhaiSpacing.xs,
        ),
      ),
      onChanged: widget.onSearch,
      onSubmitted: widget.onSearchSubmit,
    );
  }
}
