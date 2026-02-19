import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/router/routes.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/layout/app_sidebar.dart';
import '../../widgets/layout/app_header.dart';

/// شاشة إدارة المستخدمين
class UsersManagementScreen extends ConsumerStatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  ConsumerState<UsersManagementScreen> createState() =>
      _UsersManagementScreenState();
}

class _UsersManagementScreenState
    extends ConsumerState<UsersManagementScreen> {
  bool _sidebarCollapsed = false;
  String _selectedNavId = 'settings';

  final List<_User> _users = [
    _User(id: '1', name: '\u0623\u062d\u0645\u062f \u0645\u062d\u0645\u062f', role: 'owner', phone: '0501234567', active: true),
    _User(id: '2', name: '\u0645\u062d\u0645\u062f \u0639\u0644\u064a', role: 'manager', phone: '0551234567', active: true),
    _User(id: '3', name: '\u062e\u0627\u0644\u062f \u0633\u0639\u062f', role: 'cashier', phone: '0561234567', active: true),
    _User(id: '4', name: '\u0641\u0647\u062f \u0639\u0645\u0631', role: 'cashier', phone: '0571234567', active: false),
  ];

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
    final isMediumScreen = size.width > 600;
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
                  title: l10n.usersManagement,
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
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                    child: _buildContent(
                        isWideScreen, isMediumScreen, isDark, l10n),
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

  Widget _buildContent(
      bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add user button
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FilledButton.icon(
              onPressed: _addUser,
              icon: const Icon(Icons.person_add_rounded, size: 18),
              label: Text(l10n.addUser),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Users list
        _buildSettingsGroup(
          '${l10n.users} (${_users.length})',
          _users.map((user) => _buildUserTile(user, isDark)).toList(),
          isDark,
        ),
      ],
    );
  }

  Widget _buildSettingsGroup(
      String title, List<Widget> children, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildUserTile(_User user, bool isDark) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundColor: _getRoleColor(user.role).withValues(alpha: 0.1),
            child: Text(
              user.name[0],
              style: TextStyle(
                color: _getRoleColor(user.role),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (!user.active)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Text(
            user.name,
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          if (!user.active)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '\u0645\u0639\u0637\u0644',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
            ),
        ],
      ),
      subtitle: Text(
        '${_getRoleName(user.role)} \u2022 ${user.phone}',
        style: TextStyle(
          color: isDark
              ? Colors.white.withValues(alpha: 0.5)
              : AppColors.textSecondary,
          fontSize: 12,
        ),
      ),
      trailing: PopupMenuButton<String>(
        icon: Icon(Icons.more_vert_rounded,
            color: isDark
                ? Colors.white.withValues(alpha: 0.5)
                : AppColors.textSecondary),
        onSelected: (action) => _handleUserAction(user, action),
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'edit', child: Text('\u062a\u0639\u062f\u064a\u0644')),
          PopupMenuItem(
            value: user.active ? 'disable' : 'enable',
            child: Text(user.active ? '\u062a\u0639\u0637\u064a\u0644' : '\u062a\u0641\u0639\u064a\u0644'),
          ),
          if (user.role != 'owner')
            const PopupMenuItem(
              value: 'delete',
              child: Text('\u062d\u0630\u0641',
                  style: TextStyle(color: AppColors.error)),
            ),
        ],
      ),
      onTap: () => _showUserDetails(user),
    );
  }

  // === Business logic methods (preserved from original) ===

  Color _getRoleColor(String role) {
    switch (role) {
      case 'owner':
        return Colors.purple;
      case 'manager':
        return Colors.blue;
      case 'supervisor':
        return Colors.orange;
      case 'cashier':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getRoleName(String role) {
    switch (role) {
      case 'owner':
        return '\u0645\u0627\u0644\u0643';
      case 'manager':
        return '\u0645\u062f\u064a\u0631';
      case 'supervisor':
        return '\u0645\u0634\u0631\u0641';
      case 'cashier':
        return '\u0643\u0627\u0634\u064a\u0631';
      default:
        return role;
    }
  }

  void _handleUserAction(_User user, String action) {
    switch (action) {
      case 'edit':
        _editUser(user);
        break;
      case 'enable':
      case 'disable':
        setState(() {
          final index = _users.indexOf(user);
          _users[index] = _User(
            id: user.id,
            name: user.name,
            role: user.role,
            phone: user.phone,
            active: !user.active,
          );
        });
        break;
      case 'delete':
        setState(() => _users.remove(user));
        break;
    }
  }

  void _addUser() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    String role = 'cashier';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('\u0625\u0636\u0627\u0641\u0629 \u0645\u0633\u062a\u062e\u062f\u0645'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '\u0627\u0644\u0627\u0633\u0645 *',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: '\u0631\u0642\u0645 \u0627\u0644\u0647\u0627\u062a\u0641',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: role,
                decoration: const InputDecoration(
                  labelText: '\u0627\u0644\u0635\u0644\u0627\u062d\u064a\u0629',
                  prefixIcon: Icon(Icons.security),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'manager', child: Text('\u0645\u062f\u064a\u0631')),
                  DropdownMenuItem(value: 'supervisor', child: Text('\u0645\u0634\u0631\u0641')),
                  DropdownMenuItem(value: 'cashier', child: Text('\u0643\u0627\u0634\u064a\u0631')),
                ],
                onChanged: (v) => setDialogState(() => role = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('\u0625\u0644\u063a\u0627\u0621'),
            ),
            FilledButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  setState(() {
                    _users.add(_User(
                      id: 'new_${_users.length}',
                      name: nameController.text,
                      role: role,
                      phone: phoneController.text,
                      active: true,
                    ));
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('\u0625\u0636\u0627\u0641\u0629'),
            ),
          ],
        ),
      ),
    );
  }

  void _editUser(_User user) {
    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.phone);
    String role = user.role;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('\u062a\u0639\u062f\u064a\u0644 \u0627\u0644\u0645\u0633\u062a\u062e\u062f\u0645'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '\u0627\u0644\u0627\u0633\u0645 *',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: '\u0631\u0642\u0645 \u0627\u0644\u0647\u0627\u062a\u0641',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              if (user.role != 'owner')
                DropdownButtonFormField<String>(
                  value: role,
                  decoration: const InputDecoration(
                    labelText: '\u0627\u0644\u0635\u0644\u0627\u062d\u064a\u0629',
                    prefixIcon: Icon(Icons.security),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'manager', child: Text('\u0645\u062f\u064a\u0631')),
                    DropdownMenuItem(value: 'supervisor', child: Text('\u0645\u0634\u0631\u0641')),
                    DropdownMenuItem(value: 'cashier', child: Text('\u0643\u0627\u0634\u064a\u0631')),
                  ],
                  onChanged: (v) => setDialogState(() => role = v!),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('\u0625\u0644\u063a\u0627\u0621'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  final index = _users.indexOf(user);
                  _users[index] = _User(
                    id: user.id,
                    name: nameController.text,
                    role: user.role == 'owner' ? 'owner' : role,
                    phone: phoneController.text,
                    active: user.active,
                  );
                });
                Navigator.pop(context);
              },
              child: const Text('\u062d\u0641\u0638'),
            ),
          ],
        ),
      ),
    );
  }

  void _showUserDetails(_User user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: _getRoleColor(user.role).withValues(alpha: 0.1),
              child: Text(
                user.name[0],
                style: TextStyle(
                    fontSize: 32, color: _getRoleColor(user.role)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getRoleColor(user.role).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _getRoleName(user.role),
                style: TextStyle(color: _getRoleColor(user.role)),
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.phone),
              title: Text('\u0631\u0642\u0645 \u0627\u0644\u0647\u0627\u062a\u0641',
                  style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimary)),
              subtitle: Text(user.phone),
            ),
            ListTile(
              leading: Icon(
                  user.active ? Icons.check_circle : Icons.cancel,
                  color: user.active ? AppColors.success : AppColors.error),
              title: Text('\u0627\u0644\u062d\u0627\u0644\u0629',
                  style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimary)),
              subtitle:
                  Text(user.active ? '\u0646\u0634\u0637' : '\u0645\u0639\u0637\u0644'),
            ),
          ],
        ),
      ),
    );
  }
}

class _User {
  final String id;
  final String name;
  final String role;
  final String phone;
  final bool active;

  _User({
    required this.id,
    required this.name,
    required this.role,
    required this.phone,
    required this.active,
  });
}
