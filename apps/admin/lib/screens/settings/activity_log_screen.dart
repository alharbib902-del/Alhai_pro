import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// شاشة سجل النشاطات
class ActivityLogScreen extends ConsumerStatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  ConsumerState<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends ConsumerState<ActivityLogScreen> {
  String _selectedFilter = 'all';

  List<_ActivityItem> _activities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    final storeId = ref.read(currentStoreIdProvider);
    if (storeId == null) {
      setState(() => _isLoading = false);
      return;
    }
    final db = getIt<AppDatabase>();
    final logs = await db.auditLogDao.getLogs(storeId, limit: 100);
    if (mounted) {
      setState(() {
        _activities = logs.map((log) => _ActivityItem(
          user: log.userName,
          action: log.action,
          details: log.description ?? '',
          time: _formatTimeAgo(log.createdAt),
          icon: _getActionIcon(log.action),
          color: _getActionColor(log.action),
          type: _getActionType(log.action),
        )).toList();
        _isLoading = false;
      });
    }
  }

  static IconData _getActionIcon(String action) {
    if (action.contains('login')) return Icons.login_rounded;
    if (action.contains('logout')) return Icons.logout_rounded;
    if (action.contains('sale')) return Icons.receipt_long_rounded;
    if (action.contains('product') || action.contains('price')) return Icons.edit_rounded;
    if (action.contains('refund')) return Icons.assignment_return_rounded;
    if (action.contains('stock')) return Icons.inventory_rounded;
    if (action.contains('shift')) return Icons.schedule_rounded;
    if (action.contains('order')) return Icons.shopping_cart_rounded;
    if (action.contains('customer')) return Icons.person_add_rounded;
    return Icons.history_rounded;
  }

  static Color _getActionColor(String action) {
    if (action.contains('login') || action.contains('backup')) return AppColors.success;
    if (action.contains('logout')) return AppColors.textSecondary;
    if (action.contains('sale') && !action.contains('refund')) return AppColors.primary;
    if (action.contains('edit') || action.contains('price') || action.contains('stock')) return AppColors.warning;
    if (action.contains('refund') || action.contains('cancel') || action.contains('delete')) return AppColors.error;
    return AppColors.info;
  }

  static String _getActionType(String action) {
    if (action.contains('login') || action.contains('logout')) return 'auth';
    if (action.contains('sale') || action.contains('refund')) return 'sales';
    if (action.contains('product') || action.contains('price') || action.contains('stock')) return 'products';
    if (action.contains('shift') || action.contains('cash')) return 'system';
    return 'system';
  }

  static String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return '\u0627\u0644\u0622\u0646';
    if (diff.inMinutes < 60) return '\u0645\u0646\u0630 ${diff.inMinutes} \u062f\u0642\u064a\u0642\u0629';
    if (diff.inHours < 24) return '\u0645\u0646\u0630 ${diff.inHours} \u0633\u0627\u0639\u0629';
    return '\u0645\u0646\u0630 ${diff.inDays} \u064a\u0648\u0645';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        AppHeader(
          title: l10n.activityLog,
          onMenuTap: isWideScreen ? null : () => Scaffold.of(context).openDrawer(),
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
                  child: _buildContent(isWideScreen, isMediumScreen, isDark, l10n),
                ),
        ),
      ],
    );
  }

  Widget _buildContent(bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    final filtered = _selectedFilter == 'all'
        ? _activities
        : _activities.where((a) => a.type == _selectedFilter).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filters
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _buildFilterChip('all', l10n.allFilter, isDark),
            const SizedBox(width: AlhaiSpacing.xs),
            _buildFilterChip('auth', l10n.loginLogoutFilter, isDark),
            const SizedBox(width: AlhaiSpacing.xs),
            _buildFilterChip('sales', l10n.salesFilter, isDark),
            const SizedBox(width: AlhaiSpacing.xs),
            _buildFilterChip('products', l10n.productsFilter, isDark),
            const SizedBox(width: AlhaiSpacing.xs),
            _buildFilterChip('users', l10n.usersFilter, isDark),
            const SizedBox(width: AlhaiSpacing.xs),
            _buildFilterChip('system', l10n.systemFilter, isDark),
          ]),
        ),
        const SizedBox(height: AlhaiSpacing.mdl),
        _buildGroup('${l10n.activityLog} (${filtered.length})',
            filtered.map((a) => _buildActivityTile(a, isDark)).toList(), isDark,
            noItemsText: l10n.noActivities),
      ],
    );
  }

  Widget _buildFilterChip(String filter, String label, bool isDark) {
    final sel = _selectedFilter == filter;
    return FilterChip(
      label: Text(label, style: TextStyle(
        color: sel ? Colors.white : (Theme.of(context).colorScheme.onSurface),
        fontWeight: sel ? FontWeight.bold : FontWeight.normal, fontSize: 12)),
      selected: sel,
      onSelected: (_) => setState(() => _selectedFilter = filter),
      selectedColor: AppColors.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      side: BorderSide(color: sel ? AppColors.primary : (Theme.of(context).dividerColor)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildGroup(String title, List<Widget> children, bool isDark, {String noItemsText = ''}) {
    return Container(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(AlhaiSpacing.mdl, AlhaiSpacing.md, AlhaiSpacing.mdl, AlhaiSpacing.xs),
          child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface)),
        ),
        if (children.isEmpty)
          Padding(padding: const EdgeInsets.all(AlhaiSpacing.xl), child: Center(
            child: Text(noItemsText, style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant))))
        else ...children,
      ]),
    );
  }

  Widget _buildActivityTile(_ActivityItem a, bool isDark) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AlhaiSpacing.xs),
        decoration: BoxDecoration(color: a.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(a.icon, color: a.color, size: 20),
      ),
      title: Row(children: [
        Expanded(child: Text(a.action, style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500))),
        Text(a.time, style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11)),
      ]),
      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(a.details, style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
        Text(a.user, style: TextStyle(
            color: isDark ? Colors.white.withValues(alpha: 0.3) : AppColors.textTertiary, fontSize: 11)),
      ]),
    );
  }
}

class _ActivityItem {
  final String user, action, details, time, type;
  final IconData icon;
  final Color color;
  _ActivityItem({required this.user, required this.action, required this.details,
      required this.time, required this.icon, required this.color, required this.type});
}
