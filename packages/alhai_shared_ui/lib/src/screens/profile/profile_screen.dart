import '../../widgets/common/adaptive_icon.dart';
import 'package:drift/drift.dart' show Variable;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/layout/app_header.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import '../../core/router/routes.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';

/// شاشة الملف الشخصي - بيانات حقيقية
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _salesCount = 0;
  int _daysActive = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);

    try {
      final db = GetIt.I<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);
      final user = ref.read(currentUserProvider);

      if (storeId == null || user == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // Get total sales count for this cashier
      final salesStats = await db.salesDao.getSalesStats(
        storeId,
        cashierId: user.id,
      );

      // Calculate days active from user creation date
      // Use createdAt if available, otherwise approximate
      int daysActive = 0;
      try {
        // Try to get user record from DB for createdAt
        final userRecord = await db.customSelect(
          'SELECT created_at FROM users WHERE id = ? LIMIT 1',
          variables: [Variable.withString(user.id)],
        ).getSingleOrNull();

        if (userRecord != null && userRecord.data['created_at'] != null) {
          final createdAt = DateTime.fromMillisecondsSinceEpoch(
            userRecord.data['created_at'] as int,
          );
          daysActive = DateTime.now().difference(createdAt).inDays;
        } else {
          // Fallback: use sales data to estimate
          final allSales = await db.salesDao.getSalesPaginated(
            storeId,
            cashierId: user.id,
            limit: 1,
          );
          if (allSales.isNotEmpty) {
            daysActive = DateTime.now().difference(allSales.last.createdAt).inDays;
          }
        }
      } catch (_) {
        // If users table query fails, estimate from earliest sale
        try {
          final allSales = await db.salesDao.getSalesPaginated(
            storeId,
            cashierId: user.id,
            limit: 1,
          );
          if (allSales.isNotEmpty) {
            daysActive = DateTime.now().difference(allSales.last.createdAt).inDays;
          }
        } catch (_) {
          // Keep default 0
        }
      }

      if (mounted) {
        setState(() {
          _salesCount = salesStats.count;
          _daysActive = daysActive;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final isWideScreen = context.screenWidth >= 1200;
    final isMediumScreen = !context.isMobile;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final padding = context.isMobile ? 12.0 : isWideScreen ? 24.0 : 16.0;
    final user = ref.watch(currentUserProvider);
    final userName = user?.name ?? l10n.unknownUserName;
    final userEmail = user?.email ?? '';
    final userRole = user?.role?.name ?? l10n.defaultEmployeeRole;

    return Column(
              children: [
                AppHeader(
                  title: l10n.profileScreenTitle,
                  onMenuTap: isWideScreen
                      ? null
                      : () => Scaffold.of(context).openDrawer(),
                  onNotificationsTap: () => context.push('/notifications'),
                  notificationsCount: 3,
                  userName: userName,
                  userRole: l10n.branchManager,
                  actions: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      onPressed: _editProfile,
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(padding),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: isWideScreen ? 800 : double.infinity),
                        child: _buildContent(isWideScreen, isMediumScreen, isDark, l10n, userName, userEmail, userRole, user),
                      ),
                    ),
                  ),
                ),
              ],
            );
  }

  Widget _buildContent(bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n, String userName, String userEmail, String userRole, dynamic user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile header card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [AppColors.primary.withValues(alpha: 0.2), AppColors.primary.withValues(alpha: 0.1)]
                  : [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
              begin: AlignmentDirectional.topEnd,
              end: AlignmentDirectional.bottomStart,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white,
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                userName,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _translateRole(userRole),
                style: TextStyle(color: isDark ? Colors.white70 : Colors.white.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StatBadge(icon: Icons.receipt_long, value: _salesCount.toString(), label: l10n.transactionUnit),
                        const SizedBox(width: 24),
                        _StatBadge(icon: Icons.calendar_today, value: _daysActive.toString(), label: l10n.dayUnit),
                      ],
                    ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Personal info section
        Text(
          l10n.personalInfoSection,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            children: [
              _InfoTile(
                icon: Icons.email,
                label: l10n.emailFieldLabel,
                value: userEmail.isNotEmpty ? userEmail : l10n.notSpecified,
                isDark: isDark,
              ),
              Divider(height: 1, color: Theme.of(context).dividerColor),
              _InfoTile(
                icon: Icons.phone,
                label: l10n.phoneFieldLabel,
                value: user?.phone ?? l10n.notSpecified,
                isDark: isDark,
              ),
              Divider(height: 1, color: Theme.of(context).dividerColor),
              _InfoTile(
                icon: Icons.store,
                label: l10n.branchFieldLabel,
                value: l10n.mainBranchName,
                isDark: isDark,
              ),
              Divider(height: 1, color: Theme.of(context).dividerColor),
              _InfoTile(
                icon: Icons.badge,
                label: l10n.employeeNumberLabel,
                value: user?.id.substring(0, 8) ?? l10n.notSpecified,
                isDark: isDark,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Security section
        Text(
          l10n.securitySection,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.lock, color: Theme.of(context).colorScheme.onSurfaceVariant),
                title: Text(
                  l10n.changePasswordLabel,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
                trailing: AdaptiveIcon(Icons.chevron_left, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                onTap: _changePassword,
              ),
              Divider(height: 1, color: Theme.of(context).dividerColor),
              ListTile(
                leading: Icon(Icons.history, color: Theme.of(context).colorScheme.onSurfaceVariant),
                title: Text(
                  l10n.activityLogLabel,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
                trailing: AdaptiveIcon(Icons.chevron_left, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                onTap: () => context.push('/settings/activity-log'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Logout button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: AppColors.error),
            label: Text(l10n.logoutButton, style: const TextStyle(color: AppColors.error)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
  String _translateRole(String role) {
    final l10n = AppLocalizations.of(context)!;
    switch (role) {
      case 'admin': return l10n.roleAdmin;
      case 'manager': return l10n.roleManager;
      case 'cashier': return l10n.roleCashier;
      default: return l10n.roleEmployee;
    }
  }

  void _editProfile() => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.editProfileSnack)),
      );

  void _changePassword() => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.changePasswordSnack)),
      );

  Future<void> _logout() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.logoutDialogTitle),
        content: Text(l10n.logoutDialogBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(l10n.cancelButton)),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.exitButton),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(authStateProvider.notifier).logout();
      if (mounted) context.go(AppRoutes.login);
    }
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatBadge({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      );
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  const _InfoTile({required this.icon, required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon, color: AppColors.info),
        title: Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        subtitle: Text(value, style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
      );
}
