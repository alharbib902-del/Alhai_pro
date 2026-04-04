import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../providers/sa_providers.dart';

/// Platform users list -- real Supabase data.
class SAUsersListScreen extends ConsumerStatefulWidget {
  const SAUsersListScreen({super.key});

  @override
  ConsumerState<SAUsersListScreen> createState() => _SAUsersListScreenState();
}

class _SAUsersListScreenState extends ConsumerState<SAUsersListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applySearch(String query) {
    ref.read(saUserSearchProvider.notifier).state = query;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            SizedBox(
              width: 350,
              child: TextField(
                controller: _searchController,
                onChanged: _applySearch,
                decoration: InputDecoration(
                  hintText: l10n.searchUsers,
                  prefixIcon: const Icon(Icons.search_rounded),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AlhaiRadius.input),
                  ),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(height: AlhaiSpacing.md),

            // Users table
            Expanded(
              child: usersAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (users) {
                  if (users.isEmpty) {
                    return Center(
                      child: Text(
                        l10n.noUsersFound,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    );
                  }

                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AlhaiRadius.card),
                      side: BorderSide(
                        color: theme.colorScheme.outlineVariant,
                        width: AlhaiSpacing.strokeXs,
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: DataTable(
                        columnSpacing: AlhaiSpacing.lg,
                        headingRowHeight: 48,
                        dataRowMinHeight: 56,
                        dataRowMaxHeight: 56,
                        columns: [
                          DataColumn(label: Text(l10n.userName)),
                          DataColumn(label: Text(l10n.userEmail)),
                          DataColumn(label: Text(l10n.userRole)),
                          DataColumn(label: Text(l10n.userLastActive)),
                          const DataColumn(label: SizedBox()),
                        ],
                        rows: users.map((user) {
                          final name =
                              user['name'] as String? ?? 'Unknown';
                          final email =
                              user['email'] as String? ?? '-';
                          final role =
                              user['role'] as String? ?? 'viewer';
                          final lastSignIn =
                              user['last_sign_in_at'] as String?;
                          final isOnline = ds.isUserOnline(user);
                          final lastActive =
                              ds.formatLastActive(lastSignIn);
                          final userId = user['id'] as String? ?? '';

                          return DataRow(cells: [
                            DataCell(Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor:
                                      theme.colorScheme.primaryContainer,
                                  child: Text(
                                    name.isNotEmpty ? name[0] : '?',
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AlhaiSpacing.xs),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Text(name),
                                    if (isOnline)
                                      Text(
                                        'Online',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                          color: Colors.green,
                                          fontSize: 10,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            )),
                            DataCell(Text(email)),
                            DataCell(_RoleBadge(role: role)),
                            DataCell(Text(lastActive)),
                            DataCell(
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 18,
                                ),
                                onPressed: () =>
                                    context.go('/users/$userId'),
                                tooltip: l10n.viewDetails,
                              ),
                            ),
                          ]);
                        }).toList(),
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

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (role) {
      'super_admin' => (Colors.red, 'Super Admin'),
      'support' => (Colors.blue, 'Support'),
      'viewer' => (Colors.grey, 'Viewer'),
      _ => (Colors.grey, role),
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
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
