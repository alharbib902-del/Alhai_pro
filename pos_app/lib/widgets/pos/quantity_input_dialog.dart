/// Quantity Input Dialog - نافذة إدخال الكمية
///
/// تُستخدم عند الضغط على زر + في بطاقة المنتج
/// لإدخال كمية محددة قبل الإضافة للسلة
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:alhai_core/alhai_core.dart';
import '../../core/theme/app_colors.dart';

/// نافذة إدخال الكمية
class QuantityInputDialog extends StatefulWidget {
  final Product product;

  const QuantityInputDialog({
    super.key,
    required this.product,
  });

  /// عرض النافذة وإرجاع الكمية المحددة (أو null إذا تم الإلغاء)
  static Future<int?> show(BuildContext context, Product product) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showDialog<int>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        child: QuantityInputDialog(product: product),
      ),
    );
  }

  @override
  State<QuantityInputDialog> createState() => _QuantityInputDialogState();
}

class _QuantityInputDialogState extends State<QuantityInputDialog> {
  int _quantity = 1;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '1');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setQuantity(int qty) {
    if (qty < 1) qty = 1;
    if (widget.product.trackInventory && qty > widget.product.stockQty) {
      qty = widget.product.stockQty;
    }
    setState(() {
      _quantity = qty;
      _controller.text = qty.toString();
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maxQty = product.trackInventory ? product.stockQty : 9999;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // اسم المنتج والسعر
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${product.price.toStringAsFixed(2)} ر.س',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (product.trackInventory)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'المتوفر: ${product.stockQty}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white54 : AppColors.textMuted,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: isDark ? Colors.white54 : AppColors.textMuted,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // التحكم بالكمية: - [input] +
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // زر -
                _QuantityButton(
                  icon: Icons.remove,
                  onTap: _quantity > 1 ? () => _setQuantity(_quantity - 1) : null,
                  isDark: isDark,
                ),
                const SizedBox(width: 16),

                // حقل الكمية
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white24 : AppColors.border,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white24 : AppColors.border,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    onChanged: (value) {
                      final qty = int.tryParse(value) ?? 1;
                      setState(() {
                        _quantity = qty.clamp(1, maxQty);
                      });
                    },
                    onSubmitted: (_) {
                      if (_quantity > 0) Navigator.pop(context, _quantity);
                    },
                  ),
                ),
                const SizedBox(width: 16),

                // زر +
                _QuantityButton(
                  icon: Icons.add,
                  onTap: _quantity < maxQty ? () => _setQuantity(_quantity + 1) : null,
                  isDark: isDark,
                  isPrimary: true,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // أزرار سريعة
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [1, 5, 10, 25, 50]
                  .where((q) => q <= maxQty)
                  .map((qty) => _QuickAmountChip(
                        quantity: qty,
                        isSelected: _quantity == qty,
                        onTap: () => _setQuantity(qty),
                        isDark: isDark,
                      ))
                  .toList(),
            ),

            const SizedBox(height: 20),

            // الإجمالي
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الإجمالي',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${(product.price * _quantity).toStringAsFixed(2)} ر.س',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // زر الإضافة
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: _quantity > 0
                    ? () => Navigator.pop(context, _quantity)
                    : null,
                icon: const Icon(Icons.add_shopping_cart),
                label: Text(
                  'إضافة $_quantity للسلة',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// زر + أو -
class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDark;
  final bool isPrimary;

  const _QuantityButton({
    required this.icon,
    this.onTap,
    required this.isDark,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: enabled
          ? (isPrimary
              ? AppColors.primary
              : (isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.grey100))
          : (isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.grey50),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            icon,
            color: enabled
                ? (isPrimary
                    ? Colors.white
                    : (isDark ? Colors.white70 : AppColors.textPrimary))
                : (isDark ? Colors.white24 : AppColors.grey300),
            size: 24,
          ),
        ),
      ),
    );
  }
}

/// شريحة كمية سريعة
class _QuickAmountChip extends StatelessWidget {
  final int quantity;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _QuickAmountChip({
    required this.quantity,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppColors.primary.withValues(alpha: 0.15)
          : (isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.grey100),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Text(
            '$quantity',
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? Colors.white70 : AppColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}
