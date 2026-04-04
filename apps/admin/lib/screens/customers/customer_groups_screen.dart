import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:get_it/get_it.dart';
import 'package:drift/drift.dart' hide Column;

/// شاشة مجموعات العملاء وتقسيمهم
class CustomerGroupsScreen extends ConsumerStatefulWidget {
  const CustomerGroupsScreen({super.key});

  @override
  ConsumerState<CustomerGroupsScreen> createState() => _CustomerGroupsScreenState();
}

class _CustomerGroupsScreenState extends ConsumerState<CustomerGroupsScreen> {
  bool _isLoading = true;
  List<_CustomerGroup> _groups = [];
  int _selectedGroup = -1;
  List<_CustomerSummary> _customers = [];
  bool _isLoadingCustomers = false;

  List<_CustomerGroup> _buildDefaultGroups() {
    final l10n = AppLocalizations.of(context)!;
    return [
      _CustomerGroup(id: 'all', name: l10n.allCustomersGroup, icon: Icons.group_rounded, color: AppColors.info, minPurchase: 0),
      _CustomerGroup(id: 'vip', name: l10n.vipCustomersGroup, icon: Icons.star_rounded, color: AppColors.warning, minPurchase: 10000),
      _CustomerGroup(id: 'regular', name: l10n.regularCustomersGroup, icon: Icons.person_rounded, color: AppColors.success, minPurchase: 1000),
      _CustomerGroup(id: 'new', name: l10n.newCustomersGroup, icon: Icons.person_add_rounded, color: const Color(0xFF06B6D4), minPurchase: 0), // segment status color - Cyan 500
      _CustomerGroup(id: 'debt', name: l10n.customersWithDebt, icon: Icons.account_balance_rounded, color: AppColors.error, minPurchase: 0),
      _CustomerGroup(id: 'inactive', name: l10n.inactive, icon: Icons.person_off_rounded, color: Theme.of(context).colorScheme.outline, minPurchase: 0),
    ];
  }

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _loadGroupStats();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _groups = _buildDefaultGroups();
    }
  }

  Future<void> _loadGroupStats() async {
    setState(() => _isLoading = true);
    try {
      final db = GetIt.I<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // Get counts per group
      final counts = await db.customSelect(
        '''SELECT
             COUNT(*) as total,
             SUM(CASE WHEN c.created_at >= datetime('now', '-30 days') THEN 1 ELSE 0 END) as new_count,
             SUM(CASE WHEN a.balance > 0 THEN 1 ELSE 0 END) as debt_count,
             SUM(CASE WHEN c.last_purchase_at < datetime('now', '-90 days') OR c.last_purchase_at IS NULL THEN 1 ELSE 0 END) as inactive_count
           FROM customers c
           LEFT JOIN accounts a ON a.customer_id = c.id AND a.store_id = c.store_id
           WHERE c.store_id = ?''',
        variables: [Variable.withString(storeId)],
      ).getSingle();

      final total = (counts.data['total'] as int?) ?? 0;
      final newCount = (counts.data['new_count'] as int?) ?? 0;
      final debtCount = (counts.data['debt_count'] as int?) ?? 0;
      final inactiveCount = (counts.data['inactive_count'] as int?) ?? 0;
      final regularCount = (total - newCount - debtCount).clamp(0, total);
      final vipCount = (total * 0.1).round();

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _groups = [
            _CustomerGroup(id: 'all', name: l10n.allCustomersGroup, icon: Icons.group_rounded,
                color: AppColors.info, minPurchase: 0, count: total),
            _CustomerGroup(id: 'vip', name: l10n.vipCustomersGroup, icon: Icons.star_rounded,
                color: AppColors.warning, minPurchase: 10000, count: vipCount),
            _CustomerGroup(id: 'regular', name: l10n.regularCustomersGroup, icon: Icons.person_rounded,
                color: AppColors.success, minPurchase: 1000, count: regularCount),
            _CustomerGroup(id: 'new', name: l10n.newCustomers30Days, icon: Icons.person_add_rounded,
                color: Colors.cyan, minPurchase: 0, count: newCount), // segment status color
            _CustomerGroup(id: 'debt', name: l10n.haveDebts, icon: Icons.account_balance_rounded,
                color: AppColors.error, minPurchase: 0, count: debtCount),
            _CustomerGroup(id: 'inactive', name: l10n.inactive90Days, icon: Icons.person_off_rounded,
                color: Theme.of(context).colorScheme.outline, minPurchase: 0, count: inactiveCount),
          ];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCustomersForGroup(int groupIndex) async {
    setState(() { _selectedGroup = groupIndex; _isLoadingCustomers = true; });
    try {
      final db = GetIt.I<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider)!;
      final group = _groups[groupIndex];

      String whereClause;
      switch (group.id) {
        case 'new':
          whereClause = "AND c.created_at >= datetime('now', '-30 days')";
          break;
        case 'debt':
          whereClause = 'AND a.balance > 0';
          break;
        case 'inactive':
          whereClause = "AND (c.last_purchase_at < datetime('now', '-90 days') OR c.last_purchase_at IS NULL)";
          break;
        default:
          whereClause = '';
      }

      final result = await db.customSelect(
        '''SELECT
             c.id,
             c.name,
             c.phone,
             COALESCE(a.balance, 0) as debt,
             c.last_purchase_at,
             c.created_at
           FROM customers c
           LEFT JOIN accounts a ON a.customer_id = c.id AND a.store_id = c.store_id AND a.type = 'receivable'
           WHERE c.store_id = ? $whereClause
           ORDER BY c.name
           LIMIT 30''',
        variables: [Variable.withString(storeId)],
      ).get();

      if (mounted) {
        setState(() {
          _customers = result.map((row) => _CustomerSummary(
            id: row.data['id'] as String,
            name: row.data['name'] as String,
            phone: row.data['phone'] as String? ?? '',
            debt: _toDouble(row.data['debt']),
            lastPurchaseAt: _parseDate(row.data['last_purchase_at']),
          )).toList();
          _isLoadingCustomers = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingCustomers = false);
    }
  }

  double _toDouble(dynamic v) {
    if (v is int) return v.toDouble();
    if (v is double) return v;
    return 0.0;
  }

  DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.customerGroups),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _loadGroupStats),
        ],
      ),
      body: SafeArea(
        top: false,
        child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // Groups panel
                SizedBox(
                  width: MediaQuery.of(context).size.width > 600 ? 180 : MediaQuery.of(context).size.width * 0.4,
                  child: Card(
                    margin: const EdgeInsets.all(AlhaiSpacing.xs),
                    child: ListView.builder(
                      itemCount: _groups.length,
                      itemBuilder: (ctx, i) {
                        final g = _groups[i];
                        final isSelected = i == _selectedGroup;
                        return InkWell(
                          onTap: () => _loadCustomersForGroup(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? g.color.withValues(alpha: 0.15) : null,
                              border: isSelected
                                  ? BorderDirectional(end: BorderSide(color: g.color, width: 3))
                                  : null,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(g.icon, size: 16, color: g.color),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        g.name,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          color: isSelected ? g.color : null,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AlhaiSpacing.xxxs),
                                Text(
                                  l10n.customerCountLabel(g.count),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: g.color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Customers list
                Expanded(
                  child: _selectedGroup < 0
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.touch_app_rounded, size: 48, color: Theme.of(context).hintColor),
                              SizedBox(height: AlhaiSpacing.sm),
                              Text(l10n.selectGroupToViewCustomers,
                                  style: TextStyle(color: Theme.of(context).hintColor)),
                            ],
                          ),
                        )
                      : _isLoadingCustomers
                          ? const Center(child: CircularProgressIndicator())
                          : _customers.isEmpty
                              ? Center(
                                  child: Text(l10n.noCustomersInGroup,
                                      style: TextStyle(color: Theme.of(context).hintColor)),
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.all(AlhaiSpacing.xs),
                                  itemCount: _customers.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: AlhaiSpacing.xxs),
                                  itemBuilder: (ctx, i) {
                                    final c = _customers[i];
                                    final group = _groups[_selectedGroup];
                                    return Card(
                                      child: ListTile(
                                        dense: true,
                                        leading: CircleAvatar(
                                          radius: 18,
                                          backgroundColor: group.color.withValues(alpha: 0.1),
                                          child: Text(
                                            c.name.isNotEmpty ? c.name[0] : '?',
                                            style: TextStyle(color: group.color, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        title: Text(c.name, style: const TextStyle(fontSize: 13)),
                                        subtitle: Text(c.phone, style: const TextStyle(fontSize: 11)),
                                        trailing: c.debt > 0
                                            ? Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    l10n.amountSar(c.debt.toStringAsFixed(0)),
                                                    style: TextStyle(
                                                      color: AppColors.error,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  Text(l10n.debtWord, style: TextStyle(fontSize: 10, color: AppColors.error)),
                                                ],
                                              )
                                            : Icon(Icons.check_circle_rounded,
                                                color: AppColors.success, size: 18),
                                      ),
                                    );
                                  },
                                ),
                ),
              ],
            ),
      ),
    );
  }
}

class _CustomerGroup {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final double minPurchase;
  final int count;
  const _CustomerGroup({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.minPurchase,
    this.count = 0,
  });
}

class _CustomerSummary {
  final String id;
  final String name;
  final String phone;
  final double debt;
  final DateTime? lastPurchaseAt;
  const _CustomerSummary({
    required this.id,
    required this.name,
    required this.phone,
    required this.debt,
    required this.lastPurchaseAt,
  });
}
