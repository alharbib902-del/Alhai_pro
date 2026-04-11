import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

class StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;
  final TextStyle? valueStyle;

  const StatItem({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null)
          Icon(icon, color: iconColor ?? theme.colorScheme.primary, size: 20),
        if (icon != null) const SizedBox(height: AlhaiSpacing.xs),
        Text(
          value,
          style:
              valueStyle ??
              theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AlhaiSpacing.xxs),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
