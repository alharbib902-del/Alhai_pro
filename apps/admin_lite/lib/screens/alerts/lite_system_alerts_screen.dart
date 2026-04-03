/// Lite System Alerts Screen
///
/// Displays system-level alerts: sync errors, device issues,
/// license expiry, and security warnings.
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// System alerts screen for Admin Lite
class LiteSystemAlertsScreen extends StatelessWidget {
  const LiteSystemAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        centerTitle: true,
      ),
      body: _alerts.isEmpty
          ? _buildEmptyState(context, isDark, l10n)
          : ListView.builder(
              padding: EdgeInsets.all(isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg),
              itemCount: _alerts.length,
              itemBuilder: (context, index) {
                return _buildAlertTile(context, _alerts[index], isDark);
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.verified_outlined,
            size: 64,
            color: isDark ? Colors.white24 : AlhaiColors.success.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          Text(
            l10n.noResults,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white54 : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertTile(BuildContext context, _SystemAlert alert, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white12 : Theme.of(context).colorScheme.outlineVariant,
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
                  color: alert.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(alert.icon, color: alert.color, size: 20),
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
                padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.xs, vertical: AlhaiSpacing.xxxs),
                decoration: BoxDecoration(
                  color: alert.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  alert.severity,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: alert.color,
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
              color: isDark ? Colors.white54 : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: isDark ? Colors.white24 : Colors.black38),
              const SizedBox(width: AlhaiSpacing.xxs),
              Text(
                alert.time,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white24 : Colors.black38,
                ),
              ),
              const Spacer(),
              if (alert.actionLabel != null)
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.sm),
                    minimumSize: const Size(0, 32),
                  ),
                  child: Text(
                    alert.actionLabel!,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static const _alerts = [
    _SystemAlert(
      title: 'Sync Error',
      description: 'Failed to sync 3 transactions. Check internet connection.',
      severity: 'HIGH',
      time: '15 min ago',
      icon: Icons.sync_problem,
      color: AlhaiColors.error,
      actionLabel: 'Retry',
    ),
    _SystemAlert(
      title: 'Printer Disconnected',
      description: 'Receipt printer "POS-Printer-1" is offline.',
      severity: 'MEDIUM',
      time: '1 hour ago',
      icon: Icons.print_disabled,
      color: AlhaiColors.warning,
      actionLabel: 'Check',
    ),
    _SystemAlert(
      title: 'Backup Reminder',
      description: 'Last backup was 3 days ago. Consider running a backup.',
      severity: 'LOW',
      time: '3 hours ago',
      icon: Icons.backup_outlined,
      color: AlhaiColors.info,
      actionLabel: 'Backup',
    ),
    _SystemAlert(
      title: 'Storage Low',
      description: 'Device storage is 85% full. Free up space.',
      severity: 'MEDIUM',
      time: 'Yesterday',
      icon: Icons.storage,
      color: AlhaiColors.warning,
      actionLabel: null,
    ),
  ];
}

class _SystemAlert {
  final String title;
  final String description;
  final String severity;
  final String time;
  final IconData icon;
  final Color color;
  final String? actionLabel;

  const _SystemAlert({
    required this.title,
    required this.description,
    required this.severity,
    required this.time,
    required this.icon,
    required this.color,
    this.actionLabel,
  });
}
