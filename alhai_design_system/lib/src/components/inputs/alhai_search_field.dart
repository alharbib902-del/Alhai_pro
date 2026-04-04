import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../tokens/alhai_durations.dart';
import '../../tokens/alhai_radius.dart';
import '../../tokens/alhai_spacing.dart';

/// Alhai Search Field - Search input with clear and loading states
class AlhaiSearchField extends StatefulWidget {
  /// Controller for the search field
  final TextEditingController? controller;

  /// Hint text
  final String hintText;

  /// On changed callback
  final ValueChanged<String>? onChanged;

  /// On submitted callback
  final ValueChanged<String>? onSubmitted;

  /// On clear callback
  final VoidCallback? onClear;

  /// Focus node
  final FocusNode? focusNode;

  /// Auto focus
  final bool autofocus;

  /// Is loading (shows spinner)
  final bool isLoading;

  /// Enabled
  final bool enabled;

  /// Show clear button when text is present
  final bool showClearButton;

  const AlhaiSearchField({
    super.key,
    this.controller,
    this.hintText = 'بحث...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.focusNode,
    this.autofocus = false,
    this.isLoading = false,
    this.enabled = true,
    this.showClearButton = true,
  });

  @override
  State<AlhaiSearchField> createState() => _AlhaiSearchFieldState();
}

class _AlhaiSearchFieldState extends State<AlhaiSearchField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_handleTextChange);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChange);
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleTextChange() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _handleClear() {
    _controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      textInputAction: TextInputAction.search,
      onChanged: (value) {
        widget.onChanged
            ?.call(value.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), ''));
      },
      onSubmitted: widget.onSubmitted,
      inputFormatters: const [],
      maxLength: 200,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
      buildCounter: (context,
              {required currentLength, required isFocused, maxLength}) =>
          null,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: AnimatedSwitcher(
          duration: AlhaiDurations.fast,
          child: widget.isLoading
              ? Padding(
                  key: const ValueKey('loading'),
                  padding: const EdgeInsets.all(AlhaiSpacing.sm),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  ),
                )
              : Icon(
                  Icons.search,
                  key: const ValueKey('icon'),
                  color: colorScheme.onSurfaceVariant,
                ),
        ),
        suffixIcon: widget.showClearButton && _hasText
            ? IconButton(
                icon: Icon(
                  Icons.close,
                  color: colorScheme.onSurfaceVariant,
                ),
                onPressed: _handleClear,
              )
            : null,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AlhaiSpacing.md,
          vertical: AlhaiSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AlhaiRadius.full),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AlhaiRadius.full),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AlhaiRadius.full),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
    );
  }
}
