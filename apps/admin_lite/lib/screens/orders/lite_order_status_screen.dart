/// Lite Order Status Update Screen
///
/// Allows updating order status through predefined steps.
/// Shows current status and allows progression to next step.
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// Order status update screen for Admin Lite
class LiteOrderStatusScreen extends StatefulWidget {
  final String orderId;

  const LiteOrderStatusScreen({super.key, required this.orderId});

  @override
  State<LiteOrderStatusScreen> createState() => _LiteOrderStatusScreenState();
}

class _LiteOrderStatusScreenState extends State<LiteOrderStatusScreen> {
  int _currentStep = 1; // 0=confirmed, 1=preparing, 2=ready, 3=delivering, 4=completed

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.status),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order header
            _buildOrderHeader(context, isDark),
            const SizedBox(height: AlhaiSpacing.lg),

            // Status steps
            ..._buildStatusSteps(context, isDark, l10n),

            const SizedBox(height: AlhaiSpacing.xl),

            // Action button
            if (_currentStep < 4)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    setState(() {
                      if (_currentStep < 4) _currentStep++;
                    });
                  },
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: Text(_getNextStepLabel(l10n)),
                  style: FilledButton.styleFrom(
                    backgroundColor: AlhaiColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),

            if (_currentStep >= 4) ...[
              const SizedBox(height: AlhaiSpacing.md),
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.check_circle, size: 48, color: AlhaiColors.success),
                    const SizedBox(height: AlhaiSpacing.sm),
                    Text(
                      l10n.completed,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AlhaiColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AlhaiSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AlhaiColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.receipt_long, color: AlhaiColors.primary, size: 24),
          ),
          const SizedBox(width: AlhaiSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#ORD-1052',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  'Ahmed Ali \u2022 5 items \u2022 245 SAR',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white54 : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStatusSteps(BuildContext context, bool isDark, AppLocalizations l10n) {
    final steps = [
      _StatusStep(l10n.orderStatusConfirmed, Icons.check_circle, '10:30 AM'),
      _StatusStep(l10n.orderStatusPreparing, Icons.restaurant, ''),
      _StatusStep(l10n.orderStatusReady, Icons.inventory_2, ''),
      _StatusStep(l10n.orderStatusDelivering, Icons.local_shipping, ''),
      _StatusStep(l10n.completed, Icons.done_all, ''),
    ];

    return steps.asMap().entries.map((entry) {
      final step = entry.value;
      final index = entry.key;
      final isCompleted = index <= _currentStep;
      final isCurrent = index == _currentStep;
      final isLast = index == steps.length - 1;

      final color = isCompleted ? AlhaiColors.success : (isDark ? Colors.white12 : Colors.grey.shade300);

      return Padding(
        padding: const EdgeInsets.only(bottom: AlhaiSpacing.xxs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? AlhaiColors.primary
                        : (isCompleted ? AlhaiColors.success.withValues(alpha: 0.15) : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade100)),
                    borderRadius: BorderRadius.circular(12),
                    border: isCurrent ? null : Border.all(color: color),
                  ),
                  child: Icon(
                    step.icon,
                    size: 20,
                    color: isCurrent ? Colors.white : (isCompleted ? AlhaiColors.success : (isDark ? Colors.white24 : Colors.grey)),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 24,
                    margin: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxxs),
                    color: isCompleted ? AlhaiColors.success.withValues(alpha: 0.4) : (isDark ? Colors.white12 : Colors.grey.shade200),
                  ),
              ],
            ),
            const SizedBox(width: AlhaiSpacing.md),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: AlhaiSpacing.xs),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isCurrent || isCompleted ? FontWeight.w600 : FontWeight.normal,
                        color: isCurrent
                            ? AlhaiColors.primary
                            : (isCompleted
                                ? (isDark ? Colors.white : Colors.black87)
                                : (isDark ? Colors.white38 : Colors.black38)),
                      ),
                    ),
                    if (step.time.isNotEmpty)
                      Text(
                        step.time,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white38 : Colors.black45,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  String _getNextStepLabel(AppLocalizations l10n) {
    return switch (_currentStep) {
      0 => l10n.orderStatusPreparing,
      1 => l10n.orderStatusReady,
      2 => l10n.orderStatusDelivering,
      3 => l10n.completed,
      _ => l10n.done,
    };
  }
}

class _StatusStep {
  final String label;
  final IconData icon;
  final String time;
  const _StatusStep(this.label, this.icon, this.time);
}
