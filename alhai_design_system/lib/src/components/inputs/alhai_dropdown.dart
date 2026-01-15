import 'package:flutter/material.dart';

import '../../tokens/alhai_colors.dart';
import '../../tokens/alhai_radius.dart';
import '../../tokens/alhai_spacing.dart';
import '../feedback/alhai_bottom_sheet.dart';

/// AlhaiDropdown - Design system dropdown with BottomSheet selection
/// 
/// Supports:
/// - Simple dropdown with items
/// - Searchable dropdown with local filtering
/// - Form validation compatible
/// - Generic type support with builders
/// 
/// Value behavior (Controlled):
/// - [value] represents the current state (can be null as a valid value)
/// - Changes to [value] from parent will sync automatically via didUpdateWidget
/// - User selections are reported via [onChanged]
class AlhaiDropdown<T> extends FormField<T> {
  /// External value (always synced - controlled mode)
  final T? externalValue;

  /// Items list
  final List<T> items;

  /// Label builder for items
  final String Function(T item) itemLabelBuilder;

  /// Leading widget builder (optional)
  final Widget? Function(T item)? itemLeadingBuilder;

  /// Value comparison function
  final bool Function(T a, T b) compareFn;

  /// Search filter function
  final bool Function(String label, String query) searchMatcher;

  /// Value change callback
  final ValueChanged<T?>? onChanged;

  /// Field label
  final String? label;

  /// Hint text
  final String? hint;

  /// Helper text
  final String? helperText;

  /// Sheet title
  final String? sheetTitle;

  /// Empty state widget
  final Widget? emptyState;

  /// Is loading
  final bool loading;

  /// Searchable mode
  final bool searchable;

  /// Prefix widget
  final Widget? prefix;

  /// Suffix widget
  final Widget? suffix;

  /// Computed effective enabled state
  final bool effectiveEnabled;

  /// Helper to compute effective enabled (single source of truth)
  static bool _computeEffectiveEnabled({
    required bool enabled,
    required bool loading,
    required int itemCount,
  }) {
    return enabled && !loading && itemCount > 0;
  }

  /// Create a dropdown field
  AlhaiDropdown({
    super.key,
    required this.items,
    required this.itemLabelBuilder,
    this.itemLeadingBuilder,
    bool Function(T a, T b)? compareFn,
    bool Function(String label, String query)? searchMatcher,
    T? value,
    this.onChanged,
    this.label,
    this.hint,
    this.helperText,
    this.sheetTitle,
    this.emptyState,
    bool enabled = true,
    this.loading = false,
    this.searchable = false,
    this.prefix,
    this.suffix,
    super.validator,
    super.autovalidateMode,
    super.restorationId,
  }) : externalValue = value,
       compareFn = compareFn ?? ((a, b) => a == b),
       searchMatcher = searchMatcher ?? _defaultSearchMatcher,
       effectiveEnabled = _computeEffectiveEnabled(
         enabled: enabled,
         loading: loading,
         itemCount: items.length,
       ),
       super(
         initialValue: value,
         enabled: _computeEffectiveEnabled(
           enabled: enabled,
           loading: loading,
           itemCount: items.length,
         ),
         builder: (FormFieldState<T> field) {
           final state = field as _AlhaiDropdownState<T>;
           final widget = state.widget as AlhaiDropdown<T>;

           return _AlhaiDropdownField<T>(
             items: widget.items,
             itemLabelBuilder: widget.itemLabelBuilder,
             itemLeadingBuilder: widget.itemLeadingBuilder,
             compareFn: widget.compareFn,
             searchMatcher: widget.searchMatcher,
             value: state.value,
             onChanged: (newValue) {
               state.didChange(newValue);
               widget.onChanged?.call(newValue);
             },
             label: widget.label,
             hint: widget.hint,
             helperText: widget.helperText,
             errorText: state.errorText,
             sheetTitle: widget.sheetTitle,
             emptyState: widget.emptyState,
             enabled: widget.effectiveEnabled,
             loading: widget.loading,
             searchable: widget.searchable,
             prefix: widget.prefix,
             suffix: widget.suffix,
           );
         },
       );

  static bool _defaultSearchMatcher(String label, String query) {
    return label.toLowerCase().contains(query.toLowerCase());
  }

