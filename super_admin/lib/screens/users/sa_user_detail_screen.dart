import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../providers/sa_providers.dart';
import '../../core/services/undo_service.dart';

/// User detail / role management -- real Supabase data.
class SAUserDetailScreen extends ConsumerStatefulWidget {
  final String userId;
  const SAUserDetailScreen({super.key, required this.userId});

  @override
  ConsumerState<SAUserDetailScreen> createState() =>
      _SAUserDetailScreenState();
}

class _SAUserDetailScreenState extends ConsumerState<SAUserDetailScreen> {
  String? _selectedRole;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= AlhaiBreakpoints.desktop;
    final userAsync = ref.watch(saUserDetailProvider(widget.userId));
    final ds = ref.watch(saUsersDatasourceProvider);

    final onlineColor = isDark
        ? const Color(0xFF4ADE80)
        : const Color(0xFF16A34A);
    final offlineColor = colorScheme.outline;

    return Scaffold(
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (user) {
          final name = user.name ?? 'Unknown';
          final email = user.email ?? '-';
          final role = user.role ?? 'viewer';
          final createdAt = user.createdAt ?? '';
          final dateStr =
              createdAt.length >= 10 ? createdAt.substring(0, 10) : createdAt;
          final isOnline = user.isOnline;
          final lastActive = user.lastActiveFormatted;

          // Initialize selected role from data (safe: only sets once)
          if (_selectedRole == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _selectedRole == null) {
                setState(() => _selectedRole = role);
              }
            });
          }

          final statusColor = isOnline ? onlineColor : offlineColor;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AlhaiSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => context.go('/users'),
                    ),
                    const SizedBox(width: AlhaiSpacing.xs),
                    Text(
                      '${l10n.userDetail} - $name',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AlhaiSpacing.lg),

                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isWide ? 800 : double.infinity,
                    ),
                    child: Column(
                      children: [
                        // User profile card
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AlhaiRadius.card),
                            side: BorderSide(
                              color: colorScheme.outlineVariant,
                              width: AlhaiSpacing.strokeXs,
                            ),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.all(AlhaiSpacing.xl),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor:
                                      colorScheme.primaryContainer,
                                  child: Text(
                                    name.isNotEmpty ? name[0] : '?',
                                    style: theme.textTheme.headlineMedium
                                        ?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AlhaiSpacing.md),
                                Text(
                                  name,
                                  style: theme.textTheme.titleLarge
                                      ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  email,
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(
                                    color: colorScheme.outline,
                                  ),
                                ),
                                const SizedBox(height: AlhaiSpacing.sm),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AlhaiSpacing.sm,
                                    vertical: AlhaiSpacing.xxs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(
                                        AlhaiRadius.full),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: statusColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(
                                          width: AlhaiSpacing.xxs),
                                      Text(
                                        isOnline ? l10n.online : l10n.offline,
                                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                          color: statusColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(height: AlhaiSpacing.xl),
                                _InfoRow(
                                  label: l10n.userLastActive,
                                  value: lastActive,
                                ),
                                _InfoRow(
                                  label: l10n.joinDate,
                                  value: dateStr,
                                ),
                                _InfoRow(
                                  label: l10n.userRole,
                                  value: _roleLabel(role),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AlhaiSpacing.md),

                        // Danger zone: deactivate user
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AlhaiRadius.card),
                            side: BorderSide(
                              color: colorScheme.error.withValues(alpha: 0.3),
                              width: AlhaiSpacing.strokeXs,
                            ),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.all(AlhaiSpacing.lg),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                        Icons.warning_rounded,
                                        size: 20,
                                        color: colorScheme.error),
                                    const SizedBox(
                                        width: AlhaiSpacing.xs),
                                    Text(
                                      l10n.dangerZone,
                                      style: theme
                                          .textTheme.titleMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(
                                    height: AlhaiSpacing.xl),
                                Text(
                                  l10n.deactivate,
                                  style:
                                      theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: AlhaiSpacing.xs),
                                Text(
                                  'Deactivating a user will immediately revoke their access. '
                                  'The account can be reactivated later.',
                                  style:
                                      theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.outline,
                                  ),
                                ),
                                const SizedBox(height: AlhaiSpacing.md),
                                OutlinedButton(
                                  onPressed: () async {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: Text(l10n.confirm),
                                        content: const Text(
                                          'Are you sure you want to deactivate this user? Their access will be revoked immediately.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx, false),
                                            child: Text(l10n.cancel),
                                          ),
                                          FilledButton(
                                            style: FilledButton.styleFrom(
                                              backgroundColor: colorScheme.error,
                                            ),
                                            onPressed: () => Navigator.pop(ctx, true),
                                            child: Text(l10n.deactivate),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirmed != true || !context.mounted) return;

                                    await UndoService.executeWithUndo(
                                      context: context,
                                      description: 'User $name deactivated',
                                      action: () async {
                                        await ds.softDeleteUser(widget.userId);
                                        ref.invalidate(saUserDetailProvider(widget.userId));
                                        ref.invalidate(saUsersListProvider);
                                      },
                                      undoAction: () async {
                                        await ds.restoreUser(widget.userId);
                                        ref.invalidate(saUserDetailProvider(widget.userId));
                                        ref.invalidate(saUsersListProvider);
                                      },
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: colorScheme.error,
                                    side: BorderSide(
                                        color: colorScheme.error),
                                  ),
                                  child: Text(l10n.deactivate),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AlhaiSpacing.md),

                        // Role management card
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AlhaiRadius.card),
                            side: BorderSide(
                              color: colorScheme.outlineVariant,
                              width: AlhaiSpacing.strokeXs,
                            ),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.all(AlhaiSpacing.lg),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                        Icons
                                            .admin_panel_settings_rounded,
                                        size: 20,
                                        color:
                                            colorScheme.primary),
                                    const SizedBox(
                                        width: AlhaiSpacing.xs),
                                    Text(
                                      l10n.roleManagement,
                                      style: theme
                                          .textTheme.titleMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(
                                    height: AlhaiSpacing.xl),
                                _RoleOption(
                                  title: l10n.superAdminRole,
                                  description:
                                      'Full access to all platform features',
                                  icon: Icons.shield_rounded,
                                  color: isDark ? const Color(0xFFF87171) : Colors.red,
                                  value: 'super_admin',
                                  groupValue: _selectedRole!,
                                  onChanged: (v) => setState(
                                      () => _selectedRole = v!),
                                ),
                                _RoleOption(
                                  title: l10n.supportRole,
                                  description:
                                      'View stores, manage tickets, limited settings',
                                  icon: Icons.support_agent_rounded,
                                  color: isDark ? const Color(0xFF60A5FA) : Colors.blue,
                                  value: 'support',
                                  groupValue: _selectedRole!,
                                  onChanged: (v) => setState(
                                      () => _selectedRole = v!),
                                ),
                                _RoleOption(
                                  title: l10n.viewerRole,
                                  description:
                                      'Read-only access to dashboard and analytics',
                                  icon: Icons.visibility_rounded,
                                  color: colorScheme.outline,
                                  value: 'viewer',
                                  groupValue: _selectedRole!,
                                  onChanged: (v) => setState(
                                      () => _selectedRole = v!),
                                ),
                                const SizedBox(
                                    height: AlhaiSpacing.md),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.end,
                                  children: [
                                    FilledButton(
                                      onPressed: _saving ||
                                              _selectedRole == role
                                          ? null
                                          : () => _saveRole(
                                              widget.userId,
                                              _selectedRole!),
                                      child: _saving
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child:
                                                  CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Text(l10n.assignRole),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _roleLabel(String role) {
    return switch (role) {
      'super_admin' => 'Super Admin',
      'support' => 'Support',
      'viewer' => 'Viewer',
      _ => role,
    };
  }

  Future<void> _saveRole(String userId, String newRole) async {
    setState(() => _saving = true);
    try {
      final ds = ref.read(saUsersDatasourceProvider);
      await ds.updateUserRole(userId, newRole);
      ref.invalidate(saUserDetailProvider(userId));
      ref.invalidate(saUsersListProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Role updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleOption extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _RoleOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(AlhaiRadius.sm),
        child: Container(
          padding: const EdgeInsets.all(AlhaiSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AlhaiRadius.sm),
            border: Border.all(
              color: isSelected
                  ? color
                  : theme.colorScheme.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
            color: isSelected
                ? color.withValues(alpha: 0.05)
                : null,
          ),
          child: Row(
            children: [
              Radio<String>(
                value: value,
                groupValue: groupValue,
                onChanged: onChanged,
                activeColor: color,
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(AlhaiRadius.xs),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
