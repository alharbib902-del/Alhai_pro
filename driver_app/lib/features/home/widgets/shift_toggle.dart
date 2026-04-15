import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/location_service.dart';
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
