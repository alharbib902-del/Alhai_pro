import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/layout/app_sidebar.dart';
import '../../widgets/layout/app_header.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/router/routes.dart';

/// شاشة قائمة الطباعة المعلقة
class PrintQueueScreen extends ConsumerStatefulWidget {
  const PrintQueueScreen({super.key});

  @override
  ConsumerState<PrintQueueScreen> createState() => _PrintQueueScreenState();
}

class _PrintQueueScreenState extends ConsumerState<PrintQueueScreen> {
  bool _sidebarCollapsed = false;
  String _selectedNavId = 'pos';

  final List<_PrintJob> _pendingJobs = [
    _PrintJob(id: '1', type: 'receipt', orderId: 'INV-2024-150', status: 'pending', createdAt: DateTime.now().subtract(const Duration(minutes: 5))),
    _PrintJob(id: '2', type: 'receipt', orderId: 'INV-2024-149', status: 'failed', createdAt: DateTime.now().subtract(const Duration(minutes: 15))),
    _PrintJob(id: '3', type: 'report', orderId: 'تقرير يومي', status: 'pending', createdAt: DateTime.now().subtract(const Duration(minutes: 30))),
  ];

  bool _isPrinting = false;

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
                  title: 'قائمة الطباعة', // TODO: localize
                  onMenuTap: isWideScreen
                      ? () => setState(() => _sidebarCollapsed = !_sidebarCollapsed)
                      : () => Scaffold.of(context).openDrawer(),
                  onNotificationsTap: () => context.push('/notifications'),
                  notificationsCount: 3,
                  userName: 'أحمد محمد', // TODO: localize
                  userRole: l10n.branchManager,
                  actions: [
                    IconButton(
                      icon: Icon(Icons.settings, color: isDark ? Colors.white70 : AppColors.textSecondary),
                      tooltip: 'إعدادات الطابعة', // TODO: localize
                      onPressed: () => context.push(AppRoutes.settingsPrinter),
                    ),
                  ],
                ),
                Expanded(
                  child: _pendingJobs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.print_disabled, size: 64, color: isDark ? Colors.white24 : Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                'لا توجد مهام طباعة معلقة', // TODO: localize
                                style: TextStyle(color: isDark ? Colors.white54 : Colors.grey.shade600, fontSize: 16),
                              ),
                            ],
                          ),
                        )
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
    final pendingCount = _pendingJobs.where((j) => j.status == 'pending').length;
    final failedCount = _pendingJobs.where((j) => j.status == 'failed').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Printer status
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.success.withValues(alpha: 0.1) : AppColors.successSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.success.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'الطابعة متصلة', // TODO: localize
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                'XP-80C',
                style: TextStyle(color: isDark ? Colors.white54 : AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Stats row
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.print,
                label: 'إجمالي', // TODO: localize
                value: '${_pendingJobs.length}',
                color: AppColors.info,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.hourglass_empty,
                label: 'في الانتظار', // TODO: localize
                value: '$pendingCount',
                color: AppColors.warning,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.error_outline,
                label: 'فشلت', // TODO: localize
                value: '$failedCount',
                color: AppColors.error,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_pendingJobs.length} مهام معلقة', // TODO: localize
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: _clearAll,
                  child: Text('مسح الكل', style: TextStyle(color: AppColors.error)), // TODO: localize
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _isPrinting ? null : _printAll,
                  icon: _isPrinting
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.print, size: 18),
                  label: Text(_isPrinting ? 'جاري الطباعة...' : 'طباعة الكل'), // TODO: localize
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Jobs list
        ...List.generate(_pendingJobs.length, (index) {
          final job = _pendingJobs[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: job.status == 'failed'
                    ? AppColors.error.withValues(alpha: 0.3)
                    : (isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: CircleAvatar(
                backgroundColor: job.status == 'failed'
                    ? AppColors.error.withValues(alpha: 0.1)
                    : AppColors.info.withValues(alpha: 0.1),
                child: Icon(
                  job.type == 'receipt' ? Icons.receipt : Icons.description,
                  color: job.status == 'failed' ? AppColors.error : AppColors.info,
                ),
              ),
              title: Text(
                job.orderId,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              subtitle: Row(
                children: [
                  Icon(
                    job.status == 'failed' ? Icons.error : Icons.schedule,
                    size: 14,
                    color: job.status == 'failed' ? AppColors.error : AppColors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    job.status == 'failed' ? 'فشل - حاول مرة أخرى' : 'في الانتظار', // TODO: localize
                    style: TextStyle(
                      color: job.status == 'failed' ? AppColors.error : (isDark ? Colors.white54 : AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.print, color: AppColors.info),
                    onPressed: () => _printJob(job),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: AppColors.error),
                    onPressed: () => _removeJob(job),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? color.withValues(alpha: 0.1) : color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 20),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8)),
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
        userName: 'أحمد محمد', // TODO: localize
        userRole: l10n.branchManager,
        onUserTap: () => Navigator.pop(context),
      ),
    );
  }

  void _printJob(_PrintJob job) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('جاري طباعة ${job.orderId}...')), // TODO: localize
    );
    setState(() => _pendingJobs.remove(job));
  }

  void _removeJob(_PrintJob job) {
    setState(() => _pendingJobs.remove(job));
  }

  Future<void> _printAll() async {
    setState(() => _isPrinting = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isPrinting = false;
      _pendingJobs.clear();
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم طباعة جميع المهام'), backgroundColor: Colors.green), // TODO: localize
    );
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسح قائمة الطباعة'), // TODO: localize
        content: const Text('هل تريد مسح جميع مهام الطباعة المعلقة؟'), // TODO: localize
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')), // TODO: localize
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _pendingJobs.clear());
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('مسح'), // TODO: localize
          ),
        ],
      ),
    );
  }
}

class _PrintJob {
  final String id;
  final String type;
  final String orderId;
  final String status;
  final DateTime createdAt;

  _PrintJob({
    required this.id,
    required this.type,
    required this.orderId,
    required this.status,
    required this.createdAt,
  });
}
