/// شاشة الأدوار والصلاحيات - Roles & Permissions Screen
///
/// شاشة لإدارة أدوار المستخدمين وصلاحياتهم
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/router/routes.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/layout/app_sidebar.dart';
import '../../widgets/layout/app_header.dart';

/// شاشة الأدوار والصلاحيات
class RolesPermissionsScreen extends ConsumerStatefulWidget {
  const RolesPermissionsScreen({super.key});

  @override
  ConsumerState<RolesPermissionsScreen> createState() =>
      _RolesPermissionsScreenState();
}

class _RolesPermissionsScreenState
    extends ConsumerState<RolesPermissionsScreen>
    with SingleTickerProviderStateMixin {
  bool _sidebarCollapsed = false;
  String _selectedNavId = 'settings';
  late TabController _tabController;

  // بيانات تجريبية للأدوار
  final List<Role> _roles = [
    Role(
      id: '1',
      name: '\u0645\u062f\u064a\u0631 \u0627\u0644\u0646\u0638\u0627\u0645',
      description: '\u0635\u0644\u0627\u062d\u064a\u0627\u062a \u0643\u0627\u0645\u0644\u0629 \u0644\u0644\u0646\u0638\u0627\u0645',
      color: Colors.purple,
      icon: Icons.admin_panel_settings,
      usersCount: 1,
      isSystemRole: true,
      permissions: Permission.values.map((p) => p.name).toList(),
    ),
    Role(
      id: '2',
      name: '\u0645\u062f\u064a\u0631 \u0627\u0644\u0645\u062a\u062c\u0631',
      description: '\u0625\u062f\u0627\u0631\u0629 \u0627\u0644\u0645\u062a\u062c\u0631 \u0648\u0627\u0644\u0645\u0648\u0638\u0641\u064a\u0646',
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
      description: '\u0639\u0645\u0644\u064a\u0627\u062a \u0627\u0644\u0628\u064a\u0639 \u0648\u0627\u0644\u062f\u0641\u0639',
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
      description: '\u0625\u062f\u0627\u0631\u0629 \u0627\u0644\u0645\u062e\u0632\u0648\u0646 \u0648\u0627\u0644\u0645\u0646\u062a\u062c\u0627\u062a',
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
      description: '\u0627\u0644\u062a\u0642\u0627\u0631\u064a\u0631 \u0627\u0644\u0645\u0627\u0644\u064a\u0629 \u0648\u0627\u0644\u062d\u0633\u0627\u0628\u0627\u062a',
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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleNavigation(AppSidebarItem item) {
    setState(() => _selectedNavId = item.id);
    switch (item.id) {
      case 'dashboard':
        context.go(AppRoutes.dashboard);
        break;
      case 'pos':
        context.go(AppRoutes.pos);
        break;
      case 'products':
        context.push(AppRoutes.products);
        break;
      case 'categories':
        context.push(AppRoutes.categories);
        break;
      case 'inventory':
        context.push(AppRoutes.inventory);
        break;
      case 'customers':
        context.push(AppRoutes.customers);
        break;
      case 'invoices':
        context.push(AppRoutes.invoices);
        break;
      case 'orders':
        context.push(AppRoutes.orders);
        break;
      case 'sales':
        context.push(AppRoutes.invoices);
        break;
      case 'returns':
        context.push(AppRoutes.returns);
        break;
      case 'reports':
        context.push(AppRoutes.reports);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : AppColors.backgroundSecondary,
      drawer: isWideScreen ? null : _buildDrawer(l10n),
      body: Row(
        children: [
          if (isWideScreen)
            AppSidebar(
              storeName: l10n.brandName,
              groups: DefaultSidebarItems.getGroups(context),
              selectedId: _selectedNavId,
              onItemTap: _handleNavigation,
              onSettingsTap: () => context.push(AppRoutes.settings),
              onSupportTap: () {},
              onLogoutTap: () => context.go('/login'),
              collapsed: _sidebarCollapsed,
              userName: '\u0623\u062d\u0645\u062f \u0645\u062d\u0645\u062f',
              userRole: l10n.branchManager,
              onUserTap: () {},
            ),
          Expanded(
            child: Column(
              children: [
                AppHeader(
                  title: l10n.rolesPermissions,
                  onMenuTap: isWideScreen
                      ? () => setState(
                          () => _sidebarCollapsed = !_sidebarCollapsed)
                      : () => Scaffold.of(context).openDrawer(),
                  onNotificationsTap: () => context.push('/notifications'),
                  notificationsCount: 3,
                  userName:
                      '\u0623\u062d\u0645\u062f \u0645\u062d\u0645\u062f',
                  userRole: l10n.branchManager,
                ),
                // Tab bar
                Container(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : AppColors.textSecondary,
                    indicatorColor: AppColors.primary,
                    tabs: const [
                      Tab(icon: Icon(Icons.groups), text: '\u0627\u0644\u0623\u062f\u0648\u0627\u0631'),
                      Tab(icon: Icon(Icons.security), text: '\u0627\u0644\u0635\u0644\u0627\u062d\u064a\u0627\u062a'),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(AppLocalizations l10n) {
    return Drawer(
      child: AppSidebar(
        storeName: l10n.brandName,
        groups: DefaultSidebarItems.getGroups(context),
        selectedId: _selectedNavId,
        onItemTap: (item) {
          Navigator.pop(context);
          _handleNavigation(item);
        },
        onSettingsTap: () {
          Navigator.pop(context);
          context.push(AppRoutes.settings);
        },
        onSupportTap: () => Navigator.pop(context),
        onLogoutTap: () {
          Navigator.pop(context);
          context.go('/login');
        },
        userName: '\u0623\u062d\u0645\u062f \u0645\u062d\u0645\u062f',
        userRole: l10n.branchManager,
        onUserTap: () {},
      ),
    );
  }

  Widget _buildRolesTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Add role button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FilledButton.icon(
                onPressed: _showAddRoleDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('\u062f\u0648\u0631 \u062c\u062f\u064a\u062f'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._roles.map((role) => _buildRoleCard(role, isDark)),
        ],
      ),
    );
  }

  Widget _buildRoleCard(Role role, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border,
        ),
      ),
      child: InkWell(
        onTap: () => _showRoleDetails(role),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
              const SizedBox(width: 16),
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
                            color:
                                isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        if (role.isSystemRole) ...[
                          const SizedBox(width: 8),
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
                              '\u0646\u0638\u0627\u0645',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.5)
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      role.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.5)
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.person, size: 14,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.4)
                                : AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          '${role.usersCount} \u0645\u0633\u062a\u062e\u062f\u0645',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.4)
                                : AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.key, size: 14,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.4)
                                : AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          '${role.permissions.length} \u0635\u0644\u0627\u062d\u064a\u0629',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.4)
                                : AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : AppColors.textSecondary),
                onSelected: (value) => _handleRoleAction(value, role),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('\u062a\u0639\u062f\u064a\u0644')),
                  const PopupMenuItem(value: 'duplicate', child: Text('\u0646\u0633\u062e')),
                  const PopupMenuItem(value: 'users', child: Text('\u0627\u0644\u0645\u0633\u062a\u062e\u062f\u0645\u064a\u0646')),
                  if (!role.isSystemRole)
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('\u062d\u0630\u0641',
                          style: TextStyle(color: AppColors.error)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionsTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: PermissionCategory.values.map((category) {
          return _buildPermissionCategory(category, isDark);
        }).toList(),
      ),
    );
  }

  Widget _buildPermissionCategory(PermissionCategory category, bool isDark) {
    final permissions =
        Permission.values.where((p) => p.category == category).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border,
        ),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
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
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          '${permissions.length} \u0635\u0644\u0627\u062d\u064a\u0629',
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? Colors.white.withValues(alpha: 0.5)
                : AppColors.textSecondary,
          ),
        ),
        children: permissions.map((permission) {
          return ListTile(
            leading: Icon(permission.icon,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.5)
                    : AppColors.textSecondary,
                size: 20),
            title: Text(
              permission.label,
              style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary),
            ),
            subtitle: Text(
              permission.description,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.5)
                    : AppColors.textSecondary,
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
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
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: role.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(role.icon, color: role.color, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(role.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            )),
                        Text(role.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.5)
                                  : AppColors.textSecondary,
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
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.people, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${role.usersCount}',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary)),
                              Text('\u0627\u0644\u0645\u0633\u062a\u062e\u062f\u0645\u064a\u0646',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.primary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.key, color: AppColors.success),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${role.permissions.length}',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.success)),
                              Text('\u0627\u0644\u0635\u0644\u0627\u062d\u064a\u0627\u062a',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.success)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: role.permissions.length,
                itemBuilder: (context, index) {
                  final permissionName = role.permissions[index];
                  final permission = Permission.values.firstWhere(
                    (p) => p.name == permissionName,
                    orElse: () => Permission.posAccess,
                  );
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.check,
                          color: AppColors.success, size: 16),
                    ),
                    title: Text(permission.label,
                        style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimary)),
                    subtitle: Text(permission.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.5)
                              : AppColors.textSecondary,
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
    showDialog(
      context: context,
      builder: (context) => _RoleFormDialog(
        onSave: (name, description) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('\u062a\u0645 \u0625\u0636\u0627\u0641\u0629 \u0627\u0644\u062f\u0648\u0631: $name'),
              backgroundColor: AppColors.success,
            ),
          );
        },
      ),
    );
  }

  void _showEditRoleDialog(Role role) {
    showDialog(
      context: context,
      builder: (context) => _RoleFormDialog(
        role: role,
        onSave: (name, description) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('\u062a\u0645 \u062a\u062d\u062f\u064a\u062b \u0627\u0644\u062f\u0648\u0631: $name'),
              backgroundColor: AppColors.success,
            ),
          );
        },
      ),
    );
  }

  void _handleRoleAction(String action, Role role) {
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
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('\u062a\u0645 \u0646\u0633\u062e \u0627\u0644\u062f\u0648\u0631: ${role.name}'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showRoleUsers(Role role) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '\u0645\u0633\u062a\u062e\u062f\u0645\u0648 \u062f\u0648\u0631 "${role.name}"',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
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
                  '\u0645\u0633\u062a\u062e\u062f\u0645 ${index + 1}',
                  style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimary),
                ),
                subtitle: Text('user${index + 1}@example.com'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteRole(Role role) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('\u062d\u0630\u0641 \u0627\u0644\u062f\u0648\u0631'),
        content: Text('\u0647\u0644 \u0623\u0646\u062a \u0645\u062a\u0623\u0643\u062f \u0645\u0646 \u062d\u0630\u0641 \u0627\u0644\u062f\u0648\u0631 "${role.name}"\u061f'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('\u0625\u0644\u063a\u0627\u0621'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              HapticFeedback.mediumImpact();
              ScaffoldMessenger.of(this.context).showSnackBar(
                SnackBar(
                  content: Text('\u062a\u0645 \u062d\u0630\u0641 \u0627\u0644\u062f\u0648\u0631: ${role.name}'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('\u062d\u0630\u0641'),
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
    return Dialog(
      child: Container(
        width: 500,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Text(
                    widget.role == null ? '\u062f\u0648\u0631 \u062c\u062f\u064a\u062f' : '\u062a\u0639\u062f\u064a\u0644 \u0627\u0644\u062f\u0648\u0631',
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
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: '\u0627\u0633\u0645 \u0627\u0644\u062f\u0648\u0631',
                        hintText: '\u0645\u062b\u0627\u0644: \u0645\u062f\u064a\u0631 \u0627\u0644\u0645\u0628\u064a\u0639\u0627\u062a',
                        prefixIcon: Icon(Icons.badge),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: '\u0627\u0644\u0648\u0635\u0641',
                        hintText: '\u0648\u0635\u0641 \u0645\u062e\u062a\u0635\u0631 \u0644\u0644\u062f\u0648\u0631...',
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '\u0627\u0644\u0635\u0644\u0627\u062d\u064a\u0627\u062a',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ...PermissionCategory.values.map((category) {
                      final permissions = Permission.values
                          .where((p) => p.category == category)
                          .toList();
                      return ExpansionTile(
                        leading:
                            Icon(category.icon, color: category.color),
                        title: Text(category.label),
                        children: permissions.map((permission) {
                          return CheckboxListTile(
                            value: _selectedPermissions
                                .contains(permission.name),
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _selectedPermissions
                                      .add(permission.name);
                                } else {
                                  _selectedPermissions
                                      .remove(permission.name);
                                }
                              });
                            },
                            title: Text(permission.label),
                            subtitle: Text(permission.description,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary)),
                            controlAffinity:
                                ListTileControlAffinity.leading,
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
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('\u0625\u0644\u063a\u0627\u0621'),
                  ),
                  const SizedBox(width: 12),
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
                    child: const Text('\u062d\u0641\u0638'),
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
  pos, products, inventory, customers, sales, reports, settings, staff;

  String get label {
    switch (this) {
      case PermissionCategory.pos: return '\u0646\u0642\u0637\u0629 \u0627\u0644\u0628\u064a\u0639';
      case PermissionCategory.products: return '\u0627\u0644\u0645\u0646\u062a\u062c\u0627\u062a';
      case PermissionCategory.inventory: return '\u0627\u0644\u0645\u062e\u0632\u0648\u0646';
      case PermissionCategory.customers: return '\u0627\u0644\u0639\u0645\u0644\u0627\u0621';
      case PermissionCategory.sales: return '\u0627\u0644\u0645\u0628\u064a\u0639\u0627\u062a';
      case PermissionCategory.reports: return '\u0627\u0644\u062a\u0642\u0627\u0631\u064a\u0631';
      case PermissionCategory.settings: return '\u0627\u0644\u0625\u0639\u062f\u0627\u062f\u0627\u062a';
      case PermissionCategory.staff: return '\u0627\u0644\u0645\u0648\u0638\u0641\u064a\u0646';
    }
  }

  IconData get icon {
    switch (this) {
      case PermissionCategory.pos: return Icons.point_of_sale;
      case PermissionCategory.products: return Icons.inventory_2;
      case PermissionCategory.inventory: return Icons.warehouse;
      case PermissionCategory.customers: return Icons.people;
      case PermissionCategory.sales: return Icons.shopping_cart;
      case PermissionCategory.reports: return Icons.analytics;
      case PermissionCategory.settings: return Icons.settings;
      case PermissionCategory.staff: return Icons.badge;
    }
  }

  Color get color {
    switch (this) {
      case PermissionCategory.pos: return AppColors.primary;
      case PermissionCategory.products: return AppColors.success;
      case PermissionCategory.inventory: return AppColors.warning;
      case PermissionCategory.customers: return AppColors.info;
      case PermissionCategory.sales: return Colors.purple;
      case PermissionCategory.reports: return Colors.teal;
      case PermissionCategory.settings: return AppColors.grey600;
      case PermissionCategory.staff: return Colors.indigo;
    }
  }
}

/// الصلاحيات
enum Permission {
  posAccess, posHold, posSplitPayment,
  productsView, productsManage, productsDelete,
  inventoryView, inventoryManage, inventoryAdjust,
  customersView, customersManage, customersDelete,
  discountsApply, discountsCreate, refundsRequest, refundsApprove,
  reportsView, reportsExport,
  settingsView, settingsManage,
  staffView, staffManage;

  String get name {
    switch (this) {
      case Permission.posAccess: return 'pos_access';
      case Permission.posHold: return 'pos_hold';
      case Permission.posSplitPayment: return 'pos_split_payment';
      case Permission.productsView: return 'products_view';
      case Permission.productsManage: return 'products_manage';
      case Permission.productsDelete: return 'products_delete';
      case Permission.inventoryView: return 'inventory_view';
      case Permission.inventoryManage: return 'inventory_manage';
      case Permission.inventoryAdjust: return 'inventory_adjust';
      case Permission.customersView: return 'customers_view';
      case Permission.customersManage: return 'customers_manage';
      case Permission.customersDelete: return 'customers_delete';
      case Permission.discountsApply: return 'discounts_apply';
      case Permission.discountsCreate: return 'discounts_create';
      case Permission.refundsRequest: return 'refunds_request';
      case Permission.refundsApprove: return 'refunds_approve';
      case Permission.reportsView: return 'reports_view';
      case Permission.reportsExport: return 'reports_export';
      case Permission.settingsView: return 'settings_view';
      case Permission.settingsManage: return 'settings_manage';
      case Permission.staffView: return 'staff_view';
      case Permission.staffManage: return 'staff_manage';
    }
  }

  String get label {
    switch (this) {
      case Permission.posAccess: return '\u0627\u0644\u0648\u0635\u0648\u0644 \u0644\u0646\u0642\u0637\u0629 \u0627\u0644\u0628\u064a\u0639';
      case Permission.posHold: return '\u062a\u0639\u0644\u064a\u0642 \u0627\u0644\u0641\u0648\u0627\u062a\u064a\u0631';
      case Permission.posSplitPayment: return '\u062a\u0642\u0633\u064a\u0645 \u0627\u0644\u062f\u0641\u0639';
      case Permission.productsView: return '\u0639\u0631\u0636 \u0627\u0644\u0645\u0646\u062a\u062c\u0627\u062a';
      case Permission.productsManage: return '\u0625\u062f\u0627\u0631\u0629 \u0627\u0644\u0645\u0646\u062a\u062c\u0627\u062a';
      case Permission.productsDelete: return '\u062d\u0630\u0641 \u0627\u0644\u0645\u0646\u062a\u062c\u0627\u062a';
      case Permission.inventoryView: return '\u0639\u0631\u0636 \u0627\u0644\u0645\u062e\u0632\u0648\u0646';
      case Permission.inventoryManage: return '\u0625\u062f\u0627\u0631\u0629 \u0627\u0644\u0645\u062e\u0632\u0648\u0646';
      case Permission.inventoryAdjust: return '\u062a\u0639\u062f\u064a\u0644 \u0627\u0644\u0645\u062e\u0632\u0648\u0646';
      case Permission.customersView: return '\u0639\u0631\u0636 \u0627\u0644\u0639\u0645\u0644\u0627\u0621';
      case Permission.customersManage: return '\u0625\u062f\u0627\u0631\u0629 \u0627\u0644\u0639\u0645\u0644\u0627\u0621';
      case Permission.customersDelete: return '\u062d\u0630\u0641 \u0627\u0644\u0639\u0645\u0644\u0627\u0621';
      case Permission.discountsApply: return '\u062a\u0637\u0628\u064a\u0642 \u0627\u0644\u062e\u0635\u0648\u0645\u0627\u062a';
      case Permission.discountsCreate: return '\u0625\u0646\u0634\u0627\u0621 \u0627\u0644\u062e\u0635\u0648\u0645\u0627\u062a';
      case Permission.refundsRequest: return '\u0637\u0644\u0628 \u0627\u0633\u062a\u0631\u062c\u0627\u0639';
      case Permission.refundsApprove: return '\u0627\u0644\u0645\u0648\u0627\u0641\u0642\u0629 \u0639\u0644\u0649 \u0627\u0633\u062a\u0631\u062c\u0627\u0639';
      case Permission.reportsView: return '\u0639\u0631\u0636 \u0627\u0644\u062a\u0642\u0627\u0631\u064a\u0631';
      case Permission.reportsExport: return '\u062a\u0635\u062f\u064a\u0631 \u0627\u0644\u062a\u0642\u0627\u0631\u064a\u0631';
      case Permission.settingsView: return '\u0639\u0631\u0636 \u0627\u0644\u0625\u0639\u062f\u0627\u062f\u0627\u062a';
      case Permission.settingsManage: return '\u0625\u062f\u0627\u0631\u0629 \u0627\u0644\u0625\u0639\u062f\u0627\u062f\u0627\u062a';
      case Permission.staffView: return '\u0639\u0631\u0636 \u0627\u0644\u0645\u0648\u0638\u0641\u064a\u0646';
      case Permission.staffManage: return '\u0625\u062f\u0627\u0631\u0629 \u0627\u0644\u0645\u0648\u0638\u0641\u064a\u0646';
    }
  }

  String get description {
    switch (this) {
      case Permission.posAccess: return '\u0627\u0644\u0648\u0635\u0648\u0644 \u0625\u0644\u0649 \u0634\u0627\u0634\u0629 \u0646\u0642\u0637\u0629 \u0627\u0644\u0628\u064a\u0639';
      case Permission.posHold: return '\u062a\u0639\u0644\u064a\u0642 \u0627\u0644\u0641\u0648\u0627\u062a\u064a\u0631 \u0648\u0627\u0633\u062a\u0643\u0645\u0627\u0644\u0647\u0627 \u0644\u0627\u062d\u0642\u0627\u064b';
      case Permission.posSplitPayment: return '\u062a\u0642\u0633\u064a\u0645 \u0627\u0644\u062f\u0641\u0639 \u0628\u064a\u0646 \u0637\u0631\u0642 \u0645\u062e\u062a\u0644\u0641\u0629';
      case Permission.productsView: return '\u0639\u0631\u0636 \u0642\u0627\u0626\u0645\u0629 \u0627\u0644\u0645\u0646\u062a\u062c\u0627\u062a \u0648\u062a\u0641\u0627\u0635\u064a\u0644\u0647\u0627';
      case Permission.productsManage: return '\u0625\u0636\u0627\u0641\u0629 \u0648\u062a\u0639\u062f\u064a\u0644 \u0627\u0644\u0645\u0646\u062a\u062c\u0627\u062a';
      case Permission.productsDelete: return '\u062d\u0630\u0641 \u0627\u0644\u0645\u0646\u062a\u062c\u0627\u062a \u0645\u0646 \u0627\u0644\u0646\u0638\u0627\u0645';
      case Permission.inventoryView: return '\u0639\u0631\u0636 \u0643\u0645\u064a\u0627\u062a \u0627\u0644\u0645\u062e\u0632\u0648\u0646';
      case Permission.inventoryManage: return '\u0625\u062f\u0627\u0631\u0629 \u0627\u0644\u0645\u062e\u0632\u0648\u0646 \u0648\u0627\u0644\u0646\u0642\u0644';
      case Permission.inventoryAdjust: return '\u062a\u0639\u062f\u064a\u0644 \u0643\u0645\u064a\u0627\u062a \u0627\u0644\u0645\u062e\u0632\u0648\u0646 \u064a\u062f\u0648\u064a\u0627\u064b';
      case Permission.customersView: return '\u0639\u0631\u0636 \u0628\u064a\u0627\u0646\u0627\u062a \u0627\u0644\u0639\u0645\u0644\u0627\u0621';
      case Permission.customersManage: return '\u0625\u0636\u0627\u0641\u0629 \u0648\u062a\u0639\u062f\u064a\u0644 \u0627\u0644\u0639\u0645\u0644\u0627\u0621';
      case Permission.customersDelete: return '\u062d\u0630\u0641 \u0627\u0644\u0639\u0645\u0644\u0627\u0621 \u0645\u0646 \u0627\u0644\u0646\u0638\u0627\u0645';
      case Permission.discountsApply: return '\u062a\u0637\u0628\u064a\u0642 \u062e\u0635\u0648\u0645\u0627\u062a \u0645\u0648\u062c\u0648\u062f\u0629';
      case Permission.discountsCreate: return '\u0625\u0646\u0634\u0627\u0621 \u062e\u0635\u0648\u0645\u0627\u062a \u062c\u062f\u064a\u062f\u0629';
      case Permission.refundsRequest: return '\u0637\u0644\u0628 \u0627\u0633\u062a\u0631\u062c\u0627\u0639 \u0644\u0644\u0645\u0646\u062a\u062c\u0627\u062a';
      case Permission.refundsApprove: return '\u0627\u0644\u0645\u0648\u0627\u0641\u0642\u0629 \u0639\u0644\u0649 \u0637\u0644\u0628\u0627\u062a \u0627\u0644\u0627\u0633\u062a\u0631\u062c\u0627\u0639';
      case Permission.reportsView: return '\u0639\u0631\u0636 \u0627\u0644\u062a\u0642\u0627\u0631\u064a\u0631 \u0648\u0627\u0644\u0625\u062d\u0635\u0627\u0626\u064a\u0627\u062a';
      case Permission.reportsExport: return '\u062a\u0635\u062f\u064a\u0631 \u0627\u0644\u062a\u0642\u0627\u0631\u064a\u0631 \u0628\u0635\u064a\u063a \u0645\u062e\u062a\u0644\u0641\u0629';
      case Permission.settingsView: return '\u0639\u0631\u0636 \u0625\u0639\u062f\u0627\u062f\u0627\u062a \u0627\u0644\u0646\u0638\u0627\u0645';
      case Permission.settingsManage: return '\u062a\u0639\u062f\u064a\u0644 \u0625\u0639\u062f\u0627\u062f\u0627\u062a \u0627\u0644\u0646\u0638\u0627\u0645';
      case Permission.staffView: return '\u0639\u0631\u0636 \u0642\u0627\u0626\u0645\u0629 \u0627\u0644\u0645\u0648\u0638\u0641\u064a\u0646';
      case Permission.staffManage: return '\u0625\u0636\u0627\u0641\u0629 \u0648\u062a\u0639\u062f\u064a\u0644 \u0627\u0644\u0645\u0648\u0638\u0641\u064a\u0646';
    }
  }

  IconData get icon {
    switch (this) {
      case Permission.posAccess: return Icons.point_of_sale;
      case Permission.posHold: return Icons.pause_circle;
      case Permission.posSplitPayment: return Icons.call_split;
      case Permission.productsView: return Icons.visibility;
      case Permission.productsManage: return Icons.edit;
      case Permission.productsDelete: return Icons.delete;
      case Permission.inventoryView: return Icons.visibility;
      case Permission.inventoryManage: return Icons.inventory;
      case Permission.inventoryAdjust: return Icons.tune;
      case Permission.customersView: return Icons.visibility;
      case Permission.customersManage: return Icons.edit;
      case Permission.customersDelete: return Icons.delete;
      case Permission.discountsApply: return Icons.local_offer;
      case Permission.discountsCreate: return Icons.add_circle;
      case Permission.refundsRequest: return Icons.assignment_return;
      case Permission.refundsApprove: return Icons.check_circle;
      case Permission.reportsView: return Icons.analytics;
      case Permission.reportsExport: return Icons.download;
      case Permission.settingsView: return Icons.visibility;
      case Permission.settingsManage: return Icons.settings;
      case Permission.staffView: return Icons.visibility;
      case Permission.staffManage: return Icons.manage_accounts;
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
