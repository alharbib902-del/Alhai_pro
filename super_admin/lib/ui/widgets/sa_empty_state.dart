import 'package:flutter/material.dart';

/// Unified empty state widget for Super Admin screens
class SAEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SAEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  /// Empty state for no stores
  factory SAEmptyState.stores({VoidCallback? onAdd}) => SAEmptyState(
        icon: Icons.store_rounded,
        title: '\u0644\u0627 \u062a\u0648\u062c\u062f \u0645\u062a\u0627\u062c\u0631',
        subtitle: '\u0623\u0636\u0641 \u0645\u062a\u062c\u0631\u0643 \u0627\u0644\u0623\u0648\u0644 \u0644\u0644\u0628\u062f\u0621',
        actionLabel: '\u0625\u0636\u0627\u0641\u0629 \u0645\u062a\u062c\u0631',
        onAction: onAdd,
      );

  /// Empty state for no users
  factory SAEmptyState.users() => const SAEmptyState(
        icon: Icons.people_rounded,
        title: '\u0644\u0627 \u064a\u0648\u062c\u062f \u0645\u0633\u062a\u062e\u062f\u0645\u0648\u0646',
        subtitle: '\u0644\u0645 \u064a\u062a\u0645 \u0627\u0644\u0639\u062b\u0648\u0631 \u0639\u0644\u0649 \u0645\u0633\u062a\u062e\u062f\u0645\u064a\u0646 \u0645\u0637\u0627\u0628\u0642\u064a\u0646',
      );

  /// Empty state for no subscriptions
  factory SAEmptyState.subscriptions() => const SAEmptyState(
        icon: Icons.card_membership_rounded,
        title: '\u0644\u0627 \u062a\u0648\u062c\u062f \u0627\u0634\u062a\u0631\u0627\u0643\u0627\u062a',
        subtitle: '\u0644\u0645 \u064a\u062a\u0645 \u0627\u0644\u0639\u062b\u0648\u0631 \u0639\u0644\u0649 \u0627\u0634\u062a\u0631\u0627\u0643\u0627\u062a',
      );

  /// Empty state for no search results
  factory SAEmptyState.searchResults() => const SAEmptyState(
        icon: Icons.search_off_rounded,
        title: '\u0644\u0627 \u062a\u0648\u062c\u062f \u0646\u062a\u0627\u0626\u062c',
        subtitle: '\u062c\u0631\u0651\u0628 \u0643\u0644\u0645\u0627\u062a \u0628\u062d\u062b \u0645\u062e\u062a\u0644\u0641\u0629',
      );

  /// Empty state for no data/analytics
  factory SAEmptyState.analytics() => const SAEmptyState(
        icon: Icons.analytics_rounded,
        title: '\u0644\u0627 \u062a\u0648\u062c\u062f \u0628\u064a\u0627\u0646\u0627\u062a',
        subtitle: '\u0633\u062a\u0638\u0647\u0631 \u0627\u0644\u0628\u064a\u0627\u0646\u0627\u062a \u0647\u0646\u0627 \u0639\u0646\u062f \u062a\u0648\u0641\u0631\u0647\u0627',
      );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: colorScheme.primary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.outline,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
