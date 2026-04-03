import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shifts/providers/shifts_providers.dart';

class ShiftToggle extends ConsumerWidget {
  const ShiftToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnShift = ref.watch(isOnShiftProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.xs),
      child: ActionChip(
        avatar: Icon(
          isOnShift ? Icons.circle : Icons.circle_outlined,
          size: 12,
          color: isOnShift ? Colors.green : theme.colorScheme.outline,
        ),
        label: Text(
          isOnShift ? 'متصل' : 'غير متصل',
          style: TextStyle(
            color: isOnShift ? Colors.green : theme.colorScheme.outline,
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: () async {
          try {
            await ref.read(toggleShiftProvider.future);
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$e')),
              );
            }
          }
        },
      ),
    );
  }
}
