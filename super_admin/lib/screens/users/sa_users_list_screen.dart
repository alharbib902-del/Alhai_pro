import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

/// Platform users list.
class SAUsersListScreen extends StatefulWidget {
  const SAUsersListScreen({super.key});

  @override
  State<SAUsersListScreen> createState() => _SAUsersListScreenState();
}

class _SAUsersListScreenState extends State<SAUsersListScreen> {
  final _searchController = TextEditingController();

  final List<_UserRow> _users = [
    _UserRow('U-001', 'Ahmed Al-Rashid', 'ahmed@alhai.sa', 'super_admin', '2 min ago', true),
    _UserRow('U-002', 'Sara Mohammed', 'sara@alhai.sa', 'super_admin', '1 hr ago', true),
    _UserRow('U-003', 'Khalid Nasser', 'khalid@alhai.sa', 'support', '3 hrs ago', true),
    _UserRow('U-004', 'Fatima Youssef', 'fatima@alhai.sa', 'support', '1 day ago', false),
    _UserRow('U-005', 'Omar Ibrahim', 'omar@alhai.sa', 'viewer', '2 days ago', false),
    _UserRow('U-006', 'Noura Saleh', 'noura@alhai.sa', 'viewer', '5 hrs ago', true),
  ];

  List<_UserRow> get _filteredUsers {
    final q = _searchController.text.toLowerCase();
    if (q.isEmpty) return _users;
    return _users.where((u) {
      return u.name.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

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
                onChanged: (_) => setState(() {}),
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
              child: _filteredUsers.isEmpty
                  ? Center(
                      child: Text(
                        l10n.noUsersFound,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    )
                  : Card(
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
                          rows: _filteredUsers.map((user) {
                            return DataRow(cells: [
                              DataCell(Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor:
                                        theme.colorScheme.primaryContainer,
                                    child: Text(
                                      user.name[0],
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
                                      Text(user.name),
                                      if (user.isOnline)
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
                              DataCell(Text(user.email)),
                              DataCell(_RoleBadge(role: user.role)),
                              DataCell(Text(user.lastActive)),
                              DataCell(
                                IconButton(
                                  icon: const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 18,
                                  ),
                                  onPressed: () =>
                                      context.go('/users/${user.id}'),
                                  tooltip: l10n.viewDetails,
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                      ),
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

class _UserRow {
  final String id;
  final String name;
  final String email;
  final String role;
  final String lastActive;
  final bool isOnline;

  const _UserRow(
    this.id,
    this.name,
    this.email,
    this.role,
    this.lastActive,
    this.isOnline,
  );
}
