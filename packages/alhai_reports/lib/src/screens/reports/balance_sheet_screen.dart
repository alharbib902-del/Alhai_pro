import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// شاشة الميزانية العمومية
class BalanceSheetScreen extends ConsumerStatefulWidget {
  const BalanceSheetScreen({super.key});

  @override
  ConsumerState<BalanceSheetScreen> createState() => _BalanceSheetScreenState();
}

class _BalanceSheetScreenState extends ConsumerState<BalanceSheetScreen> {
  bool _isLoading = true;
  String? _error;

  // Assets
  double _cashInDrawer = 0;
  double _accountsReceivable = 0;
  double _inventoryValue = 0;

  // Liabilities
  double _accountsPayable = 0;

  double get _totalCurrentAssets => _cashInDrawer + _accountsReceivable + _inventoryValue;
  double get _totalAssets => _totalCurrentAssets;
  double get _totalLiabilities => _accountsPayable;
  double get _equity => _totalAssets - _totalLiabilities;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() { _isLoading = true; _error = null; });
      final db = GetIt.I<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) {
        setState(() { _error = 'لم يتم تحديد المتجر'; _isLoading = false; });
        return;
      }

      // Cash in drawer - sum of completed sales - expenses - payables
      final cashResult = await db.customSelect(
        '''SELECT COALESCE(SUM(CASE WHEN type IN ('sale','cash_in') THEN amount ELSE -amount END), 0) as cash
           FROM transactions WHERE store_id = ?''',
        variables: [Variable.withString(storeId)],
      ).getSingle();

      // Accounts receivable (customer debts)
      final receivables = await db.customSelect(
        '''SELECT COALESCE(SUM(balance), 0) as total
           FROM accounts WHERE store_id = ? AND type = 'receivable' AND balance > 0''',
        variables: [Variable.withString(storeId)],
      ).getSingle();

      // Inventory value
      final invResult = await db.customSelect(
        '''SELECT COALESCE(SUM(p.current_stock * COALESCE(p.cost_price, p.price * 0.7)), 0) as total
           FROM products p WHERE p.store_id = ? AND p.current_stock > 0''',
        variables: [Variable.withString(storeId)],
      ).getSingle();

      // Accounts payable (supplier debts)
      final payables = await db.customSelect(
        '''SELECT COALESCE(SUM(balance), 0) as total
           FROM accounts WHERE store_id = ? AND type = 'payable' AND balance > 0''',
        variables: [Variable.withString(storeId)],
      ).getSingle();

      if (mounted) {
        setState(() {
          _cashInDrawer = _toDouble(cashResult.data['cash']);
          _accountsReceivable = _toDouble(receivables.data['total']);
          _inventoryValue = _toDouble(invResult.data['total']);
          _accountsPayable = _toDouble(payables.data['total']);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  double _toDouble(dynamic v) {
    if (v is int) return v.toDouble();
    if (v is double) return v;
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('الميزانية العمومية')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('الميزانية العمومية')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: AlhaiColors.error),
              const SizedBox(height: AlhaiSpacing.sm),
              Text(_error!),
              const SizedBox(height: AlhaiSpacing.sm),
              ElevatedButton(onPressed: _loadData, child: const Text('إعادة المحاولة')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('الميزانية العمومية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadData,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          children: [
            // Date
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md, vertical: AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'كما في ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AlhaiSpacing.mdl),

            // ASSETS
            _SectionHeader(
              title: 'الأصول',
              total: _totalAssets,
              color: AlhaiColors.info,
              icon: Icons.account_balance_wallet_rounded,
            ),
            const SizedBox(height: AlhaiSpacing.xs),
            _GroupCard(
              title: 'الأصول المتداولة',
              isDark: isDark,
              items: [
                _LineItem(label: 'النقد في الصندوق', amount: _cashInDrawer),
                _LineItem(label: 'ذمم مدينة (عملاء)', amount: _accountsReceivable),
                _LineItem(label: 'قيمة المخزون', amount: _inventoryValue),
              ],
              total: _totalCurrentAssets,
              totalLabel: 'إجمالي الأصول المتداولة',
            ),
            const SizedBox(height: AlhaiSpacing.sm),
            _TotalRow(label: 'إجمالي الأصول', amount: _totalAssets, color: AlhaiColors.info),

            const SizedBox(height: AlhaiSpacing.mdl),
            const Divider(thickness: 2),
            const SizedBox(height: AlhaiSpacing.mdl),

            // LIABILITIES
            _SectionHeader(
              title: 'الالتزامات',
              total: _totalLiabilities,
              color: AlhaiColors.error,
              icon: Icons.account_balance_rounded,
            ),
            const SizedBox(height: AlhaiSpacing.xs),
            _GroupCard(
              title: 'الالتزامات المتداولة',
              isDark: isDark,
              items: [
                _LineItem(label: 'ذمم دائنة (موردون)', amount: _accountsPayable),
              ],
              total: _totalLiabilities,
              totalLabel: 'إجمالي الالتزامات المتداولة',
            ),
            const SizedBox(height: AlhaiSpacing.sm),
            _TotalRow(label: 'إجمالي الالتزامات', amount: _totalLiabilities, color: AlhaiColors.error),

            const SizedBox(height: AlhaiSpacing.mdl),
            const Divider(thickness: 2),
            const SizedBox(height: AlhaiSpacing.mdl),

            // EQUITY
            _SectionHeader(
              title: 'حقوق الملكية',
              total: _equity,
              color: AlhaiColors.success,
              icon: Icons.trending_up_rounded,
            ),
            const SizedBox(height: AlhaiSpacing.xs),
            Card(
              color: _equity >= 0
                  ? AlhaiColors.success.withValues(alpha: 0.08)
                  : AlhaiColors.error.withValues(alpha: 0.08),
              child: Padding(
                padding: const EdgeInsets.all(AlhaiSpacing.mdl),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('صافي حقوق الملكية',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(
                      '${_equity.toStringAsFixed(0)} ر.س',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _equity >= 0 ? AlhaiColors.successDark : AlhaiColors.errorDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AlhaiSpacing.mdl),
            // Equation check
            Card(
              color: isDark ? const Color(0xFF1E293B) : theme.colorScheme.surfaceContainerLowest,
              child: Padding(
                padding: const EdgeInsets.all(AlhaiSpacing.md),
                child: Column(
                  children: [
                    Text('معادلة المحاسبة',
                        style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                    const SizedBox(height: AlhaiSpacing.xs),
                    Text(
                      'الأصول = الالتزامات + حقوق الملكية',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: AlhaiSpacing.xxs),
                    Text(
                      '${_totalAssets.toStringAsFixed(0)} = '
                      '${_totalLiabilities.toStringAsFixed(0)} + '
                      '${_equity.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: (_totalAssets - _totalLiabilities - _equity).abs() < 1
                            ? AlhaiColors.success
                            : AlhaiColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final double total;
  final Color color;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.total,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: AlhaiSpacing.xs),
        Text(title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        const Spacer(),
        Text(
          '${total.toStringAsFixed(0)} ر.س',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}

class _GroupCard extends StatelessWidget {
  final String title;
  final bool isDark;
  final List<_LineItem> items;
  final double total;
  final String totalLabel;

  const _GroupCard({
    required this.title,
    required this.isDark,
    required this.items,
    required this.total,
    required this.totalLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                )),
            const Divider(),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item.label, style: const TextStyle(fontSize: 13)),
                  Text(
                    '${item.amount.toStringAsFixed(0)} ر.س',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(totalLabel,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                Text(
                  '${total.toStringAsFixed(0)} ر.س',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _TotalRow({required this.label, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md, vertical: AlhaiSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 15)),
          Text(
            '${amount.toStringAsFixed(0)} ر.س',
            style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _LineItem {
  final String label;
  final double amount;
  const _LineItem({required this.label, required this.amount});
}
