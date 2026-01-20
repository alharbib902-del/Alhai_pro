import 'package:flutter/material.dart';

/// Alhai Quick Action - Dashboard quick action button (v1.1.0)
/// Used in: admin_pos, super_admin dashboards
class AlhaiQuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final bool isLoading;

  const AlhaiQuickAction({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final actionColor = color ?? colorScheme.primary;

    return InkWell(
      onTap: isLoading ? null : onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: actionColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: actionColor.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: actionColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: actionColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Grid of quick actions
class AlhaiQuickActionsGrid extends StatelessWidget {
  final List<AlhaiQuickAction> actions;
  final int crossAxisCount;
  final double spacing;

  const AlhaiQuickActionsGrid({
    super.key,
    required this.actions,
    this.crossAxisCount = 4,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 1,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) => actions[index],
    );
  }
}
