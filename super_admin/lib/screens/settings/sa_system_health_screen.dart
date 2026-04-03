import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

/// System health / monitoring screen.
class SASystemHealthScreen extends StatelessWidget {
  const SASystemHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= AlhaiBreakpoints.desktop;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AlhaiSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.systemHealth,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                FilledButton.tonal(
                  onPressed: () {},
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh_rounded, size: 18),
                      SizedBox(width: AlhaiSpacing.xs),
                      Text('Refresh'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AlhaiSpacing.md),

            // Overall status banner
            _OverallStatusBanner(status: 'healthy', l10n: l10n),
            const SizedBox(height: AlhaiSpacing.lg),

            // Service status cards
            GridView.count(
              crossAxisCount: isWide ? 3 : 1,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AlhaiSpacing.md,
              crossAxisSpacing: AlhaiSpacing.md,
              childAspectRatio: isWide ? 1.4 : 2.2,
              children: [
                _ServiceCard(
                  title: l10n.serverStatus,
                  status: 'healthy',
                  icon: Icons.dns_rounded,
                  metrics: {
                    l10n.uptime: '99.97%',
                    'Response Time': '45ms',
                    'Requests/min': '2,340',
                  },
                  l10n: l10n,
                ),
                _ServiceCard(
                  title: l10n.databaseStatus,
                  status: 'healthy',
                  icon: Icons.storage_rounded,
                  metrics: {
                    'Connections': '124/500',
                    'Query Time': '12ms',
                    'Size': '48.3 GB',
                  },
                  l10n: l10n,
                ),
                _ServiceCard(
                  title: l10n.apiLatency,
                  status: 'healthy',
                  icon: Icons.speed_rounded,
                  metrics: {
                    'p50': '32ms',
                    'p95': '128ms',
                    'p99': '340ms',
                  },
                  l10n: l10n,
                ),
              ],
            ),
            const SizedBox(height: AlhaiSpacing.lg),

            // Resource usage
            Text(
              'Resource Usage',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.md),
            GridView.count(
              crossAxisCount: isWide ? 3 : 1,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AlhaiSpacing.md,
              crossAxisSpacing: AlhaiSpacing.md,
              childAspectRatio: isWide ? 2.0 : 2.5,
              children: [
                _ResourceGauge(
                  title: l10n.cpuUsage,
                  value: 0.42,
                  label: '42%',
                  color: Colors.green,
                ),
                _ResourceGauge(
                  title: l10n.memoryUsage,
                  value: 0.68,
                  label: '68%',
                  color: Colors.orange,
                ),
                _ResourceGauge(
                  title: l10n.diskUsage,
                  value: 0.55,
                  label: '55%',
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: AlhaiSpacing.lg),

            // Error rate + recent alerts
            Text(
              l10n.errorRate,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.md),
            _ErrorRateCard(),
            const SizedBox(height: AlhaiSpacing.lg),

            // Recent incidents
            Text(
              'Recent Incidents',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.md),
            _IncidentsList(),
          ],
        ),
      ),
    );
  }
}

class _OverallStatusBanner extends StatelessWidget {
  final String status;
  final AppLocalizations l10n;
  const _OverallStatusBanner(
      {required this.status, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (color, icon, label) = switch (status) {
      'healthy' => (Colors.green, Icons.check_circle_rounded, l10n.healthy),
      'degraded' => (Colors.orange, Icons.warning_rounded, l10n.degraded),
      'down' => (Colors.red, Icons.error_rounded, l10n.down),
      _ => (Colors.grey, Icons.help_rounded, 'Unknown'),
    };

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AlhaiRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: AlhaiSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'All Systems: $label',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${l10n.lastChecked}: 30 seconds ago',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String title;
  final String status;
  final IconData icon;
  final Map<String, String> metrics;
  final AppLocalizations l10n;

  const _ServiceCard({
    required this.title,
    required this.status,
    required this.icon,
    required this.metrics,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = switch (status) {
      'healthy' => Colors.green,
      'degraded' => Colors.orange,
      'down' => Colors.red,
      _ => Colors.grey,
    };
    final statusLabel = switch (status) {
      'healthy' => l10n.healthy,
      'degraded' => l10n.degraded,
      'down' => l10n.down,
      _ => 'Unknown',
    };

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AlhaiRadius.card),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
          width: AlhaiSpacing.strokeXs,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: AlhaiSpacing.xs),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AlhaiSpacing.xxs),
                Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Divider(height: AlhaiSpacing.lg),
            ...metrics.entries.map((e) => Padding(
                  padding:
                      const EdgeInsets.only(bottom: AlhaiSpacing.xs),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        e.key,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      Text(
                        e.value,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _ResourceGauge extends StatelessWidget {
  final String title;
  final double value;
  final String label;
  final Color color;

  const _ResourceGauge({
    required this.title,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AlhaiRadius.card),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
          width: AlhaiSpacing.strokeXs,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AlhaiSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AlhaiRadius.full),
              child: LinearProgressIndicator(
                value: value,
                backgroundColor:
                    theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorRateCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AlhaiRadius.card),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
          width: AlhaiSpacing.strokeXs,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.lg),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '0.12%',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    'Current error rate (last 24h)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AlhaiSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ErrorRow(code: '5xx', count: '23', color: Colors.red),
                  const SizedBox(height: AlhaiSpacing.xs),
                  _ErrorRow(
                      code: '4xx', count: '156', color: Colors.orange),
                  const SizedBox(height: AlhaiSpacing.xs),
                  _ErrorRow(
                      code: 'Timeout', count: '8', color: Colors.amber),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorRow extends StatelessWidget {
  final String code;
  final String count;
  final Color color;
  const _ErrorRow({
    required this.code,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AlhaiSpacing.xs),
        Text(
          code,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          count,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _IncidentsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AlhaiRadius.card),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
          width: AlhaiSpacing.strokeXs,
        ),
      ),
      child: Column(
        children: [
          _IncidentTile(
            title: 'Database connection spike',
            time: '2 hours ago',
            severity: 'warning',
            resolved: true,
          ),
          const Divider(height: 1),
          _IncidentTile(
            title: 'API latency increase (p99 > 500ms)',
            time: '1 day ago',
            severity: 'warning',
            resolved: true,
          ),
          const Divider(height: 1),
          _IncidentTile(
            title: 'Payment gateway timeout',
            time: '3 days ago',
            severity: 'critical',
            resolved: true,
          ),
        ],
      ),
    );
  }
}

class _IncidentTile extends StatelessWidget {
  final String title;
  final String time;
  final String severity;
  final bool resolved;

  const _IncidentTile({
    required this.title,
    required this.time,
    required this.severity,
    required this.resolved,
  });

  @override
  Widget build(BuildContext context) {
    final severityColor =
        severity == 'critical' ? Colors.red : Colors.orange;

    return ListTile(
      leading: Icon(
        resolved
            ? Icons.check_circle_rounded
            : Icons.error_rounded,
        color: resolved ? Colors.green : severityColor,
      ),
      title: Text(title),
      subtitle: Text(time),
      trailing: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AlhaiSpacing.xs,
          vertical: AlhaiSpacing.xxxs,
        ),
        decoration: BoxDecoration(
          color: resolved
              ? Colors.green.withValues(alpha: 0.1)
              : severityColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AlhaiRadius.chip),
        ),
        child: Text(
          resolved ? 'Resolved' : severity.toUpperCase(),
          style: TextStyle(
            color: resolved ? Colors.green : severityColor,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
