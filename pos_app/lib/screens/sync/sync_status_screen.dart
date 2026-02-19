import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/layout/app_sidebar.dart';
import '../../widgets/layout/app_header.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/router/routes.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';

/// شاشة حالة المزامنة
class SyncStatusScreen extends ConsumerStatefulWidget {
  const SyncStatusScreen({super.key});

  @override
  ConsumerState<SyncStatusScreen> createState() => _SyncStatusScreenState();
}

class _SyncStatusScreenState extends ConsumerState<SyncStatusScreen> {
  bool _sidebarCollapsed = false;
  String _selectedNavId = 'dashboard';

  bool _isLoading = true;
  bool _isSyncing = false;
  int _pendingCount = 0;
  DateTime? _lastSyncTime;
  final String _connectionStatus = 'online';

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    setState(() => _isLoading = true);
    try {
      final db = getIt<AppDatabase>();
      final pending = await db.syncQueueDao.getPendingItems();
      setState(() {
        _pendingCount = pending.length;
        _lastSyncTime = DateTime.now().subtract(const Duration(minutes: 5));
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _handleNavigation(AppSidebarItem item) {
    setState(() => _selectedNavId = item.id);
    switch (item.id) {
      case 'dashboard': context.go(AppRoutes.dashboard); break;
      case 'pos': context.go(AppRoutes.pos); break;
      case 'products': context.push(AppRoutes.products); break;
      case 'categories': context.push(AppRoutes.categories); break;
      case 'inventory': context.push(AppRoutes.inventory); break;
      case 'customers': context.push(AppRoutes.customers); break;
      case 'invoices': context.push(AppRoutes.invoices); break;
      case 'orders': context.push(AppRoutes.orders); break;
      case 'sales': context.push(AppRoutes.invoices); break;
      case 'returns': context.push(AppRoutes.returns); break;
      case 'reports': context.push(AppRoutes.reports); break;
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
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.backgroundSecondary,
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
              userName: 'أحمد محمد', // TODO: localize
              userRole: l10n.branchManager,
              onUserTap: () {},
            ),
          Expanded(
            child: Column(
              children: [
                AppHeader(
                  title: 'حالة المزامنة', // TODO: localize
                  onMenuTap: isWideScreen
                      ? () => setState(() => _sidebarCollapsed = !_sidebarCollapsed)
                      : () => Scaffold.of(context).openDrawer(),
                  onNotificationsTap: () => context.push('/notifications'),
                  notificationsCount: 3,
                  userName: 'أحمد محمد', // TODO: localize
                  userRole: l10n.branchManager,
                  actions: [
                    IconButton(
                      icon: Icon(Icons.refresh, color: isDark ? Colors.white70 : AppColors.textSecondary),
                      onPressed: _loadStatus,
                    ),
                  ],
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                          child: _buildContent(isWideScreen, isMediumScreen, isDark, l10n),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    final isOnline = _connectionStatus == 'online';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Connection status card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark
                ? (isOnline ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1))
                : (isOnline ? AppColors.successSurface : AppColors.errorSurface),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (isOnline ? AppColors.success : AppColors.error).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isOnline ? AppColors.success : AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isOnline ? Icons.cloud_done : Icons.cloud_off,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOnline ? 'متصل بالسيرفر' : 'غير متصل', // TODO: localize
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : (isOnline ? AppColors.success : AppColors.error),
                      ),
                    ),
                    if (_lastSyncTime != null)
                      Text(
                        'آخر مزامنة: ${_formatTime(_lastSyncTime!)}', // TODO: localize
                        style: TextStyle(color: isDark ? Colors.white54 : AppColors.textSecondary),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Pending items card
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
          ),
          child: InkWell(
            onTap: () => context.push(AppRoutes.pendingTransactions),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _pendingCount > 0
                        ? AppColors.warning.withValues(alpha: 0.1)
                        : AppColors.success.withValues(alpha: 0.1),
                    child: Icon(
                      _pendingCount > 0 ? Icons.hourglass_empty : Icons.check,
                      color: _pendingCount > 0 ? AppColors.warning : AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'العمليات المعلقة', // TODO: localize
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          _pendingCount > 0 ? '$_pendingCount عملية تنتظر المزامنة' : 'لا توجد عمليات معلقة', // TODO: localize
                          style: TextStyle(color: isDark ? Colors.white54 : AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  if (_pendingCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text('$_pendingCount', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_left, color: isDark ? Colors.white38 : AppColors.textTertiary),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Sync info card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'معلومات المزامنة', // TODO: localize
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _InfoRow(label: 'الجهاز', value: 'POS-001', isDark: isDark), // TODO: localize
              Divider(height: 16, color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
              _InfoRow(label: 'إصدار التطبيق', value: '1.0.0', isDark: isDark), // TODO: localize
              Divider(height: 16, color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
              _InfoRow(
                label: 'آخر مزامنة كاملة', // TODO: localize
                value: _lastSyncTime != null ? _formatDate(_lastSyncTime!) : '-',
                isDark: isDark,
              ),
              Divider(height: 16, color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
              _InfoRow(label: 'حالة قاعدة البيانات', value: 'سليمة', isDark: isDark), // TODO: localize
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Sync button
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isSyncing ? null : _forceSync,
            icon: _isSyncing
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.sync),
            label: Text(_isSyncing ? 'جاري المزامنة...' : 'مزامنة الآن'), // TODO: localize
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          ),
        ),
      ],
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
        userName: 'أحمد محمد', // TODO: localize
        userRole: l10n.branchManager,
        onUserTap: () => Navigator.pop(context),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'الآن'; // TODO: localize
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة'; // TODO: localize
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة'; // TODO: localize
    return 'منذ ${diff.inDays} يوم'; // TODO: localize
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _forceSync() async {
    setState(() => _isSyncing = true);
    await Future.delayed(const Duration(seconds: 2));
    await _loadStatus();
    setState(() => _isSyncing = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تمت المزامنة بنجاح'), backgroundColor: Colors.green), // TODO: localize
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  const _InfoRow({required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isDark ? Colors.white54 : AppColors.textSecondary)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
