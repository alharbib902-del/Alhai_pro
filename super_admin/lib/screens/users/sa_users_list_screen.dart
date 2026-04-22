import 'dart:async';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../providers/sa_providers.dart';
import '../../data/models/sa_user_model.dart';
import '../../ui/widgets/sa_skeleton.dart';
import '../../ui/widgets/sa_empty_state.dart';

/// Platform users list -- real Supabase data.
class SAUsersListScreen extends ConsumerStatefulWidget {
  const SAUsersListScreen({super.key});

  @override
  ConsumerState<SAUsersListScreen> createState() => _SAUsersListScreenState();
}

class _SAUsersListScreenState extends ConsumerState<SAUsersListScreen> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;
  int _rowsPerPage = 10;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _applySearch(String query) {
    ref.read(saUserSearchProvider.notifier).state = query;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final usersAsync = ref.watch(saUsersListProvider);
    final ds = ref.watch(saUsersDatasourceProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.usersManagement,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.lg),

            // Search
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 350),
              child: TextField(
                controller: _searchController,
                onChanged: (query) {
                  _debounceTimer?.cancel();
                  _debounceTimer = Timer(const Duration(milliseconds: 300), () {
                    _applySearch(query);
                  });
                },
                decoration: InputDecoration(
                  hintText: l10n.searchUsers,
                  prefixIcon: const Icon(Icons.search_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AlhaiRadius.input),
                  ),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(height: AlhaiSpacing.md),

            // Users table
            Expanded(
              child: usersAsync.when(
                loading: () => const SATableSkeleton(),
                error: (e, st) => Center(child: Text(l10n.saErrorLoading)),
                data: (users) {
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AlhaiRadius.card),
                      side: BorderSide(
                        color: colorScheme.outlineVariant,
                        width: AlhaiSpacing.strokeXs,
                      ),
                    ),
                    child: PaginatedDataTable2(
                      columnSpacing: 12,
                      horizontalMargin: 12,
                      minWidth: 800,
                      rowsPerPage: _rowsPerPage,
                      availableRowsPerPage: const [10, 25, 50],
                      onRowsPerPageChanged: (value) {
                        if (value != null) setState(() => _rowsPerPage = value);
                      },
                      headingRowHeight: 48,
                      dataRowHeight: 56,
                      empty: SAEmptyState.users(),
                      columns: [
                        DataColumn2(
                          label: Text(l10n.userName),
                          size: ColumnSize.L,
                        ),
                        DataColumn2(
                          label: Text(l10n.userEmail),
                          size: ColumnSize.L,
                        ),
                        DataColumn2(
                          label: Text(l10n.userRole),
                          fixedWidth: 130,
                        ),
                        DataColumn2(
                          label: Text(l10n.userLastActive),
                          fixedWidth: 150,
                        ),
                        const DataColumn2(label: SizedBox(), fixedWidth: 56),
                      ],
                      source: _UsersDataSource(
                        users: users,
                        context: context,
                        isDark: isDark,
                        colorScheme: colorScheme,
                        theme: theme,
                        ds: ds,
                        l10n: l10n,
                        onViewUser: (userId) => context.go('/users/$userId'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UsersDataSource extends DataTableSource {
  final List<SAUser> users;
  final BuildContext context;
  final bool isDark;
  final ColorScheme colorScheme;
  final ThemeData theme;
  final dynamic ds;
  final AppLocalizations l10n;
  final void Function(String userId) onViewUser;

  _UsersDataSource({
    required this.users,
    required this.context,
    required this.isDark,
    required this.colorScheme,
    required this.theme,
    required this.ds,
    required this.l10n,
    required this.onViewUser,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= users.length) return null;
    final user = users[index];

    final name = user.name ?? 'Unknown';
    final email = user.email ?? '-';
    final role = user.role ?? 'viewer';
    final isOnline = user.isOnline;
    final lastActive = user.lastActiveFormatted;
    final userId = user.id;

    final onlineColor = isDark
        ? const Color(0xFF4ADE80)
        : const Color(0xFF16A34A);

    return DataRow2(
      cells: [
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: colorScheme.primaryContainer,
                child: Text(
                  name.isNotEmpty ? name[0] : '?',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AlhaiSpacing.xs),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(name),
                  if (isOnline)
                    Text(
                      'Online',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: onlineColor,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        DataCell(Text(email)),
        DataCell(_RoleBadge(role: role)),
        DataCell(Text(lastActive)),
        DataCell(
          IconButton(
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            onPressed: () => onViewUser(userId),
            tooltip: l10n.viewDetails,
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => users.length;

  @override
  int get selectedRowCount => 0;
}

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final (color, label) = switch (role) {
      'super_admin' => (
        isDark ? const Color(0xFFF87171) : Colors.red,
        'Super Admin',
      ),
      'support' => (isDark ? const Color(0xFF60A5FA) : Colors.blue, 'Support'),
      'viewer' => (colorScheme.outline, 'Viewer'),
      _ => (colorScheme.outline, role),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.xs,
        vertical: AlhaiSpacing.xxxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AlhaiRadius.chip),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
