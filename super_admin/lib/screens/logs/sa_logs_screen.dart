import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

import '../../core/services/sentry_service.dart';
import '../../providers/sa_dashboard_providers.dart';

/// Platform activity logs screen.
/// Shows recent system events from Supabase auth logs and user activity.
class SALogsScreen extends ConsumerStatefulWidget {
  const SALogsScreen({super.key});

  @override
  ConsumerState<SALogsScreen> createState() => _SALogsScreenState();
}

class _SALogsScreenState extends ConsumerState<SALogsScreen> {
  List<Map<String, dynamic>> _logs = [];
  bool _isLoading = true;
  String? _error;
  String _filterLevel = 'all';

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final client = ref.read(saSupabaseClientProvider);

      // Fetch recent user activity from users table
      final recentLogins = await client
          .from('users')
          .select('id, name, role, last_login_at, created_at')
          .order('last_login_at', ascending: false, nullsFirst: false)
          .limit(50);

      final logs = <Map<String, dynamic>>[];
      for (final user in recentLogins as List) {
        final lastLogin = user['last_login_at'] as String?;
        if (lastLogin != null) {
          logs.add({
            'type': 'login',
            'level': 'info',
            'message': '${user['name'] ?? 'Unknown'} signed in',
            'detail': 'Role: ${user['role']}',
            'timestamp': lastLogin,
          });
        }
        final createdAt = user['created_at'] as String?;
        if (createdAt != null) {
          logs.add({
            'type': 'signup',
            'level': 'info',
            'message': '${user['name'] ?? 'Unknown'} registered',
            'detail': 'Role: ${user['role']}',
            'timestamp': createdAt,
          });
        }
      }

      // Fetch recent store changes
      final recentStores = await client
          .from('stores')
          .select('id, name, is_active, created_at, updated_at')
          .order('updated_at', ascending: false, nullsFirst: false)
          .limit(20);

      for (final store in recentStores as List) {
        logs.add({
          'type': 'store',
          'level': store['is_active'] == false ? 'warning' : 'info',
          'message':
              'Store "${store['name']}" ${store['is_active'] == false ? 'suspended' : 'active'}',
          'detail': 'ID: ${store['id']}',
          'timestamp':
              store['updated_at'] as String? ??
              store['created_at'] as String? ??
              '',
        });
      }

      // Sort all logs by timestamp descending
      logs.sort(
        (a, b) =>
            (b['timestamp'] as String).compareTo(a['timestamp'] as String),
      );

      setState(() {
        _logs = logs;
        _isLoading = false;
      });
    } catch (e, st) {
      reportError(e, stackTrace: st, hint: 'SALogsScreen: failed to load activity logs');
      setState(() {
        _error = 'failed'; // generic flag; UI shows l10n message
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredLogs {
    if (_filterLevel == 'all') return _logs;
    return _logs.where((l) => l['level'] == _filterLevel).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.saActivityLogs),
        actions: [
          SegmentedButton<String>(
            segments: [
              const ButtonSegment(value: 'all', label: Text('All')),
              const ButtonSegment(value: 'info', label: Text('Info')),
              ButtonSegment(value: 'warning', label: Text(l10n.saWarnings)),
            ],
            selected: {_filterLevel},
            onSelectionChanged: (v) => setState(() => _filterLevel = v.first),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadLogs,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.errorOccurred, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 16),
                  FilledButton.tonal(
                    onPressed: _loadLogs,
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            )
          : _filteredLogs.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.receipt_long_rounded,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.saNoLogsFound, style: theme.textTheme.bodyLarge),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredLogs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final log = _filteredLogs[index];
                final level = log['level'] as String;
                final icon = switch (log['type'] as String) {
                  'login' => Icons.login_rounded,
                  'signup' => Icons.person_add_rounded,
                  'store' => Icons.store_rounded,
                  _ => Icons.info_outline_rounded,
                };
                final color = level == 'warning'
                    ? Colors.amber
                    : theme.colorScheme.primary;

                final ts = DateTime.tryParse(log['timestamp'] as String? ?? '');
                final timeStr = ts != null
                    ? '${ts.year}-${ts.month.toString().padLeft(2, '0')}-${ts.day.toString().padLeft(2, '0')} ${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}'
                    : '';

                return ListTile(
                  dense: true,
                  leading: Icon(icon, color: color, size: 20),
                  title: Text(
                    log['message'] as String,
                    style: theme.textTheme.bodyMedium,
                  ),
                  subtitle: Text(
                    log['detail'] as String? ?? '',
                    style: theme.textTheme.bodySmall,
                  ),
                  trailing: Text(timeStr, style: theme.textTheme.labelSmall),
                );
              },
            ),
    );
  }
}
