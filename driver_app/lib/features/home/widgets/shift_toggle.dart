import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/location_service.dart';
import '../../deliveries/providers/delivery_providers.dart';
import '../../shifts/providers/shifts_providers.dart';

class ShiftToggle extends ConsumerWidget {
  const ShiftToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnShift = ref.watch(isOnShiftProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.xs),
      child: Semantics(
        label: isOnShift
            ? 'الوردية نشطة. اضغط لإنهاء الوردية'
            : 'الوردية غير نشطة. اضغط لبدء الوردية',
        button: true,
        toggled: isOnShift,
        child: ActionChip(
          avatar: ExcludeSemantics(
            child: Icon(
              isOnShift ? Icons.circle : Icons.circle_outlined,
              size: 12,
              color: isOnShift
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
            ),
          ),
          label: Text(
            isOnShift ? 'متصل' : 'غير متصل',
            style: TextStyle(
              color: isOnShift
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
              fontWeight: FontWeight.w600,
            ),
          ),
          onPressed: () async {
            HapticFeedback.mediumImpact();

            // Warn if ending shift while an active delivery exists.
            if (isOnShift) {
              final active =
                  ref.read(activeDeliveriesStreamProvider).valueOrNull ?? [];
              if (active.isNotEmpty && context.mounted) {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('لديك توصيل نشط'),
                    content: const Text(
                      'لديك توصيل نشط حالياً. هل تريد إنهاء الوردية؟',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('إلغاء'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.amber.shade700,
                        ),
                        child: const Text('إنهاء'),
                      ),
                    ],
                  ),
                );
                if (confirm != true) return;
              }
            }

            try {
              await ref.read(toggleShiftProvider.future);
            } on MockGpsDetectedException {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'تم اكتشاف تطبيق محاكاة موقع. يرجى تعطيله للاستمرار.',
                    ),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('حدث خطأ. حاول مرة أخرى')),
                );
              }
            }
          },
        ),
      ),
    );
  }
}
