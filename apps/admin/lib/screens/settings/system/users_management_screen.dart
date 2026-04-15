import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_auth/alhai_auth.dart'
    show isAdminProvider, currentUserProvider, PinService;
import 'package:alhai_design_system/alhai_design_system.dart';
import '../../../core/constants/admin_permissions.dart';
import '../../../core/widgets/permission_guard.dart';

/// شاشة إدارة المستخدمين
class UsersManagementScreen extends ConsumerStatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  ConsumerState<UsersManagementScreen> createState() =>
      _UsersManagementScreenState();
}

class _UsersManagementScreenState extends ConsumerState<UsersManagementScreen> {
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
        _users = usersData
            .map(
              (u) => _User(
                id: u.id,
                name: u.name,
                role: u.role,
                phone: u.phone ?? '',
                active: u.isActive,
              ),
            )
            .toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width >= 1200;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final padding = size.width < 600
        ? 12.0
        : isWideScreen
        ? 24.0
        : 16.0;

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
          child: PermissionGuard(
            permission: AdminPermissions.usersManage,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: EdgeInsets.all(padding),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isWideScreen ? 800 : double.infinity,
                      ),
                      child: _buildContent(
                        isWideScreen,
                        size.width >= 600,
                        isDark,
                        l10n,
                      ),
                    ),
                  ),
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(
    bool isWideScreen,
    bool isMediumScreen,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AlhaiSpacing.md),
        _buildSettingsGroup(
          '${l10n.users} (${_users.length})',
          _users.map((user) => _buildUserTile(user, isDark)).toList(),
          isDark,
        ),
      ],
    );
  }

  Widget _buildSettingsGroup(String title, List<Widget> children, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AlhaiSpacing.mdl,
              AlhaiSpacing.md,
              AlhaiSpacing.mdl,
              AlhaiSpacing.xs,
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildUserTile(_User user, bool isDark) {
    final l10n = AppLocalizations.of(context);
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
            PositionedDirectional(
              bottom: 0,
              end: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Theme.of(context).hintColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
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
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: AlhaiSpacing.xs),
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
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 12,
        ),
      ),
      trailing: PopupMenuButton<String>(
        icon: Icon(
          Icons.more_vert_rounded,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onSelected: (action) => _handleUserAction(user, action),
        itemBuilder: (context) {
          final l10n = AppLocalizations.of(context);
          return [
            PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  const Icon(Icons.person_rounded, size: 18),
                  const SizedBox(width: AlhaiSpacing.xs),
                  Text(l10n.jobProfile),
                ],
              ),
            ),
            PopupMenuItem(value: 'edit', child: Text(l10n.editMenuAction)),
            PopupMenuItem(
              value: user.active ? 'disable' : 'enable',
              child: Text(
                user.active ? l10n.disableMenuAction : l10n.enableMenuAction,
              ),
            ),
            if (user.role != 'owner')
              PopupMenuItem(
                value: 'delete',
                child: Text(
                  l10n.delete,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
          ];
        },
      ),
      onTap: () => _showUserDetails(user),
    );
  }

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
        return Theme.of(context).colorScheme.outline;
    }
  }

  String _getRoleName(String role) {
    final l10n = AppLocalizations.of(context);
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

  /// Security: verify the current user has admin privileges before
  /// performing sensitive user-management operations.
  bool _checkAdminPermission() {
    final isAdmin = ref.read(isAdminProvider);
    if (!isAdmin) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorOccurred),
          backgroundColor: AppColors.error,
        ),
      );
      if (kDebugMode)
        debugPrint('Security: non-admin attempted sensitive user operation');
      return false;
    }
    return true;
  }

  /// Requires the admin to re-enter their PIN before a sensitive operation
  /// (e.g. deleting or disabling a user). Returns `true` if the PIN was
  /// verified successfully, `false` otherwise (including dismissal).
  Future<bool> _requirePinConfirmation() async {
    final pinEnabled = await PinService.isEnabled();
    if (!pinEnabled) return true; // PIN not configured — allow

    if (!mounted) return false;
    final l10n = AppLocalizations.of(context);
    String? enteredPin;
    String? error;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.enterCurrentPin),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.security,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: AlhaiSpacing.md),
              TextField(
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'PIN',
                  border: const OutlineInputBorder(),
                  errorText: error,
                ),
                onChanged: (v) => enteredPin = v,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () async {
                if (enteredPin == null || enteredPin!.length < 4) {
                  setDialogState(() => error = l10n.enterCurrentPin);
                  return;
                }
                final result = await PinService.verifyPin(enteredPin!);
                if (result.isSuccess) {
                  if (context.mounted) Navigator.pop(context, true);
                } else {
                  setDialogState(() => error = result.error);
                }
              },
              child: Text(l10n.confirm),
            ),
          ],
        ),
      ),
    );

    return confirmed == true;
  }

  Future<void> _handleUserAction(_User user, String action) async {
    switch (action) {
      case 'profile':
        if (mounted) context.push('/employees/profile/${user.id}');
        break;
      case 'edit':
        _editUser(user);
        break;
      case 'enable':
      case 'disable':
        if (!_checkAdminPermission()) return;
        if (!await _requirePinConfirmation()) return;
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
            // Audit log: user status change
            _logAuditEvent(db, 'user_$action', user.id, user.name);
          }
        } catch (e) {
          if (kDebugMode) debugPrint('Error updating user status: $e');
        }
        await _loadUsers();
        break;
      case 'delete':
        if (!_checkAdminPermission()) return;
        if (!await _requirePinConfirmation()) return;
        try {
          final db = getIt<AppDatabase>();
          await db.usersDao.deleteUser(user.id);
          final syncService = ref.read(syncServiceProvider);
          await syncService.enqueueDelete(
            tableName: 'users',
            recordId: user.id,
          );
          // Audit log: user deletion
          _logAuditEvent(db, 'user_delete', user.id, user.name);
        } catch (e) {
          if (kDebugMode) debugPrint('Error deleting user: $e');
        }
        await _loadUsers();
        break;
    }
  }

  /// Best-effort audit logging for sensitive user operations.
  void _logAuditEvent(
    AppDatabase db,
    String action,
    String entityId,
    String entityName,
  ) {
    try {
      final storeId = ref.read(currentStoreIdProvider) ?? '';
      final currentUser = ref.read(currentUserProvider);
      db.auditLogDao.log(
        storeId: storeId,
        userId: currentUser?.id ?? 'unknown',
        userName: currentUser?.name ?? 'unknown',
        action: AuditAction.settingsChange,
        entityType: 'user',
        entityId: entityId,
        description: '$action: $entityName',
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Audit log failed: $e');
    }
  }

  void _addUser() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    String role = 'cashier';
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
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
                const SizedBox(height: AlhaiSpacing.sm),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: l10n.phoneNumber,
                    prefixIcon: const Icon(Icons.phone),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.sm),
                DropdownButtonFormField<String>(
                  initialValue: role,
                  decoration: InputDecoration(
                    labelText: l10n.roleLabel,
                    prefixIcon: const Icon(Icons.security),
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'manager',
                      child: Text(l10n.managerRole),
                    ),
                    DropdownMenuItem(
                      value: 'supervisor',
                      child: Text(l10n.supervisorRole),
                    ),
                    DropdownMenuItem(
                      value: 'cashier',
                      child: Text(l10n.cashierRole),
                    ),
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
                        await db.usersDao.insertUser(
                          UsersTableCompanion(
                            id: Value(id),
                            storeId: Value(storeId),
                            name: Value(nameController.text),
                            role: Value(role),
                            phone: Value(phoneController.text),
                            isActive: const Value(true),
                            createdAt: Value(now),
                          ),
                        );
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
                        if (kDebugMode) debugPrint('Error adding user: $e');
                      }
                    }
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
        final l10n = AppLocalizations.of(context);
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
                const SizedBox(height: AlhaiSpacing.sm),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: l10n.phoneNumber,
                    prefixIcon: const Icon(Icons.phone),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.sm),
                if (user.role != 'owner')
                  DropdownButtonFormField<String>(
                    initialValue: role,
                    decoration: InputDecoration(
                      labelText: l10n.roleLabel,
                      prefixIcon: const Icon(Icons.security),
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'manager',
                        child: Text(l10n.managerRole),
                      ),
                      DropdownMenuItem(
                        value: 'supervisor',
                        child: Text(l10n.supervisorRole),
                      ),
                      DropdownMenuItem(
                        value: 'cashier',
                        child: Text(l10n.cashierRole),
                      ),
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
                    if (kDebugMode) debugPrint('Error updating user: $e');
                  }
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
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        color: Theme.of(context).colorScheme.surface,
        padding: const EdgeInsets.all(AlhaiSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: _getRoleColor(user.role).withValues(alpha: 0.1),
              child: Text(
                user.name[0],
                style: TextStyle(fontSize: 32, color: _getRoleColor(user.role)),
              ),
            ),
            const SizedBox(height: AlhaiSpacing.md),
            Text(
              user.name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.xxs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AlhaiSpacing.sm,
                vertical: AlhaiSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: _getRoleColor(user.role).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _getRoleName(user.role),
                style: TextStyle(color: _getRoleColor(user.role)),
              ),
            ),
            const SizedBox(height: AlhaiSpacing.lg),
            ListTile(
              leading: const Icon(Icons.phone),
              title: Text(
                l10n.phoneNumber,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              subtitle: Text(user.phone),
            ),
            ListTile(
              leading: Icon(
                user.active ? Icons.check_circle : Icons.cancel,
                color: user.active ? AppColors.success : AppColors.error,
              ),
              title: Text(
                l10n.status,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                user.active ? l10n.activeStatus : l10n.disabledStatus,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _User {
  final String id, name, role, phone;
  final bool active;
  _User({
    required this.id,
    required this.name,
    required this.role,
    required this.phone,
    required this.active,
  });
}
