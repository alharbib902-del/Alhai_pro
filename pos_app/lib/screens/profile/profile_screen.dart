import 'package:pos_app/widgets/common/adaptive_icon.dart';
import 'package:drift/drift.dart' show Variable;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/layout/app_header.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/router/routes.dart';
import '../../providers/auth_providers.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../providers/products_providers.dart';

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
      final db = getIt<AppDatabase>();
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
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);
    final userName = user?.name ?? 'غير معروف'; // TODO: localize
    final userEmail = user?.email ?? '';
    final userRole = (user?.role ?? 'موظف').toString(); // TODO: localize

    return Column(
              children: [
                AppHeader(
                  title: 'الملف الشخصي', // TODO: localize
                  onMenuTap: isWideScreen
                      ? null
                      : () => Scaffold.of(context).openDrawer(),
                  onNotificationsTap: () => context.push('/notifications'),
                  notificationsCount: 3,
                  userName: userName,
                  userRole: l10n.branchManager,
                  actions: [
                    IconButton(
                      icon: Icon(Icons.edit, color: isDark ? Colors.white70 : AppColors.textSecondary),
                      onPressed: _editProfile,
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                    child: _buildContent(isWideScreen, isMediumScreen, isDark, l10n, userName, userEmail, userRole, user),
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
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _translateRole(userRole),
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StatBadge(icon: Icons.receipt_long, value: _salesCount.toString(), label: 'عملية'), // TODO: localize
                        const SizedBox(width: 24),
                        _StatBadge(icon: Icons.calendar_today, value: _daysActive.toString(), label: 'يوم'), // TODO: localize
                      ],
                    ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Personal info section
        Text(
          'المعلومات الشخصية', // TODO: localize
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
          ),
          child: Column(
            children: [
              _InfoTile(
                icon: Icons.email,
                label: 'البريد الإلكتروني', // TODO: localize
                value: userEmail.isNotEmpty ? userEmail : 'غير محدد', // TODO: localize
                isDark: isDark,
              ),
              Divider(height: 1, color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
              _InfoTile(
                icon: Icons.phone,
                label: 'الهاتف', // TODO: localize
                value: user?.phone ?? 'غير محدد', // TODO: localize
                isDark: isDark,
              ),
              Divider(height: 1, color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
              _InfoTile(
                icon: Icons.store,
                label: 'الفرع', // TODO: localize
                value: 'الفرع الرئيسي', // TODO: localize
                isDark: isDark,
              ),
              Divider(height: 1, color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
              _InfoTile(
                icon: Icons.badge,
                label: 'الرقم الوظيفي', // TODO: localize
                value: user?.id.substring(0, 8) ?? 'غير محدد', // TODO: localize
                isDark: isDark,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Security section
        Text(
          'الأمان', // TODO: localize
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
          ),
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.lock, color: isDark ? Colors.white54 : AppColors.textSecondary),
                title: Text(
                  'تغيير كلمة المرور', // TODO: localize
                  style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
                ),
                trailing: AdaptiveIcon(Icons.chevron_left, color: isDark ? Colors.white38 : AppColors.textTertiary),
                onTap: _changePassword,
              ),
              Divider(height: 1, color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
              ListTile(
                leading: Icon(Icons.history, color: isDark ? Colors.white54 : AppColors.textSecondary),
                title: Text(
                  'سجل النشاط', // TODO: localize
                  style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
                ),
                trailing: AdaptiveIcon(Icons.chevron_left, color: isDark ? Colors.white38 : AppColors.textTertiary),
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
            label: const Text('تسجيل الخروج', style: TextStyle(color: AppColors.error)), // TODO: localize
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
    switch (role) {
      case 'admin': return 'مدير النظام'; // TODO: localize
      case 'manager': return 'مدير'; // TODO: localize
      case 'cashier': return 'كاشير'; // TODO: localize
      default: return 'موظف'; // TODO: localize
    }
  }

  void _editProfile() => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعديل الملف الشخصي')), // TODO: localize
      );

  void _changePassword() => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تغيير كلمة المرور')), // TODO: localize
      );

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تسجيل الخروج'), // TODO: localize
        content: const Text('هل تريد تسجيل الخروج من النظام؟'), // TODO: localize
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('إلغاء')), // TODO: localize
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('خروج'), // TODO: localize
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
        leading: Icon(icon, color: isDark ? AppColors.info : AppColors.info),
        title: Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : AppColors.textSecondary)),
        subtitle: Text(value, style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : AppColors.textPrimary)),
      );
}
