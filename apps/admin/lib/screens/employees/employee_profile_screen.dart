import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:get_it/get_it.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:alhai_design_system/alhai_design_system.dart';

/// شاشة ملف الموظف التفصيلي
/// تعرض بيانات الموظف، أداء المبيعات، الورديات، والصلاحيات
class EmployeeProfileScreen extends ConsumerStatefulWidget {
  final String userId;
  const EmployeeProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<EmployeeProfileScreen> createState() =>
      _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends ConsumerState<EmployeeProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _error;
  UsersTableData? _user;

  // Sales performance
  bool _salesLoading = false;
  _SalesStats? _salesStats;
  List<_HourlySale> _hourlySales = [];
  String _salesPeriod = 'month';

  // Shifts
  bool _shiftsLoading = false;
  List<ShiftsTableData> _shifts = [];

  String _selectedRole = 'cashier';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadUser();
    _loadShifts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final db = GetIt.I<AppDatabase>();
      final user = await db.usersDao.getUserById(widget.userId);
      if (mounted) {
        setState(() {
          _user = user;
          _selectedRole = user?.role ?? 'cashier';
          _isLoading = false;
        });
        // Auto-load sales after user is loaded
        _loadSalesPerformance();
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        setState(() {
          _error = l10n.errorOccurred;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadSalesPerformance() async {
    setState(() {
      _salesLoading = true;
    });
    try {
      final db = GetIt.I<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider) ?? '';

      DateTime start;
      final now = DateTime.now();
      switch (_salesPeriod) {
        case 'week':
          start = now.subtract(const Duration(days: 7));
          break;
        case 'all':
          start = DateTime(2020);
          break;
        default:
          start = DateTime(now.year, now.month, 1);
      }

      // Aggregate sales by cashier_id
      final result = await db
          .customSelect(
            '''SELECT
             COUNT(*) as count,
             COALESCE(SUM(total), 0) as total,
             COALESCE(AVG(total), 0) as avg
           FROM sales
           WHERE store_id = ? AND cashier_id = ? AND created_at >= ?''',
            variables: [
              Variable.withString(storeId),
              Variable.withString(widget.userId),
              Variable.withDateTime(start),
            ],
          )
          .getSingle();

      // Hourly distribution
      final hourly = await db
          .customSelect(
            '''SELECT
             strftime('%H', created_at) as hour,
             COALESCE(SUM(total), 0) as total
           FROM sales
           WHERE store_id = ? AND cashier_id = ? AND created_at >= ?
           GROUP BY hour ORDER BY hour''',
            variables: [
              Variable.withString(storeId),
              Variable.withString(widget.userId),
              Variable.withDateTime(start),
            ],
          )
          .get();

      if (mounted) {
        setState(() {
          _salesStats = _SalesStats(
            count: (result.data['count'] as int?) ?? 0,
            total: _toDouble(result.data['total']),
            average: _toDouble(result.data['avg']),
          );
          _hourlySales = hourly
              .map(
                (r) => _HourlySale(
                  hour: int.tryParse(r.data['hour'] as String? ?? '0') ?? 0,
                  total: _toDouble(r.data['total']),
                ),
              )
              .toList();
          _salesLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _salesLoading = false);
    }
  }

  Future<void> _loadShifts() async {
    setState(() => _shiftsLoading = true);
    try {
      final db = GetIt.I<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider) ?? '';
      final shifts = await db
          .customSelect(
            '''SELECT * FROM shifts WHERE store_id = ? AND cashier_id = ?
           ORDER BY opened_at DESC LIMIT 20''',
            variables: [
              Variable.withString(storeId),
              Variable.withString(widget.userId),
            ],
          )
          .get();

      if (mounted) {
        setState(() {
          _shifts = shifts.map((r) {
            return ShiftsTableData(
              id: r.data['id'] as String,
              storeId: r.data['store_id'] as String,
              cashierId: r.data['cashier_id'] as String,
              cashierName: (r.data['cashier_name'] as String?) ?? '',
              openedAt: _parseDate(r.data['opened_at']),
              closedAt: r.data['closed_at'] != null
                  ? _parseDateNullable(r.data['closed_at'])
                  : null,
              status: r.data['status'] as String,
              openingCash: _toDouble(r.data['opening_cash']),
              closingCash: r.data['closing_cash'] != null
                  ? _toDouble(r.data['closing_cash'])
                  : null,
              totalSales: (r.data['total_sales'] as int?) ?? 0,
              totalSalesAmount: _toDouble(r.data['total_sales_amount']),
              totalRefunds: (r.data['total_refunds'] as int?) ?? 0,
              totalRefundsAmount: _toDouble(r.data['total_refunds_amount']),
              syncedAt: null,
            );
          }).toList();
          _shiftsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _shiftsLoading = false);
    }
  }

  double _toDouble(dynamic v) {
    if (v is int) return v.toDouble();
    if (v is double) return v;
    return 0.0;
  }

  DateTime _parseDate(dynamic v) {
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
    return DateTime.now();
  }

  DateTime? _parseDateNullable(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  Future<void> _saveRole() async {
    try {
      final db = GetIt.I<AppDatabase>();
      final u = _user!;
      final updated = UsersTableData(
        id: u.id,
        orgId: u.orgId,
        storeId: u.storeId,
        name: u.name,
        phone: u.phone,
        email: u.email,
        pin: u.pin,
        authUid: u.authUid,
        role: _selectedRole,
        roleId: u.roleId,
        avatar: u.avatar,
        isActive: u.isActive,
        lastLoginAt: u.lastLoginAt,
        createdAt: u.createdAt,
        updatedAt: DateTime.now(),
        syncedAt: u.syncedAt,
      );
      await db.usersDao.updateUser(updated);
      await _loadUser();
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.permissionsSaved),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving role: $e');
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorOccurred),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _toggleActive(bool active) async {
    try {
      final db = GetIt.I<AppDatabase>();
      final u = _user!;
      await db.usersDao.updateUser(
        UsersTableData(
          id: u.id,
          orgId: u.orgId,
          storeId: u.storeId,
          name: u.name,
          phone: u.phone,
          email: u.email,
          pin: u.pin,
          authUid: u.authUid,
          role: u.role,
          roleId: u.roleId,
          avatar: u.avatar,
          isActive: active,
          lastLoginAt: u.lastLoginAt,
          createdAt: u.createdAt,
          updatedAt: DateTime.now(),
          syncedAt: u.syncedAt,
        ),
      );
      await _loadUser();
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              active ? l10n.accountActivated : l10n.accountDeactivated,
            ),
            backgroundColor: active ? AppColors.success : AppColors.warning,
          ),
        );
      }
    } catch (e) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.employeeProfile)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null || _user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.employeeProfile)),
        body: Center(child: Text(_error ?? l10n.employeeNotFound)),
      );
    }

    final user = _user!;
    final displayName = user.name.isNotEmpty
        ? user.name
        : (user.phone ?? l10n.employeeFallback);
    final initials = displayName[0].toUpperCase();
    final roleColor = _roleColor(user.role);

    return Scaffold(
      appBar: AppBar(
        title: Text(displayName),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: const Icon(Icons.person_outline), text: l10n.profileTab),
            Tab(
              icon: const Icon(Icons.bar_chart_outlined),
              text: l10n.salesTab,
            ),
            Tab(
              icon: const Icon(Icons.schedule_outlined),
              text: l10n.shiftsTab,
            ),
            Tab(
              icon: const Icon(Icons.lock_outline),
              text: l10n.permissionsTab2,
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildProfileTab(user, initials, roleColor),
            _buildSalesTab(),
            _buildShiftsTab(),
            _buildPermissionsTab(user),
          ],
        ),
      ),
    );
  }

  Color _roleColor(String role) {
    // Role-specific colors for badges
    switch (role) {
      case 'owner':
        return const Color(0xFF9333EA); // role status color - Purple 600
      case 'manager':
        return AppColors.info;
      case 'supervisor':
        return const Color(0xFF0D9488); // role status color - Teal 600
      default:
        return AppColors.success;
    }
  }

  String _roleLabel(String role) {
    final l10n = AppLocalizations.of(context);
    switch (role) {
      case 'owner':
        return l10n.ownerRole;
      case 'manager':
        return l10n.managerRole;
      case 'supervisor':
        return l10n.supervisorRole;
      default:
        return l10n.cashierRole;
    }
  }

  Widget _buildProfileTab(
    UsersTableData user,
    String initials,
    Color roleColor,
  ) {
    final l10n = AppLocalizations.of(context);
    final displayName = user.name.isNotEmpty
        ? user.name
        : (user.phone ?? l10n.employeeFallback);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      child: Column(
        children: [
          // Avatar header
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AlhaiSpacing.lg),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: roleColor.withValues(alpha: 0.15),
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: roleColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.sm),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.xxs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AlhaiSpacing.sm,
                      vertical: AlhaiSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: roleColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _roleLabel(user.role),
                      style: TextStyle(
                        color: roleColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (user.isActive
                                  ? AppColors.success
                                  : Theme.of(context).disabledColor)
                              .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          user.isActive ? Icons.circle : Icons.circle_outlined,
                          size: 8,
                          color: user.isActive
                              ? AppColors.success
                              : Theme.of(context).disabledColor,
                        ),
                        const SizedBox(width: AlhaiSpacing.xxs),
                        Text(
                          user.isActive ? l10n.active : l10n.inactive,
                          style: TextStyle(
                            fontSize: 12,
                            color: user.isActive
                                ? AppColors.success
                                : Theme.of(context).disabledColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          // Info list
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _infoTile(
                  Icons.phone_outlined,
                  l10n.mobilePhone,
                  user.phone ?? '-',
                ),
                const Divider(height: 1, indent: 52),
                _infoTile(
                  Icons.email_outlined,
                  l10n.emailLabel,
                  user.email ?? '-',
                ),
                const Divider(height: 1, indent: 52),
                _infoTile(
                  Icons.calendar_today_outlined,
                  l10n.joinDate,
                  _formatDate(user.createdAt),
                ),
                const Divider(height: 1, indent: 52),
                _infoTile(
                  Icons.login_outlined,
                  l10n.lastLogin,
                  user.lastLoginAt != null
                      ? _formatDate(user.lastLoginAt!)
                      : l10n.neverLoggedIn,
                ),
                const Divider(height: 1, indent: 52),
                SwitchListTile(
                  secondary: const Icon(Icons.toggle_on_outlined),
                  title: Text(l10n.accountActive),
                  subtitle: Text(
                    user.isActive ? l10n.canLogin : l10n.blockedFromLogin,
                  ),
                  value: user.isActive,
                  onChanged: _toggleActive,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ListTile _infoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, size: 20, color: Theme.of(context).hintColor),
      title: Text(
        label,
        style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildSalesTab() {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        // Period selector
        Padding(
          padding: const EdgeInsets.all(AlhaiSpacing.sm),
          child: SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'week', label: Text(l10n.weekLabel)),
              ButtonSegment(value: 'month', label: Text(l10n.monthLabel)),
              ButtonSegment(value: 'all', label: Text(l10n.all)),
            ],
            selected: {_salesPeriod},
            onSelectionChanged: (s) {
              setState(() => _salesPeriod = s.first);
              _loadSalesPerformance();
            },
          ),
        ),
        Expanded(
          child: _salesLoading
              ? const Center(child: CircularProgressIndicator())
              : _salesStats == null
              ? Center(
                  child: FilledButton.icon(
                    onPressed: _loadSalesPerformance,
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.loadSalesData),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AlhaiSpacing.md),
                  child: Column(
                    children: [
                      GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 1.8,
                            ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          final metrics = [
                            (
                              Icons.attach_money_rounded,
                              AppColors.success,
                              l10n.totalSales,
                              l10n.amountSar(
                                _salesStats!.total.toStringAsFixed(0),
                              ),
                            ),
                            (
                              Icons.receipt_long_outlined,
                              AppColors.info,
                              l10n.invoiceCountLabel2,
                              '${_salesStats!.count}',
                            ),
                            (
                              Icons.trending_up_rounded,
                              const Color(0xFF9333EA),
                              l10n.averageInvoice,
                              l10n.amountSar(
                                _salesStats!.average.toStringAsFixed(0),
                              ),
                            ), // chart metric color - Purple 600
                            (
                              Icons.schedule_outlined,
                              AppColors.warning,
                              l10n.peakHourLabel,
                              _hourlySales.isNotEmpty
                                  ? '${_hourlySales.reduce((a, b) => a.total > b.total ? a : b).hour.toString().padLeft(2, '0')}:00'
                                  : '-',
                            ),
                          ];
                          final m = metrics[index];
                          return _MetricCard(
                            icon: m.$1,
                            color: m.$2,
                            title: m.$3,
                            value: m.$4,
                          );
                        },
                      ),
                      if (_hourlySales.isNotEmpty) ...[
                        const SizedBox(height: AlhaiSpacing.md),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(AlhaiSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.hourlySalesDistribution,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: AlhaiSpacing.sm),
                                _HourlyBarChart(data: _hourlySales),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildShiftsTab() {
    final l10n = AppLocalizations.of(context);
    if (_shiftsLoading) return const Center(child: CircularProgressIndicator());
    if (_shifts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.schedule_outlined,
              size: 64,
              color: Theme.of(context).hintColor,
            ),
            const SizedBox(height: AlhaiSpacing.sm),
            Text(
              l10n.noShifts,
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
            const SizedBox(height: AlhaiSpacing.md),
            FilledButton.icon(
              onPressed: _loadShifts,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.refresh),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      itemCount: _shifts.length,
      separatorBuilder: (_, __) => const SizedBox(height: AlhaiSpacing.xs),
      itemBuilder: (ctx, i) {
        final s = _shifts[i];
        final isClosed = s.status == 'closed';
        Duration? dur;
        if (s.closedAt != null) dur = s.closedAt!.difference(s.openedAt);
        return Card(
          child: ListTile(
            leading: Icon(
              isClosed
                  ? Icons.check_circle_outline
                  : Icons.radio_button_unchecked,
              color: isClosed
                  ? Theme.of(context).disabledColor
                  : AppColors.success,
            ),
            title: Text(
              _formatDate(s.openedAt),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${l10n.shiftOpenTime(_formatTime(s.openedAt))}  ${l10n.shiftCloseTime(s.closedAt != null ? _formatTime(s.closedAt!) : "--:--")}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  dur != null
                      ? l10n.hoursMinutes(dur.inHours, dur.inMinutes % 60)
                      : l10n.shiftOpenStatus,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isClosed
                        ? Theme.of(context).disabledColor
                        : AppColors.success,
                  ),
                ),
                Text(
                  l10n.invoiceCountWithNum(s.totalSales),
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPermissionsTab(UsersTableData user) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AlhaiSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.jobRole,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AlhaiSpacing.sm),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedRole,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
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
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedRole = v);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          Card(
            child: Column(
              children: [
                _permSwitch(l10n.manageProducts, Icons.inventory_2_outlined),
                const Divider(height: 1),
                _permSwitch(l10n.viewReports, Icons.bar_chart_outlined),
                const Divider(height: 1),
                _permSwitch(
                  l10n.refundOperations,
                  Icons.assignment_return_outlined,
                ),
                const Divider(height: 1),
                _permSwitch(
                  l10n.manageCustomersPermission,
                  Icons.people_outline,
                ),
                const Divider(height: 1),
                _permSwitch(l10n.manageOffers, Icons.local_offer_outlined),
              ],
            ),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _saveRole,
              icon: const Icon(Icons.save_outlined),
              label: Text(l10n.savePermissions),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          if (user.role != 'owner')
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(
                        user.isActive
                            ? l10n.deactivateAccount
                            : l10n.activateAccount,
                      ),
                      content: Text(
                        user.isActive
                            ? l10n.confirmDeactivateAccount(user.name)
                            : l10n.confirmActivateAccount(user.name),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(l10n.cancel),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: user.isActive
                                ? AppColors.error
                                : AppColors.success,
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _toggleActive(!user.isActive);
                          },
                          child: Text(
                            user.isActive ? l10n.deactivate : l10n.activate,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                icon: Icon(
                  user.isActive
                      ? Icons.person_off_outlined
                      : Icons.person_outline,
                ),
                label: Text(
                  user.isActive ? l10n.deactivateAccount : l10n.activateAccount,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: user.isActive
                      ? AppColors.error
                      : AppColors.success,
                  side: BorderSide(
                    color: user.isActive ? AppColors.error : AppColors.success,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _permSwitch(String label, IconData icon) {
    return SwitchListTile(
      secondary: Icon(icon, size: 20, color: Theme.of(context).hintColor),
      title: Text(label),
      value: true,
      onChanged: (v) {},
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

// ─── Simple chart widget ────────────────────────────────────────────────────

class _HourlyBarChart extends StatelessWidget {
  final List<_HourlySale> data;
  const _HourlyBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final maxVal = data.map((d) => d.total).reduce((a, b) => a > b ? a : b);
    return SizedBox(
      height: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((h) {
          final ratio = maxVal > 0 ? h.total / maxVal : 0.0;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Tooltip(
                message:
                    '${h.hour.toString().padLeft(2, '0')}:00 - ${l10n.amountSar(h.total.toStringAsFixed(0))}',
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 60 * ratio,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(
                          alpha: 0.6 + ratio * 0.4,
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(height: AlhaiSpacing.xxs),
                    Text(
                      '${h.hour}',
                      style: TextStyle(
                        fontSize: 9,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String value;
  const _MetricCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).hintColor,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Data models ─────────────────────────────────────────────────────────────

class _SalesStats {
  final int count;
  final double total;
  final double average;
  const _SalesStats({
    required this.count,
    required this.total,
    required this.average,
  });
}

class _HourlySale {
  final int hour;
  final double total;
  const _HourlySale({required this.hour, required this.total});
}
