import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/products_providers.dart';
import '../../providers/sync_providers.dart';
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

  List<_User> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final storeId = ref.read(currentStoreIdProvider);
    if (storeId == null) {
      setState(() => _isLoading = false);
      return;
    }
    final db = getIt<AppDatabase>();
    final usersData = await db.usersDao.getAllUsers(storeId);
    if (mounted) {
      setState(() {
        _users = usersData.map((u) => _User(
          id: u.id,
          name: u.name,
          role: u.role,
          phone: u.phone ?? '',
          active: u.isActive,
        )).toList();
        _isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Column(
              children: [
                AppHeader(
                  title: l10n.usersManagement,
                  onMenuTap: isWideScreen
                      ? null
                      : () => Scaffold.of(context).openDrawer(),
                  onNotificationsTap: () => context.push('/notifications'),
                  notificationsCount: 3,
                  userName: l10n.defaultUserName,
                  userRole: l10n.branchManager,
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                          child: _buildContent(
                              isWideScreen, isMediumScreen, isDark, l10n),
                        ),
                ),
              ],
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
    final l10n = AppLocalizations.of(context)!;
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
                l10n.disabledStatus,
                style: const TextStyle(
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
        itemBuilder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return [
            PopupMenuItem(value: 'edit', child: Text(l10n.editMenuAction)),
            PopupMenuItem(
              value: user.active ? 'disable' : 'enable',
              child: Text(user.active ? l10n.disableMenuAction : l10n.enableMenuAction),
            ),
            if (user.role != 'owner')
              PopupMenuItem(
                value: 'delete',
                child: Text(l10n.delete,
                    style: const TextStyle(color: AppColors.error)),
              ),
          ];
        },
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
    final l10n = AppLocalizations.of(context)!;
    switch (role) {
      case 'owner':
        return l10n.ownerRole;
      case 'manager':
        return l10n.managerRole;
      case 'supervisor':
        return l10n.supervisorRole;
      case 'cashier':
        return l10n.cashierRole;
      default:
        return role;
    }
  }

  Future<void> _handleUserAction(_User user, String action) async {
    switch (action) {
      case 'edit':
        _editUser(user);
        break;
      case 'enable':
      case 'disable':
        // تحديث حالة المستخدم في قاعدة البيانات
        try {
          final db = getIt<AppDatabase>();
          final dbUser = await db.usersDao.getUserById(user.id);
          if (dbUser != null) {
            final updatedUser = UsersTableData(
              id: dbUser.id,
              orgId: dbUser.orgId,
              storeId: dbUser.storeId,
              name: dbUser.name,
              phone: dbUser.phone,
              email: dbUser.email,
              pin: dbUser.pin,
              authUid: dbUser.authUid,
              role: dbUser.role,
              roleId: dbUser.roleId,
              avatar: dbUser.avatar,
              isActive: !user.active,
              lastLoginAt: dbUser.lastLoginAt,
              createdAt: dbUser.createdAt,
              updatedAt: DateTime.now(),
              syncedAt: dbUser.syncedAt,
            );
            await db.usersDao.updateUser(updatedUser);

            // إضافة للطابور المزامنة
            final syncService = ref.read(syncServiceProvider);
            await syncService.enqueueUpdate(
              tableName: 'users',
              recordId: user.id,
              changes: {
                'id': user.id,
                'is_active': !user.active,
                'updated_at': DateTime.now().toIso8601String(),
              },
            );
          }
        } catch (e) {
          debugPrint('خطأ في تحديث حالة المستخدم: $e');
        }
        // إعادة تحميل المستخدمين من قاعدة البيانات
        await _loadUsers();
        break;
      case 'delete':
        // حذف المستخدم من قاعدة البيانات
        try {
          final db = getIt<AppDatabase>();
          await db.usersDao.deleteUser(user.id);

          // إضافة للطابور المزامنة
          final syncService = ref.read(syncServiceProvider);
          await syncService.enqueueDelete(
            tableName: 'users',
            recordId: user.id,
          );
        } catch (e) {
          debugPrint('خطأ في حذف المستخدم: $e');
        }
        // إعادة تحميل المستخدمين من قاعدة البيانات
        await _loadUsers();
        break;
    }
  }

  void _addUser() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    String role = 'cashier';

    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text(l10n.addUserTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: l10n.nameRequired,
                    prefixIcon: const Icon(Icons.person),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: l10n.phoneNumber,
                    prefixIcon: const Icon(Icons.phone),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: role,
                  decoration: InputDecoration(
                    labelText: l10n.roleLabel,
                    prefixIcon: const Icon(Icons.security),
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: 'manager', child: Text(l10n.managerRole)),
                    DropdownMenuItem(value: 'supervisor', child: Text(l10n.supervisorRole)),
                    DropdownMenuItem(value: 'cashier', child: Text(l10n.cashierRole)),
                  ],
                  onChanged: (v) => setDialogState(() => role = v!),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty) {
                    final storeId = ref.read(currentStoreIdProvider);
                    if (storeId != null) {
                      try {
                        final db = getIt<AppDatabase>();
                        final id = const Uuid().v4();
                        final now = DateTime.now();
                        // إدراج المستخدم في قاعدة البيانات
                        await db.usersDao.insertUser(UsersTableCompanion(
                          id: Value(id),
                          storeId: Value(storeId),
                          name: Value(nameController.text),
                          role: Value(role),
                          phone: Value(phoneController.text),
                          isActive: const Value(true),
                          createdAt: Value(now),
                        ));

                        // إضافة للطابور المزامنة
                        final syncService = ref.read(syncServiceProvider);
                        await syncService.enqueueCreate(
                          tableName: 'users',
                          recordId: id,
                          data: {
                            'id': id,
                            'store_id': storeId,
                            'name': nameController.text,
                            'role': role,
                            'phone': phoneController.text,
                            'is_active': true,
                            'created_at': now.toIso8601String(),
                          },
                        );
                      } catch (e) {
                        debugPrint('خطأ في إضافة المستخدم: $e');
                      }
                    }
                    // إعادة تحميل المستخدمين من قاعدة البيانات
                    _loadUsers();
                  }
                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(l10n.addAction),
              ),
            ],
          ),
        );
      },
    );
  }

  void _editUser(_User user) {
    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.phone);
    String role = user.role;

    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text(l10n.editUserTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: l10n.nameRequired,
                    prefixIcon: const Icon(Icons.person),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: l10n.phoneNumber,
                    prefixIcon: const Icon(Icons.phone),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                if (user.role != 'owner')
                  DropdownButtonFormField<String>(
                    // ignore: deprecated_member_use
                    value: role,
                    decoration: InputDecoration(
                      labelText: l10n.roleLabel,
                      prefixIcon: const Icon(Icons.security),
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(value: 'manager', child: Text(l10n.managerRole)),
                      DropdownMenuItem(value: 'supervisor', child: Text(l10n.supervisorRole)),
                      DropdownMenuItem(value: 'cashier', child: Text(l10n.cashierRole)),
                    ],
                    onChanged: (v) => setDialogState(() => role = v!),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () async {
                  final finalRole = user.role == 'owner' ? 'owner' : role;
                  // تحديث المستخدم في قاعدة البيانات
                  try {
                    final db = getIt<AppDatabase>();
                    final dbUser = await db.usersDao.getUserById(user.id);
                    if (dbUser != null) {
                      final updatedUser = UsersTableData(
                        id: dbUser.id,
                        orgId: dbUser.orgId,
                        storeId: dbUser.storeId,
                        name: nameController.text,
                        phone: phoneController.text,
                        email: dbUser.email,
                        pin: dbUser.pin,
                        authUid: dbUser.authUid,
                        role: finalRole,
                        roleId: dbUser.roleId,
                        avatar: dbUser.avatar,
                        isActive: dbUser.isActive,
                        lastLoginAt: dbUser.lastLoginAt,
                        createdAt: dbUser.createdAt,
                        updatedAt: DateTime.now(),
                        syncedAt: dbUser.syncedAt,
                      );
                      await db.usersDao.updateUser(updatedUser);

                      // إضافة للطابور المزامنة
                      final syncService = ref.read(syncServiceProvider);
                      await syncService.enqueueUpdate(
                        tableName: 'users',
                        recordId: user.id,
                        changes: {
                          'id': user.id,
                          'name': nameController.text,
                          'phone': phoneController.text,
                          'role': finalRole,
                          'updated_at': DateTime.now().toIso8601String(),
                        },
                      );
                    }
                  } catch (e) {
                    debugPrint('خطأ في تحديث المستخدم: $e');
                  }
                  // إعادة تحميل المستخدمين من قاعدة البيانات
                  _loadUsers();
                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(l10n.save),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUserDetails(_User user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
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
              title: Text(l10n.phoneNumber,
                  style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimary)),
              subtitle: Text(user.phone),
            ),
            ListTile(
              leading: Icon(
                  user.active ? Icons.check_circle : Icons.cancel,
                  color: user.active ? AppColors.success : AppColors.error),
              title: Text(l10n.status,
                  style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimary)),
              subtitle:
                  Text(user.active ? l10n.activeStatus : l10n.disabledStatus),
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
