import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

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
  /// خريطة المفاتيح الرقمية (numpad + digit) → القيمة
  static final _numberKeys = <LogicalKeyboardKey, int>{
    LogicalKeyboardKey.numpad1: 1, LogicalKeyboardKey.digit1: 1,
    LogicalKeyboardKey.numpad2: 2, LogicalKeyboardKey.digit2: 2,
    LogicalKeyboardKey.numpad3: 3, LogicalKeyboardKey.digit3: 3,
    LogicalKeyboardKey.numpad4: 4, LogicalKeyboardKey.digit4: 4,
    LogicalKeyboardKey.numpad5: 5, LogicalKeyboardKey.digit5: 5,
    LogicalKeyboardKey.numpad6: 6, LogicalKeyboardKey.digit6: 6,
    LogicalKeyboardKey.numpad7: 7, LogicalKeyboardKey.digit7: 7,
    LogicalKeyboardKey.numpad8: 8, LogicalKeyboardKey.digit8: 8,
    LogicalKeyboardKey.numpad9: 9, LogicalKeyboardKey.digit9: 9,
  };

  /// مفاتيح زيادة/نقصان الكمية
  static final _increaseKeys = {
    LogicalKeyboardKey.add, LogicalKeyboardKey.equal, LogicalKeyboardKey.numpadAdd,
  };
  static final _decreaseKeys = {
    LogicalKeyboardKey.minus, LogicalKeyboardKey.numpadSubtract,
  };

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

    // اختصارات المفتاح الواحد
    final simpleShortcuts = <LogicalKeyboardKey, VoidCallback>{
      LogicalKeyboardKey.f1: onSearch,
      LogicalKeyboardKey.f2: onNewSale,
      LogicalKeyboardKey.enter: onCheckout,
      LogicalKeyboardKey.escape: onCancel,
    };

    final action = simpleShortcuts[event.logicalKey];
    if (action != null) {
      action();
      return KeyEventResult.handled;
    }

    // Ctrl+Z - تراجع
    if (HardwareKeyboard.instance.isControlPressed &&
        event.logicalKey == LogicalKeyboardKey.keyZ) {
      onUndo();
      return KeyEventResult.handled;
    }

    // +/- تغيير الكمية
    if (_increaseKeys.contains(event.logicalKey)) {
      onQuantityChange(true);
      return KeyEventResult.handled;
    }
    if (_decreaseKeys.contains(event.logicalKey)) {
      onQuantityChange(false);
      return KeyEventResult.handled;
    }

    // أرقام 1-9 للمنتجات السريعة
    final number = _numberKeys[event.logicalKey];
    if (number != null) {
      onQuickAdd(number);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
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
          const SizedBox(width: AlhaiSpacing.xxs),
          Text(
            label!,
            style: theme.textTheme.labelSmall,
          ),
        ],
      ],
    );
  }
}
