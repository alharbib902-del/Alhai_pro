import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_core/alhai_core.dart' show StoreSettings;
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

/// نظام Undo للعمليات القابلة للتراجع
/// 
/// يوفر:
/// - SnackBar مع زر "تراجع" بعد الحذف
/// - تأكيد فقط للعمليات الكبيرة (>500 ر.س)

/// نوع العملية
enum UndoActionType {
  removeFromCart,
  clearCart,
  applyDiscount,
  changeQuantity,
  cancelPayment,
}

/// بيانات العملية القابلة للتراجع
class UndoableAction {
  final UndoActionType type;
  final String description;
  final VoidCallback undoCallback;
  final double? amount;
  final DateTime timestamp;

  UndoableAction({
    required this.type,
    required this.description,
    required this.undoCallback,
    this.amount,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Notifier لإدارة العمليات القابلة للتراجع
class UndoStackNotifier extends StateNotifier<List<UndoableAction>> {
  UndoStackNotifier() : super([]);

  /// إضافة عملية جديدة للـ Stack
  void push(UndoableAction action) {
    // الاحتفاظ بآخر 10 عمليات فقط
    if (state.length >= 10) {
      state = [...state.sublist(1), action];
    } else {
      state = [...state, action];
    }
  }

  /// تنفيذ التراجع عن آخر عملية
  UndoableAction? pop() {
    if (state.isEmpty) return null;
    final last = state.last;
    state = state.sublist(0, state.length - 1);
    return last;
  }

  /// مسح كل العمليات
  void clear() {
    state = [];
  }

  /// هل يوجد عمليات للتراجع
  bool get canUndo => state.isNotEmpty;

  /// آخر عملية
  UndoableAction? get lastAction => state.isEmpty ? null : state.last;
}

/// مزود الـ Undo Stack
final undoStackProvider = StateNotifierProvider<UndoStackNotifier, List<UndoableAction>>(
  (ref) => UndoStackNotifier(),
);

/// مزود هل يمكن التراجع
final canUndoProvider = Provider<bool>((ref) {
  return ref.watch(undoStackProvider).isNotEmpty;
});

/// Helper لعرض SnackBar مع زر Undo
void showUndoSnackBar(
  BuildContext context, {
  required WidgetRef ref,
  required String message,
  required UndoActionType actionType,
  required VoidCallback undoCallback,
  double? amount,
  Duration duration = const Duration(seconds: 5),
}) {
  // تسجيل العملية
  ref.read(undoStackProvider.notifier).push(
    UndoableAction(
      type: actionType,
      description: message,
      undoCallback: undoCallback,
      amount: amount,
    ),
  );

  // عرض الـ SnackBar
  final l10n = AppLocalizations.of(context)!;
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: duration,
      action: SnackBarAction(
        label: l10n.undo,
        onPressed: () {
          undoCallback();
          ref.read(undoStackProvider.notifier).pop();
        },
      ),
    ),
  );
}

/// دالة للتأكيد قبل العمليات الكبيرة
Future<bool> confirmLargeOperation(
  BuildContext context, {
  required String title,
  required String message,
  double? amount,
  double threshold = 500.0,
}) async {
  // لا تأكيد للعمليات الصغيرة
  if (amount != null && amount < threshold) {
    return true;
  }

  final l10n = AppLocalizations.of(context)!;
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning_amber, color: AlhaiColors.warningDark),
          const SizedBox(width: 8),
          Expanded(child: Text(title)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          if (amount != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AlhaiColors.warning.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AlhaiColors.warning.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.attach_money, color: AlhaiColors.warningDark),
                  const SizedBox(width: 8),
                  Text(
                    'المبلغ: ${amount.toStringAsFixed(2)} ${StoreSettings.defaultCurrencySymbol}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AlhaiColors.warning,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(
            backgroundColor: AlhaiColors.warningDark,
          ),
          child: Text(l10n.confirm),
        ),
      ],
    ),
  );

  return result ?? false;
}

/// Widget لعرض زر Undo العائم
class UndoFloatingButton extends ConsumerWidget {
  const UndoFloatingButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final canUndo = ref.watch(canUndoProvider);
    final lastAction = ref.watch(undoStackProvider).isEmpty
        ? null
        : ref.watch(undoStackProvider).last;

    if (!canUndo) return const SizedBox.shrink();

    return PositionedDirectional(
      start: 16,
      bottom: 100,
      child: AnimatedOpacity(
        opacity: canUndo ? 1 : 0,
        duration: AlhaiDurations.slow,
        child: FloatingActionButton.small(
          heroTag: 'undo_fab',
          onPressed: () {
            final action = ref.read(undoStackProvider.notifier).pop();
            if (action != null) {
              action.undoCallback();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ تم التراجع: ${action.description}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          tooltip: lastAction != null ? '${l10n.undo}: ${lastAction.description}' : l10n.undo,
          backgroundColor: AlhaiColors.warning.withValues(alpha: 0.15),
          foregroundColor: AlhaiColors.warningDark,
          child: const Icon(Icons.undo),
        ),
      ),
    );
  }
}
