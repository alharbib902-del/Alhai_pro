import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// تعريفات اختصارات الكيبورد لشاشة POS
/// 
/// | الاختصار | الإجراء |
/// |----------|---------|
/// | F1 | تركيز البحث |
/// | F2 | بيع جديد / مسح السلة |
/// | 1-9 | إضافة منتج سريع |
/// | Enter | إتمام الدفع |
/// | +/- | تغيير الكمية |
/// | Ctrl+Z | تراجع |
/// | Esc | إلغاء |
class PosKeyboardShortcuts {
  /// معالج الاختصارات
  static KeyEventResult handleKeyEvent(
    KeyEvent event, {
    required VoidCallback onSearch,
    required VoidCallback onNewSale,
    required VoidCallback onCheckout,
    required VoidCallback onUndo,
    required VoidCallback onCancel,
    required void Function(int number) onQuickAdd,
    required void Function(bool increase) onQuantityChange,
  }) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    // F1 - البحث
    if (event.logicalKey == LogicalKeyboardKey.f1) {
      onSearch();
      return KeyEventResult.handled;
    }

    // F2 - بيع جديد
    if (event.logicalKey == LogicalKeyboardKey.f2) {
      onNewSale();
      return KeyEventResult.handled;
    }

    // Enter - إتمام الدفع
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      onCheckout();
      return KeyEventResult.handled;
    }

    // Escape - إلغاء
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      onCancel();
      return KeyEventResult.handled;
    }

    // Ctrl+Z - تراجع
    if (HardwareKeyboard.instance.isControlPressed &&
        event.logicalKey == LogicalKeyboardKey.keyZ) {
      onUndo();
      return KeyEventResult.handled;
    }

    // + زيادة الكمية
    if (event.logicalKey == LogicalKeyboardKey.add ||
        event.logicalKey == LogicalKeyboardKey.equal ||
        event.logicalKey == LogicalKeyboardKey.numpadAdd) {
      onQuantityChange(true);
      return KeyEventResult.handled;
    }

    // - نقص الكمية
    if (event.logicalKey == LogicalKeyboardKey.minus ||
        event.logicalKey == LogicalKeyboardKey.numpadSubtract) {
      onQuantityChange(false);
      return KeyEventResult.handled;
    }

    // أرقام 1-9 للمنتجات السريعة
    final number = _getNumber(event.logicalKey);
    if (number != null && number >= 1 && number <= 9) {
      onQuickAdd(number);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  static int? _getNumber(LogicalKeyboardKey key) {
    // Numpad keys
    if (key == LogicalKeyboardKey.numpad1) return 1;
    if (key == LogicalKeyboardKey.numpad2) return 2;
    if (key == LogicalKeyboardKey.numpad3) return 3;
    if (key == LogicalKeyboardKey.numpad4) return 4;
    if (key == LogicalKeyboardKey.numpad5) return 5;
    if (key == LogicalKeyboardKey.numpad6) return 6;
    if (key == LogicalKeyboardKey.numpad7) return 7;
    if (key == LogicalKeyboardKey.numpad8) return 8;
    if (key == LogicalKeyboardKey.numpad9) return 9;

    // Regular number keys
    if (key == LogicalKeyboardKey.digit1) return 1;
    if (key == LogicalKeyboardKey.digit2) return 2;
    if (key == LogicalKeyboardKey.digit3) return 3;
    if (key == LogicalKeyboardKey.digit4) return 4;
    if (key == LogicalKeyboardKey.digit5) return 5;
    if (key == LogicalKeyboardKey.digit6) return 6;
    if (key == LogicalKeyboardKey.digit7) return 7;
    if (key == LogicalKeyboardKey.digit8) return 8;
    if (key == LogicalKeyboardKey.digit9) return 9;

    return null;
  }
}

/// Widget يضيف اختصارات الكيبورد للـ POS
class PosKeyboardListener extends StatelessWidget {
  final Widget child;
  final VoidCallback onSearch;
  final VoidCallback onNewSale;
  final VoidCallback onCheckout;
  final VoidCallback onUndo;
  final VoidCallback onCancel;
  final void Function(int number) onQuickAdd;
  final void Function(bool increase) onQuantityChange;

  const PosKeyboardListener({
    super.key,
    required this.child,
    required this.onSearch,
    required this.onNewSale,
    required this.onCheckout,
    required this.onUndo,
    required this.onCancel,
    required this.onQuickAdd,
    required this.onQuantityChange,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) => PosKeyboardShortcuts.handleKeyEvent(
        event,
        onSearch: onSearch,
        onNewSale: onNewSale,
        onCheckout: onCheckout,
        onUndo: onUndo,
        onCancel: onCancel,
        onQuickAdd: onQuickAdd,
        onQuantityChange: onQuantityChange,
      ),
      child: child,
    );
  }
}

/// Widget للإشارة إلى اختصار
class KeyboardShortcutHint extends StatelessWidget {
  final String shortcut;
  final String? label;

  const KeyboardShortcutHint({
    super.key,
    required this.shortcut,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            shortcut,
            style: theme.textTheme.labelSmall?.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (label != null) ...[
          const SizedBox(width: 4),
          Text(
            label!,
            style: theme.textTheme.labelSmall,
          ),
        ],
      ],
    );
  }
}