  @override
  FormFieldState<T> createState() => _AlhaiDropdownState<T>();
}

class _AlhaiDropdownState<T> extends FormFieldState<T> {
  @override
  void didUpdateWidget(covariant AlhaiDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newWidget = widget as AlhaiDropdown<T>;
    // Sync controlled value when it changes
    if (newWidget.externalValue != oldWidget.externalValue) {
      setValue(newWidget.externalValue);
    }
  }
}

/// Internal dropdown field widget
class _AlhaiDropdownField<T> extends StatelessWidget {
  final List<T> items;
  final String Function(T item) itemLabelBuilder;
  final Widget? Function(T item)? itemLeadingBuilder;
  final bool Function(T a, T b) compareFn;
  final bool Function(String label, String query) searchMatcher;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final String? sheetTitle;
  final Widget? emptyState;
  final bool enabled;
  final bool loading;
  final bool searchable;
  final Widget? prefix;
  final Widget? suffix;

  const _AlhaiDropdownField({
    required this.items,
    required this.itemLabelBuilder,
    required this.itemLeadingBuilder,
    required this.compareFn,
    required this.searchMatcher,
    required this.value,
    required this.onChanged,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.sheetTitle,
    this.emptyState,
    this.enabled = true,
    this.loading = false,
    this.searchable = false,
    this.prefix,
    this.suffix,
  });

  T? _findSelectedItem() {
    final currentValue = value;
    if (currentValue == null) return null;
    for (final item in items) {
      if (compareFn(item, currentValue)) return item;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textDirection = Directionality.of(context);

    final isDisabled = !enabled;
    final hasError = errorText != null && errorText!.isNotEmpty;

    final selectedItem = _findSelectedItem();

    // Colors
    final fillColor = colorScheme.surfaceContainerHighest;
    final borderColor = hasError ? colorScheme.error : colorScheme.outline;
    final textColor = colorScheme.onSurface;

    return Opacity(
      opacity: isDisabled ? AlhaiColors.disabledOpacity : 1.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label
          if (label != null) ...[
            Text(
              label!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: hasError ? colorScheme.error : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.xs),
          ],

          // Dropdown field
          Material(
            color: fillColor,
            surfaceTintColor: AlhaiColors.transparent,
            borderRadius: BorderRadius.circular(AlhaiRadius.input),
            child: InkWell(
              onTap: isDisabled
                  ? null
                  : () => _showDropdownSheet(context),
              borderRadius: BorderRadius.circular(AlhaiRadius.input),
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: AlhaiSpacing.listTileMinHeight,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AlhaiRadius.input),
                  border: Border.all(
                    color: borderColor,
                    width: hasError ? AlhaiSpacing.strokeSm : 1,
                  ),
                ),
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AlhaiSpacing.md,
                ),
                child: Row(
                  textDirection: textDirection,
                  children: [
                    // Prefix
                    if (prefix != null) ...[
                      prefix!,
                      const SizedBox(width: AlhaiSpacing.sm),
                    ],

                    // Leading from selected item
                    if (selectedItem != null && itemLeadingBuilder != null) ...[
                      if (itemLeadingBuilder!(selectedItem) != null) ...[
                        itemLeadingBuilder!(selectedItem)!,
                        const SizedBox(width: AlhaiSpacing.sm),
                      ],
                    ],

                    // Value or hint
                    Expanded(
                      child: Text(
                        selectedItem != null
                            ? itemLabelBuilder(selectedItem)
                            : hint ?? '',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: selectedItem != null
                              ? textColor
                              : colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Suffix or loading or chevron
                    const SizedBox(width: AlhaiSpacing.sm),
                    if (loading)
                      SizedBox(
                        width: AlhaiSpacing.lg,
                        height: AlhaiSpacing.lg,
                        child: CircularProgressIndicator(
                          strokeWidth: AlhaiSpacing.strokeSm,
                          color: colorScheme.primary,
                        ),
                      )
                    else if (suffix != null)
                      suffix!
                    else
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: colorScheme.onSurfaceVariant,
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Helper or error text
          const SizedBox(height: AlhaiSpacing.xs),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AlhaiSpacing.mdl),
            child: Text(
              errorText ?? helperText ?? '',
              style: theme.textTheme.bodySmall?.copyWith(
                color: hasError ? colorScheme.error : colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showDropdownSheet(BuildContext context) {
    AlhaiBottomSheet.show(
      context: context,
      title: sheetTitle ?? label,
      child: _DropdownSheetContent<T>(
        items: items,
        itemLabelBuilder: itemLabelBuilder,
        itemLeadingBuilder: itemLeadingBuilder,
        compareFn: compareFn,
        searchMatcher: searchMatcher,
        value: value,
        searchable: searchable,
        emptyState: emptyState,
        onSelected: (item) {
          Navigator.pop(context);
          Future.microtask(() => onChanged(item));
        },
      ),
    );
  }
}

/// Internal sheet content widget
class _DropdownSheetContent<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T item) itemLabelBuilder;
  final Widget? Function(T item)? itemLeadingBuilder;
  final bool Function(T a, T b) compareFn;
  final bool Function(String label, String query) searchMatcher;
  final T? value;
  final bool searchable;
  final Widget? emptyState;
  final ValueChanged<T> onSelected;

  const _DropdownSheetContent({
    required this.items,
    required this.itemLabelBuilder,
    required this.itemLeadingBuilder,
    required this.compareFn,
    required this.searchMatcher,
    required this.value,
    required this.searchable,
    required this.emptyState,
    required this.onSelected,
  });

  @override
  State<_DropdownSheetContent<T>> createState() => _DropdownSheetContentState<T>();
}

class _DropdownSheetContentState<T> extends State<_DropdownSheetContent<T>> {
  late TextEditingController _searchController;
  late List<T> _filteredItems;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredItems = widget.items;
  }

  @override
  void didUpdateWidget(covariant _DropdownSheetContent<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-filter if items changed
    if (widget.items != oldWidget.items) {
      _applyFilter(_currentQuery);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _currentQuery = query;
    _applyFilter(query);
  }

  void _applyFilter(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where((item) => widget.searchMatcher(
                widget.itemLabelBuilder(item), query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textDirection = Directionality.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Search field
        if (widget.searchable) ...[
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AlhaiSpacing.md,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              textDirection: textDirection,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  color: colorScheme.onSurfaceVariant,
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AlhaiRadius.input),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AlhaiRadius.input),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AlhaiRadius.input),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: AlhaiSpacing.strokeSm,
                  ),
                ),
                contentPadding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AlhaiSpacing.md,
                  vertical: AlhaiSpacing.sm,
                ),
              ),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.sm),
        ],

