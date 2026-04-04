import 'package:flutter/material.dart';
import '../../tokens/alhai_colors.dart';

class AlhaiStatusBadge extends StatelessWidget {
  const AlhaiStatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.icon,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData? icon;

  /// Factory for common status types
  factory AlhaiStatusBadge.status({
    required String status,
    required String label,
    required bool isDark,
    Key? key,
  }) {
    final (bg, fg) = switch (status) {
      'active' => (
          AlhaiColors.statusActiveBackground(isDark),
          AlhaiColors.statusActiveForeground(isDark)
        ),
      'trial' => (
          AlhaiColors.statusTrialBackground(isDark),
          AlhaiColors.statusTrialForeground(isDark)
        ),
      'expired' => (
          AlhaiColors.statusExpiredBackground(isDark),
          AlhaiColors.statusExpiredForeground(isDark)
        ),
      'suspended' => (
          AlhaiColors.statusSuspendedBackground(isDark),
          AlhaiColors.statusSuspendedForeground(isDark)
        ),
      'paid' => (
          AlhaiColors.statusActiveBackground(isDark),
          AlhaiColors.statusActiveForeground(isDark)
        ),
      'unpaid' || 'pending' => (
          AlhaiColors.statusTrialBackground(isDark),
          AlhaiColors.statusTrialForeground(isDark)
        ),
      'overdue' => (
          AlhaiColors.statusExpiredBackground(isDark),
          AlhaiColors.statusExpiredForeground(isDark)
        ),
      _ => (
          AlhaiColors.statusInfoBackground(isDark),
          AlhaiColors.statusInfoForeground(isDark)
        ),
    };
    return AlhaiStatusBadge(
        key: key, label: label, backgroundColor: bg, foregroundColor: fg);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: foregroundColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: foregroundColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
