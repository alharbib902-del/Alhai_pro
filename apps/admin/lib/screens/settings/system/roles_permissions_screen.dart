/// شاشة الأدوار والصلاحيات - Roles & Permissions Screen
///
/// شاشة لإدارة أدوار المستخدمين وصلاحياتهم

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_auth/alhai_auth.dart'
    show isAdminProvider, currentUserProvider;
import 'package:alhai_design_system/alhai_design_system.dart';

import '../../../core/constants/admin_permissions.dart';

/// شاشة الأدوار والصلاحيات
class RolesPermissionsScreen extends ConsumerStatefulWidget {
  const RolesPermissionsScreen({super.key});

  @override
  ConsumerState<RolesPermissionsScreen> createState() =>
      _RolesPermissionsScreenState();
}

class _RolesPermissionsScreenState extends ConsumerState<RolesPermissionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  // بيانات الأدوار - يتم تحميلها من قاعدة البيانات
  List<Role> _roles = [];

  // بيانات تجريبية احتياطية
  static List<Role> get _defaultRoles => [
        Role(
          id: '1',
          name: '\u0645\u062f\u064a\u0631 \u0627\u0644\u0646\u0638\u0627\u0645',
          description:
              '\u0635\u0644\u0627\u062d\u064a\u0627\u062a \u0643\u0627\u0645\u0644\u0629 \u0644\u0644\u0646\u0638\u0627\u0645',
          color: Colors.purple,
          icon: Icons.admin_panel_settings,
          usersCount: 1,
          isSystemRole: true,
          permissions: Permission.values.map((p) => p.name).toList(),
        ),
        Role(
          id: '2',
          name: '\u0645\u062f\u064a\u0631 \u0627\u0644\u0645\u062a\u062c\u0631',
          description:
              '\u0625\u062f\u0627\u0631\u0629 \u0627\u0644\u0645\u062a\u062c\u0631 \u0648\u0627\u0644\u0645\u0648\u0638\u0641\u064a\u0646',
          color: AppColors.primary,
          icon: Icons.store,
          usersCount: 2,
          isSystemRole: true,
          permissions: [
            'pos_access',
            'products_manage',
            'inventory_manage',
            'customers_manage',
            'reports_view',
            'staff_manage',
            'discounts_create',
            'refunds_approve',
          ],
        ),
        Role(
          id: '3',
          name: '\u0643\u0627\u0634\u064a\u0631',
          description:
              '\u0639\u0645\u0644\u064a\u0627\u062a \u0627\u0644\u0628\u064a\u0639 \u0648\u0627\u0644\u062f\u0641\u0639',
          color: AppColors.success,
          icon: Icons.point_of_sale,
          usersCount: 5,
          isSystemRole: true,
          permissions: [
            'pos_access',
            'products_view',
            'customers_view',
            'discounts_apply',
          ],
        ),
        Role(
          id: '4',
          name: '\u0623\u0645\u064a\u0646 \u0645\u062e\u0632\u0646',
          description:
              '\u0625\u062f\u0627\u0631\u0629 \u0627\u0644\u0645\u062e\u0632\u0648\u0646 \u0648\u0627\u0644\u0645\u0646\u062a\u062c\u0627\u062a',
          color: AppColors.warning,
          icon: Icons.inventory,
          usersCount: 2,
          isSystemRole: false,
          permissions: [
            'products_manage',
            'inventory_manage',
            'inventory_adjust',
            'suppliers_view',
          ],
        ),
        Role(
          id: '5',
          name: '\u0645\u062d\u0627\u0633\u0628',
          description:
              '\u0627\u0644\u062a\u0642\u0627\u0631\u064a\u0631 \u0627\u0644\u0645\u0627\u0644\u064a\u0629 \u0648\u0627\u0644\u062d\u0633\u0627\u0628\u0627\u062a',
          color: AppColors.info,
          icon: Icons.account_balance,
          usersCount: 1,
          isSystemRole: false,
          permissions: [
            'reports_view',
            'reports_export',
            'debts_manage',
            'expenses_manage',
          ],
        ),
      ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    try {
      final db = getIt<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider) ?? kDefaultStoreId;
      final dbRoles = await db.usersDao.getAllRoles(storeId);

      if (dbRoles.isEmpty) {
        setState(() {
          _roles = _defaultRoles;
          _isLoading = false;
        });
        return;
      }

      final mappedRoles = dbRoles.map((r) {
        // Parse permissions from JSON or comma-separated
        List<String> permissions = [];
        try {
          if (r.permissions.startsWith('[')) {
            permissions = List<String>.from(jsonDecode(r.permissions));
          } else if (r.permissions.startsWith('{')) {
            final map = jsonDecode(r.permissions) as Map<String, dynamic>;
            permissions = map.keys.where((k) => map[k] == true).toList();
          } else {
            permissions = r.permissions
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList();
          }
        } catch (_) {
          permissions = [];
        }

        return Role(
          id: r.id,
          name: r.name,
          description: r.nameEn ?? '',
          color: _getRoleColor(r.name),
          icon: _getRoleIcon(r.name),
          usersCount: 0,
          isSystemRole: r.isSystem,
          permissions: permissions,
        );
      }).toList();

      setState(() {
        _roles = mappedRoles;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _roles = _defaultRoles;
        _isLoading = false;
      });
    }
  }

  Color _getRoleColor(String roleName) {
    if (roleName.contains(
            '\u0645\u062f\u064a\u0631 \u0627\u0644\u0646\u0638\u0627\u0645') ||
        roleName.toLowerCase().contains('admin')) {
      return Colors.purple;
    }
    if (roleName.contains('\u0645\u062f\u064a\u0631') ||
        roleName.toLowerCase().contains('manager')) {
      return AppColors.primary;
    }
    if (roleName.contains('\u0643\u0627\u0634\u064a\u0631') ||
        roleName.toLowerCase().contains('cashier')) {
      return AppColors.success;
    }
    if (roleName.contains('\u0623\u0645\u064a\u0646') ||
        roleName.toLowerCase().contains('warehouse')) {
      return AppColors.warning;
    }
    if (roleName.contains('\u0645\u062d\u0627\u0633\u0628') ||
        roleName.toLowerCase().contains('accountant')) {
      return AppColors.info;
    }
    return AppColors.primary;
  }

  IconData _getRoleIcon(String roleName) {
    if (roleName.contains(
            '\u0645\u062f\u064a\u0631 \u0627\u0644\u0646\u0638\u0627\u0645') ||
        roleName.toLowerCase().contains('admin')) {
      return Icons.admin_panel_settings;
    }
    if (roleName.contains('\u0645\u062f\u064a\u0631') ||
        roleName.toLowerCase().contains('manager')) {
      return Icons.store;
    }
    if (roleName.contains('\u0643\u0627\u0634\u064a\u0631') ||
        roleName.toLowerCase().contains('cashier')) {
      return Icons.point_of_sale;
    }
    if (roleName.contains('\u0623\u0645\u064a\u0646') ||
        roleName.toLowerCase().contains('warehouse')) {
      return Icons.inventory;
    }
    if (roleName.contains('\u0645\u062d\u0627\u0633\u0628') ||
        roleName.toLowerCase().contains('accountant')) {
      return Icons.account_balance;
    }
    return Icons.badge;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = context.isDesktop;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        AppHeader(
          title: l10n.rolesPermissions,
          onMenuTap:
              isWideScreen ? null : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 3,
          userName: l10n.defaultUserName,
          userRole: l10n.branchManager,
        ),
        // Tab bar
        Container(
          color: Theme.of(context).colorScheme.surface,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor:
                Theme.of(context).colorScheme.onSurfaceVariant,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(icon: const Icon(Icons.groups), text: l10n.rolesTab),
              Tab(icon: const Icon(Icons.security), text: l10n.permissionsTab),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildRolesTab(isDark),
              _buildPermissionsTab(isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRolesTab(bool isDark) {
    final l10n = AppLocalizations.of(context);
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AlhaiSpacing.lg),
      child: Column(
        children: [
          // Add role button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FilledButton.icon(
                onPressed: _showAddRoleDialog,
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.newRoleButton),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          if (_roles.isEmpty)
            AppEmptyState.noData(context, title: l10n.rolesPermissions)
          else
            ..._roles.map((role) => _buildRoleCard(role, isDark)),
        ],
      ),
    );
  }

  Widget _buildRoleCard(Role role, bool isDark) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: InkWell(
        onTap: () => _showRoleDetails(role),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: role.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(role.icon, color: role.color, size: 24),
              ),
              const SizedBox(width: AlhaiSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          role.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        if (role.isSystemRole) ...[
                          const SizedBox(width: AlhaiSpacing.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : AppColors.backgroundSecondary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              l10n.systemBadge,
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AlhaiSpacing.xxxs),
                    Text(
                      role.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AlhaiSpacing.xxs),
                    Row(
                      children: [
                        Icon(Icons.person,
                            size: 14,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(width: AlhaiSpacing.xxs),
                        Text(
                          l10n.userCountLabel(role.usersCount),
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: AlhaiSpacing.md),
                        Icon(Icons.key,
                            size: 14,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(width: AlhaiSpacing.xxs),
                        Text(
                          l10n.permissionCountLabel(role.permissions.length),
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                onSelected: (value) => _handleRoleAction(value, role),
                itemBuilder: (context) {
                  final l10n = AppLocalizations.of(context);
                  return [
                    PopupMenuItem(
                        value: 'edit', child: Text(l10n.editRoleMenu)),
                    PopupMenuItem(
                        value: 'duplicate',
                        child: Text(l10n.duplicateRoleMenu)),
                    PopupMenuItem(value: 'users', child: Text(l10n.users)),
                    if (!role.isSystemRole)
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(l10n.deleteRoleMenu,
                            style: const TextStyle(color: AppColors.error)),
                      ),
                  ];
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionsTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AlhaiSpacing.lg),
      child: Column(
        children: PermissionCategory.values.map((category) {
          return _buildPermissionCategory(category, isDark);
        }).toList(),
      ),
    );
  }

  Widget _buildPermissionCategory(PermissionCategory category, bool isDark) {
    final l10n = AppLocalizations.of(context);
    final permissions =
        Permission.values.where((p) => p.category == category).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(AlhaiSpacing.xs),
          decoration: BoxDecoration(
            color: category.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(category.icon, color: category.color, size: 20),
        ),
        title: Text(
          category.label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          l10n.permissionCountLabel(permissions.length),
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        children: permissions.map((permission) {
          return ListTile(
            leading: Icon(permission.icon,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20),
            title: Text(
              permission.label,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            subtitle: Text(
              permission.description,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: Text(
              permission.name,
              style: TextStyle(
                fontSize: 10,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.3)
                    : AppColors.textTertiary,
                fontFamily: 'monospace',
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // === Business logic methods (preserved from original) ===

  void _showRoleDetails(Role role) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: context.screenHeight * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AlhaiSpacing.md),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.lg),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AlhaiSpacing.sm),
                    decoration: BoxDecoration(
                      color: role.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(role.icon, color: role.color, size: 32),
                  ),
                  const SizedBox(width: AlhaiSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(role.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            )),
                        Text(role.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            )),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showEditRoleDialog(role);
                    },
                    icon: const Icon(Icons.edit),
                  ),
                ],
              ),
            ),
            const Divider(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(AlhaiSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.people, color: AppColors.primary),
                          const SizedBox(width: AlhaiSpacing.xs),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${role.usersCount}',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary)),
                              Text(l10n.users,
                                  style: const TextStyle(
                                      fontSize: 11, color: AppColors.primary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AlhaiSpacing.sm),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(AlhaiSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.key, color: AppColors.success),
                          const SizedBox(width: AlhaiSpacing.xs),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${role.permissions.length}',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.success)),
                              Text(l10n.permissionsTab,
                                  style: const TextStyle(
                                      fontSize: 11, color: AppColors.success)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AlhaiSpacing.md),
            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: AlhaiSpacing.lg),
                itemCount: role.permissions.length,
                itemBuilder: (context, index) {
                  final permissionName = role.permissions[index];
                  final permission = Permission.values.firstWhere(
                    (p) => p.name == permissionName,
                    orElse: () => Permission.posAccess,
                  );
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(AlhaiSpacing.xxs),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.check,
                          color: AppColors.success, size: 16),
                    ),
                    title: Text(permission.label,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface)),
                    subtitle: Text(permission.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        )),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddRoleDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => _RoleFormDialog(
        onSave: (name, description) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.addAction}: $name'),
              backgroundColor: AppColors.success,
            ),
          );
        },
      ),
    );
  }

  void _showEditRoleDialog(Role role) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => _RoleFormDialog(
        role: role,
        onSave: (name, description) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.save}: $name'),
              backgroundColor: AppColors.success,
            ),
          );
        },
      ),
    );
  }

  /// Security: verify the current user has admin privileges before
  /// performing sensitive role-management operations.
  bool _checkAdminPermission() {
    final isAdmin = ref.read(isAdminProvider);
    if (!isAdmin) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(l10n.errorOccurred),
            backgroundColor: AppColors.error),
      );
      debugPrint('Security: non-admin attempted sensitive role operation');
      return false;
    }
    return true;
  }

  void _handleRoleAction(String action, Role role) {
    // Security: edit, duplicate, delete require admin permission
    if ((action == 'edit' || action == 'duplicate' || action == 'delete') &&
        !_checkAdminPermission()) {
      return;
    }
    switch (action) {
      case 'edit':
        _showEditRoleDialog(role);
        break;
      case 'duplicate':
        _duplicateRole(role);
        break;
      case 'users':
        _showRoleUsers(role);
        break;
      case 'delete':
        _deleteRole(role);
        break;
    }
  }

  void _duplicateRole(Role role) {
    final l10n = AppLocalizations.of(context);
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${l10n.duplicateRoleMenu}: ${role.name}'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showRoleUsers(Role role) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AlhaiSpacing.lg),
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.users} - "${role.name}"',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.md),
            ...List.generate(
              role.usersCount,
              (index) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : AppColors.backgroundSecondary,
                  child: Text('${index + 1}'),
                ),
                title: Text(
                  '${l10n.users} ${index + 1}',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
                subtitle: Text('user${index + 1}@example.com'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Best-effort audit logging for sensitive role operations.
  void _logRoleAuditEvent(String action, String entityId, String entityName) {
    try {
      final db = getIt<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider) ?? '';
      final currentUser = ref.read(currentUserProvider);
      db.auditLogDao.log(
        storeId: storeId,
        userId: currentUser?.id ?? 'unknown',
        userName: currentUser?.name ?? 'unknown',
        action: AuditAction.settingsChange,
        entityType: 'role',
        entityId: entityId,
        description: '$action: $entityName',
      );
    } catch (e) {
      debugPrint('Audit log failed: $e');
    }
  }

  void _deleteRole(Role role) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteRoleMenu),
        content: Text('${l10n.delete} "${role.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              HapticFeedback.mediumImpact();
              // Audit log: role deletion
              _logRoleAuditEvent('role_delete', role.id, role.name);
              ScaffoldMessenger.of(this.context).showSnackBar(
                SnackBar(
                  content: Text('${l10n.delete}: ${role.name}'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}

/// نافذة إضافة/تعديل دور
class _RoleFormDialog extends StatefulWidget {
  final Role? role;
  final Function(String name, String description) onSave;

  const _RoleFormDialog({
    this.role,
    required this.onSave,
  });

  @override
  State<_RoleFormDialog> createState() => _RoleFormDialogState();
}

class _RoleFormDialogState extends State<_RoleFormDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  final Set<String> _selectedPermissions = {};

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.role?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.role?.description ?? '');
    if (widget.role != null) {
      _selectedPermissions.addAll(widget.role!.permissions);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Dialog(
      child: Container(
        width: ResponsiveDialog.maxWidth(context, maxDesktop: 500),
        constraints: BoxConstraints(
          maxHeight: context.screenHeight * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AlhaiSpacing.lg),
              child: Row(
                children: [
                  Text(
                    widget.role == null
                        ? l10n.addRoleTitle
                        : l10n.editRoleTitle,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 0),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AlhaiSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: l10n.roleNameField,
                        hintText: l10n.roleNameField,
                        prefixIcon: const Icon(Icons.badge),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: AlhaiSpacing.md),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: l10n.roleDescField,
                        hintText: l10n.roleDescField,
                        prefixIcon: const Icon(Icons.description),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: AlhaiSpacing.lg),
                    Text(
                      l10n.rolePermissionsLabel,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AlhaiSpacing.sm),
                    ...PermissionCategory.values.map((category) {
                      final permissions = Permission.values
                          .where((p) => p.category == category)
                          .toList();
                      return ExpansionTile(
                        leading: Icon(category.icon, color: category.color),
                        title: Text(category.label),
                        children: permissions.map((permission) {
                          return CheckboxListTile(
                            value:
                                _selectedPermissions.contains(permission.name),
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _selectedPermissions.add(permission.name);
                                } else {
                                  _selectedPermissions.remove(permission.name);
                                }
                              });
                            },
                            title: Text(permission.label),
                            subtitle: Text(permission.description,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary)),
                            controlAffinity: ListTileControlAffinity.leading,
                          );
                        }).toList(),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const Divider(height: 0),
            Padding(
              padding: const EdgeInsets.all(AlhaiSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: AlhaiSpacing.sm),
                  FilledButton(
                    onPressed: () {
                      if (_nameController.text.isNotEmpty) {
                        widget.onSave(
                          _nameController.text,
                          _descriptionController.text,
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: Text(l10n.save),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// نموذج الدور
class Role {
  final String id;
  final String name;
  final String description;
  final Color color;
  final IconData icon;
  final int usersCount;
  final bool isSystemRole;
  final List<String> permissions;

  Role({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.icon,
    required this.usersCount,
    required this.isSystemRole,
    required this.permissions,
  });
}

/// فئات الصلاحيات
enum PermissionCategory {
  pos,
  products,
  inventory,
  customers,
  sales,
  reports,
  settings,
  staff;

  String get label => '';
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case PermissionCategory.pos:
        return l10n.permCategoryPosLabel;
      case PermissionCategory.products:
        return l10n.permCategoryProductsLabel;
      case PermissionCategory.inventory:
        return l10n.permCategoryInventoryLabel;
      case PermissionCategory.customers:
        return l10n.permCategoryCustomersLabel;
      case PermissionCategory.sales:
        return l10n.permCategorySalesLabel;
      case PermissionCategory.reports:
        return l10n.permCategoryReportsLabel;
      case PermissionCategory.settings:
        return l10n.permCategorySettingsLabel;
      case PermissionCategory.staff:
        return l10n.permCategoryStaffLabel;
    }
  }

  IconData get icon {
    switch (this) {
      case PermissionCategory.pos:
        return Icons.point_of_sale;
      case PermissionCategory.products:
        return Icons.inventory_2;
      case PermissionCategory.inventory:
        return Icons.warehouse;
      case PermissionCategory.customers:
        return Icons.people;
      case PermissionCategory.sales:
        return Icons.shopping_cart;
      case PermissionCategory.reports:
        return Icons.analytics;
      case PermissionCategory.settings:
        return Icons.settings;
      case PermissionCategory.staff:
        return Icons.badge;
    }
  }

  Color get color {
    switch (this) {
      case PermissionCategory.pos:
        return AppColors.primary;
      case PermissionCategory.products:
        return AppColors.success;
      case PermissionCategory.inventory:
        return AppColors.warning;
      case PermissionCategory.customers:
        return AppColors.info;
      case PermissionCategory.sales:
        return Colors.purple;
      case PermissionCategory.reports:
        return Colors.teal;
      case PermissionCategory.settings:
        return AppColors.grey600;
      case PermissionCategory.staff:
        return Colors.indigo;
    }
  }
}

/// الصلاحيات
enum Permission {
  posAccess,
  posHold,
  posSplitPayment,
  productsView,
  productsManage,
  productsDelete,
  inventoryView,
  inventoryManage,
  inventoryAdjust,
  customersView,
  customersManage,
  customersDelete,
  discountsApply,
  discountsCreate,
  refundsRequest,
  refundsApprove,
  reportsView,
  reportsExport,
  settingsView,
  settingsManage,
  staffView,
  staffManage;

  /// Returns the permission string identifier from [AdminPermissions].
  String get name {
    switch (this) {
      case Permission.posAccess:
        return AdminPermissions.posAccess;
      case Permission.posHold:
        return AdminPermissions.posHold;
      case Permission.posSplitPayment:
        return AdminPermissions.posSplitPayment;
      case Permission.productsView:
        return AdminPermissions.productsView;
      case Permission.productsManage:
        return AdminPermissions.productsManage;
      case Permission.productsDelete:
        return AdminPermissions.productsDelete;
      case Permission.inventoryView:
        return AdminPermissions.inventoryView;
      case Permission.inventoryManage:
        return AdminPermissions.inventoryManage;
      case Permission.inventoryAdjust:
        return AdminPermissions.inventoryAdjust;
      case Permission.customersView:
        return AdminPermissions.customersView;
      case Permission.customersManage:
        return AdminPermissions.customersManage;
      case Permission.customersDelete:
        return AdminPermissions.customersDelete;
      case Permission.discountsApply:
        return AdminPermissions.discountsApply;
      case Permission.discountsCreate:
        return AdminPermissions.discountsCreate;
      case Permission.refundsRequest:
        return AdminPermissions.refundsRequest;
      case Permission.refundsApprove:
        return AdminPermissions.refundsApprove;
      case Permission.reportsView:
        return AdminPermissions.reportsView;
      case Permission.reportsExport:
        return AdminPermissions.reportsExport;
      case Permission.settingsView:
        return AdminPermissions.settingsView;
      case Permission.settingsManage:
        return AdminPermissions.settingsManage;
      case Permission.staffView:
        return AdminPermissions.staffView;
      case Permission.staffManage:
        return AdminPermissions.staffManage;
    }
  }

  String get label {
    switch (this) {
      case Permission.posAccess:
        return '\u0627\u0644\u0648\u0635\u0648\u0644 \u0644\u0646\u0642\u0637\u0629 \u0627\u0644\u0628\u064a\u0639';
      case Permission.posHold:
        return '\u062a\u0639\u0644\u064a\u0642 \u0627\u0644\u0641\u0648\u0627\u062a\u064a\u0631';
      case Permission.posSplitPayment:
        return '\u062a\u0642\u0633\u064a\u0645 \u0627\u0644\u062f\u0641\u0639';
      case Permission.productsView:
        return '\u0639\u0631\u0636 \u0627\u0644\u0645\u0646\u062a\u062c\u0627\u062a';
      case Permission.productsManage:
        return '\u0625\u062f\u0627\u0631\u0629 \u0627\u0644\u0645\u0646\u062a\u062c\u0627\u062a';
      case Permission.productsDelete:
        return '\u062d\u0630\u0641 \u0627\u0644\u0645\u0646\u062a\u062c\u0627\u062a';
      case Permission.inventoryView:
        return '\u0639\u0631\u0636 \u0627\u0644\u0645\u062e\u0632\u0648\u0646';
      case Permission.inventoryManage:
        return '\u0625\u062f\u0627\u0631\u0629 \u0627\u0644\u0645\u062e\u0632\u0648\u0646';
      case Permission.inventoryAdjust:
        return '\u062a\u0639\u062f\u064a\u0644 \u0627\u0644\u0645\u062e\u0632\u0648\u0646';
      case Permission.customersView:
        return '\u0639\u0631\u0636 \u0627\u0644\u0639\u0645\u0644\u0627\u0621';
      case Permission.customersManage:
        return '\u0625\u062f\u0627\u0631\u0629 \u0627\u0644\u0639\u0645\u0644\u0627\u0621';
      case Permission.customersDelete:
        return '\u062d\u0630\u0641 \u0627\u0644\u0639\u0645\u0644\u0627\u0621';
      case Permission.discountsApply:
        return '\u062a\u0637\u0628\u064a\u0642 \u0627\u0644\u062e\u0635\u0648\u0645\u0627\u062a';
      case Permission.discountsCreate:
        return '\u0625\u0646\u0634\u0627\u0621 \u0627\u0644\u062e\u0635\u0648\u0645\u0627\u062a';
      case Permission.refundsRequest:
        return '\u0637\u0644\u0628 \u0627\u0633\u062a\u0631\u062c\u0627\u0639';
      case Permission.refundsApprove:
        return '\u0627\u0644\u0645\u0648\u0627\u0641\u0642\u0629 \u0639\u0644\u0649 \u0627\u0633\u062a\u0631\u062c\u0627\u0639';
      case Permission.reportsView:
        return '\u0639\u0631\u0636 \u0627\u0644\u062a\u0642\u0627\u0631\u064a\u0631';
      case Permission.reportsExport:
        return '\u062a\u0635\u062f\u064a\u0631 \u0627\u0644\u062a\u0642\u0627\u0631\u064a\u0631';
      case Permission.settingsView:
        return '\u0639\u0631\u0636 \u0627\u0644\u0625\u0639\u062f\u0627\u062f\u0627\u062a';
      case Permission.settingsManage:
        return '\u0625\u062f\u0627\u0631\u0629 \u0627\u0644\u0625\u0639\u062f\u0627\u062f\u0627\u062a';
      case Permission.staffView:
        return '\u0639\u0631\u0636 \u0627\u0644\u0645\u0648\u0638\u0641\u064a\u0646';
      case Permission.staffManage:
        return '\u0625\u062f\u0627\u0631\u0629 \u0627\u0644\u0645\u0648\u0638\u0641\u064a\u0646';
    }
  }

  String get description {
    switch (this) {
      case Permission.posAccess:
        return '\u0627\u0644\u0648\u0635\u0648\u0644 \u0625\u0644\u0649 \u0634\u0627\u0634\u0629 \u0646\u0642\u0637\u0629 \u0627\u0644\u0628\u064a\u0639';
      case Permission.posHold:
        return '\u062a\u0639\u0644\u064a\u0642 \u0627\u0644\u0641\u0648\u0627\u062a\u064a\u0631 \u0648\u0627\u0633\u062a\u0643\u0645\u0627\u0644\u0647\u0627 \u0644\u0627\u062d\u0642\u0627\u064b';
      case Permission.posSplitPayment:
        return '\u062a\u0642\u0633\u064a\u0645 \u0627\u0644\u062f\u0641\u0639 \u0628\u064a\u0646 \u0637\u0631\u0642 \u0645\u062e\u062a\u0644\u0641\u0629';
      case Permission.productsView:
        return '\u0639\u0631\u0636 \u0642\u0627\u0626\u0645\u0629 \u0627\u0644\u0645\u0646\u062a\u062c\u0627\u062a \u0648\u062a\u0641\u0627\u0635\u064a\u0644\u0647\u0627';
      case Permission.productsManage:
        return '\u0625\u0636\u0627\u0641\u0629 \u0648\u062a\u0639\u062f\u064a\u0644 \u0627\u0644\u0645\u0646\u062a\u062c\u0627\u062a';
      case Permission.productsDelete:
        return '\u062d\u0630\u0641 \u0627\u0644\u0645\u0646\u062a\u062c\u0627\u062a \u0645\u0646 \u0627\u0644\u0646\u0638\u0627\u0645';
      case Permission.inventoryView:
        return '\u0639\u0631\u0636 \u0643\u0645\u064a\u0627\u062a \u0627\u0644\u0645\u062e\u0632\u0648\u0646';
      case Permission.inventoryManage:
        return '\u0625\u062f\u0627\u0631\u0629 \u0627\u0644\u0645\u062e\u0632\u0648\u0646 \u0648\u0627\u0644\u0646\u0642\u0644';
      case Permission.inventoryAdjust:
        return '\u062a\u0639\u062f\u064a\u0644 \u0643\u0645\u064a\u0627\u062a \u0627\u0644\u0645\u062e\u0632\u0648\u0646 \u064a\u062f\u0648\u064a\u0627\u064b';
      case Permission.customersView:
        return '\u0639\u0631\u0636 \u0628\u064a\u0627\u0646\u0627\u062a \u0627\u0644\u0639\u0645\u0644\u0627\u0621';
      case Permission.customersManage:
        return '\u0625\u0636\u0627\u0641\u0629 \u0648\u062a\u0639\u062f\u064a\u0644 \u0627\u0644\u0639\u0645\u0644\u0627\u0621';
      case Permission.customersDelete:
        return '\u062d\u0630\u0641 \u0627\u0644\u0639\u0645\u0644\u0627\u0621 \u0645\u0646 \u0627\u0644\u0646\u0638\u0627\u0645';
      case Permission.discountsApply:
        return '\u062a\u0637\u0628\u064a\u0642 \u062e\u0635\u0648\u0645\u0627\u062a \u0645\u0648\u062c\u0648\u062f\u0629';
      case Permission.discountsCreate:
        return '\u0625\u0646\u0634\u0627\u0621 \u062e\u0635\u0648\u0645\u0627\u062a \u062c\u062f\u064a\u062f\u0629';
      case Permission.refundsRequest:
        return '\u0637\u0644\u0628 \u0627\u0633\u062a\u0631\u062c\u0627\u0639 \u0644\u0644\u0645\u0646\u062a\u062c\u0627\u062a';
      case Permission.refundsApprove:
        return '\u0627\u0644\u0645\u0648\u0627\u0641\u0642\u0629 \u0639\u0644\u0649 \u0637\u0644\u0628\u0627\u062a \u0627\u0644\u0627\u0633\u062a\u0631\u062c\u0627\u0639';
      case Permission.reportsView:
        return '\u0639\u0631\u0636 \u0627\u0644\u062a\u0642\u0627\u0631\u064a\u0631 \u0648\u0627\u0644\u0625\u062d\u0635\u0627\u0626\u064a\u0627\u062a';
      case Permission.reportsExport:
        return '\u062a\u0635\u062f\u064a\u0631 \u0627\u0644\u062a\u0642\u0627\u0631\u064a\u0631 \u0628\u0635\u064a\u063a \u0645\u062e\u062a\u0644\u0641\u0629';
      case Permission.settingsView:
        return '\u0639\u0631\u0636 \u0625\u0639\u062f\u0627\u062f\u0627\u062a \u0627\u0644\u0646\u0638\u0627\u0645';
      case Permission.settingsManage:
        return '\u062a\u0639\u062f\u064a\u0644 \u0625\u0639\u062f\u0627\u062f\u0627\u062a \u0627\u0644\u0646\u0638\u0627\u0645';
      case Permission.staffView:
        return '\u0639\u0631\u0636 \u0642\u0627\u0626\u0645\u0629 \u0627\u0644\u0645\u0648\u0638\u0641\u064a\u0646';
      case Permission.staffManage:
        return '\u0625\u0636\u0627\u0641\u0629 \u0648\u062a\u0639\u062f\u064a\u0644 \u0627\u0644\u0645\u0648\u0638\u0641\u064a\u0646';
    }
  }

  IconData get icon {
    switch (this) {
      case Permission.posAccess:
        return Icons.point_of_sale;
      case Permission.posHold:
        return Icons.pause_circle;
      case Permission.posSplitPayment:
        return Icons.call_split;
      case Permission.productsView:
        return Icons.visibility;
      case Permission.productsManage:
        return Icons.edit;
      case Permission.productsDelete:
        return Icons.delete;
      case Permission.inventoryView:
        return Icons.visibility;
      case Permission.inventoryManage:
        return Icons.inventory;
      case Permission.inventoryAdjust:
        return Icons.tune;
      case Permission.customersView:
        return Icons.visibility;
      case Permission.customersManage:
        return Icons.edit;
      case Permission.customersDelete:
        return Icons.delete;
      case Permission.discountsApply:
        return Icons.local_offer;
      case Permission.discountsCreate:
        return Icons.add_circle;
      case Permission.refundsRequest:
        return Icons.assignment_return;
      case Permission.refundsApprove:
        return Icons.check_circle;
      case Permission.reportsView:
        return Icons.analytics;
      case Permission.reportsExport:
        return Icons.download;
      case Permission.settingsView:
        return Icons.visibility;
      case Permission.settingsManage:
        return Icons.settings;
      case Permission.staffView:
        return Icons.visibility;
      case Permission.staffManage:
        return Icons.manage_accounts;
    }
  }

  PermissionCategory get category {
    switch (this) {
      case Permission.posAccess:
      case Permission.posHold:
      case Permission.posSplitPayment:
        return PermissionCategory.pos;
      case Permission.productsView:
      case Permission.productsManage:
      case Permission.productsDelete:
        return PermissionCategory.products;
      case Permission.inventoryView:
      case Permission.inventoryManage:
      case Permission.inventoryAdjust:
        return PermissionCategory.inventory;
      case Permission.customersView:
      case Permission.customersManage:
      case Permission.customersDelete:
        return PermissionCategory.customers;
      case Permission.discountsApply:
      case Permission.discountsCreate:
      case Permission.refundsRequest:
      case Permission.refundsApprove:
        return PermissionCategory.sales;
      case Permission.reportsView:
      case Permission.reportsExport:
        return PermissionCategory.reports;
      case Permission.settingsView:
      case Permission.settingsManage:
        return PermissionCategory.settings;
      case Permission.staffView:
      case Permission.staffManage:
        return PermissionCategory.staff;
    }
  }
}