        // Empty state
        if (_filteredItems.isEmpty) ...[
          widget.emptyState ??
              Padding(
                padding: const EdgeInsetsDirectional.all(AlhaiSpacing.xl),
                child: Icon(
                  Icons.search_off_rounded,
                  size: AlhaiSpacing.xxl,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
        ] else ...[
          // Items list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredItems.length,
              padding: EdgeInsetsDirectional.zero,
              itemBuilder: (context, index) {
                final item = _filteredItems[index];
                final currentValue = widget.value;
                final isSelected = currentValue != null &&
                    widget.compareFn(item, currentValue);
                final leading = widget.itemLeadingBuilder?.call(item);

                return Material(
                  color: isSelected
                      ? colorScheme.secondaryContainer
                      : AlhaiColors.transparent,
                  child: InkWell(
                    onTap: () => widget.onSelected(item),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: AlhaiSpacing.md,
                        vertical: AlhaiSpacing.sm,
                      ),
                      child: Row(
                        textDirection: textDirection,
                        children: [
                          // Leading
                          if (leading != null) ...[
                            leading,
                            const SizedBox(width: AlhaiSpacing.md),
                          ],

                          // Label
                          Expanded(
                            child: Text(
                              widget.itemLabelBuilder(item),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: isSelected
                                    ? colorScheme.onSecondaryContainer
                                    : colorScheme.onSurface,
                              ),
                            ),
                          ),

                          // Check icon for selected
                          if (isSelected)
                            Icon(
                              Icons.check_rounded,
                              color: colorScheme.onSecondaryContainer,
                              size: AlhaiSpacing.lg,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
