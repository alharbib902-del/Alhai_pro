import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:alhai_core/alhai_core.dart';

/// Visual timeline showing delivery progress stages.
class DeliveryTimeline extends StatelessWidget {
  final DeliveryStatus status;

  const DeliveryTimeline({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final stages = [
      _Stage('تم التعيين', Icons.assignment_turned_in, _isCompleted(0)),
      _Stage('تم القبول', Icons.check_circle, _isCompleted(1)),
      _Stage('تم الاستلام', Icons.inventory_2, _isCompleted(2)),
      _Stage('في الطريق', Icons.local_shipping, _isCompleted(3)),
      _Stage('تم التوصيل', Icons.home, _isCompleted(4)),
    ];

    return Row(
      children: [
        for (int i = 0; i < stages.length; i++) ...[
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: stages[i].completed
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    stages[i].icon,
                    size: 16,
                    color: stages[i].completed
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.xxs),
                Text(
                  stages[i].label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    fontWeight: stages[i].completed
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: stages[i].completed
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (i < stages.length - 1)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.only(bottom: AlhaiSpacing.md),
                color: stages[i + 1].completed
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
              ),
            ),
        ],
      ],
    );
  }

  bool _isCompleted(int stageIndex) {
    final statusOrder = [
      [DeliveryStatus.assigned],
      [
        DeliveryStatus.accepted,
        DeliveryStatus.headingToPickup,
        DeliveryStatus.arrivedAtPickup,
      ],
      [DeliveryStatus.pickedUp],
      [DeliveryStatus.headingToCustomer, DeliveryStatus.arrivedAtCustomer],
      [DeliveryStatus.delivered],
    ];

    // Find which stage the current status belongs to
    int currentStage = 0;
    for (int i = 0; i < statusOrder.length; i++) {
      if (statusOrder[i].contains(status)) {
        currentStage = i;
        break;
      }
    }

    return stageIndex <= currentStage;
  }
}

class _Stage {
  final String label;
  final IconData icon;
  final bool completed;

  _Stage(this.label, this.icon, this.completed);
}
