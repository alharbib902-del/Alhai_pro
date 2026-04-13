/// Lite System Alerts Screen
///
/// Displays system-level alerts: sync health, unsynced items,
/// and inventory warnings. Queries syncQueueDao and productsDao.
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart' show AppRoutes;

import '../../providers/lite_screen_providers.dart';

/// System alerts screen for Admin Lite
class LiteSystemAlertsScreen extends ConsumerWidget {
  const LiteSystemAlertsScreen({super.key});

  void _handleAlertAction(
    BuildContext context,
    WidgetRef ref,
    SystemAlertData alert,
  ) {
    if (alert.title.contains('Sync') || alert.title.contains('Unsynced')) {
      context.go(AppRoutes.syncStatus);
    } else {
      ref.invalidate(liteSystemAlertsProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final l10n = AppLocalizations.of(context);
    final dataAsync = ref.watch(liteSystemAlertsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings), centerTitle: true),
      body: dataAsync.when(
        data: (alerts) {
          if (alerts.isEmpty) return _buildEmptyState(context, isDark, l10n);
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(liteSystemAlertsProvider),
            child: ListView.builder(
              padding: EdgeInsets.all(
                isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg,
              ),
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                return _buildAlertTile(context, ref, alerts[index], isDark);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.errorOccurred),
              TextButton.icon(
                onPressed: () => ref.invalidate(liteSystemAlertsProvider),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.tryAgain),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.verified_outlined,
            size: 64,
            color: isDark
                ? Colors.white24
                : AlhaiColors.success.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          Text(
            l10n.noResults,
            style: TextStyle(
              fontSize: 16,
              color: isDark
                  ? Colors.white54
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Color _severityColor(String severity) {
    return switch (severity) {
      'HIGH' => AlhaiColors.error,
      'MEDIUM' => AlhaiColors.warning,
      _ => AlhaiColors.info,
    };
  }

  IconData _alertIcon(String title) {
    if (title.contains('Sync') || title.contains('Unsynced')) {
      return Icons.sync_problem;
    }
    if (title.contains('Inventory')) return Icons.inventory_2_outlined;
    if (title.contains('Storage')) return Icons.storage;
    return Icons.warning_amber_rounded;
  }

  Widget _buildAlertTile(
    BuildContext context,
    WidgetRef ref,
    SystemAlertData alert,
    bool isDark,
  ) {
    final color = _severityColor(alert.severity);
    final icon = _alertIcon(alert.title);

    return Container(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white12
              : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Expanded(
                child: Text(
                  alert.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AlhaiSpacing.xs,
                  vertical: AlhaiSpacing.xxxs,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  alert.severity,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          Text(
            alert.description,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? Colors.white54
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (alert.actionLabel != null) ...[
            const SizedBox(height: AlhaiSpacing.sm),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: () => _handleAlertAction(context, ref, alert),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AlhaiSpacing.sm,
                  ),
                  minimumSize: const Size(0, 32),
                ),
                child: Text(
                  alert.actionLabel!,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
