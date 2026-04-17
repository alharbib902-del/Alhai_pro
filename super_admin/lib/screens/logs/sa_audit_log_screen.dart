import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../../core/services/sentry_service.dart';
import '../../providers/sa_dashboard_providers.dart';

/// Audit Log Viewer — displays entries from the `audit_log` table.
///
/// This screen reads the append-only audit trail that records all privileged
/// mutations and authentication events in the Super Admin console.
///
/// Features:
/// - Paginated list (most recent first)
/// - Filter by action type (auth, store, user, subscription, all)
/// - Search by actor email or target ID
/// - Pull-to-refresh
class SAAuditLogScreen extends ConsumerStatefulWidget {
  const SAAuditLogScreen({super.key});

  @override
  ConsumerState<SAAuditLogScreen> createState() => _SAAuditLogScreenState();
}

class _SAAuditLogScreenState extends ConsumerState<SAAuditLogScreen> {
  List<Map<String, dynamic>> _entries = [];
  bool _isLoading = true;
  String? _error;
  String _filterAction = 'all';
  final _searchController = TextEditingController();

  static const _pageSize = 100;

  @override
  void initState() {
    super.initState();
    _loadAuditLog();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAuditLog() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final client = ref.read(saSupabaseClientProvider);
      var query = client
          .from('sa_audit_log')
          .select('*')
          .order('created_at', ascending: false)
          .limit(_pageSize);

      final data = await query;
      final entries = (data as List).cast<Map<String, dynamic>>();

      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    } catch (e, st) {
      reportError(e, stackTrace: st, hint: 'SAAuditLogScreen: load failed');
      setState(() {
        _error = 'failed';
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredEntries {
    var filtered = _entries;

    // Filter by action prefix.
    if (_filterAction != 'all') {
      filtered = filtered
          .where(
            (e) => (e['action'] as String? ?? '').startsWith(_filterAction),
          )
          .toList();
    }

    // Filter by search text.
    final search = _searchController.text.trim().toLowerCase();
    if (search.isNotEmpty) {
      filtered = filtered.where((e) {
        final actorEmail = (e['actor_email'] as String? ?? '').toLowerCase();
        final targetId = (e['target_id'] as String? ?? '').toLowerCase();
        final action = (e['action'] as String? ?? '').toLowerCase();
        return actorEmail.contains(search) ||
            targetId.contains(search) ||
            action.contains(search);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadAuditLog,
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filters bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AlhaiSpacing.md,
              vertical: AlhaiSpacing.sm,
            ),
            child: Row(
              children: [
                // Action filter chips
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'All',
                          selected: _filterAction == 'all',
                          onTap: () => setState(() => _filterAction = 'all'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Auth',
                          selected: _filterAction == 'auth.',
                          onTap: () => setState(() => _filterAction = 'auth.'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Store',
                          selected: _filterAction == 'store.',
                          onTap: () => setState(() => _filterAction = 'store.'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'User',
                          selected: _filterAction == 'user.',
                          onTap: () => setState(() => _filterAction = 'user.'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Subscription',
                          selected: _filterAction == 'subscription.',
                          onTap: () =>
                              setState(() => _filterAction = 'subscription.'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Search field
                SizedBox(
                  width: 250,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by email, ID, action...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Content
          Expanded(
            child: _isLoading
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
                        const Text('Failed to load audit log'),
                        const SizedBox(height: 16),
                        FilledButton.tonal(
                          onPressed: _loadAuditLog,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _filteredEntries.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shield_rounded,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No audit entries found',
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadAuditLog,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(AlhaiSpacing.md),
                      itemCount: _filteredEntries.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        final entry = _filteredEntries[index];
                        return _AuditEntryTile(entry: entry);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: theme.colorScheme.primaryContainer,
      showCheckmark: false,
    );
  }
}

class _AuditEntryTile extends StatelessWidget {
  final Map<String, dynamic> entry;

  const _AuditEntryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final action = entry['action'] as String? ?? '';
    final actorEmail = entry['actor_email'] as String? ?? 'system';
    final targetType = entry['target_type'] as String? ?? '';
    final targetId = entry['target_id'] as String? ?? '';
    final createdAt = entry['created_at'] as String? ?? '';
    final metadata = entry['metadata'] as Map<String, dynamic>?;

    // Parse timestamp.
    final ts = DateTime.tryParse(createdAt);
    final timeStr = ts != null
        ? '${ts.year}-${ts.month.toString().padLeft(2, '0')}-'
              '${ts.day.toString().padLeft(2, '0')} '
              '${ts.hour.toString().padLeft(2, '0')}:'
              '${ts.minute.toString().padLeft(2, '0')}:'
              '${ts.second.toString().padLeft(2, '0')}'
        : createdAt;

    // Choose icon and color based on action.
    final (IconData icon, Color color) = switch (action) {
      String a
          when a.startsWith('auth.login_failed') ||
              a.startsWith('auth.mfa_failed') =>
        (Icons.warning_rounded, Colors.red),
      String a when a.startsWith('auth.login') => (
        Icons.login_rounded,
        Colors.green,
      ),
      String a when a.startsWith('auth.logout') => (
        Icons.logout_rounded,
        Colors.orange,
      ),
      String a when a.startsWith('auth.mfa') => (
        Icons.security_rounded,
        Colors.blue,
      ),
      String a when a.startsWith('store.') => (
        Icons.store_rounded,
        theme.colorScheme.primary,
      ),
      String a when a.startsWith('user.') => (
        Icons.person_rounded,
        theme.colorScheme.primary,
      ),
      String a when a.startsWith('subscription.') => (
        Icons.card_membership_rounded,
        theme.colorScheme.primary,
      ),
      _ => (Icons.shield_rounded, theme.colorScheme.onSurfaceVariant),
    };

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'by $actorEmail  |  $targetType/$targetId',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (metadata != null && metadata.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      metadata.entries
                          .where((e) => e.key != 'timestamp')
                          .map((e) => '${e.key}: ${e.value}')
                          .join(', '),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Text(
              timeStr,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
