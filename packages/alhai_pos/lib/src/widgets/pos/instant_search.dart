import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import '../../providers/cart_providers.dart';

/// مزود البحث الفوري
final instantSearchQueryProvider = StateProvider<String>((ref) => '');

/// مزود نتائج البحث المفلترة
final searchResultsProvider = Provider<List<Product>>((ref) {
  final query = ref.watch(instantSearchQueryProvider);
  final products = ref.watch(productsStateProvider).products;
  
  if (query.isEmpty) return products;
  
  final lowerQuery = query.toLowerCase();
  return products.where((p) {
    return p.name.toLowerCase().contains(lowerQuery) ||
           (p.barcode?.toLowerCase().contains(lowerQuery) ?? false) ||
           p.id.toLowerCase().contains(lowerQuery);
  }).toList();
});

/// Widget للبحث الفوري مع Debounce
class InstantSearchField extends ConsumerStatefulWidget {
  final FocusNode? focusNode;
  final String? hintText;
  final Duration debounceDuration;
  final ValueChanged<Product>? onProductSelected;

  const InstantSearchField({
    super.key,
    this.focusNode,
    this.hintText,
    this.debounceDuration = AlhaiDurations.slow,
    this.onProductSelected,
  });

  @override
  ConsumerState<InstantSearchField> createState() => _InstantSearchFieldState();
}

class _InstantSearchFieldState extends ConsumerState<InstantSearchField> {
  late final TextEditingController _controller;
  Timer? _debounceTimer;
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceDuration, () {
      final sanitized = InputSanitizer.sanitize(value);
      if (InputSanitizer.containsDangerousContent(sanitized)) return;
      ref.read(instantSearchQueryProvider.notifier).state = sanitized;
      setState(() => _showResults = sanitized.isNotEmpty);
    });
  }

  void _selectProduct(Product product) {
    // إضافة للسلة
    ref.read(cartStateProvider.notifier).addProduct(product);
    
    // مسح البحث
    _controller.clear();
    ref.read(instantSearchQueryProvider.notifier).state = '';
    setState(() => _showResults = false);
    
    // Callback
    widget.onProductSelected?.call(product);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final results = ref.watch(searchResultsProvider);
    final query = ref.watch(instantSearchQueryProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // حقل البحث
        TextField(
          controller: _controller,
          focusNode: widget.focusNode,
          onChanged: _onSearchChanged,
          maxLength: 100,
          decoration: InputDecoration(
            hintText: widget.hintText ?? 'بحث سريع (اسم / كود / باركود)...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _controller.text.isNotEmpty 
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    ref.read(instantSearchQueryProvider.notifier).state = '';
                    setState(() => _showResults = false);
                  },
                )
              : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest,
          ),
        ),
        
        // نتائج البحث
        if (_showResults && query.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 300),
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: results.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, color: Theme.of(context).colorScheme.outline),
                        const SizedBox(width: 8),
                        Text(
                          'لا توجد نتائج لـ "$query"',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final product = results[index];
                      return _SearchResultItem(
                        product: product,
                        query: query,
                        onTap: () => _selectProduct(product),
                      );
                    },
                  ),
          ),
      ],
    );
  }
}

/// عنصر نتيجة البحث مع Highlight
class _SearchResultItem extends StatelessWidget {
  final Product product;
  final String query;
  final VoidCallback onTap;

  const _SearchResultItem({
    required this.product,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Icon(
          Icons.inventory_2,
          color: theme.colorScheme.primary,
          size: 20,
        ),
      ),
      title: _HighlightedText(
        text: product.name,
        highlight: query,
        style: theme.textTheme.bodyLarge,
        highlightStyle: theme.textTheme.bodyLarge?.copyWith(
          backgroundColor: Colors.yellow.shade200,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Row(
        children: [
          if (product.barcode != null) ...[
            Icon(Icons.qr_code, size: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            _HighlightedText(
              text: product.barcode!,
              highlight: query,
              style: theme.textTheme.bodySmall,
              highlightStyle: theme.textTheme.bodySmall?.copyWith(
                backgroundColor: Colors.yellow.shade200,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            '${product.price.toStringAsFixed(2)} ر.س',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.add_circle, color: AlhaiColors.success),
        onPressed: onTap,
      ),
    );
  }
}

/// Widget لإبراز نص البحث
class _HighlightedText extends StatelessWidget {
  final String text;
  final String highlight;
  final TextStyle? style;
  final TextStyle? highlightStyle;

  const _HighlightedText({
    required this.text,
    required this.highlight,
    this.style,
    this.highlightStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (highlight.isEmpty) {
      return Text(text, style: style);
    }

    final lowerText = text.toLowerCase();
    final lowerHighlight = highlight.toLowerCase();
    final startIndex = lowerText.indexOf(lowerHighlight);

    if (startIndex == -1) {
      return Text(text, style: style);
    }

    final endIndex = startIndex + highlight.length;

    return RichText(
      text: TextSpan(
        style: style,
        children: [
          TextSpan(text: text.substring(0, startIndex)),
          TextSpan(
            text: text.substring(startIndex, endIndex),
            style: highlightStyle ?? style?.copyWith(
              backgroundColor: Colors.yellow.shade200,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: text.substring(endIndex)),
        ],
      ),
    );
  }
}
