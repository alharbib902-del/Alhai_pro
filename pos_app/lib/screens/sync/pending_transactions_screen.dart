import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/layout/app_sidebar.dart';
import '../../widgets/layout/app_header.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/router/routes.dart';

/// شاشة العمليات المعلقة للمزامنة
class PendingTransactionsScreen extends ConsumerStatefulWidget {
  const PendingTransactionsScreen({super.key});

  @override
  ConsumerState<PendingTransactionsScreen> createState() => _PendingTransactionsScreenState();
}

class _PendingTransactionsScreenState extends ConsumerState<PendingTransactionsScreen> {
  bool _sidebarCollapsed = false;
  String _selectedNavId = 'dashboard';

  bool _isLoading = true;
  bool _isSyncing = false;
  List<Map<String, dynamic>> _pendingItems = [];

  @override
  void initState() {
    super.initState();
    _loadPendingItems();
  }

  Future<void> _loadPendingItems() async {
    setState(() => _isLoading = true);

    // Mock data للتطوير - TODO: ربط بقاعدة البيانات
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _pendingItems = [
        {'id': 1, 'operation': 'INSERT', 'tableName': 'sales', 'recordId': 'sale-001-abc', 'createdAt': DateTime.now().subtract(const Duration(minutes: 5))},
        {'id': 2, 'operation': 'UPDATE', 'tableName': 'products', 'recordId': 'prod-002-xyz', 'createdAt': DateTime.now().subtract(const Duration(minutes: 15))},
      ];
      _isLoading = false;
    });
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
                  title: 'العمليات المعلقة', // TODO: localize
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
                      onPressed: _loadPendingItems,
                    ),
                  ],
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _pendingItems.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.cloud_done, size: 64, color: isDark ? Colors.white24 : AppColors.success),
                                  const SizedBox(height: 16),
                                  Text(
                                    'جميع العمليات متزامنة', // TODO: localize
                                    style: TextStyle(
                                      color: isDark ? Colors.white54 : AppColors.textSecondary,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'لا توجد عمليات معلقة', // TODO: localize
                                    style: TextStyle(color: isDark ? Colors.white38 : AppColors.textTertiary),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Warning banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.warning.withValues(alpha: 0.1) : AppColors.warningSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.cloud_off, color: AppColors.warning),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_pendingItems.length} عملية معلقة', // TODO: localize
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'سيتم مزامنتها عند الاتصال بالإنترنت', // TODO: localize
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: _isSyncing ? null : _syncAll,
                icon: _isSyncing
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.sync, size: 18),
                label: Text(_isSyncing ? 'مزامنة...' : 'مزامنة الكل'), // TODO: localize
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Pending items list
        ...List.generate(_pendingItems.length, (index) {
          final item = _pendingItems[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: CircleAvatar(
                backgroundColor: _getOperationColor(item['operation']).withValues(alpha: 0.1),
                child: Icon(
                  _getOperationIcon(item['operation']),
                  color: _getOperationColor(item['operation']),
                ),
              ),
              title: Text(
                _translateOperation(item['operation']),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item['tableName']} - ${item['recordId'].toString().substring(0, 8)}',
                    style: TextStyle(color: isDark ? Colors.white54 : AppColors.textSecondary),
                  ),
                  Text(
                    _formatDate(item['createdAt']),
                    style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : AppColors.textTertiary),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.sync, color: AppColors.info),
                    onPressed: () => _syncItem(item),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: AppColors.error),
                    onPressed: () => _deleteItem(item),
                  ),
                ],
              ),
            ),
          );
        }),
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

  Color _getOperationColor(String? operation) {
    switch (operation) {
      case 'INSERT': return AppColors.success;
      case 'UPDATE': return AppColors.info;
      case 'DELETE': return AppColors.error;
      default: return AppColors.textSecondary;
    }
  }

  IconData _getOperationIcon(String? operation) {
    switch (operation) {
      case 'INSERT': return Icons.add;
      case 'UPDATE': return Icons.edit;
      case 'DELETE': return Icons.delete;
      default: return Icons.sync;
    }
  }

  String _translateOperation(String? operation) {
    switch (operation) {
      case 'INSERT': return 'إضافة'; // TODO: localize
      case 'UPDATE': return 'تعديل'; // TODO: localize
      case 'DELETE': return 'حذف'; // TODO: localize
      default: return 'عملية'; // TODO: localize
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _syncAll() async {
    setState(() => _isSyncing = true);
    await Future.delayed(const Duration(seconds: 2));
    await _loadPendingItems();
    setState(() => _isSyncing = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تمت المزامنة بنجاح'), backgroundColor: Colors.green), // TODO: localize
    );
  }

  void _syncItem(Map<String, dynamic> item) {
    setState(() => _pendingItems.remove(item));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تمت مزامنة العملية')), // TODO: localize
    );
  }

  void _deleteItem(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف العملية'), // TODO: localize
        content: const Text('هل تريد حذف هذه العملية من قائمة الانتظار؟'), // TODO: localize
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')), // TODO: localize
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _pendingItems.remove(item));
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف'), // TODO: localize
          ),
        ],
      ),
    );
  }
}
